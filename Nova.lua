local Nova = {}
Nova.__index = Nova

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

Nova.Theme = {
    Bg = Color3.fromRGB(13,13,15),
    Panel = Color3.fromRGB(20,20,24),
    Element = Color3.fromRGB(30,30,35),
    Accent = Color3.fromRGB(0,170,120),
    Text = Color3.fromRGB(240,240,240),
    Muted = Color3.fromRGB(160,160,160)
}

local function create(class, props)
    local obj = Instance.new(class)
    for i,v in pairs(props or {}) do obj[i]=v end
    return obj
end

local function corner(obj, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 10)
    c.Parent = obj
end

local function stroke(obj)
    local s = Instance.new("UIStroke")
    s.Color = Color3.fromRGB(70,70,75)
    s.Transparency = 0.4
    s.Thickness = 1
    s.Parent = obj
end

local function tween(obj, props, t)
    TweenService:Create(obj, TweenInfo.new(t or 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

local function drag(frame, handle)
    local dragging, startPos, startInput

    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            startInput = i.Position
            startPos = frame.Position
        end
    end)

    UIS.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = i.Position - startInput
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-------------------------------------------------
-- ELEMENT SYSTEM
-------------------------------------------------

local Tab = {}
Tab.__index = Tab

function Tab:NewButton(text, cb)
    local b = create("TextButton", {
        Size = UDim2.new(1, -10, 0, 36),
        BackgroundColor3 = Nova.Theme.Element,
        Text = text,
        TextColor3 = Nova.Theme.Text,
        Font = Enum.Font.Gotham,
        BorderSizePixel = 0,
        Parent = self.Page
    })

    corner(b, 10)
    stroke(b)

    b.MouseEnter:Connect(function()
        tween(b, {BackgroundColor3 = Color3.fromRGB(40,40,45)}, 0.15)
    end)

    b.MouseLeave:Connect(function()
        tween(b, {BackgroundColor3 = Nova.Theme.Element}, 0.15)
    end)

    b.MouseButton1Click:Connect(function()
        if cb then cb() end
    end)

    return b
end

function Tab:NewSlider(text, min, max, default, cb)
    local value = default or min

    local f = create("Frame", {
        Size = UDim2.new(1, -10, 0, 55),
        BackgroundColor3 = Nova.Theme.Element,
        BackgroundTransparency = 0.1,
        Parent = self.Page
    })

    corner(f, 10)
    stroke(f)

    local l = create("TextLabel", {
        Size = UDim2.new(1, -10, 0, 20),
        Position = UDim2.new(0, 10, 0, 5),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Nova.Theme.Text,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = f
    })

    local bar = create("Frame", {
        Size = UDim2.new(1, -20, 0, 7),
        Position = UDim2.new(0, 10, 0, 35),
        BackgroundColor3 = Color3.fromRGB(55,55,60),
        Parent = f
    })

    corner(bar, 10)

    local fill = create("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Nova.Theme.Accent,
        Parent = bar
    })

    corner(fill, 10)

    local function set(v)
        value = math.clamp(v, min, max)
        fill.Size = UDim2.new((value-min)/(max-min), 0, 1, 0)
        l.Text = text .. " ["..min.." - "..max.."] : " .. math.floor(value)
        if cb then cb(value) end
    end

    bar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            local move
            move = UIS.InputChanged:Connect(function(i2)
                if i2.UserInputType == Enum.UserInputType.MouseMovement then
                    local p = math.clamp((i2.Position.X - bar.AbsolutePosition.X)/bar.AbsoluteSize.X, 0, 1)
                    set(min + (max-min)*p)
                end
            end)

            UIS.InputEnded:Connect(function(i2)
                if i2.UserInputType == Enum.UserInputType.MouseButton1 then
                    if move then move:Disconnect() end
                end
            end)
        end
    end)

    set(value)
    return f
end

-------------------------------------------------
-- WINDOW SYSTEM
-------------------------------------------------

function Nova:CreateWindow(cfg)
    local gui = create("ScreenGui", {
        Name = "Nova",
        Parent = Players.LocalPlayer:WaitForChild("PlayerGui"),
        ResetOnSpawn = false
    })

    local main = create("Frame", {
        Size = UDim2.new(0, 620, 0, 400),
        Position = UDim2.new(0.5, -310, 0.5, -200),
        BackgroundColor3 = Nova.Theme.Bg,
        BackgroundTransparency = 0.05,
        Parent = gui
    })

    corner(main, 12)
    stroke(main)

    local top = create("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Nova.Theme.Panel,
        BackgroundTransparency = 0.1,
        Parent = main
    })

    corner(top, 12)

    create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = cfg and cfg.Name or "Nova UI",
        TextColor3 = Nova.Theme.Text,
        Font = Enum.Font.GothamBold,
        Parent = top
    })

    local sidebar = create("Frame", {
        Size = UDim2.new(0, 160, 1, -40),
        Position = UDim2.new(0, 0, 0, 40),
        BackgroundColor3 = Nova.Theme.Panel,
        BackgroundTransparency = 0.2,
        Parent = main
    })

    local pages = create("Frame", {
        Size = UDim2.new(1, -160, 1, -40),
        Position = UDim2.new(0, 160, 0, 40),
        BackgroundTransparency = 1,
        Parent = main
    })

    drag(main, top)

    -------------------------------------------------
