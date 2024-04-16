local DEFLATE = require '/mcc/lib/compress/deflatelua'

-- Function to handle errors
local function handleError(errMsg)
	if type(errMsg) == "table" then
		errMsg = textutils.serialise(errMsg)
	end
    error(errMsg)
end

-- Function to uncompress gzip file
local function uncompressGzip(inputFilename, outputFilename)
    local fh, err = fs.open(shell.resolve(inputFilename), 'rb')
    if not fh then
        handleError(err)
    end
    
    local ofh, err = fs.open(shell.resolve(outputFilename), 'wb')
    if not ofh then
        handleError(err)
    end
    
    local success, err = DEFLATE.gunzip {input=fh, output=ofh, disable_crc = true}
    fh.close()
    ofh.close()
    
    if not success then
        handleError(err)
    end
    
    print("Uncompression completed. Output saved to", outputFilename)
end

-- Main function
local function main()
    if #arg ~= 2 then
        print("gzip <input> <output>")
        return
    end
    local inputFilename = arg[1]
    local outputFilename = arg[2] -- Adjust as needed

    local success, err = pcall(uncompressGzip, inputFilename, outputFilename)
    if not success then
        handleError(err)
    end
end

main()
