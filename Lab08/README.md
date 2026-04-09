# Lab08  Transformer Attention Mechanism

> 使用chipware完成電路設計 考慮area & clk tradeoff
> 
- 題目敘述
    - 設計一個簡化版Transformer Attention Mechanism
- 要求
    1. All multiplication operations must be carried out using the Chipware component
    2. Input synchronized at the clock rising edge.
    3. active-high asynchronous reset.
    4. Perform low-power synthesis
    5. Timing constraint for the clock period must be set to 0.55 ns. 
    6. Latency of design is less than 300 clock cycles (en 1→0 to done 0→1)
- 步驟
    - 輸入三個8*8 matrix Q K V
        - 轉置K
        - 計算W = Q * K^t
        - 計算輸出 O = W * V
    - 輸出output
        - A*B
- 規格

| signal | direction | bit width | description |
| --- | --- | --- | --- |
| reset | I | 1 | Active-high asynchronous reset. |
| clk | I | 1 | Clock signal. |
| en | I | 1 | Assert when MATRIX_Q, MATRIX_K,and MATRIX_V are valid. |
| MATRIX_Q  | I | 4 | Query data (unsigned number).  |
| MATRIX_K | I | 4 | Key data (unsigned number). |
| MATRIX_V | I | 4 | Value data (unsigned number).  |
| done | O | 1 | Assert when the answer is valid. |
| answer | O | 18 | Calculation result (unsigned number)  |
