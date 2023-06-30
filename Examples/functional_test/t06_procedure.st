% Declarations
procedure func1(x :int, y :int, z :string) 
    return
end func1

procedure func2() 

end func2

var a : array 1..10 of int

% Pass array
procedure func3(a: int)

end func3

func2()

% Warning area

% Redefine
procedure func2()

end func2 

var func2 := 1 % Redefine

% result in procedure
procedure func4()
    result 1
end func4

% Not procedure
var i: int
i()

% Syntax error area

% Assign
% var i := func2()

% procedure in procedure
{%
procedure func5()
    procedure func6()
    end func6
end func5
%}

