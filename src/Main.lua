--[[
    SNOWY ❄️ — Steal a Brainrot Edition v2.6
    Entry module loaded by SNOWY.lua.
    Implements local session utilities and keeps experience-specific features disabled
    for Steal a Brainrot. Game recognition uses the experience UniverseId; feature implementations are reported separately.
]]
---------------------------------------------------------------- Services
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

---------------------------------------------------------------- Remote module loader
local RAW_BASE = "https://raw.githubusercontent.com/irongg676/SNOWY/main"
local function loadRemoteModule(moduleName)
    local url = RAW_BASE .. "/src/" .. moduleName .. ".lua"
    local ok, source = pcall(function() return game:HttpGet(url) end)
    assert(ok and type(source) == "string" and #source > 0, "SNOWY: failed to download " .. moduleName)
    local compileOk, chunk = pcall(loadstring, source)
    assert(compileOk and type(chunk) == "function", "SNOWY: failed to compile " .. moduleName)
    local runOk, result = pcall(chunk)
    assert(runOk, "SNOWY: failed to load " .. moduleName .. ": " .. tostring(result))
    return result
end

local Settings = loadRemoteModule("Settings")
local Theme = loadRemoteModule("Theme")
local GameAdapter = loadRemoteModule("GameAdapter")
local UI = loadRemoteModule("UI")({
    Theme = Theme, UIS = UIS, TweenService = TweenService, LocalPlayer = LocalPlayer,
})
local gui = UI.gui
local uiTrack = UI.track
local uiConnections = UI.connections or {}
local connections = {}
local function track(conn)
    table.insert(connections, conn)
    return uiTrack(conn)
end
local corner, stroke, gradient = UI.corner, UI.stroke, UI.gradient
local addPress, softGradient = UI.addPress, UI.softGradient
local label, clampPos, makeDraggable = UI.label, UI.clampPos, UI.makeDraggable
local notify = loadRemoteModule("Notifications")({
    Settings = Settings, Theme = Theme, TweenService = TweenService, gui = gui,
    corner = corner, stroke = stroke, label = label,
})


---------------------------------------------------------------- Main window
local W, H = Settings.Width, Settings.Height
do
    local vp = gui.AbsoluteSize
    if vp.X > 0 then W = math.min(W, vp.X - 20) end
    if vp.Y > 0 then H = math.min(H, vp.Y - 20) end
end

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, W, 0, H)
main.BackgroundColor3 = Theme.Background
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.Parent = gui
corner(main, 16)
local mainGrad = gradient(stroke(main, Color3.new(1, 1, 1), 2), 45)
local mainScale = Instance.new("UIScale")
mainScale.Parent = main

local function centerPos()
    local vp = gui.AbsoluteSize
    return clampPos((vp.X - W) / 2, (vp.Y - H) / 2, Vector2.new(W, H))
end
main.Position = centerPos()

-- Header
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, Settings.HeaderHeight)
header.BackgroundColor3 = Theme.Panel
header.BorderSizePixel = 0
header.Parent = main

local titleLbl = label(header, {
    Text = "❄️ SNOWY", Font = Enum.Font.GothamBold, Size = 22,
    Position = UDim2.new(0, 16, 0, 0), SizeUDim = UDim2.new(0.5, 0, 1, 0),
})
gradient(titleLbl)

label(header, {
    Text = "v" .. Settings.Version, Size = 12, Color = Theme.SubText,
    Position = UDim2.new(0, 112, 0, 4), SizeUDim = UDim2.new(0, 50, 1, 0),
})

local function headerButton(text, xOffset, color)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 38, 0, 34)
    b.Position = UDim2.new(1, xOffset, 0.5, -17)
    b.BackgroundColor3 = color or Theme.Item
    b.Text = text
    b.TextColor3 = Theme.Text
    b.Font = Enum.Font.GothamBold
    b.TextSize = 16
    b.AutoButtonColor = true
    b.Parent = header
    corner(b, 9)
    addPress(b)
    return b
end

local collapseBtn = headerButton("—", -92)
local closeBtn = headerButton("✕", -50, Theme.Danger)

-- Divider line
local divider = Instance.new("Frame")
divider.Size = UDim2.new(1, 0, 0, 2)
divider.Position = UDim2.new(0, 0, 0, Settings.HeaderHeight)
divider.BorderSizePixel = 0
divider.BackgroundColor3 = Color3.new(1, 1, 1)
divider.Parent = main
gradient(divider)

