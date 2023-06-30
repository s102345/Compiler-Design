## Lex(Scanner)變更項目

### 定義 Section
    - Library 移動至 main.h
    - Symbol Table 定義移動至 main.h
    - Symbol Table 實作移動至 main.cpp
    - 沿用C定義的yywrap, yylex
    - 取消token的output

### 規則 Section
    - 更改double以接納小數___.0
    - 基於BNF只能接受char或token的原則，所以我們將Delimiters, Arithmetic, Relational, logical拆分並個別回傳 
    - token BEGIN和yacc reserve word衝突，改成BEGIN_
    - 回傳採用struct Symbol型態，屬性有：
        - 四個型態的變數
        - 四個型態的動態陣列(vector)
        - 名稱
        - 型態(bool, int, string, real)
        - 狀態(Const, Variable等等)
        - 起始/結束index(array)
    - true, false改為回傳symbol型態，而不是token TRUE, FALSE，詳細資訊：
        - bool變數 -> true/false
        - 型態 -> bool
    - type: int, real, string, bool改為回傳型態的enum(int)，而不是token INT, REAL, STRING, BOOL
    - Numerical, String改為回傳symbol型態，詳細資訊：
        - 對應變數 -> yytext(with accommodate transform)
        - 型態 -> int/string/real
    - ID改為回傳symbol型態，詳細資訊：
        - 名稱 -> yytext
        - 狀態 -> Const/Variable/Array/Function/Procedure

### 主程式 Section
    - 移除main function，以yacc main function為主

## 其他
- 加分項
    - int/real隱式轉換
- 備註
    - 讓put實現print以方便顯示