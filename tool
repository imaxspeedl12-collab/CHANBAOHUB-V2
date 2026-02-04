if CHANBAOHUB_LOADED and not _G.CHANBAOHUB_DEBUG == true then
    print("CHANBAOHUB is already running!", 0)
    return
end
pcall(function() getgenv().CHANBAOHUB_LOADED = true end)

local loadgame = game
repeat task.wait() until loadgame:IsLoaded() and game.Players.LocalPlayer

local function checkraid() return game.PlaceId == 18859789310 end
local function checksea2() return game.PlaceId == 7258239416 end
local function checksea1() return game.PlaceId == 4587545091 end
local function sea(value)
    return (value == 3 and game.PlaceId == 15759515082) or
           (value == 1 and game.PlaceId == 4520749081) or
           (value == 2 and game.PlaceId == 6381829480) or
           (value == 4 and game.PlaceId == 5931540094)
end

local httprequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
if not httprequest then
    warn("Executor không hỗ trợ HTTP!")
    game.Players.LocalPlayer:Kick("Executer Không Hỗ Trợ Script")
    return
end

local function checkForUpdatesAndLoadOnce(url)
    local lastCode = ""
    local hasLoaded = false
    task.spawn(function()
        while true do
            local success, newCode = pcall(function()
                return game:HttpGet(url .. "?t=" .. os.time(), true)
            end)
            if success and newCode ~= lastCode and not hasLoaded then
                lastCode = newCode
                loadstring(newCode)()
                hasLoaded = true
            elseif newCode == lastCode then
                hasLoaded = false
            end
            task.wait(5)
        end
    end)
end

-- LINK SOURCE MỚI CỦA MÀY CHO KING LEGACY (SẠCH HOÀN TOÀN, THAY THẾ GIST 1 CŨ)
local KING_LEGACY_HUB = "https://raw.githubusercontent.com/imaxspeedl12-collab/cbv2/refs/heads/main/SOURCE%20HOP"

-- Load hub theo game
if checksea1() or checksea2() or checkraid() or sea(1) or sea(2) or sea(3) or sea(4) or game.PlaceId == 18192562963 then
    checkForUpdatesAndLoadOnce(KING_LEGACY_HUB)
else
    print("Game chưa hỗ trợ")
end

-- Queue on teleport tự chạy lại source mới của mày
local TeleportCheck = false
local queue_on_teleport = (syn and syn.queue_on_teleport) or queue_on_teleport or (fluxus and fluxus.queue_on_teleport)
game:GetService("Players").LocalPlayer.OnTeleport:Connect(function(State)
    if not TeleportCheck and queue_on_teleport then
        TeleportCheck = true
        queue_on_teleport([[
            loadstring(game:HttpGet("https://raw.githubusercontent.com/imaxspeedl12-collab/cbv2/refs/heads/main/SOURCE%20HOP?t="..os.time(),true))()
        ]])
    end
end)
