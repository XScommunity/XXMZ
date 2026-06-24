-- w speed

local WindUI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"
))()

local Window = WindUI:CreateWindow({
    Title = "XXMZ HUB | Land Or Die",
    Author = "by 29",
    Folder = "XXMZ",
    Size = UDim2.fromOffset(580, 460),
    MinSize = Vector2.new(560, 350),
    MaxSize = Vector2.new(850, 560),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 200,
    HideSearchBar = true,
    ScrollBarEnabled = false,
    BackgroundImageTransparency = 0.5,
    Background = "rbxassetid://100169693594473",

    OpenButton = {
    Title = "XXMZ HUB",
    CornerRadius = UDim.new(1, 0),
    StrokeThickness = 3,
    Enabled = true,
    Draggable = true,
    OnlyMobile = false,
    Scale = 1,
    Color = ColorSequence.new(
        Color3.fromHex("#30FF6A"),
        Color3.fromHex("#e7ff2f")
    ),
},
})

-- ==================== BACKGROUND FIX ====================
-- WindUI creates the background image as a child of the Squircle Background frame.
-- The Squircle is an ImageLabel with a white rounded-corner image that covers everything.
-- We make the Squircle transparent and create the background as a sibling instead.

task.spawn(function()
    task.wait(0.3)

    pcall(function()
        local Main = Window.UIElements.Main
        if not Main then return end

        local MainContent = Main:WaitForChild("Main", 2)
        if not MainContent then return end

        local Background = MainContent:WaitForChild("Background", 2)
        if not Background then return end

        -- Create background image as a SIBLING of Background (same parent level)
        -- This puts it BEHIND the Squircle in render order
        local bgImage = Instance.new("ImageLabel")
        bgImage.Name = "WindowBgImage"
        bgImage.Size = UDim2.new(1, 0, 1, 0)
        bgImage.Position = UDim2.new(0, 0, 0, 0)
        bgImage.BackgroundTransparency = 1
        bgImage.Image = "rbxassetid://71142928093016"
        bgImage.ImageTransparency = 0
        bgImage.ScaleType = Enum.ScaleType.Crop
        bgImage.ZIndex = 0

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 16)
        corner.Parent = bgImage

        bgImage.Parent = MainContent

        -- Ensure Background renders on top
        Background.LayoutOrder = 1
        bgImage.LayoutOrder = 0

        -- Make the Squircle semi-transparent so the image shows through
        Background.ImageTransparency = 0.25

        -- Also make MainBar background semi-transparent
        local mainBar = MainContent:WaitForChild("MainBar", 1)
        if mainBar then
            local mainBarBg = mainBar:WaitForChild("Background", 1)
            if mainBarBg then
                mainBarBg.ImageTransparency = 0.5
            end
        end
    end)
end)

-- ==================== VARIAVEIS GLOBAIS ====================
local AutoTalkEnabled = false
local AutoCrateEnabled = false
local SpamAutopilotEnabled = false
local AutoRadioEnabled = false
local ESPCollisionEnabled = false
local AutoFuelEnabled = false
local AutoToiletEnabled = false
local AutoWindowEnabled = false
local ESPObjects = {}

-- ==================== TABS ====================
local MainTab = Window:Tab({ Title = "Main", Icon = "user" })
local TasksTab = Window:Tab({ Title = "Auto Tasks", Icon = "list-checks" })
local ExploitsTab = Window:Tab({ Title = "Exploits", Icon = "sword" })
local ShopTab = Window:Tab({ Title = "Shop", Icon = "shopping-cart" })
local CrateTab = Window:Tab({ Title = "Auto Crate", Icon = "package" })
local ESPTab = Window:Tab({ Title = "ESP", Icon = "eye" })
local TrollTab = Window:Tab({ Title = "Troll", Icon = "zap" })

-- ==================== TAB: MAIN ====================

-- Auto Walk with Passengers
MainTab:Toggle({
    Title = "Auto Talk with passengers [+/- $4.000/9min]",
    Value = false,
    Callback = function(Value)
        AutoTalkEnabled = Value
        if Value then
            task.spawn(function()
                while AutoTalkEnabled do
                    local Passengers = workspace.Plane.Passengers
                    for _, Passenger in pairs(Passengers:GetChildren()) do
                        if Passenger:IsA("Model") then
                            pcall(function()
                                local Event = game:GetService("ReplicatedStorage").Remotes.TooltipAction
                                Event:FireServer("Talk to Passenger", Passenger)
                            end)
                        end
                    end
                    task.wait(0.5)
                end
            end)
        end
    end,
})

