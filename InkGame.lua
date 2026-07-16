local Fluent = loadstring(game:HttpGet(
    "https://github.com/StyearX/Fluent-Modded/releases/download/Fluent/FluentPro"
))()

-- ============================================
-- SERVICES & VARIABLES
-- ============================================
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ============================================
-- WINDOW
-- ============================================
local Window = Fluent:CreateWindow({
    Title       = "XXMZ HUB | INK GAME",
    SubTitle    = "by 29",
    TitleIcon   = "rbxassetid://134886947410499",
    TabWidth    = 200,
    Size        = UDim2.fromOffset(600, 500),
    Acrylic     = true,
    Theme       = "AMOLED",
    MinimizeKey = Enum.KeyCode.RightShift,
    Search      = true,
    Font        = "RobotoMono",
})

local Tabs = {
    Main   = Window:AddTab({ Title = "Main",   Icon = "solar/home-bold" }),
    Player = Window:AddTab({ Title = "Player", Icon = "solar/user-bold" }),
    Combat = Window:AddTab({ Title = "Combat", Icon = "solar/sword-bold" }),
    ESPs   = Window:AddTab({ Title = "ESPs",   Icon = "solar/eye-bold" }),
    Teleport = Window:AddTab({ Title = "Teleport", Icon = "solar/map-point-bold" }),
    GreenLightRedLight = Window:AddTab({ Title = "Green Light, Red Light", Icon = "solar/play-circle-bold" }),
    GlassBridge = Window:AddTab({ Title = "Glass Bridge", Icon = "solar/danger-square-bold" }),
    HideAndSeek = Window:AddTab({ Title = "Hide And Seek", Icon = "solar/magnifer-bold" }),
    Rebel  = Window:AddTab({ Title = "Rebel",  Icon = "solar/shield-bold" }),
    JumpRope = Window:AddTab({ Title = "Jump Rope", Icon = "solar/activity-bold" }),
}

local Options = Fluent.Options

-- ============================================
-- INSTANT PROXIMITY PROMPT
-- ============================================
local InstantPrompt = {
    Enabled = false,
    Prompts = {},
    DescendantAddedConnection = nil
}

local function ProcessPrompt(prompt)
    if not prompt:IsA("ProximityPrompt") then return end
    if InstantPrompt.Prompts[prompt] then return end
    InstantPrompt.Prompts[prompt] = prompt.HoldDuration
    prompt.HoldDuration = 0
end

local function ScanExistingPrompts()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            ProcessPrompt(obj)
        end
    end
end

local function StartInstantPrompt()
    if InstantPrompt.DescendantAddedConnection then return end
    ScanExistingPrompts()
    InstantPrompt.DescendantAddedConnection = workspace.DescendantAdded:Connect(function(descendant)
        if descendant:IsA("ProximityPrompt") then
            ProcessPrompt(descendant)
        end
    end)
end

local function StopInstantPrompt()
    if InstantPrompt.DescendantAddedConnection then
        InstantPrompt.DescendantAddedConnection:Disconnect()
        InstantPrompt.DescendantAddedConnection = nil
    end
    for prompt, originalDuration in pairs(InstantPrompt.Prompts) do
        if prompt then
            prompt.HoldDuration = originalDuration
        end
    end
    InstantPrompt.Prompts = {}
end

-- ============================================
-- HIDE AND SEEK CHECK
-- ============================================
local function IsHideAndSeekActive()
    local liveFolder = workspace:FindFirstChild("Live")
    if not liveFolder then return false end
    local playerFolder = liveFolder:FindFirstChild(LocalPlayer.Name)
    if not playerFolder then return false end
    return playerFolder:FindFirstChild("PlayingHideAndSeek") ~= nil
end

-- ============================================
-- LOCK ON SYSTEM
-- ============================================
local LockOn = {
    Enabled = false,
    Target = nil,
    Connection = nil,
    Distance = 20,
    FocusMode = false,
    FocusedPlayer = nil,
    FocusLabel = nil
}

local function W2S(pos)
    local v, onScreen = Camera:WorldToViewportPoint(pos)
    return Vector2.new(v.X, v.Y), v.Z, onScreen
end

local function GetNearestPlayer()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end
    local hrp = character.HumanoidRootPart
    local nearestTarget = nil
    local nearestDistance = math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
            if targetHRP then
                local distance = (targetHRP.Position - hrp.Position).Magnitude
                if distance < nearestDistance and distance <= LockOn.Distance then
                    nearestDistance = distance
                    nearestTarget = player.Character
                end
            end
        end
    end
    return nearestTarget
end

local function GetPlayerInView()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end
    local mousePos = UserInputService:GetMouseLocation()
    local closestTarget = nil
    local closestDistance = math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
            if targetHRP then
                local targetPos = targetHRP.Position
                local screenPos, depth, onScreen = W2S(targetPos)
                if onScreen and depth > 0 then
                    local distance = (Vector2.new(mousePos.X, mousePos.Y) - screenPos).Magnitude
                    if distance < closestDistance and distance < 200 then
                        closestDistance = distance
                        closestTarget = player.Character
                    end
                end
            end
        end
    end
    return closestTarget
end

local function StartLockOn()
    if LockOn.Connection then return end
    LockOn.Connection = RunService.RenderStepped:Connect(function()
        if not LockOn.Enabled then return end
        local character = LocalPlayer.Character
        if not character or not character:FindFirstChild("HumanoidRootPart") then return end
        local target = nil
        if LockOn.FocusMode and LockOn.FocusedPlayer and LockOn.FocusedPlayer.Parent then
            target = LockOn.FocusedPlayer
        else
            target = GetNearestPlayer()
        end
        if target and target:FindFirstChild("HumanoidRootPart") then
            local hrp = character.HumanoidRootPart
            local targetHRP = target.HumanoidRootPart
            local lookVector = (targetHRP.Position - hrp.Position).Unit
            hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + Vector3.new(lookVector.X, 0, lookVector.Z))
            if LockOn.FocusMode and LockOn.FocusLabel then
                local screenPos, depth, onScreen = W2S(targetHRP.Position)
                if onScreen and depth > 0 then
                    LockOn.FocusLabel.Position = Vector2.new(screenPos.X, screenPos.Y - 50)
                    LockOn.FocusLabel.Visible = true
                else
                    LockOn.FocusLabel.Visible = false
                end
            end
        elseif LockOn.FocusLabel then
            LockOn.FocusLabel.Visible = false
        end
    end)
end

local function StopLockOn()
    if LockOn.Connection then
        LockOn.Connection:Disconnect()
        LockOn.Connection = nil
    end
    if LockOn.FocusLabel then
        LockOn.FocusLabel.Visible = false
    end
end

