/* C++ 定義 */
%{

//#include "lex.yy.c"
#include "main.h"
#include "HW3.h"
using namespace std;

extern "C"{
    void yyerror(const char *s);
    extern int yylex(void);
    extern FILE* yyin;
}

#define Trace(t) {cout << t << '\n';}
#define RaiseWarning(t) {cout << "Warning: "; yyerror(t);}

SymbolTable_Scope symbolTableList;
bool isInFoo = false;
Symbol currentFoo = Symbol();
Symbol currentFooTmp = Symbol(); // Clone of currentFoo
int foo_counter = 0;
int returnCounter = 0;
bool foo_invocation_flag = false;

string fileName = "";
ofstream out;
int scope = 0;

bool isInLoop = false;

bool isNumerical(Symbol s){
    if(s.myType != INT_TYPE && s.myType != REAL_TYPE){
        return false;
    }
    else{
        return true;
    }
}


%}
/* yacc 定義 */

/* Tokens */

/* Reserve words */
%token VAR ARRAY CHAR CONST 
%token IF THEN ELSE DEFAULT
%token LOOP DO FOR DECREASING WHEN OF
%token FUNCTION PROCEDURE END RETURN
%token BEGIN_ PUT GET RESULT EXIT SKIP

/* Type */
/*
%union{
    bool boolValue;
    int intValue;
    double realValue;
    char* stringValue; //Can't use string here
    char charValue;
}
*/

//%token <stringValue> ID
%type <symbol> expression expression_component array_reference function_invocation
%type <typeID> type

%token <symbol> ID INT_VAL REAL_VAL STR_VAL BOOL_VAL
%token <typeID> BOOL STRING INT REAL


/* Operation */
/*
    Precedence:
        (1) - (unary)
        (2) * / mod
        (3) + -
        (4) < <= = => > not=
        (5) not
        (6) and
        (7) or
*/

%token ASG

%left OR
%left AND
%left NOT
%left '<' LE '=' GE '>' NE
%left '+' '-'
%left '*' '/' MOD
%nonassoc UMINUS

/* Grammar Rule */
%start program
%%

// Program
//program: declaration program | statement program | ;
program: {programStart();} declarations {mainFunctionStart();} statements {mainFunctionFinish(); programFinish();};

// Declarations 
declaration: const_declaration | variable_declaration | array_declaration | function_declaration | procedure_declaration;

// Type that can be declared
type: BOOL | STRING | INT | REAL;

// Arguments of function or procedure with comma
formal_arguments: formal_arguments formal_argument |;

// Record type & status
formal_argument: ID ':' type{
    Symbol sym = $1;
    sym.myStatus = VAR_STATUS;
    sym.myType = $3;
    currentFoo.myParameter.push_back(pair<int, bool>(sym.myType, false));
    symbolTableList.insertSymbol(sym);      
} | ID ':' ARRAY INT_VAL '.''.' INT_VAL OF type{
    if($7.myValue.intValue - $4.myValue.intValue <= 0){
        RaiseWarning("Array length error!");
    }
    if (symbolTableList.lookupSymbol_local($1.myName).myName != "NULL"){
        RaiseWarning("Identifier re-define!");
    }
    if(symbolTableList.lookupSymbol($1.myName).myStatus == ARR_STATUS && symbolTableList.lookupSymbol($1.myName).myName != "NULL"){
        Symbol sym = symbolTableList.lookupSymbol($1.myName);
        currentFoo.myParameter.push_back(pair<int, bool>(sym.myType, true));
        //symbolTableList.insertSymbol(sym);  
    }
    else{
        RaiseWarning("Array must be define in first place!");
        //Give a temp array
        Symbol sym = $1;
        sym.myType = $9;
        sym.myStatus = ARR_STATUS;
        switch($9){
            case INT_TYPE:
                sym.myValue.intArray.resize($7.myValue.intValue + 1); // $5 <= index <= $8
                break;
            case REAL_TYPE:
                sym.myValue.realArray.resize($7.myValue.intValue + 1);
                break;
            case BOOL_TYPE:
                sym.myValue.boolArray.resize($7.myValue.intValue + 1);
                break;
            case STR_TYPE:
                sym.myValue.stringArray.resize($7.myValue.intValue + 1);
                break;
        }
        sym.startIndex = $4.myValue.intValue;
        sym.endIndex = $7.myValue.intValue;
        currentFoo.myParameter.push_back(pair<int, bool>(sym.myType, true));
        symbolTableList.insertSymbol(sym);
    }
}
|',';

/* Const declaration
    1. Expression must be const 
    2. Type must be the same
    3. ID can't re-define 
*/
const_declaration: CONST ID ':' type ASG expression {
                    if ($6.myStatus != CONST_STATUS && $6.myStatus != NONE){
                        yyerror("syntax error");
                        return 1;
                    }
                    
                    if ($4 == INT_TYPE && $6.myType == REAL_TYPE){
                        $6.myValue.intValue = $6.myValue.realValue;
                        RaiseWarning("Assign int to real / real to int!");
                    }
                    else if($4 == REAL_TYPE && $6.myType == INT_TYPE){
                        $6.myValue.realValue = $6.myValue.intValue;
                        RaiseWarning("Assign int to real / real to int!");
                    }
                    else if ($4 != $6.myType){
                        RaiseWarning("Assign unmatch type to identifier!");
                    }

                    if (symbolTableList.lookupSymbol_local($2.myName).myName != "NULL"){
                        RaiseWarning("Identifier re-define!");
                    }
                    
                    Symbol sym = $6;
                    sym.myName = $2.myName;
                    sym.myType = $4;
                    sym.myStatus = CONST_STATUS;
                    symbolTableList.insertSymbol(sym);
                    if(!symbolTableList.isGlobal(sym.myName)){
                        popGen();
                    }
                } 
                | CONST ID ASG expression {
                    if ($4.myStatus != CONST_STATUS && $4.myStatus != NONE){
                        yyerror("syntax error");
                        return 1;
                    }

                    if (symbolTableList.lookupSymbol_local($2.myName).myName != "NULL"){
                        RaiseWarning("Identifier re-define!");
                    }
                    
                    Symbol sym = $4;
                    sym.myName = $2.myName;
                    sym.myStatus = CONST_STATUS;
                    symbolTableList.insertSymbol(sym);  
                    if(!symbolTableList.isGlobal(sym.myName)){
                        popGen();
                    }            
                };

