#ifndef MAIN_HPP
#define MAIN_HPP

#include <iostream>
#include <string>
#include <map>
#include <vector>
#include <stack>

using namespace std;

const int nil = -1;

struct Symbol;

enum TYPE{
    BOOL_TYPE = 0,
    INT_TYPE,
    REAL_TYPE,
    STR_TYPE,
    VOID
};

enum STATUS{
    NONE = 0,
    CONST_STATUS,
    VAR_STATUS,
    ARR_STATUS,
    FOO_STATUS,
    PCD_STATUS
};

struct Value_multiType{
    bool boolValue;
    int intValue;
    double realValue;
    string stringValue; 
    vector<bool> boolArray;
    vector<int> intArray;
    vector<double> realArray;
    vector<string> stringArray;
};

typedef struct Symbol{
    string myName;
    Value_multiType myValue;
    int myType;
    int myStatus; //Enum
    int startIndex; //Array
    int endIndex; //Array 
    vector<pair<int, bool> > myParameter; // Function & procedure (type, isArray)
    //Null Symbol Constructor
    Symbol(){
        myName = "NULL";
    }
    //Symbol Constructor
    Symbol(string n, Value_multiType v, int mt, int ms){
        myName = n;
        myValue = v;
        myType = mt;
        myStatus = ms;
    }
}Symbol;

struct Type{
    Symbol symbol;
    int typeID;
};

class SymbolTable{
    private:
    map<string, int> myMap; // Map between name & index of symbol
    vector<Symbol> myTable; // Table of symbols
    public:
    SymbolTable();
    ~SymbolTable();
    void create();
    int lookup(string s);
    Symbol lookupSymbol(int idx);
    Symbol lookupSymbol(string s);
    void update(Symbol sym);
    void insert(Symbol sym);
    void dump();
    SymbolTable operator=(const SymbolTable& sT);
};


class SymbolTable_Scope{
    private:
    vector<SymbolTable> myTables;
    public:
    SymbolTable_Scope();
    ~SymbolTable_Scope();
    void insertSymbol(Symbol sym);
    void updateSymbol(Symbol sym);
    Symbol lookupSymbol(string s);
    Symbol lookupSymbol_local(string s);
    void create();
    void insert(SymbolTable symbolTable);
    void dump();
};


#define YYSTYPE Type

#endif


// Ref: https://blog.csdn.net/huyansoft/article/details/8860224