local function ToggleFocusPlayer()
    if not LockOn.FocusMode then
        local target = GetPlayerInView()
        if target then
            LockOn.FocusMode = true
            LockOn.FocusedPlayer = target
            if not LockOn.FocusLabel then
                LockOn.FocusLabel = Drawing.new("Text")
                LockOn.FocusLabel.Text = "FOCUSED"
                LockOn.FocusLabel.Size = 16
                LockOn.FocusLabel.Color = Color3.fromRGB(255, 255, 0)
                LockOn.FocusLabel.Outline = true
                LockOn.FocusLabel.Center = true
                LockOn.FocusLabel.Font = Drawing.Fonts.Monospace
            end
            Fluent:Notify({ Title = "Focus Player", Content = "Locked onto " .. target.Name, Duration = 3 })
        end
    else
        LockOn.FocusMode = false
        LockOn.FocusedPlayer = nil
        if LockOn.FocusLabel then
            LockOn.FocusLabel.Visible = false
        end
        Fluent:Notify({ Title = "Focus Player", Content = "Unlocked", Duration = 3 })
    end
end

-- ============================================
-- SPEED BOOST SYSTEM
-- ============================================
local SpeedBoost = {
    Enabled = false,
    DefaultWalkSpeed = 16,
    BoostedWalkSpeed = 50,
    Connection = nil
}

local function StartSpeedBoostLoop()
    if SpeedBoost.Connection then
        SpeedBoost.Connection:Disconnect()
        SpeedBoost.Connection = nil
    end
    SpeedBoost.Connection = RunService.Heartbeat:Connect(function()
        if not SpeedBoost.Enabled then return end
        local character = LocalPlayer.Character
        if not character then return end
        local humanoid = character:FindFirstChild("Humanoid")
        if not humanoid then return end
        if humanoid.WalkSpeed ~= SpeedBoost.BoostedWalkSpeed then
            humanoid.WalkSpeed = SpeedBoost.BoostedWalkSpeed
        end
    end)
end

local function StopSpeedBoostLoop()
    if SpeedBoost.Connection then
        SpeedBoost.Connection:Disconnect()
        SpeedBoost.Connection = nil
    end
    local character = LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = SpeedBoost.DefaultWalkSpeed
        end
    end
end

-- ============================================
-- SAFE SPOT TELEPORT
-- ============================================
local SafeSpotPosition = CFrame.new(-224, 328, 409)

local function TeleportToSafeSpot()
    local character = LocalPlayer.Character
    if not character then
        Fluent:Notify({ Title = "Safe Spot", Content = "Character not found!", Duration = 3 })
        return
    end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then
        Fluent:Notify({ Title = "Safe Spot", Content = "HumanoidRootPart not found!", Duration = 3 })
        return
    end
    hrp.CFrame = SafeSpotPosition
    Fluent:Notify({ Title = "Safe Spot", Content = "Teleported to safe position!", Duration = 3 })
end

-- ============================================
-- NORMAL PLAYER ESP
-- ============================================
local NormalPlayerESP = {
    Enabled = false,
    Highlights = {},
    Labels = {},
    Connection = nil,
    PlayerAddedConnection = nil,
    PlayerRemovingConnection = nil
}

local function GetPlayerFromCharacter(character)
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character == character then
            return player
        end
    end
    return nil
end

local function IsGuard(player)
    local liveFolder = workspace:FindFirstChild("Live")
    if not liveFolder then return false end
    local playerFolder = liveFolder:FindFirstChild(player.Name)
    if not playerFolder then return false end
    return playerFolder:FindFirstChild("StoringFold") ~= nil
end

local function GetNormalESPColors(player)
    local isGuard = IsGuard(player)
    if isGuard then
        return {
            fillColor = Color3.fromRGB(255, 105, 180),
            outlineColor = Color3.fromRGB(255, 20, 147),
            textColor = Color3.fromRGB(255, 105, 180),
            fillTransparency = 0.5
        }
    else
        return {
            fillColor = Color3.fromRGB(255, 255, 255),
            outlineColor = Color3.fromRGB(200, 200, 200),
            textColor = Color3.fromRGB(255, 255, 255),
            fillTransparency = 0.7
        }
    end
end

local function CreateNormalPlayerESP(character)
    if character == LocalPlayer.Character then return end
    local player = GetPlayerFromCharacter(character)
    if not player then return end
    if NormalPlayerESP.Highlights[character] then
        NormalPlayerESP.Highlights[character]:Destroy()
        NormalPlayerESP.Highlights[character] = nil
    end
    if NormalPlayerESP.Labels[character] then
        NormalPlayerESP.Labels[character]:Remove()
        NormalPlayerESP.Labels[character] = nil
    end
    local colors = GetNormalESPColors(player)
    local highlight = Instance.new("Highlight")
    highlight.Name = "XXMZ_NormalPlayerESP"
    highlight.FillColor = colors.fillColor
    highlight.FillTransparency = colors.fillTransparency
    highlight.OutlineColor = colors.outlineColor
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Adornee = character
    highlight.Parent = character
    NormalPlayerESP.Highlights[character] = highlight
    local label = Drawing.new("Text")
    label.Size = 14
    label.Outline = true
    label.Center = true
    label.Font = Drawing.Fonts.Monospace
    label.Color = colors.textColor
    label.Visible = false
    NormalPlayerESP.Labels[character] = label
end

local function RemoveNormalPlayerESP(character)
    if NormalPlayerESP.Highlights[character] then
        NormalPlayerESP.Highlights[character]:Destroy()
        NormalPlayerESP.Highlights[character] = nil
    end
    if NormalPlayerESP.Labels[character] then
        NormalPlayerESP.Labels[character]:Remove()
        NormalPlayerESP.Labels[character] = nil
    end
end

local function UpdateNormalPlayerESP()
    if not NormalPlayerESP.Enabled then return end
    for character, label in pairs(NormalPlayerESP.Labels) do
        if not character or not character.Parent then
            RemoveNormalPlayerESP(character)
        else
            local head = character:FindFirstChild("Head")
            if head then
                local pos, onScreen = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 1.5, 0))
                if onScreen then
                    local player = GetPlayerFromCharacter(character)
                    if player then
                        local displayName = player.DisplayName or player.Name
                        local username = player.Name
                        local isGuard = IsGuard(player)
                        local guardTag = isGuard and " [GUARD]" or ""
                        label.Text = displayName .. guardTag .. " (@" .. username .. ")"
                        label.Position = Vector2.new(pos.X, pos.Y)
                        label.Visible = true
                        local colors = GetNormalESPColors(player)
                        label.Color = colors.textColor
                        if NormalPlayerESP.Highlights[character] then
                            NormalPlayerESP.Highlights[character].FillColor = colors.fillColor
                            NormalPlayerESP.Highlights[character].OutlineColor = colors.outlineColor
                        end
                    else
                        label.Visible = false
                    end
                else
                    label.Visible = false
                end
            else
                label.Visible = false
            end
        end
    end
end

