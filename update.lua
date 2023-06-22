local URL_PREFIX = 'https://raw.githubusercontent.com/bieno12/mcc/master/'
local DIR_PREFIX = '/mcc/'

function entry(name)
    return function()
        response = http.get(URL_PREFIX .. name, nil, true)
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
    entry('lib/sortchest.lua'),
    entry('LICENSE.md'),

    entry('lib/traverse.lua'),
    entry('inventory.lua'),
    entry('window.lua')
    
)
