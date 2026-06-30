-- loader.lua
-- Loads protected.lua, then the main UI (which now includes ESP).
-- Run THIS file through PolSec, then paste the output into your executor.

local DEBUG = true

local function dbg(...)
    if DEBUG then
        warn("[loader] " .. table.concat({...}, " "))
    end
end

local function fetch(url)
    local bust = "?nocache=" .. tostring(math.floor(tick() * 1000))
    if string.find(url, "?") then
        bust = "&nocache=" .. tostring(math.floor(tick() * 1000))
    end
    url = url .. bust

    for i = 1, 3 do
        if typeof(request) == "function" then
            local ok, res = pcall(function()
                return request({
                    Url = url,
                    Method = "GET",
                    Headers = {
                        ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
                    }
                })
            end)
            if ok and res then
                if res.StatusCode == 200 and type(res.Body) == "string" and #res.Body > 0 then
                    return res.Body
                else
                    dbg("request non-200/empty: status=" .. tostring(res.StatusCode) .. " len=" .. tostring(type(res.Body) == "string" and #res.Body or 0))
                end
            else
                dbg("request error: " .. tostring(res))
            end
        end

        for _, cache in ipairs({false, true}) do
            local ok, content = pcall(function()
                return game:HttpGet(url, cache)
            end)
            if ok and type(content) == "string" and #content > 0 then
                return content
            elseif not ok then
                dbg("HttpGet error (cache=" .. tostring(cache) .. "): " .. tostring(content))
            end
        end

        if i < 3 then
            task.wait(0.5)
        end
    end
    return nil
end

local function loadUrl(url)
    local content = fetch(url)
    if not content then
        warn("[loader] failed to fetch a required script")
        return
    end

    -- strip UTF-8 BOM if present
    if content:sub(1, 3) == "\239\187\191" then
        content = content:sub(4)
    end

    local chunk, loadErr = loadstring(content)
    if not chunk then
        warn("[loader] invalid lua received | len=" .. tostring(#content) .. " | first=[" .. content:sub(1, 80):gsub("\n", "\\n") .. "] | last=[" .. content:sub(-80):gsub("\n", "\\n") .. "] | err=" .. tostring(loadErr))
        return
    end

    local ok, runErr = pcall(chunk, url)
    if not ok then
        warn("[loader] runtime error: " .. tostring(runErr))
    end
end

local function loadFile(path)
    local ok, content = pcall(function()
        return readfile(path)
    end)
    if not ok or type(content) ~= "string" or #content == 0 then
        dbg("failed to read: " .. tostring(path) .. " | ok=" .. tostring(ok) .. " type=" .. type(content))
        return false
    end

    local chunk, loadErr = loadstring(content)
    if not chunk then
        warn("[loader] invalid lua from local file: " .. tostring(path) .. " | " .. tostring(loadErr))
        return false
    end

    local runOk, runErr = pcall(chunk, path)
    if not runOk then
        warn("[loader] runtime error in " .. tostring(path) .. ": " .. tostring(runErr))
        return false
    end
    print("[loader] loaded: " .. tostring(path))
    return true
end

local USE_LOCAL = false

local PROTECTED_URL = "https://raw.githubusercontent.com/dsfvxcvb/evolution/main/protected.lua"
local UI_URL        = "https://raw.githubusercontent.com/dsfvxcvb/evolution/main/use_kimi.txt"

local PROTECTED_PATHS = {
    "advanced/protected.lua",
    "protected.lua",
    "C:\\Users\\Adkin\\Downloads\\advanced\\protected.lua",
    "C:/Users/Adkin/Downloads/advanced/protected.lua"
}
local UI_PATHS = {
    "advanced/use_kimi.txt",
    "use_kimi.txt",
    "C:\\Users\\Adkin\\Downloads\\advanced\\use_kimi.txt",
    "C:/Users/Adkin/Downloads/advanced/use_kimi.txt"
}

if USE_LOCAL then
    local protectedLoaded = false
    for _, p in ipairs(PROTECTED_PATHS) do
        if loadFile(p) then
            protectedLoaded = true
            break
        end
    end
    if not protectedLoaded then
        warn("[loader] could not load protected.lua locally; tried: " .. table.concat(PROTECTED_PATHS, ", "))
    end

    local uiLoaded = false
    for _, p in ipairs(UI_PATHS) do
        if loadFile(p) then
            uiLoaded = true
            break
        end
    end
    if not uiLoaded then
        warn("[loader] could not load use_kimi.txt locally; tried: " .. table.concat(UI_PATHS, ", "))
    end
else
    loadUrl(PROTECTED_URL)
    loadUrl(UI_URL)
end