-- Pages
local pages = Instance.new("Frame")
pages.BackgroundTransparency = 1
pages.Position = UDim2.new(0, 0, 0, Settings.HeaderHeight + 6)
pages.Size = UDim2.new(1, 0, 1, -(Settings.HeaderHeight + 6 + Settings.TabBarHeight))
pages.Parent = main

-- Tab bar
local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, 0, 0, Settings.TabBarHeight)
tabBar.Position = UDim2.new(0, 0, 1, -Settings.TabBarHeight)
tabBar.BackgroundColor3 = Theme.Panel
tabBar.BorderSizePixel = 0
tabBar.Parent = main

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
tabLayout.Padding = UDim.new(0, 4)
tabLayout.Parent = tabBar

local pageList, tabList = {}, {}

local function selectTab(name)
    for n, page in pairs(pageList) do
        if n == name then
            if not page.Visible then
                page.Position = UDim2.new(0, 10, 0, 16)
                page.Visible = true
                TweenService:Create(page, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                    Position = UDim2.new(0, 10, 0, 0),
                }):Play()
            end
        else
            page.Visible = false
        end
    end
    for n, t in pairs(tabList) do
        local active = (n == name)
        TweenService:Create(t.btn, TweenInfo.new(0.15), {
            BackgroundTransparency = active and 0 or 1,
        }):Play()
        t.label.TextColor3 = active and Theme.Text or Theme.SubText
    end
end

local function newPage(name, icon, titleText, descText)
    local page = Instance.new("ScrollingFrame")
    page.Name = name
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.Size = UDim2.new(1, -20, 1, 0)
    page.Position = UDim2.new(0, 10, 0, 0)
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = Theme.Purple
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.CanvasSize = UDim2.new()
    page.Visible = false
    page.Parent = pages

    local l = Instance.new("UIListLayout")
    l.Padding = UDim.new(0, 8)
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Parent = page

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 4)
    pad.PaddingBottom = UDim.new(0, 10)
    pad.Parent = page

    -- عنوان الصفحة
    local head = Instance.new("Frame")
    head.Size = UDim2.new(1, 0, 0, 46)
    head.BackgroundTransparency = 1
    head.LayoutOrder = -1
    head.Parent = page
    label(head, {
        Text = titleText, Font = Enum.Font.GothamBold, Size = 18,
        SizeUDim = UDim2.new(1, 0, 0, 26),
    })
    label(head, {
        Text = descText, Size = 12, Color = Theme.SubText,
        Position = UDim2.new(0, 0, 0, 26), SizeUDim = UDim2.new(1, 0, 0, 18),
    })

    pageList[name] = page

    -- زر التبويب
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 60, 0, 54)
    btn.BackgroundColor3 = Theme.Purple
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.Parent = tabBar
    corner(btn, 12)
    gradient(btn, 90)
    addPress(btn)

    label(btn, {
        Text = icon, Size = 22, Align = Enum.TextXAlignment.Center,
        SizeUDim = UDim2.new(1, 0, 0, 32), Position = UDim2.new(0, 0, 0, 4),
    })
    local nameLbl = label(btn, {
        Text = name, Size = 11, Font = Enum.Font.GothamBold, Color = Theme.SubText,
        Align = Enum.TextXAlignment.Center,
        SizeUDim = UDim2.new(1, 0, 0, 16), Position = UDim2.new(0, 0, 0, 34),
    })

    btn.MouseButton1Click:Connect(function() selectTab(name) end)
    tabList[name] = { btn = btn, label = nameLbl }
    return page
end

local function sectionLabel(page, text, order)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 0, 22)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextColor3 = Theme.Blue
    l.Font = Enum.Font.GothamBold
    l.TextSize = 13
    l.LayoutOrder = order or 0
    l.Parent = page
    return l
end

local function infoRow(page, labelText, value)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 46)
    row.BackgroundColor3 = Color3.new(1, 1, 1)
    row.Parent = page
    corner(row, 12)
    softGradient(row)

    label(row, {
        Text = labelText, Color = Theme.SubText,
        Position = UDim2.new(0, 14, 0, 0), SizeUDim = UDim2.new(0.4, 0, 1, 0),
    })
    local v = label(row, {
        Text = tostring(value), Align = Enum.TextXAlignment.Right,
        Position = UDim2.new(0.4, 0, 0, 0), SizeUDim = UDim2.new(0.6, -14, 1, 0),
    })
    return v
end

