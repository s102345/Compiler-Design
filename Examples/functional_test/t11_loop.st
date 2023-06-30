var a := 1
loop
    const b := 1
end loop

for a: 1 .. 10
    const b := 1
end for

for decreasing a: 10 .. 1
    const b := 1
end for

% Warning
var c := 5

const d := "str"
for d: 1 .. 10
    const b := 1
end for

for c: 1.1 .. 10
    const b := 1
end for