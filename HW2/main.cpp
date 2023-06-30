#include "main.h"


SymbolTable::SymbolTable(){
    this->create();
}

SymbolTable::~SymbolTable(){
    this->myMap.clear();
    this->myTable.clear();
}

void SymbolTable::create(){
    // Do nothing
}

// Find index only
int SymbolTable::lookup(string s){
    /* Found */
    auto iter = this->myMap.find(s);
    if (iter != this->myMap.end()){
        return iter->second;
    }
    else{
        return nil;
    }
}


// Update symbol
void SymbolTable::update(Symbol sym){
    /* Update table only */
    int idx = this->lookup(sym.myName);
    if(idx != nil){
        //Fool proof
        if(sym.myName == this->myTable[idx].myName){
            this->myTable[idx] = sym;
        }
    }
}


// Find symbol
Symbol SymbolTable::lookupSymbol(int idx){
    return this->myTable[idx];
}


// Insert Symbol
void SymbolTable::insert(Symbol sym){
    if (sym.myStatus != NONE){
        int idx = lookup(sym.myName);
        /* New */
        if (idx == nil){
            this->myMap.insert(pair<string, int>(sym.myName, this->myTable.size()));
            this->myTable.push_back(sym);
        }
    }
}

void SymbolTable::dump(){
    string TYPE_NAME[5] = {"boolean", "int", "real", "string", "void"};

    vector<string> mapTemp; // In order to make map sorted from [0~n]
    mapTemp.resize(this->myMap.size());
    cout << "\nSymbol Table: \n";
    for(auto iter = this->myMap.begin(); iter != this->myMap.end(); iter++){
        mapTemp[iter->second] = iter->first;
    }
    for (int i = 0; i < mapTemp.size(); i++){
        string symName = mapTemp[i];
        int idx = this->lookup(symName);
        if (idx == nil){
            cout << "SymbolTable non sync alert\n";
            return;
        }   
        Symbol sym = this->myTable[idx];
        cout << "Identifier " << symName;
        switch (sym.myType){
            case INT_TYPE:
                cout << " -type: int";
                if(sym.myStatus == CONST_STATUS) cout << " -value: " << sym.myValue.intValue;
                break;
            case STR_TYPE:
                cout << " -type: string";
                if(sym.myStatus == CONST_STATUS) cout << " -value: " << sym.myValue.stringValue;
                break;
            case REAL_TYPE:
                cout << " -type: real";
                if(sym.myStatus == CONST_STATUS) cout << " -value: " << sym.myValue.realValue;
                break;
            case BOOL_TYPE:
                cout << " -type: boolean";
                if(sym.myStatus == CONST_STATUS) cout << " -value: " << sym.myValue.boolValue;
                break;
            case VOID:
                cout << " -type: void";
                break;
        }
        switch (sym.myStatus){
            case NONE:
                cout << " -status: none";
                break;
            case CONST_STATUS:
                cout << " -status: const";
                break;
            case VAR_STATUS:
                cout << " -status: variable";
                break;
            case ARR_STATUS:
                cout << " -length: " << sym.endIndex - sym.startIndex + 1;
                cout << " -status: array";
                break;
            case FOO_STATUS:
                cout << " -status: function";
                if(sym.myParameter.size() == 0){
                    cout << " -parameters: empty";
                }
                else{
                    cout << " -parameters: (";
                    for(int i = 0; i < sym.myParameter.size(); i++){
                        cout << "type: " << TYPE_NAME[sym.myParameter[i].first] << ", isArray: " << sym.myParameter[i].second;
                        if (i != sym.myParameter.size() - 1){
                            cout << ", ";
                        }
                        else{
                            cout << ")";
                        }
                    }
                }
                break;
            case PCD_STATUS:
                cout << " -status: procedure";
                if(sym.myParameter.size() == 0){
                    cout << " -parameters: empty";
                }
                else{
                    cout << " -parameters: (";
                    for(int i = 0; i < sym.myParameter.size(); i++){
                        cout << "type: " << TYPE_NAME[sym.myParameter[i].first] << ", isArray: " << sym.myParameter[i].second;
                        if (i != sym.myParameter.size() - 1){
                            cout << ", ";
                        }
                        else{
                            cout << ")";
                        }
                    }
                }
                break;
        }
        cout << " -index: " << i << '\n';
    }
    cout << '\n';
}

SymbolTable SymbolTable::operator=(const SymbolTable& sT){
    SymbolTable tmp;
    tmp.myMap = sT.myMap;
    tmp.myTable = sT.myTable;
    return tmp;
}

SymbolTable_Scope::SymbolTable_Scope(){
    this->create();
}

SymbolTable_Scope::~SymbolTable_Scope(){
    this->myTables.clear();
}

void SymbolTable_Scope::create(){
    //Init state: one table
    this->myTables.push_back(SymbolTable());
}

// Search global
Symbol SymbolTable_Scope::lookupSymbol(string s){
    for(int i = this->myTables.size() - 1; i >= 0; i--){
        SymbolTable tmp = this->myTables[i];
        int idx = tmp.lookup(s);
        if (idx != nil){
            return tmp.lookupSymbol(idx);
        }
    }
    return Symbol();
}

// Search local
Symbol SymbolTable_Scope::lookupSymbol_local(string s){
    SymbolTable tmp = this->myTables[this->myTables.size() - 1];
    int idx = tmp.lookup(s);
    if (idx != nil){
        return tmp.lookupSymbol(idx);
    }
    return Symbol();
}

// Insert Symbol Table
void SymbolTable_Scope::insert(SymbolTable symbolTable){
    this->myTables.push_back(symbolTable);
}

// Insert Symbol(Default local scope)
void SymbolTable_Scope::insertSymbol(Symbol sym){
    int length = this->myTables.size();
    this->myTables[length-1].insert(sym);
}

// Update Symbol(Default local scope)
void SymbolTable_Scope::updateSymbol(Symbol sym){
    int length = this->myTables.size();
    this->myTables[length-1].update(sym);
}

//Dump last SymbolTable
void SymbolTable_Scope::dump(){
    int length = this->myTables.size();
    this->myTables[length-1].dump();
    this->myTables.pop_back();
}

