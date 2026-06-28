local Nova = {}
Nova.__index = Nova

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

Nova.Theme = {
    Background = Color3.fromRGB(12,12,14),
    Panel = Color3.fromRGB(20,20,24),
    Element = Color3.fromRGB(28,28,32),
    Accent = Color3.fromRGB(0,170,120),
    Text = Color3.fromRGB(240,240,240),
    Muted = Color3.fromRGB(150,150,150)
}

local function create(c,p)
    local o = Instance.new(c)
    for i,v in pairs(p or {}) do o[i]=v end
    return o
end

local function corner(p,r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0,r or 10)
    c.Parent = p
end

local function stroke(p)
    local s = Instance.new("UIStroke")
    s.Color = Color3.fromRGB(55,55,60)
    s.Thickness = 1
    s.Parent = p
end

local function tween(obj,props,t)
    TweenService:Create(obj,TweenInfo.new(t or 0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),props):Play()
end

local function drag(frame,handle)
    local d,s,p
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            d=true
            s=i.Position
            p=frame.Position
        end
    end)

    UIS.InputChanged:Connect(function(i)
        if d and i.UserInputType == Enum.UserInputType.MouseMovement then
            local delta=i.Position-s
            frame.Position=UDim2.new(p.X.Scale,p.X.Offset+delta.X,p.Y.Scale,p.Y.Offset+delta.Y)
        end
    end)

    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            d=false
        end
    end)
end

local Tab={}
Tab.__index=Tab

function Tab:NewButton(text,cb)
    local b=create("TextButton",{
        Size=UDim2.new(1,-12,0,38),
        BackgroundColor3=Nova.Theme.Element,
        Text=text,
        TextColor3=Nova.Theme.Text,
        Font=Enum.Font.GothamMedium,
        TextSize=14,
        Parent=self.Page,
        BorderSizePixel=0
    })

    corner(b,10)
    stroke(b)

    b.MouseEnter:Connect(function()
        tween(b,{BackgroundColor3=Color3.fromRGB(35,35,40)},0.15)
    end)

    b.MouseLeave:Connect(function()
        tween(b,{BackgroundColor3=Nova.Theme.Element},0.15)
    end)

    b.MouseButton1Click:Connect(function()
        if cb then cb() end
    end)

    return b
end

function Tab:NewToggle(text,default,cb)
    local state=default or false

    local f=create("Frame",{
        Size=UDim2.new(1,-12,0,40),
        BackgroundColor3=Nova.Theme.Element,
        Parent=self.Page,
        BorderSizePixel=0
    })

    corner(f,10)
    stroke(f)

    local l=create("TextLabel",{
        Size=UDim2.new(1,-80,1,0),
        BackgroundTransparency=1,
        Text=text,
        TextColor3=Nova.Theme.Text,
        Font=Enum.Font.Gotham,
        TextSize=14,
        Parent=f,
        TextXAlignment=Enum.TextXAlignment.Left
    })

    local bg=create("Frame",{
        Size=UDim2.new(0,42,0,20),
        Position=UDim2.new(1,-52,0.5,-10),
        BackgroundColor3=Color3.fromRGB(60,60,65),
        Parent=f
    })

    corner(bg,20)

    local dot=create("Frame",{
        Size=UDim2.new(0,16,0,16),
        Position=UDim2.new(0,2,0.5,-8),
        BackgroundColor3=Color3.fromRGB(255,255,255),
        Parent=bg
    })

    corner(dot,20)

    local function update()
        if state then
            tween(bg,{BackgroundColor3=Nova.Theme.Accent},0.15)
            tween(dot,{Position=UDim2.new(1,-18,0.5,-8)},0.15)
        else
            tween(bg,{BackgroundColor3=Color3.fromRGB(60,60,65)},0.15)
            tween(dot,{Position=UDim2.new(0,2,0.5,-8)},0.15)
        end
        if cb then cb(state) end
    end

    f.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            state=not state
            update()
        end
    end)

    update()
    return f
end

