/*** 定義 ***/
%{

#include "main.h"
#include "y.tab.h"
#include <fstream>

extern "C"{
    int yywrap(void);
    int yylex(void);
}

using namespace std;

#define BUFFER buf = buf + yytext
#define token(t) {BUFFER; return(t);}
#define tokenNumerical(t, n) {BUFFER; return(t);}
#define tokenString(t, s) {BUFFER; return(t);}

string buf = "";
int currentLine = 1;
bool isMultiComment = false;
bool isCode = true;
extern ofstream out;

void print(){
    if (isCode && buf != ""){    
        cout << "/* " << currentLine << ": " << buf << " */" << '\n'; 
    }
    buf = ""; //Clear
    currentLine++;
    isCode = true;
}


%}

WhiteSpace [ \t] 

Identifiers [a-zA-Z][a-zA-Z0-9]*
non_zero_digits [0-9]
digits [1-9]
Interger 0|{digits}{non_zero_digits}*
Double {digits}{non_zero_digits}*\.{non_zero_digits}+
String \".*\"

%x COMMENT

/*** 規則 ***/
%%

\%.*  {isCode = false; BUFFER;}
"{%".* {isCode = false; BUFFER; BEGIN(COMMENT);} // Begin of comment
<COMMENT>. {isCode = false; BUFFER;} // Add any letter to buffer
<COMMENT>"\n" {isCode = false; print();} // Newline -> print buffer
<COMMENT>"%}" {isCode = false; BUFFER; BEGIN(INITIAL);} // End of comment

"\." {token('.');}
"," {token(',');}
"\:" {token(':');}
";" {token(';');}
"\(" {token('(');}
"\)" {token(')');}
"\[" {token('[');}
"\]" {token(']');}
"\{" {token('{');}
"\}" {token('}');}

"\+" {token('+');}
"\-" {token('-');}
"\*" {token('*');}
"\/" {token('/');}

"mod"  {token(MOD);}
":="   {token(ASG);}
"<"    {token('<');}
">"    {token('>');}
"="    {token('=');}
"<="   {token(LE);}
">="   {token(GE);}
"not=" {token(NE);}

"and" {token(AND);}
"or"  {token(OR);}
"not" {token(NOT);}

"array" {token(ARRAY);}
"begin" {token(BEGIN_);}
"bool" {yylval.typeID = BOOL_TYPE; token(BOOL);}
"char" {token(CHAR);}
"const" {token(CONST);}
"decreasing" {token(DECREASING);}
"default" {token(DEFAULT);}
"do" {token(DO);}
"else" {token(ELSE);}
"end" {token(END);}
"exit" {token(EXIT);}
"false" {yylval.symbol.myValue.boolValue = false; yylval.symbol.myType = BOOL_TYPE; token(BOOL_VAL);}
"for" {token(FOR);}
"function" {token(FUNCTION);}
"get" {token(GET);}
"if" {token(IF);}
"int" {yylval.typeID = INT_TYPE; token(INT);}
"loop" {token(LOOP);}
"of" {token(OF);}
"put" {token(PUT);}
"procedure" {token(PROCEDURE);}
"real" {yylval.typeID = REAL_TYPE; token(REAL);}
"result" {token(RESULT);}
"return" {token(RETURN);}
"skip" {token(SKIP);}
"string" {yylval.typeID = STR_TYPE; token(STRING);}
"true" {yylval.symbol.myValue.boolValue = true; yylval.symbol.myType = BOOL_TYPE; token(BOOL_VAL);}
"var" {token(VAR);}
"when" {token(WHEN);}
"then" {token(THEN);}

{Identifiers} {yylval.symbol.myName = yytext; tokenString(ID, yytext);}

{Interger} {yylval.symbol.myValue.intValue = stoi(yytext); yylval.symbol.myType = INT_TYPE; tokenNumerical(INT_VAL, stoi(yytext));} // Use int to save result

{Double} {yylval.symbol.myValue.realValue = stod(yytext); yylval.symbol.myType = REAL_TYPE; tokenNumerical(REAL_VAL, stod(yytext));} // Use double to save result


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
    yylval.symbol.myValue.stringValue = str;
    yylval.symbol.myType = STR_TYPE;
    tokenString(STR_VAL, str);
} // Block "abc \n abc"

{WhiteSpace} {BUFFER;} //Save whitespace into buffer

"\n" {print();} //Handle all newline print

. {
    BUFFER;
    print();
    cout << "bad character: " << yytext << '\n';
    exit(-1);
}

%%

int yywrap(void){
    print();
    //puts("End of the file.");
    return 1;
}