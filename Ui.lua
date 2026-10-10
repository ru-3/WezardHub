local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local Defaults = {
    Name = "Wezard Hub",
    MapName = "Your Map",
    Update = "Halloween Update",
    Size = Vector2.new(650, 350),
    TabSize = Vector2.new(100, 30),
    ControlSize = Vector2.new(110, 32),
    BackgroundId = "80147053215390",
    HeaderFontId = "12187375194",
    ContentFontId = "113086061264643",
    ToggleKey = Enum.KeyCode.RightShift,
    MinimumScale = 0.15,
    MaximumScale = 1,
    MaxNotifications = 4,
    NotificationDuration = 5,
    ClosePrompt = "Are You Sure Wannna Close Script?",
    Colors = {
        Background = Color3.fromRGB(10, 10, 12),
        Surface = Color3.fromRGB(22, 22, 25),
        Raised = Color3.fromRGB(33, 30, 28),
        Orange = Color3.fromRGB(255, 132, 26),
        OrangeDeep = Color3.fromRGB(172, 70, 12),
        White = Color3.fromRGB(250, 246, 240),
        Muted = Color3.fromRGB(177, 171, 166),
        Border = Color3.fromRGB(65, 45, 31),
    },
}
local Library = {}
local Window = {}
Window.__index = Window
local Tab = {}
Tab.__index = Tab
local Section = {}
Section.__index = Section

local function make(class, properties, parent)
    local object = Instance.new(class)
    for key, value in pairs(properties or {}) do
        object[key] = value
    end
    object.Parent = parent
    return object
end

local function round(parent, radius)
    local corner = parent:FindFirstChildOfClass("UICorner")
    if corner then
        corner.CornerRadius = UDim.new(0, radius or 8)
        return corner
    end
    return make("UICorner", {CornerRadius = UDim.new(0, radius or 8)}, parent)
end

local function stroke(parent, color, transparency)
    return make("UIStroke", {Color = color, Thickness = 1, Transparency = transparency or 0.35, ApplyStrokeMode = Enum.ApplyStrokeMode.Border}, parent)
end

local function font(id)
    local ok, result = pcall(Font.new, "rbxassetid://" .. tostring(id))
    if ok then
        return result
    end
    return Font.new("rbxasset://fonts/families/SourceSansPro.json")
end

local function copy(value)
    if type(value) ~= "table" then
        return value
    end
    local result = {}
    for key, child in pairs(value) do
        result[key] = copy(child)
    end
    return result
end

local function merge(base, override)
    local result = copy(base)
    for key, value in pairs(override or {}) do
        if type(value) == "table" and type(result[key]) == "table" then
            result[key] = merge(result[key], value)
        else
            result[key] = value
        end
    end
    return result
end

local function finite(value)
    return type(value) == "number" and value == value and math.abs(value) < math.huge
end

