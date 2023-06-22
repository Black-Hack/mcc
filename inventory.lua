local arg = {...}
local bufferChestName

if #arg ~= 1 then
    print("inventory [buffer_chest]")
    return
else
    bufferChestName = arg[1]
    local chest = peripheral.wrap(bufferChestName)
    if not chest or not peripheral.hasType(bufferChestName, "inventory") then
        print("peripheral has to be of type inventory")
        return
    end
end
local bufferChest = peripheral.wrap(bufferChestName)
local chest_names = {}
for i, name in ipairs(peripheral.getNames()) do
    if peripheral.hasType(name, "inventory") and name ~= bufferChestName then
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
    for slot,item in pairs(bufferChest.list()) do
        local itemDetail = bufferChest.getItemDetail(slot)
        itemDetail.count = nil
        local itemstr = textutils.serialise(itemDetail)
        local count = item.count
        if not Inventory[itemstr] then
            Inventory[itemstr] = item.count
        else
            Inventory[itemstr] =  Inventory[itemstr] + item.count
        end
        for _, name  in pairs(chest_names) do
            if count <= 0 then
                break
            end
            local pushedcount = 1
            while pushedcount ~= 0 do
                pushedcount = bufferChest.pushItems(name, slot)
                count = count - pushedcount
            end
        end
        if  Inventory[itemstr] then
            Inventory[itemstr] =  Inventory[itemstr] - count
        end
    end
end
local function getItemStrFromName(itemName)
    for itemstr,_ in pairs(Inventory) do
        local itemTable = textutils.unserialise(itemstr)
        if itemTable.displayName == itemName then return itemstr end;
    end
    return nil
end
local function getItemStrFromSlot(chest, slot)
    local itemDetail = chest.getItemDetail(slot)
    itemDetail.count = nil
    return textutils.serialise(itemDetail)
end

local function fetchfromInventory(itemName, itemCount)
    local itemstr = getItemStrFromName(itemName)
    if not itemstr then
        print("item was not found")
        return
    end
    local i = 1
    while i <= #chest_names and itemCount > 0 do
        local chest = peripheral.wrap(chest_names[i])
        for slot,_ in pairs(chest.list()) do
            local currentItemstr = getItemStrFromSlot(chest, slot)
            local itemTable = textutils.unserialise(currentItemstr)
            if itemTable.displayName == itemName then
                local pulledCount = bufferChest.pullItems(chest_names[i], slot, itemCount)
                itemCount = itemCount - pulledCount
                Inventory[itemstr] = Inventory[itemstr] - pulledCount
            end

        end
        i = i + 1
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
        if command == "fetch" then
            write("Item Name: ")
            local itemName = read()
            write("Count: ")
            local itemCount = tonumber(read())
            if not itemCount or not itemCount then
                print("enter valid input")
            else
                fetchfromInventory(itemName, itemCount)
            end
        end
        if command == "exit" then
            break
        end
    end        
end

invShell()