local function StartNormalPlayerESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            CreateNormalPlayerESP(player.Character)
        end
    end
    if NormalPlayerESP.Connection then
        NormalPlayerESP.Connection:Disconnect()
    end
    NormalPlayerESP.Connection = RunService.RenderStepped:Connect(UpdateNormalPlayerESP)
    NormalPlayerESP.PlayerAddedConnection = Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(character)
            if NormalPlayerESP.Enabled then
                task.wait(0.5)
                CreateNormalPlayerESP(character)
            end
        end)
        if player.Character and NormalPlayerESP.Enabled then
            CreateNormalPlayerESP(player.Character)
        end
    end)
    NormalPlayerESP.PlayerRemovingConnection = Players.PlayerRemoving:Connect(function(player)
        if player.Character then
            RemoveNormalPlayerESP(player.Character)
        end
    end)
end

local function StopNormalPlayerESP()
    if NormalPlayerESP.Connection then
        NormalPlayerESP.Connection:Disconnect()
        NormalPlayerESP.Connection = nil
    end
    if NormalPlayerESP.PlayerAddedConnection then
        NormalPlayerESP.PlayerAddedConnection:Disconnect()
        NormalPlayerESP.PlayerAddedConnection = nil
    end
    if NormalPlayerESP.PlayerRemovingConnection then
        NormalPlayerESP.PlayerRemovingConnection:Disconnect()
        NormalPlayerESP.PlayerRemovingConnection = nil
    end
    for character, _ in pairs(NormalPlayerESP.Highlights) do
        RemoveNormalPlayerESP(character)
    end
    NormalPlayerESP.Highlights = {}
    NormalPlayerESP.Labels = {}
end

-- ============================================
-- HIDE AND SEEK ESP
-- ============================================
local HideAndSeekESP = {
    Enabled = false,
    Highlights = {},
    Labels = {},
    Connection = nil,
    PlayerAddedConnection = nil,
    PlayerRemovingConnection = nil
}

local function HasKnife(player)
    if player.Character then
        if player.Character:FindFirstChild("Knife") then return true end
    end
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        if backpack:FindFirstChild("Knife") then return true end
    end
    return false
end

local function GetHideAndSeekESPColors(player)
    local hasKnife = HasKnife(player)
    if hasKnife then
        return {
            fillColor = Color3.fromRGB(255, 0, 0),
            outlineColor = Color3.fromRGB(200, 0, 0),
            textColor = Color3.fromRGB(255, 0, 0),
            fillTransparency = 0.5
        }
    else
        return {
            fillColor = Color3.fromRGB(0, 100, 255),
            outlineColor = Color3.fromRGB(0, 80, 200),
            textColor = Color3.fromRGB(0, 150, 255),
            fillTransparency = 0.7
        }
    end
end

local function CreateHideAndSeekESP(character)
    if character == LocalPlayer.Character then return end
    local player = GetPlayerFromCharacter(character)
    if not player then return end
    if HideAndSeekESP.Highlights[character] then
        HideAndSeekESP.Highlights[character]:Destroy()
        HideAndSeekESP.Highlights[character] = nil
    end
    if HideAndSeekESP.Labels[character] then
        HideAndSeekESP.Labels[character]:Remove()
        HideAndSeekESP.Labels[character] = nil
    end
    local colors = GetHideAndSeekESPColors(player)
    local highlight = Instance.new("Highlight")
    highlight.Name = "XXMZ_HideAndSeekESP"
    highlight.FillColor = colors.fillColor
    highlight.FillTransparency = colors.fillTransparency
    highlight.OutlineColor = colors.outlineColor
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Adornee = character
    highlight.Parent = character
    HideAndSeekESP.Highlights[character] = highlight
    local label = Drawing.new("Text")
    label.Size = 14
    label.Outline = true
    label.Center = true
    label.Font = Drawing.Fonts.Monospace
    label.Color = colors.textColor
    label.Visible = false
    HideAndSeekESP.Labels[character] = label
end

local function RemoveHideAndSeekESP(character)
    if HideAndSeekESP.Highlights[character] then
        HideAndSeekESP.Highlights[character]:Destroy()
        HideAndSeekESP.Highlights[character] = nil
    end
    if HideAndSeekESP.Labels[character] then
        HideAndSeekESP.Labels[character]:Remove()
        HideAndSeekESP.Labels[character] = nil
    end
end

local function UpdateHideAndSeekESP()
    if not HideAndSeekESP.Enabled then return end
    for character, label in pairs(HideAndSeekESP.Labels) do
        if not character or not character.Parent then
            RemoveHideAndSeekESP(character)
        else
            local head = character:FindFirstChild("Head")
            if head then
                local pos, onScreen = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 1.5, 0))
                if onScreen then
                    local player = GetPlayerFromCharacter(character)
                    if player then
                        local displayName = player.DisplayName or player.Name
                        local username = player.Name
                        local hasKnife = HasKnife(player)
                        local knifeTag = hasKnife and " [KNIFE]" or ""
                        label.Text = displayName .. knifeTag .. " (@" .. username .. ")"
                        label.Position = Vector2.new(pos.X, pos.Y)
                        label.Visible = true
                        local colors = GetHideAndSeekESPColors(player)
                        label.Color = colors.textColor
                        if HideAndSeekESP.Highlights[character] then
                            HideAndSeekESP.Highlights[character].FillColor = colors.fillColor
                            HideAndSeekESP.Highlights[character].OutlineColor = colors.outlineColor
                        end
                    else
                        label.Visible = false
                    end
                else
                    label.Visible = false
                end
            else
                label.Visible = false
            end
        end
    end
end

local function StartHideAndSeekESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            CreateHideAndSeekESP(player.Character)
        end
    end
    if HideAndSeekESP.Connection then
        HideAndSeekESP.Connection:Disconnect()
    end
    HideAndSeekESP.Connection = RunService.RenderStepped:Connect(UpdateHideAndSeekESP)
    HideAndSeekESP.PlayerAddedConnection = Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(character)
            if HideAndSeekESP.Enabled then
                task.wait(0.5)
                CreateHideAndSeekESP(character)
            end
        end)
        if player.Character and HideAndSeekESP.Enabled then
            CreateHideAndSeekESP(player.Character)
        end
    end)
    HideAndSeekESP.PlayerRemovingConnection = Players.PlayerRemoving:Connect(function(player)
        if player.Character then
            RemoveHideAndSeekESP(player.Character)
        end
    end)
end

local function StopHideAndSeekESP()
    if HideAndSeekESP.Connection then
        HideAndSeekESP.Connection:Disconnect()
        HideAndSeekESP.Connection = nil
    end
    if HideAndSeekESP.PlayerAddedConnection then
        HideAndSeekESP.PlayerAddedConnection:Disconnect()
        HideAndSeekESP.PlayerAddedConnection = nil
    end
    if HideAndSeekESP.PlayerRemovingConnection then
        HideAndSeekESP.PlayerRemovingConnection:Disconnect()
        HideAndSeekESP.PlayerRemovingConnection = nil
    end
    for character, _ in pairs(HideAndSeekESP.Highlights) do
        RemoveHideAndSeekESP(character)
    end
    HideAndSeekESP.Highlights = {}
    HideAndSeekESP.Labels = {}
