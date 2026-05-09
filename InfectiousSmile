--[[
    Zelo Library v2.3.0
    UI Library para Roblox

    FIXES/NOVIDADES v2.3.0:
    - Blur NÃO muda ao minimizar/expandir (só muda ao fechar/unload)
    - Suporte a mobile (Touch + Mouse)
    - Settings agora é um painel lateral (como aba), acessado pelo botão do nome
    - Toggle "No Name" nas settings (esconde nome do jogador no header)
    - Bug corrigido: fechar com X e reabrir com ToggleKey funciona corretamente
    - Botão Unload nas settings
    - Settings é padrão em todos os scripts da library
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")

local LP = Players.LocalPlayer
local NAME = LP.Name

local C = {
    BG = Color3.fromRGB(15, 15, 15),
    Surface = Color3.fromRGB(22, 22, 22),
    Surface2 = Color3.fromRGB(28, 28, 28),
    Surface3 = Color3.fromRGB(33, 33, 33),
    Border = Color3.fromRGB(40, 40, 40),
    Border2 = Color3.fromRGB(50, 50, 50),
    Text = Color3.fromRGB(220, 220, 220),
    Dim = Color3.fromRGB(130, 130, 130),
    Muted = Color3.fromRGB(75, 75, 75),
    White = Color3.fromRGB(235, 235, 235),
    Black = Color3.fromRGB(15, 15, 15),
    Green = Color3.fromRGB(76, 175, 125),
    Red = Color3.fromRGB(200, 70, 70),
    TabBG = Color3.fromRGB(230, 230, 230),
    Blue = Color3.fromRGB(88, 101, 242),
    NotifySuccess = Color3.fromRGB(76, 175, 80),
    NotifyError = Color3.fromRGB(244, 67, 54),
    NotifyInfo = Color3.fromRGB(33, 150, 243),
    NotifyWarning = Color3.fromRGB(255, 152, 0),
}

-- Detecta se é mobile
local IS_MOBILE = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local function make(class, props, parent)
    local o = Instance.new(class)
    if class == "Frame" or class == "ScrollingFrame" then
        o.BorderSizePixel = 0
    end
    for k,v in pairs(props) do
        pcall(function() o[k] = v end)
    end
    o.Parent = parent
    return o
end

local function corner(r, p)
    local o = Instance.new("UICorner")
    o.CornerRadius = UDim.new(0, r)
    o.Parent = p
    return o
end

local function stroke(col, t, p)
    local o = Instance.new("UIStroke")
    o.Color = col
    o.Thickness = t
    o.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    o.Parent = p
    return o
end

local function pad(T,B,L,R,p)
    local o = Instance.new("UIPadding")
    o.PaddingTop = UDim.new(0,T or 0)
    o.PaddingBottom = UDim.new(0,B or 0)
    o.PaddingLeft = UDim.new(0,L or 0)
    o.PaddingRight = UDim.new(0,R or 0)
    o.Parent = p
end

local function listLayout(dir, padding, p)
    local o = Instance.new("UIListLayout")
    o.FillDirection = dir or Enum.FillDirection.Vertical
    o.Padding = UDim.new(0, padding or 0)
    o.SortOrder = Enum.SortOrder.LayoutOrder
    o.Parent = p
    return o
end

local function tween(obj, t, props)
    TweenService:Create(obj, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

-- Helper: conecta tanto mouse quanto touch num frame/button
local function onActivated(obj, fn)
    if obj:IsA("GuiButton") then
        obj.MouseButton1Click:Connect(fn)
        obj.TouchTap:Connect(fn)
    else
        obj.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1
            or inp.UserInputType == Enum.UserInputType.Touch then
                fn(inp)
            end
        end)
    end
end

-- NOTIFICATION
local NotifyGui = nil
local function getNotifyGui()
    if NotifyGui then return NotifyGui end
    NotifyGui = make("ScreenGui", {
        Name = "ZeloNotify",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    }, CoreGui)
    pcall(function() NotifyGui.Parent = LP:WaitForChild("PlayerGui") end)
    return NotifyGui
end

local Zelo = {}
Zelo.__index = Zelo

function Zelo:Notify(opts)
    opts = opts or {}
    local title = opts.Title or "Notificacao"
    local text = opts.Text or ""
    local duration = opts.Duration or 5
    local notifyType = opts.Type or "info"

    local typeColors = {
        success = C.NotifySuccess,
        error = C.NotifyError,
        info = C.NotifyInfo,
        warning = C.NotifyWarning,
    }
    local accentColor = typeColors[notifyType] or C.NotifyInfo

    local gui = getNotifyGui()

    local container = gui:FindFirstChild("NotifyContainer")
    if not container then
        container = make("Frame", {
            Name = "NotifyContainer",
            Size = UDim2.new(0, 320, 1, -40),
            Position = UDim2.new(1, -340, 0, 20),
            BackgroundTransparency = 1,
        }, gui)
        local layout = listLayout(Enum.FillDirection.Vertical, 8, container)
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    end

    local notif = make("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = C.Surface,
        BackgroundTransparency = 0.05,
        AutomaticSize = Enum.AutomaticSize.Y,
    }, container)
    corner(8, notif)
    stroke(C.Border, 1, notif)

    local accentBar = make("Frame", {
        Size = UDim2.new(0, 4, 1, 0),
        BackgroundColor3 = accentColor,
        ZIndex = 2,
    }, notif)
    corner(4, accentBar)

    local inner = make("Frame", {
        Size = UDim2.new(1, -20, 0, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
    }, notif)
    pad(12, 12, 0, 0, inner)
    listLayout(Enum.FillDirection.Vertical, 4, inner)

    make("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = C.White,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, inner)

    make("TextLabel", {
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = C.Dim,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutomaticSize = Enum.AutomaticSize.Y,
    }, inner)

    local progressBar = make("Frame", {
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 1, -2),
        BackgroundColor3 = accentColor,
        BackgroundTransparency = 0.3,
        ZIndex = 2,
    }, notif)

    notif.Position = UDim2.new(1, 50, 0, 0)
    tween(notif, 0.3, {Position = UDim2.new(0, 0, 0, 0)})
    tween(progressBar, duration, {Size = UDim2.new(0, 0, 0, 2)})

    task.delay(duration, function()
        tween(notif, 0.3, {Position = UDim2.new(1, 50, 0, 0), BackgroundTransparency = 1})
        task.delay(0.3, function()
            notif:Destroy()
        end)
    end)
end

function Zelo:CreateWindow(cfg)
    cfg = cfg or {}

    local Title = cfg.Title or "Zelo"
    local SubTitle = cfg.SubTitle or "v1.0"
    local KeySystem = cfg.KeySystem or false
    local ValidKey = cfg.Key or ""
    local KeyNote = cfg.KeyNote or "Insira a key para continuar."
    local GetKeyLink = cfg.GetKeyLink or nil
    local SaveKey = cfg.SaveKey ~= false
    local Discord = cfg.Discord or nil
    local DiscordText = cfg.DiscordText or "Entre no nosso servidor!"
    local ToggleKey = cfg.ToggleKey or Enum.KeyCode.RightShift
    local Transparency = math.clamp(cfg.Transparency or 0.05, 0, 0.9)
    local BlurEnabled = cfg.Blur ~= false

    local SaveFileName   = cfg.SaveFileName   or ("Zelo_Key_" .. game.PlaceId)
    local KeyTitle       = cfg.KeyTitle       or "Key System"
    local KeySubTitle    = cfg.KeySubTitle    or nil
    local KeyGetText     = cfg.KeyGetText     or "Get Key"
    local KeyConfirmText = cfg.KeyConfirmText or "Confirmar"
    local KeyCloseText   = cfg.KeyCloseText   or "Fechar"

    local WIN_VISIBLE = false   -- começa false, só fica true após KeySystem/Discord/direto
    local WIN_ALPHA = Transparency
    local TABS = {}
    local ACTIVE_TAB = nil
    local SETTINGS_ACTIVE = false
    local BLUR_OBJ = nil
    local MAIN_GUI = nil
    local WIN = nil
    local WindowObj = nil

    -- Blur só ativado enquanto janela aberta E não minimizada
    if BlurEnabled then
        BLUR_OBJ = Instance.new("BlurEffect")
        BLUR_OBJ.Size = 0
        BLUR_OBJ.Enabled = false
        BLUR_OBJ.Parent = Lighting
    end

    local function setBlur(on)
        if not BlurEnabled or not BLUR_OBJ then return end
        if on then
            BLUR_OBJ.Enabled = true
            tween(BLUR_OBJ, 0.5, {Size = 20})
        else
            tween(BLUR_OBJ, 0.3, {Size = 0})
            task.delay(0.3, function()
                if BLUR_OBJ then BLUR_OBJ.Enabled = false end
            end)
        end
    end

    MAIN_GUI = make("ScreenGui", {
        Name = "ZeloLib",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    }, CoreGui)
    pcall(function() MAIN_GUI.Parent = LP:WaitForChild("PlayerGui") end)

    -- Mobile: tamanho adaptado
    local WIN_W = IS_MOBILE and 580 or 720
    local WIN_H = IS_MOBILE and 420 or 500
    local WIN_X = IS_MOBILE and -WIN_W/2 or -360
    local WIN_Y = IS_MOBILE and -WIN_H/2 or 60
    local WIN_XSCALE = 0.5
    local WIN_YSCALE = IS_MOBILE and 0.5 or 0

    WIN = make("Frame", {
        Name = "Window",
        Size = UDim2.new(0, WIN_W, 0, WIN_H),
        Position = UDim2.new(WIN_XSCALE, WIN_X, WIN_YSCALE, WIN_Y),
        BackgroundColor3 = C.BG,
        BackgroundTransparency = WIN_ALPHA,
        Active = true,
        ClipsDescendants = false,
        Visible = false,
    }, MAIN_GUI)
    corner(12, WIN)
    stroke(C.Border, 1, WIN)

    make("ImageLabel", {
        Size = UDim2.new(1, 60, 1, 60),
        Position = UDim2.new(0, -30, 0, -30),
        BackgroundTransparency = 1,
        Image = "rbxassetid://6014261993",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        ZIndex = 0,
    }, WIN)

    local Header = make("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 46),
        BackgroundColor3 = C.BG,
        BackgroundTransparency = WIN_ALPHA,
        Active = true,
    }, WIN)

    make("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = C.Border,
    }, Header)

    local LogoF = make("Frame", {
        Size = UDim2.new(0, 140, 1, 0),
        BackgroundTransparency = 1,
    }, Header)

    make("TextLabel", {
        Size = UDim2.new(1, -10, 0, 18),
        Position = UDim2.new(0, 14, 0, 8),
        BackgroundTransparency = 1,
        Text = Title,
        TextColor3 = C.White,
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, LogoF)

    make("TextLabel", {
        Size = UDim2.new(1, -10, 0, 12),
        Position = UDim2.new(0, 14, 0, 26),
        BackgroundTransparency = 1,
        Text = SubTitle,
        TextColor3 = C.Muted,
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, LogoF)

    -- Botão do usuário (abre Settings)
    local UserBtn = make("TextButton", {
        Name = "UserBtn",
        Size = UDim2.new(0, 120, 0, 28),
        Position = UDim2.new(1, -204, 0.5, -14),
        BackgroundTransparency = 1,
        BackgroundColor3 = C.Surface2,
        Text = NAME .. "  ⚙",
        TextColor3 = C.Dim,
        Font = Enum.Font.GothamBold,
        TextSize = 10,
        AutoButtonColor = false,
    }, Header)
    corner(6, UserBtn)

    local MinBtn = make("TextButton", {
        Name = "MinBtn",
        Size = UDim2.new(0, 32, 0, 32),
        Position = UDim2.new(1, -76, 0.5, -16),
        BackgroundColor3 = C.Surface2,
        Text = "-",
        TextColor3 = C.Dim,
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        AutoButtonColor = false,
    }, Header)
    corner(6, MinBtn)

    MinBtn.MouseEnter:Connect(function()
        tween(MinBtn, 0.15, {BackgroundColor3 = C.Surface3, TextColor3 = C.Text})
    end)
    MinBtn.MouseLeave:Connect(function()
        tween(MinBtn, 0.15, {BackgroundColor3 = C.Surface2, TextColor3 = C.Dim})
    end)

    local CloseBtn = make("TextButton", {
        Name = "CloseBtn",
        Size = UDim2.new(0, 32, 0, 32),
        Position = UDim2.new(1, -40, 0.5, -16),
        BackgroundColor3 = C.Surface2,
        Text = "x",
        TextColor3 = C.Dim,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        AutoButtonColor = false,
    }, Header)
    corner(6, CloseBtn)

    CloseBtn.MouseEnter:Connect(function()
        tween(CloseBtn, 0.15, {BackgroundColor3 = C.Red, TextColor3 = C.White})
    end)
    CloseBtn.MouseLeave:Connect(function()
        tween(CloseBtn, 0.15, {BackgroundColor3 = C.Surface2, TextColor3 = C.Dim})
    end)

    -- Drag (mouse + touch)
    local dragging = false
    local dragStart, startPos

    local function beginDrag(inputPos)
        dragging = true
        dragStart = inputPos
        startPos = WIN.Position
    end
    local function endDrag()
        dragging = false
    end

    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            beginDrag(input.Position)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            WIN.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            endDrag()
        end
    end)

    local Body = make("Frame", {
        Name = "Body",
        Size = UDim2.new(1, 0, 1, -46),
        Position = UDim2.new(0, 0, 0, 46),
        BackgroundTransparency = 1,
        ClipsDescendants = false,
    }, WIN)

    local Sidebar = make("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 160, 1, 0),
        BackgroundColor3 = C.Surface,
        BackgroundTransparency = WIN_ALPHA,
    }, Body)

    make("Frame", {
        Size = UDim2.new(0, 1, 1, 0),
        Position = UDim2.new(1, -1, 0, 0),
        BackgroundColor3 = C.Border,
    }, Sidebar)

    local TabSearch = make("TextBox", {
        Name = "TabSearch",
        Size = UDim2.new(1, -16, 0, 30),
        Position = UDim2.new(0, 8, 0, 8),
        BackgroundColor3 = C.Surface2,
        Text = "",
        PlaceholderText = "Buscar tabs...",
        TextColor3 = C.Text,
        PlaceholderColor3 = C.Muted,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        ClearTextOnFocus = false,
    }, Sidebar)
    corner(6, TabSearch)
    stroke(C.Border, 1, TabSearch)
    pad(0, 0, 8, 8, TabSearch)

    local TabScroll = make("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, -50),
        Position = UDim2.new(0, 0, 0, 46),
        BackgroundTransparency = 1,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = C.Border,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ElasticBehavior = Enum.ElasticBehavior.Never,
    }, Sidebar)
    listLayout(Enum.FillDirection.Vertical, 2, TabScroll)
    pad(6, 6, 6, 6, TabScroll)

    local ContentArea = make("Frame", {
        Name = "ContentArea",
        Size = UDim2.new(1, -160, 1, 0),
        Position = UDim2.new(0, 160, 0, 0),
        BackgroundTransparency = 1,
        ClipsDescendants = false,
    }, Body)

    -- ==============================================================
    -- SETTINGS PANEL (lateral, mesmo estilo de aba)
    -- ==============================================================
    local SettingsFrame = make("Frame", {
        Name = "SettingsFrame",
        Size = UDim2.new(1, -160, 1, 0),
        Position = UDim2.new(0, 160, 0, 0),
        BackgroundTransparency = 1,
        ClipsDescendants = false,
        Visible = false,
    }, Body)

    local SettingsScroll = make("ScrollingFrame", {
        Size = UDim2.new(1, -28, 1, -10),
        Position = UDim2.new(0, 14, 0, 10),
        BackgroundTransparency = 1,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = C.Border,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ElasticBehavior = Enum.ElasticBehavior.Never,
    }, SettingsFrame)
    listLayout(Enum.FillDirection.Vertical, 10, SettingsScroll)

    local function makeSettingsSection(title)
        local gb = make("Frame", {
            Name = "SettingsGroup",
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundColor3 = C.Surface,
            AutomaticSize = Enum.AutomaticSize.Y,
        }, SettingsScroll)
        corner(8, gb)
        stroke(C.Border, 1, gb)

        local inner = make("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.Y,
        }, gb)
        pad(10, 10, 12, 12, inner)
        listLayout(Enum.FillDirection.Vertical, 6, inner)

        if title and title ~= "" then
            local hdr = make("Frame", {
                Size = UDim2.new(1, 0, 0, 22),
                BackgroundTransparency = 1,
                LayoutOrder = 0,
            }, inner)
            make("TextLabel", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = title:upper(),
                TextColor3 = C.Muted,
                Font = Enum.Font.GothamBold,
                TextSize = 8,
                TextXAlignment = Enum.TextXAlignment.Left,
            }, hdr)
            make("Frame", {
                Size = UDim2.new(1, 0, 0, 1),
                Position = UDim2.new(0, 0, 1, -1),
                BackgroundColor3 = C.Border,
            }, hdr)
        end

        return inner
    end

    -- Section: HUB
    local secHub = makeSettingsSection("Hub")
    local loCount = 1

    -- Toggle "No Name"
    local noNameVal = false
    local noNameRow = make("Frame", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = C.Surface2,
        LayoutOrder = loCount,
    }, secHub)
    loCount += 1
    corner(6, noNameRow)
    stroke(C.Border, 1, noNameRow)

    make("TextLabel", {
        Size = UDim2.new(1, -54, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = "No Name",
        TextColor3 = C.Text,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, noNameRow)

    local noNamePill = make("Frame", {
        Size = UDim2.new(0, 36, 0, 18),
        Position = UDim2.new(1, -46, 0.5, -9),
        BackgroundColor3 = C.Surface3,
    }, noNameRow)
    corner(9, noNamePill)
    stroke(C.Border, 1, noNamePill)

    local noNameKnob = make("Frame", {
        Size = UDim2.new(0, 12, 0, 12),
        Position = UDim2.new(0, 3, 0.5, -6),
        BackgroundColor3 = C.White,
    }, noNamePill)
    corner(6, noNameKnob)

    local function setNoName(v)
        noNameVal = v
        tween(noNamePill, 0.15, {BackgroundColor3 = v and C.Green or C.Surface3})
        tween(noNameKnob, 0.15, {
            Position = v and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
        })
        UserBtn.Text = v and "⚙" or (NAME .. "  ⚙")
    end

    onActivated(noNameRow, function()
        setNoName(not noNameVal)
    end)

    -- Keybind para esconder
    local kbRow = make("Frame", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundTransparency = 1,
        LayoutOrder = loCount,
    }, secHub)
    loCount += 1

    local kbBg = make("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = C.Surface2,
    }, kbRow)
    corner(6, kbBg)
    stroke(C.Border, 1, kbBg)

    make("TextLabel", {
        Size = UDim2.new(1, -100, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = "Keybind (esconder)",
        TextColor3 = C.Text,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, kbBg)

    local kbBox = make("TextButton", {
        Size = UDim2.new(0, 80, 0, 22),
        Position = UDim2.new(1, -90, 0.5, -11),
        BackgroundColor3 = C.Surface3,
        Text = "[" .. tostring(ToggleKey):gsub("Enum.KeyCode.", "") .. "]",
        TextColor3 = C.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 9,
        AutoButtonColor = false,
    }, kbBg)
    corner(5, kbBox)
    stroke(C.Border, 1, kbBox)

    local listeningKB = false
    onActivated(kbBox, function()
        listeningKB = true
        kbBox.Text = "[ ... ]"
        kbBox.TextColor3 = C.Muted
    end)
    UserInputService.InputBegan:Connect(function(inp, gp)
        if gp then return end
        if listeningKB and inp.UserInputType == Enum.UserInputType.Keyboard then
            ToggleKey = inp.KeyCode
            kbBox.Text = "[" .. tostring(inp.KeyCode):gsub("Enum.KeyCode.", "") .. "]"
            kbBox.TextColor3 = C.Text
            listeningKB = false
        end
    end)

    -- Transparência
    local alphaSection = makeSettingsSection("Transparencia")
    local alphaRow = make("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        LayoutOrder = 1,
    }, alphaSection)

    local sliderBG = make("Frame", {
        Size = UDim2.new(1, 0, 0, 6),
        Position = UDim2.new(0, 0, 0, 16),
        BackgroundColor3 = C.Surface3,
    }, alphaRow)
    corner(3, sliderBG)
    stroke(C.Border2, 1, sliderBG)

    local sliderFill = make("Frame", {
        Size = UDim2.new(WIN_ALPHA, 0, 1, 0),
        BackgroundColor3 = C.White,
    }, sliderBG)
    corner(3, sliderFill)

    local alphaLbl = make("TextLabel", {
        Size = UDim2.new(1, 0, 0, 14),
        BackgroundTransparency = 1,
        Text = math.floor(WIN_ALPHA * 100) .. "%",
        TextColor3 = C.Dim,
        Font = Enum.Font.Gotham,
        TextSize = 9,
        TextXAlignment = Enum.TextXAlignment.Right,
    }, alphaRow)

    local draggingAlpha = false
    sliderBG.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            draggingAlpha = true
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            draggingAlpha = false
        end
    end)
    RunService.RenderStepped:Connect(function()
        if draggingAlpha then
            local mx = UserInputService:GetMouseLocation().X
            local rel = math.clamp(
                (mx - sliderBG.AbsolutePosition.X) / sliderBG.AbsoluteSize.X, 0, 1)
            WIN_ALPHA = rel
            sliderFill.Size = UDim2.new(rel, 0, 1, 0)
            alphaLbl.Text = math.floor(rel * 100) .. "%"
            WIN.BackgroundTransparency = rel
            Header.BackgroundTransparency = rel
            Sidebar.BackgroundTransparency = rel
            if TABS then
                for _, tab in pairs(TABS) do
                    for _, child in pairs(tab.LeftContainer:GetChildren()) do
                        if child:IsA("Frame") and child.Name == "Groupbox" then
                            child.BackgroundTransparency = rel
                        end
                    end
                    for _, child in pairs(tab.RightContainer:GetChildren()) do
                        if child:IsA("Frame") and child.Name == "Groupbox" then
                            child.BackgroundTransparency = rel
                        end
                    end
                end
            end
        end
    end)

    -- Blur (apenas se habilitado)
    if BlurEnabled then
        local blurSection = makeSettingsSection("Blur do Fundo")
        local blurRow = make("Frame", {
            Size = UDim2.new(1, 0, 0, 32),
            BackgroundTransparency = 1,
            LayoutOrder = 1,
        }, blurSection)

        local blurBg = make("Frame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = C.Surface2,
        }, blurRow)
        corner(6, blurBg)
        stroke(C.Border, 1, blurBg)

        make("TextLabel", {
            Size = UDim2.new(1, -54, 1, 0),
            Position = UDim2.new(0, 10, 0, 0),
            BackgroundTransparency = 1,
            Text = "Blur ativo",
            TextColor3 = C.Text,
            Font = Enum.Font.Gotham,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, blurBg)

        local blurOn = true
        local blurPill = make("Frame", {
            Size = UDim2.new(0, 36, 0, 18),
            Position = UDim2.new(1, -46, 0.5, -9),
            BackgroundColor3 = C.Green,
        }, blurBg)
        corner(9, blurPill)
        stroke(C.Border, 1, blurPill)

        local blurKnob = make("Frame", {
            Size = UDim2.new(0, 12, 0, 12),
            Position = UDim2.new(1, -15, 0.5, -6),
            BackgroundColor3 = C.White,
        }, blurPill)
        corner(6, blurKnob)

        onActivated(blurBg, function()
            blurOn = not blurOn
            tween(blurPill, 0.15, {BackgroundColor3 = blurOn and C.Green or C.Surface3})
            tween(blurKnob, 0.15, {
                Position = blurOn and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
            })
            if BLUR_OBJ then
                if blurOn and WIN_VISIBLE then
                    BLUR_OBJ.Enabled = true
                    tween(BLUR_OBJ, 0.4, {Size = 20})
                else
                    tween(BLUR_OBJ, 0.3, {Size = 0})
                    task.delay(0.3, function() if BLUR_OBJ then BLUR_OBJ.Enabled = false end end)
                end
            end
        end)
    end

    -- Discord nas settings (se tiver)
    if Discord then
        local dcSection = makeSettingsSection("Discord")
        local dcRow = make("Frame", {
            Size = UDim2.new(1, 0, 0, 32),
            BackgroundTransparency = 1,
            LayoutOrder = 1,
        }, dcSection)

        local dcBtn = make("TextButton", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = C.Blue,
            Text = "Copiar invite",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Font = Enum.Font.GothamBold,
            TextSize = 10,
            AutoButtonColor = false,
        }, dcRow)
        corner(6, dcBtn)

        onActivated(dcBtn, function()
            pcall(function() setclipboard(Discord) end)
            dcBtn.Text = "Copiado!"
            task.delay(1.5, function() dcBtn.Text = "Copiar invite" end)
        end)
    end

    -- Unload
    local unloadSection = makeSettingsSection("Unload")
    local unloadRow = make("Frame", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundTransparency = 1,
        LayoutOrder = 1,
    }, unloadSection)

    local unloadBtn = make("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = C.Red,
        Text = "Descarregar Script",
        TextColor3 = C.White,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        AutoButtonColor = false,
    }, unloadRow)
    corner(6, unloadBtn)

    onActivated(unloadBtn, function()
        tween(WIN, 0.2, {Size = UDim2.new(0, WIN_W, 0, 0)})
        task.delay(0.25, function()
            if BLUR_OBJ then BLUR_OBJ:Destroy() end
            MAIN_GUI:Destroy()
        end)
    end)

    -- ==============================================================
    -- MINIMIZE / TOGGLE / CLOSE
    -- ==============================================================
    local bodyMinimized = false

    local function showWindow()
        WIN.Visible = true
        Body.Visible = true
        WIN_VISIBLE = true
        bodyMinimized = false
        tween(WIN, 0.2, {Size = UDim2.new(0, WIN_W, 0, WIN_H)})
        -- Blur NÃO é ativado ao expandir — mantém estado atual
    end

    local function hideWindow()
        bodyMinimized = true
        WIN_VISIBLE = false
        tween(WIN, 0.2, {Size = UDim2.new(0, WIN_W, 0, 46)})
        task.delay(0.2, function()
            Body.Visible = false
        end)
        -- Blur NÃO é desativado ao minimizar
    end

    MinBtn.MouseButton1Click:Connect(function()
        if bodyMinimized then
            showWindow()
        else
            hideWindow()
        end
    end)
    MinBtn.TouchTap:Connect(function()
        if bodyMinimized then
            showWindow()
        else
            hideWindow()
        end
    end)

    -- Fechar: esconde a janela, reseta estado para poder reabrir com ToggleKey
    CloseBtn.MouseButton1Click:Connect(function()
        tween(WIN, 0.2, {Size = UDim2.new(0, WIN_W, 0, 0)})
        task.delay(0.2, function()
            WIN.Visible = false
            Body.Visible = true  -- reset para quando reabrir
            WIN_VISIBLE = false
            bodyMinimized = false  -- FIX: reseta estado para ToggleKey funcionar
        end)
    end)
    CloseBtn.TouchTap:Connect(function()
        tween(WIN, 0.2, {Size = UDim2.new(0, WIN_W, 0, 0)})
        task.delay(0.2, function()
            WIN.Visible = false
            Body.Visible = true
            WIN_VISIBLE = false
            bodyMinimized = false
        end)
    end)

    -- ToggleKey: abre se fechado, minimiza/expande se visível
    UserInputService.InputBegan:Connect(function(inp, gp)
        if gp then return end
        if inp.KeyCode == ToggleKey and not listeningKB then
            if not WIN.Visible then
                -- estava fechado (X foi pressionado), reabre
                WIN.Size = UDim2.new(0, WIN_W, 0, 0)
                WIN.Visible = true
                Body.Visible = true
                WIN_VISIBLE = true
                bodyMinimized = false
                tween(WIN, 0.2, {Size = UDim2.new(0, WIN_W, 0, WIN_H)})
            elseif bodyMinimized then
                showWindow()
            else
                hideWindow()
            end
        end
    end)

    TabSearch:GetPropertyChangedSignal("Text"):Connect(function()
        local q = TabSearch.Text:lower()
        for _, btn in pairs(TabScroll:GetChildren()) do
            if btn:IsA("TextButton") then
                btn.Visible = q == "" or btn.Text:lower():find(q, 1, true) ~= nil
            end
        end
    end)

    -- ==============================================================
    -- SETTINGS TAB TOGGLE (botão do nome)
    -- ==============================================================
    local function openSettings()
        SETTINGS_ACTIVE = true
        -- Esconde tab atual
        if ACTIVE_TAB then
            ACTIVE_TAB.Frame.Visible = false
            ACTIVE_TAB.SectionSearch.Visible = false
            ACTIVE_TAB.Btn.BackgroundColor3 = C.Surface2
            ACTIVE_TAB.Btn.TextColor3 = C.Dim
        end
        SettingsFrame.Visible = true
        UserBtn.BackgroundColor3 = C.TabBG
        UserBtn.TextColor3 = C.Black
        UserBtn.BackgroundTransparency = 0
    end

    local function closeSettings()
        SETTINGS_ACTIVE = false
        SettingsFrame.Visible = false
        UserBtn.BackgroundColor3 = C.Surface2
        UserBtn.TextColor3 = C.Dim
        UserBtn.BackgroundTransparency = 1
        -- Restaura tab ativa
        if ACTIVE_TAB then
            ACTIVE_TAB.Frame.Visible = true
            ACTIVE_TAB.SectionSearch.Visible = true
            ACTIVE_TAB.Btn.BackgroundColor3 = C.TabBG
            ACTIVE_TAB.Btn.TextColor3 = C.Black
        end
    end

    UserBtn.MouseEnter:Connect(function()
        if not SETTINGS_ACTIVE then
            UserBtn.BackgroundTransparency = 0
            UserBtn.TextColor3 = C.Text
        end
    end)
    UserBtn.MouseLeave:Connect(function()
        if not SETTINGS_ACTIVE then
            UserBtn.BackgroundTransparency = 1
            UserBtn.TextColor3 = C.Dim
        end
    end)
    onActivated(UserBtn, function()
        if SETTINGS_ACTIVE then
            closeSettings()
        else
            openSettings()
        end
    end)

    -- ==============================================================
    -- WINDOW OBJECT
    -- ==============================================================
    WindowObj = {}

    local function selectTab(tabObj)
        if SETTINGS_ACTIVE then
            closeSettings()
        end
        if ACTIVE_TAB then
            ACTIVE_TAB.Btn.BackgroundColor3 = C.Surface2
            ACTIVE_TAB.Btn.TextColor3 = C.Dim
            ACTIVE_TAB.Frame.Visible = false
            ACTIVE_TAB.SectionSearch.Visible = false
        end

        ACTIVE_TAB = tabObj
        tabObj.Btn.BackgroundColor3 = C.TabBG
        tabObj.Btn.TextColor3 = C.Black
        tabObj.Frame.Visible = true
        tabObj.SectionSearch.Visible = true
    end

    function WindowObj:AddTab(name)
        local tabBtn = make("TextButton", {
            Name = name,
            Size = UDim2.new(1, 0, 0, 34),
            BackgroundColor3 = C.Surface2,
            Text = name,
            TextColor3 = C.Dim,
            Font = Enum.Font.GothamBold,
            TextSize = 11,
            AutoButtonColor = false,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, TabScroll)
        corner(6, tabBtn)
        pad(0, 0, 10, 0, tabBtn)

        local tabFrame = make("Frame", {
            Name = "Tab_" .. name,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible = false,
            ClipsDescendants = false,
        }, ContentArea)

        local secSearch = make("TextBox", {
            Name = "SecSearch",
            Size = UDim2.new(1, -28, 0, 28),
            Position = UDim2.new(0, 14, 0, 10),
            BackgroundColor3 = C.Surface2,
            Text = "",
            PlaceholderText = "Buscar secoes...",
            TextColor3 = C.Text,
            PlaceholderColor3 = C.Muted,
            Font = Enum.Font.Gotham,
            TextSize = 10,
            ClearTextOnFocus = false,
            Visible = false,
        }, tabFrame)
        corner(6, secSearch)
        stroke(C.Border, 1, secSearch)
        pad(0, 0, 8, 8, secSearch)

        local leftContainer = make("Frame", {
            Name = "LeftContainer",
            Size = UDim2.new(0.5, -10, 1, -48),
            Position = UDim2.new(0, 14, 0, 44),
            BackgroundTransparency = 1,
            ClipsDescendants = false,
        }, tabFrame)
        listLayout(Enum.FillDirection.Vertical, 10, leftContainer)

        local rightContainer = make("Frame", {
            Name = "RightContainer",
            Size = UDim2.new(0.5, -10, 1, -48),
            Position = UDim2.new(0.5, 4, 0, 44),
            BackgroundTransparency = 1,
            ClipsDescendants = false,
        }, tabFrame)
        listLayout(Enum.FillDirection.Vertical, 10, rightContainer)

        secSearch:GetPropertyChangedSignal("Text"):Connect(function()
            local q = secSearch.Text:lower()
            for _, child in pairs(leftContainer:GetChildren()) do
                if child:IsA("Frame") and child.Name == "Groupbox" then
                    local title = child:GetAttribute("Title") or ""
                    child.Visible = q == "" or title:lower():find(q, 1, true) ~= nil
                end
            end
            for _, child in pairs(rightContainer:GetChildren()) do
                if child:IsA("Frame") and child.Name == "Groupbox" then
                    local title = child:GetAttribute("Title") or ""
                    child.Visible = q == "" or title:lower():find(q, 1, true) ~= nil
                end
            end
        end)

        local tabObj = {
            Btn = tabBtn,
            Frame = tabFrame,
            SectionSearch = secSearch,
            LeftContainer = leftContainer,
            RightContainer = rightContainer,
        }
        table.insert(TABS, tabObj)

        tabBtn.MouseEnter:Connect(function()
            if ACTIVE_TAB ~= tabObj then
                tabBtn.BackgroundColor3 = C.Surface3
                tabBtn.TextColor3 = C.Text
            end
        end)
        tabBtn.MouseLeave:Connect(function()
            if ACTIVE_TAB ~= tabObj then
                tabBtn.BackgroundColor3 = C.Surface2
                tabBtn.TextColor3 = C.Dim
            end
        end)
        onActivated(tabBtn, function()
            selectTab(tabObj)
        end)

        if #TABS == 1 then selectTab(tabObj) end

        local TabObj = {}

        local function createGroupbox(sTitle, isRight)
            local container = isRight and rightContainer or leftContainer

            local gbFrame = make("Frame", {
                Name = "Groupbox",
                Size = UDim2.new(1, 0, 0, 0),
                BackgroundColor3 = C.Surface,
                BackgroundTransparency = WIN_ALPHA,
                AutomaticSize = Enum.AutomaticSize.Y,
                ClipsDescendants = false,
            }, container)
            gbFrame:SetAttribute("Title", sTitle or "")
            corner(8, gbFrame)
            stroke(C.Border, 1, gbFrame)

            local gbInner = make("Frame", {
                Size = UDim2.new(1, 0, 0, 0),
                BackgroundTransparency = 1,
                AutomaticSize = Enum.AutomaticSize.Y,
                ClipsDescendants = false,
            }, gbFrame)
            gbInner.AutomaticSize = Enum.AutomaticSize.Y
            pad(10, 10, 12, 12, gbInner)
            listLayout(Enum.FillDirection.Vertical, 6, gbInner)

            if sTitle and sTitle ~= "" then
                local hdrRow = make("Frame", {
                    Size = UDim2.new(1, 0, 0, 22),
                    BackgroundTransparency = 1,
                    LayoutOrder = 0,
                }, gbInner)

                make("TextLabel", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = sTitle:upper(),
                    TextColor3 = C.Muted,
                    Font = Enum.Font.GothamBold,
                    TextSize = 8,
                    TextXAlignment = Enum.TextXAlignment.Left,
                }, hdrRow)

                make("Frame", {
                    Size = UDim2.new(1, 0, 0, 1),
                    Position = UDim2.new(0, 0, 1, -1),
                    BackgroundColor3 = C.Border,
                }, hdrRow)
            end

            return gbFrame, gbInner
        end

        function TabObj:AddLeftGroupbox(sTitle)
            local gbFrame, gbInner = createGroupbox(sTitle, false)
            return self:_createSectionObj(gbInner, gbFrame)
        end

        function TabObj:AddRightGroupbox(sTitle)
            local gbFrame, gbInner = createGroupbox(sTitle, true)
            return self:_createSectionObj(gbInner, gbFrame)
        end

        function TabObj:_createSectionObj(secInner, gbFrame)
            local SectionObj = {}
            local orderCount = 1

            local function nextOrder()
                orderCount = orderCount + 1
                return orderCount
            end

            local function makeRow(h)
                return make("Frame", {
                    Size = UDim2.new(1, 0, 0, h or 32),
                    BackgroundTransparency = 1,
                    LayoutOrder = nextOrder(),
                    ClipsDescendants = false,
                }, secInner)
            end

            function SectionObj:AddButton(opts)
                opts = opts or {}
                local row = makeRow(32)
                local b = make("TextButton", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundColor3 = C.Surface2,
                    Text = opts.Text or "Button",
                    TextColor3 = C.Text,
                    Font = Enum.Font.GothamBold,
                    TextSize = 11,
                    AutoButtonColor = false,
                }, row)
                corner(6, b)
                stroke(C.Border, 1, b)

                b.MouseEnter:Connect(function()
                    tween(b, 0.12, {BackgroundColor3 = C.Surface3})
                end)
                b.MouseLeave:Connect(function()
                    tween(b, 0.12, {BackgroundColor3 = C.Surface2})
                end)
                onActivated(b, function()
                    tween(b, 0.06, {BackgroundColor3 = C.Border})
                    task.delay(0.1, function()
                        tween(b, 0.1, {BackgroundColor3 = C.Surface2})
                    end)
                    if opts.Callback then opts.Callback() end
                end)
                return b
            end

            function SectionObj:AddToggle(opts)
                opts = opts or {}
                local val = opts.Default or false
                local row = makeRow(32)
                local bg = make("Frame", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundColor3 = C.Surface2,
                }, row)
                corner(6, bg)
                stroke(C.Border, 1, bg)

                make("TextLabel", {
                    Size = UDim2.new(1, -54, 1, 0),
                    Position = UDim2.new(0, 10, 0, 0),
                    BackgroundTransparency = 1,
                    Text = opts.Text or "Toggle",
                    TextColor3 = C.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                }, bg)

                local pill = make("Frame", {
                    Size = UDim2.new(0, 36, 0, 18),
                    Position = UDim2.new(1, -46, 0.5, -9),
                    BackgroundColor3 = val and C.Green or C.Surface3,
                }, bg)
                corner(9, pill)
                stroke(C.Border, 1, pill)

                local knob = make("Frame", {
                    Size = UDim2.new(0, 12, 0, 12),
                    Position = val and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6),
                    BackgroundColor3 = C.White,
                }, pill)
                corner(6, knob)

                local function setToggle(v)
                    val = v
                    tween(pill, 0.15, {BackgroundColor3 = v and C.Green or C.Surface3})
                    tween(knob, 0.15, {
                        Position = v and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
                    })
                    if opts.Callback then opts.Callback(v) end
                end

                onActivated(bg, function()
                    setToggle(not val)
                end)

                local ctrl = {}
                function ctrl:Set(v) setToggle(v) end
                function ctrl:Get() return val end
                return ctrl
            end

            function SectionObj:AddKeybind(opts)
                opts = opts or {}
                local currentKey = opts.Default or Enum.KeyCode.Unknown
                local listening = false
                local row = makeRow(32)
                local bg = make("Frame", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundColor3 = C.Surface2,
                }, row)
                corner(6, bg)
                stroke(C.Border, 1, bg)

                make("TextLabel", {
                    Size = UDim2.new(1, -100, 1, 0),
                    Position = UDim2.new(0, 10, 0, 0),
                    BackgroundTransparency = 1,
                    Text = opts.Text or "Keybind",
                    TextColor3 = C.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                }, bg)

                local keyBtn = make("TextButton", {
                    Size = UDim2.new(0, 80, 0, 22),
                    Position = UDim2.new(1, -90, 0.5, -11),
                    BackgroundColor3 = C.Surface3,
                    Text = "[" .. tostring(currentKey):gsub("Enum.KeyCode.", "") .. "]",
                    TextColor3 = C.Dim,
                    Font = Enum.Font.GothamBold,
                    TextSize = 9,
                    AutoButtonColor = false,
                }, bg)
                corner(5, keyBtn)
                stroke(C.Border, 1, keyBtn)

                onActivated(keyBtn, function()
                    listening = true
                    keyBtn.Text = "[ ... ]"
                    keyBtn.TextColor3 = C.Muted
                end)

                UserInputService.InputBegan:Connect(function(inp, gp)
                    if gp then return end
                    if listening and inp.UserInputType == Enum.UserInputType.Keyboard then
                        currentKey = inp.KeyCode
                        keyBtn.Text = "[" .. tostring(inp.KeyCode):gsub("Enum.KeyCode.", "") .. "]"
                        keyBtn.TextColor3 = C.Dim
                        listening = false
                        if opts.Callback then opts.Callback(currentKey) end
                    end
                end)

                local ctrl = {}
                function ctrl:Get() return currentKey end
                return ctrl
            end

            function SectionObj:AddInput(opts)
                opts = opts or {}
                local row = makeRow(32)
                local bg = make("Frame", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundColor3 = C.Surface2,
                }, row)
                corner(6, bg)
                stroke(C.Border, 1, bg)

                make("TextLabel", {
                    Size = UDim2.new(0.45, 0, 1, 0),
                    Position = UDim2.new(0, 10, 0, 0),
                    BackgroundTransparency = 1,
                    Text = opts.Text or "Input",
                    TextColor3 = C.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                }, bg)

                local box = make("TextBox", {
                    Size = UDim2.new(0.5, -10, 0, 22),
                    Position = UDim2.new(0.5, 0, 0.5, -11),
                    BackgroundColor3 = C.Surface3,
                    Text = opts.Default or "",
                    PlaceholderText = opts.Placeholder or "...",
                    TextColor3 = C.Text,
                    PlaceholderColor3 = C.Muted,
                    Font = Enum.Font.Gotham,
                    TextSize = 11,
                    ClearTextOnFocus = true,
                }, bg)
                corner(5, box)
                stroke(C.Border, 1, box)
                pad(0, 0, 8, 8, box)

                box.FocusLost:Connect(function()
                    if opts.Callback then opts.Callback(box.Text) end
                end)

                local ctrl = {}
                function ctrl:Get() return box.Text end
                function ctrl:Set(v) box.Text = tostring(v) end
                return ctrl
            end

            function SectionObj:AddParagraph(opts)
                opts = opts or {}
                local row = make("Frame", {
                    Size = UDim2.new(1, 0, 0, 0),
                    BackgroundColor3 = C.Surface2,
                    AutomaticSize = Enum.AutomaticSize.Y,
                    LayoutOrder = nextOrder(),
                }, secInner)
                corner(6, row)
                stroke(C.Border, 1, row)
                pad(8, 8, 10, 10, row)
                row.AutomaticSize = Enum.AutomaticSize.Y

                local inner = make("Frame", {
                    Size = UDim2.new(1, 0, 0, 0),
                    BackgroundTransparency = 1,
                    AutomaticSize = Enum.AutomaticSize.Y,
                }, row)
                inner.AutomaticSize = Enum.AutomaticSize.Y
                listLayout(Enum.FillDirection.Vertical, 4, inner)

                if opts.Title and opts.Title ~= "" then
                    make("TextLabel", {
                        Size = UDim2.new(1, 0, 0, 14),
                        BackgroundTransparency = 1,
                        Text = opts.Title,
                        TextColor3 = C.White,
                        Font = Enum.Font.GothamBold,
                        TextSize = 11,
                        TextXAlignment = Enum.TextXAlignment.Left,
                    }, inner)
                end

                local bodyLbl = make("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 0),
                    BackgroundTransparency = 1,
                    Text = opts.Body or "",
                    TextColor3 = C.Dim,
                    Font = Enum.Font.Gotham,
                    TextSize = 10,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextWrapped = true,
                    AutomaticSize = Enum.AutomaticSize.Y,
                }, inner)
                bodyLbl.AutomaticSize = Enum.AutomaticSize.Y

                local ctrl = {}
                function ctrl:SetBody(v) bodyLbl.Text = tostring(v) end
                return ctrl
            end

            function SectionObj:AddDropdown(opts)
                opts = opts or {}
                local options = opts.Options or {}
                local selected = opts.Default or (options[1] or "")
                local row = makeRow(34)
                row.ClipsDescendants = false

                local bg = make("Frame", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundColor3 = C.Surface2,
                    ClipsDescendants = false,
                }, row)
                corner(6, bg)
                stroke(C.Border, 1, bg)

                make("TextLabel", {
                    Size = UDim2.new(1, -40, 1, 0),
                    Position = UDim2.new(0, 10, 0, 0),
                    BackgroundTransparency = 1,
                    Text = opts.Text or "Dropdown",
                    TextColor3 = C.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                }, bg)

                local dropBtn = make("TextButton", {
                    Size = UDim2.new(0, 100, 0, 24),
                    Position = UDim2.new(1, -110, 0.5, -12),
                    BackgroundColor3 = C.Surface3,
                    Text = selected,
                    TextColor3 = C.Text,
                    Font = Enum.Font.GothamBold,
                    TextSize = 10,
                    AutoButtonColor = false,
                    ClipsDescendants = false,
                }, bg)
                corner(5, dropBtn)
                stroke(C.Border, 1, dropBtn)

                local dropArrow = make("TextLabel", {
                    Size = UDim2.new(0, 20, 0, 24),
                    Position = UDim2.new(1, -20, 0, 0),
                    BackgroundTransparency = 1,
                    Text = "v",
                    TextColor3 = C.Dim,
                    Font = Enum.Font.GothamBold,
                    TextSize = 10,
                }, dropBtn)

                local dropFrame = make("Frame", {
                    Size = UDim2.new(0, 100, 0, 0),
                    BackgroundColor3 = C.Surface3,
                    Visible = false,
                    ZIndex = 200,
                    AutomaticSize = Enum.AutomaticSize.Y,
                }, WIN)
                corner(6, dropFrame)
                stroke(C.Border, 1, dropFrame)
                listLayout(Enum.FillDirection.Vertical, 1, dropFrame)
                pad(2, 2, 2, 2, dropFrame)

                local open = false

                local function refreshOptions()
                    for _, child in pairs(dropFrame:GetChildren()) do
                        if child:IsA("TextButton") then child:Destroy() end
                    end
                    for _, opt in pairs(options) do
                        local optBtn = make("TextButton", {
                            Size = UDim2.new(1, 0, 0, 26),
                            BackgroundColor3 = C.Surface3,
                            Text = opt,
                            TextColor3 = (opt == selected) and C.Green or C.Text,
                            Font = Enum.Font.Gotham,
                            TextSize = 10,
                            AutoButtonColor = false,
                            ZIndex = 201,
                        }, dropFrame)
                        corner(4, optBtn)

                        optBtn.MouseEnter:Connect(function()
                            if opt ~= selected then
                                tween(optBtn, 0.1, {BackgroundColor3 = C.Surface2})
                            end
                        end)
                        optBtn.MouseLeave:Connect(function()
                            if opt ~= selected then
                                tween(optBtn, 0.1, {BackgroundColor3 = C.Surface3})
                            end
                        end)
                        onActivated(optBtn, function()
                            selected = opt
                            dropBtn.Text = selected
                            open = false
                            dropFrame.Visible = false
                            dropArrow.Text = "v"
                            if opts.Callback then opts.Callback(selected) end
                        end)
                    end
                end
                refreshOptions()

                local function repositionDrop()
                    local winPos = WIN.AbsolutePosition
                    local btnPos = dropBtn.AbsolutePosition
                    local btnSize = dropBtn.AbsoluteSize
                    local relX = btnPos.X - winPos.X
                    local relY = btnPos.Y - winPos.Y + btnSize.Y + 4
                    dropFrame.Position = UDim2.new(0, relX, 0, relY)
                    dropFrame.Size = UDim2.new(0, btnSize.X, 0, 0)
                end

                onActivated(dropBtn, function()
                    open = not open
                    dropArrow.Text = open and "^" or "v"
                    if open then
                        refreshOptions()
                        repositionDrop()
                        dropFrame.Visible = true
                    else
                        dropFrame.Visible = false
                    end
                end)

                local ctrl = {}
                function ctrl:Set(v)
                    selected = v
                    dropBtn.Text = selected
                    if opts.Callback then opts.Callback(selected) end
                end
                function ctrl:Get() return selected end
                function ctrl:Refresh(newOpts)
                    options = newOpts
                    refreshOptions()
                end
                return ctrl
            end

            function SectionObj:AddSlider(opts)
                opts = opts or {}
                local min = opts.Min or 0
                local max = opts.Max or 100
                local val = opts.Default or min
                local row = makeRow(40)
                local bg = make("Frame", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundColor3 = C.Surface2,
                }, row)
                corner(6, bg)
                stroke(C.Border, 1, bg)

                make("TextLabel", {
                    Size = UDim2.new(0.5, 0, 0, 14),
                    Position = UDim2.new(0, 10, 0, 4),
                    BackgroundTransparency = 1,
                    Text = opts.Text or "Slider",
                    TextColor3 = C.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                }, bg)

                local valLbl = make("TextLabel", {
                    Size = UDim2.new(0.5, 0, 0, 14),
                    Position = UDim2.new(0.5, -10, 0, 4),
                    BackgroundTransparency = 1,
                    Text = tostring(val),
                    TextColor3 = C.Dim,
                    Font = Enum.Font.GothamBold,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Right,
                }, bg)

                local sliderBG2 = make("Frame", {
                    Size = UDim2.new(1, -20, 0, 6),
                    Position = UDim2.new(0, 10, 0, 24),
                    BackgroundColor3 = C.Surface3,
                }, bg)
                corner(3, sliderBG2)
                stroke(C.Border2, 1, sliderBG2)

                local sliderFill2 = make("Frame", {
                    Size = UDim2.new((val - min) / (max - min), 0, 1, 0),
                    BackgroundColor3 = C.White,
                }, sliderBG2)
                corner(3, sliderFill2)

                local sliderKnob = make("Frame", {
                    Size = UDim2.new(0, 12, 0, 12),
                    Position = UDim2.new((val - min) / (max - min), -6, 0.5, -6),
                    BackgroundColor3 = C.White,
                    ZIndex = 2,
                }, sliderBG2)
                corner(6, sliderKnob)

                local draggingSlider = false
                local function setSlider(newVal)
                    val = math.clamp(newVal, min, max)
                    local percent = (val - min) / (max - min)
                    sliderFill2.Size = UDim2.new(percent, 0, 1, 0)
                    sliderKnob.Position = UDim2.new(percent, -6, 0.5, -6)
                    valLbl.Text = tostring(math.floor(val * 100) / 100)
                    if opts.Callback then opts.Callback(val) end
                end

                sliderBG2.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1
                    or inp.UserInputType == Enum.UserInputType.Touch then
                        draggingSlider = true
                    end
                end)
                UserInputService.InputEnded:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1
                    or inp.UserInputType == Enum.UserInputType.Touch then
                        draggingSlider = false
                    end
                end)
                RunService.RenderStepped:Connect(function()
                    if draggingSlider then
                        local mouseX = UserInputService:GetMouseLocation().X
                        local relX = math.clamp(
                            (mouseX - sliderBG2.AbsolutePosition.X) / sliderBG2.AbsoluteSize.X,
                            0, 1)
                        setSlider(min + relX * (max - min))
                    end
                end)

                local ctrl = {}
                function ctrl:Set(v) setSlider(v) end
                function ctrl:Get() return val end
                return ctrl
            end

            function SectionObj:AddColorPicker(opts)
                opts = opts or {}
                local color = opts.Default or Color3.fromRGB(255, 255, 255)
                local row = makeRow(32)
                row.ClipsDescendants = false

                local bg = make("Frame", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundColor3 = C.Surface2,
                    ClipsDescendants = false,
                }, row)
                corner(6, bg)
                stroke(C.Border, 1, bg)

                make("TextLabel", {
                    Size = UDim2.new(1, -50, 1, 0),
                    Position = UDim2.new(0, 10, 0, 0),
                    BackgroundTransparency = 1,
                    Text = opts.Text or "Color",
                    TextColor3 = C.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                }, bg)

                local colorPreview = make("Frame", {
                    Size = UDim2.new(0, 28, 0, 22),
                    Position = UDim2.new(1, -38, 0.5, -11),
                    BackgroundColor3 = color,
                    ClipsDescendants = false,
                }, bg)
                corner(4, colorPreview)
                stroke(C.Border, 1, colorPreview)

                local pickerOpen = false

                local pickerFrame = make("Frame", {
                    Size = UDim2.new(0, 180, 0, 120),
                    BackgroundColor3 = C.Surface,
                    Visible = false,
                    ZIndex = 200,
                }, WIN)
                corner(8, pickerFrame)
                stroke(C.Border, 1, pickerFrame)

                local rInput = make("TextBox", {
                    Size = UDim2.new(0.3, -4, 0, 24),
                    Position = UDim2.new(0, 4, 0, 4),
                    BackgroundColor3 = C.Surface2,
                    Text = tostring(math.floor(color.R * 255)),
                    TextColor3 = C.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 10,
                    ZIndex = 201,
                }, pickerFrame)
                corner(4, rInput)

                local gInput = make("TextBox", {
                    Size = UDim2.new(0.3, -4, 0, 24),
                    Position = UDim2.new(0.35, 0, 0, 4),
                    BackgroundColor3 = C.Surface2,
                    Text = tostring(math.floor(color.G * 255)),
                    TextColor3 = C.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 10,
                    ZIndex = 201,
                }, pickerFrame)
                corner(4, gInput)

                local bInput = make("TextBox", {
                    Size = UDim2.new(0.3, -4, 0, 24),
                    Position = UDim2.new(0.7, 0, 0, 4),
                    BackgroundColor3 = C.Surface2,
                    Text = tostring(math.floor(color.B * 255)),
                    TextColor3 = C.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 10,
                    ZIndex = 201,
                }, pickerFrame)
                corner(4, bInput)

                local labels = {"R", "G", "B"}
                local inputs = {rInput, gInput, bInput}
                local xOffsets = {0, 0.35, 0.7}
                for i, lbl in ipairs(labels) do
                    make("TextLabel", {
                        Size = UDim2.new(0.3, -4, 0, 14),
                        Position = UDim2.new(xOffsets[i], 4, 0, 30),
                        BackgroundTransparency = 1,
                        Text = lbl,
                        TextColor3 = C.Muted,
                        Font = Enum.Font.GothamBold,
                        TextSize = 9,
                        ZIndex = 201,
                    }, pickerFrame)
                end

                local pickerPreview = make("Frame", {
                    Size = UDim2.new(1, -8, 0, 40),
                    Position = UDim2.new(0, 4, 0, 50),
                    BackgroundColor3 = color,
                    ZIndex = 201,
                }, pickerFrame)
                corner(6, pickerPreview)

                local function updateColor()
                    local r = math.clamp(tonumber(rInput.Text) or 0, 0, 255)
                    local g = math.clamp(tonumber(gInput.Text) or 0, 0, 255)
                    local b = math.clamp(tonumber(bInput.Text) or 0, 0, 255)
                    color = Color3.fromRGB(r, g, b)
                    colorPreview.BackgroundColor3 = color
                    pickerPreview.BackgroundColor3 = color
                    if opts.Callback then opts.Callback(color) end
                end

                rInput.FocusLost:Connect(updateColor)
                gInput.FocusLost:Connect(updateColor)
                bInput.FocusLost:Connect(updateColor)

                local function repositionPicker()
                    local winPos = WIN.AbsolutePosition
                    local previewPos = colorPreview.AbsolutePosition
                    local previewSize = colorPreview.AbsoluteSize
                    local relX = previewPos.X - winPos.X - 180 + previewSize.X
                    local relY = previewPos.Y - winPos.Y + previewSize.Y + 4
                    pickerFrame.Position = UDim2.new(0, relX, 0, relY)
                end

                onActivated(colorPreview, function(inp)
                    pickerOpen = not pickerOpen
                    if pickerOpen then
                        repositionPicker()
                        pickerFrame.Visible = true
                    else
                        pickerFrame.Visible = false
                    end
                end)

                local ctrl = {}
                function ctrl:Set(c)
                    color = c
                    colorPreview.BackgroundColor3 = c
                    pickerPreview.BackgroundColor3 = c
                    rInput.Text = tostring(math.floor(c.R * 255))
                    gInput.Text = tostring(math.floor(c.G * 255))
                    bInput.Text = tostring(math.floor(c.B * 255))
                end
                function ctrl:Get() return color end
                return ctrl
            end

            return SectionObj
        end

        return TabObj
    end

    -- ==============================================================
    -- KEY SYSTEM
    -- ==============================================================
    if KeySystem then
        local KeyGui = make("ScreenGui", {
            Name = "ZeloKey",
            ResetOnSpawn = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        }, CoreGui)
        pcall(function() KeyGui.Parent = LP:WaitForChild("PlayerGui") end)

        local KeyOverlay = make("Frame", {
            Name = "KeyOverlay",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 0.6,
            ZIndex = 1000,
            Active = true,
        }, KeyGui)

        local cardHeight = KeySubTitle and 280 or 240

        local KeyCard = make("Frame", {
            Name = "Card",
            Size = UDim2.new(0, 400, 0, cardHeight),
            Position = UDim2.new(0.5, -200, 0.5, -cardHeight/2),
            BackgroundColor3 = C.Surface,
            ZIndex = 1001,
            Active = true,
        }, KeyOverlay)
        corner(12, KeyCard)
        stroke(C.Border, 1, KeyCard)

        make("TextLabel", {
            Size = UDim2.new(1, 0, 0, 30),
            Position = UDim2.new(0, 0, 0, 8),
            BackgroundTransparency = 1,
            Text = KeyTitle,
            TextColor3 = C.White,
            Font = Enum.Font.GothamBold,
            TextSize = 18,
            TextXAlignment = Enum.TextXAlignment.Center,
            ZIndex = 1002,
        }, KeyCard)

        if KeySubTitle then
            make("TextLabel", {
                Size = UDim2.new(1, 0, 0, 16),
                Position = UDim2.new(0, 0, 0, 38),
                BackgroundTransparency = 1,
                Text = KeySubTitle,
                TextColor3 = C.Muted,
                Font = Enum.Font.Gotham,
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Center,
                ZIndex = 1002,
            }, KeyCard)
        end

        local separatorY = KeySubTitle and 58 or 42
        make("Frame", {
            Size = UDim2.new(1, -40, 0, 1),
            Position = UDim2.new(0, 20, 0, separatorY),
            BackgroundColor3 = C.Border,
            ZIndex = 1002,
        }, KeyCard)

        local noteY = separatorY + 8
        make("TextLabel", {
            Size = UDim2.new(1, -40, 0, 50),
            Position = UDim2.new(0, 20, 0, noteY),
            BackgroundTransparency = 1,
            Text = KeyNote,
            TextColor3 = C.Dim,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Center,
            ZIndex = 1002,
        }, KeyCard)

        local inputY = noteY + 58
        local KeyInput = make("TextBox", {
            Size = UDim2.new(1, -40, 0, 38),
            Position = UDim2.new(0, 20, 0, inputY),
            BackgroundColor3 = C.Surface2,
            Text = "",
            PlaceholderText = "Digite a key aqui...",
            TextColor3 = C.Text,
            PlaceholderColor3 = C.Muted,
            Font = Enum.Font.Gotham,
            TextSize = 13,
            ClearTextOnFocus = false,
            ZIndex = 1002,
        }, KeyCard)
        corner(8, KeyInput)
        stroke(C.Border, 1, KeyInput)
        pad(0, 0, 12, 12, KeyInput)

        local btnY = inputY + 46
        local BtnRow = make("Frame", {
            Size = UDim2.new(1, -40, 0, 34),
            Position = UDim2.new(0, 20, 0, btnY),
            BackgroundTransparency = 1,
            ZIndex = 1002,
        }, KeyCard)

        local BtnConfirm = make("TextButton", {
            Size = UDim2.new(0.32, -4, 1, 0),
            BackgroundColor3 = C.Green,
            Text = KeyConfirmText,
            TextColor3 = C.White,
            Font = Enum.Font.GothamBold,
            TextSize = 12,
            AutoButtonColor = false,
            ZIndex = 1002,
        }, BtnRow)
        corner(8, BtnConfirm)

        local BtnGetKey = make("TextButton", {
            Size = UDim2.new(0.32, -4, 1, 0),
            Position = UDim2.new(0.34, 0, 0, 0),
            BackgroundColor3 = C.Blue,
            Text = KeyGetText,
            TextColor3 = C.White,
            Font = Enum.Font.GothamBold,
            TextSize = 12,
            AutoButtonColor = false,
            ZIndex = 1002,
            Visible = GetKeyLink ~= nil,
        }, BtnRow)
        corner(8, BtnGetKey)

        local BtnClose = make("TextButton", {
            Size = UDim2.new(0.32, -4, 1, 0),
            Position = UDim2.new(0.68, 0, 0, 0),
            BackgroundColor3 = C.Surface3,
            Text = KeyCloseText,
            TextColor3 = C.Dim,
            Font = Enum.Font.GothamBold,
            TextSize = 12,
            AutoButtonColor = false,
            ZIndex = 1002,
        }, BtnRow)
        corner(8, BtnClose)
        stroke(C.Border, 1, BtnClose)

        local savedKey = nil
        if SaveKey then
            pcall(function()
                if writefile and readfile then
                    local keyFile = SaveFileName .. ".txt"
                    if isfile(keyFile) then
                        savedKey = readfile(keyFile)
                    end
                end
            end)
        end

        if savedKey and savedKey == ValidKey then
            KeyGui:Destroy()
            WIN.Visible = true
            WIN_VISIBLE = true
            setBlur(true)
            Zelo:Notify({
                Title = KeyTitle,
                Text = "Key carregada automaticamente!",
                Duration = 3,
                Type = "success"
            })
        end

        onActivated(BtnConfirm, function()
            if KeyInput.Text == ValidKey then
                KeyGui:Destroy()
                WIN.Visible = true
                WIN_VISIBLE = true
                setBlur(true)
                if SaveKey then
                    pcall(function()
                        if writefile then
                            local keyFile = SaveFileName .. ".txt"
                            writefile(keyFile, ValidKey)
                        end
                    end)
                end
                Zelo:Notify({
                    Title = "Sucesso!",
                    Text = "Key validada com sucesso!",
                    Duration = 3,
                    Type = "success"
                })
            else
                KeyInput.Text = ""
                KeyInput.PlaceholderText = "Key incorreta!"
                KeyInput.PlaceholderColor3 = C.Red
                tween(KeyCard, 0.05, {Position = UDim2.new(0.5, -198, 0.5, -cardHeight/2)})
                task.delay(0.05, function()
                    tween(KeyCard, 0.05, {Position = UDim2.new(0.5, -200, 0.5, -cardHeight/2)})
                end)
                Zelo:Notify({
                    Title = "Erro",
                    Text = "Key incorreta! Tente novamente.",
                    Duration = 3,
                    Type = "error"
                })
            end
        end)

        if GetKeyLink then
            onActivated(BtnGetKey, function()
                pcall(function() setclipboard(GetKeyLink) end)
                BtnGetKey.Text = "Copiado!"
                task.delay(1.5, function() BtnGetKey.Text = KeyGetText end)
            end)
        end

        onActivated(BtnClose, function()
            KeyGui:Destroy()
            MAIN_GUI:Destroy()
            if BLUR_OBJ then BLUR_OBJ:Destroy() end
        end)
    end

    -- ==============================================================
    -- DISCORD (sem key system)
    -- ==============================================================
    if Discord and not KeySystem then
        local DiscordGui = make("ScreenGui", {
            Name = "ZeloDiscord",
            ResetOnSpawn = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        }, CoreGui)
        pcall(function() DiscordGui.Parent = LP:WaitForChild("PlayerGui") end)

        local DiscordOverlay = make("Frame", {
            Name = "DiscordOverlay",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 0.6,
            ZIndex = 1000,
            Active = true,
        }, DiscordGui)

        local DCard = make("Frame", {
            Name = "Card",
            Size = UDim2.new(0, 400, 0, 200),
            Position = UDim2.new(0.5, -200, 0.5, -100),
            BackgroundColor3 = C.Surface,
            ZIndex = 1001,
            Active = true,
        }, DiscordOverlay)
        corner(12, DCard)
        stroke(C.Border, 1, DCard)

        make("TextLabel", {
            Size = UDim2.new(1, 0, 0, 40),
            BackgroundTransparency = 1,
            Text = Title,
            TextColor3 = C.White,
            Font = Enum.Font.GothamBold,
            TextSize = 18,
            TextXAlignment = Enum.TextXAlignment.Center,
            ZIndex = 1002,
        }, DCard)

        make("TextLabel", {
            Size = UDim2.new(1, -40, 0, 60),
            Position = UDim2.new(0, 20, 0, 50),
            BackgroundTransparency = 1,
            Text = DiscordText,
            TextColor3 = C.Dim,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Center,
            ZIndex = 1002,
        }, DCard)

        local DCopy = make("TextButton", {
            Size = UDim2.new(0.48, -5, 0, 34),
            Position = UDim2.new(0, 20, 0, 120),
            BackgroundColor3 = C.Blue,
            Text = "Copiar Invite",
            TextColor3 = C.White,
            Font = Enum.Font.GothamBold,
            TextSize = 12,
            AutoButtonColor = false,
            ZIndex = 1002,
        }, DCard)
        corner(8, DCopy)

        local DClose = make("TextButton", {
            Size = UDim2.new(0.48, -5, 0, 34),
            Position = UDim2.new(0.52, 5, 0, 120),
            BackgroundColor3 = C.Surface3,
            Text = "Fechar",
            TextColor3 = C.Dim,
            Font = Enum.Font.GothamBold,
            TextSize = 12,
            AutoButtonColor = false,
            ZIndex = 1002,
        }, DCard)
        corner(8, DClose)
        stroke(C.Border, 1, DClose)

        onActivated(DCopy, function()
            pcall(function() setclipboard(Discord) end)
            DCopy.Text = "Copiado!"
            task.delay(1.5, function() DCopy.Text = "Copiar Invite" end)
        end)

        onActivated(DClose, function()
            DiscordGui:Destroy()
            WIN.Visible = true
            WIN_VISIBLE = true
            setBlur(true)
        end)
    end

    if not KeySystem and not Discord then
        WIN.Visible = true
        WIN_VISIBLE = true
        setBlur(true)
    end

    print("[Zelo] Library v2.3.0 carregada | " .. NAME)
    return WindowObj
end

return Zelo
