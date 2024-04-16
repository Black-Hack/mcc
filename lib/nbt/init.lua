-- nbt.lua

local deflate = require "/mcc/lib/compress/deflatelua" -- Gzip decompress library
local modulePath = debug.getinfo(1, "S").source:sub(2)
local nbtreader = require (modulePath:gsub("[^/]+$", "") .. "nbtreader")
local nbtwriter = require (modulePath:gsub("[^/]+$", "") .. "nbtwriter")

DEBUG = false

local nbt = {}
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

-- Function to read an NBT file and convert it to a Lua table
function nbt.read(filename)
	filename = shell.resolve(filename)
	local file = io.open(filename, "rb") -- Open the NBT file for reading in binary mode
	if not file then
		error("Failed to open file: " .. filename)
	end

	local isCompressed = false -- Flag to indicate if the file is compressed
	local tempfilename = shell.resolve "nbtfile.temp"
	-- Check if the file is compressed by inspecting the first two bytes
	local magicNumber = file:read(2)
	file:seek("set") -- Reset the file position to the beginning
	if magicNumber == "\x1f\x8b" then
		-- If the first two bytes match the gzip magic number, the file is compressed
		print("compresesd")
		isCompressed = true

		local tmpFile = assert(io.open(tempfilename, "wb"))
		deflate.gunzip { input = file, output = tmpFile}

		file:close()
		tmpFile:close()
		local err
		file, err = assert(io.open(tempfilename, "r+b"))
	end
	-- Call nbt2table.read to parse the NBT data into a Lua table
	local parsedData = nbtreader.read(file)
	file:close()

	if isCompressed then
		fs.delete(tempfilename)
	end
	return parsedData, isCompressed

end

-- Function to write a Lua table to an NBT file
function nbt.write(filename, tag)
    -- Open the file for writing
    local file = io.open(shell.resolve(filename), "wb")
    if not file then
        error("Failed to open file for writing: " .. filename)
    end
    nbtwriter.write(tag, file)
    file:close()
end


function nbt.nbt2table(tag)
    if tag.tagType == TAG_COMPOUND then
        local c = {}

		for name, innerTag in pairs(tag.content) do
           innerTag = nbt.nbt2table(innerTag)
			c[name] = innerTag
		end
        return c
    elseif tag.tagType == TAG_LIST then
			local l = {}
        for _,innerTag in pairs(tag.content) do

            table.insert(l, (nbt.nbt2table(innerTag)))
        end
        return l
    else
       return tag.content
    end 
end
return nbt -- Return the module table
