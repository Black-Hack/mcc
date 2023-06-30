local URL_PREFIX = 'https://raw.githubusercontent.com/bieno12/inventory_system/master/'
local DIR_PREFIX = '/inventory_system/'
local headers = {}
headers["Cache-Control"] = "no-cache"
headers["Pragma"] = "no-cache"

local function entry(name)
    return function()
        local url = URL_PREFIX .. name .. "?timestamp=" .. os.time()
        local response = http.get(url, headers, true)
        print(("%s : %d"):format(name, response.getResponseCode()))
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
    entry('controller.lua'),
    entry('view.lua'),
    entry('model.lua')
)
