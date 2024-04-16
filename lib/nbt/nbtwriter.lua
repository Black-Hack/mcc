
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

function nbtwriter.write(tag, filehandler)
    -- Write the tag type byte
    filehandler:write(string.char(tag.tagType))
    
    -- Write tag content based on tag type
    if tag.tagType == TAG_END then
        -- Nothing to write for TAG_END
    elseif tag.tagType == TAG_BYTE then
        filehandler:write(string.pack(">b", tag.content))
    elseif tag.tagType == TAG_SHORT then
        filehandler:write(string.pack(">H", tag.content))
    elseif tag.tagType == TAG_INT then
        filehandler:write(string.pack(">i", tag.content))
    elseif tag.tagType == TAG_LONG then
        filehandler:write(string.pack(">l", tag.content))
    elseif tag.tagType == TAG_FLOAT then
        filehandler:write(string.pack(">f", tag.content))
    elseif tag.tagType == TAG_DOUBLE then
        filehandler:write(string.pack(">d", tag.content))
    elseif tag.tagType == TAG_BYTE_ARRAY then
        -- Write the length of the byte array as a 4-byte integer
        filehandler:write(string.pack(">i", #tag.content))
        -- Write the byte array itself
        filehandler:write(tag.content)
    elseif tag.tagType == TAG_STRING then
        -- Write the length of the string as a 2-byte integer
        filehandler:write(string.pack(">H", #tag.content))
        -- Write the string itself
        filehandler:write(tag.content)
    elseif tag.tagType == TAG_LIST then
        -- Write the list type byte
        filehandler:write(string.char(tag.innerTagType))
        -- Write the length of the list as a 4-byte integer
        filehandler:write(string.pack(">i", #tag.content))
        -- Write each element of the list recursively
        for _, element in ipairs(tag.content) do
            nbtwriter.write(element, filehandler)
        end
    elseif tag.tagType == TAG_COMPOUND then
        -- Write each compound element recursively
		if tag.name ~= nil then
			nbtwriter.write({tagType = TAG_STRING, content = tag.name}, filehandler)
		end
        for name, subtag in pairs(tag.content) do
            -- Write subtag name
            nbtwriter.write({tagType = TAG_STRING, content = name}, filehandler)
            -- Write subtag itself
            nbtwriter.write(subtag, filehandler)
        end
        -- Write TAG_END to indicate end of compound
        filehandler:write(string.char(TAG_END))
    elseif tag.tagType == TAG_INT_ARRAY then
        -- Write the length of the int array as a 4-byte integer
        filehandler:write(string.pack(">i", #tag.content))
        -- Write each integer of the array
        for _, value in ipairs(tag.content) do
            filehandler:write(string.pack(">i", value))
        end
    elseif tag.tagType == TAG_LONG_ARRAY then
        -- Write the length of the long array as a 4-byte integer
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