--hello there
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
        error("peripheral has to be of type inventory")
        return
    end
end

local view = require( "view")
local model = require("model")

model.setBufferChest(bufferChestName)

local topWindow = view.topWindow
local buttonsBar = view.buttonsBar
local statusBar = view.statusBar
local contentWindow = view.contentWindow
function topWindow.onclick(mouseButton, posX, posY)
    local width,_ = topWindow.getSize()

    if posX < width - 2 then
        local oldterm = term.redirect(topWindow)
        topWindow.text = ""
        topWindow.draw()
        topWindow.setCursorPos(1, 1)
        topWindow.text = read()
        term.redirect(oldterm)
        contentWindow.currentPage = 1
        contentWindow.items = model.searchItems(topWindow.text)
        contentWindow.fillPlaceholders()
    else
        topWindow.text = ""
        contentWindow.currentPage = 1
        contentWindow.items = model.searchItems(topWindow.text)
        contentWindow.fillPlaceholders()
    end
    topWindow.draw()
end

--buttons bar stuff
function buttonsBar.storeButton.onclick(mouseButton, posX, posY)
    statusBar.leftText = "storing.."
    statusBar.draw()
    model.storeBuffer()
    statusBar.leftText = "finished storing"
    statusBar.draw()

end

function buttonsBar.updateButton.onclick(mouseButton, posX, posY)
    statusBar.leftText = "sorting chests.."
    statusBar.draw()
    model.scan_chests()
    statusBar.leftText = "sorting scanning"
    statusBar.draw()
end

function buttonsBar.sortButton.onclick(mouseButton, posX, posY)
    statusBar.leftText = "sorting chests.."
    statusBar.draw()
    model.sortStorageChests()
    statusBar.leftText = "sorted chests!"
    statusBar.draw()
end
function buttonsBar.onclick(mouseButton, posX, posY)
    --store button
    local x, y = buttonsBar.storeButton.getPosition()
    local w, h = buttonsBar.storeButton.getSize()
    if (x <= posX and posX < w + x) and (y <= posY and posY < h + y) then
        buttonsBar.storeButton.onclick(mouseButton, posX - x + 1, posY - y + 1)
    end

    --update button
    local x, y = buttonsBar.updateButton.getPosition()
    local w, h = buttonsBar.updateButton.getSize()
    if (x <= posX and posX < w + x) and (y <= posY and posY < h + y) then
        buttonsBar.updateButton.onclick(mouseButton, posX - x + 1, posY - y + 1)
    end

    --sort button
    local x, y = buttonsBar.sortButton.getPosition()
    local w, h = buttonsBar.sortButton.getSize()
    if (x <= posX and posX < w + x) and (y <= posY and posY < h + y) then
            buttonsBar.sortButton.onclick(mouseButton, posX - x + 1, posY - y + 1)
    end
    contentWindow.items = model.searchItems(topWindow.text)
    contentWindow.fillPlaceholders()

end
--end buttons bar

--contentWindow

for i,ph in ipairs(contentWindow.phs) do
    function ph.onclick(mouseButton, posX, posY)
        if not ph.isVisible() then return end
        if mouseButton == 1 then
            statusBar.leftText = "fetching " .. " 1 " .. ph.item.itemTable.displayName
            statusBar.draw()
            model.fetchItem(ph.item.itemstr, 1)
            statusBar.leftText = "fetched " .. " 1 " .. ph.item.itemTable.displayName
            statusBar.draw()
        elseif mouseButton == 2 then
            statusBar.leftText = "fetching " .. " 64 " .. ph.item.itemTable.displayName
            statusBar.draw()
            model.fetchItem(ph.item.itemstr, 64)
            statusBar.leftText = "fetched " .. " 64 " .. ph.item.itemTable.displayName
            statusBar.draw()
        end
        if not model.getItemCount(ph.item.itemstr) then
            contentWindow.items = model.searchItems(topWindow.text or "")
            contentWindow.fillPlaceholders()
        end 
    end


end
function contentWindow.prevButton.onclick(mouseButton, posX, posY)
    if contentWindow.currentPage <= 1 then return end
    contentWindow.currentPage = contentWindow.currentPage - 1
    contentWindow.fillPlaceholders()
end

function contentWindow.nextButton.onclick(mouseButton, posX, posY)
    contentWindow.currentPage = contentWindow.currentPage + 1
    contentWindow.currentPage = math.min(contentWindow.currentPage, math.ceil(#contentWindow.items / #contentWindow.phs))
    contentWindow.fillPlaceholders()
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
    --check placeholders
    for i = 1, #contentWindow.phs do
        local ph = contentWindow.phs[i];
        x, y = ph.getPosition()
        w, h = ph.getSize()
        if (x <= posX and posX < w + x) and (y <= posY and posY < h + y) then
            ph.onclick(mouseButton, posX - x + 1, posY - y + 1)
        end
    end
end


function view.root.onclick(mouseButton, posX, posY)
    contentWindow.fillPlaceholders()
    --check the topWindow
    local x, y = topWindow.getPosition()
    local w, h = topWindow.getSize()
    if (x <= posX and posX < w + x) and (y <= posY and posY < h + y) then
        topWindow.onclick(mouseButton, posX - x + 1, posY - y + 1)
    end
    --statusbar
    --buttonsBar
    x, y = buttonsBar.getPosition()
    w, h = buttonsBar.getSize()
    if (x <= posX and posX < w + x) and (y <= posY and posY < h + y) then
        buttonsBar.onclick(mouseButton, posX - x + 1, posY - y + 1)
    end

    --contentWindow
    x, y = contentWindow.getPosition()
    w, h = contentWindow.getSize()
    if (x <= posX and posX < w + x) and (y <= posY and posY < h + y) then
        contentWindow.onclick(mouseButton, posX - x + 1, posY - y + 1)
    end
end



-- main loop
while true do
	view.root.draw()
	local _,mouseButton, posX, posY = os.pullEvent("mouse_click")
    view.root.onclick(mouseButton, posX, posY)
end
