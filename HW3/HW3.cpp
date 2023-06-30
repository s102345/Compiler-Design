// This is code generator.
#include "HW3.h"

BranchManager branchManager;

string makeTabs(int num){
    string buf = "";
    for(int i = 0; i < num; i++){
        buf += '\t';
    }
    return buf;
}


void BranchManager::createBranch(int amount){
    vector<string> tmp;
    for(int i = 0; i < amount; i++){
        string s = "L" + to_string(branchAmount);
        branchAmount++;
        tmp.push_back(s);
    }
    this->myBranches.push(tmp);
}

string BranchManager::getBranch(int idx){
    return this->myBranches.top()[idx];
}

void BranchManager::dropBranch(){
    this->myBranches.pop();
}

/*
string makeBranch(){
    string s = "L" + to_string(branchAmount);
    branchAmount++;
    return s;
}
*/

void generate(string s){
    if (s == "}"){
        scope--;
    }
    string tabs = makeTabs(scope);
    //cout << tabs << s << '\n';
    out << tabs << s << '\n';
    if (s == "{"){
        scope++;
    }
    if(s[s.length() - 1] == ':'){
        noOpGen();
    }
}

void programStart(){
    generate("class " + fileName);
    generate("{");
}

void programFinish(){
    generate("}");
}

void mainFunctionStart(){
    generate("method public static void main(java.lang.String[])");
    generate("max_stack 15");
    generate("max_locals 15");
    generate("{");
}

void mainFunctionFinish(){
    generate("return");
    generate("}");
}

void globalVariable(string name, string value){
    if(scope == 1){
        string tmp = "field static int " + name;
        if (value != "NULL"){
            tmp += " = " + value;
        }
        generate(tmp);
    }
}

void localVariable(string name, string value){
    if(scope != 1){
        int idx = symbolTableList.lookupSymbolIndex(name);
        //generate("sipush " + value);
        generate("istore " + to_string(idx));
    }
}

void globalVariableAssign(string name){
    generate("getstatic int "+ fileName + "." + name);
}

void localVariableAssign(string index){
    generate("iload " + index);
}

void globalVariableAssigned(string name){
    generate("putstatic int " + fileName + "." + name);
}

void localVariableAssigned(string index){
    generate("istore " + index);
}

void constAssign(string type, string value){
    if (scope != 1) {
        if (type == "int") generate("sipush " + value);
        if (type == "bool")  generate("iconst_" + value);
        if (type == "string") generate("ldc \"" + value + "\"");
    }
}

void popGen(){
    generate("pop");
}

void operatorGen(string op){
    if (op == "+") generate("iadd");
    if (op == "-") generate("isub");
    if (op == "*") generate("imul");
    if (op == "/") generate("idiv");
    if (op == "mod") generate("irem");
    if (op == "neg") generate("ineg");
    if (op == "and") generate("iand");
    if (op == "or") generate("ior");
    if (op == "not"){
        constAssign("bool", "1");
        generate("ixor");
    }
}

void compareOperatorGen(string op){
    branchManager.createBranch(2);
    //string branchA, branchB;
    //branchA = makeBranch();
    //branchB = makeBranch();
    generate("isub");
    string myOp = "";
    if (op == "<") myOp = "iflt";
    if (op == ">") myOp = "ifgt";
    if (op == "=") myOp = "ifeq";
    if (op == "<=") myOp = "ifle";
    if (op == ">=") myOp = "ifge";
    if (op == "not=") myOp = "ifne";
    generate(myOp + " " + branchManager.getBranch(0));
    generate("iconst_0");
    generate("goto " + branchManager.getBranch(1));
    generate(branchManager.getBranch(0) + ":");
    generate("iconst_1");
    generate(branchManager.getBranch(1) + ":");
    
    branchManager.dropBranch();
}

void putHeader(){
    generate("getstatic java.io.PrintStream java.lang.System.out");
}

void putGen(string type){
    if (type == "string") generate("invokevirtual void java.io.PrintStream.print(java.lang.String)");
    if (type == "int") generate("invokevirtual void java.io.PrintStream.print(int)");
    if (type == "bool") generate("invokevirtual void java.io.PrintStream.print(boolean)");
}

void skipGen(){
    generate("getstatic java.io.PrintStream java.lang.System.out");
    generate("invokevirtual void java.io.PrintStream.println()");
}

void ifStart(){
    //for(int i = 0; i < 2; i++) branchTemp.push_back(makeBranch());
    branchManager.createBranch(2);
    generate("ifeq " + branchManager.getBranch(0)); //If not equal branch
}

//Condition not satisfy -> to else
void elseStart(){
    generate("goto " + branchManager.getBranch(1));
    generate(branchManager.getBranch(0) + ":");
}

//Condition not satisfy -> jump to next label
void ifEnd(){
    generate(branchManager.getBranch(0) + ":");
    //noOpGen();
    branchManager.dropBranch();
}

void ifElseEnd(){
    generate(branchManager.getBranch(1) + ":");
    //noOpGen();
    branchManager.dropBranch();
}

void loopStart(){
    branchManager.createBranch(2);
    generate(branchManager.getBranch(0) + ":");
}

void loopBody(){
    generate("ifne " + branchManager.getBranch(1));
}

void loopEnd(){
    generate("goto " + branchManager.getBranch(0));
    generate(branchManager.getBranch(1) + ":");
    branchManager.dropBranch();
}

void exitGen(){
    generate("ifne " + branchManager.getBranch(1));
}

void functionStart(string name, string type, vector<string> params){
    string s = "method public static " + type + " " + name + "(";
    for(int i = 0; i < params.size(); i++){
        s += params[i];
        if(i != params.size() - 1) s += ", "; 
    }
    s += ")";
    generate(s);
    generate("max_stack 15");
    generate("max_locals 15");
    generate("{");
}

void functionReturn(){
    generate("ireturn");
}

void functionEnd(){
    generate("}");
}

void functionInvocation(string name, string type, vector<string> params){
    string s = "invokestatic " + type + " " + fileName + "." + name + "(";
    for(int i = 0; i < params.size(); i++){
        s += params[i];
        if(i != params.size() - 1) s += ", "; 
    }
    s += ")";
    generate(s);
}

void procedureStart(string name, vector<string> params){
    string s = "method public static void " + name + "(";
    for(int i = 0; i < params.size(); i++){
        s += params[i];
        if(i != params.size() - 1) s += ", "; 
    }
    s += ")";
    generate(s);
    generate("max_stack 15");
    generate("max_locals 15");
    generate("{");
}

void procedureReturn(){
    generate("return");
}

void procedureInvocation(string name, vector<string> params){
    string s = "invokestatic void " + fileName + "." + name + "(";
    for(int i = 0; i < params.size(); i++){
        s += params[i];
        if(i != params.size() - 1) s += ", "; 
    }
    s += ")";
    generate(s);
}

void noOpGen(){
    generate("nop");
}