function sort(inv, cmp)
    inv = inv or { peripheral.find 'inventory' }
    cmp = cmp or function(a, b) return a.item.name < b.item.name end

    local occupied = {}
    local emptyChest = nil
    local emptySlot = nil

    for _, chest in pairs(inv) do
        local items = chest.list()
        chest.items = items

        for slot, item in pairs(items) do
            local data = {
                item = item,
                chest = chest,
                slot = slot,
            }

            occupied[#occupied + 1] = data
            item.data = data
        end

        if not emptyChest then
            for i = 1, chest.size() do
                if not items[i] then
                    emptyChest = chest
                    emptySlot = i
                    break
                end
            end
        end
    end

    if not emptyChest then
        print("Error: no empty slot found.")
        return
    end

    function doMoveItem(fromChest, fromSlot, toChest, toSlot)
        local toChestName = peripheral.getName(toChest)

        fromChest.pushItems(toChestName, fromSlot, nil, toSlot)

        local item = fromChest.items[fromSlot]
        fromChest.items[fromSlot] = nil
        toChest.items[toSlot] = item
        item.data.chest = toChest
        item.data.slot = toSlot
    end

    function moveItem(fromChest, fromSlot, toChest, toSlot)
        if fromChest == toChest and fromSlot == toSlot then
            return
        end
        if toChest.items[toSlot] then
            doMoveItem(toChest, toSlot, emptyChest, emptySlot)
        end
        doMoveItem(fromChest, fromSlot, toChest, toSlot)
        emptyChest = fromChest
        emptySlot = fromSlot
    end

    table.sort(occupied, cmp)

    local currChestIdx = 1
    local currSlot = 1
    for i = 1, #occupied do
        local item = occupied[i]
        local currChest = inv[currChestIdx]
        item.targetChest = currChest
        item.targetSlot = currSlot

        currSlot = currSlot + 1
        if currSlot > currChest.size() then
            currChestIdx = currChestIdx + 1
            currSlot = 1
        end
    end

    for _, item in pairs(occupied) do
        moveItem(item.chest, item.slot, item.targetChest, item.targetSlot)
    end
end

return {
    sort = sort,
}
