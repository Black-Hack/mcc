local advanced_inventory = require "/mcc.lib.advanced_inventory"

local chest1 = advanced_inventory.wrap(peripheral.wrap(arg[1]))
local chest2 = advanced_inventory.wrap(peripheral.wrap(arg[2]))


--push 10 gold ingots from chest1 to chest2

print("transfered: ".. chest1.pullItemByName("minecraft:gold_ingot", 10, chest2))
-- print("taken back: ".. chest1.pullItemByName("minecraft:gold_ingot", 10, chest2))