-- w speed

local WindUI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"
))()

loadstring(game:HttpGet("https://raw.githubusercontent.com/XScommunity/XXMZ/refs/heads/main/tinc"))()

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
task.spawn(function()
    task.wait(0.3)
    pcall(function()
        local Main = Window.UIElements.Main
        if not Main then return end
        local MainContent = Main:WaitForChild("Main", 2)
        if not MainContent then return end
        local Background = MainContent:WaitForChild("Background", 2)
        if not Background then return end

        local bgImage = Instance.new("ImageLabel")
        bgImage.Name = "WindowBgImage"
        bgImage.Size = UDim2.new(1, 0, 1, 0)
        bgImage.Position = UDim2.new(0, 0, 0, 0)
        bgImage.BackgroundTransparency = 1
        bgImage.Image = "rbxassetid://71142928093016"
        bgImage.ImageTransparency = 0
        bgImage.ScaleType = Enum.ScaleType.Crop
        bgImage.ZIndex = 0
        Instance.new("UICorner", bgImage).CornerRadius = UDim.new(0, 16)
        bgImage.Parent = MainContent

        Background.LayoutOrder = 1
        bgImage.LayoutOrder = 0
        Background.ImageTransparency = 0.25

        local mainBar = MainContent:WaitForChild("MainBar", 1)
        if mainBar then
            local mainBarBg = mainBar:WaitForChild("Background", 1)
            if mainBarBg then mainBarBg.ImageTransparency = 0.5 end
        end
    end)
end)

-- ==================== GLOBAL VARIABLES ====================
local AutoTalkEnabled = false
local AutoCrateEnabled = false
local SpamAutopilotEnabled = false
local AutoRadioEnabled = false
local AutoFuelEnabled = false
local AutoToiletEnabled = false
local AutoWindowEnabled = false

-- ==================== AI PILOT ====================
local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local RepStorage = game:GetService("ReplicatedStorage")
local Workspace  = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local PilotControl = nil

local function findRemote()
    if PilotControl then return PilotControl end
    local tries = {
        function() return RepStorage:FindFirstChild("Remotes") and RepStorage.Remotes:FindFirstChild("PilotControl") end,
        function() return RepStorage:FindFirstChild("PilotControl") end,
        function()
            for _, v in ipairs(RepStorage:GetDescendants()) do
                if v.Name == "PilotControl" and (v:IsA("RemoteEvent") or v:IsA("RemoteFunction")) then
                    return v
                end
            end
        end,
    }
    for _, fn in ipairs(tries) do
        local ok, res = pcall(fn)
        if ok and res then PilotControl = res return PilotControl end
    end
    return nil
end

task.spawn(function()
    local n = 0
    while not PilotControl and n < 30 do
        findRemote()
        if not PilotControl then task.wait(1) end
        n += 1
    end
end)

local ROLL_MULT  = 10
local PITCH_MULT = 10

task.spawn(function()
    task.wait(3)
    pcall(function()
        local bal = require(RepStorage:WaitForChild("Modules", 10):WaitForChild("Balancing", 10)):get_active()
        if bal and bal.flight then
            ROLL_MULT  = 10 * bal.flight.plane_maneuverability_roll
            PITCH_MULT = 10 * bal.flight.plane_maneuverability_pitch
        end
    end)
end)

local PilotConfig = {
    PilotEnabled      = false,
    AltMin            = 3000,
    AltMax            = 10000,
    StabDeadzone      = 30,
    StabStrength      = 0.25,
    EvasionStrength   = 1.0,
    EvasionDuration   = 1.8,
    CollisionPattern  = "^CollisionPlane_Active",
    RampTime          = 0.15,
    WarnCollision     = false,
    EvasionMinDist    = 800,   -- só evade se avião inimigo estiver dentro dessa distância (studs)
}

local PilotState = {
    TargetAlt    = 0,
    CurrentAlt   = 0,
    Evading      = false,
    EvasionDir   = 0,
    EvasionTimer = 0,
    PitchRamp    = 0,
    Conn         = nil,
}

local function getAltitude()
    local v = Workspace:FindFirstChild("ClientAltitude")
    if v and v:IsA("NumberValue") then return v.Value end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj.Name == "ClientAltitude" and obj:IsA("NumberValue") then return obj.Value end
    end
    local char = LocalPlayer.Character
    if char then
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then return root.Position.Y end
    end
    return 0
end

local function ramp(current, target, maxDelta)
    local delta = target - current
    if math.abs(delta) <= maxDelta then return target end
    return current + (delta > 0 and maxDelta or -maxDelta)
end

-- ============================================
-- DETECÇÃO DE COLISÃO — CORRIGIDA
-- Avião não tem HumanoidRootPart, então busca
-- qualquer BasePart nos descendentes do modelo
-- ============================================
-- Guarda posições anteriores pra calcular velocidade/direção dos inimigos
local planeLastPos = {}

