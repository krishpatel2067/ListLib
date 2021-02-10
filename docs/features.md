# Features

There are certain convinient features beyond the API, which are in the root type of `List` and is also inherited downwards. These are primarily built on the metamethods available in Luau, so more may be added if possible!

## Negative Indexing
Negative indicies allow you to reference from the end-to-start direction, where `-1` denotes the very last element, `-2` second to last, etc.

```lua
local MyNumList = NumList.new({90, 92, 94, 96, 98, 100})
print(MyNumList[-1]) --100
```

## Slicing
Using calls, just like with functions, you are able to pass the parameters to slice (or get a certain part of) the `List` or `NumList`. It takes in up to three parameters:
* `int` lower -- lower bound
* `int` upper = List.Length -- upper bound; default is the end of the list
* `int` step = 1 -- incremend the indexing; default is 1 (consecutive elements)

Additionally, you are able to input negative numbers!

```lua
local MyNumList = NumList.fromRange(1, 25)
print(MyNumList(-15, -1, 2)) --NumList({11, 13, 15, 17, 19, 21, 23, 25})

--or reverse the list using negative step!
print(MyNumList(-15, -1, -2)) --NumList({25, 23, 21, 19, 17, 15, 13, 11})
```

## Concatenation
Merge two `List`s or `NumList`s together on the stop using the concatenation operator.

```lua
local MyList1 = List.new({1, "two", 3})
local MyList2 = List.new({"four", 5, 6})

print(MyList1 .. MyList2) --NumList({1, "two", 3, "four", 5, 6})

MyList2 ..= MyList1
print(MyList2) --NumList({"four", 5, 6, 1, "two", 3})
```
