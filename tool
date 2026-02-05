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

-- ================== WHITELIST BẰNG USERNAME TỪ PASTEBIN ==================
local player = game.Players.LocalPlayer
local myUsername = player.Name:lower()  -- lowercase để so sánh ko phân biệt

-- THAY LINK NÀY BẰNG LINK RAW THẬT CỦA MÀY
local WHITELIST_URL = "https://pastebin.com/raw/bCzb1um3"  -- <-- EDIT Ở ĐÂY, thay ABC123DEF bằng code thật

print("CHANBAOHUB - Đang check whitelist từ: " .. WHITELIST_URL)

local success, data = pcall(function()
    return game:HttpGet(WHITELIST_URL .. "?t=" .. os.time(), true)
end)

if not success then
    warn("CHANBAOHUB - Load whitelist FAIL: " .. tostring(data))  -- in lỗi chi tiết (ví dụ HTTP 404, 403)
    -- return  -- comment tạm nếu muốn cho chạy dù fail
else
    if data == "" or data:find("Not Found") then
        warn("CHANBAOHUB - Pastebin rỗng hoặc không tồn tại!")
    else
        print("CHANBAOHUB - Load OK, nội dung mẫu: " .. (data:sub(1, 100) or "rỗng"))  -- debug xem data có gì
        local allowed = {}
        for line in data:gmatch("[^\r\n]+") do
            line = line:match("^%s*(.-)%s*$"):gsub("%s+", "")  -- trim space/tab thừa
            if line ~= "" and not line:match("^%-%-") then
                allowed[line:lower()] = true
            end
        end
        
        print("Username của mày: " .. myUsername)
        if allowed[myUsername] then
            print("CHANBAOHUB - Whitelist OK! Username hợp lệ.")
        else
            warn("CHANBAOHUB - Username '" .. player.Name .. "' KHÔNG có trong whitelist!")
            -- player:Kick("Không có quyền dùng CHANBAOHUB!")  -- uncomment nếu muốn kick
            return  -- dừng script nếu ko whitelist
        end
    end
end
-- ================== END WHITELIST ==================

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