/* Variable declaration
    1. Expression must be const 
    2. Type must be the same
    3. ID can't re-define 
*/
variable_declaration: VAR ID ':' type ASG expression {
                        if ($6.myStatus != CONST_STATUS && $6.myStatus != NONE){
                            yyerror("syntax error");
                            return 1;
                        }

                        if ($4 == INT_TYPE && $6.myType == REAL_TYPE){
                            $6.myValue.intValue = $6.myValue.realValue;
                            RaiseWarning("Assign int to real / real to int!");
                        }
                        else if($4 == REAL_TYPE && $6.myType == INT_TYPE){
                            $6.myValue.realValue = $6.myValue.intValue;
                            RaiseWarning("Assign int to real / real to int!");
                        }
                        else if ($4 != $6.myType){
                            RaiseWarning("Assign type that doesn't fit!");
                        }

                        if (symbolTableList.lookupSymbol_local($2.myName).myName != "NULL"){
                            RaiseWarning("Identifier re-define!");
                        }

                        Symbol sym = $6;
                        sym.myName = $2.myName;
                        sym.myType = $4;
                        sym.myStatus = VAR_STATUS;
                        symbolTableList.insertSymbol(sym);

                        if (sym.myType == INT_TYPE){
                            globalVariable(sym.myName, to_string(sym.myValue.intValue));
                            localVariable(sym.myName, to_string(sym.myValue.intValue));
                        }

                    }   
                    | VAR ID ASG expression {
                        if ($4.myStatus != CONST_STATUS && $4.myStatus != NONE){
                            yyerror("syntax error");
                            return 1;
                        }

                        if (symbolTableList.lookupSymbol_local($2.myName).myName != "NULL"){
                            RaiseWarning("Identifier re-define!");
                        }         
                        Symbol sym = $4;
                        sym.myName = $2.myName;
                        sym.myStatus = VAR_STATUS;
                        symbolTableList.insertSymbol(sym);

                        if (sym.myType == INT_TYPE){
                            globalVariable(sym.myName, to_string(sym.myValue.intValue));
                            localVariable(sym.myName, to_string(sym.myValue.intValue));
                        }
                    }
                    | VAR ID ':' type {
                        if (symbolTableList.lookupSymbol_local($2.myName).myName != "NULL"){
                            RaiseWarning("Identifier re-define!");
                        }

                        Symbol sym = $2;
                        sym.myType = $4;
                        sym.myStatus = VAR_STATUS;
                        symbolTableList.insertSymbol(sym);
                        
                        if(sym.myType == INT_TYPE){
                            globalVariable(sym.myName, "NULL");
                            //localVariable(sym.myName, to_string(sym.myValue.intValue));
                        }
                    };

/* Array declaration
    1. Index must be int -> Syntax error
    2. Int_val on right  must > left
    3. Identifier can't re-define
    4. value of index > 0 -> Syntax error
*/
array_declaration: VAR ID ':' ARRAY INT_VAL '.''.' INT_VAL OF type{
    if($8.myValue.intValue - $5.myValue.intValue <= 0){
        RaiseWarning("Array length error!");
    }

    if (symbolTableList.lookupSymbol_local($2.myName).myName != "NULL"){
        RaiseWarning("Identifier re-define!");
    }

    Symbol sym = $2;
    sym.myType = $10;
    sym.myStatus = ARR_STATUS;
    switch($10){
        case INT_TYPE:
            sym.myValue.intArray.resize($8.myValue.intValue + 1); // $5 <= index <= $8
            break;
        case REAL_TYPE:
            sym.myValue.realArray.resize($8.myValue.intValue + 1);
            break;
        case BOOL_TYPE:
            sym.myValue.boolArray.resize($8.myValue.intValue + 1);
            break;
        case STR_TYPE:
            sym.myValue.stringArray.resize($8.myValue.intValue + 1);
            break;
    }
    sym.startIndex = $5.myValue.intValue;
    sym.endIndex = $8.myValue.intValue;
    symbolTableList.insertSymbol(sym);
};