function Tab:NewSlider(text,min,max,default,cb)
    local val=default or min

    local f=create("Frame",{
        Size=UDim2.new(1,-12,0,55),
        BackgroundColor3=Nova.Theme.Element,
        Parent=self.Page
    })

    corner(f,10)
    stroke(f)

    local l=create("TextLabel",{
        Size=UDim2.new(1,-10,0,20),
        Position=UDim2.new(0,10,0,4),
        BackgroundTransparency=1,
        Text=text,
        TextColor3=Nova.Theme.Text,
        Font=Enum.Font.Gotham,
        TextSize=14,
        Parent=f,
        TextXAlignment=Enum.TextXAlignment.Left
    })

    local bar=create("Frame",{
        Size=UDim2.new(1,-20,0,8),
        Position=UDim2.new(0,10,0,35),
        BackgroundColor3=Color3.fromRGB(50,50,55),
        Parent=f
    })

    corner(bar,10)

    local fill=create("Frame",{
        Size=UDim2.new(0,0,1,0),
        BackgroundColor3=Nova.Theme.Accent,
        Parent=bar
    })

    corner(fill,10)

    local function set(v)
        val=math.clamp(v,min,max)
        fill.Size=UDim2.new((val-min)/(max-min),0,1,0)
        l.Text=text.." : "..math.floor(val)
        if cb then cb(val) end
    end

    bar.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            local m
            m=UIS.InputChanged:Connect(function(i2)
                if i2.UserInputType==Enum.UserInputType.MouseMovement then
                    local p=math.clamp((i2.Position.X-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
                    set(min+(max-min)*p)
                end
            end)

            UIS.InputEnded:Connect(function(i2)
                if i2.UserInputType==Enum.UserInputType.MouseButton1 then
                    if m then m:Disconnect() end
                end
            end)
        end
    end)

    set(val)
    return f
end

function Nova:CreateWindow(cfg)
    local gui=create("ScreenGui",{
        Name="Nova",
        Parent=Players.LocalPlayer:WaitForChild("PlayerGui"),
        ResetOnSpawn=false
    })

    local main=create("Frame",{
        Size=UDim2.new(0,580,0,370),
        Position=UDim2.new(0.5,-290,0.5,-185),
        BackgroundColor3=Nova.Theme.Background,
        Parent=gui,
        BorderSizePixel=0
    })

    corner(main,12)
    stroke(main)

    local top=create("Frame",{
        Size=UDim2.new(1,0,0,38),
        BackgroundColor3=Nova.Theme.Panel,
        Parent=main
    })

    corner(top,12)

    local title=create("TextLabel",{
        Size=UDim2.new(1,0,1,0),
        BackgroundTransparency=1,
        Text=cfg and cfg.Name or "Nova",
        TextColor3=Nova.Theme.Text,
        Font=Enum.Font.GothamBold,
        TextSize=14,
        Parent=top
    })

    local close=create("TextButton",{
        Size=UDim2.new(0,38,0,38),
        Position=UDim2.new(1,-38,0,0),
        Text="×",
        TextColor3=Color3.fromRGB(255,90,90),
        BackgroundTransparency=1,
        Font=Enum.Font.GothamBold,
        TextSize=18,
        Parent=top
    })

    close.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)

    local sidebar=create("Frame",{
        Size=UDim2.new(0,150,1,-38),
        Position=UDim2.new(0,0,0,38),
        BackgroundColor3=Nova.Theme.Panel,
        Parent=main
    })

    local pages=create("Frame",{
        Size=UDim2.new(1,-150,1,-38),
        Position=UDim2.new(0,150,0,38),
        BackgroundTransparency=1,
        Parent=main
    })

    drag(main,top)

    return setmetatable({
        Gui=gui,
        Main=main,
        Sidebar=sidebar,
        Pages=pages,
        Tabs={}
    },Nova)
end

function Nova:CreateTab(name)
    local b=create("TextButton",{
        Size=UDim2.new(1,-10,0,36),
        BackgroundColor3=Nova.Theme.Element,
        Text=name,
        TextColor3=Nova.Theme.Text,
        Font=Enum.Font.Gotham,
        Parent=self.Sidebar,
        BorderSizePixel=0
    })

    corner(b,10)

    local page=create("Frame",{
        Size=UDim2.new(1,0,1,0),
        BackgroundTransparency=1,
        Visible=false,
        Parent=self.Pages
    })

    create("UIListLayout",{
        Padding=UDim.new(0,8),
        Parent=page
    })

    local tab=setmetatable({Page=page,Library=self},Tab)

    b.MouseButton1Click:Connect(function()
        for _,v in pairs(self.Tabs) do
            v.Page.Visible=false
        end
        page.Visible=true
    end)

    table.insert(self.Tabs,tab)

    return tab
end

return Nova
