--[[
    SettingsModal.luau
    Settings modal for managing game settings
]]

local SettingsModal = {}

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Modules
local BaseUI = require(script.Parent.Parent.BaseUI)
local ModalBase = require(script.Parent.ModalBase)
local PlayerDataController = require(script.Parent.Parent.Parent.Controllers.PlayerDataController)

-- Constants
local COLORS = BaseUI.GetColors()
local TWEEN_INFO = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- Local variables
local activeSection = "General"

-- Show local notification instead of relying on MainScreen
local function showLocalNotification(title, message, notificationType, duration)
    local player = Players.LocalPlayer
    if not player then return end
    
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then return end
    
    -- Create notification directly
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title,
        Text = message,
        Duration = duration or 3
    })
end

-- Show the settings modal
function SettingsModal.Show()
    -- Get settings data from PlayerDataController
    local settingsData = PlayerDataController.GetDataByPath("Settings") or {}
    
    -- Create default settings if they don't exist
    local defaultSettings = {
        General = {
            MusicVolume = settingsData.General and settingsData.General.MusicVolume or 50,
            SoundVolume = settingsData.General and settingsData.General.SoundVolume or 50,
            ShowTutorials = settingsData.General and settingsData.General.ShowTutorials or true,
            Quality = settingsData.General and settingsData.General.Quality or "Auto"
        },
        Interface = {
            ShowNotifications = settingsData.Interface and settingsData.Interface.ShowNotifications or true,
            UIScale = settingsData.Interface and settingsData.Interface.UIScale or 100,
            ShowHUD = settingsData.Interface and settingsData.Interface.ShowHUD or true,
            ColorBlindMode = settingsData.Interface and settingsData.Interface.ColorBlindMode or "None"
        },
        Notifications = {
            JobReminders = settingsData.Notifications and settingsData.Notifications.JobReminders or true,
            BillReminders = settingsData.Notifications and settingsData.Notifications.BillReminders or true,
            EventAlerts = settingsData.Notifications and settingsData.Notifications.EventAlerts or true,
            FriendActivities = settingsData.Notifications and settingsData.Notifications.FriendActivities or true
        }
    }
    
    -- Create the base modal
    local modal = ModalBase.CreateBaseModal("Settings", UDim2.new(0, 700, 0, 500))
    
    -- Create tab buttons container
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.Size = UDim2.new(0, 160, 1, -40)
    tabContainer.Position = UDim2.new(0, 20, 0, 20)
    tabContainer.BackgroundColor3 = COLORS.SECONDARY
    tabContainer.BorderSizePixel = 0
    tabContainer.Parent = modal.contentContainer
    
    -- Apply shadow
    BaseUI.ApplyShadow(tabContainer, 10)
    
    -- Create content container
    local contentContainer = Instance.new("Frame")
    contentContainer.Name = "SettingsContent"
    contentContainer.Size = UDim2.new(1, -200, 1, -40)
    contentContainer.Position = UDim2.new(0, 180, 0, 20)
    contentContainer.BackgroundTransparency = 1
    contentContainer.Parent = modal.contentContainer
    
    -- Create tabs
    local tabButtons = {}
    local sections = {"General", "Interface", "Notifications", "About"}
    
    -- Tab layout
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Vertical
    tabLayout.Padding = UDim.new(0, 10)
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    tabLayout.Parent = tabContainer
    
    local tabPadding = Instance.new("UIPadding")
    tabPadding.PaddingTop = UDim.new(0, 15)
    tabPadding.Parent = tabContainer
    
    for i, sectionName in ipairs(sections) do
        local tabButton = BaseUI.CreateStyledButton("Tab_" .. sectionName, sectionName)
        tabButton.Size = UDim2.new(1, -30, 0, 40)
        tabButton.Parent = tabContainer
        
        -- Highlight the active tab
        if sectionName == activeSection then
            tabButton.BackgroundColor3 = COLORS.PRIMARY
        end
        
        -- Tab click handler
        tabButton.MouseButton1Click:Connect(function()
            -- Reset all tab colors
            for _, btn in pairs(tabButtons) do
                TweenService:Create(btn, TWEEN_INFO, {BackgroundColor3 = COLORS.BUTTON}):Play()
            end
            
            -- Highlight selected tab
            TweenService:Create(tabButton, TWEEN_INFO, {BackgroundColor3 = COLORS.PRIMARY}):Play()
            
            -- Update active section
            activeSection = sectionName
            
            -- Clear and rebuild content
            for _, child in pairs(contentContainer:GetChildren()) do
                child:Destroy()
            end
            
            -- Build the selected section
            if sectionName == "General" then
                buildGeneralSection(contentContainer, defaultSettings.General)
            elseif sectionName == "Interface" then
                buildInterfaceSection(contentContainer, defaultSettings.Interface)
            elseif sectionName == "Notifications" then
                buildNotificationsSection(contentContainer, defaultSettings.Notifications)
            elseif sectionName == "About" then
                buildAboutSection(contentContainer)
            end
        end)
        
        tabButtons[sectionName] = tabButton
    end
    
    -- Build the initial section (General)
    buildGeneralSection(contentContainer, defaultSettings.General)
    
    -- Create save button
    local saveButton = BaseUI.CreateStyledButton("SaveButton", "Save Settings")
    saveButton.Size = UDim2.new(0, 150, 0, 40)
    saveButton.Position = UDim2.new(1, -170, 1, -60)
    saveButton.Parent = contentContainer
    
    -- Save button click handler
    saveButton.MouseButton1Click:Connect(function()
        -- Example remote event call (commented out)
        -- local saveSettingsEvent = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("SaveSettings")
        -- saveSettingsEvent:FireServer(defaultSettings)
        
        -- Also save to temporary data
        PlayerDataController.SetTemporaryData("Settings", defaultSettings)
        
        -- Show success notification (independent from MainScreen)
        showLocalNotification("Settings", "Your settings have been saved!", "success", 3)
        
        -- Close the modal
        ModalBase.CloseModal(modal)
    end)
