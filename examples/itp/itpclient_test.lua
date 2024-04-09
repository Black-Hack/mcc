local client = require("itpclient")
rednet.open("back")
local depositInventory = arg[1]
-- Define a function to handle the response from the server
local function handleResponse(response)
    print("Transferred Items:")
    for _, item in ipairs(response.items) do
        print(item.name, item.amount)
    end
    print("Errors:")
    for _, error in ipairs(response.errors) do
        print(error.type, error.message)
    end
end
print("Enter action (push or pull):")
local action = read()

print("Enter item name:")
local itemName = read()

print("Enter item amount:")
local itemAmount = tonumber(read())

local response
if action == "push" then
    response = client.request(0)
        :setInventory(depositInventory)
        :addItem({ name = itemName, amount = itemAmount })
        :sendPushItemRequest()
elseif action == "pull" then
    response = client.request(0)
        :setInventory(depositInventory)
        :addItem({ name = itemName, amount = itemAmount })
        :sendPullItemRequest()
else
    print("Invalid action. Please specify either 'push' or 'pull'.")
    return
end

handleResponse(response)