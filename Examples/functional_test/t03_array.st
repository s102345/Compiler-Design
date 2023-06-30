% Declaration
var a: array 1..10 of int
var b: array 0..5 of bool
const c := 2
var d := 5

% Assign
a[1] := 1
a[c * 5] := 2
b[0] := true
b[d] := false
var e: array 0..5 of bool
b := e

% Access
put a[1]
put a[10]
put b[0]
put b[5]

% Warning area
put a[0] % Out of index
put a[c * 10] % Out of index
a[1] := "EE" % Wrong type
var a: array 1..100 of real % Redefine
var a: int % Redefine

% Syntax error area
% var a: array -1..100 of real % -(UMINUS) is expression