end

-- Build the General section
function buildGeneralSection(parent, settings)
    local settingsContainer = Instance.new("ScrollingFrame")
    settingsContainer.Name = "GeneralSettings"
    settingsContainer.Size = UDim2.new(1, 0, 1, -70)
    settingsContainer.BackgroundTransparency = 1
    settingsContainer.ScrollBarThickness = 6
    settingsContainer.ScrollingDirection = Enum.ScrollingDirection.Y
    settingsContainer.Parent = parent
    
    -- Settings layout
    local settingsLayout = Instance.new("UIListLayout")
    settingsLayout.FillDirection = Enum.FillDirection.Vertical
    settingsLayout.Padding = UDim.new(0, 20)
    settingsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    settingsLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    settingsLayout.Parent = settingsContainer
    
    -- Add padding
    local settingsPadding = Instance.new("UIPadding")
    settingsPadding.PaddingTop = UDim.new(0, 15)
    settingsPadding.PaddingLeft = UDim.new(0, 15)
    settingsPadding.PaddingRight = UDim.new(0, 15)
    settingsPadding.Parent = settingsContainer
    
    -- Music volume slider
    local musicVolumeContainer = createSettingItem(
        "Music Volume",
        "Adjust the volume of the game's music",
        settingsContainer
    )
    
    local musicSlider = createSlider(
        "MusicVolumeSlider",
        musicVolumeContainer,
        settings.MusicVolume,
        function(value)
            settings.MusicVolume = value
            -- Example implementation to adjust music volume in real-time
            -- local SoundService = game:GetService("SoundService")
            -- SoundService.MusicVolume = value / 100
        end
    )
    musicSlider.LayoutOrder = 1
    
    -- Sound effects volume slider
    local soundVolumeContainer = createSettingItem(
        "Sound Effects Volume",
        "Adjust the volume of sound effects",
        settingsContainer
    )
    
    local soundSlider = createSlider(
        "SoundVolumeSlider",
        soundVolumeContainer,
        settings.SoundVolume,
        function(value)
            settings.SoundVolume = value
            -- Example implementation to adjust sound effects volume in real-time
            -- local SoundService = game:GetService("SoundService")
            -- SoundService.SoundVolume = value / 100
        end
    )
    soundSlider.LayoutOrder = 2
    
    -- Show tutorials toggle
    local tutorialsContainer = createSettingItem(
        "Show Tutorials",
        "Enable or disable tutorial popups",
        settingsContainer
    )
    
    local tutorialsToggle = createToggle(
        "ShowTutorialsToggle",
        tutorialsContainer,
        settings.ShowTutorials,
        function(value)
            settings.ShowTutorials = value
        end
    )
    tutorialsToggle.LayoutOrder = 3
    
    -- Quality dropdown
    local qualityContainer = createSettingItem(
        "Graphics Quality",
        "Adjust the graphics quality",
        settingsContainer
    )
    
    local qualityOptions = {"Low", "Medium", "High", "Auto"}
    local qualityDropdown = createDropdown(
        "QualityDropdown",
        qualityContainer,
        qualityOptions,
        settings.Quality,
        function(value)
            settings.Quality = value
            
            -- Example implementation to adjust quality in real-time
            -- local UserGameSettings = UserSettings():GetService("UserGameSettings")
            -- if value == "Low" then
            --     UserGameSettings.SavedQualityLevel = Enum.SavedQualityLevel.Level01
            -- elseif value == "Medium" then
            --     UserGameSettings.SavedQualityLevel = Enum.SavedQualityLevel.Level05
            -- elseif value == "High" then
            --     UserGameSettings.SavedQualityLevel = Enum.SavedQualityLevel.Level10
            -- elseif value == "Auto" then
            --     UserGameSettings.SavedQualityLevel = Enum.SavedQualityLevel.Automatic
            -- end
        end
    )
    qualityDropdown.LayoutOrder = 4
    
    -- Update canvas size
    settingsContainer.CanvasSize = UDim2.new(0, 0, 0, settingsLayout.AbsoluteContentSize.Y + 30)
