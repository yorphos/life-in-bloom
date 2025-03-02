--[[
    MainScreen.luau
    Main UI screen that contains the dashboard, toolbar, and other UI elements
]]

local MainScreen = {}

-- Services
local Players = game:GetService("Players")

-- Modules
local BaseUI = require(script.Parent.Parent.BaseUI)
local CoreComponents = require(script.Parent.Parent.Components.CoreComponents)
local PlayerDataController = require(script.Parent.Parent.Parent.Controllers.PlayerDataController)
local PlayerMovementController = require(script.Parent.Parent.Parent.Controllers.PlayerMovementController)

-- MainUIController will be required when needed to avoid cyclic dependencies
local MainUIController

-- Constants
local COLORS = BaseUI.GetColors()

-- Local variables
local player = Players.LocalPlayer
local isSprintActive = false

-- Helper functions to get UI references
local function GetRef(path)
    return BaseUI.GetRef("screens", "main." .. path)
end

-- Show notification
function MainScreen.ShowNotification(title, message, type, duration)
    local notificationContainer = GetRef("notificationContainer")
    CoreComponents.CreateNotification(title, message, type, duration, notificationContainer)
end

-- Function to handle modal opening through a callback approach
local modalCallbacks = {}

function MainScreen.RegisterModalCallback(modalType, callback)
    modalCallbacks[modalType] = callback
end

function MainScreen.OpenModal(modalType, ...)
    if modalCallbacks[modalType] then
        return modalCallbacks[modalType](...)
    else
        MainScreen.ShowNotification("Error", modalType .. " modal not available", "error", 3)
        return false
    end
end