-- WINDOW CONTROLS
-------------------------------------------------
-------------------------------------------------
-- WINDOW CONTROLS (FIXED)
-------------------------------------------------

local TweenService = game:GetService("TweenService")

local isFullscreen = false
local isMinimized = false

local normalSize = main.Size
local normalPos = main.Position

-- SHOW BUTTON (restores UI)
local showBtn = create("TextButton", {
    Size = UDim2.new(0, 120, 0, 40),
    Position = UDim2.new(0.5, -60, 0.5, -20),
    BackgroundColor3 = Color3.fromRGB(15,15,15),
    Text = "Show",
    TextColor3 = Color3.fromRGB(255,255,255),
    Font = Enum.Font.GothamBold,
    Visible = false,
    Parent = gui,
    BorderSizePixel = 0,
    ZIndex = 10
})

corner(showBtn, 10)
stroke(showBtn)

-- FULLSCREEN BUTTON
local fsBtn = create("TextButton", {
    Size = UDim2.new(0, 26, 0, 26),
    Position = UDim2.new(1, -70, 0.5, -13),
    BackgroundColor3 = Color3.fromRGB(60,120,255),
    Text = "",
    Parent = top,
    BorderSizePixel = 0
})
corner(fsBtn, 100)

-- MINIMIZE BUTTON
local minBtn = create("TextButton", {
    Size = UDim2.new(0, 26, 0, 26),
    Position = UDim2.new(1, -35, 0.5, -13),
    BackgroundColor3 = Color3.fromRGB(35,35,35),
    Text = "",
    Parent = top,
    BorderSizePixel = 0
})
corner(minBtn, 100)

-------------------------------------------------
-- FULLSCREEN TOGGLE
-------------------------------------------------

fsBtn.MouseButton1Click:Connect(function()
    isFullscreen = not isFullscreen

    if isFullscreen then
        TweenService:Create(main, TweenInfo.new(0.3), {
            Size = UDim2.new(1,0,1,0),
            Position = UDim2.new(0,0,0,0)
        }):Play()
    else
        TweenService:Create(main, TweenInfo.new(0.3), {
            Size = normalSize,
            Position = normalPos
        }):Play()
    end
end)

-------------------------------------------------
-- MINIMIZE
-------------------------------------------------

minBtn.MouseButton1Click:Connect(function()
    if isMinimized then return end
    isMinimized = true

    TweenService:Create(main, TweenInfo.new(0.25), {
        Size = UDim2.new(0,0,0,0),
        BackgroundTransparency = 1
    }):Play()

    task.delay(0.25, function()
        main.Visible = false
        showBtn.Visible = true
        showBtn.Size = UDim2.new(0,0,0,40)

        TweenService:Create(showBtn, TweenInfo.new(0.2), {
            Size = UDim2.new(0,120,0,40)
        }):Play()
    end)
end)

-------------------------------------------------
-- RESTORE
-------------------------------------------------

showBtn.MouseButton1Click:Connect(function()
    if not isMinimized then return end
    isMinimized = false

    main.Visible = true
    showBtn.Visible = false

    main.Size = UDim2.new(0,0,0,0)
    main.BackgroundTransparency = 1

    TweenService:Create(main, TweenInfo.new(0.3), {
        Size = normalSize,
        Position = normalPos,
        BackgroundTransparency = 0.05
    }):Play()
end)

    return setmetatable({
        Gui = gui,
        Main = main,
        Sidebar = sidebar,
        Pages = pages,
        Tabs = {},
        ActiveTab = nil
    }, Nova)
end

-------------------------------------------------
-- PRO TAB SYSTEM (FIXED + ANIMATED INDICATOR)
-------------------------------------------------

function Nova:CreateTab(name)

    local btn = create("TextButton", {
        Size = UDim2.new(1, -10, 0, 38),
        BackgroundColor3 = Nova.Theme.Element,
        Text = name,
        TextColor3 = Nova.Theme.Text,
        Font = Enum.Font.Gotham,
        BorderSizePixel = 0,
        Parent = self.Sidebar
    })

    corner(btn, 10)

    local page = create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Visible = false,
        Parent = self.Pages
    })

    create("UIListLayout", {
        Padding = UDim.new(0, 8),
        Parent = page
    })

    local tab = setmetatable({Page = page, Library = self}, Tab)

    btn.MouseButton1Click:Connect(function()
        for _, t in pairs(self.Tabs) do
            t.Page.Visible = false
        end

        page.Visible = true
        self.ActiveTab = page

        tween(btn, {BackgroundColor3 = Color3.fromRGB(45,45,50)}, 0.2)
    end)

    table.insert(self.Tabs, tab)

    if #self.Tabs == 1 then
        page.Visible = true
        self.ActiveTab = page
    end

    return tab
end

return Nova
