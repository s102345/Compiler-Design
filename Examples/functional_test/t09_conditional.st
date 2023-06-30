const a := 1

if 1 < 2 then
    const b := 1
    put a    
end if

if a >= 2 then
    const b := 2
    put "a >= 2"
else
    const b := 3
    put "a < 2"    
end if

% Syntax error
{%
if 1 then
    const b := 1
    put a    
end if
%}