local function icon(parent, kind, color, size)
    local root = make("Frame", {Size = UDim2.fromOffset(size or 16, size or 16), BackgroundTransparency = 1}, parent)
    local function line(x, y, width, height, rotation)
        local part = make("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(x, y), Size = UDim2.fromScale(width, height), BackgroundColor3 = color, BorderSizePixel = 0, Rotation = rotation or 0}, root)
        round(part, 2)
        return part
    end
    local function ring(x, y, width, height)
        local part = make("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(x, y), Size = UDim2.fromScale(width, height), BackgroundTransparency = 1}, root)
        round(part, 4)
        stroke(part, color, 0)
    end
    if kind == "Close" then
        line(0.5, 0.5, 0.8, 0.1, 45)
        line(0.5, 0.5, 0.8, 0.1, -45)
    elseif kind == "Minus" then
        line(0.5, 0.5, 0.75, 0.1)
    elseif kind == "Chevron" then
        line(0.35, 0.5, 0.45, 0.1, 45)
        line(0.65, 0.5, 0.45, 0.1, -45)
    elseif kind == "Check" then
        line(0.3, 0.58, 0.4, 0.12, 45)
        line(0.6, 0.48, 0.65, 0.12, -45)
    elseif kind == "Settings" or kind == "Sliders" then
        for i = 1, 3 do
            line(0.5, i * 0.25, 0.85, 0.08)
            line(i == 2 and 0.65 or 0.35, i * 0.25, 0.12, 0.24)
        end
    elseif kind == "Home" then
        line(0.3, 0.28, 0.6, 0.1, -40)
        line(0.7, 0.28, 0.6, 0.1, 40)
        line(0.2, 0.62, 0.1, 0.55)
        line(0.8, 0.62, 0.1, 0.55)
        line(0.5, 0.88, 0.7, 0.1)
        line(0.5, 0.73, 0.1, 0.3)
    elseif kind == "Info" then
        ring(0.5, 0.5, 0.85, 0.85)
        line(0.5, 0.6, 0.1, 0.3)
        line(0.5, 0.3, 0.1, 0.1)
    elseif kind == "Bell" then
        ring(0.5, 0.45, 0.55, 0.65)
        line(0.5, 0.78, 0.85, 0.1)
        line(0.5, 0.94, 0.2, 0.1)
    elseif kind == "Player" then
        ring(0.5, 0.25, 0.35, 0.35)
        ring(0.5, 0.75, 0.7, 0.4)
    elseif kind == "Eye" then
        ring(0.5, 0.5, 0.95, 0.55)
        line(0.5, 0.5, 0.17, 0.17)
    else
        for x = 0, 1 do
            for y = 0, 1 do
                ring(0.25 + x * 0.5, 0.25 + y * 0.5, 0.3, 0.3)
            end
        end
    end
    return root
end

function Window:_connect(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(self.Connections, connection)
    return connection
end

function Window:_tween(object, properties, duration)
    if self.Destroyed or not object.Parent then
        return nil
    end
    local tween = TweenService:Create(object, TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), properties)
    tween:Play()
    return tween
end

function Window:_call(callback, ...)
    if type(callback) ~= "function" or self.Destroyed then
        return
    end
    local arguments = table.pack(...)
    task.spawn(function()
        if self.Destroyed then
            return
        end
        local ok, message = pcall(callback, table.unpack(arguments, 1, arguments.n))
        if not ok and not self.Destroyed then
            warn("Wezard Hub callback: " .. tostring(message))
            self:Notify({Title = "Action failed", Text = "The script action could not finish.", Duration = 5})
        end
    end)
end

function Window:_text(parent, text, properties)
    return make("TextLabel", merge({BackgroundTransparency = 1, Text = tostring(text or ""), FontFace = self.ContentFont, TextSize = 13, TextColor3 = self.Colors.White, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd}, properties), parent)
end

function Window:_button(parent, text, properties)
    local button = make("TextButton", merge({BackgroundColor3 = self.Colors.Raised, BorderSizePixel = 0, AutoButtonColor = false, Text = text or "", FontFace = self.ContentFont, TextSize = 13, TextColor3 = self.Colors.White}, properties), parent)
    round(button)
    stroke(button, self.Colors.Border)
    self:_connect(button.MouseEnter, function()
        self:_tween(button, {BackgroundColor3 = self.Colors.OrangeDeep})
    end)
    self:_connect(button.MouseLeave, function()
        self:_tween(button, {BackgroundColor3 = self.Colors.Raised})
    end)
    return button
end

function Window:_iconButton(parent, name, position)
    local button = self:_button(parent, "", {Name = name, Position = position, Size = UDim2.fromOffset(28, 28)})
    local glyph = icon(button, name, self.Colors.White, 14)
    glyph.AnchorPoint = Vector2.new(0.5, 0.5)
    glyph.Position = UDim2.fromScale(0.5, 0.5)
    local tooltip = self:_text(button, name == "Minus" and "Hide" or "Close", {AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 1, 5), Size = UDim2.fromOffset(60, 22), BackgroundTransparency = 0, BackgroundColor3 = self.Colors.Surface, TextXAlignment = Enum.TextXAlignment.Center, Visible = false, ZIndex = 80})
    round(tooltip, 4)
    self:_connect(button.MouseEnter, function() tooltip.Visible = true end)
    self:_connect(button.MouseLeave, function() tooltip.Visible = false end)
    return button
end

function Window:_drag(handle, target, onClick)
    local active, startPointer, startPosition, moved
    self:_connect(handle.InputBegan, function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end
        if self.Modal.Visible and target == self.Main then
            return
        end
        active = input
        startPointer = Vector2.new(input.Position.X, input.Position.Y)
        startPosition = Vector2.new(target.Position.X.Offset, target.Position.Y.Offset)
        moved = false
    end)
    self:_connect(UserInputService.InputChanged, function(input)
        if not active then return end
        if active.UserInputType == Enum.UserInputType.Touch and input ~= active then return end
        if active.UserInputType == Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        local delta = Vector2.new(input.Position.X, input.Position.Y) - startPointer
        if delta.Magnitude > 5 then moved = true end
        if moved then
            local bounds = self.Root.AbsoluteSize
            local rendered = target.AbsoluteSize
            local anchor = target.AnchorPoint
            local point = startPosition + delta
            target.Position = UDim2.fromOffset(math.clamp(point.X, rendered.X * anchor.X, math.max(rendered.X * anchor.X, bounds.X - rendered.X * (1 - anchor.X))), math.clamp(point.Y, rendered.Y * anchor.Y, math.max(rendered.Y * anchor.Y, bounds.Y - rendered.Y * (1 - anchor.Y))))
        end
    end)
    self:_connect(UserInputService.InputEnded, function(input)
        if input ~= active then return end
        local clicked = not moved
        active = nil
        if clicked and onClick then onClick() end
    end)
end

function Library.new(options)
    local player = Players.LocalPlayer
    assert(player, "Wezard Hub must run from a LocalScript on the client.")
    local config = merge(Defaults, options)
    assert(typeof(config.Size) == "Vector2" and config.Size.X > 0 and config.Size.Y > 0, "Size must be a positive Vector2.")
    local self = setmetatable({Config = config, Colors = config.Colors, Connections = {}, Tabs = {}, Controls = {}, Flags = {}, Notifications = {}, Destroyed = false, Visible = true}, Window)
    self.HeaderFont = font(config.HeaderFontId)
    self.ContentFont = font(config.ContentFontId)
    self.Root = make("ScreenGui", {Name = "WezardHub", ResetOnSpawn = false, IgnoreGuiInset = false, ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 100}, config.Parent or player:WaitForChild("PlayerGui"))
    self.Main = make("CanvasGroup", {Name = "Window", AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(config.Size.X, config.Size.Y), BackgroundColor3 = self.Colors.Background, BorderSizePixel = 0, ClipsDescendants = true}, self.Root)
    round(self.Main, 8)
    stroke(self.Main, self.Colors.Orange, 0.25)
    self.Scale = make("UIScale", {Scale = 1}, self.Main)
    make("ImageLabel", {Name = "HalloweenBackground", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Image = "rbxassetid://" .. config.BackgroundId, ImageTransparency = 0.35, ScaleType = Enum.ScaleType.Crop}, self.Main)
    make("Frame", {Size = UDim2.fromScale(1, 1), BackgroundColor3 = self.Colors.Background, BackgroundTransparency = 0.18, BorderSizePixel = 0}, self.Main)
    local header = make("Frame", {Name = "Header", Size = UDim2.new(1, 0, 0, 54), BackgroundColor3 = self.Colors.Background, BackgroundTransparency = 0.2, BorderSizePixel = 0, Active = true}, self.Main)
    self.Title = self:_text(header, config.Name .. " • " .. config.MapName .. " • " .. config.Update, {Position = UDim2.fromOffset(18, 12), Size = UDim2.new(1, -112, 0, 29), FontFace = self.HeaderFont, TextSize = 18})
    local hide = self:_iconButton(header, "Minus", UDim2.new(1, -76, 0, 13))
    local close = self:_iconButton(header, "Close", UDim2.new(1, -42, 0, 13))
    local rule = make("Frame", {Position = UDim2.fromOffset(0, 53), Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = self.Colors.Orange, BorderSizePixel = 0}, header)
    make("UIGradient", {Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.85), NumberSequenceKeypoint.new(0.5, 0.1), NumberSequenceKeypoint.new(1, 0.85)})}, rule)
    self.TabList = make("ScrollingFrame", {Name = "Tabs", Position = UDim2.fromOffset(12, 68), Size = UDim2.new(0, config.TabSize.X + 8, 1, -105), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 2, ScrollBarImageColor3 = self.Colors.Orange, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollingDirection = Enum.ScrollingDirection.Y}, self.Main)
    make("UIPadding", {PaddingLeft = UDim.new(0, 2), PaddingTop = UDim.new(0, 2), PaddingBottom = UDim.new(0, 4)}, self.TabList)
    make("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder}, self.TabList)
    local dividerX = config.TabSize.X + 28
    make("Frame", {Position = UDim2.fromOffset(dividerX, 64), Size = UDim2.new(0, 1, 1, -102), BackgroundColor3 = self.Colors.Border, BorderSizePixel = 0}, self.Main)
    self.Pages = make("Frame", {Name = "Pages", Position = UDim2.fromOffset(dividerX + 14, 67), Size = UDim2.new(1, -dividerX - 30, 1, -105), BackgroundTransparency = 1}, self.Main)
    self.Footer = self:_text(self.Main, "HALLOWEEN EDITION", {Position = UDim2.new(0, 18, 1, -28), Size = UDim2.new(1, -90, 0, 17), TextSize = 10, TextColor3 = self.Colors.Muted})
    self.Dots = {}
    for i = 1, 3 do
        local dot = make("Frame", {Position = UDim2.new(1, -60 + (i - 1) * 14, 1, -23), Size = UDim2.fromOffset(6, 6), BackgroundColor3 = i == 2 and self.Colors.Background or self.Colors.Orange, BorderSizePixel = 0}, self.Main)
        round(dot, 6)
        stroke(dot, self.Colors.Orange, 0.3)
        table.insert(self.Dots, dot)
    end
    self.Floating = self:_button(self.Root, "", {Name = "VisibilityToggle", Size = UDim2.fromOffset(46, 46), Position = UDim2.fromOffset(24, 110), ZIndex = 90})
    round(self.Floating, 23)
    local floatingIcon = icon(self.Floating, "Eye", self.Colors.Orange, 24)
    floatingIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    floatingIcon.Position = UDim2.fromScale(0.5, 0.5)
    self.Overlay = make("Frame", {Name = "DropdownOverlay", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 200, Visible = false}, self.Root)
    self.OverlayShield = make("TextButton", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", ZIndex = 200, AutoButtonColor = false}, self.Overlay)
    self.Modal = make("Frame", {Name = "CloseConfirmation", Size = UDim2.fromScale(1, 1), BackgroundColor3 = self.Colors.Background, BackgroundTransparency = 0.25, Visible = false, ZIndex = 300, Active = true}, self.Root)
    local blocker = make("TextButton", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, ZIndex = 300}, self.Modal)
    local dialog = make("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.new(0.9, 0, 0, 148), BackgroundColor3 = self.Colors.Surface, BorderSizePixel = 0, ZIndex = 301}, self.Modal)
    make("UISizeConstraint", {MaxSize = Vector2.new(340, 148)}, dialog)
    round(dialog, 8)
    stroke(dialog, self.Colors.Orange, 0.15)
    self:_text(dialog, config.ClosePrompt, {Position = UDim2.fromOffset(20, 18), Size = UDim2.new(1, -40, 0, 62), FontFace = self.HeaderFont, TextSize = 17, TextWrapped = true, TextTruncate = Enum.TextTruncate.None, TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 302})
    local yes = self:_button(dialog, "Yes", {Position = UDim2.new(0.5, -120, 1, -50), Size = UDim2.fromOffset(110, 32), ZIndex = 302})
    local no = self:_button(dialog, "No", {Position = UDim2.new(0.5, 10, 1, -50), Size = UDim2.fromOffset(110, 32), ZIndex = 302})
    self.NotificationZone = make("Frame", {Name = "NotificationZone", AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -8, 0, 8), Size = UDim2.new(0, 240, 1, -16), BackgroundTransparency = 1, ZIndex = 400}, self.Root)
    make("UIListLayout", {HorizontalAlignment = Enum.HorizontalAlignment.Right, VerticalAlignment = Enum.VerticalAlignment.Top, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6)}, self.NotificationZone)
    self:_connect(hide.Activated, function() self:SetVisible(false) end)
    self:_connect(close.Activated, function() self:RequestClose() end)
    self:_connect(yes.Activated, function() self:Destroy() end)
    self:_connect(no.Activated, function() self.Modal.Visible = false end)
    self:_connect(blocker.Activated, function() end)
    self:_connect(self.OverlayShield.Activated, function() self:_closeDropdown() end)
    self:_connect(UserInputService.InputBegan, function(input, processed)
        if processed or UserInputService:GetFocusedTextBox() then return end
        if input.KeyCode == Enum.KeyCode.Escape then
            self.Modal.Visible = false
            self:_closeDropdown()
        elseif input.KeyCode == config.ToggleKey and not self.Modal.Visible then
            self:SetVisible(not self.Visible)
        end
    end)
    self:_drag(header, self.Main)
    self:_drag(self.Floating, self.Floating, function()
        if not self.Modal.Visible then self:SetVisible(not self.Visible) end
    end)
    local firstResize = true
    local function resize()
        if self.Destroyed then return end
        local viewport = self.Root.AbsoluteSize
        if viewport.X < 1 or viewport.Y < 1 then return end
        local scale = math.min(config.MaximumScale, math.max(config.MinimumScale, math.min((viewport.X - 24) / config.Size.X, (viewport.Y - 24) / config.Size.Y)))
        self.Scale.Scale = scale
        self.NotificationZone.Size = UDim2.new(0, math.min(240, math.max(120, viewport.X - 16)), 1, -16)
        local actual = config.Size * scale
        local point = firstResize and viewport / 2 or Vector2.new(self.Main.Position.X.Offset, self.Main.Position.Y.Offset)
        self.Main.Position = UDim2.fromOffset(math.clamp(point.X, actual.X / 2, math.max(actual.X / 2, viewport.X - actual.X / 2)), math.clamp(point.Y, actual.Y / 2, math.max(actual.Y / 2, viewport.Y - actual.Y / 2)))
        firstResize = false
        local floating = self.Floating.Position
        self.Floating.Position = UDim2.fromOffset(math.clamp(floating.X.Offset, 0, math.max(0, viewport.X - 46)), math.clamp(floating.Y.Offset, 0, math.max(0, viewport.Y - 46)))
        self:_closeDropdown()
    end
    self:_connect(self.Root:GetPropertyChangedSignal("AbsoluteSize"), resize)
    resize()
    self:_connect(RunService.RenderStepped, function()
        if not self.Visible then return end
        local phase = os.clock() * 2
        for i, dot in ipairs(self.Dots) do
            dot.BackgroundTransparency = 0.15 + (math.sin(phase - i) + 1) * 0.25
        end
    end)
    self:_connect(self.Root.Destroying, function() self:Destroy() end)
    return self
