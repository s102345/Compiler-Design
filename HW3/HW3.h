#ifndef CODE_GEN_H
#define CODE_GEN_H

#include <iostream>
#include <fstream>
#include <stack>
#include "main.h"

using namespace std;

extern string fileName;
extern int scope;
extern SymbolTable_Scope symbolTableList;
extern bool isInLoop;
extern ofstream out;
//extern int branchAmount;
//extern vector<string> branchTemp;
//extern BranchManager branchManager;

string makeBranch();

void generate();

void programStart();
void programFinish();

void mainFunctionStart();
void mainFunctionFinish();

void globalVariable(string name, string value);
void localVariable(string name, string value);

void globalVariableAssign(string name);
void localVariableAssign(string index);

void globalVariableAssigned(string name);
void localVariableAssigned(string index);

void constAssign(string type, string value);

void putHeader();
void putGen(string type);

void skipGen();

void operatorGen(string op);
void compareOperatorGen(string op);

void ifStart();
void elseStart();
void ifEnd();
void ifElseEnd();

void loopStart();
void loopBody();
void loopEnd();
void exitGen();

void functionStart(string name, string type, vector<string> params);
void functionEnd();
void functionReturn();
void functionInvocation(string name, string type, vector<string> params);

void procedureStart(string name, vector<string> params);
void procedureReturn();
void procedureInvocation(string name, vector<string> params);

void noOpGen();
void popGen();


class BranchManager{
    private:
    stack<vector<string> > myBranches;
    int branchAmount;
    public:
    void createBranch(int amount);
    string getBranch(int idx);
    void dropBranch();
};

#endif

