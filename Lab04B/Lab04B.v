//---------------------------------------------------------//
//- Digital IC Design 2025                                 //
//-                                                        //
//- Lab04B: Verilog Behavioral Level                       //
//---------------------------------------------------------//

`timescale 1ns/1ps

module heptagon(
  input              clk,      // Clock signal
  input              reset,    // Asynchronous active-high reset
  input      [9:0]   X,        // X-coordinate input (unsigned)
  input      [9:0]   Y,        // Y-coordinate input (unsigned)
  output             valid,    // Output valid signal
  output     [2:0]   Index,    // Sorted heptagon index output
  output     [18:0]  Area      // Sorted heptagon area output
);

//** Add your code below this line **//

  reg             sort_start, area_start;
  wire            sort_done, area_done;
  reg     [5:0]   input_count;
  reg     [9:0]   x_buf[0:34];
  reg     [9:0]   y_buf[0:34];

//output wire to reg
  reg             valid_reg;
  reg     [2:0]   Index_reg;
  reg     [18:0]  Area_reg;
  assign valid=valid_reg;
  assign Index=Index_reg;
  assign Area=Area_reg;

//signal
  reg     [2:0]   state;
  parameter       IDLE=3'b0, IN=3'b1, START_SORT=3'd2, WAIT_SORT=3'd3, START_AREA=3'd4, WAIT_AREA=3'd5, SORT_RESULT=3'd6, OUT=3'd7;

  reg [9:0] x_hepta[0:6],y_hepta[0:6];
  wire [9:0] x0,x1,x2,x3,x4,x5,x6,y0,y1,y2,y3,y4,y5,y6;

  integer i, j;
  wire [18:0] area_result;
// output storage
  reg [18:0]  area_mem[0:4];      //output to area
  reg [2:0]   index_mem[0:4];     //output to index
  reg [2:0]   hepta_index;        //which hepta

  reg [2:0]   index_temp;
  reg [18:0]  area_memtemp;
  reg [2:0]   index_memtemp;

	reg [2:0] sort_i;
	reg [2:0] sort_j;
  heptagon_sortxy hsort(
    .clk(clk),
    .reset(reset),
    .start(sort_start),
    .xin0(x_hepta[0]),
    .xin1(x_hepta[1]),
    .xin2(x_hepta[2]),
    .xin3(x_hepta[3]),
    .xin4(x_hepta[4]),
    .xin5(x_hepta[5]),
    .xin6(x_hepta[6]),
    .yin0(y_hepta[0]),
    .yin1(y_hepta[1]),
    .yin2(y_hepta[2]),
    .yin3(y_hepta[3]),
    .yin4(y_hepta[4]),
    .yin5(y_hepta[5]),
    .yin6(y_hepta[6]),
//output
    .x0(x0),
    .x1(x1),
    .x2(x2),
    .x3(x3),
    .x4(x4),
    .x5(x5),
    .x6(x6),
    .y0(y0),
    .y1(y1),
    .y2(y2),
    .y3(y3),
    .y4(y4),
    .y5(y5),
    .y6(y6),
    .done(sort_done)
  );

  heptagon_area harea(
    .clk(clk),
    .reset(reset),
    .start(area_start),
    .x0(x0),
    .x1(x1),
    .x2(x2),
    .x3(x3),
    .x4(x4),
    .x5(x5),
    .x6(x6), 
    .y0(y0), 
    .y1(y1),
    .y2(y2),
    .y3(y3),
    .y4(y4),
    .y5(y5),
    .y6(y6),
//output
    .done(area_done),
    .area(area_result)
  );

  always@(posedge clk) begin
    if (reset == 1) begin
      sort_start <= 0;
      area_start <= 0;
      hepta_index <= 0;
      input_count <= 0;
      index_temp <= 0;
      valid_reg <= 0;
      state <= IDLE;
      Index_reg <=0;
      Area_reg <=0;
      sort_i <= 0;
	    sort_j <= 0;
    end else begin
      case(state)
        IDLE: begin
          valid_reg <= 0;

          x_buf[input_count] <= X;
          y_buf[input_count] <= Y;
          input_count <= input_count+1;
          state <= IN;
        end

        IN:begin
          x_buf[input_count] <= X;
          y_buf[input_count] <= Y;
          input_count <= input_count+1;

          if(input_count == 34)
              state <= START_SORT;
          else
              state <= IN;
        end

        START_SORT: begin  //2
          for (i = 0; i < 7; i = i + 1) begin
            x_hepta[i] <= x_buf[hepta_index * 7 +i];
            y_hepta[i] <= y_buf[hepta_index * 7 +i];
          end
          sort_start <= 1 ;
          state <= WAIT_SORT;
        end

        WAIT_SORT: begin   //3
          sort_start <= 0;
          if(sort_done == 1)begin
            area_start <= 1;
            state <=START_AREA;
          end
          else
              state <= WAIT_SORT;
        end

        START_AREA: begin  //4
          area_start <= 0;
          if(area_done == 1)begin
            state <= WAIT_AREA;
          end else begin
              state <= START_AREA;
          end
        end

        WAIT_AREA:begin   //5
          area_mem[hepta_index] <= area_result;
			    index_mem[hepta_index] <= hepta_index + 1;
          if (hepta_index == 4) begin  
		        state <= SORT_RESULT;
		        sort_i <= 0; // 進入排序前，初始化計數器
		        sort_j <= 0;
			    end else begin
		        hepta_index <= hepta_index + 1;
		        state <= START_SORT;
			    end
        end

        SORT_RESULT:begin  //6
	        if (sort_i < 4) begin
		        if (sort_j < 4 - sort_i) begin
			        if (area_mem[sort_j] < area_mem[sort_j+1]) begin
                area_mem[sort_j]    <= area_mem[sort_j+1];
                area_mem[sort_j+1]  <= area_mem[sort_j];
                index_mem[sort_j]   <= index_mem[sort_j+1];
                index_mem[sort_j+1] <= index_mem[sort_j];
	            end
	            // j++
	            sort_j <= sort_j + 1;
            end else begin
	            sort_j <= 0;
	            sort_i <= sort_i + 1;
            end
          end else begin
	          // i=4
            state <= OUT;
            index_temp <= 0;
          end
        end

        OUT:begin      //7
          if(index_temp == 5) begin
            valid_reg <= 0;
            state <= IDLE;
          end  else begin
            valid_reg <= 1;
            Index_reg <= index_mem[index_temp];
            Area_reg <= area_mem[index_temp];
            index_temp <= index_temp + 1;
            state <= OUT;
          end
	      end
      endcase
    end
  end
endmodule


module heptagon_sortxy(
    input              clk,
    input              reset,
    input              start,
    input      [9:0] xin0,        // X-coordinate input (unsigned)
    input      [9:0] xin1,
    input      [9:0] xin2,
    input      [9:0] xin3,
    input      [9:0] xin4,
    input      [9:0] xin5,
    input      [9:0] xin6,
    input      [9:0] yin0,        // Y-coordinate input (unsigned)
    input      [9:0] yin1,
    input      [9:0] yin2,
    input      [9:0] yin3,
    input      [9:0] yin4,
    input      [9:0] yin5,
    input      [9:0] yin6,

    output     reg     [9:0] x0,
    output     reg     [9:0] x1,
    output     reg     [9:0] x2,
    output     reg     [9:0] x3,
    output     reg     [9:0] x4,
    output     reg     [9:0] x5,
    output     reg     [9:0] x6,
    output     reg     [9:0] y0,
    output     reg     [9:0] y1,
    output     reg     [9:0] y2,
    output     reg     [9:0] y3,
    output     reg     [9:0] y4,
    output     reg     [9:0] y5,
    output     reg     [9:0] y6,
    output     reg     done
);

    reg             [1:0] statesort;
    parameter             SIGN=2'b0, SORT=2'd1, OUT=2'd2;   //signal

//inputxy turn to sign to compute cross product
    reg signed [10:0] sx[0:6];
    reg signed [10:0] sy[0:6];
    reg signed [10:0] tempx,tempy;

    integer i,j;
    reg [9:0] X[0:6];    //group

    always @(*)begin
        X[0] = xin0;
        X[1] = xin1;
        X[2] = xin2;
        X[3] = xin3;
        X[4] = xin4;
        X[5] = xin5;
        X[6] = xin6;
    end

    reg [9:0] Y[0:6];
    always @(*)begin
        Y[0] = yin0;
        Y[1] = yin1;
        Y[2] = yin2;
        Y[3] = yin3;
        Y[4] = yin4;
        Y[5] = yin5;
        Y[6] = yin6;
    end

    always @(posedge clk) begin       //sort xy
        if (reset == 1) begin
            statesort <= SIGN;
            done <= 0;
        end else begin

        case (statesort)
            SIGN:begin     //turn to sign number
                if (start == 1) begin
                    statesort <= SORT;
                    done <=0;
                end
                else begin
                    statesort <= SIGN;
                    done <=0;
                end
            end

            SORT:begin
                statesort <= OUT;
            end

            OUT:begin     //output the sorted point(x1,y1) to (x7,y7)
                x0 <= sx[0][9:0];
                x1 <= sx[1][9:0];
                x2 <= sx[2][9:0];
                x3 <= sx[3][9:0];
                x4 <= sx[4][9:0];
                x5 <= sx[5][9:0];
                x6 <= sx[6][9:0];
                y0 <= sy[0][9:0];
                y1 <= sy[1][9:0];
                y2 <= sy[2][9:0];
                y3 <= sy[3][9:0];
                y4 <= sy[4][9:0];
                y5 <= sy[5][9:0];
                y6 <= sy[6][9:0];

                done <= 1;
                statesort <= SIGN;
            end
        endcase
        end
    end

    always@(*) begin
    case (statesort)
        SIGN:begin      //turn to sign number
            if (start == 1) begin
                for(i = 0; i < 7; i=i+1)
                begin
                    sx[i] = {1'b0,X[i]};
                    sy[i] = {1'b0,Y[i]};
                end
            end
        end
        SORT:begin  //change the point to counterwise order based on cross neg|pos
        for(i = 0; i < 5; i = i + 1)begin
            for(j = 1; j <=  6 ; j = j + 1)begin
                if((j<6-i) && cross_product(sx[0],sy[0],sx[j],sy[j],sx[j+1],sy[j+1])<0) begin
                    tempx=sx[j];
                    tempy=sy[j];
                    sx[j]=sx[j+1];
                    sy[j]=sy[j+1];
                    sx[j+1]=tempx;
                    sy[j+1]=tempy;
                end
            end
        end
        end
    endcase
    end

    function signed [21:0] cross_product;       //cross compute
        input signed [10:0] X0,Y0,X1,Y1,X2,Y2;
        cross_product = (X1-X0) * (Y2-Y0) - (X2-X0) * (Y1-Y0);
    endfunction

endmodule

module heptagon_area(
    input              clk,
    input              reset,
    input              start,
    input      [9:0] x0,
    input      [9:0] x1,
    input      [9:0] x2,
    input      [9:0] x3,
    input      [9:0] x4,
    input      [9:0] x5,
    input      [9:0] x6,
    input      [9:0] y0,
    input      [9:0] y1,
    input      [9:0] y2,
    input      [9:0] y3,
    input      [9:0] y4,
    input      [9:0] y5,
    input      [9:0] y6,
    output     reg done,
    output     reg [18:0] area
);

    wire [9:0] x_arr[0:6];
    assign x_arr[0] = x0;
    assign x_arr[1] = x1;
    assign x_arr[2] = x2;
    assign x_arr[3] = x3;
    assign x_arr[4] = x4;
    assign x_arr[5] = x5;
    assign x_arr[6] = x6;

    wire [9:0] y_arr[0:6];
    assign y_arr[0] = y0;
    assign y_arr[1] = y1;
    assign y_arr[2] = y2;
    assign y_arr[3] = y3;
    assign y_arr[4] = y4;
    assign y_arr[5] = y5;
    assign y_arr[6] = y6;

    reg             [1:0] statearea;
    parameter             SIGN=2'b0, CALC=2'b1, OUT=2'd2;   //signal

    reg             [2:0] i;
    reg signed [20:0] sum,sum1,sum2,sum3,sum4,sum5,sum6;      //10bit cal to 20+sign

    reg signed [10:0] sx[0:7];    //inputxy turn to sign to compute partial calculate x[7]set to x[0] calculate x(i+1)
    reg signed [10:0] sy[0:7];

    always@(posedge clk)begin       //sort xy
        if (reset == 1)
        begin
            statearea <= SIGN;
            done <= 0;
            sum <= 0;
            area <= 0;
            i <= 0;
        end else begin

        case(statearea)
            SIGN:begin     //change to sign num
                done <=0;
                if (start == 1)  begin
                    sum <= 0;
                    i <= 0;
                    statearea <= CALC;
                end
                else
                    statearea <= SIGN;
            end

            CALC:begin      //calculate sum
            statearea <= OUT;
            end

            OUT:begin       //change sign if negative area  then change to unsign area
            if(sum6 < 0)begin
                area <= (-sum6) >> 1;
                done <= 1;
                statearea <= SIGN;
            end
            else begin
                area <= sum6 >> 1;
                done <= 1;
                statearea <= SIGN;
            end
            end
        endcase
        end
    end

    always@(*) begin
    case (statearea)
        SIGN:begin      //change to sign num
            if (start == 1) begin
                for(i = 0;i < 7;i = i+1)
                begin
                    sx[i] = {1'b0, x_arr[i]};
                    sy[i] = {1'b0, y_arr[i]};
                end
                sx[7] = x_arr[0];
                sy[7] = y_arr[0];

            end
        end

        CALC:begin      //calculate sum
            sum = area_product(sx[0],sy[0],sx[1],sy[1]);
            sum1 = sum + area_product(sx[1],sy[1],sx[2],sy[2]);
            sum2 = sum1 + area_product(sx[2],sy[2],sx[3],sy[3]);
            sum3 = sum2 + area_product(sx[3],sy[3],sx[4],sy[4]);
            sum4 = sum3 + area_product(sx[4],sy[4],sx[5],sy[5]);
            sum5 = sum4 + area_product(sx[5],sy[5],sx[6],sy[6]);
            sum6 = sum5 + area_product(sx[6],sy[6],sx[7],sy[7]);
        end
    endcase
    end

    function signed [20:0] area_product;        //area compute
    input signed [10:0] X0,Y0,X1,Y1;
    area_product = X0*Y1 - X1*Y0;
    endfunction
endmodule