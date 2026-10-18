# Digital Integrated Circuits Design LAB

記錄lab部分 一些寫過的東西 

涵蓋Verilog HD、FSM控制、演算法HW實作、ChipWare IP 元件整合，以及電路合成硬體資源限制之優化。

---

## 專案內容

| 專題  | 功能架構簡述 |
| :--- |  :--- |
| **Sorting the Areas of Heptagons** (Lab04B) | 接收頂點座標輸入，用Shoelace Formula計算七邊形面積，並以 FSM 控制面積排序與依序輸出。 |
| **Simplified Transformer Attention** (Lab08)  | 實作簡化版 Transformer 自注意力機制（$Q \times K^T \times V$），結合矩陣轉置與 `CW_mult` 元件完成兩階段矩陣乘法。 |
| **IEEE 754 Double-Precision FP Multiplier** (Final) | 實作 64-bit IEEE 754 雙精度浮點數乘法器，採用 8-bit 串列 I/O 傳輸與 Shift-and-Add 演算法達成低面積硬體設計。 |

---

## 開發工具與驗證環境

* **硬體描述語言**：Verilog HDL
* **RTL 模擬與驗證**：NC-Verilog / VCS
* **波形除錯工具**：nWave / Verdi
* **邏輯合成工具**：Synopsys Design Compiler
