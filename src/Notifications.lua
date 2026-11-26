-- SNOWY Notifications module
return function(deps)
    local Settings = deps.Settings
    local Theme = deps.Theme
    local TweenService = deps.TweenService
    local gui = deps.gui
    local corner = deps.corner
    local stroke = deps.stroke
    local label = deps.label
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
    return notify
end
