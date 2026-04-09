//--------------------------------------------------//
//- Digital IC Design 2025                          //
//-                                                 //
//- Final Project: FP_MUL                           //
//--------------------------------------------------//
`timescale 1ns/1ps

module FP_MUL(CLK, RESET, ENABLE, DATA_IN, DATA_OUT, READY);

// I/O Ports
input           CLK; //clock signal
input           RESET; //sync. RESET=1
input           ENABLE; //input data sequence when ENABLE =1
input   [7:0]   DATA_IN; //input data sequence
output  [7:0]   DATA_OUT; //ouput data sequence
output          READY; //output data is READY when READY=1

reg             READY;
reg     [4:0]   counter_in;
reg     [7:0]   input_A [0:7];
reg     [7:0]   input_B [0:7];
reg             in_data_rdy;
reg     [7:0]   output_Z [0:7];
reg     [7:0]   DATA_OUT;
reg     [3:0]   counter_out;

integer         i;

//sign,exp,frac reg
reg sign_A, sign_B, sign_Z;             //1bit
reg [10:0] exp_A, exp_B, exp_Z;         //11bit
reg [52:0] frac_A, frac_B, normmult_Z, mult_op_A, mult_op_B;      //1+52bit
reg [105:0] mult_Z;                     //(1+52)*(1+52) 106bit
reg [63:0]  result_Z;
wire [51:0] frac_A_body,frac_B_body;
assign frac_A_body = {input_A[6][3:0], input_A[5], input_A[4], input_A[3], input_A[2], input_A[1], input_A[0]};
assign frac_B_body = {input_B[6][3:0], input_B[5], input_B[4], input_B[3], input_B[2], input_B[1], input_B[0]};
//for mult
reg [5:0] mult_cnt;
reg [105:0] mult_acc;

// state
reg [2:0] state,next_state;
parameter IDLE=3'd0, LOAD=3'd1, CALC=3'd2, MULT=3'd3, NORM=3'd4, REBUILD=3'd5, OUTZ=3'd6, OUTPUT=3'd7;
reg result_valid;

always @(posedge CLK ) begin
    if(RESET)
        state <= IDLE;
    else
        state <= next_state;
end
always @(*) begin
    case (state)
        IDLE:begin
            next_state =(ENABLE) ? LOAD:IDLE;
        end
        LOAD:begin
            next_state =(counter_in == 5'd15) ? CALC : LOAD;
        end
        CALC:begin
            next_state =(result_valid ) ? MULT : CALC;
        end
        MULT:begin
            next_state = (mult_cnt == 6'd55) ? NORM : MULT;
        end
        NORM:begin
            next_state = REBUILD;
        end
        REBUILD:begin
            next_state = OUTZ;
        end
        OUTZ:begin
            next_state = OUTPUT;
        end
        OUTPUT:begin
            next_state = (counter_out == 4'd8) ? IDLE : OUTPUT;
        end
        default: next_state =IDLE;
    endcase
end

// round
wire guard,round,sticky;
wire [53:0] round_Z;
wire round_add;

assign guard = mult_Z[105] ? mult_Z[52] : mult_Z[51];
assign round = mult_Z[105] ? mult_Z[51] : mult_Z[50];
assign sticky = mult_Z[105] ? |mult_Z[50:0] : |mult_Z[49:0];
assign lsb = normmult_Z[0];
assign round_add = ((guard && round) || (guard && !round && sticky) || (guard && !round && !sticky && lsb));
assign round_Z = normmult_Z + round_add;

//Latch input data sequence
always@(posedge CLK)
begin
    if(RESET) begin
        counter_in <= 5'd0;
        in_data_rdy <= 1'b0;
        for(i=0; i <= 7; i=i+1) input_A[i] <= 0;
        for(i=0; i <= 7; i=i+1) input_B[i] <= 0;
    end else begin
        case (state)
            IDLE:
                if (ENABLE) begin
                    input_A[counter_in] <= DATA_IN;
                    counter_in <= counter_in + 1'b1;
                end
            LOAD:
            begin
                if (ENABLE) begin
                    if (counter_in < 8)
                        input_A[counter_in] <= DATA_IN;
                    else
                        input_B[counter_in-8] <= DATA_IN;
                    counter_in <= counter_in + 1'b1;
                    in_data_rdy <= (counter_in == 15);
                end
            end
            default:
            begin
                in_data_rdy <= 1'b0;
                counter_in <= 5'd0;
            end
        endcase
    end
end

//cut 3 part of fp
always@(posedge CLK)
begin
    if(RESET) begin
        result_valid <= 0;
        sign_A <= 0;
        exp_A <= 0;
        frac_A <=0;
        sign_B <= 0;
        exp_B <= 0;
        frac_B <=0;
    end else if (state == CALC ) begin
        sign_A <= input_A[7][7];
        exp_A <= {input_A[7][6:0], input_A[6][7:4]};
        frac_A <= {1'b1, frac_A_body};
        sign_B <= input_B[7][7];
        exp_B <= {input_B[7][6:0], input_B[6][7:4]};
        frac_B <= {1'b1, frac_B_body};
        result_valid <= 1;
    end else
        result_valid <= 0;
end

//mult
always@(posedge CLK)
begin
    if(RESET) begin
        mult_op_A <= 0;
        mult_op_B <= 0;
        mult_cnt <= 0;
        mult_acc <= 0;
    end else if (state == MULT ) begin
        if (mult_cnt == 0)begin
            mult_op_A <= frac_A;
            mult_op_B <= frac_B;
            mult_cnt <= 1;
            mult_acc <= 0;
        end else if (mult_cnt <= 54) begin
            if(mult_op_B[0])
            begin
                mult_acc <= mult_acc + ({{53{1'b0}}, mult_op_A} << (mult_cnt-1));
            end
            mult_op_B <= mult_op_B >> 1;
            mult_cnt <= mult_cnt + 1;
            if (mult_cnt == 54)
                mult_Z <= mult_acc;
        end else if (mult_cnt == 55)
            mult_cnt <= 0;
    end
end

//normalize Z
always@(posedge CLK)
begin
    if(RESET) begin
        normmult_Z <= 0;
        sign_Z <= 0;
        exp_Z <= 0;
    end else if (state == NORM)begin
        normmult_Z <= mult_Z[105] ? mult_Z[105:53] : mult_Z[104:52];
        exp_Z <= exp_A + exp_B - 11'd1023 + mult_Z[105];
        sign_Z <= sign_A ^ sign_B;
    end
end

//rebuild write output
always@(posedge CLK)
begin
    if(RESET) begin
        result_Z <= 0;
    end else if (state == REBUILD ) begin
        result_Z <= {sign_Z, exp_Z, round_Z[51:0]};
    end
end

//outZ
always@(posedge CLK)
begin
    if(RESET) begin
        for(i=0; i <= 7; i=i+1) output_Z[i] <= 0;
    end else if (state == OUTZ) begin
        output_Z[0] <= result_Z[7:0];
        output_Z[1] <= result_Z[15:8];
        output_Z[2] <= result_Z[23:16];
        output_Z[3] <= result_Z[31:24];
        output_Z[4] <= result_Z[39:32];
        output_Z[5] <= result_Z[47:40];
        output_Z[6] <= result_Z[55:48];
        output_Z[7] <= result_Z[63:56];
    end
end

// 0 nan infinite operation
/*
*/

//Output Control
always@(posedge CLK)
begin
    if(RESET) begin
        counter_out <= 0;
        READY <= 0;
        DATA_OUT <= 0;
    end else if (state == OUTPUT) begin
        DATA_OUT <= output_Z[counter_out];
        counter_out <= counter_out + 1;
        READY <= 1;
    end else begin
        READY <= 0;
        counter_out <= 0;
    end
end

endmodule