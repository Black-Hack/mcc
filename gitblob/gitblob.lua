GITBLOB_HOSTNAME = "gitblob"
PROTOCOL = "ftp"
DEFAULT_PATH = '/mcc'
if #arg < 1 then
	print("watch [directory]")
	print("lookup")
	print("sync server_id [directory]")
	return
end

local cmd = arg[1]
print(cmd)

if cmd == "watch" then
	local server = require("server")
	server.startServer("gitblob")
	server.watchDirectory(arg[2] or DEFAULT_PATH)
	return
end
if cmd == "lookup" then
	rednet.open("back")
	print(textutils.serialise(rednet.lookup("ftp")))
end

if cmd == "sync" then
	if #arg < 2 then
		print("sync server_id [directory]")
		return
	end
	local client = require("client")
	client.setServer(tonumber(arg[2]))
	local dir = arg[3] or DEFAULT_PATH
	client.syncDirectory(dir)
end