-- Toggle
-- Toggle helper for real settings only.
local ToggleStates = {}
local function newToggle(page, key, labelText, subText, opts)
    opts = opts or {}
    ToggleStates[key] = opts.default or false

    local row = Instance.new("TextButton")
    row.Size = UDim2.new(1, 0, 0, 62)
    row.BackgroundColor3 = Color3.new(1, 1, 1)
    row.Text = ""
    row.AutoButtonColor = false
    row.Parent = page
    corner(row, 12)
    softGradient(row)
    addPress(row)
    local rowStroke = stroke(row, Theme.Purple, 1, 1)

    label(row, {
        Text = labelText, Font = Enum.Font.GothamBold, Size = 15,
        Position = UDim2.new(0, 14, 0, 10), SizeUDim = UDim2.new(1, -90, 0, 22),
    })
    label(row, {
        Text = subText or "", Size = 11, Color = Theme.SubText,
        Position = UDim2.new(0, 14, 0, 32), SizeUDim = UDim2.new(1, -90, 0, 18),
    })

    local pill = Instance.new("Frame")
    pill.Size = UDim2.new(0, 52, 0, 28)
    pill.Position = UDim2.new(1, -66, 0.5, -14)
    pill.Parent = row
    corner(pill, 14)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 22, 0, 22)
    knob.BackgroundColor3 = Theme.Text
    knob.Parent = pill
    corner(knob, 11)

    local function paint(on, animate)
        local info = TweenInfo.new(animate and 0.25 or 0, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        TweenService:Create(pill, info, { BackgroundColor3 = on and Theme.Purple or Theme.Off }):Play()
        TweenService:Create(knob, info, {
            Position = on and UDim2.new(1, -25, 0.5, -11) or UDim2.new(0, 3, 0.5, -11),
        }):Play()
        TweenService:Create(rowStroke, info, { Transparency = on and 0.3 or 1 }):Play()
    end
    paint(ToggleStates[key], false)

    row.MouseButton1Click:Connect(function()
        ToggleStates[key] = not ToggleStates[key]
        local on = ToggleStates[key]
        paint(on, true)
        if opts.onChange then opts.onChange(on) end
        if opts.uiOnly then
            notify(labelText .. (on and " ON" or " OFF") .. " — واجهة فقط، لا توجد وظيفة مرتبطة")
        end
    end)
    return row
end

local function newButton(page, text, callback, color)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 52)
    b.BackgroundColor3 = color or Color3.new(1, 1, 1)
    b.Text = text
    b.TextColor3 = Theme.Text
    b.Font = Enum.Font.GothamBold
    b.TextSize = 15
    b.Parent = page
    corner(b, 12)
    addPress(b)
    if not color then gradient(b) end
    b.MouseButton1Click:Connect(function() callback(b) end)
    return b
end

---------------------------------------------------------------- Pages
local pServer = newPage("Server", "🌐", "Server", "معلومات السيرفر الحالي وأدواته")
local pCarry = newPage("Carry", "📦", "Auto Carry", "حالة التوافق")
local pExit = newPage("Exit", "✅", "Auto Exit", "أدوات مغادرة السيرفر")
local pEsp = newPage("ESP", "👁", "Player ESP", "حالة التوافق")
local pSettings = newPage("Settings", "⚙️", "Settings", "إعدادات SNOWY")

-- Helpers for real, local utility actions (no game exploits / no fake toggles)
local function copyToClipboard(value)
    local clipboard = setclipboard or toclipboard
    if type(clipboard) ~= "function" then
        notify("الحافظة غير مدعومة في بيئة التشغيل", true)
        return false
    end
    local ok = pcall(clipboard, tostring(value))
    if ok then
        notify("تم النسخ إلى الحافظة")
        return true
    end
    notify("تعذر النسخ إلى الحافظة", true)
    return false
end

local function infoNote(page, message, order)
    local box = Instance.new("Frame")
    box.Size = UDim2.new(1, 0, 0, 66)
    box.BackgroundColor3 = Theme.Item
    box.BorderSizePixel = 0
    box.LayoutOrder = order or 0
    box.Parent = page
    corner(box, 12)
    stroke(box, Theme.Blue, 1, 0.55)
    local txt = label(box, {
        Text = message, Size = 12, Color = Theme.SubText,
        Position = UDim2.new(0, 12, 0, 6),
        SizeUDim = UDim2.new(1, -24, 1, -12),
    })
    txt.TextWrapped = true
    txt.TextYAlignment = Enum.TextYAlignment.Center
    return box
end

