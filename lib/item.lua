Item = {}

function Item.getItemSlot(item_name)
    for i = 1, 16 do
        local curr_item = turtle.getItemDetail(i, false)
        if curr_item ~= nil and curr_item.name == item_name then
            return i
        end
    end
    return 0
end
return Item