local Nova = {}
Nova.__index = Nova

Nova.State = {
    Toggles = {},
    Sliders = {}
}

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")

local function create(class, props)
    local obj = Instance.new(class)
    for i, v in pairs(props or {}) do
        obj[i] = v
    end
    return obj
end

local function corner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 6)
    c.Parent = p
end

local function stroke(p)
    local s = Instance.new("UIStroke")
    s.Color = Color3.fromRGB(60,60,60)
    s.Thickness = 1
    s.Parent = p
end

local function drag(frame, handle)
    local dragging, start, startPos

    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            start = i.Position
            startPos = frame.Position
        end
    end)

    UIS.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = i.Position - start
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

local Tab = {}
Tab.__index = Tab

function Tab:NewButton(text, callback)
    local b = create("TextButton", {
        Size = UDim2.new(1,-10,0,34),
        BackgroundColor3 = Color3.fromRGB(30,30,30),
        Text = text,
        TextColor3 = Color3.fromRGB(255,255,255),
        Font = Enum.Font.Gotham,
        TextSize = 14,
        BorderSizePixel = 0,
        Parent = self.Page
    })

    corner(b,6)
    stroke(b)

    b.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)

    return b
end

function Tab:NewToggle(text, default, callback)
    local state = default or false

    local f = create("Frame", {
        Size = UDim2.new(1,-10,0,34),
        BackgroundColor3 = Color3.fromRGB(30,30,30),
        Parent = self.Page
    })

    corner(f,6)
    stroke(f)

    local t = create("TextLabel", {
        Size = UDim2.new(0.7,0,1,0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Color3.fromRGB(255,255,255),
        Font = Enum.Font.Gotham,
        TextSize = 14,
        Parent = f
    })

    local box = create("Frame", {
        Size = UDim2.new(0,38,0,18),
        Position = UDim2.new(1,-45,0.5,-9),
        BackgroundColor3 = Color3.fromRGB(60,60,60),
        Parent = f
    })

    corner(box,10)

    local dot = create("Frame", {
        Size = UDim2.new(0,16,0,16),
        Position = UDim2.new(0,1,0.5,-8),
        BackgroundColor3 = Color3.fromRGB(255,255,255),
        Parent = box
    })

    corner(dot,10)

    local function update()
        if state then
            box.BackgroundColor3 = Color3.fromRGB(0,170,120)
            dot.Position = UDim2.new(1,-17,0.5,-8)
        else
            box.BackgroundColor3 = Color3.fromRGB(60,60,60)
            dot.Position = UDim2.new(0,1,0.5,-8)
        end

        if callback then callback(state) end
    end

    box.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            state = not state
            update()
        end
    end)

    update()
    return f
end

function Tab:NewSlider(text, min, max, default, callback)
    local val = default or min

    local f = create("Frame", {
        Size = UDim2.new(1,-10,0,50),
        BackgroundColor3 = Color3.fromRGB(30,30,30),
        Parent = self.Page
    })

    corner(f,6)
    stroke(f)

    local l = create("TextLabel", {
        Size = UDim2.new(1,-10,0,20),
        Position = UDim2.new(0,10,0,2),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Color3.fromRGB(255,255,255),
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = f
    })

    local bar = create("Frame", {
        Size = UDim2.new(1,-20,0,8),
        Position = UDim2.new(0,10,0,30),
        BackgroundColor3 = Color3.fromRGB(60,60,60),
        Parent = f
    })

    corner(bar,6)

    local fill = create("Frame", {
        Size = UDim2.new(0,0,1,0),
        BackgroundColor3 = Color3.fromRGB(0,170,120),
        Parent = bar
    })

    corner(fill,6)

    local function set(v)
        val = math.clamp(v,min,max)
        fill.Size = UDim2.new((val-min)/(max-min),0,1,0)
        l.Text = text.." : "..math.floor(val)
        if callback then callback(val) end
    end

    bar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            local m
            m = UIS.InputChanged:Connect(function(i2)
                if i2.UserInputType == Enum.UserInputType.MouseMovement then
                    local p = math.clamp((i2.Position.X - bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
                    set(min+(max-min)*p)
                end
            end)

            UIS.InputEnded:Connect(function(i2)
                if i2.UserInputType == Enum.UserInputType.MouseButton1 then
                    if m then m:Disconnect() end
                end
            end)
        end
    end)

    set(val)
    return f
end

function Nova:CreateWindow(cfg)
    local gui = create("ScreenGui", {
        Name = "Nova",
        Parent = Players.LocalPlayer:WaitForChild("PlayerGui"),
        ResetOnSpawn = false
    })

    local main = create("Frame", {
        Size = UDim2.new(0,520,0,340),
        Position = UDim2.new(0.5,-260,0.5,-170),
        BackgroundColor3 = Color3.fromRGB(18,18,18),
        BorderSizePixel = 0,
        Parent = gui
    })

    corner(main,10)
    stroke(main)

    local top = create("Frame", {
        Size = UDim2.new(1,0,0,30),
        BackgroundColor3 = Color3.fromRGB(22,22,22),
        BorderSizePixel = 0,
        Parent = main
    })

    corner(top,10)

    local title = create("TextLabel", {
        Size = UDim2.new(1,0,1,0),
        BackgroundTransparency = 1,
        Text = cfg and cfg.Name or "Nova UI",
        TextColor3 = Color3.fromRGB(255,255,255),
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        Parent = top
    })

    local close = create("TextButton", {
        Size = UDim2.new(0,30,0,30),
        Position = UDim2.new(1,-30,0,0),
        Text = "X",
        TextColor3 = Color3.fromRGB(255,80,80),
        BackgroundTransparency = 1,
        Parent = top
    })

    close.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)

    local sidebar = create("Frame", {
        Size = UDim2.new(0,120,1,-30),
        Position = UDim2.new(0,0,0,30),
        BackgroundColor3 = Color3.fromRGB(22,22,22),
        BorderSizePixel = 0,
        Parent = main
    })

    local pages = create("Frame", {
        Size = UDim2.new(1,-120,1,-30),
        Position = UDim2.new(0,120,0,30),
        BackgroundTransparency = 1,
        Parent = main
    })

    drag(main, top)

    return setmetatable({
        Gui = gui,
        Main = main,
        Sidebar = sidebar,
        Pages = pages,
        Tabs = {},
        State = Nova.State
    }, Nova)
end

function Nova:CreateTab(name)
    local b = create("TextButton", {
        Size = UDim2.new(1,-10,0,32),
        BackgroundColor3 = Color3.fromRGB(30,30,30),
        Text = name,
        TextColor3 = Color3.fromRGB(255,255,255),
        Font = Enum.Font.Gotham,
        Parent = self.Sidebar
    })

    corner(b,6)

    local page = create("Frame", {
        Size = UDim2.new(1,0,1,0),
        BackgroundTransparency = 1,
        Visible = false,
        Parent = self.Pages
    })

    create("UIListLayout", {
        Padding = UDim.new(0,6),
        Parent = page
    })

    local tab = setmetatable({Page = page, Library = self}, Tab)

    b.MouseButton1Click:Connect(function()
        for _,v in pairs(self.Tabs) do
            v.Page.Visible = false
        end
        page.Visible = true
    end)

    table.insert(self.Tabs, tab)

    return tab
end

return Nova
