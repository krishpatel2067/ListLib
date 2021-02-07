# List
**API Reference**

A List is essentially an ordered array with added functionalities. As with normal arrays, the indices must be numbers, but the values can be anything.

!!! Note
    This only shows the API that is for consumer use; hidden API is not listed.  

___

## Constructors
### new
> **Parameters** (`table` array)

Creates a List from the given array.

```lua
--this is the List we will use for future examples
local MyList = List.new({1, true, "three", 4, 5})
print(MyList) --List({1, true, three, 4, 5}) 
```
### fillWith
> **Parameters** (`number` count, `variant` value)

Essentially `table.create`; creates a array of `count` number of `value`s.

```lua
local MyList = List.fillWith(5, 'a')
print(MyList) --List({'a', 'a', 'a', 'a', 'a'})
```
___
## Properties
### Alias
*`string`*

Used to "name" the List, which shows when printing. This can be useful for distinguishing between different Lists.

```lua
MyList.Alias = "Example"
print(MyList) --Example({1, true, three, 4, 5})
```

### Length
*`number`* 

!!! quote "READONLY"

The length of the List. Simply doing `#List` will always return 0 because the object will be a proxy (empty) table.

```lua
print(#MyList) --0
print(MyList.Length) --5
```

### __type
*`string`*

!!! quote "READONLY"

Signifies the type of the object, which will always be `List`. Alternatively, you can also get the type via `type(MyList)` or `typeof(MyList)`, but only in scripts that require the *base* module directly. That is, if you pass the object as a parameter to another script, you must use `__type` because `type` and `typeof` will always return `table` in those environments.

```lua
--script that requires module
local import = require(ListLibModule) --this does the magic!
local List = import('List')

print(typeof(MyList)) --List
print(type(MyList)) --List
print(MyList.__type) --List

--in another script that does NOT require the ListLib module
print(typeof(MyList)) --table
print(type(MyList)) --table
print(MyList.__type) --List

```
___
## Functions
### AddFunction
*`void`*

> **Parameters** (`string` name, `function` func)

Creates a custom method for that List object with the given `name` and `func`. When calling, any parameters passed can be recieved by the given `func`. Speaking of calling, you can call using both `.` and `:`; in the latter, `func`'s first parameter will always be `self`, in the former, this will not happen.

```lua
--our function here will get the first and last element from the list
MyList:AddFunction('GetEnds', function(self, ...)

    print(...) --just demonstration purposes
    return self[1], self[self.Length]

end)

local first, last =  MyList:GetEnds('random', 'args')
--prints: random, args

print(first, last) --1 5
```
Similarily, if you don't anticipate using `self`, then you always use `.` (e.g. `MyList.SomeFunction()`).

### AddProperty
*`void`*

> **Parameters** (`string` name, `variant` value)

Creates a custom property with name `name` and a default value of `value`, which can be anything but a function (for that use `List:AddFunction`).

**Using List:AddFunction and List:AddProperty**
```lua
--this basically checks if the "owner" of the list is a certain username, which will
--control how the custom method will behave (it's pointless; just demonstration purposes)

MyList:AddProperty('Owner', 'TheCarbyneUniverse')
MyList:AddFunction('IsStolen', function(self)

    return not self.Owner == 'TheCarbyneUniverse'

end)

print(MyList:IsStolen()) --false
MyList.Owner = 'coefficients'
print(MyList:IsStolen()) --true

```
### Append
*`void`*

> **Parameters** (`variant` item, ...)

An `inplace` method; allows the addition of *at least* one item at the end of the List:

```lua
MyList:Append(6, 7, "eight")
print(MyList) --MyList({1, true, three, 4, 5, 6, 7, "eight"})
```
### Clear
*`void`*

Just like `table.clear`; it empties the internal table, but leaves the memory allocated for future need.

### Clone
*`List`*

Creates an identical `List`, similar to `Instance:Clone`.

### Count
*`number`*

> **Parameters** (`variante` value)

Returns the number times `value` appears in the List:

```lua
local MyNewList = List.new({"hello", "world", 2, "hello"})
print(MyNewList:Count("hello")) --2
```

### CountValues
*`table`*

Returns a table with the count of all the values in the table, arranged in descending order. The structure is as follows:

```
{{value, count},
{value, count},
...
{value, count}}
```
```lua
local MyNewList = List.new({true, false, true, true, 1, 2, 2, 3})
print(MyNewList:CountValues())
--[[

{

    {true, 3},
    {2, 2},
    {false, 1},
    {1, 1},
    {3, 1}

}
]]
```
This way, you can get the most numerous value like such:

```lua
print(MyNewList:CountValues()[1][1]) --true
```

### Empty
*`void`*

Empties the internal table and unallocates the memory, unlike `List:Clear`.

### Find
*`number`* or *`table`*

> **Parameters** (`variant` item, `boolean` all = false)

