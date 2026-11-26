--[[
    SNOWY ❄️  —  UI Shell v2.1 (ملف واحد لـ Delta)
    الحالة: لم يتم اختبار هذا الكود.
    خيارات Server Finder / Value Finder / Auto Carry / Auto Exit / Player ESP هي واجهة فقط
    ولا تنفّذ أي وظيفة داخل اللعبة.
    يعمل فعلاً: السحب، التصغير، الإخفاء مع زر فتح دائم ❄️، التبويبات، الإشعارات،
    معلومات السيرفر الحالي، وصفحة Settings.
    الأقسام: Settings / UI / Main (مطابقة لهيكل المستودع)
]]

---------------------------------------------------------------- Services
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

---------------------------------------------------------------- Settings (src/Settings.lua)
local Settings = {
    Version = "2.1",
    NotificationsEnabled = true,
    Width = 340,
    Height = 450,
    HeaderHeight = 52,
    TabBarHeight = 66,
}

local Theme = {
    Background = Color3.fromRGB(9, 9, 15),
    Panel = Color3.fromRGB(18, 16, 30),
    Item = Color3.fromRGB(26, 23, 44),
    Purple = Color3.fromRGB(139, 92, 246),
    Blue = Color3.fromRGB(59, 130, 246),
    Text = Color3.fromRGB(238, 238, 252),
    SubText = Color3.fromRGB(140, 138, 175),
    Off = Color3.fromRGB(52, 49, 76),
    Danger = Color3.fromRGB(220, 70, 110),
}

---------------------------------------------------------------- UI helpers (src/UI.lua)
local connections = {}
local function track(conn)
    table.insert(connections, conn)
    return conn
end

local function makeGui()
    local g = Instance.new("ScreenGui")
    g.Name = "SNOWY_UI"
    g.ResetOnSpawn = false
    g.IgnoreGuiInset = true
    g.DisplayOrder = 999

    local parent
    pcall(function()
        if gethui then parent = gethui() end
    end)
    if not parent then
        pcall(function()
            local cg = game:GetService("CoreGui")
            local test = Instance.new("Folder")
            test.Parent = cg
            test:Destroy()
            parent = cg
        end)
    end
    parent = parent or LocalPlayer:WaitForChild("PlayerGui")

    local old = parent:FindFirstChild("SNOWY_UI")
    if old then old:Destroy() end

    g.Parent = parent
    return g
end

local function corner(obj, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 10)
    c.Parent = obj
    return c
end

local function stroke(obj, color, t, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color
    s.Thickness = t or 1.5
    s.Transparency = transparency or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = obj
    return s
end

local function gradient(obj, rotation)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new(Theme.Purple, Theme.Blue)
    g.Rotation = rotation or 0
    g.Parent = obj
    return g
end

-- ضغطة ناعمة: يصغر العنصر قليلاً عند اللمس ويرجع
local function addPress(obj)
    local sc = obj:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
    sc.Parent = obj
    local info = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    obj.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then
            TweenService:Create(sc, info, { Scale = 0.96 }):Play()
        end
    end)
    obj.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then
            TweenService:Create(sc, info, { Scale = 1 }):Play()
        end
    end)
end

local function softGradient(obj)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new(Color3.fromRGB(36, 32, 62), Theme.Item)
    g.Rotation = 90
    g.Parent = obj
    return g
end

local function label(parent, props)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Font = props.Font or Enum.Font.GothamMedium
    l.TextSize = props.Size or 14
    l.TextColor3 = props.Color or Theme.Text
    l.Text = props.Text or ""
    l.TextXAlignment = props.Align or Enum.TextXAlignment.Left
    l.TextYAlignment = props.AlignY or Enum.TextYAlignment.Center
    l.Position = props.Position or UDim2.new()
    l.Size = props.SizeUDim or UDim2.new(1, 0, 1, 0)
    l.TextTruncate = Enum.TextTruncate.AtEnd
    l.Parent = parent
    return l
end

local gui = makeGui()

local function clampPos(x, y, size)
    local vp = gui.AbsoluteSize
    return UDim2.fromOffset(
        math.clamp(x, 0, math.max(0, vp.X - size.X)),
        math.clamp(y, 0, math.max(0, vp.Y - size.Y))
    )
end

-- سحب مع إبقاء العنصر داخل الشاشة، و onTap للنقرة بدون سحب
local function makeDraggable(handle, target, onTap)
    local dragging, startInput, dragStart, startPos, moved = false, nil, nil, nil, 0

    track(handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            startInput = input
            dragStart = input.Position
            startPos = target.AbsolutePosition
            moved = 0
            local ended
            ended = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    ended:Disconnect()
                    if onTap and moved < 8 then onTap() end
                end
            end)
        end
    end))

    track(UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            moved = math.max(moved, d.Magnitude)
            target.Position = clampPos(startPos.X + d.X, startPos.Y + d.Y, target.AbsoluteSize)
        end
    end))
