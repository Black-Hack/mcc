PROTOCOL = 'itp'

local client = {}


--- Creates a request builder object.

--- @param server number|string The server ID or hostname. Prefer ID over hostname due to long lookup time.
--- @return table @The request builder object.
local function createRequestBuilder(server)
    local requestBuilder = {
        server = server,
        items = {},
    }

    --- Adds an item to the list of requested items.
    --- @param item table @The item should have at least name and amount fields.
    --- @return table @The request builder object.
    function requestBuilder:addItem(item)
        table.insert(requestBuilder.items, item)
        return requestBuilder
    end
    --- defines the deposit inventory.
    --- @param depositInventory string @name of chest to deposit items to.
    --- @return table @The request builder object.
    function requestBuilder:setInventory(depositInventory)
        requestBuilder.inventory = depositInventory
        return requestBuilder
    end

    --- defines the deposit inventory.
    --- @param index string @type of the request.
    --- @return table @The request builder object.
    function requestBuilder:setIndex(index)
        requestBuilder.index = index
        return requestBuilder
    end
    --- Constructs the final request object.
    --- @param timeout number @The timeout waiting for response
    --- @return table|nil The request object.
    function requestBuilder:sendPullItemRequest(timeout)
        local request = {
            index = requestBuilder.index,
            type =  "pull_item",
			depositInventory = requestBuilder.inventory,
			items = requestBuilder.items
        }
        -- Send the request to the server
		rednet.send(server, textutils.serialise(request), PROTOCOL)

		-- wait for response
		local id, message = {}, {}
		while id ~= server and id ~= nil do
			id, message = rednet.receive(PROTOCOL, timeout)
		end

        if id == nil then return nil end

		local response = textutils.unserialise(message)
        return response
    end

    --- Constructs the final request object.
    --- @param timeout number @The timeout waiting for response
    --- @return table|nil The request object.
    function requestBuilder:sendPushItemRequest(timeout)
        local request = {
            index = requestBuilder.index,
            type =  "push_item",
			fromInventory = requestBuilder.inventory,
			items = requestBuilder.items
        }
        -- Send the request to the server
		rednet.send(server, textutils.serialise(request), PROTOCOL)
		-- wait for response
		local id, message = {}, {}
		while id ~= server and id ~= nil do
			id, message = rednet.receive(PROTOCOL, timeout)
		end

        if id == nil then return nil end

		local response = textutils.unserialise(message)
        return response
    end

    return requestBuilder
end

--- Creates a request builder object.
---@param server number|string @The server ID or hostname. Prefer ID over hostname due to long lookup time.
---@return table @The request builder object.
function client.request(server)
    if type(server) == "string" then
        server = rednet.lookup(PROTOCOL, server) -- Returns the number
    end
    return createRequestBuilder(server)
end

return client
