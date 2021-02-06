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