/* Function/Procedure declaration
    1. Function in function/procedure -> Syntax error
    2. Name of Function & End function must be the same
    3. Identifier can't re-define
*/
function_declaration: FUNCTION ID{ 
                        if(isInFoo){
                            // Covered by syntax error
                            // RaiseWarning("Function declearation is not allowed in another function/procedure!");  
                        }
                        else{
                            isInFoo = true;
                            Symbol sym = $2;
                            sym.myStatus = FOO_STATUS;
                            currentFooTmp = currentFoo; 
                            currentFoo = sym;
                            returnCounter = 0;
                        }
                        symbolTableList.create(); //Scope
                    } function_declaration_argument {
                        vector<string> params;
                        for(int i = 0; i < currentFoo.myParameter.size(); i++){
                            if(currentFoo.myParameter[i].first == INT_TYPE) params.push_back("int");
                            if(currentFoo.myParameter[i].first == REAL_TYPE) params.push_back("real");
                            if(currentFoo.myParameter[i].first == BOOL_TYPE) params.push_back("bool");
                            if(currentFoo.myParameter[i].first == STR_TYPE) params.push_back("string");
                        }
                        if (currentFoo.myType == INT_TYPE) functionStart(currentFoo.myName, "int", params);
                    }
                    declarations_statements END ID{
                        if (returnCounter == 0){
                            RaiseWarning("Must have result called!");       
                        }
                        if (currentFoo.myName != $8.myName){
                            RaiseWarning("Function name of identifier & end is not match");           
                        }
                        if (symbolTableList.lookupSymbol(currentFoo.myName).myName != "NULL"){
                            RaiseWarning("Identifier re-define!");
                        }
                        symbolTableList.dump(); 
                        Symbol sym = currentFoo;
                        symbolTableList.insertSymbol(sym);
                        isInFoo = false;    
                        currentFoo = currentFooTmp; 
                        functionEnd();
                    };

function_declaration_argument: '(' ')' ':' type {
                        currentFoo.myType = $4;
                    }
                    | '(' formal_arguments ')' ':' type{
                        currentFoo.myType = $5;
                    };

procedure_declaration: PROCEDURE ID{
                        if(isInFoo){
                            // Covered by syntax error
                            // RaiseWarning("Procedure declearation is not allowed in another function/procedure!");
                        }
                        else{
                            isInFoo = true;
                            Symbol sym = $2;
                            sym.myType = VOID;
                            sym.myStatus = PCD_STATUS;
                            currentFooTmp = currentFoo;      
                            currentFoo = sym;
                            returnCounter = 0;
                        }
                        symbolTableList.create(); //Scope
                    } procedure_declaration_argument{
                        vector<string> params;
                        for(int i = 0; i < currentFoo.myParameter.size(); i++){
                            if(currentFoo.myParameter[i].first == INT_TYPE) params.push_back("int");
                            if(currentFoo.myParameter[i].first == REAL_TYPE) params.push_back("real");
                            if(currentFoo.myParameter[i].first == BOOL_TYPE) params.push_back("bool");
                            if(currentFoo.myParameter[i].first == STR_TYPE) params.push_back("string");
                        }
                        procedureStart(currentFoo.myName, params);
                    }declarations_statements END ID{
                        if (returnCounter == 0){
                            RaiseWarning("Must have return called!");       
                        }
                        if (currentFoo.myName != $8.myName){
                            RaiseWarning("Procedure name of identifier & end is not match");           
                        }
                        if (symbolTableList.lookupSymbol(currentFoo.myName).myName != "NULL"){
                            RaiseWarning("Identifier re-define!");
                        }
                        symbolTableList.dump(); 
                        Symbol sym = currentFoo;
                        symbolTableList.insertSymbol(sym);
                        isInFoo = false; 
                        currentFoo = currentFooTmp; 
                        functionEnd(); // }
                    };

procedure_declaration_argument: '(' formal_arguments ')' | '(' ')';

/* Expression */

/* Expressions by comma
    1. Check type
    2. Special case: array must be declare first
*/
expressions: expression{
                vector<pair<int, bool> > params = currentFoo.myParameter;
                //cout << foo_counter;
                if(foo_counter >= params.size()){
                    RaiseWarning("Function/Procedure get more parameter than expection!");
                }
                else{
                    // Is array
                    if(params[foo_counter].second){
                        if (symbolTableList.lookupSymbol($1.myName).myName == "NULL"){
                            RaiseWarning("Use undefined array in function/procedure!");
                        }
                    }
                    // Type checking
                    if (params[foo_counter].first != $1.myType){
                        if(isNumerical($1) && (params[foo_counter].first == INT_TYPE || params[foo_counter].first == REAL_TYPE)){
                            RaiseWarning("Raise implict convertion in the parameter of function/procedure!");
                        }
                        else{
                            RaiseWarning("Get different type in the parameter of function/procedure!");
                        }
                    }
                    foo_counter++;
                }
            }
            | expressions ',' expressions | ;

// Symbols
expression_component: ID {
                        $$ = symbolTableList.lookupSymbol($1.myName);
                        if ($$.myName == "NULL"){
                            RaiseWarning("Usage of undefined variable!");  
                        }
                        if($$.myStatus == VAR_STATUS){
                            if(symbolTableList.isGlobal($$.myName)){
                                globalVariableAssign($$.myName);
                            }
                            else{
                                if (isInFoo){
                                    string idx = to_string(symbolTableList.lookupSymbolIndex($$.myName));
                                    localVariableAssign(idx);
                                }
                                else{
                                    string idx = to_string(symbolTableList.lookupSymbolIndex_offset($$.myName));
                                    localVariableAssign(idx);
                                }
                            }
                        }
                        else if($$.myStatus == CONST_STATUS){
                            if($$.myType == INT_TYPE){
                                string value = to_string($$.myValue.intValue);
                                constAssign("int", value);
                            }
                            else if($$.myType == BOOL_TYPE){
                                string value = to_string($$.myValue.boolValue);
                                constAssign("bool", value);
                            }
                            else if($$.myType == STR_TYPE){
                                string value = $$.myValue.stringValue;
                                constAssign("string", value);
                            }
                        }
                    }
                    | function_invocation {
                        $$ = symbolTableList.lookupSymbol($1.myName); 
                        if($$.myStatus == PCD_STATUS){
                            // illegal
                            yyerror("syntax error");
                            return 1;
                            //RaiseWarning("Procedure can't be right value of assignment!");  
                        }
                    }
                    | array_reference
                    | INT_VAL {$$.myValue.realValue = $1.myValue.intValue; constAssign("int", to_string($1.myValue.intValue));} //Implict Type Convertion
                    | REAL_VAL {$$.myValue.intValue = $1.myValue.realValue;} //Implict Type Convertion 
                    | BOOL_VAL {constAssign("bool", to_string($1.myValue.boolValue));}
                    | STR_VAL {constAssign("string", $1.myValue.stringValue);};


