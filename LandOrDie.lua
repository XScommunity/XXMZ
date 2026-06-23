-- w speed

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

local Window = Library:CreateWindow({
    Title = "XXMZ",
    Footer = "by 29",
    Icon = 95816097006870,
    NotifySide = "Right",
    ShowCustomCursor = true,
})

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
local Tabs = {
    Main = Window:AddTab("Main", "user"),
    Tasks = Window:AddTab("Auto Tasks", "list-checks"),
    Exploits = Window:AddTab("Exploits", "sword"),
    Shop = Window:AddTab("Shop", "shopping-cart"),
    Crate = Window:AddTab("Auto Crate", "package"),
    ESP = Window:AddTab("ESP", "eye"),
    Troll = Window:AddTab("Troll", "zap"),
    ["UI Settings"] = Window:AddTab("UI Settings", "settings"),
}

-- ==================== TAB: MAIN ====================
local MainLeft = Tabs.Main:AddLeftGroupbox("Main Features")

-- Auto Walk with Passengers
MainLeft:AddToggle("AutoTalkPassengers", {
    Text = "Auto Walk with passengers [+/- $4.000/9min]",
    Default = false,
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
MainLeft:AddToggle("AutoRadio", {
    Text = "Auto Talk to Radio",
    Default = false,
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
MainLeft:AddToggle("AutoExtinguisher", {
    Text = "Auto Extinguisher Spray",
    Default = false,
    Callback = function(Value)
        if Value then
            task.spawn(function()
                while Toggles.AutoExtinguisher.Value do
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
local TasksLeft = Tabs.Tasks:AddLeftGroupbox("Tasks")

-- Auto Unclog Toilet
TasksLeft:AddToggle("AutoToilet", {
    Text = "Auto Unclog Toilet",
    Default = false,
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
TasksLeft:AddToggle("AutoWindow", {
    Text = "Auto Fix Windows",
    Default = false,
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
TasksLeft:AddToggle("AutoFuel", {
    Text = "Auto Fuel",
    Default = false,
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
local ExploitsLeft = Tabs.Exploits:AddLeftGroupbox("Exploits")

-- Best plane for free
ExploitsLeft:AddButton({
    Text = "Best plane for free (OP)",
    Func = function()
        pcall(function()
            local Event = game:GetService("ReplicatedStorage").Remotes.PlaneRemote
            Event:FireServer("equip_plane", "tungtung")
        end)
        Library:Notify({
            Title = "Exploit",
            Description = "Best plane equipped!",
            Time = 3,
        })
    end,
    DoubleClick = false,
})

-- ==================== TAB: SHOP ====================
local ShopLeft = Tabs.Shop:AddLeftGroupbox("Shop")

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

ShopLeft:AddDropdown("BuyItemDropdown", {
    Values = GetAvailableTools(),
    Default = 1,
    Multi = false,
    Text = "Buy Items",
    Callback = function(Value)
        if Value and Value ~= "No tools found" then
            pcall(function()
                local Event = game:GetService("ReplicatedStorage").Remotes.TabletShopPurchase
                Event:FireServer(Value, "miles")
            end)
            Library:Notify({
                Title = "Purchase",
                Description = "Attempted to buy: " .. tostring(Value),
                Time = 3,
            })
        end
    end,
})

ShopLeft:AddButton({
    Text = "Refresh Tool List",
    Func = function()
        Options.BuyItemDropdown:SetValues(GetAvailableTools())
        Library:Notify({
            Title = "Refreshed",
            Description = "Tool list updated!",
            Time = 2,
        })
    end,
    DoubleClick = false,
})

-- ==================== TAB: AUTO CRATE ====================
local CrateLeft = Tabs.Crate:AddLeftGroupbox("Auto Crate")

CrateLeft:AddToggle("AutoCrate", {
    Text = "Auto Pickup Crates",
    Default = false,
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
local ESPLeft = Tabs.ESP:AddLeftGroupbox("ESP")

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

ESPLeft:AddToggle("ESPCollision", {
    Text = "ESP Collision Planes (Red)",
    Default = false,
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
local TrollLeft = Tabs.Troll:AddLeftGroupbox("Troll")

TrollLeft:AddButton({
    Text = "Turn OFF Engine 1",
    Func = function()
        pcall(function()
            local Event = game:GetService("ReplicatedStorage").Remotes.TooltipAction
            Event:FireServer("Engine 1", workspace.Plane.Cockpit["Engine 1"])
        end)
    end,
    DoubleClick = false,
})

TrollLeft:AddButton({
    Text = "Turn OFF Engine 2",
    Func = function()
        pcall(function()
            local Event = game:GetService("ReplicatedStorage").Remotes.TooltipAction
            Event:FireServer("Engine 2", workspace.Plane.Cockpit["Engine 2"])
        end)
    end,
    DoubleClick = false,
})

TrollLeft:AddToggle("SpamAutopilot", {
    Text = "Spam Autopilot",
    Default = false,
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

-- ==================== UI SETTINGS ====================
local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu")

MenuGroup:AddToggle("KeybindMenuOpen", {
    Default = Library.KeybindFrame.Visible,
    Text = "Open Keybind Menu",
    Callback = function(value)
        Library.KeybindFrame.Visible = value
    end,
})

MenuGroup:AddToggle("ShowCustomCursor", {
    Text = "Custom Cursor",
    Default = true,
    Callback = function(Value)
        Library.ShowCustomCursor = Value
    end,
})

MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", {
    Default = "RightShift",
    NoUI = true,
    Text = "Menu keybind",
})

MenuGroup:AddButton({
    Text = "Unload",
    Func = function()
        Library:Unload()
    end,
    DoubleClick = false,
})

Library.ToggleKeybind = Options.MenuKeybind

-- ThemeManager & SaveManager
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
ThemeManager:SetFolder("XXMZ")
SaveManager:SetFolder("XXMZ/plane-hub")
SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])
SaveManager:LoadAutoloadConfig()

Library:Notify({
    Title = "XXMZ Loaded",
    Description = "Script loaded successfully!",
    Time = 5,
})
