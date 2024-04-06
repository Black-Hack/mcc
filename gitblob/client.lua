local M = {}
GITBLOB_HOSTNAME = "gitblob"
PROTOCOL = "ftp"
function M.setServer(serverId)
	M.serverId = serverId
end

function M.syncDirectory(baseDirectory)
	if not fs.isDir(baseDirectory) then
		fs.makeDir(baseDirectory)
	end
	M.baseDirectory = fs.combine(baseDirectory, '.')
	--send ftp request to gitblob server
	local requestData = {
		type = "update"
	}
	rednet.send(M.serverId, textutils.serialise(requestData), PROTOCOL)
	--wait for responses from server
	local id, message = {}, {}
	while id ~= nil and id ~= M.serverId do
		id, message = rednet.receive(PROTOCOL, 10)
	end
	if id == nil then
		error("update request timeout")
		return
	end
	local response = textutils.unserialise(message)

	for _, fileMetaData in pairs(response.body.files) do
		local file = M.requestFile(fileMetaData.filename)
		if file ~= nil then
			if M.shouldUpdate(file) then
				M.saveFile(file)
				print("saving file recieved: " .. file.filename)

			else
				print(" file unchanged: " .. file.filename)
			end
		end
	end
	M.deleteOtherFiles(response.body.files)
end

function M.requestFile(filename)
	local request = {
		type = "file_request",
		body = {
			filename = filename
		}
	}
	rednet.send(M.serverId, textutils.serialise(request), PROTOCOL)
	local id, message= {}, {}
	while id ~= nil and id ~= M.serverId do
		id, message = rednet.receive(PROTOCOL, 10)
	end
	if id == nil then
		error("file request timeout")
		return
	end
	local response = textutils.unserialise(message)
	return response.body.file
end
function M.shouldUpdate(file)
	local localFilePath = fs.combine(M.baseDirectory, file.filename)
	if not fs.exists(localFilePath) then
		return true
	end
	if file.attributes.modified > fs.attributes(localFilePath).modified then
		return true
	end
	return false
end

function M.saveFile(file)
	local fullpath = fs.combine(M.baseDirectory, file.filename)
	local handle = fs.open(fullpath, "w")
	handle.write(file.fileData)
	handle.flush()
	handle.close()
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
function M.deleteOtherFiles(keepfiles)
	for i = 1, #keepfiles do
		keepfiles[i] = fs.combine(M.baseDirectory, keepfiles[i].filename)
	end
	for _, filename in pairs( M.listAllFiles(M.baseDirectory)) do
		if not M.containsValue(keepfiles, filename) then
			fs.delete(filename)
			print("deleted file : ".. filename )
		end
	end
end

function M.containsValue(tbl, value)
    for _, v in pairs(tbl) do
        if v == value then
            return true
        end
    end
    return false
end
return M