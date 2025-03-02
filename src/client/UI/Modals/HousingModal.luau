--[[
    HousingModal.luau
    Housing modal for viewing and purchasing properties
]]

local HousingModal = {}

-- Services
local TweenService = game:GetService("TweenService")

-- Modules
local BaseUI = require(script.Parent.Parent.BaseUI)
local ModalBase = require(script.Parent.ModalBase)
local PlayerDataController = require(script.Parent.Parent.Parent.Controllers.PlayerDataController)

-- Constants
local COLORS = BaseUI.GetColors()
local TWEEN_INFO = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- Local variables
local activeSection = "Houses"

-- Show the housing modal
function HousingModal.Show()
    -- Get housing data from PlayerDataController
    local housingData = PlayerDataController.GetDataByPath("Housing") or {}
    local ownedHouses = housingData.OwnedHouses or {}
    local availableHouses = housingData.AvailableHouses or {}
    
    -- Create the base modal
    local modalRefs = ModalBase.CreateBaseModal("Housing", UDim2.new(0, 800, 0, 600))
    
    if not modalRefs then
        warn("Failed to create housing modal")
        return
    end
    
    -- Store references in BaseUI
    BaseUI.AddRef("modals", "housing.modal", modalRefs.modal)
    BaseUI.AddRef("modals", "housing.content", modalRefs.content)
    BaseUI.AddRef("modals", "housing.screenGui", modalRefs.screenGui)
    
    -- Create tab buttons container
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.Size = UDim2.new(1, -40, 0, 40)
    tabContainer.Position = UDim2.new(0, 20, 0, 20)
    tabContainer.BackgroundTransparency = 1
    tabContainer.Parent = modalRefs.content
    
    BaseUI.AddRef("modals", "housing.tabContainer", tabContainer)
    
    -- Create tabs
    local tabButtons = {}
    local sections = {"Houses", "Furniture", "Decorations"}
    
    for i, sectionName in ipairs(sections) do
        local tabButton = BaseUI.CreateStyledButton("Tab_" .. sectionName, sectionName)
        tabButton.Size = UDim2.new(0, 150, 0, 36)
        tabButton.Position = UDim2.new(0, (i-1) * 160, 0, 0)
        tabButton.Parent = tabContainer
        
        -- Store reference to tab button
        BaseUI.AddRef("modals", "housing.tabs." .. sectionName, tabButton)
        
        -- Highlight the active tab
        if sectionName == activeSection then
            tabButton.BackgroundColor3 = COLORS.PRIMARY
        end
        
        -- Tab click handler
        tabButton.MouseButton1Click:Connect(function()
            -- Reset all tab colors
            for _, btn in pairs(tabButtons) do
                TweenService:Create(btn, TWEEN_INFO, {BackgroundColor3 = COLORS.PRIMARY}):Play()
            end
            
            -- Highlight selected tab
            TweenService:Create(tabButton, TWEEN_INFO, {BackgroundColor3 = COLORS.PRIMARY:Lerp(Color3.new(1, 1, 1), 0.2)}):Play()
            
            -- Update active section
            activeSection = sectionName
            
            -- Clear and rebuild content
            local contentContainer = BaseUI.GetRef("modals", "housing.content")
            if contentContainer then
                for _, child in pairs(contentContainer:GetChildren()) do
                    if child.Name == "SectionContent" then
                        child:Destroy()
                    end
                end
                
                -- Build the selected section
                if sectionName == "Houses" then
                    buildHousesSection(contentContainer, ownedHouses, availableHouses)
                elseif sectionName == "Furniture" then
                    buildFutureSection(contentContainer, "Furniture")
                elseif sectionName == "Decorations" then
                    buildFutureSection(contentContainer, "Decorations")
                end
            end
        end)
        
        tabButtons[sectionName] = tabButton
    end
    
    -- Build the initial section (Houses)
    buildHousesSection(modalRefs.content, ownedHouses, availableHouses)
    
    -- Connect to housing data updates
    local housingUpdateConnection
    housingUpdateConnection = PlayerDataController.ListenForData("Housing", function(newHousingData)
        local contentContainer = BaseUI.GetRef("modals", "housing.content")
        if not contentContainer or not contentContainer.Parent then
            housingUpdateConnection:Disconnect()
            return
        end
        
        if activeSection == "Houses" and newHousingData then
            for _, child in pairs(contentContainer:GetChildren()) do
                if child.Name == "SectionContent" then
                    child:Destroy()
                end
            end
            
            buildHousesSection(
                contentContainer, 
                newHousingData.OwnedHouses or {}, 
                newHousingData.AvailableHouses or {}
            )
        end
    end)
    
    -- Clean up when modal closes
    modalRefs.screenGui.AncestryChanged:Connect(function(_, newParent)
        if not newParent and housingUpdateConnection then
            housingUpdateConnection:Disconnect()
            housingUpdateConnection = nil
            
            -- Clean up references when modal is closed
            BaseUI.RemoveRef("modals", "housing")
        end
    end)
