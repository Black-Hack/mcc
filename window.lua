local strings = require "cc.strings"
local screenWidth, screenHeight = term.getSize()
local root = term.current()
local searchWindow = window.create(root,1, 1, screenWidth, 2)

searchWindow.setBackgroundColor(colors.red)
searchWindow.clear()
searchWindow.myText = "hello"
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
        lines = strings.wrap(placeholder.myDisplayName,
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
os.pullEvent("key")