end

-- ============================================
-- TELEPORT SYSTEM
-- ============================================
local function TeleportToNewPlayers()
    local placeId = 119099244949868
    Fluent:Notify({ Title = "Teleport", Content = "Teleporting to New Players Server...", Duration = 3 })
    task.wait(1)
    pcall(function()
        TeleportService:Teleport(placeId, LocalPlayer)
    end)
end

-- ============================================
-- GREEN LIGHT, RED LIGHT SYSTEM
-- ============================================
local GLRL = {
    AntiDetectEnabled = false,
    Connection = nil
}

local function RemoveInjuredAndStun()
    local liveFolder = workspace:FindFirstChild("Live")
    if not liveFolder then return end
    local playerFolder = liveFolder:FindFirstChild(LocalPlayer.Name)
    if not playerFolder then return end
    local injured = playerFolder:FindFirstChild("InjuredWalking")
    if injured then
        injured:Destroy()
    end
    local stun = playerFolder:FindFirstChild("Stun")
    if stun then
        stun:Destroy()
    end
end

local function StartAntiDetect()
    if GLRL.Connection then
        GLRL.Connection:Disconnect()
        GLRL.Connection = nil
    end
    GLRL.Connection = RunService.Heartbeat:Connect(function()
        if not GLRL.AntiDetectEnabled then return end
        RemoveInjuredAndStun()
    end)
end

local function StopAntiDetect()
    if GLRL.Connection then
        GLRL.Connection:Disconnect()
        GLRL.Connection = nil
    end
end

local function TeleportToEnd()
    local character = LocalPlayer.Character
    if not character then
        Fluent:Notify({ Title = "Teleport", Content = "Character not found!", Duration = 3 })
        return
    end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then
        Fluent:Notify({ Title = "Teleport", Content = "HumanoidRootPart not found!", Duration = 3 })
        return
    end
    hrp.CFrame = CFrame.new(-45, 1025, 135)
    Fluent:Notify({ Title = "Teleport", Content = "Teleported to the end! (-45, 1025, 135)", Duration = 3 })
end

-- ============================================
-- GLASS BRIDGE SYSTEM
-- ============================================
local function RevealGlass()
    local GlassBridge = workspace:FindFirstChild("GlassBridge")
    if not GlassBridge then
        Fluent:Notify({ Title = "Glass Bridge", Content = "GlassBridge not found in workspace!", Duration = 3 })
        return
    end
    local GlassHolder = GlassBridge:FindFirstChild("GlassHolder")
    if not GlassHolder then
        Fluent:Notify({ Title = "Glass Bridge", Content = "GlassHolder not found!", Duration = 3 })
        return
    end
    for _, descendant in pairs(GlassHolder:GetDescendants()) do
        if descendant.Name == "BlossomPlatform" then
            descendant:Destroy()
        end
    end
    local revealedCount = 0
    for _, glassPane in pairs(GlassHolder:GetChildren()) do
        local paneChildren = glassPane:GetChildren()
        for _, pane in pairs(paneChildren) do
            if pane:IsA("Model") and pane.PrimaryPart then
                local primaryPart = pane.PrimaryPart
                local isBreakable = primaryPart:GetAttribute("exploitingisevil")
                if isBreakable then
                    primaryPart.Color = Color3.fromRGB(248, 87, 87)
                    primaryPart.Transparency = 0
                    primaryPart.Material = Enum.Material.Neon
                    local platform = Instance.new("Part")
                    platform.Name = "BlossomPlatform"
                    platform.Size = primaryPart.Size
                    platform.CFrame = primaryPart.CFrame + Vector3.new(0, 2, 0)
                    platform.Anchored = true
                    platform.CanCollide = true
                    platform.Transparency = 0.5
                    platform.Color = Color3.fromRGB(255, 255, 255)
                    platform.Material = Enum.Material.Glass
                    platform.Parent = GlassHolder
                else
                    primaryPart.Color = Color3.fromRGB(28, 235, 87)
                    primaryPart.Transparency = 0
                    primaryPart.Material = Enum.Material.Neon
                end
                revealedCount = revealedCount + 1
            end
        end
    end
    Fluent:Notify({ Title = "Glass Bridge", Content = "Revealed " .. revealedCount .. " glass panes! Red = Break, Green = Safe", Duration = 5 })
end

-- ============================================
-- REBEL SYSTEM
-- ============================================
local Rebel = {
    Enabled = false,
    Connection = nil
}

local GuardNames = {
    "RebelGuard",
    "GuardDoesntAggroTillLOSCantMoveHigherRange",
    "HallwayGuard",
    "FinalRebel",
    "RebelFirstWave",
    "RebelThird"
}

local function BringGuards()
    local liveFolder = workspace:FindFirstChild("Live")
    if not liveFolder then return end
    local character = LocalPlayer.Character
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local targetPos = hrp.Position + hrp.CFrame.LookVector * 20
    for _, guardName in ipairs(GuardNames) do
        for _, obj in pairs(liveFolder:GetChildren()) do
            if string.find(obj.Name, guardName) then
                local targetPart = nil
                if obj:IsA("Model") then
                    if obj.PrimaryPart then
                        targetPart = obj.PrimaryPart
                    else
                        targetPart = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")
                    end
                elseif obj:IsA("BasePart") then
                    targetPart = obj
                end
                if targetPart then
                    if obj:IsA("Model") then
                        obj:PivotTo(CFrame.new(targetPos, hrp.Position))
                    else
                        targetPart.CFrame = CFrame.new(targetPos, hrp.Position)
                    end
                end
            end
        end
    end
end

local function StartBringGuardsLoop()
    if Rebel.Connection then
        Rebel.Connection:Disconnect()
        Rebel.Connection = nil
    end
    Rebel.Connection = RunService.Heartbeat:Connect(function()
        if not Rebel.Enabled then return end
        BringGuards()
    end)
end

local function StopBringGuardsLoop()
    if Rebel.Connection then
        Rebel.Connection:Disconnect()
        Rebel.Connection = nil
    end
end

-- ============================================
-- JUMP ROPE SYSTEM
-- ============================================
local function DeleteRope()
    local jumpRope = workspace:FindFirstChild("JumpRope")
    if not jumpRope then
        Fluent:Notify({ Title = "Jump Rope", Content = "JumpRope not found in workspace!", Duration = 3 })
        return
    end
    local important = jumpRope:FindFirstChild("Important")
    if not important then
        Fluent:Notify({ Title = "Jump Rope", Content = "Important folder not found!", Duration = 3 })
        return
    end
    local rope = important:FindFirstChild("rope")
    if not rope then
        Fluent:Notify({ Title = "Jump Rope", Content = "rope not found in Important!", Duration = 3 })
        return
    end
    rope:Destroy()
    Fluent:Notify({ Title = "Jump Rope", Content = "Rope deleted successfully!", Duration = 3 })