end

-- Build the Interface section
function buildInterfaceSection(parent, settings)
    local settingsContainer = Instance.new("ScrollingFrame")
    settingsContainer.Name = "InterfaceSettings"
    settingsContainer.Size = UDim2.new(1, 0, 1, -70)
    settingsContainer.BackgroundTransparency = 1
    settingsContainer.ScrollBarThickness = 6
    settingsContainer.ScrollingDirection = Enum.ScrollingDirection.Y
    settingsContainer.Parent = parent
    
    -- Settings layout
    local settingsLayout = Instance.new("UIListLayout")
    settingsLayout.FillDirection = Enum.FillDirection.Vertical
    settingsLayout.Padding = UDim.new(0, 20)
    settingsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    settingsLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    settingsLayout.Parent = settingsContainer
    
    -- Add padding
    local settingsPadding = Instance.new("UIPadding")
    settingsPadding.PaddingTop = UDim.new(0, 15)
    settingsPadding.PaddingLeft = UDim.new(0, 15)
    settingsPadding.PaddingRight = UDim.new(0, 15)
    settingsPadding.Parent = settingsContainer
    
    -- Show notifications toggle
    local notificationsContainer = createSettingItem(
        "Show Notifications",
        "Enable or disable in-game notifications",
        settingsContainer
    )
    
    local notificationsToggle = createToggle(
        "ShowNotificationsToggle",
        notificationsContainer,
        settings.ShowNotifications,
        function(value)
            settings.ShowNotifications = value
        end
    )
    notificationsToggle.LayoutOrder = 1
    
    -- UI Scale slider
    local uiScaleContainer = createSettingItem(
        "UI Scale",
        "Adjust the size of the user interface",
        settingsContainer
    )
    
    local uiScaleSlider = createSlider(
        "UIScaleSlider",
        uiScaleContainer,
        settings.UIScale,
        function(value)
            settings.UIScale = value
            -- Example implementation to adjust UI scale in real-time
            -- local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
            -- local mainGUI = playerGui:FindFirstChild("MainGUI")
            -- if mainGUI then
            --     local uiScale = mainGUI:FindFirstChild("UIScale") or Instance.new("UIScale")
            --     uiScale.Scale = value / 100
            --     uiScale.Parent = mainGUI
            -- end
        end
    )
    uiScaleSlider.LayoutOrder = 2
    
    -- Show HUD toggle
    local hudContainer = createSettingItem(
        "Show HUD",
        "Show or hide the heads-up display",
        settingsContainer
    )
    
    local hudToggle = createToggle(
        "ShowHUDToggle",
        hudContainer,
        settings.ShowHUD,
        function(value)
            settings.ShowHUD = value
        end
    )
    hudToggle.LayoutOrder = 3
    
    -- Colorblind mode dropdown
    local colorblindContainer = createSettingItem(
        "Colorblind Mode",
        "Adjust colors for different types of color blindness",
        settingsContainer
    )
    
    local colorblindOptions = {"None", "Protanopia", "Deuteranopia", "Tritanopia"}
    local colorblindDropdown = createDropdown(
        "ColorblindDropdown",
        colorblindContainer,
        colorblindOptions,
        settings.ColorBlindMode,
        function(value)
            settings.ColorBlindMode = value
        end
    )
    colorblindDropdown.LayoutOrder = 4
    
    -- Update canvas size
    settingsContainer.CanvasSize = UDim2.new(0, 0, 0, settingsLayout.AbsoluteContentSize.Y + 30)
