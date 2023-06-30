% Declarations
function func1(x :int, y :int, z :string) :bool
    result true
end func1

function func2():int 

end func2

var a: array 1..10 of int

var c: bool
c := func1(1, 2, "s")

% Pass array
function func3(a: array 1..10 of int):int 

end func3

% Return value
function func4(a: array 1..10 of int):int 
    var e :int
    result a[1]
    result func2()
    result 1 + 2
    result e * 10
end func4

% Warning area

c := func1(1, 2, 3)
c := func1(1, 2, "s", 4)
c := func1(1, 2)
c := func1("1", "2")
func3(a, "1")

% Redefine
function func2():int 

end func2 

var func2 := 1 % Redefine

% Redefine in scope
function func2():int
    var func2 := 1
    result 123
end func2 

% Return wrong type
function func3():int
    result "EE" 
end func3 

% return in function
function func4():int
    return
end func4

% ID not match
function func5():int
    result 1
end func3

% Not defined first
function func6(b: array 1..10 of int):int
end func6

% Not Function
var i: int
i()

% Syntax error area

% Assign
% var i := func2()

% Function in Function
{%
function func5():int 
    function func6():int 
    end func6
end func5
%}