/* Expressions 
    1. type must be the same
    2. '+', '-', '*', '/', '<', '<=', '>=', '>' accept int/real only
    3. mod accept int only
    4. '=', 'not=' accept same type only
*/
expression:   
        expression '+' expression {
            if(isNumerical($1) && isNumerical($3)){
                //Int & Real
                if($1.myType != $3.myType){
                    RaiseWarning("Add int with real/ real with int!");
                }
                //Int only
                if ($1.myType == INT_TYPE && $3.myType == INT_TYPE){
                    $$.myType = INT_TYPE;
                    $$.myValue.intValue = $1.myValue.intValue + $3.myValue.intValue; 
                    operatorGen("+");
                }
                else{
                    $$.myType = REAL_TYPE;
                    $$.myValue.realValue = $1.myValue.realValue + $3.myValue.realValue; 
                }
            }
            else{
                RaiseWarning("Use type that can't perform +!");  
            }
        }                                 
        | expression '-' expression{
            if(isNumerical($1) && isNumerical($3)){
                //Int & Real
                if($1.myType != $3.myType){
                    RaiseWarning("Minus int with real/ real with int!");
                }
                //Int only
                if ($1.myType == INT_TYPE && $3.myType == INT_TYPE){
                    $$.myType = INT_TYPE;
                    $$.myValue.intValue = $1.myValue.intValue - $3.myValue.intValue; 
                    operatorGen("-");
                }
                else{
                    $$.myType = REAL_TYPE;
                    $$.myValue.realValue = $1.myValue.realValue - $3.myValue.realValue; 
                }
            }
            else{
                RaiseWarning("Use type that can't perform -(MINUS)!");  
            }
        }                               
        | expression '*' expression {
            if(isNumerical($1) && isNumerical($3)){
                //Int & Real
                if($1.myType != $3.myType){
                    RaiseWarning("Times int with real/ real with int!");
                }   
                //Int only
                if ($1.myType == INT_TYPE && $3.myType == INT_TYPE){
                    $$.myType = INT_TYPE;
                    $$.myValue.intValue = $1.myValue.intValue * $3.myValue.intValue; 
                    operatorGen("*");
                }
                else{
                    $$.myType = REAL_TYPE;
                    $$.myValue.realValue = $1.myValue.realValue * $3.myValue.realValue; 
                }
            }
            else{
                RaiseWarning("Use type that can't perform *!");  
            }
        }                               
        | expression '/' expression{
            if(isNumerical($1) && isNumerical($3)){
                //Int & Real
                if($1.myType != $3.myType){
                    RaiseWarning("Divide int with real/ real with int!");
                }
                if ($3.myValue.intValue == 0){
                    RaiseWarning("Divided with 0");   
                }
                //Int only
                if ($1.myType == INT_TYPE && $3.myType == INT_TYPE){
                    $$.myType = INT_TYPE;
                    $$.myValue.intValue = $1.myValue.intValue * $3.myValue.intValue;
                    operatorGen("/"); 
                }
                else{
                    $$.myType = REAL_TYPE;
                    $$.myValue.realValue = $1.myValue.realValue * $3.myValue.realValue; 
                }
            }
            else{
                RaiseWarning("Use type that can't perform /!");  
            }
        }                               
        | '-' expression %prec UMINUS {
            if($2.myType == INT_TYPE){
                $$.myValue.intValue = $2.myValue.intValue * -1;
                $$.myType = INT_TYPE;
                operatorGen("neg");
            }
            else if($2.myType == REAL_TYPE){
                $$.myValue.realValue = $2.myValue.realValue * -1;
                $$.myType = REAL_TYPE;
            }
            else{
                RaiseWarning("Use type that can't perform -(UMINUS)!");  
            }
        }
        | expression MOD expression {
            if(isNumerical($1) && isNumerical($3)){
                if($1.myType == REAL_TYPE || $3.myType == REAL_TYPE){
                    RaiseWarning("Mod with real value!");
                }
                $$.myValue.intValue = $1.myValue.intValue % $3.myValue.intValue; 
                $$.myType = INT_TYPE;      
                operatorGen("mod"); 
            }
            else{
                RaiseWarning("Use type that can't perform mod!");
            }
        }
        | '(' expression ')' {$$ = $2;}
        | NOT expression {
            if ($2.myType == BOOL_TYPE){
                bool tmp = $2.myValue.boolValue;
                $$.myValue.boolValue = !tmp;
                $$.myType = BOOL_TYPE;
                $$.myStatus = NONE;
                operatorGen("not"); 
            }
            else{
                RaiseWarning("Use non-boolean type for boolean-expression!");       
            }
        }
        | expression OR expression{
            if ($1.myType == BOOL_TYPE && $3.myType == BOOL_TYPE){
                $$.myValue.boolValue = $1.myValue.boolValue || $3.myValue.boolValue;
                $$.myType = BOOL_TYPE;
                $$.myStatus = NONE;
                operatorGen("or"); 
            }
            else{
                RaiseWarning("Use non-boolean type for boolean-expression!");
                
            }
        }
        | expression AND expression{
            if ($1.myType == BOOL_TYPE && $3.myType == BOOL_TYPE){
                $$.myValue.boolValue = $1.myValue.boolValue && $3.myValue.boolValue;
                $$.myType = BOOL_TYPE;
                $$.myStatus = NONE;
                operatorGen("and"); 
            }
            else{
                RaiseWarning("Use non-boolean type for boolean-expression!");
            }
        }
        | expression '<' expression {
            if(isNumerical($1) && isNumerical($3)){
                if($1.myType != $3.myType){
                    RaiseWarning("Compare int with real / real with int!");
                }
                $$.myValue.boolValue = $1.myValue.realValue < $3.myValue.realValue;
                $$.myType = BOOL_TYPE; 
                $$.myStatus = NONE;
                compareOperatorGen("<");
            }
            else{
                RaiseWarning("Use type that can't perform < !");
            }
        } 
        | expression LE expression {
            if(isNumerical($1) && isNumerical($3)){
                if($1.myType != $3.myType){
                    RaiseWarning("Compare int with real / real with int!");
                }
                $$.myValue.boolValue = $1.myValue.realValue <= $3.myValue.realValue;
                $$.myType = BOOL_TYPE; 
                $$.myStatus = NONE;
                compareOperatorGen("<=");
            }
            else{
                RaiseWarning("Use type that can't perform <= !");
            }
        } 
        | expression '=' expression {
            $$.myType = BOOL_TYPE;
            $$.myStatus = NONE;
            // Speical case: two array
            if($1.myStatus == ARR_STATUS && $3.myStatus == ARR_STATUS){
                if($1.myType == $3.myType && ($1.endIndex - $1.startIndex) == ($3.endIndex - $3.startIndex)){
                    $$.myValue.boolValue = true; 
                }
                else{
                    $$.myValue.boolValue = false;
                }
            }
            else if($1.myStatus == ARR_STATUS || $3.myStatus == ARR_STATUS){
                RaiseWarning("Compare array with single value!");
            }
            else{
                if($1.myType == $3.myType){
                    compareOperatorGen("=");
                    switch($1.myType){
                        case INT_TYPE:
                            $$.myValue.boolValue = $1.myValue.intValue == $3.myValue.intValue;
                            break;
                        case REAL_TYPE:
                            $$.myValue.boolValue = $1.myValue.realValue == $3.myValue.realValue;
                            break;
                        case BOOL_TYPE:
                            $$.myValue.boolValue = $1.myValue.boolValue == $3.myValue.boolValue;
                            break;
                        case STR_TYPE:
                            $$.myValue.boolValue = $1.myValue.stringValue == $3.myValue.stringValue;
                            break;
                        default:
                            RaiseWarning("Use type that can't perform = !");
                    }
                }
                else if (isNumerical($1) && isNumerical($3)){
                    $$.myValue.boolValue = $1.myValue.realValue == $3.myValue.realValue;
                    RaiseWarning("Compare int with real/ real with int!");
                }
                else{
                    RaiseWarning("Comparing with different type!");
                }
            }
        } 
        | expression GE expression {
            if(isNumerical($1) && isNumerical($3)){
                if($1.myType != $3.myType){
                    RaiseWarning("Compare int with real / real with int!");
                }
                $$.myValue.boolValue = $1.myValue.realValue >= $3.myValue.realValue;
                $$.myType = BOOL_TYPE; 
                $$.myStatus = NONE;
                compareOperatorGen(">=");
            }
            else{
                RaiseWarning("Use type that can't perform >= !");
            }
        } 
        | expression '>' expression {
            if(isNumerical($1) && isNumerical($3)){
                if($1.myType != $3.myType){
                    RaiseWarning("Compare int with real / real with int!");
                }
                $$.myValue.boolValue = $1.myValue.realValue > $3.myValue.realValue;
                $$.myType = BOOL_TYPE; 
                $$.myStatus = NONE;
                compareOperatorGen(">");
            }
            else{
                RaiseWarning("Use type that can't perform > !");
            }
        } 
        | expression NE expression {
            $$.myType = BOOL_TYPE;
            $$.myStatus = NONE;
            // Speical case: two array
            if($1.myStatus == ARR_STATUS && $3.myStatus == ARR_STATUS){
                if($1.myType == $3.myType && ($1.endIndex - $1.startIndex) == ($3.endIndex - $3.startIndex)){
                    $$.myValue.boolValue = false; 
                }
                else{
                    $$.myValue.boolValue = true;
                }
            }
            else if($1.myStatus == ARR_STATUS || $3.myStatus == ARR_STATUS){
                RaiseWarning("Compare array with single value!");
            }
            else{
                if($1.myType == $3.myType){
                    compareOperatorGen("not=");
                    switch($1.myType){
                        case INT_TYPE:
                            $$.myValue.boolValue = $1.myValue.intValue != $3.myValue.intValue;
                            break;
                        case REAL_TYPE:
                            $$.myValue.boolValue = $1.myValue.realValue != $3.myValue.realValue;
                            break;
                        case BOOL_TYPE:
                            $$.myValue.boolValue = $1.myValue.boolValue != $3.myValue.boolValue;
                            break;
                        case STR_TYPE:
                            $$.myValue.boolValue = $1.myValue.stringValue != $3.myValue.stringValue;
                            break;
                        default:
                            RaiseWarning("Use type that can't perform = !");
                    }
                }
                else if (isNumerical($1) && isNumerical($3)){
                    $$.myValue.boolValue = $1.myValue.realValue == $3.myValue.realValue;
                    RaiseWarning("Compare int with real/ real with int!");
                }
                else{
                    RaiseWarning("Comparing with different type!");
                }
            }
        } 
        | expression_component; 