end

function Window:SetVisible(value)
    if self.Destroyed then return end
    self.Visible = value == true
    self.Main.Visible = self.Visible
    self:_closeDropdown()
    if not self.Visible then self.Modal.Visible = false end
end

function Window:RequestClose()
    if self.Destroyed then return end
    self:_closeDropdown()
    self.Modal.Visible = true
end

function Window:SetTitle(mapName, update)
    if self.Destroyed then return end
    self.Config.MapName = tostring(mapName or self.Config.MapName)
    self.Config.Update = tostring(update or self.Config.Update)
    self.Title.Text = self.Config.Name .. " • " .. self.Config.MapName .. " • " .. self.Config.Update
end

function Window:_closeDropdown()
    if self.OpenDropdown then
        self.OpenDropdown:Destroy()
        self.OpenDropdown = nil
    end
    self.Overlay.Visible = false
end

function Window:Destroy()
    if self.Destroyed then return end
    self.Destroyed = true
    for _, connection in ipairs(self.Connections) do connection:Disconnect() end
    self.Connections = {}
    while #self.Notifications > 0 do
        local notification = table.remove(self.Notifications)
        notification.Dismiss(true)
    end
    self.Notifications = {}
    self.Controls = {}
    self.Flags = {}
    self.Tabs = {}
    if self.Root then self.Root:Destroy() end
