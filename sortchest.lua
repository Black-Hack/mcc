local sortchest = require 'lib.sortchest'

while true do
    sortchest.sort(nil, function(a, b)
        if a.item.name < b.item.name then return true end
        if a.item.name > b.item.name then return false end
        
        if a.item.count < b.item.count then return false end
        if a.item.count > b.item.count then return true end
        
        local chestA = peripheral.getName(a.chest)
        local chestB = peripheral.getName(b.chest)
        if chestA < chestB then return true end
        if chestA > chestB then return false end
        
        if a.slot < b.slot then return true end
        if a.slot > b.slot then return false end
        
        return false
    end)
end

