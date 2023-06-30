{%
    Ref:https://www.programiz.com/dsa/binary-search
%}
var arr : array 0..6 of int

function binarySearch(arr: array 0..6 of int, x: int, low: int, high: int) :int
  % Repeat until the pointers low and high meet each other
  loop 
    exit when low <= high
    var mid: int
    put low + (high - low) / 2
    
    mid := low + (high - low) / 2

    if arr[mid] = x then
      result mid
    end if

    if arr[mid] < x then
      low := mid + 1
    else
      high := mid - 1
    end if

  end loop

  result -1

end binarySearch

% Main
var n := 7
const x := 4
var myResult: int
%var arr : array 0..6 of int
myResult := binarySearch(arr, x, 0, n - 1)
if (myResult = -1) then
put "Not found"
else
put "Element is found at index "
put myResult
end if
  
