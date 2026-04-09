# Lab06 Coordinate Calculator

> 合成電路synthesis + netlist確認邏輯是否跟RTL一致
> 
- 題目敘述
    - 設計一個座標計算機 運算並輸出一系列有效座標
- 要求
    1. I/O are 3bit unsigned num
    2. Active-high asynchronous reset.
    3. Input signals are synchronized at the clock rising edge.
    4. Timing constraint requires a clock period of 0.37 ns
    5. Once **nt** active, TB supplies 3 coordinate pairs, and asserts **busy** before receiving the final pair to prevent new inputs
- 步驟
    - 接收三組座標 一組代表三角形的三個點
    - 頂點保證 X1=X3 且 Y1<Y2<Y3
        - 保證一定有垂直邊
    - 根據input
        - 水平掃描 Y=Y1 ~ Y=Y3
        - 找坐落三角形內部的整數點
    - 輸出output
        - 順序 下~上 左~右
- 規格

| signal | direction | bit width | description |
| --- | --- | --- | --- |
| reset | I | 1 | Active-high asynchronous reset signal.
When the reset signal is asserted, the design is asynchronously reset. |
| clk | I | 1 | Clock source. The design is synchronous design triggered at the positive edge of clk.  |
| nt | I | 1 | New triangle indication. When the nt ignal is high, it indicates that three consecutive pairs of coordinate inputs for a triangle are available. Note that nt is active high only when the busy signal s low.  |
| xi | I | 3 | The x-coordinate input for the triangle.  |
| yi | I | 3 | The y-coordinate input for the triangle.  |
| busy | O | 1 | Busy signal. When the busy signal is high, it indicates that the coordinate calculator is processing the current triangle, preventing the acceptance of new coordinate inputs (i.e., nt will remain inactive).  |
| po | O | 1 | Valid output indication. When the po signal is high, it indicates that a sequence of coordinate outputs for the triangle is valid on the output ports (xo and yo). |
| xo | O | 3 | The x-coordinate output. |
| yo | O | 3 | The y-coordinate output. |

