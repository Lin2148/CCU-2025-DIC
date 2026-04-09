//-----------------------------------------------------------------//
//- Digital IC Design 2025                                         //
//- Lab08: Low-Power Syntheis                                      //
//-----------------------------------------------------------------//

//cadence translate_off
`include "/usr/chipware/CHIPWARE.v"
//cadence translate_on

module TRANSFORMER_ATTENTION(clk,
    reset,
    MATRIX_Q,
    MATRIX_K,
    MATRIX_V,
    en,
    done,
    answer);

input       clk;
input       reset;
input       en;
input [3:0] MATRIX_Q;
input [3:0] MATRIX_K;
input [3:0] MATRIX_V;

output reg [17:0] answer;
output reg done;

//** Add your code below this line **//
//matrix mem
reg [3:0] Q[0:63], K[0:63], V[0:63], KT[0:63];
reg [11:0] W[0:63];
reg [17:0] O[0:63];

//counter
reg [6:0] load_count, mull_count, mul2_count, out_count;

//state
reg [2:0] state;
parameter IDLE=3'd0, LOAD=3'd1, TRANSPOSE=3'd2, MUL1=3'd3, MUL2=3'd4, OUTPUT=3'd5, DONE=3'd6, CALMUL2=3'd7;

//loop for transpose
integer i, j, k, q;

//inter calulation for matrix mul1
wire [7:0] product[0:7];
reg [11:0] productsum;
reg [3:0] Q_row[0:7];   //i judge row
reg [3:0] KT_col[0:7];  // j judge col

//inter calulation for matrix mul2
wire [15:0] product2 [0:7];
reg [17:0] productsum2;
reg [11:0] W_row [0:7];
reg [3:0] V_col [0:7];
reg [17:0] sum4,sum5,sum6,sum7;
reg [17:0] ssum2,ssum3;

reg [6:0] i_idx, j_idx;
reg [6:0] i_idx2, j_idx2;

//cw
    CHIPWARE #(.wA(4), .wB(4)) m1 (.A(Q_row[0]), .B(KT_col[0]), .TC(0),.Z(product[0]));
    CHIPWARE #(.wA(4), .wB(4)) m2 (.A(Q_row[1]), .B(KT_col[1]), .TC(0),.Z(product[1]));
    CHIPWARE #(.wA(4), .wB(4)) m3 (.A(Q_row[2]), .B(KT_col[2]), .TC(0),.Z(product[2]));
    CHIPWARE #(.wA(4), .wB(4)) m4 (.A(Q_row[3]), .B(KT_col[3]), .TC(0),.Z(product[3]));
    CHIPWARE #(.wA(4), .wB(4)) m5 (.A(Q_row[4]), .B(KT_col[4]), .TC(0),.Z(product[4]));
    CHIPWARE #(.wA(4), .wB(4)) m6 (.A(Q_row[5]), .B(KT_col[5]), .TC(0),.Z(product[5]));
    CHIPWARE #(.wA(4), .wB(4)) m7 (.A(Q_row[6]), .B(KT_col[6]), .TC(0),.Z(product[6]));
    CHIPWARE #(.wA(4), .wB(4)) m8 (.A(Q_row[7]), .B(KT_col[7]), .TC(0),.Z(product[7]));

    CHIPWARE #(.wA(12), .wB(4)) m9 (.A(W_row[0]), .B(V_col[0]), .TC(0),.Z(product2[0]));
    CHIPWARE #(.wA(12), .wB(4)) m10 (.A(W_row[1]), .B(V_col[1]), .TC(0),.Z(product2[1]));
    CHIPWARE #(.wA(12), .wB(4)) m11 (.A(W_row[2]), .B(V_col[2]), .TC(0),.Z(product2[2]));
    CHIPWARE #(.wA(12), .wB(4)) m12 (.A(W_row[3]), .B(V_col[3]), .TC(0),.Z(product2[3]));
    CHIPWARE #(.wA(12), .wB(4)) m13 (.A(W_row[4]), .B(V_col[4]), .TC(0),.Z(product2[4]));
    CHIPWARE #(.wA(12), .wB(4)) m14 (.A(W_row[5]), .B(V_col[5]), .TC(0),.Z(product2[5]));
    CHIPWARE #(.wA(12), .wB(4)) m15 (.A(W_row[6]), .B(V_col[6]), .TC(0),.Z(product2[6]));
    CHIPWARE #(.wA(12), .wB(4)) m16 (.A(W_row[7]), .B(V_col[7]), .TC(0),.Z(product2[7]));

always @(posedge clk or posedge reset) begin    //state logic
    if (reset) begin
        state <= IDLE;
    end else begin
        case(state)
            IDLE: begin
                if (en)
                    state <= LOAD;
                else
                    state <= IDLE;
            end
            LOAD: begin
                if (load_count == 64 && en == 0)
                    state <= TRANSPOSE;
                else
                    state <= LOAD;
            end

            TRANSPOSE: begin
                state <= MUL1;
            end

            MUL1: begin
                if (mull_count == 63)
                    state <= MUL2;
                else
                    state <= MUL1;
            end

            MUL2: begin
                if (mul2_count == 67)
                    state <= OUTPUT;
                else
                    state <= CALMUL2;
            end

            CALMUL2:begin
                state <= MUL2;
            end

            OUTPUT: begin
                if (out_count == 63 && done == 1 )
                    state <= DONE;
                else
                    state <= OUTPUT;
            end

            DONE: begin
                state <= IDLE;
            end
        endcase
    end
end

always @(posedge clk or posedge reset) begin    //cal logic
    if (reset) begin
        load_count <= 0;
        mull_count <= 0;
        mul2_count <= 0;
        out_count <= 0;
        i_idx <= 0;
        j_idx <= 0;
        i_idx2 <= 0;
        j_idx2 <= 0;
        done <= 0;
    end else begin
    case(state)
        IDLE: begin
            if (en) begin
                Q[load_count] <= MATRIX_Q;
                K[load_count] <= MATRIX_K;
                V[load_count] <= MATRIX_V;
                load_count <= load_count + 1;
            end
        end
        LOAD: begin
            Q[load_count] <= MATRIX_Q;
            K[load_count] <= MATRIX_K;
            V[load_count] <= MATRIX_V;
            load_count <= load_count + 1;
        end

        TRANSPOSE: begin
            for (i = 0; i < 8; i = i + 1 )begin
                for (j = 0; j < 8; j = j + 1) begin
                    KT[(j << 3) + i] <= K[(i << 3) + j];
                end
            end
        end

        MUL1: begin
            if (j_idx == 7)begin        //use i,j_idx for 64 interproduct
                j_idx <= 0;
                i_idx <= i_idx + 1;
            end else begin
                j_idx <= j_idx + 1;
            end

            W[(i_idx << 3) + j_idx] <= productsum;
            mull_count <= mull_count + 1;
        end
        MUL2: begin
            for (q = 0; q < 8; q = q + 1)begin          //need 8 row and col in 1 time then compute pro.sum
                W_row[q] = W[(i_idx2 << 3) + q];
                V_col[q] = V[(q << 3) + j_idx2];
            end
            mul2_count <= mul2_count + 1;
            sum4 <= product2[0]+product2[1];
            sum5 <= product2[2]+product2[3];
            sum6 <= product2[4]+product2[5];
            sum7 <= product2[6]+product2[7];
            productsum2 <= ssum2 + ssum3;
            if (j_idx2 == 7)begin       //use i,j_idx for 64 interproduct
                j_idx2 <= 0;
                i_idx2 <= i_idx2 + 1;
            end else begin
                j_idx2 <= j_idx2 + 1;
            end
        end

        CALMUL2: begin
            O[(i_idx2 << 3) + j_idx2 - 3] <= productsum2;
            ssum2 <= sum4 + sum5;
            ssum3 <= sum6 + sum7;

        end

        OUTPUT: begin
            answer <= O[out_count];
            out_count <= out_count + 1;
            done <= 1;
        end
    endcase
    end
end

always @(*) begin

    for (k = 0; k < 8; k = k + 1)begin
    Q_row[k] = 0;
    KT_col[k]=0;
    end

    productsum =0;

    case(state)
    default:;
    MUL1: begin
        for (k = 0; k < 8; k = k + 1)begin          //need 8 row and col in 1 time then compute pro.sum
            Q_row[k] = Q[(i_idx << 3) + k];
            KT_col[k] = KT[(k << 3) + j_idx];
        end
        productsum = product[0] + product[1];
        productsum = productsum + product[2];
        productsum = productsum + product[3];
        productsum = productsum + product[4];
        productsum = productsum + product[5];
        productsum = productsum + product[6];
        productsum = productsum + product[7];
    end
    endcase
end

endmodule