/* Function & procedure invocation
    1. Take care of undefined function/procedure
    2. Check expression's type
*/
function_invocation:  ID{
    if (symbolTableList.lookupSymbol($1.myName).myName == "NULL"){
        if($1.myStatus == FOO_STATUS) RaiseWarning("Use undefined function!");
        if($1.myStatus == PCD_STATUS) RaiseWarning("Use undefined procedure!");
    }
    
    if(symbolTableList.lookupSymbol($1.myName).myStatus != FOO_STATUS && symbolTableList.lookupSymbol($1.myName).myStatus != PCD_STATUS){
        RaiseWarning("Using non_function / non_procedure identifer in invocation");
    }
    else{
        // Prevent reset when foo(foo1())
        if (!foo_invocation_flag){
            currentFooTmp = currentFoo;
            currentFoo = symbolTableList.lookupSymbol($1.myName); 
            foo_counter = 0; // Init
        }
        else
            foo_invocation_flag = true;
    }
} '(' expressions ')'{
    foo_invocation_flag = false;
    if (foo_counter < currentFoo.myParameter.size()){
        RaiseWarning("Function/procedure get parameter lower than expected!");
    } 

    if(currentFoo.myStatus == FOO_STATUS){
        vector<string> params;
        for(int i = 0; i < currentFoo.myParameter.size(); i++){
            if(currentFoo.myParameter[i].first == INT_TYPE) params.push_back("int");
            if(currentFoo.myParameter[i].first == REAL_TYPE) params.push_back("real");
            if(currentFoo.myParameter[i].first == BOOL_TYPE) params.push_back("bool");
            if(currentFoo.myParameter[i].first == STR_TYPE) params.push_back("string");
        }
        if(currentFoo.myType == INT_TYPE) functionInvocation(currentFoo.myName, "int", params);
    }
    else if(currentFoo.myStatus == PCD_STATUS){
        vector<string> params;
        for(int i = 0; i < currentFoo.myParameter.size(); i++){
            if(currentFoo.myParameter[i].first == INT_TYPE) params.push_back("int");
            if(currentFoo.myParameter[i].first == REAL_TYPE) params.push_back("real");
            if(currentFoo.myParameter[i].first == BOOL_TYPE) params.push_back("bool");
            if(currentFoo.myParameter[i].first == STR_TYPE) params.push_back("string");
        }
        procedureInvocation(currentFoo.myName, params);
    }

    currentFoo = currentFooTmp;
}; 