-- Create main UI
function MainScreen.CreateMainUI()
    local playerGui = player:WaitForChild("PlayerGui")
    
    -- Initialize BaseUI with playerGui reference
    BaseUI.Init(playerGui)
    
    -- Hide default Roblox leaderboard/playerlist
    if player.PlayerGui:FindFirstChild("PlayerList") then
        player.PlayerGui.PlayerList.Enabled = false
    end
    
    -- Create main GUI
    local mainGui = Instance.new("ScreenGui")
    mainGui.Name = "MainGUI"
    mainGui.ResetOnSpawn = false
    mainGui.DisplayOrder = 10
    mainGui.Parent = playerGui
    
    -- Store reference
    BaseUI.AddRef("screens", "main.mainGui", mainGui)
    
    -- Create player card (Sims-like but much smaller)
    local playerCard = Instance.new("Frame")
    playerCard.Name = "PlayerCard"
    playerCard.Size = UDim2.new(0, 150, 0, 200) -- Reduced size
    playerCard.Position = UDim2.new(0, 10, 0, 10) -- Position in top corner
    playerCard.BackgroundColor3 = COLORS.SECONDARY
    playerCard.BackgroundTransparency = 0.4 -- Make it semi-transparent
    playerCard.BorderSizePixel = 0
    playerCard.Parent = mainGui
    
    -- Store reference
    BaseUI.AddRef("screens", "main.playerCard", playerCard)
    
    -- Add rounded corners to player card
    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 8)
    cardCorner.Parent = playerCard
    
    -- Apply subtle shadow
    BaseUI.ApplyShadow(playerCard, 15)
    
    -- Player avatar image (thumbnail)
    local avatarImage = Instance.new("ImageLabel")
    avatarImage.Name = "AvatarImage"
    avatarImage.Size = UDim2.new(0, 60, 0, 60) -- Smaller avatar
    avatarImage.Position = UDim2.new(0.5, 0, 0, 10)
    avatarImage.AnchorPoint = Vector2.new(0.5, 0)
    avatarImage.BackgroundColor3 = COLORS.BACKGROUND
    avatarImage.BackgroundTransparency = 0.5
    avatarImage.BorderSizePixel = 0
    avatarImage.Image = "rbxthumb://type=AvatarHeadShot&id=" .. player.UserId .. "&w=150&h=150"
    avatarImage.Parent = playerCard
    
    -- Add circular mask to avatar
    local avatarCorner = Instance.new("UICorner")
    avatarCorner.CornerRadius = UDim.new(1, 0) -- Makes it circular
    avatarCorner.Parent = avatarImage
    
    -- Player name
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "PlayerName"
    nameLabel.Size = UDim2.new(1, -10, 0, 18)
    nameLabel.Position = UDim2.new(0, 5, 0, 75)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.DisplayName
    nameLabel.TextColor3 = COLORS.TEXT
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14
    nameLabel.TextXAlignment = Enum.TextXAlignment.Center
    nameLabel.Parent = playerCard
    
    -- Currency display (inside player card)
    local currencyDisplay = Instance.new("Frame")
    currencyDisplay.Name = "CurrencyDisplay"
    currencyDisplay.Size = UDim2.new(1, -20, 0, 24)
    currencyDisplay.Position = UDim2.new(0, 10, 0, 95)
    currencyDisplay.BackgroundColor3 = COLORS.SECONDARY
    currencyDisplay.BackgroundTransparency = 0.2
    currencyDisplay.BorderSizePixel = 0
    currencyDisplay.Parent = playerCard
    
    -- Add rounded corners
    local currencyCorner = Instance.new("UICorner")
    currencyCorner.CornerRadius = UDim.new(0, 6)
    currencyCorner.Parent = currencyDisplay
    
    -- Money icon
    local moneyIcon = Instance.new("ImageLabel")
    moneyIcon.Name = "MoneyIcon"
    moneyIcon.Size = UDim2.new(0, 16, 0, 16)
    moneyIcon.Position = UDim2.new(0, 5, 0, 4)
    moneyIcon.BackgroundTransparency = 1
    moneyIcon.Image = "rbxassetid://8990865364" -- Money icon
    moneyIcon.Parent = currencyDisplay
    
    -- Currency value
    local currencyValue = Instance.new("TextLabel")
    currencyValue.Name = "CurrencyValue"
    currencyValue.Size = UDim2.new(1, -30, 1, 0)
    currencyValue.Position = UDim2.new(0, 25, 0, 0)
    currencyValue.BackgroundTransparency = 1
    currencyValue.Text = tostring(PlayerDataController.GetDataByPath("Stats", "Currency") or 0)
    currencyValue.TextColor3 = COLORS.TEXT
    currencyValue.Font = Enum.Font.GothamMedium
    currencyValue.TextSize = 14
    currencyValue.TextXAlignment = Enum.TextXAlignment.Left
    currencyValue.Parent = currencyDisplay
    
    -- Store currency reference
    BaseUI.AddRef("screens", "main.currencyDisplay.container", currencyDisplay)
    BaseUI.AddRef("screens", "main.currencyDisplay.icon", moneyIcon)
    BaseUI.AddRef("screens", "main.currencyDisplay.valueText", currencyValue)
    
    -- Stats container
    local statsContainer = Instance.new("Frame")
    statsContainer.Name = "StatsContainer"
    statsContainer.Size = UDim2.new(1, -20, 0, 75)
    statsContainer.Position = UDim2.new(0, 10, 0, 124)
    statsContainer.BackgroundTransparency = 1
    statsContainer.Parent = playerCard
    
    -- Add a vertical layout
    local statsLayout = Instance.new("UIListLayout")
    statsLayout.FillDirection = Enum.FillDirection.Vertical
    statsLayout.Padding = UDim.new(0, 5)
    statsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    statsLayout.Parent = statsContainer
    
    -- Health bar
    local healthBar = CoreComponents.CreateProgressBar(
        "Health", 
        PlayerDataController.GetDataByPath("Stats", "Health") or 100,
        PlayerDataController.GetDataByPath("Stats", "MaxHealth") or 100,
        COLORS.HEALTH,
        UDim2.new(1, 0, 0, 15)
    )
    healthBar.container.LayoutOrder = 1
    healthBar.container.Parent = statsContainer
    
    -- Store reference
    BaseUI.AddRef("screens", "main.healthBar", healthBar)
    
    -- Energy/Stamina bar
    local energyBar = CoreComponents.CreateProgressBar(
        "Energy", 
        PlayerDataController.GetDataByPath("Stats", "Energy") or 100,
        PlayerDataController.GetDataByPath("Stats", "MaxEnergy") or 100,
        COLORS.ENERGY,
        UDim2.new(1, 0, 0, 15)
    )
    energyBar.container.LayoutOrder = 2
    energyBar.container.Parent = statsContainer
    
    -- Store reference
    BaseUI.AddRef("screens", "main.energyBar", energyBar)
    
    -- Mood bar (Sims-like)
    local moodBar = CoreComponents.CreateProgressBar(
        "Mood", 
        PlayerDataController.GetDataByPath("Stats", "Mood") or 100,
        PlayerDataController.GetDataByPath("Stats", "MaxMood") or 100,
        COLORS.MOOD,
        UDim2.new(1, 0, 0, 15)
    )
    moodBar.container.LayoutOrder = 3
    moodBar.container.Parent = statsContainer
    
    -- Store reference
    BaseUI.AddRef("screens", "main.moodBar", moodBar)
    
    -- Create action buttons container (vertical stack on left)
    local actionButtonsContainer = Instance.new("Frame")
    actionButtonsContainer.Name = "ActionButtons"
    actionButtonsContainer.Size = UDim2.new(0, 45, 0, 155)
    actionButtonsContainer.Position = UDim2.new(0, 10, 0, 220) -- Below player card
    actionButtonsContainer.BackgroundTransparency = 1
    actionButtonsContainer.Parent = mainGui
    
    -- Add vertical layout for buttons
    local actionButtonsLayout = Instance.new("UIListLayout")
    actionButtonsLayout.FillDirection = Enum.FillDirection.Vertical
    actionButtonsLayout.Padding = UDim.new(0, 10)
    actionButtonsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    actionButtonsLayout.Parent = actionButtonsContainer
    
    -- Inventory button (circle icon)
    local inventoryButton = Instance.new("ImageButton")
    inventoryButton.Name = "InventoryButton"
    inventoryButton.Size = UDim2.new(0, 45, 0, 45)
    inventoryButton.BackgroundColor3 = COLORS.PRIMARY
    inventoryButton.BackgroundTransparency = 0.2
    inventoryButton.Image = "rbxassetid://8990865464" -- Inventory icon
    inventoryButton.ImageTransparency = 0
    inventoryButton.Parent = actionButtonsContainer
    
    -- Round the inventory button
    local inventoryCorner = Instance.new("UICorner")
    inventoryCorner.CornerRadius = UDim.new(1, 0)
    inventoryCorner.Parent = inventoryButton
    
    -- Create notification badge for inventory (hidden by default)
    local inventoryBadge = Instance.new("Frame")
    inventoryBadge.Name = "NotificationBadge"
    inventoryBadge.Size = UDim2.new(0, 20, 0, 20)
    inventoryBadge.Position = UDim2.new(1, -5, 0, -5)
    inventoryBadge.BackgroundColor3 = COLORS.ERROR
    inventoryBadge.BackgroundTransparency = 0
    inventoryBadge.Visible = false
    inventoryBadge.ZIndex = 2
    inventoryBadge.Parent = inventoryButton
    
    -- Make the badge circular
    local badgeCorner = Instance.new("UICorner")
    badgeCorner.CornerRadius = UDim.new(1, 0)
    badgeCorner.Parent = inventoryBadge
    
    -- Badge text (for count)
    local badgeText = Instance.new("TextLabel")
    badgeText.Name = "BadgeText"
    badgeText.Size = UDim2.new(1, 0, 1, 0)
    badgeText.BackgroundTransparency = 1
    badgeText.Text = "0"
    badgeText.TextColor3 = COLORS.TEXT
    badgeText.Font = Enum.Font.GothamBold
    badgeText.TextSize = 12
    badgeText.ZIndex = 3
    badgeText.Parent = inventoryBadge

    BaseUI.AddRef("screens", "main.inventoryButton", inventoryButton)
    BaseUI.AddRef("screens", "main.inventoryBadge", inventoryBadge)
    BaseUI.AddRef("screens", "main.inventoryBadgeText", badgeText)
    
    inventoryButton.MouseButton1Click:Connect(function()
        MainScreen.OpenModal("Inventory")
        
        -- Hide notification badge when inventory is opened
        if inventoryBadge.Visible then
            inventoryBadge.Visible = false
            badgeText.Text = "0"
        end
    end)
    
    -- Career button (circle icon)
    local careerButton = Instance.new("ImageButton")
    careerButton.Name = "CareerButton"
    careerButton.Size = UDim2.new(0, 45, 0, 45)
    careerButton.BackgroundColor3 = COLORS.INFO
    careerButton.BackgroundTransparency = 0.2
    careerButton.Image = "rbxassetid://8990866023" -- Career icon
    careerButton.ImageTransparency = 0
    careerButton.Parent = actionButtonsContainer
    
    -- Round the career button
    local careerCorner = Instance.new("UICorner")
    careerCorner.CornerRadius = UDim.new(1, 0)
    careerCorner.Parent = careerButton

    BaseUI.AddRef("screens", "main.careerButton", careerButton)
    
    careerButton.MouseButton1Click:Connect(function()
        -- Print debug info but don't show notification unless there's an error
        print("Career button clicked")
        
        local success, error = pcall(function()
            MainScreen.OpenModal("Career")
        end)
        
        if not success then
            print("ERROR when opening Career modal:", error)
            MainScreen.ShowNotification("Error", "Failed to open career panel", "error", 3)
        end
    end)
    
    -- Settings button (circle icon)
    local settingsButton = Instance.new("ImageButton")
    settingsButton.Name = "SettingsButton"
    settingsButton.Size = UDim2.new(0, 45, 0, 45)
    settingsButton.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
    settingsButton.BackgroundTransparency = 0.2
    settingsButton.Image = "rbxassetid://8990866412" -- Settings icon
    settingsButton.ImageTransparency = 0
    settingsButton.Parent = actionButtonsContainer
    
    -- Round the settings button
    local settingsCorner = Instance.new("UICorner")
    settingsCorner.CornerRadius = UDim.new(1, 0)
    settingsCorner.Parent = settingsButton

    BaseUI.AddRef("screens", "main.settingsButton", settingsButton)
    
    settingsButton.MouseButton1Click:Connect(function()
        MainScreen.OpenModal("Settings")
    end)
    
    -- Sprint button (circle icon)
    local sprintButton = Instance.new("ImageButton")
    sprintButton.Name = "SprintButton"
    sprintButton.Size = UDim2.new(0, 45, 0, 45)
    sprintButton.BackgroundColor3 = Color3.fromRGB(76, 175, 80) -- Green for sprint
    sprintButton.BackgroundTransparency = 0.6 -- More transparent when inactive
    sprintButton.Image = "rbxassetid://8990866412" -- Sprint icon
    sprintButton.ImageTransparency = 0
    sprintButton.Parent = actionButtonsContainer
    
    -- Round the sprint button
    local sprintCorner = Instance.new("UICorner")
    sprintCorner.CornerRadius = UDim.new(1, 0)
    sprintCorner.Parent = sprintButton

    BaseUI.AddRef("screens", "main.sprintButton", sprintButton)
    
    -- Function to update sprint button appearance
    local function updateSprintButtonAppearance(enabled)
        isSprintActive = enabled
        
        if isSprintActive then
            -- Active state: more visible
            sprintButton.BackgroundTransparency = 0.2
            sprintButton.BackgroundColor3 = Color3.fromRGB(76, 175, 80) -- Brighter green
        else
            -- Inactive state: more transparent
            sprintButton.BackgroundTransparency = 0.6
            sprintButton.BackgroundColor3 = Color3.fromRGB(76, 175, 80) -- Dimmer green
        end
    end
    
    sprintButton.MouseButton1Click:Connect(function()
        -- Call the PlayerMovementController ToggleSprint function
        if PlayerMovementController and typeof(PlayerMovementController.ToggleSprint) == "function" then
            PlayerMovementController.ToggleSprint()
            -- Button appearance will be updated via the SprintStateChanged event
        else
            MainScreen.ShowNotification("Sprint", "Sprint function not available", "error", 3)
        end
    end)
    
    -- Listen for sprint state changes from the controller
    if PlayerMovementController.SprintStateChanged then
        PlayerMovementController.SprintStateChanged.Event:Connect(function(enabled)
            updateSprintButtonAppearance(enabled)
            MainScreen.ShowNotification(
                "Sprint", 
                enabled and "Sprint mode activated" or "Sprint mode deactivated", 
                "info", 
                1.5
            )
        end)
    end
    
    -- Create notification container
    local notificationContainer = Instance.new("Frame")
    notificationContainer.Name = "NotificationContainer"
    notificationContainer.Size = UDim2.new(1, 0, 1, 0)
    notificationContainer.BackgroundTransparency = 1
    notificationContainer.Parent = mainGui

    BaseUI.AddRef("screens", "main.notificationContainer", notificationContainer)
    
    -- We no longer need this line since we're using BaseUI's reference system
    -- BaseUI.SetUIRefs(uiRefs)

    return BaseUI.GetRefs("screens", "main")
