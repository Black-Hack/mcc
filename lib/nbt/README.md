# NBT reader and writer

### how to use

```lua
local nbt = require "/mcc/lib/nbt"

local tag = nbt.read("filename")

-- convert to a lua table
local tb = nbt.nbt2table(tag)

--save the tag
nbt.save("filename.nbt", tag)

```

### value manipulation
currently there is no easy way to manipulate data directly, 
but understanding the tag structure enables you to manipulate it easily
you can do
```lua
print(textutils.serialize(tag))
```
it will print the tag structure recursively.

### TODO
needs option to compress the file upon saving, although there are no compressing library yet