/*
procedure_invocation: ID '(' expressions ')'{
    if (symbolTableList.lookupSymbol($1.myName).myName == "NULL"){
        RaiseWarning("Use undefined procedure!");
    }
};
*/

/* Reference to array
    1. Array index must be int
    2. Array index must in range
    3. Array must be defined
*/
array_reference: ID '[' expression ']'{
                $1 = symbolTableList.lookupSymbol($1.myName);
                $$ = $1;
                $$.myStatus = VAR_STATUS;
                if($3.myType != INT_TYPE){
                    yyerror("syntax error");
                    return 1;
                }
                if(symbolTableList.lookupSymbol($1.myName).myStatus != ARR_STATUS){
                    RaiseWarning("Using non_array identifer in invocation");
                }
                else{
                    if (symbolTableList.lookupSymbol($1.myName).myName == "NULL"){
                        RaiseWarning("Use undefined array!");                
                    }
                    if($3.myValue.intValue < $1.startIndex || $3.myValue.intValue > $1.endIndex){
                        RaiseWarning("Index out of array!");   
                    }
                    else{
                        switch($1.myType){
                            case INT_TYPE:
                                $$.myValue.intValue = $1.myValue.intArray[$3.myValue.intValue];
                                break;
                            case REAL_TYPE:
                                $$.myValue.realValue = $1.myValue.realArray[$3.myValue.intValue];
                                break;
                            case BOOL_TYPE:
                                $$.myValue.boolValue = $1.myValue.boolArray[$3.myValue.intValue];
                                break;
                            case STR_TYPE:
                                $$.myValue.stringValue = $1.myValue.stringArray[$3.myValue.intValue];
                                break;
                        }
                    }
                }
            };

/* Statement */
// Zero or more declarations
// Zero or more statement
declarations_statements: statement declarations_statements| var_declaration declarations_statements |;
// Limited declarations 
var_declaration: const_declaration | variable_declaration | array_declaration;

declarations: declarations declaration |;
statements: statements statement |;

/* Blocks
    1. Scope
*/
blocks: BEGIN_ {
        symbolTableList.create(); //Scope
    } declarations_statements END{
        symbolTableList.dump();
};

// Basic statements