end

-- ============================================
-- TESTING FEATURE (Auto-delete Anchor)
-- ============================================
local TestingFeature = {
    Enabled = false,
    Connection = nil
}

local function DeleteAnchor()
    local live = workspace:FindFirstChild("Live")
    if not live then return end
    local playerFolder = live:FindFirstChild("hesaidimsigma11")
    if not playerFolder then return end
    local anchor = playerFolder:FindFirstChild("Anchor")
    if anchor then
        anchor:Destroy()
    end
end

local function StartTestingFeature()
    if TestingFeature.Connection then return end
    DeleteAnchor()
    TestingFeature.Connection = workspace.DescendantAdded:Connect(function(descendant)
        if not TestingFeature.Enabled then return end
        if descendant.Name == "Anchor" and descendant.Parent and descendant.Parent.Name == "hesaidimsigma11" then
            task.wait(0.05)
            if descendant and descendant.Parent then
                descendant:Destroy()
            end
        end
    end)
end

local function StopTestingFeature()
    if TestingFeature.Connection then
        TestingFeature.Connection:Disconnect()
        TestingFeature.Connection = nil
    end
end

-- ============================================
-- UI - MAIN TAB
-- ============================================
Tabs.Main:AddToggle("InstantPrompt", {
    Title    = "Instant Proximity Prompt",
    Icon     = "solar/shield-bold",
    Default  = false,
    Callback = function(value)
        InstantPrompt.Enabled = value
        if InstantPrompt.Enabled then
            StartInstantPrompt()
            Fluent:Notify({ Title = "Instant Prompt", Content = "Activated!", Duration = 3 })
        else
            StopInstantPrompt()
            Fluent:Notify({ Title = "Instant Prompt", Content = "Deactivated!", Duration = 3 })
        end
    end,
})

Tabs.Main:AddToggle("TestingFeature", {
    Title    = "Testing Feature",
    Icon     = "solar/bug-bold",
    Default  = false,
    Callback = function(value)
        TestingFeature.Enabled = value
        if TestingFeature.Enabled then
            StartTestingFeature()
            Fluent:Notify({ Title = "Testing Feature", Content = "Auto-delete Anchor activated!", Duration = 3 })
        else
            StopTestingFeature()
            Fluent:Notify({ Title = "Testing Feature", Content = "Auto-delete Anchor deactivated!", Duration = 3 })
        end
    end,
})

-- ============================================
-- UI - PLAYER TAB
-- ============================================
Tabs.Player:AddToggle("SpeedBoost", {
    Title    = "Speed Boost",
    Icon     = "solar/speed-bold",
    Default  = false,
    Callback = function(value)
        SpeedBoost.Enabled = value
        if SpeedBoost.Enabled then
            StartSpeedBoostLoop()
        else
            StopSpeedBoostLoop()
        end
    end,
})

Tabs.Player:AddSlider("SpeedBoostValue", {
    Title    = "Boost Speed",
    Icon     = "solar/speed-bold",
    Default  = 50,
    Min      = 16,
    Max      = 150,
    Rounding = 0,
    Callback = function(value)
        SpeedBoost.BoostedWalkSpeed = value
        if SpeedBoost.Enabled then
            local character = LocalPlayer.Character
            if character then
                local humanoid = character:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = value
                end
            end
        end
    end,
})

Tabs.Player:AddButton({
    Title    = "Safe Spot",
    Icon     = "solar/map-point-bold",
    Callback = function()
        TeleportToSafeSpot()
    end,
})

-- ============================================
-- UI - COMBAT TAB
-- ============================================
Tabs.Combat:AddToggle("LockOn", {
    Title    = "Lock On (Nearest Player)",
    Icon     = "solar/target-bold",
    Default  = false,
    Callback = function(value)
        LockOn.Enabled = value
        if LockOn.Enabled then
            StartLockOn()
        else
            StopLockOn()
        end
    end,
})

Tabs.Combat:AddToggle("FocusPlayer", {
    Title    = "Focus Player (Mouse Target)",
    Icon     = "solar/crosshair-bold",
    Default  = false,
    Callback = function(value)
        if value then
            ToggleFocusPlayer()
        else
            LockOn.FocusMode = false
            LockOn.FocusedPlayer = nil
            if LockOn.FocusLabel then
                LockOn.FocusLabel.Visible = false
            end
            Fluent:Notify({ Title = "Focus Player", Content = "Unlocked", Duration = 3 })
        end
    end,
})

Tabs.Combat:AddSlider("LockOnDistance", {
    Title    = "Lock On Distance",
    Icon     = "solar/ruler-bold",
    Default  = 20,
    Min      = 5,
    Max      = 100,
    Rounding = 0,
    Callback = function(value)
        LockOn.Distance = value
    end,
})

-- ============================================
-- BALLOON ESP (workspace.Effects)
-- ============================================
local BalloonESP = {
    Enabled = false,
    Highlights = {},
    Labels = {},
    Connection = nil,
    DescendantAddedConnection = nil,
    DescendantRemovingConnection = nil
}

local function CreateBalloonESP(balloon)
    if not balloon or not balloon:IsA("Model") then return end
    if BalloonESP.Highlights[balloon] then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "XXMZ_BalloonESP"
    highlight.FillColor = Color3.fromRGB(255, 255, 0)
    highlight.FillTransparency = 0.3
    highlight.OutlineColor = Color3.fromRGB(255, 200, 0)
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Adornee = balloon
    highlight.Parent = balloon
    BalloonESP.Highlights[balloon] = highlight

    local label = Drawing.new("Text")
    label.Size = 14
    label.Outline = true
    label.Center = true
    label.Font = Drawing.Fonts.Monospace
    label.Color = Color3.fromRGB(255, 255, 0)
    label.Text = "BALLOON"
    label.Visible = false
    BalloonESP.Labels[balloon] = label
end

local function RemoveBalloonESP(balloon)
    if BalloonESP.Highlights[balloon] then
        BalloonESP.Highlights[balloon]:Destroy()
        BalloonESP.Highlights[balloon] = nil
    end
    if BalloonESP.Labels[balloon] then
        BalloonESP.Labels[balloon]:Remove()
        BalloonESP.Labels[balloon] = nil
    end
end

local function ScanExistingBalloons()
    local effects = workspace:FindFirstChild("Effects")
    if not effects then return end
    for _, obj in pairs(effects:GetDescendants()) do
        if obj:IsA("Model") and obj.Name == "Balloon" then
            CreateBalloonESP(obj)
        end
    end
end