end

-- Build the Notifications section
function buildNotificationsSection(parent, settings)
    local settingsContainer = Instance.new("ScrollingFrame")
    settingsContainer.Name = "NotificationSettings"
    settingsContainer.Size = UDim2.new(1, 0, 1, -70)
    settingsContainer.BackgroundTransparency = 1
    settingsContainer.ScrollBarThickness = 6
    settingsContainer.ScrollingDirection = Enum.ScrollingDirection.Y
    settingsContainer.Parent = parent
    
    -- Settings layout
    local settingsLayout = Instance.new("UIListLayout")
    settingsLayout.FillDirection = Enum.FillDirection.Vertical
    settingsLayout.Padding = UDim.new(0, 20)
    settingsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    settingsLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    settingsLayout.Parent = settingsContainer
    
    -- Add padding
    local settingsPadding = Instance.new("UIPadding")
    settingsPadding.PaddingTop = UDim.new(0, 15)
    settingsPadding.PaddingLeft = UDim.new(0, 15)
    settingsPadding.PaddingRight = UDim.new(0, 15)
    settingsPadding.Parent = settingsContainer
    
    -- Job reminders toggle
    local jobRemindersContainer = createSettingItem(
        "Job Reminders",
        "Get notifications when it's time to work",
        settingsContainer
    )
    
    local jobRemindersToggle = createToggle(
        "JobRemindersToggle",
        jobRemindersContainer,
        settings.JobReminders,
        function(value)
            settings.JobReminders = value
        end
    )
    jobRemindersToggle.LayoutOrder = 1
    
    -- Bill reminders toggle
    local billRemindersContainer = createSettingItem(
        "Bill Reminders",
        "Get notifications when bills are due",
        settingsContainer
    )
    
    local billRemindersToggle = createToggle(
        "BillRemindersToggle",
        billRemindersContainer,
        settings.BillReminders,
        function(value)
            settings.BillReminders = value
        end
    )
    billRemindersToggle.LayoutOrder = 2
    
    -- Event alerts toggle
    local eventAlertsContainer = createSettingItem(
        "Event Alerts",
        "Get notifications about special in-game events",
        settingsContainer
    )
    
    local eventAlertsToggle = createToggle(
        "EventAlertsToggle",
        eventAlertsContainer,
        settings.EventAlerts,
        function(value)
            settings.EventAlerts = value
        end
    )
    eventAlertsToggle.LayoutOrder = 3
    
    -- Friend activities toggle
    local friendActivitiesContainer = createSettingItem(
        "Friend Activities",
        "Get notifications about your friends' activities",
        settingsContainer
    )
    
    local friendActivitiesToggle = createToggle(
        "FriendActivitiesToggle",
        friendActivitiesContainer,
        settings.FriendActivities,
        function(value)
            settings.FriendActivities = value
        end
    )
    friendActivitiesToggle.LayoutOrder = 4
    
    -- Update canvas size
    settingsContainer.CanvasSize = UDim2.new(0, 0, 0, settingsLayout.AbsoluteContentSize.Y + 30)
end

