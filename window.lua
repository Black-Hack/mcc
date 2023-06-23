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
            if itemCount <= 0 then break end
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

local function searchInventoryByName(itemName)
    local result = {}
    for itemstr, count in pairs(Inventory) do
        local itemTable = textutils.unserialise(itemstr)
        if string.find(string.upper(itemTable.displayName), string.upper(itemName)) then
            table.insert(result, itemstr)
        end
    end
    return result
end
---windows.lua 

local screenWidth, screenHeight = term.getSize()
local root = term.current()
local searchWindow = window.create(root,1, 1, screenWidth, 2)
searchWindow.setBackgroundColor(colors.red)
searchWindow.myText = ""

--draws myText: the typed so far
--draws XX : cancel button
function searchWindow.draw()
    local posX, posY = searchWindow.getPosition()
    local width, height = searchWindow.getSize()
    searchWindow.clear()
    searchWindow.setCursorPos(1,2)
    searchWindow.write(searchWindow.myText)
    searchWindow.setCursorPos(width - 2, 2)
    searchWindow.write("XX")
end

--handles click on searchWindow.
-- posX and posY are relative to the window
--@param mouseButton 1 : left button, 2 : right Button, 3 : middle Button
function searchWindow.onclick(mouseButton, posX, posY)
    local width, height = searchWindow.getSize()

    if posX < width - 2 then
        local oldterm = term.redirect(searchWindow)
        searchWindow.myText = ""
        searchWindow.draw()
        searchWindow.setCursorPos(1, 2)
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
local w,h = contentWindow.getSize()
contentWindow.myWidth = w
contentWindow.myHeight = h 
--ph : Placeholder
contentWindow.myphWidth = 16
contentWindow.myphHeight = 3
contentWindow.placeholders = {}
contentWindow.myItemstrs = {}
contentWindow.mySearchText = nil
local function fetchByItemStr(itemstr, itemCount)
    local i = 1
    while i <= #chest_names and itemCount > 0 do
        local chest = peripheral.wrap(chest_names[i])
        for slot,_ in pairs(chest.list()) do
            if itemCount <= 0 then break end
            local currentItemstr = getItemStrFromSlot(chest, slot)
            if currentItemstr == itemstr then
                local pulledCount = bufferChest.pullItems(chest_names[i], slot, itemCount)
                itemCount = itemCount - pulledCount
                Inventory[itemstr] = Inventory[itemstr] - pulledCount
            end
        end
        i = i + 1
    end
    if Inventory[itemstr] == 0 then
        Inventory[itemstr] = nil
        contentWindow.mySearchText = nil
    end
end
local function create_placeholder(posX, posY)
    local placeholder = window.create(contentWindow, posX, posY,
        contentWindow.myphWidth, contentWindow.myphHeight)
    
    placeholder.setBackgroundColor(colors.red)
    placeholder.myItemstr = ""
    placeholder.myDisplayName = "NULL"
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
        placeholder.write(Inventory[placeholder.myItemstr])
    end
    function placeholder.onclick(mouseButton, posX, posY)
        if not placeholder.isVisible() then return end
        if mouseButton == 1 then
            fetchByItemStr(placeholder.myItemstr, 1)
        elseif mouseButton == 2 then
            fetchByItemStr(placeholder.myItemstr, 64)
        end
        contentWindow.draw()
    end
    return placeholder
end
--create two buttons (windows)
--prevButton, nextButton
contentWindow.prevButton = window.create(contentWindow, 1, contentWindow.myHeight, 2, 1)
contentWindow.nextButton = window.create(contentWindow, contentWindow.myWidth - 2, contentWindow.myHeight, 2, 1)
contentWindow.prevButton.setBackgroundColor(colors.red)
contentWindow.nextButton.setBackgroundColor(colors.red)
contentWindow.storeButton = window.create(contentWindow, 4, contentWindow.myHeight, 5, 1)
contentWindow.storeButton.setBackgroundColor(colors.green)
--currentPage is number indicating which set of items should be displayed to placeholders
contentWindow.currentPage = 1
--prevButton decrements currentPage onclick
function contentWindow.prevButton.onclick(mouseButton, posX, posY)
    if contentWindow.currentPage > 1 then
        contentWindow.currentPage = contentWindow.currentPage - 1
    end
    contentWindow.draw()
end
function contentWindow.storeButton.onclick(mouseButton, posX, posY)
    if mouseButton == 1 then storeBuffer() end
    contentWindow.draw()