local function getClosestCollision()
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return false, nil end

    local myPos = myRoot.Position
    local now = tick()
    local threat = nil
    local threatDist = math.huge

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:match(PilotConfig.CollisionPattern) then
            local dist = (obj.Position - myPos).Magnitude

            -- Fora da distância máxima → ignora
            if dist <= PilotConfig.EvasionMinDist then
                -- Checa se tá se aproximando usando posição anterior
                local key = obj:GetDebugId()
                local last = planeLastPos[key]
                local approaching = true  -- assume ameaça se não tem histórico ainda

                if last then
                    local prevDist = (last.pos - myPos).Magnitude
                    -- Só é ameaça se tá ficando mais perto
                    approaching = dist < prevDist
                end

                planeLastPos[key] = { pos = obj.Position, t = now }

                if approaching and dist < threatDist then
                    threatDist = dist
                    threat = obj
                end
            end
        end
    end

    -- Limpa entradas antigas do cache (objetos que sumiram)
    for key, data in pairs(planeLastPos) do
        if now - data.t > 3 then
            planeLastPos[key] = nil
        end
    end

    if threat then
        return true, threat.Position.Y
    end
    return false, nil
end

local function calcEvasionDir(enemyY)
    local alt = PilotState.CurrentAlt
    if alt < PilotConfig.AltMin then return 1 end
    if alt > PilotConfig.AltMax then return -1 end
    return enemyY >= PilotState.CurrentAlt and -1 or 1
end

local function onStep(dt)
    if not PilotConfig.PilotEnabled then return end

    PilotState.CurrentAlt = getAltitude()

    local colliding, enemyY = getClosestCollision()

    if colliding then
        if PilotConfig.WarnCollision and not PilotState.Evading then
            WindUI:Notify({
                Title = "Collision Warning",
                Content = "Collision plane detected! Evading...",
                Icon = "alert-triangle",
                Duration = 3,
            })
        end
        PilotState.Evading      = true
        PilotState.EvasionTimer = PilotConfig.EvasionDuration
        PilotState.EvasionDir   = calcEvasionDir(enemyY)
    elseif PilotState.EvasionTimer > 0 then
        PilotState.EvasionTimer -= dt
        if PilotState.EvasionTimer <= 0 then
            PilotState.Evading    = false
            PilotState.EvasionDir = 0
            -- Atualiza alvo para altitude atual após evasão
            PilotState.TargetAlt  = PilotState.CurrentAlt
        end
    end

    local pitchTarget = 0

    if PilotState.Evading then
        pitchTarget = PilotState.EvasionDir * PilotConfig.EvasionStrength
    else
        -- Estabilização: erro = quanto precisa corrigir
        local err = PilotState.TargetAlt - PilotState.CurrentAlt

        if math.abs(err) > PilotConfig.StabDeadzone then
            -- Sinal: err > 0 significa abaixo do alvo → pitch "up" → PitchRamp positivo
            -- err < 0 significa acima do alvo → pitch "down" → PitchRamp negativo
            -- Dividido por 200 (mais sensível) com clamp pra não travar o avião
            pitchTarget = math.clamp(err / 200, -0.4, 0.4)
        end
    end

    local maxDelta       = PITCH_MULT / PilotConfig.RampTime * dt
    PilotState.PitchRamp = ramp(PilotState.PitchRamp, pitchTarget * PITCH_MULT, maxDelta)

    local remote = findRemote()
    if not remote then return end

    -- "up" = nose up = sobe, "down" = nose down = desce
    -- PitchRamp > 0 quando err > 0 (abaixo do alvo) → sobe ✓
    -- PitchRamp < 0 quando err < 0 (acima do alvo) → desce ✓
    if math.abs(PilotState.PitchRamp) > 0.01 then
        local dir = PilotState.PitchRamp > 0 and "up" or "down"
        remote:FireServer("pitch", dir, math.abs(PilotState.PitchRamp) * dt)
    end
end

-- ==================== TABS ====================
local MainTab     = Window:Tab({ Title = "Main",        Icon = "user" })
local TasksTab    = Window:Tab({ Title = "Auto Tasks",  Icon = "list-checks" })
local ExploitsTab = Window:Tab({ Title = "Exploits",    Icon = "sword" })
local ShopTab     = Window:Tab({ Title = "Shop",        Icon = "shopping-cart" })
local CrateTab    = Window:Tab({ Title = "Auto Crate",  Icon = "package" })
local AirplaneTab = Window:Tab({ Title = "Airplane",    Icon = "plane" })
local DiscordTab  = Window:Tab({ Title = "Discord",     Icon = "message-circle" })

-- ==================== MAIN ====================

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

-- ==================== AUTO TASKS ====================

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

-- ==================== EXPLOITS ====================

