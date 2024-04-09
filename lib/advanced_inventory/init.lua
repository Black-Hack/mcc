M = {}

function M.wrap(inventory)
	-- get name of chest/inventory
	function inventory.getName()
		return peripheral.getName(inventory)
	end

	--item name not item display name
	--returns a list of slots that have the item
	function inventory.getItemSlotsByName(itemName)
		local res = {}
		for slot, itemDetail in pairs(inventory.list()) do
			if itemDetail.name == itemName then
				table.insert(res, slot)
			end
		end
		return res
	end
	--first item slot met is returned
	function inventory.getItemSlotByName(itemName)
		for slot, itemDetail in pairs(inventory.list()) do
			if itemDetail.name == itemName then
				return slot
			end
		end
		return nil
	end

	--push the amount specified or less of the item to target inventory
	--returns pushedAmount
	function inventory.pushItemByName(itemName, amount, targetInventory)
		local prevAmount = amount
		local slots = inventory.getItemSlotsByName(itemName)
		local i = 1
		local nslots = #slots
		while i <= nslots and amount > 0 do
			local pushedAmount = inventory.pushItems(targetInventory.getName(), slots[i], amount)
			if pushedAmount == 0 then break end
			amount = amount - pushedAmount
			i = i + 1
		end
		return prevAmount - amount
	end
	function inventory.pullItemByName(itemName, amount, sourceInventory)
		return sourceInventory.pushItemByName(itemName, amount, inventory)
	end
	return inventory
end

return M