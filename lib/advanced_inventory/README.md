### using Advanced Inventory

if say I want to transfer item from a chest to another by name
this could be done easily
```lua
chest1.pushItemByName("minecraft:gold_ingot", 10, chest2)
```
or
```lua
chest2.pullItemByName("minecraft:gold_ingot", 10, chest1)
```
check the code for the full api