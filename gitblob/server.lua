local M = {}

function M.startServer(hostname)
	M.hostname = hostname
	rednet.open('back')
	rednet.host("ftp", hostname)

end
function M.watchDirectory(directory)
	M.baseDir = fs.combine(directory, '.')
    print("watching ".. M.baseDir .. " ")
	for _, filename in pairs(M.listAllFiles(M.baseDir)) do
		print("file: " .. M.removePrefix(filename, M.baseDir.."/"))
	end

	while true do
		local id, message, protocol = rednet.receive()
		if protocol ~= "ftp" then
			rednet.send(id, "unsupported protocol", protocol)
		else
			local request = textutils.unserialise(message)
			if request.type == "file_request" then
				M.sendFile(id, request.body.filename)
			end
			if request.type == "update" then
				local files = M.listAllFiles(M.baseDir)
				local response = {type = "update_response", body = {}}
				response.body.files = {}
				for i = 1, #files do
					local file = {}
					file.filename = M.removePrefix(files[i], M.baseDir..'/')
					file.attributes = fs.attributes(files[i])
					table.insert(response.body.files, file)
				end
				rednet.send(id, textutils.serialise(response), "ftp")
			end

		end
	end
end
function M.sendFile(receiverId, filename)
	local response = {type = "file_response", body = {file = {}}}
	local localFilePath = fs.combine(M.baseDir, filename)
	response.body.file.filename = filename
	response.body.file.attributes = fs.attributes(localFilePath)
	response.body.file.fileData = fs.open(localFilePath, "r").readAll()
	rednet.send(receiverId, textutils.serialise(response), "ftp")
end

--lists all files recursively
function M.listAllFiles(directory, level)
	local allFiles = {}
	level = level or 0

	for _, filename in ipairs(fs.list(directory)) do
		if fs.isDir(fs.combine(directory, filename)) then
			local res = M.listAllFiles(fs.combine(directory, filename), level + 1)
			for i = 1, #res do
				table.insert(allFiles, res[i])
			end
		else
			table.insert(allFiles, fs.combine(directory, filename))
		end
	end
	return allFiles
end

function M.removePrefix(inputString, prefix)
    if string.sub(inputString, 1, #prefix) == prefix then
        return string.sub(inputString, string.len(prefix) + 1)
    else
        return inputString
    end
end
return M
