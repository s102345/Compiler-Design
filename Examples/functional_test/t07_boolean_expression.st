% boolean expression
put not true %0
put not false %1
put not not true %1
put true and true %1
put true and false %0
put false or true %1
put false or false %0
put false or not true %0
put true and not false %1
put 1 < 2 %1
put 1 > 3 %0
put "123" = "123" %1
put "123" not= "1" %1
put 1 >= 1 %1
put 1 < 2 and 2 < 3 %1
put 1 > 2 or 1 >= 0 %1

% Equal test
var a: array 1..10 of int
var b: array 0..5 of real
var c: array 1..10 of int
var d: array 0..5 of int

put a = c %1
put d = b %0

% Warning
var e: bool
e := not 1
e := "str" = 123
e := 1.2 = 12