end 
--nextButton increments currentPage onclick
function contentWindow.nextButton.onclick(mouseButton, posX, posY)
    contentWindow.currentPage = contentWindow.currentPage + 1
    contentWindow.draw()
end
--create the placeholders
for i = 0, 8 do
    local posX = math.floor(i / 3) * contentWindow.myphWidth + math.floor(i/3) + 1
    local posY = ((i) % 3) * ((contentWindow.myHeight) / 3) + 2
    local placeholder = create_placeholder(posX, posY)
    table.insert(contentWindow.placeholders, placeholder)
end
--fill placeholders with relevent itemstr info 
function contentWindow.fillPlaceholders()
    if contentWindow.mySearchText ~= searchWindow.myText then
        contentWindow.mySearchText = searchWindow.myText
        contentWindow.myItemstrs = searchInventoryByName(contentWindow.mySearchText);
    end
    local itemstrs =  contentWindow.myItemstrs
    local i = 1
    while i < #itemstrs and i < #contentWindow.placeholders do
        local ph = contentWindow.placeholders[i];
        ph.setVisible(true)
        ph.myItemstr= itemstrs[i]
        local itemTable = textutils.unserialise(ph.myItemstr)
        ph.myDisplayName = itemTable.displayName
        i = i + 1
    end
    while i < #contentWindow.placeholders do
        contentWindow.placeholders[i].setVisible(false)
        i = i + 1
    end

end
function contentWindow.draw()
    contentWindow.fillPlaceholders()
    contentWindow.clear()
    --draw prev,next Buttons
    contentWindow.prevButton.clear()
    contentWindow.prevButton.write("<<")
    contentWindow.nextButton.clear()
    contentWindow.nextButton.write(">>")
    --draw storeButton
    contentWindow.storeButton.clear()
    contentWindow.storeButton.write("store")
    --draw placeholders
    for i =1, #contentWindow.placeholders do
        contentWindow.placeholders[i].draw()
    end
    --draw currentPage
    contentWindow.setCursorPos(math.floor(contentWindow.myWidth / 2) - 3, contentWindow.myHeight)
    contentWindow.write(("Page %d"):format(contentWindow.currentPage))
end

function contentWindow.onclick(mouseButton, posX, posY)
    --check if prevButton is clicked
    local x, y = contentWindow.prevButton.getPosition()
    local w, h = contentWindow.prevButton.getSize()
    if (x <= posX and posX < w + x) and (y <= posY and posY < h + y) then
        contentWindow.prevButton.onclick(mouseButton, posX - x + 1, posY - y + 1)
    end
    --check if nextButton is clicked
    x, y = contentWindow.nextButton.getPosition()
    w, h = contentWindow.nextButton.getSize()
    if (x <= posX and posX < w + x) and (y <= posY and posY < h + y) then
        contentWindow.nextButton.onclick(mouseButton, posX - x + 1, posY - y + 1)
    end
    --check if storeButton is clicked
    x, y = contentWindow.storeButton.getPosition()
    w, h = contentWindow.storeButton.getSize()
    if (x <= posX and posX < w + x) and (y <= posY and posY < h + y) then
        contentWindow.storeButton.onclick(mouseButton, posX - x + 1, posY - y + 1)
    end
    --check placeholders
    for i = 1, #contentWindow.placeholders do
        local ph = contentWindow.placeholders[i];
        x, y = ph.getPosition()
        w, h = ph.getSize()
        if (x <= posX and posX < w + x) and (y <= posY and posY < h + y) then
            ph.onclick(mouseButton, posX - x + 1, posY - y + 1)
        end
    end
end




--handles general mouse clicks
--redirects the event to clicked windows with posX , posY relative the the window itself
function root.onclick(mouseButton, posX, posY)
    --check the searchWindow
    local x, y = searchWindow.getPosition()
    local w, h = searchWindow.getSize()
    if (x <= posX and posX < w + x) and (y <= posY and posY < h + y) then
        searchWindow.onclick(mouseButton, posX - x + 1, posY - y + 1)
    end
    --check the contentWindow
    x, y = contentWindow.getPosition()
    w, h = contentWindow.myWidth, contentWindow.myHeight
    if (x <= posX and posX < w + x) and (y <= posY and posY < h + y) then
        contentWindow.onclick(mouseButton, posX - x + 1, posY - y + 1)
    end
end

while true do
    searchWindow.draw()
    contentWindow.draw()
    ---@diagnostic disable-next-line: undefined-field
    local _, mouseButton, posX, posY = os.pullEvent("mouse_click")
    root.onclick(mouseButton, posX, posY)
end