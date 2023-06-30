var sum: int
var i: int
var j: int
const b: int := 0


for i : 0 .. 10
    for j: 0 .. 10
        const b: int := 1
        const c: int := 1
    end for
    const b: int := 2
    const c: int := 2
end for

const flag := (1 + 2) > 1
if flag then
    const b: int := 3
    const c: int := 3
else
    const b: int := 4
    const c: int := 4
end if

flag := not flag
if flag then
    const b: int := 5
    const c: int := 5
end if

begin
    const b: int := 6
    const c: int := 6
end

function foo(a : int, d: int): int
    const b: int := 7
    const c: int := 7
end foo

const a: int := 0

procedure pcd(a : int)
    const b: int := 8
    const c: int := 8
end pcd

const c: int := 9