-- defualt direction is facing towards the lava farm


local itpclient
local traverse = require "/mcc.lib.traverse"

local serverMode = false
local fuelServerId, bucketsChestName, lavaChestName


LAVA_BUCKET = 'minecraft:lava_bucket'
BUCKET = 'minecraft:bucket'
CAULDREN_TTHRESHOLD = 6

if #arg > 0 then
	serverMode = true
	print("fuel server id:")
	fuelServerId = tonumber(read())

	print("empty buckets chestname:")
	bucketsChestName = read()
	
	print("lava buckets chestname:")
	lavaChestName = read()
	itpclient = require "/mcc.lib.itp.itpclient"
	rednet.open("bottom")
end





--- Wait until the CAULDREN_TTHRESHOLD is filled with lava
local function monitorCauldren()
	local len = 0
	print('waiting for cualdrens to fill up...')
	while os.pullEvent("redstone") do
		if redstone.getAnalogInput("bottom") ~= 0 then
			len = len + 1
			print(len .. " cauldrens are filled")
			if len >= CAULDREN_TTHRESHOLD then
				return ;
			end
		end
	end
end



local function fetchEmptyBuckets()
	turtle.turnLeft()
	turtle.select(1)
	turtle.suck(16) --suck 16 buckets
	if turtle.getItemCount() < 16 then
		if serverMode and fuelServerId then
			-- request 16 empty buckets
			local response = itpclient.request(fuelServerId):setInventory(bucketsChestName)
			:addItem({name=BUCKET, amount = 16 - turtle.getItemCount()})
			:sendPullItemRequest()
			if #response.items == 0 then
				error(textutils.serialise(response))
			end
			turtle.suck(16 - turtle.getItemCount())
		else
			turtle.turnRight()
			error("not enough empty buckets")
		end
	end
	turtle.turnRight()
end

local function collectLava()
	turtle.placeDown()
end

local function traverseFarm()
	turtle.forward()
	turtle.up(); turtle.up()
	traverse.rect(4, 4, false, collectLava)
	turtle.down(); turtle.down()
	turtle.back()
end

local function handleFullInventory()
	if serverMode and fuelServerId then
		-- send push request to fuel server
		local response = itpclient.request(fuelServerId):setInventory(lavaChestName)
			:addItem({name = LAVA_BUCKET, amount = 64})
			:sendPushItemRequest()

		if #response.items == 0 then
			error(textutils.serialise(response))
		end

	else
		turtle.turnLeft()
		error("lava inventory is full")
	end
end
local function emptyInventory()
	turtle.turnRight()
	for slot = 1, 16 do
		local item = turtle.getItemDetail(slot)
		if item ~= nil and item.name == LAVA_BUCKET then
			turtle.select(slot)
			if not turtle.drop() then
				handleFullInventory()
			end
		end
	end
	turtle.turnLeft()

	turtle.turnLeft()
	for slot = 1, 16 do
		local item = turtle.getItemDetail(slot)
		if item ~= nil and item.name == BUCKET then
			turtle.select(slot)
			turtle.drop()
		end
	end
	turtle.turnRight()

	turtle.select(1)
end
local function refuelIfNeeded()
	if turtle.getFuelLevel() > 500 then
		return 
	end
	for slot = 1, 16 do
		local item = turtle.getItemDetail(slot)
		if item ~= nil and item.name == LAVA_BUCKET then
			turtle.select(slot)
			turtle.refuel()
			return
		end
	end
end
local function main()
	while true do
		monitorCauldren()
		fetchEmptyBuckets()
		traverseFarm()
		refuelIfNeeded()
		emptyInventory()
	end
end



main()
