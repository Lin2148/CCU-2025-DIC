# Lab03B Encoded Multiplier Circuit

> gate-level verilog寫法
> 
- 題目敘述
    - 設計一個編碼乘法器電路
    - 根據input
        - 剛好一個1的位置→輸出所在bit位置
        - 0或多個1 →輸出000
    - 這兩個無號數output相乘
    - 最後6bit結果 (max case 7*7)


- 規格
    - Input: a[7:0], b[7:0]
    - Output: out[5:0]
    - implemented using Verilog HDL structural-level descriptions → 結構層級描述實現
    - implemented using only standard cells → 只能用StdCell 組合所需邏輯