-- Auto Talk to Radio
MainTab:Toggle({
    Title = "Auto Talk to Radio",
    Value = false,
    Callback = function(Value)
        AutoRadioEnabled = Value
        if Value then
            task.spawn(function()
                while AutoRadioEnabled do
                    pcall(function()
                        local Event = game:GetService("ReplicatedStorage").Remotes.TooltipAction
                        Event:FireServer("Radio", workspace.Plane.Cockpit.ATCButton)
                    end)
                    task.wait(1)
                end
            end)
        end
    end,
})

-- Auto Extinguisher Spray
local AutoExtinguisherToggle
AutoExtinguisherToggle = MainTab:Toggle({
    Title = "Auto Extinguisher Spray",
    Value = false,
    Callback = function(Value)
        if Value then
            task.spawn(function()
                while AutoExtinguisherToggle:Get() do
                    pcall(function()
                        local char = game:GetService("Players").LocalPlayer.Character
                        local extinguisher = char:FindFirstChild("Fire Extinguisher")
                        if extinguisher then
                            local Event = game:GetService("ReplicatedStorage").Remotes.ExtinguisherSpray
                            Event:FireServer(
                                "spray",
                                extinguisher,
                                Vector3.new(-212.734375, 498.56094360352, -340.4658203125),
                                Vector3.new(-0.12363119423389, -0.50498163700104, 0.85422986745834),
                                0.055181335657835
                            )
                        end
                    end)
                    task.wait(0.1)
                end
            end)
        end
    end,
})

-- ==================== TAB: AUTO TASKS ====================

-- Auto Unclog Toilet
TasksTab:Toggle({
    Title = "Auto Unclog Toilet",
    Value = false,
    Callback = function(Value)
        AutoToiletEnabled = Value
        if Value then
            task.spawn(function()
                while AutoToiletEnabled do
                    pcall(function()
                        local Event = game:GetService("ReplicatedStorage").Remotes.TooltipAction
                        Event:FireServer("Unclog Toilet", workspace.Plane.Toilet.Toilet_1)
                    end)
                    task.wait(1)
                end
            end)
        end
    end,
})

-- Auto Fix Windows
TasksTab:Toggle({
    Title = "Auto Fix Windows",
    Value = false,
    Callback = function(Value)
        AutoWindowEnabled = Value
        if Value then
            task.spawn(function()
                while AutoWindowEnabled do
                    local WindowsFolder = workspace.Plane:FindFirstChild("Windows")
                    if WindowsFolder then
                        for _, WindowObj in pairs(WindowsFolder:GetChildren()) do
                            if WindowObj:IsA("Model") and WindowObj.Name:match("^Window") then
                                pcall(function()
                                    local Event = game:GetService("ReplicatedStorage").Remotes.TooltipAction
                                    Event:FireServer("fix_window", WindowObj)
                                end)
                            end
                        end
                    end
                    task.wait(1)
                end
            end)
        end
    end,
})

-- Auto Fuel
local AutoFuelToggle
AutoFuelToggle = TasksTab:Toggle({
    Title = "Auto Fuel",
    Value = false,
    Callback = function(Value)
        AutoFuelEnabled = Value
        if Value then
            pcall(function()
                local Event = game:GetService("ReplicatedStorage").Remotes.TooltipAction
                Event:FireServer("Fuel Door", workspace.Plane.Fuel.PortLeft.FuelDoor)
            end)
            task.wait(0.5)
            pcall(function()
                local Event = game:GetService("ReplicatedStorage").Remotes.GasAction
                Event:FireServer("start", "PortLeft")
            end)
        else
            pcall(function()
                local Event = game:GetService("ReplicatedStorage").Remotes.GasAction
                Event:FireServer("stop")
            end)
            task.wait(0.5)
            pcall(function()
                local Event = game:GetService("ReplicatedStorage").Remotes.TooltipAction
                Event:FireServer("Fuel Door", workspace.Plane.Fuel.PortLeft.FuelDoor)
            end)
        end
    end,
})

-- ==================== TAB: EXPLOITS ====================

-- Best plane for free
ExploitsTab:Button({
    Title = "Best plane for free (OP)",
    Callback = function()
        pcall(function()
            local Event = game:GetService("ReplicatedStorage").Remotes.PlaneRemote
            Event:FireServer("equip_plane", "tungtung")
        end)
        WindUI:Notify({
            Title = "Exploit",
            Content = "Best plane equipped!",
            Icon = "zap",
            Duration = 3,
        })
    end,
})

-- ==================== TAB: SHOP ====================

local function GetAvailableTools()
    local AvailableTools = {}
    local success, ToolsFolder = pcall(function()
        return game:GetService("ReplicatedStorage").Assets.Tools
    end)
    if success and ToolsFolder then
        for _, Tool in pairs(ToolsFolder:GetChildren()) do
            if Tool:IsA("Tool") or Tool:IsA("Model") then
                table.insert(AvailableTools, Tool.Name)
            end
        end
    end
    if #AvailableTools == 0 then
        table.insert(AvailableTools, "No tools found")
    end
    return AvailableTools