end

function Window:AddTab(options)
    assert(not self.Destroyed, "Window is destroyed.")
    options = options or {}
    local tab = setmetatable({Window = self, Name = options.Name or "Tab", Sections = {}}, Tab)
    tab.Button = self:_button(self.TabList, "", {Name = tab.Name, Size = UDim2.fromOffset(self.Config.TabSize.X, self.Config.TabSize.Y), LayoutOrder = #self.Tabs + 1})
    local glyph = icon(tab.Button, options.Icon or "Grid", self.Colors.Orange, 14)
    glyph.Position = UDim2.fromOffset(9, 8)
    self:_text(tab.Button, tab.Name, {Position = UDim2.fromOffset(30, 0), Size = UDim2.new(1, -35, 1, 0), TextSize = 12})
    tab.Accent = make("Frame", {Size = UDim2.new(0, 2, 1, -12), Position = UDim2.fromOffset(0, 6), BackgroundColor3 = self.Colors.Orange, BorderSizePixel = 0, Visible = false}, tab.Button)
    round(tab.Accent, 2)
    tab.Page = make("ScrollingFrame", {Name = tab.Name, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3, ScrollBarImageColor3 = self.Colors.Orange, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollingDirection = Enum.ScrollingDirection.Y, Visible = false}, self.Pages)
    make("UIPadding", {PaddingLeft = UDim.new(0, 2), PaddingRight = UDim.new(0, 8), PaddingTop = UDim.new(0, 2), PaddingBottom = UDim.new(0, 12)}, tab.Page)
    make("UIListLayout", {Padding = UDim.new(0, 14), SortOrder = Enum.SortOrder.LayoutOrder}, tab.Page)
    self:_connect(tab.Button.Activated, function() tab:Select() end)
    table.insert(self.Tabs, tab)
    if #self.Tabs == 1 then tab:Select() end
    return tab
end

function Tab:Select()
    local window = self.Window
    if window.Destroyed then return end
    window:_closeDropdown()
    window.SelectedTab = self
    for _, tab in ipairs(window.Tabs) do
        local selected = tab == self
        tab.Page.Visible = selected
        tab.Accent.Visible = selected
        local outline = tab.Button:FindFirstChildOfClass("UIStroke")
        if outline then outline.Color = selected and window.Colors.Orange or window.Colors.Border end
    end
end

function Tab:AddSection(title)
    local window = self.Window
    assert(not window.Destroyed, "Window is destroyed.")
    local section = setmetatable({Window = window, Tab = self}, Section)
    section.Root = make("Frame", {Name = title or "Section", Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = #self.Sections + 1}, self.Page)
    make("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder}, section.Root)
    window:_text(section.Root, title or "Controls", {Size = UDim2.new(1, 0, 0, 24), FontFace = window.HeaderFont, TextSize = 16, TextColor3 = window.Colors.Orange, LayoutOrder = 0})
    section.Grid = make("Frame", {Name = "Controls", Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = 1}, section.Root)
    make("UIGridLayout", {CellSize = UDim2.fromOffset(window.Config.ControlSize.X, window.Config.ControlSize.Y), CellPadding = UDim2.fromOffset(10, 10), SortOrder = Enum.SortOrder.LayoutOrder}, section.Grid)
    table.insert(self.Sections, section)
    return section
end

function Section:_base(options)
    local window = self.Window
    assert(not window.Destroyed, "Window is destroyed.")
    options = options or {}
    local flag = options.Flag
    if flag then assert(window.Controls[flag] == nil, "Duplicate flag: " .. tostring(flag)) end
    local frame = window:_button(self.Grid, "", {Name = options.Name or "Control", Size = UDim2.fromOffset(window.Config.ControlSize.X, window.Config.ControlSize.Y), LayoutOrder = #self.Grid:GetChildren()})
    local control = {Instance = frame, Window = window, Flag = flag, Disabled = false, Value = nil}
    function control:Get()
        return copy(self.Value)
    end
    function control:SetDisabled(value)
        self.Disabled = value == true
        self.Instance.Active = not self.Disabled
        self.Instance.BackgroundTransparency = self.Disabled and 0.5 or 0
    end
    function control:_store(value, silent)
        self.Value = copy(value)
        if self.Flag then window.Flags[self.Flag] = copy(value) end
        if not silent then window:_call(options.Callback, copy(value)) end
    end
    if flag then window.Controls[flag] = control end
    return control, frame, options
end

function Section:AddButton(options)
    local control, frame, opts = self:_base(options)
    frame.Text = opts.Name or "Button"
    if opts.Icon then
        frame.Text = ""
        local glyph = icon(frame, opts.Icon, self.Window.Colors.Orange, 14)
        glyph.Position = UDim2.fromOffset(8, 9)
        self.Window:_text(frame, opts.Name or "Button", {Position = UDim2.fromOffset(28, 0), Size = UDim2.new(1, -33, 1, 0), TextSize = 12})
    end
    self.Window:_connect(frame.Activated, function()
        if not control.Disabled then self.Window:_call(opts.Callback) end
    end)
    return control
end

function Section:AddToggle(options)
    local control, frame, opts = self:_base(options)
    local window = self.Window
    window:_text(frame, opts.Name or "Toggle", {Position = UDim2.fromOffset(7, 0), Size = UDim2.new(1, -39, 1, 0), TextSize = 12})
    local track = make("Frame", {Position = UDim2.new(1, -30, 0.5, -7), Size = UDim2.fromOffset(24, 14), BackgroundColor3 = window.Colors.Border, BorderSizePixel = 0}, frame)
    round(track, 7)
    local knob = make("Frame", {Position = UDim2.fromOffset(2, 2), Size = UDim2.fromOffset(10, 10), BackgroundColor3 = window.Colors.White, BorderSizePixel = 0}, track)
    round(knob, 5)
    control.Kind = "Toggle"
    function control:Set(value, silent)
        if window.Destroyed then return end
        assert(type(value) == "boolean", "Toggle value must be boolean.")
        local changed = self.Value ~= value
        self:_store(value, silent or not changed)
        window:_tween(track, {BackgroundColor3 = value and window.Colors.Orange or window.Colors.Border})
        window:_tween(knob, {Position = UDim2.fromOffset(value and 12 or 2, 2)})
    end
    window:_connect(frame.Activated, function()
        if not control.Disabled then control:Set(not control.Value) end
    end)
    control:Set(opts.Default == true, true)
    return control
end

function Section:AddSlider(options)
    local control, frame, opts = self:_base(options)
    local window = self.Window
    local minimum, maximum, step = opts.Min or 0, opts.Max or 100, opts.Step or 1
    assert(finite(minimum) and finite(maximum) and maximum > minimum, "Slider Max must exceed Min.")
    assert(finite(step) and step > 0, "Slider Step must be positive.")
    window:_text(frame, opts.Name or "Slider", {Position = UDim2.fromOffset(7, 2), Size = UDim2.new(1, -41, 0, 17), TextSize = 11})
    local valueText = window:_text(frame, "", {Position = UDim2.new(1, -38, 0, 2), Size = UDim2.fromOffset(31, 17), TextSize = 10, TextColor3 = window.Colors.Orange, TextXAlignment = Enum.TextXAlignment.Right})
    local track = make("Frame", {Position = UDim2.fromOffset(8, 24), Size = UDim2.new(1, -16, 0, 3), BackgroundColor3 = window.Colors.Border, BorderSizePixel = 0}, frame)
    round(track, 2)
    local fill = make("Frame", {Size = UDim2.fromScale(0, 1), BackgroundColor3 = window.Colors.Orange, BorderSizePixel = 0}, track)
    round(fill, 2)
    local knob = make("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0, 0.5), Size = UDim2.fromOffset(7, 7), BackgroundColor3 = window.Colors.White, BorderSizePixel = 0}, track)
    round(knob, 4)
    control.Kind = "Slider"
    function control:Set(value, silent)
        if window.Destroyed then return end
        assert(finite(value), "Slider value must be finite.")
        value = math.clamp(value, minimum, maximum)
        if value ~= maximum then value = math.clamp(minimum + math.floor((value - minimum) / step + 0.5) * step, minimum, maximum) end
        value = tonumber(string.format("%.6f", value))
        local changed = self.Value ~= value
        self:_store(value, silent or not changed)
        local alpha = (value - minimum) / (maximum - minimum)
        fill.Size = UDim2.fromScale(alpha, 1)
        knob.Position = UDim2.fromScale(alpha, 0.5)
        valueText.Text = tostring(value)
    end
    local active
    local function update(input)
        if track.AbsoluteSize.X <= 0 then return end
        local alpha = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        control:Set(minimum + alpha * (maximum - minimum))
    end
    window:_connect(frame.InputBegan, function(input)
        if control.Disabled then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            active = input
            update(input)
        end
    end)
    window:_connect(UserInputService.InputChanged, function(input)
        if not active or control.Disabled then return end
        if (active.UserInputType == Enum.UserInputType.Touch and input == active) or (active.UserInputType == Enum.UserInputType.MouseButton1 and input.UserInputType == Enum.UserInputType.MouseMovement) then update(input) end
    end)
    window:_connect(UserInputService.InputEnded, function(input) if input == active then active = nil end end)
    control:Set(opts.Default or minimum, true)
    return control
end

function Section:AddDropdown(options)
    local control, frame, opts = self:_base(options)
    local window = self.Window
    local choices = {}
    local function normalize(values)
        assert(type(values) == "table", "Dropdown Options must be a table.")
        local seen, result = {}, {}
        for _, value in ipairs(values) do
            assert(type(value) == "string", "Dropdown options must be strings.")
            if not seen[value] then seen[value] = true table.insert(result, value) end
        end
        return result
    end
    choices = normalize(opts.Options or {})
    local label = window:_text(frame, opts.Name or "Dropdown", {Position = UDim2.fromOffset(7, 0), Size = UDim2.new(1, -29, 1, 0), TextSize = 12})
    local glyph = icon(frame, "Chevron", window.Colors.Orange, 12)
    glyph.Position = UDim2.new(1, -19, 0.5, -6)
    control.Kind = "Dropdown"
    control.Multi = opts.Multi == true
    function control:Set(value, silent)
        if window.Destroyed then return end
        if self.Multi then
            assert(type(value) == "table", "Multi dropdown value must be a table.")
            local selected = {}
            for _, choice in ipairs(choices) do
                if table.find(value, choice) then table.insert(selected, choice) end
            end
            value = selected
        else
            assert(value == nil or type(value) == "string", "Dropdown value must be a string or nil.")
            if value ~= nil and not table.find(choices, value) then value = nil end
        end
        local changed = HttpService:JSONEncode(self.Value) ~= HttpService:JSONEncode(value)
        self:_store(value, silent or not changed)
        local selected = self.Multi and table.concat(value, ", ") or value
        label.Text = selected and selected ~= "" and selected or opts.Name or "Select"
    end
    function control:SetOptions(values)
        choices = normalize(values)
        self:Set(self.Value, true)
        window:_closeDropdown()
    end
    local function open()
        if control.Disabled then return end
        if window.DropdownOwner == control and window.OpenDropdown then window:_closeDropdown() return end
        window:_closeDropdown()
        window.DropdownOwner = control
        window.Overlay.Visible = true
        local bounds = window.Root.AbsoluteSize
        local width = math.min(190, bounds.X - 16)
        local height = math.min(math.max(36, #choices * 32 + 8), 176, math.max(36, bounds.Y - 16))
        local position = frame.AbsolutePosition - window.Root.AbsolutePosition
        local x = math.clamp(position.X, 8, math.max(8, bounds.X - width - 8))
        local y = position.Y + frame.AbsoluteSize.Y + 4
        if y + height > bounds.Y - 8 then y = position.Y - height - 4 end
        y = math.clamp(y, 8, math.max(8, bounds.Y - height - 8))
        local popup = make("ScrollingFrame", {Name = "DropdownMenu", Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(width, height), BackgroundColor3 = window.Colors.Surface, BorderSizePixel = 0, ZIndex = 201, ScrollBarThickness = 3, ScrollBarImageColor3 = window.Colors.Orange, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollingDirection = Enum.ScrollingDirection.Y}, window.Overlay)
        window.OpenDropdown = popup
        round(popup, 8)
        stroke(popup, window.Colors.Orange, 0.2)
        make("UIPadding", {PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4), PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 6)}, popup)
        make("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2)}, popup)
        if #choices == 0 then window:_text(popup, "No options", {Size = UDim2.new(1, 0, 0, 28), ZIndex = 202}) end
        for i, choice in ipairs(choices) do
            local option = make("TextButton", {Text = choice, FontFace = window.ContentFont, TextSize = 13, TextColor3 = window.Colors.White, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, BackgroundColor3 = window.Colors.Raised, BorderSizePixel = 0, AutoButtonColor = false, Size = UDim2.new(1, 0, 0, 30), LayoutOrder = i, ZIndex = 202}, popup)
            round(option, 4)
            make("UIPadding", {PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 25)}, option)
            local mark = icon(option, "Check", window.Colors.Orange, 12)
            mark.Position = UDim2.new(1, -18, 0.5, -6)
            local function selected() return control.Multi and table.find(control.Value, choice) ~= nil or (not control.Multi and control.Value == choice) end
            mark.Visible = selected()
            option.Activated:Connect(function()
                if window.Destroyed or control.Disabled then return end
                if control.Multi then
                    local value = control:Get()
                    local index = table.find(value, choice)
                    if index then table.remove(value, index) else table.insert(value, choice) end
                    control:Set(value)
                    mark.Visible = selected()
                else
                    control:Set(choice)
                    window:_closeDropdown()
                end
            end)
        end
    end
    window:_connect(frame.Activated, open)
    control:Set(opts.Default or (control.Multi and {} or nil), true)
    return control
end

function Section:AddLabel(options)
    if type(options) == "string" then options = {Name = options} end
    local control, frame, opts = self:_base(options)
    frame.Active = false
    frame.Selectable = false
    frame.Text = opts.Text or opts.Name or "Label"
    frame.TextColor3 = self.Window.Colors.Muted
    function control:Set(text)
        if self.Window.Destroyed then return end
        self.Value = tostring(text)
        frame.Text = self.Value
    end
    control:Set(frame.Text)
    return control
end

function Section:AddTextbox(options)
    local control, frame, opts = self:_base(options)
    local window = self.Window
    frame.Active = false
    local input = make("TextBox", {Position = UDim2.fromOffset(7, 0), Size = UDim2.new(1, -14, 1, 0), BackgroundTransparency = 1, Text = "", PlaceholderText = opts.Name or "Enter text", PlaceholderColor3 = window.Colors.Muted, TextColor3 = window.Colors.White, FontFace = window.ContentFont, TextSize = 12, ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd}, frame)
    control.Kind = "Textbox"
    function control:Set(value, silent)
        if window.Destroyed then return end
        assert(type(value) == "string", "Textbox value must be a string.")
        value = string.sub(value, 1, opts.MaxLength or 128)
        local changed = self.Value ~= value
        self:_store(value, silent or not changed)
        input.Text = value
    end
    window:_connect(input.Focused, function() if control.Disabled then input:ReleaseFocus() end end)
    window:_connect(input.FocusLost, function()
        if control.Disabled then input.Text = control.Value return end
        control:Set(input.Text)
    end)
    control:Set(opts.Default or "", true)
    return control
end

function Window:ExportConfig()
    assert(not self.Destroyed, "Window is destroyed.")
    return HttpService:JSONEncode({Version = 1, Flags = self.Flags})
end

function Window:ImportConfig(json, silent)
    if self.Destroyed then return false, "Window is destroyed." end
    local ok, data = pcall(function() return HttpService:JSONDecode(json) end)
    if not ok or type(data) ~= "table" or data.Version ~= 1 or type(data.Flags) ~= "table" then return false, "Invalid Wezard Hub config." end
    for flag, value in pairs(data.Flags) do
        local control = self.Controls[flag]
        if control and control.Set and control.Kind then
            local valid = (control.Kind == "Toggle" and type(value) == "boolean") or (control.Kind == "Slider" and finite(value)) or (control.Kind == "Textbox" and type(value) == "string") or (control.Kind == "Dropdown" and ((control.Multi and type(value) == "table") or (not control.Multi and type(value) == "string")))
            if not valid then return false, "Invalid value for " .. tostring(flag) end
        end
    end
    for flag, value in pairs(data.Flags) do
        local control = self.Controls[flag]
        if control and control.Set and control.Kind then control:Set(value, silent ~= false) end
    end
    return true
end

function Window:Notify(options)
    if self.Destroyed then return nil end
    options = options or {}
    local duration = tonumber(options.Duration) or self.Config.NotificationDuration
    if not finite(duration) then duration = 5 end
    duration = math.clamp(duration, 0.5, 120)
    while #self.Notifications >= math.max(1, self.Config.MaxNotifications) do
        local oldest = table.remove(self.Notifications, 1)
        oldest.Dismiss()
    end
    self.NotificationOrder = (self.NotificationOrder or 0) + 1
    local holder = make("CanvasGroup", {Name = "Notification", Size = UDim2.new(1, 0, 0, 100), BackgroundColor3 = self.Colors.Background, BorderSizePixel = 0, GroupTransparency = 1, LayoutOrder = self.NotificationOrder, ZIndex = 400, ClipsDescendants = true}, self.NotificationZone)
    round(holder, 8)
    stroke(holder, self.Colors.Orange, 0.25)
    local title = self:_text(holder, options.Title or "Notification", {Position = UDim2.fromOffset(10, 7), Size = UDim2.new(1, -49, 0, 19), FontFace = self.HeaderFont, TextSize = 12, TextColor3 = self.Colors.Orange, ZIndex = 401})
    local timer = self:_text(holder, "", {Position = UDim2.new(1, -34, 0, 8), Size = UDim2.fromOffset(24, 16), TextSize = 10, TextColor3 = self.Colors.Muted, TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 401})
    self:_text(holder, options.Text or "", {Position = UDim2.fromOffset(10, 29), Size = UDim2.new(1, -20, 0, 31), TextSize = 12, TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top, TextColor3 = self.Colors.Muted, ZIndex = 401})
    local action = make("TextButton", {Text = options.ActionLabel or "Dismiss", FontFace = self.ContentFont, TextColor3 = self.Colors.White, BackgroundColor3 = self.Colors.Raised, BorderSizePixel = 0, AutoButtonColor = false, Position = UDim2.fromOffset(10, 64), Size = UDim2.new(1, -20, 0, 24), TextSize = 11, ZIndex = 401}, holder)
    round(action, 4)
    stroke(action, self.Colors.Border)
    local track = make("Frame", {Position = UDim2.new(0, 10, 1, -6), Size = UDim2.new(1, -20, 0, 2), BackgroundColor3 = self.Colors.Border, BorderSizePixel = 0, ZIndex = 401}, holder)
    local fill = make("Frame", {Size = UDim2.fromScale(1, 1), BackgroundColor3 = self.Colors.White, BorderSizePixel = 0, ZIndex = 402}, track)
    make("UIGradient", {Color = ColorSequence.new(self.Colors.Orange, self.Colors.OrangeDeep)}, fill)
    local tween = TweenService:Create(fill, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Size = UDim2.fromScale(0, 1)})
    local dismissed = false
    local notification = {Instance = holder}
    local localConnections = {}
    table.insert(localConnections, action.MouseEnter:Connect(function() self:_tween(action, {BackgroundColor3 = self.Colors.OrangeDeep}) end))
    table.insert(localConnections, action.MouseLeave:Connect(function() self:_tween(action, {BackgroundColor3 = self.Colors.Raised}) end))
    function notification.Dismiss(immediate)
        if dismissed then return end
        dismissed = true
        tween:Cancel()
        for _, connection in ipairs(localConnections) do connection:Disconnect() end
        local index = table.find(self.Notifications, notification)
        if index then table.remove(self.Notifications, index) end
        if immediate or self.Destroyed then holder:Destroy() return end
        self:_tween(holder, {GroupTransparency = 1}, 0.2)
        task.delay(0.22, function() if holder.Parent then holder:Destroy() end end)
    end
    table.insert(self.Notifications, notification)
    table.insert(localConnections, action.Activated:Connect(function()
        if dismissed then return end
        if options.ActionCallback then
            self:_call(options.ActionCallback, holder, notification.Dismiss)
        else
            notification.Dismiss()
        end
    end))
    self:_tween(holder, {GroupTransparency = 0}, 0.25)
    tween:Play()
    local deadline = os.clock() + duration
    task.spawn(function()
        while not dismissed and not self.Destroyed and holder.Parent do
            local remaining = deadline - os.clock()
            if remaining <= 0 then break end
            timer.Text = tostring(math.ceil(remaining)) .. "s"
            task.wait(0.2)
        end
        notification.Dismiss()
    end)
    return notification
end

function Window:SendActionNotification(title, text, duration, actionLabel, actionCallback)
    local notification = self:Notify({Title = title, Text = text, Duration = duration, ActionLabel = actionLabel, ActionCallback = actionCallback})
    if not notification then return nil end
    return notification.Instance, notification.Dismiss
end

return Library
