# flow
An error handling system for Lua, with support for GLua.

The primary issue I had with the built-in error handling system was the fact that it didn't support error types. Thus, if you want a single function to be able to have multiple error conditions whilst maintaining the ability to catch each exception individually, you need to resort to string manipulation. To get around this problem, I designed this system with the goal of implementing error types whilst maintaining ease of use. I also added a structure for assertions, such that multiple can be chained together in an easy to use and read fashion.

## Assertions
I defined an assertion structure. Each assertion item has an associated callback, which takes some data, and returns:

 - The assertion status (whether the given data passes the assertion)
 - A string representing the exception type to throw if the assertion failed
 - A string message to provide details on the cause of the error

The intention was that through the exception type, any function could assert different requirements and have the calling function be able to easily act differently based on what exact issue is faced.

Each assertion item can also have a collection of sub-assertions: assertions which depend on the parent assertion. When an assertion item is indexed, the list of sub-assertions is checked to see if the index provided equals the name of any sub-assertion: if it does, a new assertion structure is composed and returned which performs the checks of both the parent, and the indexed sub-assertion. This behaviour allows assertions to be chained, as you'll see in the example section.

## Example
A simple example usage example would be the following function:
```lua
function add(firstValue, secondValue)
	flow.assert.isNumber(firstValue)
	flow.assert.isNumber(secondValue)
  
	return firstValue + secondValue
end

local status = flow.protectedCall(function()
	return add(5, 3)
end)

if (status.exception.type == "TYPE_RESTRICTION_VIOLATION") then
	print("Error: " .. status.exception.message)
else
	local result = status.returns[1]

	print(result)
end
```
The above code will print out `8`: if you change one of the values that `add` is called with to a non-number type, you will get `Error: Number expected, got <type>`.

You can also chain other assertions together. `isString` defines a few sub-assertions by default, such as the `contains` assertion. An example usage of this would be `flow.assert.isString.contains(data, "test")`, which would check that the given data is a string, which contains the text `test`.

## Exception types
By default the following types are defined:

  - `TYPE_RESTRICTION_VIOLATION`: This type of exception occurs when data of one type is expected, but another type is received.
  - `SIZE_MISMATCH`: This type of exception occurs when data of one size (or range of sizes) is expected, but data of another size is received.
  - `VALUE_MISMATCH`: This type of exception occurs when the contents of some data is expected to follow some format, but does not. An example of this is the `flow.assert.isString.contains` example shown above, which states that the string is expected to contain a certain value.
