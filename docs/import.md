# Importing

The structure for ListLib is as follows:

```
ListLib
    List
    NumList
    Matrix
```

To easily load all the modules, you can require the base `ListLib` module which returns a function to import the other three:

```lua
local import = require(ListLib)
local List, NumList, Matrix = import("List", "NumList", "Matrix")
```
The importation will return the module functionality in the order of parameters.

!!! note "Importing vs Requiring"
    It is highly recommended that you use the import function because it will initialize that script's environment with updated in-built functions such as `pairs`, `type`, `typeof`, etc. to recognize these datatypes and treat them accordingly. In scripts that you pass the objects as parameters, for example, and `ListLib` isn't be imported, the script environments  will not be updated with these functions, so you must be the functions within the object itself such as `List:Pairs` and `List.__type` (for the above three).