end

-- Build the Houses section
function buildHousesSection(parent, ownedHouses, availableHouses)
    local sectionContent = Instance.new("ScrollingFrame")
    sectionContent.Name = "SectionContent"
    sectionContent.Size = UDim2.new(1, -40, 1, -80)
    sectionContent.Position = UDim2.new(0, 20, 0, 70)
    sectionContent.BackgroundTransparency = 1
    sectionContent.ScrollBarThickness = 6
    sectionContent.ScrollingDirection = Enum.ScrollingDirection.Y
    sectionContent.CanvasSize = UDim2.new(0, 0, 0, 0) -- Will be updated
    sectionContent.Parent = parent
    
    BaseUI.AddRef("modals", "housing.sectionContent", sectionContent)
    
    -- Setup grid layout
    local gridLayout = Instance.new("UIGridLayout")
    gridLayout.CellSize = UDim2.new(0, 230, 0, 320)
    gridLayout.CellPadding = UDim2.new(0, 15, 0, 15)
    gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    gridLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    gridLayout.Parent = sectionContent
    
    -- Header for owned houses
    if #ownedHouses > 0 then
        local ownedHeader = BaseUI.CreateLabel(
            "OwnedHeader", 
            "Your Properties", 
            UDim2.new(1, 0, 0, 30),
            UDim2.new(0, 0, 0, 0),
            COLORS.TEXT,
            18,
            sectionContent
        )
        ownedHeader.TextXAlignment = Enum.TextXAlignment.Left
        ownedHeader.LayoutOrder = -1
        
        BaseUI.AddRef("modals", "housing.ownedHeader", ownedHeader)
        
        -- Create house cards for owned houses
        for i, house in ipairs(ownedHouses) do
            createHouseCard(house, sectionContent, true)
        end
    end
    
    -- Header for available houses
    if #availableHouses > 0 then
        local availableHeader = BaseUI.CreateLabel(
            "AvailableHeader", 
            "Available Properties", 
            UDim2.new(1, 0, 0, 30),
            UDim2.new(0, 0, 0, 0),
            COLORS.TEXT,
            18,
            sectionContent
        )
        availableHeader.TextXAlignment = Enum.TextXAlignment.Left
        availableHeader.LayoutOrder = 100
        
        BaseUI.AddRef("modals", "housing.availableHeader", availableHeader)
        
        -- Create house cards for available houses
        for i, house in ipairs(availableHouses) do
            createHouseCard(house, sectionContent, false)
        end
    end
    
    -- Update canvas size
    sectionContent.CanvasSize = UDim2.new(0, 0, 0, (math.ceil((#ownedHouses + #availableHouses + 2) / 3) * 335))
end

-- Create a house card
function createHouseCard(house, parent, isOwned)
    local card = Instance.new("Frame")
    card.Name = "HouseCard_" .. house.Id
    card.BackgroundColor3 = COLORS.SECONDARY
    card.BorderSizePixel = 0
    card.Parent = parent
    
    -- Store reference for this house card
    local refPath = "housing.cards." .. house.Id
    BaseUI.AddRef("modals", refPath, card)
    
    -- Apply shadow
    BaseUI.ApplyShadow(card, 10)
    
    -- House image
    local houseImage = Instance.new("ImageLabel")
    houseImage.Name = "HouseImage"
    houseImage.Size = UDim2.new(1, 0, 0, 150)
    houseImage.Position = UDim2.new(0, 0, 0, 0)
    houseImage.BackgroundColor3 = COLORS.BACKGROUND
    houseImage.Image = house.Image or ""
    houseImage.ScaleType = Enum.ScaleType.Crop
    houseImage.BorderSizePixel = 0
    houseImage.Parent = card
    
    BaseUI.AddRef("modals", refPath .. ".image", houseImage)
    
    -- House name
    local nameLabel = BaseUI.CreateLabel(
        "NameLabel", 
        house.Name, 
        UDim2.new(1, -20, 0, 25),
        UDim2.new(0, 10, 0, 160),
        COLORS.TEXT,
        16,
        card
    )
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Font = Enum.Font.GothamBold
    
    BaseUI.AddRef("modals", refPath .. ".nameLabel", nameLabel)
    
    -- House type
    local typeLabel = BaseUI.CreateLabel(
        "TypeLabel", 
        house.Type, 
        UDim2.new(1, -20, 0, 20),
        UDim2.new(0, 10, 0, 185),
        COLORS.TEXT_SECONDARY,
        14,
        card
    )
    typeLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    BaseUI.AddRef("modals", refPath .. ".typeLabel", typeLabel)
    
    -- Stats container
    local statsContainer = Instance.new("Frame")
    statsContainer.Name = "StatsContainer"
    statsContainer.Size = UDim2.new(1, -20, 0, 60)
    statsContainer.Position = UDim2.new(0, 10, 0, 210)
    statsContainer.BackgroundTransparency = 1
    statsContainer.Parent = card
    
    BaseUI.AddRef("modals", refPath .. ".statsContainer", statsContainer)
    
    -- Stats layout
    local statsLayout = Instance.new("UIListLayout")
    statsLayout.FillDirection = Enum.FillDirection.Vertical
    statsLayout.Padding = UDim.new(0, 5)
    statsLayout.Parent = statsContainer
    
    -- Add house stats
    local statEntries = {
        {name = "Value", value = "$" .. tostring(house.Value or 0)},
        {name = "Size", value = tostring(house.Size or 0) .. " sq ft"},
        {name = "Rooms", value = tostring(house.Rooms or 1)}
    }
    
    for _, stat in ipairs(statEntries) do
        local statRow = Instance.new("Frame")
        statRow.Name = "Stat_" .. stat.name
        statRow.Size = UDim2.new(1, 0, 0, 15)
        statRow.BackgroundTransparency = 1
        statRow.Parent = statsContainer
        
        local statName = BaseUI.CreateLabel(
            "StatName", 
            stat.name .. ":", 
            UDim2.new(0, 60, 1, 0),
            UDim2.new(0, 0, 0, 0),
            COLORS.TEXT_SECONDARY,
            12,
            statRow
        )
        statName.TextXAlignment = Enum.TextXAlignment.Left
        
        local statValue = BaseUI.CreateLabel(
            "StatValue", 
            stat.value, 
            UDim2.new(1, -65, 1, 0),
            UDim2.new(0, 65, 0, 0),
            COLORS.TEXT,
            12,
            statRow
        )
        statValue.TextXAlignment = Enum.TextXAlignment.Left
        statValue.Font = Enum.Font.GothamMedium
        
        -- We don't need to store references for individual stat rows
    end
    
    -- Action button
    local actionButton
    if isOwned then
        actionButton = BaseUI.CreateStyledButton("ViewButton", "View Property")
    else
        actionButton = BaseUI.CreateStyledButton("BuyButton", "Buy: $" .. tostring(house.Value or 0))
    end
    
    actionButton.Size = UDim2.new(1, -20, 0, 36)
    actionButton.Position = UDim2.new(0, 10, 1, -46)
    actionButton.Parent = card
    
    BaseUI.AddRef("modals", refPath .. ".actionButton", actionButton)
    
    -- Button click handler
    actionButton.MouseButton1Click:Connect(function()
        if isOwned then
            -- Implement viewing logic
            local MainScreen = require(script.Parent.Parent.Screens.MainScreen)
            MainScreen.ShowNotification("Housing", "Teleporting to your property...", "info", 3)
            
            -- Example remote event call (commented out)
            -- local teleportEvent = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("TeleportToHouse")
            -- teleportEvent:FireServer(house.Id)
        else
            -- Implement purchase logic
            local MainScreen = require(script.Parent.Parent.Screens.MainScreen)
            
            -- Check if player has enough money
            local playerCurrency = PlayerDataController.GetDataByPath("Stats", "Currency") or 0
            
            if playerCurrency >= house.Value then
                local confirmPurchase = Instance.new("BindableFunction")
                
                confirmPurchase.OnInvoke = function(response)
                    if response == "Yes" then
                        -- Example remote event call (commented out)
                        -- local purchaseEvent = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("PurchaseHouse")
                        -- purchaseEvent:FireServer(house.Id)
                        
                        MainScreen.ShowNotification("Purchase", "Property purchase initiated!", "success", 3)
                    end
                end
                
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "Confirm Purchase",
                    Text = "Buy " .. house.Name .. " for $" .. tostring(house.Value) .. "?",
                    Duration = 10,
                    Callback = confirmPurchase,
                    Button1 = "Yes",
                    Button2 = "No"
                })
            else
                MainScreen.ShowNotification("Purchase", "Not enough money to buy this property.", "error", 3)
            end
        end
    end)
end

-- Build a Coming Soon section
function buildFutureSection(parent, sectionName)
    local sectionContent = Instance.new("Frame")
    sectionContent.Name = "SectionContent"
    sectionContent.Size = UDim2.new(1, -40, 1, -80)
    sectionContent.Position = UDim2.new(0, 20, 0, 70)
    sectionContent.BackgroundTransparency = 1
    sectionContent.Parent = parent
    
    BaseUI.AddRef("modals", "housing.futureContent." .. sectionName, sectionContent)
    
    -- Create coming soon message
    local comingSoonFrame = BaseUI.CreateFrame(
        "ComingSoonFrame",
        UDim2.new(1, 0, 0, 200),
        UDim2.new(0, 0, 0.3, 0),
        COLORS.BACKGROUND,
        sectionContent
    )
    
    BaseUI.AddRef("modals", "housing.futureContent." .. sectionName .. ".frame", comingSoonFrame)
    
    -- Coming soon icon
    local iconLabel = Instance.new("ImageLabel")
    iconLabel.Name = "ComingSoonIcon"
    iconLabel.Size = UDim2.new(0, 64, 0, 64)
    iconLabel.Position = UDim2.new(0.5, -32, 0, 30)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Image = "rbxassetid://8990865834" -- Replace with actual coming soon icon
    iconLabel.Parent = comingSoonFrame
    
    BaseUI.AddRef("modals", "housing.futureContent." .. sectionName .. ".icon", iconLabel)
    
    -- Coming soon title
    local titleLabel = BaseUI.CreateLabel(
        "TitleLabel",
        sectionName .. " Coming Soon!",
        UDim2.new(1, 0, 0, 30),
        UDim2.new(0, 0, 0, 110),
        COLORS.TEXT,
        24,
        comingSoonFrame
    )
    titleLabel.TextXAlignment = Enum.TextXAlignment.Center
    
    BaseUI.AddRef("modals", "housing.futureContent." .. sectionName .. ".title", titleLabel)
    
    -- Coming soon description
    local descLabel = BaseUI.CreateLabel(
        "DescLabel",
        "We're working hard to bring you amazing " .. string.lower(sectionName) .. " for your properties.",
        UDim2.new(1, -100, 0, 60),
        UDim2.new(0, 50, 0, 140),
        COLORS.TEXT_SECONDARY,
        16,
        comingSoonFrame
    )
    descLabel.TextWrapped = true
    
    BaseUI.AddRef("modals", "housing.futureContent." .. sectionName .. ".description", descLabel)
end

return HousingModal 