local model = {}
local bufferChestName = "minecraft:chest_16"
local bufferChest = peripheral.wrap(bufferChestName)
local chestNames = {}
local inventory = {}


function model.setBufferChest(name)
    bufferChestName = name
    bufferChest = peripheral.wrap(bufferChestName)
    chestNames = {}
    for _, name in ipairs(peripheral.getNames()) do
        if peripheral.hasType(name, "inventory")
            and name ~= bufferChestName
            and name ~= "right"
            and name ~= "left" then
    
            table.insert(chestNames, name)
        end
    end
end

for _, name in ipairs(peripheral.getNames()) do
    if peripheral.hasType(name, "inventory")
		and name ~= bufferChestName
		and name ~= "right"
		and name ~= "left" then

        table.insert(chestNames, name)
    end
end

--get names of connected chests

local function scan_chests()
    local items = {}
    for i, name in ipairs(chestNames) do
        local chest = peripheral.wrap(name)
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
inventory = scan_chests()

function model.scan_chests()
    inventory = scan_chests()
end

--stores all item in bufferChest to connected chests
function model.storeBuffer()
    for slot,item in pairs(bufferChest.list()) do
        local itemDetail = bufferChest.getItemDetail(slot)
        itemDetail.count = nil
        local itemstr = textutils.serialise(itemDetail)
        local count = item.count
        for _, name  in pairs(chestNames) do
            if count <= 0 then
                break
            end
            local pushedcount = 1
            while pushedcount ~= 0 do
                pushedcount = bufferChest.pushItems(name, slot)
				if not inventory[itemstr] then
					inventory[itemstr] = pushedcount
				else
					inventory[itemstr] =  inventory[itemstr] + pushedcount
				end
                count = count - pushedcount
            end
        end
    end
end


function model.searchItems(displayName)
    local result = {}
    for itemstr, count in pairs(inventory) do
        local itemTable = textutils.unserialise(itemstr)

        if string.find(string.upper(itemTable.displayName), string.upper(displayName)) then
            table.insert(result, {itemTable = itemTable, itemstr = itemstr})
        end
    end
    return result
end

local function getItemStrFromSlot(chest, slot)
    local itemDetail = chest.getItemDetail(slot)
    itemDetail.count = nil
    return textutils.serialise(itemDetail)
end
function model.fetchItem(itemstr, itemCount)
	local i = 1
	while i <= #chestNames and itemCount > 0 do
		local chest = peripheral.wrap(chestNames[i])
		for slot, _ in pairs(chest.list()) do
			if itemCount <= 0 then
                break
            end
			local currentItemstr = getItemStrFromSlot(chest, slot)
			if currentItemstr == itemstr then
				local pulledCount = bufferChest.pullItems(chestNames[i], slot, itemCount)
				itemCount = itemCount - pulledCount
				inventory[itemstr] = inventory[itemstr] - pulledCount
			end
		end
		i = i + 1
	end
    if inventory[itemstr] <= 0 then
		inventory[itemstr] = nil
	end
end

function model.getItemCount(item)
	if not item then
        error("item is nil")
    end
    -- local itemstr = textutils.serialise(item)
	return inventory[item]
end
return model