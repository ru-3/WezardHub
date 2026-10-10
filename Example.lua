local UiUrl = "https://raw.githubusercontent.com/YourName/WezardHub/main/Ui.lua"
local ConfigUrl = "https://raw.githubusercontent.com/YourName/WezardHub/main/config.lua"

local Ui = loadstring(game:HttpGet(UiUrl))()
local Config = loadstring(game:HttpGet(ConfigUrl))()

local Hub = Ui.new(Config)
Hub:SetTitle("Your Map", "Halloween Update")

local Main = Hub:AddTab({Name = "Main", Icon = "Home"})
local Player = Hub:AddTab({Name = "Player", Icon = "Player"})
local Settings = Hub:AddTab({Name = "Settings", Icon = "Settings"})
local About = Hub:AddTab({Name = "About", Icon = "Info"})

local Actions = Main:AddSection("Quick Actions")
local Enabled = Actions:AddToggle({
    Name = "Enabled",
    Flag = "Enabled",
    Default = false,
    Callback = function(value)
        Hub:Notify({Title = "Status", Text = value and "Enabled." or "Disabled."})
    end,
})
Actions:AddButton({
    Name = "Run Action",
    Icon = "Grid",
    Callback = function()
        Hub:Notify({Title = "Action", Text = "Connect your script action here."})
    end,
})
Actions:AddDropdown({
    Name = "Mode",
    Flag = "Mode",
    Options = {"Normal", "Fast", "Quiet"},
    Default = "Normal",
    Callback = function(value)
        Hub:Notify({Title = "Mode", Text = tostring(value) .. " selected."})
    end,
})

local Selection = Main:AddSection("Selection")
Selection:AddDropdown({
    Name = "Targets",
    Flag = "Targets",
    Multi = true,
    Options = {"Players", "Objects", "Zones", "Items", "Events", "Other"},
    Default = {"Objects", "Items"},
    Callback = function(values)
        print("Selected:", table.concat(values, ", "))
    end,
})
Selection:AddSlider({
    Name = "Intensity",
    Flag = "Intensity",
    Min = 0,
    Max = 100,
    Step = 5,
    Default = 50,
    Callback = function(value)
        print("Intensity:", value)
    end,
})
Selection:AddLabel({Text = "Ready"})

local PlayerOptions = Player:AddSection("Player Options")
PlayerOptions:AddToggle({Name = "Highlight", Flag = "Highlight", Default = false, Callback = function(value) print("Highlight:", value) end})
PlayerOptions:AddSlider({Name = "Distance", Flag = "Distance", Min = 10, Max = 500, Step = 10, Default = 100, Callback = function(value) print("Distance:", value) end})
PlayerOptions:AddTextbox({Name = "Player name", Flag = "PlayerName", Default = "", MaxLength = 32, Callback = function(value) print("Player name:", value) end})

local Configuration = Settings:AddSection("Configuration")
local SavedConfig
Configuration:AddButton({Name = "Save Config", Callback = function()
    SavedConfig = Hub:ExportConfig()
    Hub:Notify({Title = "Config saved", Text = "Settings saved for this session."})
end})
Configuration:AddButton({Name = "Load Config", Callback = function()
    if not SavedConfig then
        Hub:Notify({Title = "No config", Text = "Save your settings first."})
        return
    end
    local success, message = Hub:ImportConfig(SavedConfig, false)
    Hub:Notify({Title = success and "Config loaded" or "Config error", Text = success and "Settings restored." or message})
end})
Configuration:AddButton({Name = "Reset Toggle", Callback = function() Enabled:Set(false) end})
Configuration:AddButton({Name = "Hide GUI", Icon = "Eye", Callback = function() Hub:SetVisible(false) end})
Configuration:AddButton({Name = "Close GUI", Icon = "Close", Callback = function() Hub:RequestClose() end})

local Details = About:AddSection("Wezard Hub")
Details:AddLabel({Text = "Halloween"})
Details:AddLabel({Text = "Version 1.0"})
Details:AddButton({Name = "Notification", Icon = "Bell", Callback = function()
    Hub:SendActionNotification("Wezard Hub", "An action notification.", 6, "Confirm", function(holder, dismiss)
        dismiss()
        Hub:Notify({Title = "Confirmed", Text = "Notification action completed."})
    end)
end})

Hub:SendActionNotification("Wezard Hub", "Script loaded successfully.", 6, "Dismiss", function(holder, dismiss)
    dismiss()
end)