-- Build the About section
function buildAboutSection(parent)
    local aboutContainer = Instance.new("Frame")
    aboutContainer.Name = "AboutSection"
    aboutContainer.Size = UDim2.new(1, 0, 1, -70)
    aboutContainer.BackgroundTransparency = 1
    aboutContainer.Parent = parent
    
    -- Game logo
    local logoImage = Instance.new("ImageLabel")
    logoImage.Name = "GameLogo"
    logoImage.Size = UDim2.new(0, 200, 0, 200)
    logoImage.Position = UDim2.new(0.5, -100, 0, 20)
    logoImage.BackgroundTransparency = 1
    logoImage.Image = "rbxassetid://8990866223" -- Replace with actual game logo
    logoImage.Parent = aboutContainer
    
    -- Game name
    local gameName = BaseUI.CreateLabel(
        "GameName", 
        "Life Simulator", 
        UDim2.new(1, 0, 0, 40),
        UDim2.new(0, 0, 0, 230),
        COLORS.TEXT,
        28,
        aboutContainer
    )
    gameName.Font = Enum.Font.GothamBold
    
    -- Create game version label
    BaseUI.CreateLabel(
        "GameVersion", 
        "Version 1.0.0", 
        UDim2.new(1, 0, 0, 25),
        UDim2.new(0, 0, 0, 270),
        COLORS.SECONDARY_TEXT,
        16,
        aboutContainer
    )
    
    -- Credits
    local creditsTitle = BaseUI.CreateLabel(
        "CreditsTitle", 
        "Credits", 
        UDim2.new(1, 0, 0, 30),
        UDim2.new(0, 0, 0, 310),
        COLORS.TEXT,
        18,
        aboutContainer
    )
    creditsTitle.Font = Enum.Font.GothamBold
    
    local creditsText = BaseUI.CreateLabel(
        "CreditsText", 
        "Developed by: Your Developer Team\nUI Design: Design Team\nSpecial Thanks: Testing Team", 
        UDim2.new(1, -100, 0, 60),
        UDim2.new(0, 50, 0, 340),
        COLORS.SECONDARY_TEXT,
        14,
        aboutContainer
    )
    creditsText.TextWrapped = true
    creditsText.TextXAlignment = Enum.TextXAlignment.Center
end

-- Create a setting item with label and description
function createSettingItem(title, description, parent)
    local container = Instance.new("Frame")
    container.Name = title:gsub(" ", "") .. "Container"
    container.Size = UDim2.new(1, 0, 0, 70)
    container.BackgroundTransparency = 1
    container.Parent = parent
    
    local titleLabel = BaseUI.CreateLabel(
        "Title", 
        title, 
        UDim2.new(0.5, 0, 0, 25),
        UDim2.new(0, 0, 0, 0),
        COLORS.TEXT,
        16,
        container
    )
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Font = Enum.Font.GothamBold
    
    local descLabel = BaseUI.CreateLabel(
        "Description", 
        description, 
        UDim2.new(0.5, 0, 0, 25),
        UDim2.new(0, 0, 0, 25),
        COLORS.SECONDARY_TEXT,
        14,
        container
    )
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    return container
end

-- Create a slider control
function createSlider(name, parent, initialValue, onChange)
    local sliderContainer = Instance.new("Frame")
    sliderContainer.Name = name
    sliderContainer.Size = UDim2.new(0.5, 0, 0, 40)
    sliderContainer.Position = UDim2.new(0.5, 0, 0, 0)
    sliderContainer.BackgroundTransparency = 1
    sliderContainer.Parent = parent
    
    local sliderTrack = Instance.new("Frame")
    sliderTrack.Name = "Track"
    sliderTrack.Size = UDim2.new(1, 0, 0, 4)
    sliderTrack.Position = UDim2.new(0, 0, 0.5, -2)
    sliderTrack.BackgroundColor3 = COLORS.SECONDARY
    sliderTrack.BorderSizePixel = 0
    sliderTrack.Parent = sliderContainer
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Name = "Fill"
    sliderFill.Size = UDim2.new(initialValue / 100, 0, 1, 0)
    sliderFill.BackgroundColor3 = COLORS.PRIMARY
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderTrack
    
    local sliderKnob = Instance.new("Frame")
    sliderKnob.Name = "Knob"
    sliderKnob.Size = UDim2.new(0, 16, 0, 16)
    sliderKnob.Position = UDim2.new(initialValue / 100, 0, 0.5, 0)
    sliderKnob.AnchorPoint = Vector2.new(0.5, 0.5)
    sliderKnob.BackgroundColor3 = COLORS.PRIMARY
    sliderKnob.BorderSizePixel = 0
    sliderKnob.Parent = sliderContainer
    
    -- Make knob circular
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(1, 0)
    uiCorner.Parent = sliderKnob
    
    -- Value label
    local valueLabel = BaseUI.CreateLabel(
        "Value", 
        tostring(initialValue), 
        UDim2.new(0, 40, 0, 20),
        UDim2.new(1, -40, 0, 10),
        COLORS.TEXT,
        14,
        sliderContainer
    )
    
    -- Slider functionality
    local isDragging = false
    
    local function updateSlider(input)
        local pos = math.clamp((input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)
        local value = math.floor(pos * 100)
        
        -- Update UI
        sliderFill.Size = UDim2.new(pos, 0, 1, 0)
        sliderKnob.Position = UDim2.new(pos, 0, 0.5, 0)
        valueLabel.Text = tostring(value)
        
        -- Callback
        onChange(value)
    end
    
    sliderContainer.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            updateSlider(input)
        end
    end)
    
    sliderContainer.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(input)
        end
    end)
    
    return sliderContainer
