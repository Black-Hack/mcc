PROTOCOL = 'itp'

local server = {}

--- Creates a response builder object.
---@return table The response builder object.
local function createResponseBuilder()
    local responseBuilder = {
        items = {},
        errors = {}
    }

    --- Adds an item to the list of transferred items.
    --- @param item table The item to add.
    function responseBuilder:addItem(item)
        table.insert(responseBuilder.items, item)
    end

    --- Adds an error to the list of errors.
    --- @param errorType string The type of error.
    --- @param errorMessage string The error message.
    function responseBuilder:addError(errorType, errorMessage)
        table.insert(responseBuilder.errors, { type = errorType, message = errorMessage })
    end

    --- Constructs the final response object.
    --- @return table The pull item response object.
    function responseBuilder:buildPullItemResponse()
        local response = {
            index = 2,
            type = "pull_item",
            items = responseBuilder.items,
            errors = responseBuilder.errors
        }
        return response
    end
    --- Constructs the final response object.
    --- @return table The response object.
    function responseBuilder:buildPushItemResponse()
        local response = {
            index = 2,
            type = "push_item",
            items = responseBuilder.items,
            errors = responseBuilder.errors
        }
        return response
    end
    return responseBuilder
end

--- Listens for requests and handles them using the provided request handler.
---@param requestHandler function The function to handle incoming requests.
function server.listen(requestHandler)
    while true do
        local id, message = rednet.receive(PROTOCOL)
        local request = textutils.unserialise(message)
        -- Call the request handler to process the request
        local response = requestHandler(request, id)
        -- Send the response back to the client
        rednet.send(id, textutils.serialise(response), PROTOCOL)
    end
end

server.responseBuilder = createResponseBuilder
return server
