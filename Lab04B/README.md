# Lab04B  Sorting the Areas of Heptagons

- 題目敘述
    - 接收35個輸入(5個7邊形頂點)，計算面積，排序輸出大到小
- 要求
    1. Each register is assigned in a single always block to avoid race condition.
    2. Nonblocking assignments in edge triggered always blocks
    3. Use of only two-dimensional arrays
- 步驟
    1. 整理頂點順序 (Vertex Ordering)
        - 選擇基準點 → 得到向量
        - 計算cross product 根據正負判斷順時(逆時)針順序
        - 計算cross前要先轉乘sign num

        
    2. 算面積
        - 透過Shoelace formula

    3. 排序+輸出
        - Bubble Sort 大到小
        - valid set 1然後輸出
        - 一個clk輸出一個index + area
- 規格
    - Input signals are unsigned number and synchronized at the clock rising edge.
    - The reset scheme is an active-high asynchronous reset.
    
    | Signal Name  | I/O  | Width  | Description |
    | --- | --- | --- | --- |
    | clk  | I | 1 | CLK signal |
    | reset | I | 1 | Asynchronous reset signal (active high)  |
    | X | I | 10 | X-coordinate of the heptagon (unsigned) |
    | Y | I | 10 | Y-coordinate of the heptagon (unsigned) |
    | valid | O | 1 | When valid is high, the Index and Area are valid output  |
    | Index | O | 3 | Index of the heptagon  |
    | Area | O | 19 | Area of the heptagon  |
    
