local URL_PREFIX = 'https://raw.githubusercontent.com/Black-Hack/mcc/master/'
local DIR_PREFIX = '/mcc/'

local headers = {}
headers["cache-control"] = "no-cache"
headers["pragma"] = "no-cache"
local function entry(name)
    return function()
        local response = http.get(URL_PREFIX .. name, headers, true)
        local file = fs.open(DIR_PREFIX .. name, 'wb')
        file.write(response.readAll())
        file.close()
    end
end

fs.delete(DIR_PREFIX)
fs.makeDir(DIR_PREFIX)
fs.makeDir(DIR_PREFIX .. 'lib/')

parallel.waitForAll(
    entry('update.lua'),
    entry('sortchest.lua'),
    entry('excavate.lua'),
    entry('lib/sortchest.lua'),
    entry('LICENSE.md'),

    entry('lib/traverse.lua'),

    entry('inventory_system/controller.lua'),
    entry('inventory_system/model.lua'),
    entry('inventory_system/view.lua')
)
