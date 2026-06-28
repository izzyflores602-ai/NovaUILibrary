local Nova = {}
Nova.__index = Nova

Nova.State = {
    Toggles = {},
    Sliders = {},
    Text = {}
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

local Tab = {}
Tab.__index = Tab

function Tab:NewButton(text, callback)
    local btn = create("TextButton", {
        Size = UDim2.new(1, -10, 0, 32),
        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
        TextColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Text = text,
        Parent = self.Page
    })

    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)

    return btn
end

function Tab:NewToggle(text, default, callback)
    local state = default or false
    self.Library.State.Toggles[text] = state

    local btn = create("TextButton", {
        Size = UDim2.new(1, -10, 0, 32),
        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
        TextColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Text = text .. ": " .. tostring(state),
        Parent = self.Page
    })

    local function update()
        self.Library.State.Toggles[text] = state
        btn.Text = text .. ": " .. tostring(state)
        if callback then callback(state) end
    end

    btn.MouseButton1Click:Connect(function()
        state = not state
        update()
    end)

    update()

    return btn
end

function Tab:NewSlider(text, min, max, default, callback)
    local value = default or min
    self.Library.State.Sliders[text] = value

    local holder = create("Frame", {
        Size = UDim2.new(1, -10, 0, 45),
        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
        BorderSizePixel = 0,
        Parent = self.Page
    })

    local label = create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Text = text .. ": " .. value,
        Parent = holder
    })

    local bar = create("TextButton", {
        Size = UDim2.new(1, -10, 0, 18),
        Position = UDim2.new(0, 5, 0, 25),
        BackgroundColor3 = Color3.fromRGB(45, 45, 45),
        Text = "",
        Parent = holder
    })

    local function set(v)
        value = math.clamp(v, min, max)
        self.Library.State.Sliders[text] = value
        label.Text = text .. ": " .. math.floor(value)
        if callback then callback(value) end
    end

    bar.MouseButton1Down:Connect(function()
        local moveConn
        moveConn = UIS.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                local percent = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                set(min + (max - min) * percent)
            end
        end)

        UIS.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                if moveConn then moveConn:Disconnect() end
            end
        end)
    end)

    set(value)

    return holder
end

function Tab:NewTextBox(text, placeholder, callback)
    local holder = create("Frame", {
        Size = UDim2.new(1, -10, 0, 40),
        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
        BorderSizePixel = 0,
        Parent = self.Page
    })

    create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Text = text,
        Parent = holder
    })

    local box = create("TextBox", {
        Size = UDim2.new(1, -10, 0, 18),
        Position = UDim2.new(0, 5, 0, 20),
        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
        TextColor3 = Color3.fromRGB(255, 255, 255),
        PlaceholderText = placeholder or "",
        ClearTextOnFocus = false,
        Parent = holder
    })

    box.FocusLost:Connect(function()
        if callback then callback(box.Text) end
    end)

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

    local sidebar = create("Frame", {
        Size = UDim2.new(0, 120, 1, 0),
        BackgroundColor3 = Color3.fromRGB(22, 22, 22),
        BorderSizePixel = 0,
        Parent = main
    })

    local pageHolder = create("Frame", {
        Size = UDim2.new(1, -120, 1, 0),
        Position = UDim2.new(0, 120, 0, 0),
        BackgroundTransparency = 1,
        Parent = main
    })

    create("UIListLayout", {
        Padding = UDim.new(0, 6),
        Parent = sidebar
    })

    local self = setmetatable({
        Gui = gui,
        Main = main,
        Sidebar = sidebar,
        PageHolder = pageHolder,
        Tabs = {},
        State = Nova.State
    }, Nova)

    return self
end

function Nova:CreateTab(name)
    local button = create("TextButton", {
        Size = UDim2.new(1, -10, 0, 32),
        BackgroundColor3 = Color3.fromRGB(28, 28, 28),
        TextColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Text = name,
        Parent = self.Sidebar
    })

    local page = create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Visible = false,
        Parent = self.PageHolder
    })

    create("UIListLayout", {
        Padding = UDim.new(0, 6),
        Parent = page
    })

    local tab = setmetatable({
        Page = page,
        Library = self
    }, Tab)

    button.MouseButton1Click:Connect(function()
        for _, v in pairs(self.Tabs) do
            v.Page.Visible = false
        end
        page.Visible = true
    end)

    table.insert(self.Tabs, tab)

    return tab
end

return Nova