Finds the first occurence of `item` and returns the index. If `all` is true, then returns a table of indices of all occurences.

```lua
local MyNewList = List.new({1, 2, 3, 2})

print(MyNewList:Find(2)) --2
print(MyNewList:Find(2, true)) --{2, 4}
```

### GetTable
*`table`*

Basically gets table version of the List, which can be useful when you want to end List functionalities and access table functionalities.

### Pairs
*`function`*

Returns an iterator function and behaves just like Lua `pairs`. If the script you're using does not require the base ListLib module, then you must use this function instead of just doing `pairs(List)`:

```lua
--script that requires ListLib
for i, v in pairs(MyList) do
    print(i, v)
end

--script that does NOT require ListLib
for i, v in MyList:Pairs() do
    print(i, v)
end
```
### Remove
*`void`*

> **Parameters** (`variant` item, `number` startingIndex = 1, `number` count = 1)

An `inplace` method; removes `item` from the List, and behaves like `table.remove`. On top of that, if `startingIndex` is given, it will remove `count` number of occurrences of `item`. To input `count`, you must provide `startingIndex` first. Unlike `List:Append`, you can only input one item at a time.

!!! tip
    You can input -1 as `count` to remove all occurrences!

```lua
local MyNewList = List.new({"string", "anotherStr", "string", "somethingElse", "string"})
MyNewList:Remove("string", 2, -1)
print(MyNewList) --List({string, anotherStr, somethingElse})
```
The above examle ignored the `"string"` at index 1 because the given `startIndex` was 2.

### RemoveDuplicates
*`void`*

> **Parameters** (`variant` item)

An `inplace` method; removes duplicates of `item`. Alternatively, you can manually do:

```lua
--starts from the index after the index of "value" and clears all occurences from then on  
MyList:Remove("value", MyList:Find("value") + 1, -1)
```

### Replace
*`void`*

> **Parameters** (`variant` item, `variant` newItem, `number` startingIndex = 1, `number` count = 1)

An `inplace` method; replaces the first occurrence of `item` with `newItem`. If `startingIndex` is given, the replacement will start from that index onwards. If `count` is given, replaces that many occurrences of `item`.

!!! tip
    You can input -1 as `count` to replace all occurrences!

### Reverse
*`List`* or *`void`*

> **Parameters** (`boolean` inplace = false)

Reverses the List, and if `inplace` is true, the method acts like an `inplace` method, otherwise, the reversed List is returned.

```lua
MyList:Reverse(true)
print(MyList)
--or
print(MyList:Reverse())

--both give:
--List({5, 4, three, true, 1}) 
```

### Shuffle
*`List`* or *`void`*

> **Parameters** (`boolean` inplace = false)

Shuffles the List randomly; if `inplace` is true, the current List is replaced, otherwise, the shuffled List will be returned.

### Sort
*`List`* or *`void`*

> **Parameters** (`boolean` descending = false, `boolean` inplace = false)

By default, sorts the List in ascending ordeer unless `descending` is true. If `inplace` is true, the current List is sorted, otherwise, the current List will not be affected and the sorted List will be returned.

!!! info "Regarding Sorting"
    The method uses `table.sort` internally, so non-numerical values will be sorted with the mercy of the aforementioned function! For example, strings will be in alphabetical order, but mixed Lists will be grouped by datatypes according to how `table.sort` would do it.  

### Unpack
*`void`*

Unpacks the list similar to `table.unpack`.

### Zip
*`function`*

> **Parameters** (`variant` iterable, ...)

An iterator function that works like Python's `zip`. You can give as many `iterable` objects as needed, such as `strings`, `tables`, `Lists`, `NumLists`, or `Matricies`. Each `iterable` will be indexed in order and the function returns the corresponding element from each.

```lua
local someTable = {5, 4, 3, 2, 1, 0}
local str = "hello"
local MyList = List.new({1, true, three, 4, 5, 6, 7, eight})

for i, v1, v2, v3 in MyList:Zip(someTable, str) do
    print(i, v1, v2, v3)
end

--[[output:

1 1 5 h
2 true 4 e
3 three 3 l
4 4 2 l
5 5 1 o

]]
```
Here's what happening above:

|Index|Value1|Value2|Value3|
|---|---|---|---|
|`1`|`1`|`5`|`h`|
|`2`|`true`|`4`|`e`|
|`3`|`three`|`3`|`l`|
|`4`|`4`|`2`|`l`|
|`5`|`5`|`1`|`o`|


!!! info
    Zipping will end when the end the of the shortest `iterable` is reached. In the above example, since the string `str` was the shortest out of the three with the length of 5, the zipping stopped at index 5.

If the above kept on going until the end of the longest `iterable`, it would look like this:

|Index|Value1|Value2|Value3|
|---|---|---|---|
|`6`|`6`|`0`|`nil`|
|`7`|`7`|`nil`|`nil`|
|`8`|`eight`|`nil`|`nil`|

## Events