end

local BuyDropdown
BuyDropdown = ShopTab:Dropdown({
    Title = "Buy Items",
    Values = GetAvailableTools(),
    Value = 1,
    Callback = function(Value)
        if Value and Value ~= "No tools found" then
            pcall(function()
                local Event = game:GetService("ReplicatedStorage").Remotes.TabletShopPurchase
                Event:FireServer(Value, "miles")
            end)
            WindUI:Notify({
                Title = "Purchase",
                Content = "Attempted to buy: " .. tostring(Value),
                Icon = "shopping-cart",
                Duration = 3,
            })
        end
    end,
})

ShopTab:Button({
    Title = "Refresh Tool List",
    Callback = function()
        BuyDropdown:Refresh(GetAvailableTools())
        WindUI:Notify({
            Title = "Refreshed",
            Content = "Tool list updated!",
            Icon = "refresh-cw",
            Duration = 2,
        })
    end,
})

-- ==================== TAB: AUTO CRATE ====================

CrateTab:Toggle({
    Title = "Auto Pickup Crates",
    Value = false,
    Callback = function(Value)
        AutoCrateEnabled = Value
        if Value then
            task.spawn(function()
                while AutoCrateEnabled do
                    for _, Obj in pairs(workspace:GetDescendants()) do
                        if Obj.Name:match("^DeliveryCrate") then
                            pcall(function()
                                local Event = game:GetService("ReplicatedStorage").Remotes.TooltipAction
                                Event:FireServer("Pickup Delivery", Obj)
                            end)
                        end
                    end
                    task.wait(0.5)
                end
            end)
        end
    end,
})

-- ==================== TAB: ESP ====================

local function CreateESP(Model)
    if ESPObjects[Model] then return end
    if not Model or not Model.Parent then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "CollisionPlaneESP"
    billboard.Adornee = Model
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 5, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = Model

    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "ESPText"
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
    textLabel.TextStrokeTransparency = 0
    textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.GothamBold
    textLabel.Text = "[COLLISION PLANE]"
    textLabel.Parent = billboard

    ESPObjects[Model] = billboard
end

local function UpdateESP()
    if not ESPCollisionEnabled then return end

    local Simulation = workspace:FindFirstChild("Simulation")
    if not Simulation then return end

    for _, Obj in pairs(Simulation:GetChildren()) do
        if Obj:IsA("Model") and Obj.Name:match("^CollisionPlane_Active") then
            CreateESP(Obj)
        end
    end
end

local ESPToggle
ESPToggle = ESPTab:Toggle({
    Title = "ESP Collision Planes (Red)",
    Value = false,
    Callback = function(Value)
        ESPCollisionEnabled = Value

        if Value then
            UpdateESP()

            task.spawn(function()
                while ESPCollisionEnabled do
                    UpdateESP()
                    task.wait(2)
                end
            end)

            local Simulation = workspace:FindFirstChild("Simulation")
            if Simulation then
                Simulation.ChildAdded:Connect(function(child)
                    if ESPCollisionEnabled and child:IsA("Model") and child.Name:match("^CollisionPlane_Active") then
                        CreateESP(child)
                    end
                end)
            end
        else
            for model, billboard in pairs(ESPObjects) do
                if billboard then billboard:Destroy() end
            end
            ESPObjects = {}
        end
    end,
})

-- ==================== TAB: TROLL ====================

TrollTab:Button({
    Title = "Turn OFF Engine 1",
    Callback = function()
        pcall(function()
            local Event = game:GetService("ReplicatedStorage").Remotes.TooltipAction
            Event:FireServer("Engine 1", workspace.Plane.Cockpit["Engine 1"])
        end)
    end,
})

TrollTab:Button({
    Title = "Turn OFF Engine 2",
    Callback = function()
        pcall(function()
            local Event = game:GetService("ReplicatedStorage").Remotes.TooltipAction
            Event:FireServer("Engine 2", workspace.Plane.Cockpit["Engine 2"])
        end)
    end,
})

local SpamAutopilotToggle
SpamAutopilotToggle = TrollTab:Toggle({
    Title = "Spam Autopilot",
    Value = false,
    Callback = function(Value)
        SpamAutopilotEnabled = Value
        if Value then
            task.spawn(function()
                while SpamAutopilotEnabled do
                    pcall(function()
                        local Event = game:GetService("ReplicatedStorage").Remotes.TooltipAction
                        Event:FireServer("Autopilot", workspace.Plane.Cockpit.AutopilotButton)
                    end)
                    task.wait(0.1)
                end
            end)
        end
    end,
})

-- ==================== NOTIFICAÇÃO DE CARREGAMENTO ====================

WindUI:Notify({
    Title = "XXMZ Loaded",
    Content = "Script loaded successfully!",
    Icon = "check-circle",
    Duration = 5,
})
