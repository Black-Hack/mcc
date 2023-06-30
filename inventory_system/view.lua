local model = require "model"
local strings = require "cc.strings"
local view = {}
local root = term.native()
view.root = root
local w, h = view.root.getSize()
root.width = w
root.height = h


-- topWindow
local topWindow = window.create(term.native(), 1, 1, root.width, 1)
view.topWindow = topWindow
topWindow.setBackgroundColor(colors.blue)
topWindow.text = ""
function topWindow.draw()
	local posX, posY = topWindow.getPosition()
    local width, height = topWindow.getSize()
    topWindow.clear()
    topWindow.setCursorPos(1,1)
    topWindow.write(topWindow.text)
    topWindow.setCursorPos(width - 2, 1)
    topWindow.write("XX")
end

-- contentWindow
local contentWindow = window.create(root, 1, 5, root.width, root.height - 4)
view.contentWindow = contentWindow
contentWindow.setBackgroundColor(colors.gray)
contentWindow.currentPage = 1
contentWindow.items = model.searchItems(topWindow.text or "")


w, h = contentWindow.getSize()
contentWindow.width = w
contentWindow.height = h
--prevButton
contentWindow.prevButton = window.create(contentWindow, 1, math.floor(contentWindow.height / 2), 1, 2)
contentWindow.prevButton.setBackgroundColor(colors.blue)
--nextButton
contentWindow.nextButton = window.create(contentWindow, contentWindow.width, math.floor(contentWindow.height / 2), 1, 2)
contentWindow.nextButton.setBackgroundColor(colors.blue)
--placeholders

local function create_placeholder(posX, posY, width, height, color)
    local placeholder = window.create(contentWindow, posX, posY,
        width, height)
    placeholder.setBackgroundColor(color)
    placeholder.item = nil
    placeholder.width = width
    placeholder.height = height
    function placeholder.draw()
        if not placeholder.isVisible() then return end
        placeholder.clear()
        local lines = strings.wrap(placeholder.item.itemTable.displayName, placeholder.width)
        --draw name
        for i = 1, #lines do
            placeholder.setCursorPos(1, i)
            placeholder.write(lines[i])
        end
        --draw count
        placeholder.setCursorPos(placeholder.width - 3, placeholder.height)
        placeholder.write(model.getItemCount(placeholder.item.itemstr))
    end
    return placeholder
end

contentWindow.phs = {}
-- 7 x 3 placeholders
local phwidth = 15
local phheight = 2
for i = 0, 21 - 1 do
    local x = (math.floor(i / 7) * phwidth + 1) + 3
    local y = (i % 7) * phheight + 1 + 1
    local color
    if (i % 2 == 0) then
        color = colors.blue
    else
        color = colors.red
    end
    local newph = create_placeholder(x, y, phwidth, phheight, color)
    table.insert(contentWindow.phs, newph)
end

function contentWindow.draw()
    contentWindow.clear()
    --draw placeholders
    for _, ph in pairs(contentWindow.phs) do
        ph.draw()
    end
    --draw Buttons
    contentWindow.prevButton.setCursorPos(1,1)
    contentWindow.prevButton.write("<")
    contentWindow.prevButton.setCursorPos(1,2)
    contentWindow.prevButton.write("<")

    contentWindow.nextButton.setCursorPos(1,1)
    contentWindow.nextButton.write(">")
    contentWindow.nextButton.setCursorPos(1,2)
    contentWindow.nextButton.write(">")
    --draw currentPage
    contentWindow.setCursorPos(math.floor(contentWindow.width / 2) - 2, 1)
    contentWindow.write(("page %d"): format(contentWindow.currentPage))
end

function contentWindow.fillPlaceholders()
    local items = contentWindow.items
    local page = contentWindow.currentPage
    local i = 1
    while i + (page - 1) * #contentWindow.phs <= #items and i <= #contentWindow.phs do
        local ph = contentWindow.phs[i];
        ph.setVisible(true)
        ph.item = items[i + (page - 1) * #contentWindow.phs]
        i = i + 1
    end
    while i <= #contentWindow.phs do
        contentWindow.phs[i].item = nil
        contentWindow.phs[i].setVisible(false)
        i = i + 1
    end
end
contentWindow.fillPlaceholders()

--statusBar
local statusBar = window.create(root, 1, 2, root.width, 1)
view.statusBar = statusBar
statusBar.setBackgroundColor(colors.red)
statusBar.leftText = "Hello"
statusBar.rightText = "there"
function statusBar.draw()
    statusBar.clear()
    statusBar.setCursorPos(1,1)
    statusBar.write(statusBar.leftText)
    local width, height = statusBar.getSize()
    statusBar.setCursorPos(width - #statusBar.rightText + 1,1)
    statusBar.write(statusBar.rightText)
end

--buttonsBar
local buttonsBar = window.create(root, 1, 3, root.width, 2)
view.buttonsBar = buttonsBar
buttonsBar.setBackgroundColor(colors.gray)
--storeButton

buttonsBar.storeButton = window.create(buttonsBar, 1, 1, 5, 2)
buttonsBar.storeButton.setBackgroundColor(colors.blue)
--updateButton
buttonsBar.updateButton = window.create(buttonsBar, 7, 1, 6, 2)
buttonsBar.updateButton.setBackgroundColor(colors.blue)

--updateButton
buttonsBar.sortButton = window.create(buttonsBar, 15, 1, 4, 2)
buttonsBar.sortButton.setBackgroundColor(colors.blue)
function buttonsBar.draw()
    buttonsBar.clear()

    --store buttonsBar
    buttonsBar.storeButton.clear()
    buttonsBar.storeButton.setCursorPos(1,1)
    buttonsBar.storeButton.write("store")
    --update Buttons
    buttonsBar.updateButton.clear()
    buttonsBar.updateButton.setCursorPos(1,1)
    buttonsBar.updateButton.write("update")
    --sort Buttons
    buttonsBar.sortButton.clear()
    buttonsBar.sortButton.setCursorPos(1,1)
    buttonsBar.sortButton.write("sort")
end


function view.root.draw()
    root.clear()
    topWindow.draw()
    statusBar.draw()
    buttonsBar.draw()
    contentWindow.draw()
end
return view