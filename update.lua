local URL_PREFIX = 'https://raw.githubusercontent.com/' .. settings.get("mcc_repo_path",'Black-Hack/mcc/master/')
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

fs.makeDir(DIR_PREFIX)
fs.makeDir(DIR_PREFIX .. 'lib/')

print(URL_PREFIX)
parallel.waitForAll(
    entry('update.lua'),
    entry('sortchest.lua'),
    entry('excavate.lua'),
    entry('lib/sortchest.lua'),
    entry('LICENSE.md'),

    entry('lib/traverse.lua'),

    entry('inventory_system/controller.lua'),
    entry('inventory_system/model.lua'),
    entry('inventory_system/view.lua'),

    entry('lib/advanced_inventory/init.lua'),

    entry('lib/itp/itpserver.lua'),
    entry('lib/itp/itpclient.lua'),


    entry('gitblob/client.lua'),
    entry('gitblob/server.lua'),
    entry('gitblob/gitblob.lua'),

    entry('examples/advanced_inventory/inventory_test.lua'),
    entry('examples/advanced_inventory/inventory_test.lua'),
    entry('examples/itp/itpclient_test.lua'),
    entry('examples/itp/itpserver_test.lua'),

    entry('lava_farmer/lava_farmer.lua')
)