end

-- Connect stat listeners
function MainScreen.ConnectStatListeners()
    -- Listen for stat changes
    PlayerDataController.ListenForData("Stats", function(stats)
        if not stats then return end
        
        -- Update currency display
        if stats.Currency ~= nil then
            local currencyValueText = BaseUI.GetRef("screens", "main.currencyDisplay.valueText")
            if currencyValueText then
                currencyValueText.Text = tostring(stats.Currency)
            end
        end
        
        -- Update health bar with improved format
        if stats.Health ~= nil and stats.MaxHealth ~= nil then
            local healthBar = BaseUI.GetRef("screens", "main.healthBar")
            if healthBar then
                local healthPercent = math.floor((stats.Health / stats.MaxHealth) * 100)
                local formattedText = string.format("%d / %d (%d%%)", stats.Health, stats.MaxHealth, healthPercent)
                healthBar.updateProgress(stats.Health, stats.MaxHealth, formattedText)
            end
        end
        
        -- Update energy bar with improved format
        if stats.Energy ~= nil and stats.MaxEnergy ~= nil then
            local energyBar = BaseUI.GetRef("screens", "main.energyBar")
            if energyBar then
                local energyPercent = math.floor((stats.Energy / stats.MaxEnergy) * 100)
                local formattedText = string.format("%d / %d (%d%%)", stats.Energy, stats.MaxEnergy, energyPercent)
                energyBar.updateProgress(stats.Energy, stats.MaxEnergy, formattedText)
            end
        end
        
        -- Update mood bar with improved format
        if stats.Mood ~= nil and stats.MaxMood ~= nil then
            local moodBar = BaseUI.GetRef("screens", "main.moodBar")
            if moodBar then
                local moodPercent = math.floor((stats.Mood / stats.MaxMood) * 100)
                local formattedText = string.format("%d / %d (%d%%)", stats.Mood, stats.MaxMood, moodPercent)
                moodBar.updateProgress(stats.Mood, stats.MaxMood, formattedText)
            end
        end
    end)
