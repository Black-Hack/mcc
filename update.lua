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
    entry('excavate.lua')
)
