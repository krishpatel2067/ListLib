# NumList
**API Reference**

`NumList`s are `List`s that are specialized for numbers. It inherits the methods and properties from `List`, but has certain added on top.

!!! Note
    This only shows the API that is for consumer use; hidden API is not listed.  
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
### fillWith
> **Parameters** (`int` count, `number` value)

Works just like `List.fillWith` except that the values must always be numerical.

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

