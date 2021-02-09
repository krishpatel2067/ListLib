# NumList
**API Reference**

`NumList`s are `List`s that are specialized for numbers. It inherits the methods and properties from `List`, but has certain added on top.

!!! Note
    This only shows the API that is for consumer use; hidden API is not listed.  
## Constructors
### new
> **Parameters** (`table` array, `int` base = 10)

Creates a new `NumList` with the given `array` (filled with numbers only) and an optional `base`, which defaults to 10. For other bases, please consider using strings in the array to preserve their numerical representation. 

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

### fillNormal
> **Parameters** (`int` count, `number` avg, `number` std)

Creates a normalized distribution with `count` number of values and with the given mean of `avg` and standard deviation of `std`. 

```lua
local MyNumList = NumList.fromNormal(10, 5, 10)
print(MyNumList:GetAvg()) --5
print(MyNumList:GetStd()) --10
```
!!! note
    Due to floating point errors that may occasionally arise, the average and standard deviation may be ever-so-slightly off (i.e. something like `5.0000000012` instead of `5`).