end

---------------------------------------------------------------- Notifications
local toastHolder = Instance.new("Frame")
toastHolder.Name = "Toasts"
toastHolder.BackgroundTransparency = 1
toastHolder.AnchorPoint = Vector2.new(0.5, 0)
toastHolder.Size = UDim2.new(0, 300, 0, 200)
toastHolder.Position = UDim2.new(0.5, 0, 0, 44)
toastHolder.ZIndex = 50
toastHolder.Parent = gui

local toastLayout = Instance.new("UIListLayout")
toastLayout.Padding = UDim.new(0, 6)
toastLayout.SortOrder = Enum.SortOrder.LayoutOrder
toastLayout.Parent = toastHolder

local function notify(text, force)
    if not Settings.NotificationsEnabled and not force then return end
    local t = Instance.new("Frame")
    t.Size = UDim2.new(1, 0, 0, 42)
    t.BackgroundColor3 = Theme.Panel
    t.BackgroundTransparency = 0.05
    t.ZIndex = 51
    t.Parent = toastHolder
    corner(t, 10)
    local s = stroke(t, Theme.Purple, 1.5)

    local txt = label(t, {
        Text = "❄️  " .. text, Size = 13,
        Position = UDim2.new(0, 12, 0, 0), SizeUDim = UDim2.new(1, -24, 1, 0),
    })
    txt.ZIndex = 52
    txt.TextWrapped = true
    txt.TextTruncate = Enum.TextTruncate.None

    -- ظهور ناعم
    t.BackgroundTransparency = 1
    s.Transparency = 1
    txt.TextTransparency = 1
    local inInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(t, inInfo, { BackgroundTransparency = 0.05 }):Play()
    TweenService:Create(s, inInfo, { Transparency = 0 }):Play()
    TweenService:Create(txt, inInfo, { TextTransparency = 0 }):Play()

    task.delay(2.6, function()
        if not t.Parent then return end
        local info = TweenInfo.new(0.3)
        TweenService:Create(t, info, { BackgroundTransparency = 1 }):Play()
        TweenService:Create(txt, info, { TextTransparency = 1 }):Play()
        TweenService:Create(s, info, { Transparency = 1 }):Play()
        task.wait(0.35)
        t:Destroy()
    end)
end

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
-- opts.uiOnly = true → واجهة فقط. opts.default / opts.onChange للخيارات الحقيقية.
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
local pCarry = newPage("Carry", "📦", "Auto Carry", "واجهة فقط — لا وظيفة مرتبطة")
local pExit = newPage("Exit", "✅", "Auto Exit", "واجهة فقط — لا وظيفة مرتبطة")
local pEsp = newPage("ESP", "👁", "Player ESP", "واجهة فقط — لا وظيفة مرتبطة")
local pSettings = newPage("Settings", "⚙️", "Settings", "إعدادات SNOWY")

-- Server
sectionLabel(pServer, "CURRENT SERVER", 1)
local playersRow = infoRow(pServer, "Players", #Players:GetPlayers() .. " / " .. Players.MaxPlayers)
playersRow.Parent.LayoutOrder = 2
local placeRow = infoRow(pServer, "Place ID", game.PlaceId)
placeRow.Parent.LayoutOrder = 3
local jobRow = infoRow(pServer, "Job ID", game.JobId ~= "" and game.JobId or "N/A")
jobRow.Parent.LayoutOrder = 4
sectionLabel(pServer, "TOOLS (UI ONLY)", 5)
newToggle(pServer, "ServerFinder", "Server Finder", "UI only", { uiOnly = true }).LayoutOrder = 6
newToggle(pServer, "ValueFinder", "Server Value Finder", "UI only", { uiOnly = true }).LayoutOrder = 7

local function refreshPlayers()
    playersRow.Text = #Players:GetPlayers() .. " / " .. Players.MaxPlayers
end
track(Players.PlayerAdded:Connect(refreshPlayers))
track(Players.PlayerRemoving:Connect(function() task.defer(refreshPlayers) end))

-- Carry / Exit / ESP
newToggle(pCarry, "AutoCarry", "Auto Carry", "UI only", { uiOnly = true })
newToggle(pExit, "AutoExit", "Auto Exit — DONE", "UI only", { uiOnly = true })
newToggle(pEsp, "PlayerESP", "Player ESP", "UI only", { uiOnly = true })

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
notify("SNOWY جاهز — الخيارات واجهة فقط", true)