-- Server: real information about the current session only
sectionLabel(pServer, "CURRENT SERVER", 1)
local playersRow = infoRow(pServer, "Players", #Players:GetPlayers() .. " / " .. Players.MaxPlayers)
playersRow.Parent.LayoutOrder = 2
local placeRow = infoRow(pServer, "Place ID", game.PlaceId)
placeRow.Parent.LayoutOrder = 3
local jobRow = infoRow(pServer, "Job ID", game.JobId ~= "" and game.JobId or "N/A")
jobRow.Parent.LayoutOrder = 4
local serverAgeRow = infoRow(pServer, "Local session", "--")
serverAgeRow.Parent.LayoutOrder = 5

local function refreshServerInfo()
    playersRow.Text = #Players:GetPlayers() .. " / " .. Players.MaxPlayers
    placeRow.Text = tostring(game.PlaceId)
    jobRow.Text = game.JobId ~= "" and game.JobId or "N/A"
    local seconds = math.max(0, math.floor(workspace.DistributedGameTime))
    local minutes = math.floor(seconds / 60)
    serverAgeRow.Text = string.format("%02d:%02d", math.floor(minutes / 60), minutes % 60)
end

local function serverSummary()
    return table.concat({
        "SNOWY Server Info",
        "Place ID: " .. tostring(game.PlaceId),
        "Job ID: " .. (game.JobId ~= "" and game.JobId or "N/A"),
        "Players: " .. #Players:GetPlayers() .. " / " .. Players.MaxPlayers,
        "Local session: " .. serverAgeRow.Text,
    }, "\n")
end

sectionLabel(pServer, "SERVER TOOLS", 6)
newButton(pServer, "Refresh Server Info", function()
    refreshServerInfo()
    notify("تم تحديث معلومات السيرفر")
end).LayoutOrder = 7
newButton(pServer, "Copy Server Info", function()
    refreshServerInfo()
    copyToClipboard(serverSummary())
end).LayoutOrder = 8
newButton(pServer, "Copy Job ID", function()
    if game.JobId == "" then
        notify("Job ID غير متاح في هذا المكان", true)
    else
        copyToClipboard(game.JobId)
    end
end).LayoutOrder = 9
newButton(pServer, "Copy Place ID", function()
    copyToClipboard(game.PlaceId)
end).LayoutOrder = 10

sectionLabel(pServer, "GAME DATA", 11)
infoNote(pServer,
    "Server Value Finder يحتاج بيانات يوفّرها مطوّر اللعبة بشكل مصرح. لا يمكن استنتاج قيم Brainrots الخاصة باللعبة من واجهة العميل وحدها.",
    12)

local function refreshPlayers()
    playersRow.Text = #Players:GetPlayers() .. " / " .. Players.MaxPlayers
end
track(Players.PlayerAdded:Connect(refreshPlayers))
track(Players.PlayerRemoving:Connect(function() task.defer(refreshPlayers) end))

-- Steal a Brainrot adapter: recognize the entire experience by UniverseId,
-- including its sub-places. Recognition is not a claim that every game feature is implemented.
local adapterStatus = GameAdapter.getStatus(game.PlaceId, game.GameId)
local gameDetected = adapterStatus.supported == true

infoNote(pCarry,
    gameDetected
        and "تم التعرف على Steal a Brainrot. نظام الالتقاط التلقائي لم يُفعّل بعد؛ هذه الحالة تؤكد توافق اللعبة فقط."
        or adapterStatus.message,
    1)
infoNote(pExit,
    gameDetected
        and "تم التعرف على Steal a Brainrot. المغادرة التلقائية ستحتاج تأكيداً موثوقاً لنجاح إيداع Brainrot أولاً."
        or adapterStatus.message,
    1)
infoNote(pEsp,
    gameDetected
        and "تم التعرف على Steal a Brainrot. عرض مؤشرات اللاعبين غير مفعّل في هذه النسخة بعد."
        or adapterStatus.message,
    1)

-- Compatibility buttons report recognition of the target experience, not feature completion.
newButton(pCarry, "Check Game Compatibility", function()
    local status = GameAdapter.getStatus(game.PlaceId, game.GameId)
    notify(status.supported and status.message or status.message, not status.supported)
end, Theme.Purple).LayoutOrder = 2

newButton(pCarry, "Copy Game IDs", function()
    copyToClipboard("Universe ID: " .. tostring(game.GameId) .. "\nPlace ID: " .. tostring(game.PlaceId))
end).LayoutOrder = 3

newButton(pExit, "Check Game Compatibility", function()
    local status = GameAdapter.getStatus(game.PlaceId, game.GameId)
    notify(status.supported and "اللعبة معروفة: Steal a Brainrot. تأكيد الإيداع التلقائي غير متاح بعد." or status.message, not status.supported)
end, Theme.Purple).LayoutOrder = 2

newButton(pExit, "Copy Current Job ID", function()
    if game.JobId == "" then
        notify("Job ID غير متاح في هذه الجلسة", true)
    else
        copyToClipboard(game.JobId)
    end
end, Theme.Danger).LayoutOrder = 3

newButton(pEsp, "Check Game Compatibility", function()
    local status = GameAdapter.getStatus(game.PlaceId, game.GameId)
    notify(status.supported and "اللعبة معروفة: Steal a Brainrot. وظيفة ESP لم تُنفّذ بعد." or status.message, not status.supported)
end, Theme.Purple).LayoutOrder = 2

-- Settings (وظائف حقيقية)
sectionLabel(pSettings, "GENERAL", 1)
newToggle(pSettings, "Notifications", "Notifications", "تشغيل / إيقاف الإشعارات", {
    default = true,
    onChange = function(on)
        Settings.NotificationsEnabled = on
        notify("Notifications " .. (on and "ON" or "OFF"), true)
    end,
}).LayoutOrder = 2

sectionLabel(pSettings, "WINDOW", 3)
newButton(pSettings, "Reset Position", function()
    main.Position = centerPos()
    notify("تمت إعادة الموضع")
end).LayoutOrder = 4

sectionLabel(pSettings, "DANGER", 5)
local unloadArmed = false
newButton(pSettings, "Unload SNOWY (يحذف الواجهة)", function(btn)
    if not unloadArmed then
        unloadArmed = true
        btn.Text = "اضغط مرة ثانية للتأكيد"
        task.delay(3, function()
            unloadArmed = false
            if btn.Parent then btn.Text = "Unload SNOWY (يحذف الواجهة)" end
        end)
        return
    end
    for _, c in ipairs(connections) do pcall(function() c:Disconnect() end) end
    for _, c in ipairs(uiConnections) do pcall(function() c:Disconnect() end) end
    gui:Destroy()
end, Theme.Danger).LayoutOrder = 6

---------------------------------------------------------------- Bubble (زر الفتح الدائم)
local bubble = Instance.new("Frame")
bubble.Name = "SnowBubble"
bubble.Size = UDim2.new(0, 58, 0, 58)
bubble.BackgroundColor3 = Theme.Panel
bubble.Visible = false
bubble.Parent = gui
corner(bubble, 29)
local bubbleGrad = gradient(stroke(bubble, Color3.new(1, 1, 1), 2.5), 45)
local bubbleScale = Instance.new("UIScale")
bubbleScale.Parent = bubble
label(bubble, {
    Text = "❄️", Size = 28, Align = Enum.TextXAlignment.Center,
})

local function showMain()
    local p = bubble.AbsolutePosition
    main.Position = clampPos(p.X, p.Y, main.AbsoluteSize)
    bubble.Visible = false
    mainScale.Scale = 0.8
    main.Visible = true
    TweenService:Create(mainScale, TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Scale = 1,
    }):Play()
