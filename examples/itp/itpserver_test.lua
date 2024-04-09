-- Import the server module
local server = require("itpserver")
local advanced_inventory = require "/mcc.advanced_inventory"
rednet.open("back")

local storage = advanced_inventory.wrap(peripheral.wrap(arg[1]))
-- Define a function to handle requests from clients
local function handlePullItemRequest(request, clientid)
	local responseBuilder = server.responseBuilder();

    print("pull_item received from client: " .. clientid)

	local depositInventory = peripheral.wrap(request.depositInventory)
	if depositInventory == nil then
		responseBuilder:addError({type = "deposit_error", message = "inventory was not found"})
		return responseBuilder:buildPushItemResponse()
	end

	depositInventory = advanced_inventory.wrap(depositInventory)
    print("Requested Items:")
    for _, item in pairs(request.items) do
        print(item.name, item.amount)
		local transferredAmount = depositInventory.pullItemByName(item.name, item.amount, storage)
		responseBuilder:addItem({ name = item.name, amount = transferredAmount })
    end

    return responseBuilder:buildPullItemResponse()
end
local function handlePushItemRequest(request, clientid)
	local responseBuilder = server.responseBuilder();

    print("push_item received from client: " .. clientid)

	local fromInventory = peripheral.wrap(request.fromInventory)
	if fromInventory == nil then
		responseBuilder:addError({type = "deposit_error", message = "inventory was not found"})
		return responseBuilder:buildPushItemResponse()
	end

	fromInventory = advanced_inventory.wrap(fromInventory)
    print("Requested to push Items:")
    for _, item in pairs(request.items) do
        print(item.name, item.amount)
		local transferredAmount = fromInventory.pushItemByName(item.name, item.amount, storage)
		responseBuilder:addItem({ name = item.name, amount = transferredAmount })
    end

    return responseBuilder:buildPushItemResponse()
end

local function router(request, clientid)
	if request.type == "pull_item" then
		return handlePullItemRequest(request, clientid)
	elseif request.type == "push_item" then
		return handlePushItemRequest(request, clientid)
	end
end

-- Start the server and listen for requests
server.listen(router)
