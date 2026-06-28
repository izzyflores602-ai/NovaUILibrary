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

local function corner(parent, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 6)
    c.Parent = parent
end

local function stroke(parent, t)
    local s = Instance.new("UIStroke")
    s.Thickness = t or 1
    s.Color = Color3.fromRGB(60, 60, 60)
    s.Parent = parent
end

local Tab = {}
Tab.__index = Tab

function Tab:NewButton(text, callback)
    local btn = create("TextButton", {
        Size = UDim2.new(1, -10, 0, 36),
        BackgroundColor3 = Color3.fromRGB(28, 28, 28),
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Text = text,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        BorderSizePixel = 0,
        Parent = self.Page
    })

    corner(btn, 6)
    stroke(btn, 0.5)

    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    end)

    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    end)

    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)

    return btn
end

function Tab:NewToggle(text, default, callback)
    local state = default or false
    self.Library.State.Toggles[text] = state

    local holder = create("Frame", {
        Size = UDim2.new(1, -10, 0, 36),
        BackgroundColor3 = Color3.fromRGB(28, 28, 28),
        BorderSizePixel = 0,
        Parent = self.Page
    })

    corner(holder, 6)
    stroke(holder, 0.5)

    local label = create("TextLabel", {
        Size = UDim2.new(0.7, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.Gotham,
        TextSize = 14,
        Parent = holder
    })

    local switch = create("Frame", {
        Size = UDim2.new(0, 40, 0, 18),
        Position = UDim2.new(1, -50, 0.5, -9),
        BackgroundColor3 = Color3.fromRGB(60, 60, 60),
        Parent = holder
    })

    corner(switch, 10)

    local dot = create("Frame", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0, 1, 0.5, -8),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Parent = switch
    })

    corner(dot, 10)

    local function update()
        self.Library.State.Toggles[text] = state
        if callback then callback(state) end

        if state then
            switch.BackgroundColor3 = Color3.fromRGB(0, 170, 120)
            dot.Position = UDim2.new(1, -17, 0.5, -8)
        else
            switch.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            dot.Position = UDim2.new(0, 1, 0.5, -8)
        end
    end

    switch.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            state = not state
            update()
        end
    end)

    update()

    return holder
end

function Tab:NewSlider(text, min, max, default, callback)
    local value = default or min

    local holder = create("Frame", {
        Size = UDim2.new(1, -10, 0, 50),
        BackgroundColor3 = Color3.fromRGB(28, 28, 28),
        BorderSizePixel = 0,
        Parent = self.Page
    })

    corner(holder, 6)
    stroke(holder, 0.5)

    local label = create("TextLabel", {
        Size = UDim2.new(1, -10, 0, 20),
        Position = UDim2.new(0, 10, 0, 2),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = holder
    })

    local barBG = create("Frame", {
        Size = UDim2.new(1, -20, 0, 10),
        Position = UDim2.new(0, 10, 0, 30),
        BackgroundColor3 = Color3.fromRGB(50, 50, 50),
        Parent = holder
    })

    corner(barBG, 6)

    local fill = create("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(0, 170, 120),
        Parent = barBG
    })

    corner(fill, 6)

    local function set(v)
        value = math.clamp(v, min, max)
        fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
        label.Text = text .. " : " .. math.floor(value)
        self.Library.State.Sliders[text] = value
        if callback then callback(value) end
    end

    barBG.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local move
            move = UIS.InputChanged:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseMovement then
                    local p = math.clamp((i.Position.X - barBG.AbsolutePosition.X) / barBG.AbsoluteSize.X, 0, 1)
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

    return holder
end

function Nova:CreateWindow(config)
    local gui = create("ScreenGui", {
        Name = config and config.Name or "Nova",
        ResetOnSpawn = false,
        Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    })

    local main = create("Frame", {
        Size = UDim2.new(0, 520, 0, 340),
        Position = UDim2.new(0.5, -260, 0.5, -170),
        BackgroundColor3 = Color3.fromRGB(18, 18, 18),
        BorderSizePixel = 0,
        Parent = gui
    })

    corner(main, 8)

    local sidebar = create("Frame", {
        Size = UDim2.new(0, 120, 1, 0),
        BackgroundColor3 = Color3.fromRGB(22, 22, 22),
        BorderSizePixel = 0,
        Parent = main
    })

    local pages = create("Frame", {
        Size = UDim2.new(1, -120, 1, 0),
        Position = UDim2.new(0, 120, 0, 0),
        BackgroundTransparency = 1,
        Parent = main
    })

    create("UIListLayout", {
        Padding = UDim.new(0, 6),
        Parent = sidebar
    })

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
    local btn = create("TextButton", {
        Size = UDim2.new(1, -10, 0, 32),
        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Text = name,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        BorderSizePixel = 0,
        Parent = self.Sidebar
    })

    corner(btn, 6)

    local page = create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Visible = false,
        Parent = self.Pages
    })

    create("UIListLayout", {
        Padding = UDim.new(0, 6),
        Parent = page
    })

    local tab = setmetatable({
        Page = page,
        Library = self
    }, Tab)

    btn.MouseButton1Click:Connect(function()
        for _, v in pairs(self.Tabs) do
            v.Page.Visible = false
        end
        page.Visible = true
    end)

    table.insert(self.Tabs, tab)

    return tab
end

return Nova
