% Declarations
var a :string := "Hey There"
var b := -25
var c :string

% Safe area
const d := 10
var e := d + 1
var f :int := d + 1

% Warning area
var g :real := 1.5 % Redefine
var h: string := 1.5 % Wrong type
var i: string := d + 10 % Wrong type
var j: int := 1.5 % Implict type convertion
var k: real := 10 % Implict type convertion

% Syntax error area
% var l := 10
% var m: string := l * 5