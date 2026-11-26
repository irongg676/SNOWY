-- SNOWY UI module: shared interface primitives
return function(deps)
    local Theme = deps.Theme
    local UIS = deps.UIS
    local TweenService = deps.TweenService
    local LocalPlayer = deps.LocalPlayer
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

    return {
        gui = gui, connections = connections, track = track,
        corner = corner, stroke = stroke, gradient = gradient,
        addPress = addPress, softGradient = softGradient,
        label = label, clampPos = clampPos, makeDraggable = makeDraggable,
    }
end
