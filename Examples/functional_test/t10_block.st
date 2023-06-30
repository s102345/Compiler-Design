const a := 1
const b := 2
% Single
begin
    put a 
    const a := 2
    put a 
    const c := 3
end

% Double
begin
    const a := 2
    begin
        const a := 3
        const c := 4
        put a 
    end
end