end

local hiding = false
local function hideMain()
    if hiding then return end
    hiding = true
    local p = main.AbsolutePosition
    local t = TweenService:Create(mainScale, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Scale = 0.8,
    })
    t:Play()
    t.Completed:Wait()
    main.Visible = false
    mainScale.Scale = 1
    bubble.Position = clampPos(p.X, p.Y, bubble.AbsoluteSize)
    bubbleScale.Scale = 0.5
    bubble.Visible = true
    TweenService:Create(bubbleScale, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Scale = 1,
    }):Play()
    hiding = false
end

-- Collapse (تصغير النافذة إلى الشريط العلوي فقط)
local collapsed = false
collapseBtn.MouseButton1Click:Connect(function()
    collapsed = not collapsed
    pages.Visible = not collapsed
    tabBar.Visible = not collapsed
    divider.Visible = not collapsed
    collapseBtn.Text = collapsed and "▢" or "—"
    TweenService:Create(main, TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, W, 0, collapsed and Settings.HeaderHeight or H),
    }):Play()
end)

closeBtn.MouseButton1Click:Connect(hideMain)

makeDraggable(header, main)
makeDraggable(bubble, bubble, showMain)

-- حدود متحركة (دوران الألوان)
track(RunService.Heartbeat:Connect(function(dt)
    if main.Visible then mainGrad.Rotation = (mainGrad.Rotation + dt * 35) % 360 end
    if bubble.Visible then bubbleGrad.Rotation = (bubbleGrad.Rotation + dt * 90) % 360 end
end))

---------------------------------------------------------------- Main (src/Main.lua)
selectTab("Server")
refreshServerInfo()
notify("SNOWY جاهز — أدوات السيرفر المحلية متاحة", true)
