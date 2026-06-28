local Nova = {}
Nova.__index = Nova

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")

Nova.Theme = {
    Bg = Color3.fromRGB(14,14,16),
    Panel = Color3.fromRGB(22,22,26),
    Element = Color3.fromRGB(30,30,35),
    Accent = Color3.fromRGB(0,170,120),
    Text = Color3.fromRGB(240,240,240)
}

local function create(class, props)
    local obj = Instance.new(class)
    for i,v in pairs(props or {}) do
        obj[i] = v
    end
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
    s.Transparency = 0.3
    s.Thickness = 1
    s.Parent = obj
end

local function drag(frame, handle)
    local dragging, startPos, startInput

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            startInput = input.Position
            startPos = frame.Position
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - startInput
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- TAB SYSTEM
local Tab = {}
Tab.__index = Tab

function Tab:NewButton(text, cb)
    local b = create("TextButton", {
        Size = UDim2.new(1, -10, 0, 36),
        BackgroundColor3 = Nova.Theme.Element,
        Text = text,
        TextColor3 = Nova.Theme.Text,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        BorderSizePixel = 0,
        Parent = self.Page
    })

    corner(b, 10)
    stroke(b)

    b.MouseButton1Click:Connect(function()
        if cb then cb() end
    end)

    return b
end

function Tab:NewSlider(text, min, max, default, cb)
    local value = default or min

    local frame = create("Frame", {
        Size = UDim2.new(1, -10, 0, 55),
        BackgroundColor3 = Nova.Theme.Element,
        Parent = self.Page
    })

    corner(frame, 10)
    stroke(frame)

    local label = create("TextLabel", {
        Size = UDim2.new(1, -10, 0, 20),
        Position = UDim2.new(0, 10, 0, 5),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Nova.Theme.Text,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame
    })

    local bar = create("Frame", {
        Size = UDim2.new(1, -20, 0, 8),
        Position = UDim2.new(0, 10, 0, 35),
        BackgroundColor3 = Color3.fromRGB(50,50,55),
        Parent = frame
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
        if cb then cb(value) end
    end

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local move
            move = UIS.InputChanged:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseMovement then
                    local p = math.clamp((i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                    set(min + (max - min) * p)
                end
            end)

            UIS.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then
                    if move then move:Disconnect() end
                end
            end)
        end
    end)

    set(value)
    return frame
end

-- WINDOW
function Nova:CreateWindow(cfg)
    local gui = create("ScreenGui", {
        Name = "Nova",
        Parent = Players.LocalPlayer:WaitForChild("PlayerGui"),
        ResetOnSpawn = false
    })

    local main = create("Frame", {
        Size = UDim2.new(0, 600, 0, 380),
        Position = UDim2.new(0.5, -300, 0.5, -190),
        BackgroundColor3 = Nova.Theme.Bg,
        BorderSizePixel = 0,
        Parent = gui
    })

    corner(main, 12)
    stroke(main)

    local top = create("Frame", {
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = Nova.Theme.Panel,
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
        Size = UDim2.new(0, 150, 1, -38),
        Position = UDim2.new(0, 0, 0, 38),
        BackgroundColor3 = Nova.Theme.Panel,
        Parent = main
    })

    local pages = create("Frame", {
        Size = UDim2.new(1, -150, 1, -38),
        Position = UDim2.new(0, 150, 0, 38),
        BackgroundTransparency = 1,
        Parent = main
    })

    drag(main, top)

    return setmetatable({
        Gui = gui,
        Main = main,
        Sidebar = sidebar,
        Pages = pages,
        Tabs = {}
    }, Nova)
end

-- TAB FIXED (IMPORTANT)
function Nova:CreateTab(name)

    local button = create("TextButton", {
        Size = UDim2.new(1, -10, 0, 36),
        BackgroundColor3 = Nova.Theme.Element,
        Text = name,
        TextColor3 = Nova.Theme.Text,
        Font = Enum.Font.Gotham,
        Parent = self.Sidebar,
        BorderSizePixel = 0
    })

    corner(button, 10)

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

    button.MouseButton1Click:Connect(function()
        for _, t in pairs(self.Tabs) do
            t.Page.Visible = false
        end
        page.Visible = true
    end)

    table.insert(self.Tabs, tab)

    if #self.Tabs == 1 then
        page.Visible = true
    end

    return tab
end

return Nova