ExploitsTab:Button({
    Title = "free plane op idk",
    Callback = function()
        pcall(function()
            local Event = game:GetService("ReplicatedStorage").Remotes.PlaneRemote
            Event:FireServer("equip_plane", "tungtung")
        end)
        WindUI:Notify({ Title = "Exploit", Content = "Best plane equipped!", Icon = "zap", Duration = 3 })
    end,
})

-- ==================== SHOP ====================

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
    if #AvailableTools == 0 then table.insert(AvailableTools, "No tools found") end
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
            WindUI:Notify({ Title = "Purchase", Content = "Attempted to buy: " .. tostring(Value), Icon = "shopping-cart", Duration = 3 })
        end
    end,
})

ShopTab:Button({
    Title = "Refresh Tool List",
    Callback = function()
        BuyDropdown:Refresh(GetAvailableTools())
        WindUI:Notify({ Title = "Refreshed", Content = "Tool list updated!", Icon = "refresh-cw", Duration = 2 })
    end,
})

-- ==================== AUTO CRATE ====================

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

-- ==================== AIRPLANE (AI PILOT) ====================

AirplaneTab:Toggle({
    Title = "AI Pilot",
    Value = false,
    Callback = function(Value)
        PilotConfig.PilotEnabled = Value
        if Value then
            PilotState.CurrentAlt   = getAltitude()
            PilotState.TargetAlt    = PilotState.CurrentAlt
            PilotState.PitchRamp    = 0
            PilotState.Evading      = false
            PilotState.EvasionTimer = 0
            PilotState.EvasionDir   = 0
            if PilotState.Conn then PilotState.Conn:Disconnect() end
            PilotState.Conn = RunService.RenderStepped:Connect(onStep)
            WindUI:Notify({ Title = "AI Pilot", Content = "ON — Alt alvo: " .. math.floor(PilotState.TargetAlt), Icon = "plane", Duration = 3 })
        else
            if PilotState.Conn then PilotState.Conn:Disconnect() PilotState.Conn = nil end
            WindUI:Notify({ Title = "AI Pilot", Content = "OFF", Icon = "plane", Duration = 3 })
        end
    end,
})

AirplaneTab:Toggle({
    Title = "Warn Collision",
    Value = false,
    Callback = function(Value) PilotConfig.WarnCollision = Value end,
})

AirplaneTab:Button({
    Title = "Reset Target Altitude",
    Callback = function()
        PilotState.TargetAlt = getAltitude()
        WindUI:Notify({ Title = "AI Pilot", Content = "Alt alvo: " .. math.floor(PilotState.TargetAlt), Icon = "check-circle", Duration = 3 })
    end,
})

AirplaneTab:Slider({
    Title = "Evasion Strength",
    Value = { Default = 1.0, Min = 0.1, Max = 1.0 },
    Step = 0.05,
    Callback = function(Value) PilotConfig.EvasionStrength = Value end,
})

AirplaneTab:Slider({
    Title = "Evasion Duration",
    Value = { Default = 1.8, Min = 0.5, Max = 5.0 },
    Step = 0.1,
    Callback = function(Value) PilotConfig.EvasionDuration = Value end,
})

AirplaneTab:Slider({
    Title = "Max Evade Altitude",
    Value = { Default = 10000, Min = 5000, Max = 20000 },
    Step = 500,
    Callback = function(Value) PilotConfig.AltMax = Value end,
})

AirplaneTab:Slider({
    Title = "Min Evade Altitude",
    Value = { Default = 3000, Min = 500, Max = 5000 },
    Step = 100,
    Callback = function(Value) PilotConfig.AltMin = Value end,
})

AirplaneTab:Slider({
    Title = "Stabilization Strength",
    Value = { Default = 0.25, Min = 0.05, Max = 1.0 },
    Step = 0.05,
    Callback = function(Value) PilotConfig.StabStrength = Value end,
})

AirplaneTab:Slider({
    Title = "Evasion Trigger Distance",
    Value = { Default = 800, Min = 100, Max = 3000 },
    Step = 50,
    Callback = function(Value) PilotConfig.EvasionMinDist = Value end,
})

-- ==================== DISCORD ====================

DiscordTab:Button({
    Title = "Copy Invite",
    Callback = function()
        pcall(function()
            if setclipboard then setclipboard("https://discord.gg/d2MQ98N47u") end
        end)
        WindUI:Notify({ Title = "Discord", Content = "Invite copied to clipboard!", Icon = "copy", Duration = 3 })
    end,
})

-- ==================== TROLL ====================
local TrollTab = Window:Tab({ Title = "Troll", Icon = "zap" })

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

-- ==================== LOADED ====================
WindUI:Notify({
    Title = "XXMZ Loaded",
    Content = "Script loaded successfully!",
    Icon = "check-circle",
    Duration = 5,
})
