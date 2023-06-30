/*** 定義 ***/
%{
#include <iostream>
#include <string>
#include <map>
#include <vector>

using namespace std;

#define BUFFER buf = buf + yytext
#define token(t) {BUFFER; cout<< "<" << t << ">\n";}
#define tokenNumerical(t, n) {BUFFER; cout<< "<" << t << ":" << n << ">\n";}
#define tokenString(t, s) {BUFFER; cout<< "<" << t << ":" << s << ">\n";}

string buf = "";
int currentLine = 1;
bool isMultiComment = false;
const int nil = -1;

void print(){
    cout << currentLine << ": " << buf << '\n'; 
    buf = ""; //Clear
    currentLine++;
}

map<string, int> symbolTable;

map<string, int> create(){
    map<string, int> m;
    return m;
}

int lookup(string s){
    /* Found */
    auto iter = symbolTable.find(s);
    if (iter != symbolTable.end()){
        return iter->second;
    }
    else{
        return nil;
    }
}

void insert(string s){
    int idx = lookup(s);
    /* New */
    if (idx == nil){
        symbolTable.insert(pair<string, int>(s, symbolTable.size()));
    }
}

void dump(){
    vector<string> mapTemp; // In order to make map sorted from [0~n]
    mapTemp.resize(symbolTable.size());
    cout << "\nSymbol Table: \n";
    for(auto iter = symbolTable.begin(); iter != symbolTable.end(); iter++){
        mapTemp[iter->second] = iter->first;
    }
    for (int i = 0; i < mapTemp.size(); i++){
        cout << "Identifier " << mapTemp[i] << " has corresponding index: " << i << '\n';
    }
}

%}

WhiteSpace [ \t] 
Delimiters \.|,|\:|;|\(|\)|\[|\]|\{|\}
Arithmetic \+|\-|\*|\/|mod|:=   
Relational <|<=|>=|>|=|not=
logical and|or|not

Identifiers [a-zA-Z][a-zA-Z0-9]*
non_zero_digits [0-9]
digits [1-9]
Interger 0|{digits}{non_zero_digits}*
Double {digits}{non_zero_digits}*\.{digits}+
String \".*\"

%x COMMENT

/*** 規則 ***/
%%

\%.*  {BUFFER;}
"{%".* {BUFFER; BEGIN(COMMENT);} // Begin of comment
<COMMENT>. {BUFFER;} // Add any letter to buffer
<COMMENT>"\n" {print();} // Newline -> print buffer
<COMMENT>"%}" {BUFFER; BEGIN(INITIAL);} // End of comment

{Delimiters} {token(yytext);}
{Arithmetic} {token(yytext);}
{Relational} {token(yytext);}
{logical} {token(yytext);}

"array" {token("ARRAY");}
"begin" {token("BEGIN");}
"bool" {token("BOOL");}
"char" {token("CHAR");}
"const" {token("CONST");}
"decreasing" {token("DECREASING");}
"default" {token("DEFAULT");}
"do" {token("DO");}
"else" {token("ELSE");}
"end" {token("END");}
"exit" {token("EXIT");}
"false" {token("FALSE");}
"for" {token("FOR");}
"function" {token("FUNCTION");}
"get" {token("GET");}
"if" {token("IF");}
"int" {token("INT");}
"loop" {token("LOOP");}
"of" {token("OF");}
"put" {token("PUT");}
"procedure" {token("PROCEDURE");}
"real" {token("REAL");}
"result" {token("RESULT");}
"return" {token("RETURN");}
"skip" {token("SKIP");}
"string" {token("STRING");}
"true" {token("TRUE");}
"var" {token("VAR");}
"when" {token("WHEN");}
"then" {token("THEN");}

{Identifiers} {tokenString("Identifier", yytext); insert(yytext);}

{Interger} {tokenNumerical("Numerical", stoi(yytext));} // Use int to save result

{Double} {tokenNumerical("Numerical", stod(yytext));} // Use double to save result


{String} {
    string str = "";
    /*
        Last quote included.
        We use this count only if we have more than 2 quote -> "12"12". 
        If we take 2nd quote, we need to put back 3rd quote.
    */
    int ambigousCount = 1; 
    bool ambigousFlag = false;
    /* Travel the yytext without first quote & last quote*/
    for(int i = 1; i < yyleng - 1; i++){
        /* Last word as quote -> "123""*/
        if(yytext[i] == '\"' && i == yyleng - 2){
            /* First ambigous quote*/
            if (!ambigousFlag){
                ambigousFlag = true;
                continue;
            }
        }
        /* Double quote -> read one quote and ignore one quote*/
        else if(yytext[i] == '\"' && yytext[i+1] == '\"'){
            str += yytext[i];
            i += 1;
            continue;
        }
        /* Ambigous quote(single quote in string), ex. "123"123" */
        /* Take second quote as final quote.*/
        else if(yytext[i] == '\"' && yytext[i+1] != '\"'){
            /* First ambigous quote*/
            if (!ambigousFlag){
                ambigousFlag = true;
                continue;
            }
        }

        if (ambigousFlag){
            ambigousCount++;
        }
        else{
            /* Record */
            str += yytext[i];
        }
    }
    if (ambigousFlag){
        yyless(yyleng - ambigousCount); //Put back those ambigous word
    }
    tokenString("string", str);
} // Block "abc \n abc"

{WhiteSpace} {BUFFER;} //Save whitespace into buffer

"\n" {print();} //Handle all newline print

<<EOF>> {print(); return 0;}

. {
    BUFFER;
    print();
    cout << "bad character: " << yytext << '\n';
    exit(-1);
}

%%
/*** C++ ***/
int main(){
    symbolTable = create(); 
    yylex();
    dump();
    return 0;
}