local function UpdateBalloonESP()
    if not BalloonESP.Enabled then return end
    for balloon, label in pairs(BalloonESP.Labels) do
        if not balloon or not balloon.Parent then
            RemoveBalloonESP(balloon)
        else
            local primary = balloon:FindFirstChildWhichIsA("BasePart") or balloon.PrimaryPart
            if primary then
                local pos, onScreen = Camera:WorldToViewportPoint(primary.Position + Vector3.new(0, 2, 0))
                if onScreen then
                    label.Position = Vector2.new(pos.X, pos.Y)
                    label.Visible = true
                else
                    label.Visible = false
                end
            else
                label.Visible = false
            end
        end
    end
end

local function StartBalloonESP()
    ScanExistingBalloons()

    local effects = workspace:FindFirstChild("Effects")
    if effects then
        BalloonESP.DescendantAddedConnection = effects.DescendantAdded:Connect(function(descendant)
            if not BalloonESP.Enabled then return end
            if descendant:IsA("Model") and descendant.Name == "Balloon" then
                CreateBalloonESP(descendant)
            end
        end)

        BalloonESP.DescendantRemovingConnection = effects.DescendantRemoving:Connect(function(descendant)
            if descendant:IsA("Model") and descendant.Name == "Balloon" then
                RemoveBalloonESP(descendant)
            end
        end)
    end

    if BalloonESP.Connection then
        BalloonESP.Connection:Disconnect()
    end
    BalloonESP.Connection = RunService.RenderStepped:Connect(UpdateBalloonESP)
end

local function StopBalloonESP()
    if BalloonESP.Connection then
        BalloonESP.Connection:Disconnect()
        BalloonESP.Connection = nil
    end
    if BalloonESP.DescendantAddedConnection then
        BalloonESP.DescendantAddedConnection:Disconnect()
        BalloonESP.DescendantAddedConnection = nil
    end
    if BalloonESP.DescendantRemovingConnection then
        BalloonESP.DescendantRemovingConnection:Disconnect()
        BalloonESP.DescendantRemovingConnection = nil
    end
    for balloon, _ in pairs(BalloonESP.Highlights) do
        RemoveBalloonESP(balloon)
    end
    BalloonESP.Highlights = {}
    BalloonESP.Labels = {}
end

-- ============================================
-- UI - ESPs TAB
-- ============================================
Tabs.ESPs:AddToggle("NormalPlayerESP", {
    Title    = "Player ESP",
    Icon     = "solar/eye-bold",
    Default  = false,
    Callback = function(value)
        NormalPlayerESP.Enabled = value
        if NormalPlayerESP.Enabled then
            StartNormalPlayerESP()
            Fluent:Notify({ Title = "ESP", Content = "Activated! White = Normal, Pink = Guard", Duration = 3 })
        else
            StopNormalPlayerESP()
            Fluent:Notify({ Title = "ESP", Content = "Deactivated!", Duration = 3 })
        end
    end,
})

Tabs.ESPs:AddToggle("BalloonESP", {
    Title    = "Balloon ESP",
    Icon     = "solar/air-balloon-bold",
    Default  = false,
    Callback = function(value)
        BalloonESP.Enabled = value
        if BalloonESP.Enabled then
            StartBalloonESP()
            Fluent:Notify({ Title = "Balloon ESP", Content = "Activated!", Duration = 3 })
        else
            StopBalloonESP()
            Fluent:Notify({ Title = "Balloon ESP", Content = "Deactivated!", Duration = 3 })
        end
    end,
})

-- ============================================
-- EXIT DOOR ESP (Hide And Seek)
-- ============================================
local ExitDoorESP = {
    Enabled = false,
    Highlights = {},
    Labels = {},
    Connection = nil
}

local ExitDoorPath = "workspace.HideAndSeekMap.NEWFIXEDDOORS.Floor3.EXITDOORS"

local function GetExitDoorsFolder()
    local map = workspace:FindFirstChild("HideAndSeekMap")
    if not map then return nil end
    local doors = map:FindFirstChild("NEWFIXEDDOORS")
    if not doors then return nil end
    local floor3 = doors:FindFirstChild("Floor3")
    if not floor3 then return nil end
    return floor3:FindFirstChild("EXITDOORS")
end

local function CreateExitDoorESP(door)
    if not door then return end
    if ExitDoorESP.Highlights[door] then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "XXMZ_ExitDoorESP"
    highlight.FillColor = Color3.fromRGB(255, 255, 0)
    highlight.FillTransparency = 0.3
    highlight.OutlineColor = Color3.fromRGB(255, 215, 0)
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Adornee = door
    highlight.Parent = door
    ExitDoorESP.Highlights[door] = highlight

    local label = Drawing.new("Text")
    label.Size = 16
    label.Outline = true
    label.Center = true
    label.Font = Drawing.Fonts.Monospace
    label.Color = Color3.fromRGB(255, 255, 0)
    label.Text = "EXIT DOOR"
    label.Visible = false
    ExitDoorESP.Labels[door] = label
end

local function RemoveExitDoorESP(door)
    if ExitDoorESP.Highlights[door] then
        ExitDoorESP.Highlights[door]:Destroy()
        ExitDoorESP.Highlights[door] = nil
    end
    if ExitDoorESP.Labels[door] then
        ExitDoorESP.Labels[door]:Remove()
        ExitDoorESP.Labels[door] = nil
    end
end

local function ScanExitDoors()
    local folder = GetExitDoorsFolder()
    if not folder then return end
    for _, door in pairs(folder:GetDescendants()) do
        if door:IsA("Model") or door:IsA("BasePart") then
            CreateExitDoorESP(door)
        end
    end
end

local function UpdateExitDoorESP()
    if not ExitDoorESP.Enabled then return end
    for door, label in pairs(ExitDoorESP.Labels) do
        if not door or not door.Parent then
            RemoveExitDoorESP(door)
        else
            local part = door:IsA("BasePart") and door or door:FindFirstChildWhichIsA("BasePart")
            if part then
                local pos, onScreen = Camera:WorldToViewportPoint(part.Position + Vector3.new(0, 3, 0))
                if onScreen then
                    label.Position = Vector2.new(pos.X, pos.Y)
                    label.Visible = true
                else
                    label.Visible = false
                end
            else
                label.Visible = false
            end
        end
    end
end

local function StartExitDoorESP()
    ScanExitDoors()
    if ExitDoorESP.Connection then
        ExitDoorESP.Connection:Disconnect()
    end
    ExitDoorESP.Connection = RunService.RenderStepped:Connect(UpdateExitDoorESP)
end

local function StopExitDoorESP()
    if ExitDoorESP.Connection then
        ExitDoorESP.Connection:Disconnect()
        ExitDoorESP.Connection = nil
    end
    for door, _ in pairs(ExitDoorESP.Highlights) do
        RemoveExitDoorESP(door)
    end
    ExitDoorESP.Highlights = {}
    ExitDoorESP.Labels = {}
end