end

-- Create a toggle control
function createToggle(name, parent, initialValue, onChange)
    local toggleContainer = Instance.new("Frame")
    toggleContainer.Name = name
    toggleContainer.Size = UDim2.new(0.5, 0, 0, 30)
    toggleContainer.Position = UDim2.new(0.5, 0, 0, 10)
    toggleContainer.BackgroundTransparency = 1
    toggleContainer.Parent = parent
    
    local toggleBackground = Instance.new("Frame")
    toggleBackground.Name = "Background"
    toggleBackground.Size = UDim2.new(0, 50, 0, 26)
    toggleBackground.Position = UDim2.new(0, 0, 0.5, -13)
    toggleBackground.BorderSizePixel = 0
    toggleBackground.Parent = toggleContainer
    
    -- Rounded corners
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(1, 0)
    uiCorner.Parent = toggleBackground
    
    local toggleKnob = Instance.new("Frame")
    toggleKnob.Name = "Knob"
    toggleKnob.Size = UDim2.new(0, 20, 0, 20)
    toggleKnob.AnchorPoint = Vector2.new(0, 0.5)
    toggleKnob.BorderSizePixel = 0
    toggleKnob.Parent = toggleBackground
    
    -- Rounded knob
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = toggleKnob
    
    -- Update the toggle UI based on value
    local function updateToggleUI(value)
        if value then
            toggleBackground.BackgroundColor3 = COLORS.PRIMARY
            toggleKnob.Position = UDim2.new(0, 27, 0.5, 0)
            toggleKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        else
            toggleBackground.BackgroundColor3 = COLORS.SECONDARY
            toggleKnob.Position = UDim2.new(0, 3, 0.5, 0)
            toggleKnob.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
        end
    end
    
    -- Set initial state
    updateToggleUI(initialValue)
    
    -- Add click handler
    toggleBackground.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            initialValue = not initialValue
            updateToggleUI(initialValue)
            onChange(initialValue)
        end
    end)
    
    return toggleContainer
end

