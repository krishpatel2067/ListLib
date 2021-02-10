# NumList
**API Reference**

`NumList`s are `List`s that are specialized for numbers. It inherits the methods and properties from `List`, but has certain added on top. The datatype supports a number base system upon creation and conversion up to hexadecimal. 

!!! Note
    This only shows the API that is for consumer use; hidden API is not listed.  

___
## Class Properties

### Inherited from `List`
* `Inline`
* `MaxDisplay`

`ShowDataTypeContents` is not inherited since the only datatype supported is numbers.
___
## Constructors
### new
> **Parameters** (`table` array, `int` base = 10)

Creates a new `NumList` with the given `array` (filled with numbers only) and an optional `base`, which defaults to 10. For other bases, use strings in the array to preserve their numerical representation. If the strings are invalid (i.e. higher than base 16 or plain words), `NumList` will rasie an error something along the lines of `NumList creation: an error occurred`.

However, despite the base given, the numbers will always be converted to base 10.

```lua
--we will use this for future examples

--binary inputs
local MyNumList = NumList.new({'1010', '1001', '1000', '0111', '0110', '0101'}, 2) --must include 2, else it will error!
print(MyNumList) --NumList({10, 9, 8, 7, 6, 5})
```
### fromNormal
> **Parameters** (`int` count, `number` avg, `number` std)

Creates a normalized distribution with `count` number of values and with the given mean of `avg` and standard deviation of `std`. 

```lua
local MyNumList = NumList.fromNormal(10, 5, 10)
print(MyNumList:GetAvg()) --5
print(MyNumList:GetStd()) --10
```
!!! note
    Due to floating point errors that may occasionally arise, the average and standard deviation may be ever-so-slightly off (i.e. something like `5.0000000012` instead of `5`).
### fillWith
> **Parameters** (`int` count, `number` value)

Works just like `List.fillWith` except that the values must always be numerical.

### fromRandom
> **Parameters** (`number` min, `number` max, `int` count)

Creates `count` number of elements which are random numbers between the given `min` and `max`, which can be decimals.

```lua
local MyNumList = NumList.fromRandom(0.1, 0.55, 5)
print(MyNumList) --NumList({0.41, 0.18, 0.5, 0.44, 0.45})
```
### fromRange
> **Parameters** (`number` min, `number` max, `number` step = 1, `int` base = 10)

Similar to Python's `numpy.arange`; creates an array from `min` to `max`, incrementing by the optional `step`. The inputs for those three can be given in strings in case they are non-base 10 numbers.

```lua
--array from 90-100 with inc 2 in the hexadecimal number system
local MyNumList = NumList.fromRange('5A', '64', '2', 16)
print(MyNumList) --NumList({90, 92, 94, 96, 98, 100})
```
### linspace
> **Parameters** (`number` min, `number` max, `int` count)

Just like `numpy.linspace`; it creates an array from `min` to `max` with the given `count` such that each number is spaced out by an event, automatically-calculated increment (unlike `NumList.fromRange`).

```lua
local MyNumList = NumList.linspace(1, 10, 5)
print(MyNumList) --NumList({1, 3.25, 5.5, 7.75, 10})
```
Above, the increment is 2.25 (which can be calculated by `(max - min) / (count - 1)`).
___
## Properties

### Inherited from `List`
These properties are inherited from `List` and work the same way:
* `Alias`
* `Length`
* `__type`
___

## Functions

### GetAvg
*`number`*
Gets the average of the numbers, equivalent to doing `NumList:GetSum() / NumList.Length`.

### GetFivePointSummary
*`table`*

Gets the box-plot-related stats (minimum, first quartile, median, third quartile, and maximum) in a dictionary with the keys:
* `Min`
* `Q1`
* `Median`
* `Q3`
* `Max`

### GetMAD
*`number`*
Gets the mean absolute deviation of the `NumList`; the length must be greater than 0, else an error will be raised.

### GetMax
*`number`*

Gets the maximum value from the `NumList`.

### GetMedian
*`number`*

Gets the median of the `NumList`.
### GetMin
*`number`*

Gets the minimum value from the `NumList`.

### GetMode
*`table`*
Gets the mode of the set and returns the values in a table (since multiple values can appear the same number of times). If every value appears exactly once in the set, the mode will be `nil`.

### GetProduct
*`number`*
Simply gets the product of all the elements in the `NumList`.

### GetQ1
*`number`*

Gets the first quartile of the set.

### GetQ3
*`number`*
Gets the third quartile of the set.

### GetRange
*`number`*
Gets the range, the difference between the maximum and the minimum.

### GetStats
*`table`*

Gets *all* the stats in a dictionary, with the keys:
* `Min`
* `Q1`
* `Median`
* `Q3`
* `Max`
* `Range`
* `Sum`
* `Product`
* `Avg`
* `Std`
* `MAD`
* `Mode` 

For `Mode`, the value will be `"None"` to represent `nil` because else the key will be non-existent.
### GetStd
*`number`*
Gets the population standard deviation of the set of numbers; the length of the `NumList` must be greater than 1, else it will raise an error.
### GetSum
*`number`*

Simply gets the sum of all the elements in the `NumList`.

### ToBase
*`table`*
**Parameters** (`int` base)

Converts the current base-10 `NumList` values to the given `base`, which will be returned as a table (*not* a NumList) with string values. Also works with decimals.

```lua
local MyNumList = NumList.new({90, 92, 94, 96, 98, 100})
print(MyNumList:ToBase(16)) --{"5A", "5C", "5E", "60", "62", "64"}
```

### Inherited from `List`
These functions are inherited from `List` and are also available with `NumList` (only with slight modifications to accept only numbers, for example):

* `NumList:Clear()`
* `NumList:Empty()`
* `NumList:Clone()`
* `NumList:Append()`
* `NumList:Replace()`
* `NumList:Remove()`
* `NumList:RemoveDuplicates()`
* `NumList:Select()`
* `NumList:Pairs()`
* `NumList:Zip()`
* `NumList:Find()`
* `NumList:Sort()`
* `NumList:Reverse()`
* `NumList:Count()`
* `NumList:CountValues()`
___

## Events

### Inherited from `List`
These events work the same as they do with `List`:

* `Changed`
* `Added`
* `Removed`