-- ============================================
-- UI - HIDE AND SEEK TAB
-- ============================================
Tabs.HideAndSeek:AddToggle("HideAndSeekESP", {
    Title    = "Hide And Seek ESP",
    Icon     = "solar/magnifer-bold",
    Default  = false,
    Callback = function(value)
        HideAndSeekESP.Enabled = value
        if HideAndSeekESP.Enabled then
            if IsHideAndSeekActive() then
                StartHideAndSeekESP()
                Fluent:Notify({ Title = "Hide And Seek", Content = "Activated! Blue = Normal, Red = Knife", Duration = 3 })
            else
                Options.HideAndSeekESP:SetValue(false)
                HideAndSeekESP.Enabled = false
                Fluent:Notify({ Title = "Hide And Seek", Content = "PlayingHideAndSeek not found! ESP not activated.", Duration = 3 })
            end
        else
            StopHideAndSeekESP()
            Fluent:Notify({ Title = "Hide And Seek", Content = "Deactivated!", Duration = 3 })
        end
    end,
})

Tabs.HideAndSeek:AddToggle("ExitDoorESP", {
    Title    = "Exit Door ESP",
    Icon     = "solar/door-open-bold",
    Default  = false,
    Callback = function(value)
        ExitDoorESP.Enabled = value
        if ExitDoorESP.Enabled then
            StartExitDoorESP()
            Fluent:Notify({ Title = "Exit Door ESP", Content = "Activated! Yellow highlight", Duration = 3 })
        else
            StopExitDoorESP()
            Fluent:Notify({ Title = "Exit Door ESP", Content = "Deactivated!", Duration = 3 })
        end
    end,
})

-- ============================================
-- TELEPORT FUNCTIONS (Place & Region)
-- ============================================
local function TeleportToLobby()
    local character = LocalPlayer.Character
    if not character then
        Fluent:Notify({ Title = "Teleport", Content = "Character not found!", Duration = 3 })
        return
    end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then
        Fluent:Notify({ Title = "Teleport", Content = "HumanoidRootPart not found!", Duration = 3 })
        return
    end
    hrp.CFrame = CFrame.new(263, 54, -17)
    Fluent:Notify({ Title = "Teleport", Content = "Teleported to Lobby! (263, 54, -17)", Duration = 3 })
end

local function TeleportToPlayer(playerIdentifier)
    -- Handle both raw username and "DisplayName (@Name)" format
    local targetName = playerIdentifier
    local extracted = playerIdentifier:match("%(@(.+)%)")
    if extracted then
        targetName = extracted
    end

    for _, player in pairs(Players:GetPlayers()) do
        if player.Name == targetName then
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local character = LocalPlayer.Character
                if not character then return end
                local hrp = character:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                hrp.CFrame = player.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
                Fluent:Notify({ Title = "Teleport", Content = "Teleported to " .. player.DisplayName .. "!", Duration = 3 })
                return
            end
        end
    end
    Fluent:Notify({ Title = "Teleport", Content = "Player not found!", Duration = 3 })
end

local function GetPlayerList()
    local list = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(list, player.DisplayName .. " (@" .. player.Name .. ")")
        end
    end
    return list
end

