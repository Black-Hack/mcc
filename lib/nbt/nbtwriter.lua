
local nbtwriter = {}
local m = {}
DEBUG = true
TAG_END = 0
TAG_BYTE = 1
TAG_SHORT = 2
TAG_INT = 3
TAG_LONG = 4
TAG_FLOAT = 5
TAG_DOUBLE = 6
TAG_BYTE_ARRAY = 7
TAG_STRING = 8
TAG_LIST = 9
TAG_COMPOUND = 10
TAG_INT_ARRAY = 11
TAG_LONG_ARRAY = 12

DEBUG = false
local logger
local function log(message)
	if DEBUG then
		if logger == nil then
			if fs.exists(shell.resolve "log") then
				logger = assert(io.open(shell.resolve "log", "a"))
			else
				logger = assert(io.open(shell.resolve "log", "w+"))
			end
		end
		logger:write(message .."\n")
		logger:flush()
	end
end

function m.writeName(name, filehandler)
    filehandler:write(string.pack(">H", #name))
    filehandler:write(name)
end
function nbtwriter.write(tag, filehandler, context)
    -- Write the tag type byte
    if context ~= TAG_LIST then
        log("Writing tag type: " .. tag.tagType)
        filehandler:write(string.pack(">b", tag.tagType))
    end
    if tag.name ~= nil then
        log("Writing tag name: " .. tag.name)
        m.writeName(tag.name, filehandler)
    end
    -- Write tag content based on tag type
    if tag.tagType == TAG_END then
        -- Nothing to write for TAG_END
    elseif tag.tagType == TAG_BYTE then
        log("Writing byte: " .. tag.content)
        filehandler:write(string.pack(">b", tag.content))
    elseif tag.tagType == TAG_SHORT then
        log("Writing short: " .. tag.content)
        filehandler:write(string.pack(">h", tag.content))
    elseif tag.tagType == TAG_INT then
        log("Writing int: " .. tag.content)
        filehandler:write(string.pack(">i", tag.content))
    elseif tag.tagType == TAG_LONG then
        log("Writing long: " .. tag.content)
        filehandler:write(string.pack(">l", tag.content))
    elseif tag.tagType == TAG_FLOAT then
        log("Writing float: " .. tag.content)
        filehandler:write(string.pack(">f", tag.content))
    elseif tag.tagType == TAG_DOUBLE then
        log("Writing double: " .. tag.content)
        filehandler:write(string.pack(">d", tag.content))
    elseif tag.tagType == TAG_BYTE_ARRAY then
        log("Writing byte array length: " .. #tag.content)
        -- Write the length of the byte array as a 4-byte integer
        filehandler:write(string.pack(">i", #tag.content))
        -- Write the byte array itself
        filehandler:write(tag.content)
    elseif tag.tagType == TAG_STRING then
        log("Writing string: " .. tag.content)
        -- Write the length of the string as a 2-byte integer
        filehandler:write(string.pack(">H", #tag.content))
        -- Write the string itself
        filehandler:write(tag.content)
    elseif tag.tagType == TAG_LIST then
        -- Write the list type byte
        log("Writing list type: " .. tag.innerTagType)
        filehandler:write(string.char(tag.innerTagType))
        -- Write the length of the list as a 4-byte integer
        log("Writing list length: " .. #tag.content)
        filehandler:write(string.pack(">i", #tag.content))
        -- Write each element of the list recursively
        for _, element in ipairs(tag.content) do
            nbtwriter.write(element, filehandler, TAG_LIST)
        end
    elseif tag.tagType == TAG_COMPOUND then
        for name, subtag in pairs(tag.content) do
            nbtwriter.write(subtag, filehandler, TAG_COMPOUND)
        end
        log("write end tag")
        filehandler:write(string.char(TAG_END))
    elseif tag.tagType == TAG_INT_ARRAY then
        -- Write the length of the int array as a 4-byte integer
        log("Writing int array length: " .. #tag.content)
        filehandler:write(string.pack(">i", #tag.content))
        -- Write each integer of the array
        for _, value in ipairs(tag.content) do
            filehandler:write(string.pack(">i", value))
        end
    elseif tag.tagType == TAG_LONG_ARRAY then
        -- Write the length of the long array as a 4-byte integer
        log("Writing long array length: " .. #tag.content)
        filehandler:write(string.pack(">i", #tag.content))
        -- Write each long integer of the array
        for _, value in ipairs(tag.content) do
            filehandler:write(string.pack(">l", value))
        end
    else
        error("Unsupported tag type: " .. tag.tagType)
    end
end


return nbtwriter