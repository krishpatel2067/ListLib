# DataTypes

There are three main datatypes in ListLib:

* List
* NumList
* Matrix

`List`s are the very basic between the three because they add a relatively minimal functionality to regular tables such as manipulation (reverse, replace, etc.) and utility (find, slice, etc.). Lists allow values of any datatype.

`NumList`s, as they may imply, are inherited from Lists, but with the added restriction of only numbers. This allows for various mathamatical funtions such as sum, product, min/max, and stats.

A `Matrix` is the most unique datatype out of the three. They are internally Lists containing NumLists because matricies only allow numerical values. Matricies allow for functions such as cofactor, inverse, etc.

!!! info "Beta"
    Matricies are in Beta as of now, so expect some bugs/limited functionality. Report any concerns [here](https://devforum.roblox.com/t/greetings/164871?u=thecarbyneuniverse "ListLib Official Release Post").

More datatypes may be added in the future if necessary.