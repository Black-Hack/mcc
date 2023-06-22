Item = require "lib.item"
local arg = {...}
local buffer_chest
if #arg ~= 1 then
    print("inventory [buffer_chest]")
    return
else
    buffer_chest = arg[1]
    local chest = peripheral.wrap(buffer_chest)
    if not chest or not peripheral.hasType(buffer_chest, "inventory") then
        print("peripheral has to be of type inventory")
        return
    end
end

local chest_names = {}
for i, name in ipairs(peripheral.getNames()) do
    if peripheral.hasType(name, "inventory") and name ~= buffer_chest then
        table.insert(chest_names, name)
    end
end
Inventory = {}


local function scan_chests()
    local items = {}
    for i, name in ipairs(chest_names) do
        local chest = peripheral.wrap(name)
        print(peripheral.getName(chest))
        for slot, item in pairs(chest.list()) do
        
            local itemDetail = chest.getItemDetail(slot)
            itemDetail.count = nil
            local itemstr = textutils.serialise(itemDetail)
            if not items[itemstr] then
                items[itemstr] = item.count
            else
                items[itemstr] =  items[itemstr] + item.count
            end
    

        end
    end
    return items
end
Inventory = scan_chests()
Monitor = peripheral.find("monitor")


local function storeBuffer()
    local chest = peripheral.wrap(buffer_chest)
    for slot,item in pairs(chest.list()) do
        local itemDetail = chest.getItemDetail(slot)
        itemDetail.count = nil
        local itemstr = textutils.serialise(itemDetail)
        local count = item.count
        if not items[itemstr] then
            items[itemstr] = item.count
        else
            items[itemstr] =  items[itemstr] + item.count
        end
        for _, name  in pairs(chest_names) do
            if count <= 0 then
                break
            end
            local pushedcount = 1
            while pushedcount ~= 0 do
                pushedcount = chest.pushItems(name, slot)
                count = count - pushedcount
            end
        end
        if  items[itemstr] then
            items[itemstr] =  items[itemstr] - count
        end
    end
end

local function listInventory()
    for itemstr, count in pairs(Inventory) do
        local itemTable = textutils.unserialise(itemstr)
        print(("%s  %d"):format(itemTable.displayName, count))
    end
end

local function invShell()
    while true do
        io.write("inv>>")
        local command = read()
        if command == "store" then
            storeBuffer()
        end
        if command == "list" then
            listInventory()
        end
        if command == "update" then
            Inventory = scan_chests()
        end
        if command == "exit" then
            break
        end
    end        
end

invShell()