simple_statement: 
            /* Array :=
                1. Index must be int
                2. Index must be in range
                3. Array must be defined
                4. := type must equals to Array type
            */
            ID '[' expression ']' ASG expression{
                $1 = symbolTableList.lookupSymbol($1.myName); //Update
                if($3.myType != INT_TYPE){
                    RaiseWarning("Array index is not int!");
                    
                }
                if($3.myValue.intValue < $1.startIndex || $3.myValue.intValue > $1.endIndex){
                    RaiseWarning("Index out of array!");
                    
                }
                if (symbolTableList.lookupSymbol($1.myName).myName == "NULL"){
                    RaiseWarning("Use undefined array!");
                    
                } // Need info of index 
                if($1.myType == $6.myType){
                    switch($1.myType){
                        case INT_TYPE:
                            $1.myValue.intArray[$3.myValue.intValue] = $6.myValue.intValue;
                            break;
                        case REAL_TYPE:
                            $1.myValue.realArray[$3.myValue.intValue] = $6.myValue.realValue;
                            break;
                        case BOOL_TYPE:
                            $1.myValue.boolArray[$3.myValue.intValue] = $6.myValue.boolValue;
                            break;
                        case STR_TYPE:
                            $1.myValue.stringArray[$3.myValue.intValue] = $6.myValue.stringValue;
                            break;
                    }
                }
                else if($1.myType == INT_TYPE && $3.myType == REAL_TYPE){
                    $1.myValue.intArray[$3.myValue.intValue] = int($6.myValue.realValue);
                    RaiseWarning("Assign real to int array!");
                }
                else if($1.myType == REAL_TYPE && $3.myType == INT_TYPE){
                    $1.myValue.realArray[$3.myValue.intValue] = double($6.myValue.intValue);
                    RaiseWarning("Assign int to real array!");
                }
                else{
                    RaiseWarning("Assign value to wrong array type!");
                }
                symbolTableList.updateSymbol($1);
            }
            /* Id :=
                1. Id can't only be variable
                2. Index must be in range
                3. Array must be defined
                4. := type must equals to Array type
            */
            | ID ASG expression{
                $1 = symbolTableList.lookupSymbol($1.myName);
                if ($1.myStatus == CONST_STATUS){
                    RaiseWarning("Const can not assign another value!");
                }
                else if ($1.myStatus == ARR_STATUS){
                    if($3.myStatus != ARR_STATUS){
                        RaiseWarning("Array can not assign single value!");
                    }               
                }
                else if ($1.myStatus == FOO_STATUS || $1.myStatus == PCD_STATUS || $1.myStatus == NONE){
                    RaiseWarning("Illegal left value!");
                }
                if ($1.myType == $3.myType){
                switch($1.myType){
                        case INT_TYPE:
                            $1.myValue.intValue = $3.myValue.intValue;
                            break;
                        case REAL_TYPE:
                            $1.myValue.realValue = $3.myValue.realValue;
                            break;
                        case BOOL_TYPE:
                            $1.myValue.boolValue = $3.myValue.boolValue;
                            break;
                        case STR_TYPE:
                            $1.myValue.stringValue = $3.myValue.stringValue;
                            break;
                    }
                }
                else if($1.myType == INT_TYPE && $3.myType == REAL_TYPE){
                    $1.myValue.intValue = int($3.myValue.realValue);
                    RaiseWarning("Assign real to int identifier!");
                }
                else if($1.myType == REAL_TYPE && $3.myType == INT_TYPE){
                    $1.myValue.realValue = double($3.myValue.intValue);
                    RaiseWarning("Assign int to real identifier!");
                }
                else{
                    RaiseWarning("Assign value to wrong type!");
                }
                symbolTableList.updateSymbol($1);

                if($1.myStatus == VAR_STATUS){
                    if(symbolTableList.isGlobal($1.myName)){
                        globalVariableAssigned($1.myName);
                    }
                    else{
                        if(isInFoo){
                            string idx = to_string(symbolTableList.lookupSymbolIndex($1.myName));
                            localVariableAssigned(idx);
                        }
                        else{
                            string idx = to_string(symbolTableList.lookupSymbolIndex_offset($1.myName));
                            localVariableAssigned(idx);
                        }
                    }
                }
                
            }
            /* put
                1. Can't output array
            */
            | PUT {putHeader();} expression{
                // Another trace function
                if ($3.myStatus == ARR_STATUS || $3.myStatus == PCD_STATUS){
                    RaiseWarning("Can't output this type!");
                }
                else{
                    switch($3.myType){
                        case INT_TYPE:
                            //cout << "PUT: " << $2.myValue.intValue << '\n';
                            putGen("int");
                            break;
                        case REAL_TYPE:
                            //cout << "PUT: " <<  $2.myValue.realValue << '\n';
                            break;
                        case BOOL_TYPE:
                            //cout << "PUT: " <<  $2.myValue.boolValue << '\n';
                            putGen("bool");
                            break;
                        case STR_TYPE:
                            //cout << "PUT: " <<  $2.myValue.stringValue << '\n';
                            putGen("string");
                            break;
                    }
                }
            }
            | GET expression 
            /* result
                1. Can't use in procedure
                2. Must meet function type
            */
            | RESULT expression{
                if (isInFoo){
                    if (currentFoo.myStatus == PCD_STATUS){
                        RaiseWarning("Procedure has no return value!");
                    }
                    else if ($2.myType != currentFoo.myType){
                        RaiseWarning("Return type must equal to defination!");
                    }
                    returnCounter++;
                }
                functionReturn();
            }
            /* result
                1. Can't use in function
            */
            | RETURN {
                if (isInFoo){
                    if (currentFoo.myStatus == FOO_STATUS){
                        RaiseWarning("Function must has a return value!");
                    }
                    returnCounter++;
                }
                procedureReturn();
            }
            | EXIT{
                exitGen();
            }
            /* exit when expression
                1. expression must be boolean
            */
            | EXIT WHEN expression{
                if ($3.myType != BOOL_TYPE){
                    yyerror("syntax error");
                    return 1;
                }
                exitGen();
            }
            | SKIP{
                skipGen();
            }
            | function_invocation{
                if(symbolTableList.lookupSymbol($1.myName).myStatus == FOO_STATUS){
                    RaiseWarning("Return value of function will be dropped!");  
                }
            };

// All possible statement
statement:  blocks
        |   simple_statement
        |   conditional
        |   loop;

/* Conditional If
    1. expression must be boolean
    2. scope
*/ 
conditional:  IF expression {
                if ($2.myType != BOOL_TYPE){
                    yyerror("syntax error");
                    return 1;
                }
                symbolTableList.create(); //Scope
                ifStart();   
            } THEN declarations_statements conditional_else;

conditional_else: ELSE{
                    symbolTableList.dump();
                    symbolTableList.create();
                    elseStart();
                } declarations_statements END IF { symbolTableList.dump(); ifElseEnd();}
                | END IF { symbolTableList.dump(); ifEnd();};

