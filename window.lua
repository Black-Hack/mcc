local strings = require "cc.strings"

local arg = {...}
local bufferChestName


--validate bufferChestName
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

--get names of connected chests
local chest_names = {}
for i, name in ipairs(peripheral.getNames()) do
    if peripheral.hasType(name, "inventory") and name ~= bufferChestName then
        table.insert(chest_names, name)
    end
end

Inventory = {}
--scan all items in connected chests
--@returns table[itemstr] = count
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

--stores all item in bufferChest to connected chests
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
--puts the item with itemName in bufferChest 
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
--prints global Inventory
local function listInventory()
    for itemstr, count in pairs(Inventory) do
        local itemTable = textutils.unserialise(itemstr)
        print(("%s  %d"):format(itemTable.displayName, count))
    end
end
--temporary console app
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

---windows.lua 

local screenWidth, screenHeight = term.getSize()
local root = term.current()
local searchWindow = window.create(root,1, 1, screenWidth, 2)

searchWindow.setBackgroundColor(colors.red)
searchWindow.clear()
searchWindow.myText = "hello"

--draws myText: the typed so far
--draws XX : cancel button
function searchWindow.draw()
    local posX, posY = searchWindow.getPosition()
    local width, height = searchWindow.getSize()
    searchWindow.setCursorPos(1,2)
    searchWindow.write(searchWindow.myText)
    searchWindow.setCursorPos(width - 2, 2)
    searchWindow.write("XX")
    searchWindow.setCursorPos(1,2)
    searchWindow.setCursorBlink(true)
end

--handles click on searchWindow.
-- posX and posY are relative to the window
--@param mouseButton 1 : left button, 2 : right Button, 3 : middle Button
function searchWindow.onclick(mouseButton, posX, posY)
    local width, height = searchWindow.getSize()

    if posX < width - 2 then
        local oldterm = term.redirect(searchWindow)
        searchWindow.myText = read()
        term.redirect(oldterm)
    else
        searchWindow.myText = ""
    end
    searchWindow.draw()
end

--contentWindow where the items will be
--displayed
--it has a list of children windows that are
--called placeholders
--placeholder is window that displays an 
--item's name and count
-- the contentWindow have a constant number
--placeholders.
--placeholder has myItemstr, myDisplayName, myCount
local contentWindow = window.create(root, 1, 3, screenWidth, screenHeight - 2)
contentWindow.setBackgroundColor(colors.blue)
contentWindow.clear()
local w,h = contentWindow.getSize()
contentWindow.myWidth = w
contentWindow.myHeight = h 
--ph : Placeholder
contentWindow.myphWidth = 16
contentWindow.myphHeight = 3
contentWindow.placeholders = {}
local function create_placeholder(posX, posY)
    local placeholder = window.create(contentWindow, posX, posY,
        contentWindow.myphWidth, contentWindow.myphHeight)
    
    placeholder.setBackgroundColor(colors.red)
    placeholder.myItemstr = ""
    placeholder.myDisplayName = "NULL"
    placeholder.myCount = 0
    local width, height = placeholder.getSize()
    placeholder.myWidth = width
    placeholder.myHeight = height
    function placeholder.draw()
        placeholder.clear()
        local lines = strings.wrap(placeholder.myDisplayName,
        placeholder.myWidth)
        --draw name
        for i = 1, #lines do
            placeholder.setCursorPos(1, i)
            placeholder.write(lines[i])
        end
        --draw count
        placeholder.setCursorPos(placeholder.myWidth - 4, placeholder.myHeight)
        placeholder.write(placeholder.myCount)            
    end
    
    return placeholder
end
--create two buttons (windows)
--prevButton, nextButton
contentWindow.prevButton = window.create(contentWindow, 1, contentWindow.myHeight, 2, 1)
contentWindow.nextButton = window.create(contentWindow, contentWindow.myWidth - 2, contentWindow.myHeight, 2, 1)
contentWindow.prevButton.setBackgroundColor(colors.red)
contentWindow.nextButton.setBackgroundColor(colors.red)
--currentPage is number indicating which set of items should be displayed to placeholders
contentWindow.currentPage = 1
--prevButton decrements currentPage onclick
function contentWindow.prevButton.onclick()
    if contentWindow.currentPage > 1 then
        contentWindow.currentPage = contentWindow.currentPage - 1
    end
end 
--nextButton increments currentPage onclick
function contentWindow.nextButton.onclick()
    contentWindow.currentPage = contentWindow.currentPage + 1
    
end
--create the placeholders
for i = 0, 8 do
    local posX = math.floor(i / 3) * contentWindow.myphWidth + math.floor(i/3) + 1
    local posY = ((i) % 3) * ((contentWindow.myHeight) / 3) + 2
    local placeholder = create_placeholder(posX, posY)
    table.insert(contentWindow.placeholders, placeholder) 
end

function contentWindow.draw()
    local posX, posY = contentWindow.getPosition()
    contentWindow.clear()
    --draw placeholders
    for i =1, #contentWindow.placeholders do
        contentWindow.placeholders[i].draw()
    end
    --draw prev,next Buttons
    contentWindow.prevButton.write("<<")
    contentWindow.nextButton.write(">>")
end


contentWindow.draw()
searchWindow.draw()
