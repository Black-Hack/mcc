-- nbt.lua

local deflate = require "/mcc/lib/compress/deflatelua" -- Gzip decompress library
local modulePath = debug.getinfo(1, "S").source:sub(2)
local nbtreader = require (modulePath:gsub("[^/]+$", "") .. "nbtreader")
local nbt = {}                                      -- Define a table to hold our module functions and data


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
function nbt.write(filename, data)
	-- Implement the logic here to convert the Lua table to NBT format and write it to a file
	-- You'll need to serialize the Lua table into NBT format

	-- Example pseudocode:
	-- 1. Open the file for writing
	-- 2. Convert the Lua table to NBT format
	-- 3. Write the NBT data to the file
	-- 4. Close the file
end

function nbt.nbt2table(tag)
    
    if tag.type == TAG_COMPOUND then
        local c = {}
        for name, innerTag in pairs(tag.content) do
            c[name] = nbt.nbt2table(innerTag)
        end
        return c
    elseif tag.type == TAG_LIST then
        local l = {}
        for innerTag in pairs(tag.content) do
            table.insert(l, (nbt.nbt2table(innerTag)))
        end
        return l
    else
       return tag.content
    end
end
return nbt -- Return the module table
