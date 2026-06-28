--hi
local Nova = {}
Nova.__index = Nova

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")

Nova.Theme = {
    Bg = Color3.fromRGB(12,12,14),
    Panel = Color3.fromRGB(20,20,24),
    Element = Color3.fromRGB(28,28,32),
    Accent = Color3.fromRGB(0,170,120),
    Text = Color3.fromRGB(240,240,240)
}

local function create(c,p)
    local o = Instance.new(c)
    for i,v in pairs(p or {}) do o[i]=v end
    return o
end

local function corner(p,r)
    local c=Instance.new("UICorner")
    c.CornerRadius=UDim.new(0,r or 10)
    c.Parent=p
end

local function stroke(p)
    local s=Instance.new("UIStroke")
    s.Color=Color3.fromRGB(70,70,75)
    s.Transparency=0.4
    s.Thickness=1
    s.Parent=p
end

local function drag(frame,handle)
    local d,s,p
    handle.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            d=true
            s=i.Position
            p=frame.Position
        end
    end)

    UIS.InputChanged:Connect(function(i)
        if d and i.UserInputType==Enum.UserInputType.MouseMovement then
            local delta=i.Position-s
            frame.Position=UDim2.new(
                p.X.Scale,p.X.Offset+delta.X,
                p.Y.Scale,p.Y.Offset+delta.Y
            )
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
        Size=UDim2.new(1,-12,0,36),
        BackgroundColor3=Nova.Theme.Element,
        Text=text,
        TextColor3=Nova.Theme.Text,
        Font=Enum.Font.Gotham,
        Parent=self.Page
    })

    corner(b,10)
    stroke(b)

    b.MouseButton1Click:Connect(function()
        if cb then cb() end
    end)

    return b
end

-- ✔ FIXED SLIDER API (min, max clearly defined)
function Tab:NewSlider(text,min,max,default,cb)
    local val=default or min

    local f=create("Frame",{
        Size=UDim2.new(1,-12,0,55),
        BackgroundColor3=Nova.Theme.Element,
        BackgroundTransparency=0.15,
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
        TextXAlignment=Enum.TextXAlignment.Left,
        Parent=f
    })

    local bar=create("Frame",{
        Size=UDim2.new(1,-20,0,7),
        Position=UDim2.new(0,10,0,35),
        BackgroundColor3=Color3.fromRGB(50,50,55),
        BackgroundTransparency=0.2,
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
        l.Text=text.." ["..min.." - "..max.."] : "..math.floor(val)
        if cb then cb(val) end
    end

    bar.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            local move
            move=UIS.InputChanged:Connect(function(i2)
                if i2.UserInputType==Enum.UserInputType.MouseMovement then
                    local p=math.clamp((i2.Position.X-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
                    set(min+(max-min)*p)
                end
            end)

            UIS.InputEnded:Connect(function(i2)
                if i2.UserInputType==Enum.UserInputType.MouseButton1 then
                    if move then move:Disconnect() end
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
        Size=UDim2.new(0,600,0,380),
        Position=UDim2.new(0.5,-300,0.5,-190),
        BackgroundColor3=Nova.Theme.Bg,
        BackgroundTransparency=0.05,
        Parent=gui
    })

    corner(main,12)
    stroke(main)

    local top=create("Frame",{
        Size=UDim2.new(1,0,0,38),
        BackgroundColor3=Nova.Theme.Panel,
        BackgroundTransparency=0.1,
        Parent=main
    })

    corner(top,12)

    local title=create("TextLabel",{
        Size=UDim2.new(1,0,1,0),
        BackgroundTransparency=1,
        Text=cfg and cfg.Name or "Nova",
        TextColor3=Nova.Theme.Text,
        Font=Enum.Font.GothamBold,
        Parent=top
    })

    local sidebar=create("Frame",{
        Size=UDim2.new(0,150,1,-38),
        Position=UDim2.new(0,0,0,38),
        BackgroundColor3=Nova.Theme.Panel,
        BackgroundTransparency=0.2,
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
    local btn=create("TextButton",{
        Size=UDim2.new(1,-10,0,36),
        BackgroundColor3=Nova.Theme.Element,
        BackgroundTransparency=0.1,
        Text=name,
        TextColor3=Nova.Theme.Text,
        Parent=self.Sidebar
    })

    corner(btn,10)

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

    btn.MouseButton1Click:Connect(function()
        for _,t in pairs(self.Tabs) do
            t.Page.Visible=false
        end
        page.Visible=true
    end)

    table.insert(self.Tabs,tab)

    if #self.Tabs==1 then
        page.Visible=true
    end

    return tab
end

return Nova