end

-- Update inventory indicator
function MainScreen.UpdateInventoryIndicator(inventoryData)
    local inventoryBadge = BaseUI.GetRef("screens", "main.inventoryBadge")
    local inventoryBadgeText = BaseUI.GetRef("screens", "main.inventoryBadgeText")
    local inventoryButton = BaseUI.GetRef("screens", "main.inventoryButton")
    
    if not inventoryBadge or not inventoryBadgeText or not inventoryButton then
        warn("Inventory UI elements not found")
        return
    end
    
    -- If no inventory data or no new items, hide the badge
    if not inventoryData or not inventoryData.newItems or #inventoryData.newItems == 0 then
        inventoryBadge.Visible = false
        inventoryBadgeText.Text = "0"
        return
    end
    
    -- Show notification badge with count of new items
    local newItemCount = #inventoryData.newItems
    inventoryBadge.Visible = true
    inventoryBadgeText.Text = tostring(math.min(newItemCount, 99))
    
    if newItemCount > 99 then
        inventoryBadgeText.Text = "99+"
    end
    
    -- Optional: Add subtle pulse animation to draw attention
    local TweenService = game:GetService("TweenService")
    local pulseIn = TweenService:Create(
        inventoryButton,
        TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
        {BackgroundTransparency = 0}
    )
    
    local pulseOut = TweenService:Create(
        inventoryButton,
        TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
        {BackgroundTransparency = 0.2}
    )
    
    -- Play pulse sequence
    pulseIn:Play()
    pulseIn.Completed:Connect(function()
        pulseOut:Play()
    end)
end

return MainScreen 