/* Loop
    1. ID must be defined
    2. scope
    3. ID must be int
    4. Range must be int
    5. ID must be variable
*/
loop: LOOP{
        symbolTableList.create(); //Scope
        loopStart();
    }declarations_statements END LOOP{
        symbolTableList.dump();
        loopEnd();
    }
    | FOR DECREASING ID ':' expression{
        string idx = to_string(symbolTableList.lookupSymbolIndex_offset($3.myName));
        if(symbolTableList.isGlobal($3.myName)){
            globalVariableAssigned($3.myName);
        }
        else{
            localVariableAssigned(idx);
        }
        loopStart();
        if(symbolTableList.isGlobal($3.myName)){
            globalVariableAssign($3.myName);
        }
        else{
            localVariableAssign(idx);
        }
    } '.''.' expression{
        if ($5.myStatus != NONE && $5.myStatus != CONST_STATUS){
            yyerror("syntax error");
            return 1;
        }
        if ($9.myStatus != NONE && $9.myStatus != CONST_STATUS){
            yyerror("syntax error");
            return 1;
        }
        
        if (symbolTableList.lookupSymbol($3.myName).myName == "NULL"){
            RaiseWarning("Use undefined identifier!");
        }
        Symbol sym = symbolTableList.lookupSymbol($3.myName);
        if ($5.myType != INT_TYPE || $9.myType != INT_TYPE){
            RaiseWarning("Condition in for-loop must be int!");
            
        }
        if (sym.myType != INT_TYPE){
            RaiseWarning("Identifier in for-loop must be int!");
            
        }
        if (sym.myStatus != VAR_STATUS){
            RaiseWarning("Identifier in for-loop must be variable!");
        }
        if($5.myValue.intValue < $9.myValue.intValue){
            RaiseWarning("Loop value must be decreasing!");
        }
        symbolTableList.create(); //Scope
  
        compareOperatorGen("<");
        loopBody();
        
    } declarations_statements{

    } END FOR {
        symbolTableList.dump();
        string idx = to_string(symbolTableList.lookupSymbolIndex_offset($3.myName));
        if(symbolTableList.isGlobal($3.myName)){
            globalVariableAssign($3.myName);
        }
        else{
            localVariableAssign(idx);
        } 
        constAssign("int", "-1");
        operatorGen("+");
        if(symbolTableList.isGlobal($3.myName)){
            globalVariableAssigned($3.myName);
        }
        else{
            localVariableAssigned(idx);
        }
        loopEnd();
    }
    | FOR ID ':' expression {
        string idx = to_string(symbolTableList.lookupSymbolIndex_offset($2.myName));
        if(symbolTableList.isGlobal($2.myName)){
            globalVariableAssigned($2.myName);
        }
        else{
            localVariableAssigned(idx);
        }
        loopStart();   
        if(symbolTableList.isGlobal($2.myName)){
            globalVariableAssign($2.myName);
        }
        else{
            localVariableAssign(idx);
        }
    }'.''.' expression{
        if ($4.myStatus != NONE && $4.myStatus != CONST_STATUS){
            yyerror("syntax error");
            return 1;
        }
        if ($8.myStatus != NONE && $8.myStatus != CONST_STATUS){
            yyerror("syntax error");
            return 1;
        }
        
        if (symbolTableList.lookupSymbol($2.myName).myName == "NULL"){
            RaiseWarning("Use undefined identifier!");
        }
        Symbol sym = symbolTableList.lookupSymbol($2.myName);
        if ($4.myType != INT_TYPE || $8.myType != INT_TYPE){
            RaiseWarning("Condition in for-loop must be int!");
            
        }
        if (sym.myType != INT_TYPE){
            RaiseWarning("Identifier in for-loop must be int!");
            
        }
        if (sym.myStatus != VAR_STATUS){
            RaiseWarning("Identifier in for-loop must be variable!");
        }
        if ($4.myValue.intValue > $8.myValue.intValue){
            RaiseWarning("Loop value must be increasing!");
        }
        symbolTableList.create(); //Scope 
        compareOperatorGen(">");
        loopBody();
    } declarations_statements{

    } END FOR {
        symbolTableList.dump(); 
        string idx = to_string(symbolTableList.lookupSymbolIndex_offset($2.myName));
        if(symbolTableList.isGlobal($2.myName)){
            globalVariableAssign($2.myName);
        }
        else{
            localVariableAssign(idx);
        }
        constAssign("int", "1");
        operatorGen("+");
        if(symbolTableList.isGlobal($2.myName)){
            globalVariableAssigned($2.myName);
        }
        else{
            localVariableAssigned(idx);
        }
        loopEnd();
    };



%%
/* C++ Code */

void yyerror(const char *s){
    cout << s << '\n';
}

int main(int argc, char **argv){
    // ./HW3 file.st
    if(argc != 2){
        cout << "Please have one file per time.\n";
        exit(1);
    }
    yyin = fopen(argv[1], "r");
    if(!yyin){
        cout << "File does not exist!\n";
        exit(1);
    }

    string tmp = "";
    string param = string(argv[1]);
    //Remove folder
    for (char c: param){
        if (c == '/') tmp = "";
        else{
        tmp += c;     
        }
    }
    //Remove extension
    for (char c: tmp){
        if (c == '.') break;
        fileName += c;
    }

    out.open(fileName + ".jsm");
    //cout << fileName << '\n';


    /* perform parsing */
    if (yyparse() == 1)                 /* parsing */
        cout << "Parsing error!\n";     /* syntax error */
    symbolTableList.dump();
}