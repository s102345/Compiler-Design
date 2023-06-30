var i : int
begin
    put "A"
    skip
end

for i : 1 .. 3
    begin
        put "for is good"
        put i
        skip
    end
end for

begin
    put "B"
    skip
end

begin
    i := 0
    loop
    exit when (i = 3)
    begin
        put "loop is good"
        put i
        skip
    end
    i := i + 1
    end loop
end

begin
    put "C"
    skip
end

begin
    if true then
        begin
            put "if is good"
            skip
        end
    end if
    
    begin 
        if false then
            put "error"
        else
            begin
                put "else is good"
                skip
            end
        end if
    end    
end

begin
    put "D"
    skip
end