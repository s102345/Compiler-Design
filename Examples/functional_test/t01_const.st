% Declarations
const a :int := 10
const b := "C"

% Safe area
const c := a + 5
const d :int := a + 10

% Warning area
const c :real := 1.5 % Redefine
const e: string := 1.5 % Wrong type
const f: string := a + 10 % Wrong type
const g: int := 1.5 % Implict type convertion
const h: real := 10 % Implict type convertion

% Syntax error area
% var i := 10
% const j: string := i * 5