local function TeleportToRandomBalloon()
    local effects = workspace:FindFirstChild("Effects")
    if not effects then
        Fluent:Notify({ Title = "Balloon", Content = "Effects folder not found!", Duration = 3 })
        return
    end
    local balloons = {}
    for _, obj in pairs(effects:GetDescendants()) do
        if obj:IsA("Model") and obj.Name == "Balloon" then
            table.insert(balloons, obj)
        end
    end
    if #balloons == 0 then
        Fluent:Notify({ Title = "Balloon", Content = "No balloons found!", Duration = 3 })
        return
    end
    local randomBalloon = balloons[math.random(1, #balloons)]
    local part = randomBalloon:FindFirstChildWhichIsA("BasePart") or randomBalloon.PrimaryPart
    if part then
        local character = LocalPlayer.Character
        if not character then return end
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        hrp.CFrame = part.CFrame + Vector3.new(0, 5, 0)
        Fluent:Notify({ Title = "Balloon", Content = "Teleported to a random balloon!", Duration = 3 })
    end
end

local function HasTakedown()
    local character = LocalPlayer.Character
    if character then
        if character:FindFirstChild("Takedown") then return true end
    end
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        if backpack:FindFirstChild("Takedown") then return true end
    end
    return false
end

local function EquipTakedown()
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        local takedown = backpack:FindFirstChild("Takedown")
        if takedown then
            local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid:EquipTool(takedown)
                return true
            end
        end
    end
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("Takedown") then
        return true
    end
    return false
end

local function UseTakedown()
    local character = LocalPlayer.Character
    if not character then return end
    local takedown = character:FindFirstChild("Takedown")
    if not takedown then return end

    -- Try multiple activation methods
    pcall(function()
        if takedown:FindFirstChild("RemoteEvent") then
            takedown.RemoteEvent:FireServer()
        end
    end)

    pcall(function()
        takedown:Activate()
    end)

    pcall(function()
        if takedown:FindFirstChild("Activate") then
            takedown.Activate:FireServer()
        end
    end)
end

local BringLoop = {
    Connection = nil,
    OriginalCFrame = nil,
    TargetPlayer = nil,
    Equipped = false,
    Used = false
}

local function StartBringLoop(targetPlayer)
    if BringLoop.Connection then
        BringLoop.Connection:Disconnect()
        BringLoop.Connection = nil
    end

    local character = LocalPlayer.Character
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    BringLoop.OriginalCFrame = hrp.CFrame
    BringLoop.TargetPlayer = targetPlayer
    BringLoop.Equipped = false
    BringLoop.Used = false

    BringLoop.Connection = RunService.Heartbeat:Connect(function()
        if not BringLoop.TargetPlayer or not BringLoop.TargetPlayer.Parent then
            StopBringLoop()
            return
        end

        local targetChar = BringLoop.TargetPlayer.Character
        if not targetChar or not targetChar:FindFirstChild("HumanoidRootPart") then
            StopBringLoop()
            return
        end

        local myChar = LocalPlayer.Character
        if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then
            StopBringLoop()
            return
        end

        local myHRP = myChar.HumanoidRootPart
        local targetHRP = targetChar.HumanoidRootPart

        -- FACE the target (look at them)
        local lookVector = (targetHRP.Position - myHRP.Position).Unit
        myHRP.CFrame = CFrame.new(myHRP.Position, myHRP.Position + Vector3.new(lookVector.X, 0, lookVector.Z))

        -- Orbit close to target (right behind them)
        local offset = CFrame.new(0, 0, -2)
        myHRP.CFrame = targetHRP.CFrame * offset

        -- Re-face after moving
        lookVector = (targetHRP.Position - myHRP.Position).Unit
        myHRP.CFrame = CFrame.new(myHRP.Position, myHRP.Position + Vector3.new(lookVector.X, 0, lookVector.Z))

        -- Equip Takedown
        if not BringLoop.Equipped then
            EquipTakedown()
            BringLoop.Equipped = true
            task.wait(0.1)
        end

        -- USE Takedown on target
        if BringLoop.Equipped and not BringLoop.Used then
            UseTakedown()
            BringLoop.Used = true
        end
    end)
end

local function StopBringLoop()
    if BringLoop.Connection then
        BringLoop.Connection:Disconnect()
        BringLoop.Connection = nil
    end

    if BringLoop.OriginalCFrame then
        local character = LocalPlayer.Character
        if character then
            local hrp = character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = BringLoop.OriginalCFrame
            end
        end
    end

    BringLoop.OriginalCFrame = nil
    BringLoop.TargetPlayer = nil
    BringLoop.Equipped = false
    BringLoop.Used = false
end

local function BringPlayer(playerIdentifier)
    if not HasTakedown() then
        Fluent:Notify({ Title = "Bring", Content = "You don't have Takedown item!", Duration = 3 })
        return
    end

    local targetName = playerIdentifier
    local extracted = playerIdentifier:match("%(@(.+)%)")
    if extracted then
        targetName = extracted
    end

    for _, player in pairs(Players:GetPlayers()) do
        if player.Name == targetName then
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                Fluent:Notify({ Title = "Bring", Content = "Targeting " .. player.DisplayName .. "...", Duration = 3 })
                StartBringLoop(player)

                task.delay(3, function()
                    StopBringLoop()
                    Fluent:Notify({ Title = "Bring", Content = "Finished! Returned to original position.", Duration = 3 })
                end)
                return
            end
        end
    end
    Fluent:Notify({ Title = "Bring", Content = "Player not found!", Duration = 3 })
end

-- ============================================
-- UI - TELEPORT TAB
-- ============================================
Tabs.Teleport:AddParagraph({
    Title   = "Place",
    Content = "Teleport to specific locations",
})

Tabs.Teleport:AddButton({
    Title    = "New Players Server",
    Icon     = "solar/planet-bold",
    Callback = function()
        TeleportToNewPlayers()
    end,
})

Tabs.Teleport:AddParagraph({
    Title   = "Region",
    Content = "Teleport to in-game areas",
})

Tabs.Teleport:AddButton({
    Title    = "Teleport To Lobby",
    Icon     = "solar/building-bold",
    Callback = function()
        TeleportToLobby()
    end,
})

Tabs.Teleport:AddButton({
    Title    = "Teleport to Balloon",
    Icon     = "solar/air-balloon-bold",
    Callback = function()
        TeleportToRandomBalloon()
    end,
})

Tabs.Teleport:AddParagraph({
    Title   = "Player Actions",
    Content = "Select a player and choose an action",
})

Tabs.Teleport:AddDropdown("PlayerActionDropdown", {
    Title                 = "Select Player",
    Icon                  = "solar/users-group-rounded-bold",
    Values                = GetPlayerList(),
    Default               = 1,
    Multi                 = false,
    DropdownOutsideWindow = false,
    Callback              = function(value)
        -- Stores selected player
    end,
})

Tabs.Teleport:AddButton({
    Title    = "Teleport to Player",
    Icon     = "solar/user-arrow-right-bold",
    Callback = function()
        local selected = Options.PlayerActionDropdown.Value
        if selected and selected ~= "" then
            local username = selected:match("%(@(.+)%)")
            if username then
                TeleportToPlayer(username)
            else
                Fluent:Notify({ Title = "Teleport", Content = "Invalid selection!", Duration = 3 })
            end
        else
            Fluent:Notify({ Title = "Teleport", Content = "No player selected!", Duration = 3 })
        end
    end,
})

Tabs.Teleport:AddButton({
    Title    = "Bring Player (PLAYER 120, DONT ABUSE)",
    Icon     = "solar/user-hand-up-bold",
    Callback = function()
        local selected = Options.PlayerActionDropdown.Value
        if selected and selected ~= "" then
            local username = selected:match("%(@(.+)%)")
            if username then
                BringPlayer(username)
            else
                Fluent:Notify({ Title = "Bring", Content = "Invalid selection!", Duration = 3 })
            end
        else
            Fluent:Notify({ Title = "Bring", Content = "No player selected!", Duration = 3 })
        end
    end,
})

-- ============================================
-- UI - GREEN LIGHT, RED LIGHT TAB
-- ============================================
Tabs.GreenLightRedLight:AddToggle("AntiDetect", {
    Title    = "Anti-Detect (Remove Injured/Stun)",
    Icon     = "solar/shield-check-bold",
    Default  = false,
    Callback = function(value)
        GLRL.AntiDetectEnabled = value
        if GLRL.AntiDetectEnabled then
            StartAntiDetect()
            Fluent:Notify({ Title = "Green Light, Red Light", Content = "Anti-Detection activated!", Duration = 3 })
        else
            StopAntiDetect()
            Fluent:Notify({ Title = "Green Light, Red Light", Content = "Anti-Detection deactivated!", Duration = 3 })
        end
    end,
})

Tabs.GreenLightRedLight:AddButton({
    Title    = "Teleport to End",
    Icon     = "solar/flag-bold",
    Callback = function()
        TeleportToEnd()
    end,
})

-- ============================================
-- UI - GLASS BRIDGE TAB
-- ============================================
Tabs.GlassBridge:AddButton({
    Title    = "Reveal Glass",
    Icon     = "solar/danger-square-bold",
    Callback = function()
        RevealGlass()
    end,
})

-- ============================================
-- UI - REBEL TAB
-- ============================================
Tabs.Rebel:AddToggle("BringGuards", {
    Title    = "Bring Guards",
    Icon     = "solar/sword-bold",
    Default  = false,
    Callback = function(value)
        Rebel.Enabled = value
        if Rebel.Enabled then
            StartBringGuardsLoop()
            Fluent:Notify({ Title = "Rebel", Content = "Bring Guards activated!", Duration = 3 })
        else
            StopBringGuardsLoop()
            Fluent:Notify({ Title = "Rebel", Content = "Bring Guards deactivated!", Duration = 3 })
        end
    end,
})

-- ============================================
-- UI - JUMP ROPE TAB
-- ============================================
Tabs.JumpRope:AddButton({
    Title    = "Delete Rope",
    Icon     = "solar/scissors-bold",
    Callback = function()
        DeleteRope()
    end,
})

-- Update player dropdown when players join/leave
Players.PlayerAdded:Connect(function()
    task.wait(0.5)
    if Options.PlayerActionDropdown then
        Options.PlayerActionDropdown:SetValues(GetPlayerList())
    end
end)

Players.PlayerRemoving:Connect(function()
    task.wait(0.5)
    if Options.PlayerActionDropdown then
        Options.PlayerActionDropdown:SetValues(GetPlayerList())
    end
end)

-- ============================================
-- INIT
-- ============================================
Fluent:Notify({
    Title    = "XXMZ INK",
    Content  = "Loaded! All features ready.",
    Duration = 5,
})
