local packageInfo = {
    type = "github",
    author = "bieno12",
    branch = "master",
    repository = "mcc",
    src = "/",
    target = '/mcc'
}
local ETAG_PATH = ".update/etags"
local API_URL = "https://api.github.com/repos/"
local LIST_CONTENTS_URL = API_URL .. packageInfo.author .. "/" .. packageInfo.repository .."/contents/"..packageInfo.branch.."?recursive=true"
local GIT_TREES_URL = API_URL .. packageInfo.author .. "/" .. packageInfo.repository .."/git/trees/"

local DOWNLOAD_URL_PREFIX = 'https://raw.githubusercontent.com/'..packageInfo.author.."/"..packageInfo.repository.."/"..packageInfo.branch.."/"



local function log(message, color)
    if color == nil then color = colors.white end
    if term and term.isColor() then
        term.setTextColor(color)
        print(message)
        term.setTextColor(colors.white)
    else
        print(message)
    end
end
local function httpGet(url, headers)
    if headers == nil then headers = {} end
    local response, errstring = http.get(url, headers, true)
    if response  == nil then
        error("failed to get ".. url ..":" .. errstring)
    end
    return response
end


local function loadEtags()
    local etagStoragePath = fs.combine(packageInfo.target, ETAG_PATH)
    if not fs.exists(etagStoragePath) then
      return {}
    end
    local data = io.open(etagStoragePath):read("*all")
    if data then
      return textutils.unserialise(data) or {}
    end
    return {}
  end

  local function saveEtags(etags)
    local etagStoragePath = fs.combine(packageInfo.target, ETAG_PATH)
    -- Ensure the directory exists
    local file, err = fs.open(etagStoragePath, "w")
    if file == nil then error(err) end
    file.write(textutils.serialise(etags))
    file.close()
  end

local function saveFile(content, targetFilename)
    local file = fs.open(fs.combine(packageInfo.target, targetFilename), 'wb')
    file.write(content)
    file.close()
end


local function getGitTree(sha)
    local fullurl = GIT_TREES_URL..sha.. "?recursive=true"
    local response = httpGet(fullurl).readAll()
    response = textutils.unserialiseJSON(response)
    local files = {}
    for _, item in pairs(response['tree']) do
        if item.type == "blob" then
            files[item.path] = DOWNLOAD_URL_PREFIX .. item.path
        end
    end
    return files
end

local function fetchPackage()
    local packageFiles = getGitTree(packageInfo.branch)
    local etags = loadEtags()
    local tasks = {}
    for targetFilename, url in pairs(packageFiles) do
        table.insert(tasks,
            function ()
                local response = httpGet(url, {["If-None-Match"] = etags[targetFilename]})
                local remoteEtag = response.getResponseHeaders()["ETag"]
                etags[targetFilename] = remoteEtag
                if response.getResponseCode() == 200 then
                    saveFile(response.readAll(), targetFilename)
                    log("downloaded: "..targetFilename, colors.green)
                end
            end
        )
    end
    parallel.waitForAll(table.unpack(tasks))
    saveEtags(etags)
end

fs.makeDir(packageInfo.target)
fetchPackage()

