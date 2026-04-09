`timescale 100ps/10ps

module triangle(clk, reset, nt, xi, yi, busy, po, xo, yo);
input       clk, reset, nt;
input [2:0] xi, yi;
output      busy, po;
output [2:0] xo, yo;

//** Add your code below this line **//

reg[2:0] x1,x2,x3,y1,y2,y3;
reg[2:0] scan_x,scan_y;
reg signed [6:0] lhs,rhs;
reg signed [6:0] dx1,dx2;

reg [2:0]xo_reg,yo_reg;
reg po_reg,busy_reg;
assign po=po_reg;
assign xo=xo_reg;
assign yo=yo_reg;
assign busy=busy_reg;

reg[2:0] state;
parameter IDLE=3'd0, INPUT2=3'd1, INPUT3=3'd2, CALC=3'd3, EMIT=3'd4, EMIT2=3'd5, EMIT3=3'd6, DONE=3'd7;

always @(posedge clk or posedge reset) begin    //state logic
    if(reset) begin
        state <= IDLE;
    end else begin
        case(state)
            IDLE: begin
                if (nt)
                    state <= INPUT2;
                else
                    state <= IDLE;
            end
            
            INPUT2: begin
                state <= INPUT3;
            end
            
            INPUT3: begin
                state <= CALC;
            end
            
            CALC: begin
                state <=EMIT;
            end
            
            EMIT: begin
                if(scan_y <= y2) begin
                    state <= EMIT;
                end else begin
                    state <= EMIT2;
                end
            end
            
            EMIT2:begin
                state <=EMIT3;
            end
            
            EMIT3:begin
                if ( scan_y >= y2 && scan_y <= y3) begin
                    state <= EMIT3;
                end else begin
                    state <= DONE;
                end
            end
            
            DONE: begin
                state <= IDLE;
            end
        endcase
    end
end

always @(posedge clk or posedge reset) begin    //cal logic
    if(reset) begin
        busy_reg <= 0;
        po_reg <= 0;
        xo_reg <= 0;
        yo_reg <= 0;
        scan_x <= 0;
        scan_y <= 0;
        
    end else begin
        case(state)
            IDLE: begin
                x1 <= xi;
                y1 <= yi;
            end
            
            INPUT2: begin
                x2 <= xi;
                y2 <= yi;
                busy_reg <= 1;
            end
            
            INPUT3: begin
                x3 <= xi;
                y3 <= yi;
            end
            
            CALC: begin
                scan_x <= 0;
                scan_y <= y1;
            end
            
            EMIT: begin
                if(scan_y <= y2)begin
                    if(((x1 > x2) ?(rhs <= lhs):(lhs <= rhs))&& scan_x >=((x1 > x2) ? x2 : x1) && scan_x <= ((x1 > x2) ? x1 : x2)) begin
                        xo_reg <= scan_x;
                        yo_reg <= scan_y;
                        po_reg <=1;
                    end else begin
                        po_reg <=0;
                    end
                    if (scan_x == 7)begin
                        scan_x <= 0;
                        scan_y <= scan_y + 1;
                    end else begin
                        scan_x <= scan_x + 1;
                    end
                end
                if((x2 > x1) && (scan_x == x2) && (scan_y == y2))begin
                    po_reg <=0;
                end
            end
            
            EMIT2:begin
                if(x2 > x1)begin
                    xo_reg <= x2;
                    yo_reg <= y2;
                    po_reg <= 1;
                end
            end
            
            EMIT3: begin
                if(scan_y <= y3)begin
                    if(((x1 > x2) ?(rhs <= lhs):(lhs <= rhs)) && scan_x >=((x1 < x2) ? x1 : x2) && scan_x <= ((x1 > x2) ? x1 : x2)) begin
                        xo_reg <= scan_x;
                        yo_reg <= scan_y;
                        po_reg <=1;
                    end else begin
                        po_reg <=0;
                    end
                    if (scan_x == 7)begin
                        scan_x <= 0;
                        scan_y <= scan_y + 1;
                    end else begin
                        scan_x <= scan_x + 1;
                    end
                end
            end
            
            DONE: begin
                busy_reg <= 0;
            end
        endcase
    end
end

always @(*) begin
    case (state)
        EMIT:begin
            dx1 = scan_x - x1;
            dx2 = x2 - x1;
            lhs = dx1 * (y2 - y1);
            rhs = dx2 * (scan_y - y1);
        end
        
        EMIT3:begin
            dx1 = scan_x - x2;
            dx2 = x3 - x2;
            lhs = dx1 * (y3 - y2);
            rhs = dx2 * (scan_y - y2);
        end
    endcase
end

endmodule