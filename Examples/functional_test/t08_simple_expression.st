% identifer := expression
var a := 5
var b : int
var c: array 1..10 of int

b := a * 2
put b

b := 2 
put b

b := (1 + 3) / 2 + 1 + 2 * 2 + 10 mod 2 % 13 
put b

% put
put a + 5
c[a] := a
put c[a]

function func1():int 
end func1
put func1

% Warning
put c % Can't output array

procedure func2() 
end func2
put func2 % Can't output procedure

% Get
get 1 + 1

% result & return 
% Ref to function & procedure

% skip
skip

% exit
exit when 1 = 1

% Syntax error
% exit 10