-- Create a dropdown control
function createDropdown(name, parent, options, initialValue, onChange)
    local dropdownContainer = Instance.new("Frame")
    dropdownContainer.Name = name
    dropdownContainer.Size = UDim2.new(0.5, 0, 0, 30)
    dropdownContainer.Position = UDim2.new(0.5, 0, 0, 10)
    dropdownContainer.BackgroundTransparency = 1
    dropdownContainer.Parent = parent
    
    local dropdownButton = Instance.new("TextButton")
    dropdownButton.Name = "Button"
    dropdownButton.Size = UDim2.new(1, 0, 1, 0)
    dropdownButton.BackgroundColor3 = COLORS.BACKGROUND
    dropdownButton.BorderSizePixel = 0
    dropdownButton.Text = ""
    dropdownButton.Parent = dropdownContainer
    
    -- Rounded corners
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 6)
    buttonCorner.Parent = dropdownButton
    
    -- Current selection text
    local selectionText = BaseUI.CreateLabel(
        "Selection", 
        initialValue, 
        UDim2.new(1, -50, 1, 0),
        UDim2.new(0, 10, 0, 0),
        COLORS.TEXT,
        14,
        dropdownButton
    )
    selectionText.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Dropdown arrow
    local arrowLabel = Instance.new("TextLabel")
    arrowLabel.Name = "Arrow"
    arrowLabel.Size = UDim2.new(0, 30, 0, 30)
    arrowLabel.Position = UDim2.new(1, -30, 0, 0)
    arrowLabel.BackgroundTransparency = 1
    arrowLabel.Text = "▼"
    arrowLabel.TextColor3 = COLORS.TEXT
    arrowLabel.TextSize = 14
    arrowLabel.Font = Enum.Font.GothamBold
    arrowLabel.Parent = dropdownButton
    
    -- Options container (initially hidden)
    local optionsContainer = Instance.new("Frame")
    optionsContainer.Name = "Options"
    optionsContainer.Size = UDim2.new(1, 0, 0, #options * 30)
    optionsContainer.Position = UDim2.new(0, 0, 1, 5)
    optionsContainer.BackgroundColor3 = COLORS.BACKGROUND
    optionsContainer.BorderSizePixel = 0
    optionsContainer.Visible = false
    optionsContainer.ZIndex = 10
    optionsContainer.Parent = dropdownContainer
    
    -- Rounded corners for options
    local optionsCorner = Instance.new("UICorner")
    optionsCorner.CornerRadius = UDim.new(0, 6)
    optionsCorner.Parent = optionsContainer
    
    -- Apply shadow to options
    BaseUI.ApplyShadow(optionsContainer, 10)
    
    -- Add options
    for i, option in ipairs(options) do
        local optionButton = Instance.new("TextButton")
        optionButton.Name = "Option_" .. option
        optionButton.Size = UDim2.new(1, 0, 0, 30)
        optionButton.Position = UDim2.new(0, 0, 0, (i-1) * 30)
        optionButton.BackgroundTransparency = 1
        optionButton.Text = ""
        optionButton.ZIndex = 10
        optionButton.Parent = optionsContainer
        
        local optionText = BaseUI.CreateLabel(
            "Text", 
            option, 
            UDim2.new(1, -20, 1, 0),
            UDim2.new(0, 10, 0, 0),
            COLORS.TEXT,
            14,
            optionButton
        )
        optionText.TextXAlignment = Enum.TextXAlignment.Left
        optionText.ZIndex = 10
        
        -- Highlight if this is the current selection
        if option == initialValue then
            optionButton.BackgroundTransparency = 0.9
            optionButton.BackgroundColor3 = COLORS.PRIMARY
        end
        
        -- Option click handler
        optionButton.MouseButton1Click:Connect(function()
            selectionText.Text = option
            optionsContainer.Visible = false
            onChange(option)
            
            -- Update selected option highlight
            for _, child in pairs(optionsContainer:GetChildren()) do
                if child:IsA("TextButton") then
                    child.BackgroundTransparency = 1
                end
            end
            
            optionButton.BackgroundTransparency = 0.9
            optionButton.BackgroundColor3 = COLORS.PRIMARY
        end)
        
        -- Hover effect
        optionButton.MouseEnter:Connect(function()
            if option ~= selectionText.Text then
                optionButton.BackgroundTransparency = 0.9
                optionButton.BackgroundColor3 = COLORS.SECONDARY
            end
        end)
        
        optionButton.MouseLeave:Connect(function()
            if option ~= selectionText.Text then
                optionButton.BackgroundTransparency = 1
            else
                optionButton.BackgroundTransparency = 0.9
                optionButton.BackgroundColor3 = COLORS.PRIMARY
            end
        end)
    end
    
    -- Toggle dropdown on button click
    dropdownButton.MouseButton1Click:Connect(function()
        optionsContainer.Visible = not optionsContainer.Visible
        arrowLabel.Text = optionsContainer.Visible and "▲" or "▼"
    end)
    
    -- Close dropdown when clicking outside
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local position = UserInputService:GetMouseLocation()
            
            -- Check if click is outside the dropdown
            if optionsContainer.Visible then
                local dropdownFrame = dropdownContainer.AbsolutePosition
                local dropdownSize = dropdownContainer.AbsoluteSize
                local optionsSize = optionsContainer.AbsoluteSize
                
                local isInDropdown = 
                    position.X >= dropdownFrame.X and 
                    position.X <= dropdownFrame.X + dropdownSize.X and 
                    position.Y >= dropdownFrame.Y and 
                    position.Y <= dropdownFrame.Y + dropdownSize.Y + optionsSize.Y + 5
                
                if not isInDropdown then
                    optionsContainer.Visible = false
                    arrowLabel.Text = "▼"
                end
            end
        end
    end)
    
    return dropdownContainer
end

return SettingsModal 