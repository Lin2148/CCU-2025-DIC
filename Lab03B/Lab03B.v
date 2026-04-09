//---------------------------------------------------------//
//- Digital IC Design 2025                                 //
//-                                                        //
//- LAB03B: Verilog Gate Level                             //
//---------------------------------------------------------//

`timescale 1ns/1ps

module lab03b (
    input  [7:0] a,
    input  [7:0] b,
    output [5:0] out
);

//Examples to instantiate the cells from cell library
//AN2*** u1( .A1(a), .A2(b), .Z(out));

//** Add your code below this line **//
wire [2:0] ra3b, rb3b;

//change a to 3bit
encoder A(.a(a), .ra3b(ra3b));

//change b to 3bit
encoder B(.a(b), .ra3b(rb3b));

wire A1B0, A2B0, A0B1, A1B1, A2B1, A0B2, A1B2, A2B2;
wire cm1, cm2, cm3;
wire sm2_1,sm3_1;
wire cm2_1,cm3_1;

AN2*** fmul_00(.A1(ra3b[0]), .A2(rb3b[0]), .Z(out[0]));
AN2*** fmul_10(.A1(ra3b[1]), .A2(rb3b[0]), .Z(A1B0));
AN2*** fmul_20(.A1(ra3b[2]), .A2(rb3b[0]), .Z(A2B0));  //1 partial product

AN2*** fmul_01(.A1(ra3b[0]), .A2(rb3b[1]), .Z(A0B1));
AN2*** fmul_11(.A1(ra3b[1]), .A2(rb3b[1]), .Z(A1B1));
AN2*** fmul_21(.A1(ra3b[2]), .A2(rb3b[1]), .Z(A2B1));  //2 partial product

AN2*** fmul_02(.A1(ra3b[0]), .A2(rb3b[2]), .Z(A0B2));
AN2*** fmul_12(.A1(ra3b[1]), .A2(rb3b[2]), .Z(A1B2));
AN2*** fmul_22(.A1(ra3b[2]), .A2(rb3b[2]), .Z(A2B2));  //3 partial product

FA1*** fma1(.A(A1B0), .B(A0B1), .CI(1'b0), .S(out[1]), .CO(cm1)); //out[1]

FA1*** fma2_1(.A(A2B0), .B(A1B1), .CI(cm1), .S(sm2_1), .CO(cm2_1));
FA1*** fma2_2(.A(A0B2), .B(sm2_1), .CI(1'b0), .S(out[2]), .CO(cm2));  //out[2]
FA1*** fma3_1(.A(A2B1), .B(1'b0), .CI(cm2_1), .S(sm3_1), .CO(cm3_1));
FA1*** fma3_2(.A(sm3_1), .B(A1B2), .CI(cm2), .S(out[3]), .CO(cm3));  //out[3]

FA1*** fma4(.A(A2B2), .B(cm3_1), .CI(cm3), .S(out[4]), .CO(out[5]));  //out[4][5]

endmodule

module encoder (input [7:0] a, output [2:0] ra3b);
wire add1, add2, add3, add4, add5, add6, add7;
wire carry1, carry2, carry3, carry4, carry5, carry6, carry7;
wire carry_temp;
wire unvalid, valid;

FA1*** fa1(.A(a[0]), .B(a[1]), .CI(1'b0), .S(add1), .CO(carry1));
FA1*** fa2(.A(add1), .B(a[2]), .CI(carry1), .S(add2), .CO(carry2));
FA1*** fa3(.A(add2), .B(a[3]), .CI(carry2), .S(add3), .CO(carry3));
FA1*** fa4(.A(add3), .B(a[4]), .CI(carry3), .S(add4), .CO(carry4));
FA1*** fa5(.A(add4), .B(a[5]), .CI(carry4), .S(add5), .CO(carry5));
FA1*** fa6(.A(add5), .B(a[6]), .CI(carry5), .S(add6), .CO(carry6));
FA1*** fa7(.A(add6), .B(a[7]), .CI(carry6), .S(add7), .CO(carry7));
OR4*** catemp(.A1(carry1), .A2(carry2), .A3(carry3), .A4(carry4), .Z(carry_temp));
OR4*** unv(.A1(carry_temp), .A2(carry5), .A3(carry6), .A4(carry7), .Z(unvalid)); //carry have num means unvalid
GINVMCO*** v(.I(unvalid), .ZN(valid));

wire a2n, a3n, a4n, a5n, a6n, a7n;
wire a1_1, a1_2, a2_1, a2_2, a3_1, a3_2;
wire a1, a2, a3, a4, a5, a6;
wire [2:0]a3b, ra3b;
GINVMCO*** a2inv(.I(a[2]), .ZN(a2n));
GINVMCO*** a3inv(.I(a[3]), .ZN(a3n));
GINVMCO*** a4inv(.I(a[4]), .ZN(a4n));
GINVMCO*** a5inv(.I(a[5]), .ZN(a5n));
GINVMCO*** a6inv(.I(a[6]), .ZN(a6n));
GINVMCO*** a7inv(.I(a[7]), .ZN(a7n));

AN4*** a1_a(.A1(a[1]), .A2(a2n), .A3(a3n), .A4(a4n), .Z(a1_1));
AN3*** a1_b(.A1(a5n), .A2(a6n), .A3(a7n), .Z(a1_2));
AN2*** a1_f(.A1(a1_1), .A2(a1_2), .Z(a1));  //001

AN4*** a2_a(.A1(a[2]), .A2(a3n), .A3(a4n), .A4(a5n), .Z(a2_1));
AN2*** a2_b(.A1(a6n), .A2(a7n), .Z(a2_2));
AN2*** a2_f(.A1(a2_1), .A2(a2_2), .Z(a2));  //010

AN3*** a3_a(.A1(a[3]), .A2(a4n), .A3(a5n), .Z(a3_1));
AN2*** a3_b(.A1(a6n), .A2(a7n), .Z(a3_2));
AN2*** a3_f(.A1(a3_1), .A2(a3_2), .Z(a3));  //011

AN4*** a4_f(.A1(a[4]), .A2(a5n), .A3(a6n), .A4(a7n), .Z(a4)); //100

AN3*** a5_f(.A1(a[5]), .A2(a6n), .A3(a7n), .Z(a5));  //101

AN2*** a6_f(.A1(a[6]), .A2(a7n), .Z(a6));  //110     111=a[7]

OR4*** a3bit2(.A1(a4), .A2(a5), .A3(a6), .A4(a[7]), .Z(a3b[2]));  //3bit[2]
OR4*** a3bit1(.A1(a2), .A2(a3), .A3(a6), .A4(a[7]), .Z(a3b[1]));  //3bit[1]
OR4*** a3bit0(.A1(a1), .A2(a3), .A3(a5), .A4(a[7]), .Z(a3b[0]));  //3bit[0]

AN2*** ra3bit2(.A1(a3b[2]), .A2(valid), .Z(ra3b[2]));   //mask 3bit[2]
AN2*** ra3bit1(.A1(a3b[1]), .A2(valid), .Z(ra3b[1]));   //mask 3bit[1]
AN2*** ra3bit0(.A1(a3b[0]), .A2(valid), .Z(ra3b[0]));   //mask 3bit[0]
endmodule