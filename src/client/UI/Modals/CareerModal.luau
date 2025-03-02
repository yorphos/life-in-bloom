--[[
    CareerModal.luau
    Career selection and management UI
]]

local CareerModal = {}

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local BaseUI = require(script.Parent.Parent.BaseUI)
local ModalBase = require(script.Parent.ModalBase)
local PlayerDataController = require(script.Parent.Parent.Parent.Controllers.PlayerDataController)

-- Constants
local COLORS = BaseUI.GetColors()

-- Variables
local selectedCareer = nil
local dataListenerDisconnect = nil
local buttonConnections = {}  -- Store connections for proper cleanup

-- Create and show career modal
function CareerModal.Show()
    local modalRefs = ModalBase.CreateBaseModal("Career", UDim2.new(0, 800, 0, 500))
    
    -- Check if modal creation failed
    if not modalRefs then
        warn("Failed to create career modal")
        return
    end
    
    -- Store references in BaseUI
    BaseUI.AddRef("modals", "career.modal", modalRefs.modal)
    BaseUI.AddRef("modals", "career.content", modalRefs.content)
    BaseUI.AddRef("modals", "career.screenGui", modalRefs.screenGui)
    
    -- Create the split layout
    local splitContainer = Instance.new("Frame")
    splitContainer.Name = "SplitContainer"
    splitContainer.Size = UDim2.new(1, 0, 1, -20)
    splitContainer.Position = UDim2.new(0, 0, 0, 10)
    splitContainer.BackgroundTransparency = 1
    splitContainer.Parent = modalRefs.content
    
    -- Left panel (Career List)
    local careerListPanel = Instance.new("Frame")
    careerListPanel.Name = "CareerListPanel"
    careerListPanel.Size = UDim2.new(0.4, -10, 1, 0)
    careerListPanel.BackgroundColor3 = COLORS.SECONDARY
    careerListPanel.BorderSizePixel = 0
    careerListPanel.Parent = splitContainer
    
    BaseUI.AddRef("modals", "career.careerListPanel", careerListPanel)
    
    -- Add rounded corners to career list panel
    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 8)
    listCorner.Parent = careerListPanel
    
    -- Create career list title
    local listTitle = BaseUI.CreateLabel(
        "ListTitle",
        "Career Options",
        UDim2.new(1, -20, 0, 30),
        UDim2.new(0, 10, 0, 10),
        COLORS.TEXT,
        18,
        careerListPanel
    )
    listTitle.Font = Enum.Font.GothamBold
    
    -- Create career list
    local careerList = Instance.new("ScrollingFrame")
    careerList.Name = "CareerList"
    careerList.Size = UDim2.new(1, -20, 1, -60)
    careerList.Position = UDim2.new(0, 10, 0, 50)
    careerList.BackgroundTransparency = 1
    careerList.BorderSizePixel = 0
    careerList.ScrollBarThickness = 6
    careerList.ScrollBarImageColor3 = COLORS.PRIMARY
    careerList.Parent = careerListPanel
    
    BaseUI.AddRef("modals", "career.careerList", careerList)
    
    -- Add list layout
    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.Name
    listLayout.Padding = UDim.new(0, 10)
    listLayout.Parent = careerList
    
    -- Right panel (Career Details)
    local detailsPanel = Instance.new("Frame")
    detailsPanel.Name = "DetailsPanel"
    detailsPanel.Size = UDim2.new(0.6, -10, 1, 0)
    detailsPanel.Position = UDim2.new(0.4, 10, 0, 0)
    detailsPanel.BackgroundColor3 = COLORS.SECONDARY
    detailsPanel.BorderSizePixel = 0
    detailsPanel.Parent = splitContainer
    
    BaseUI.AddRef("modals", "career.detailsPanel", detailsPanel)
    
    -- Add rounded corners to details panel
    local detailsCorner = Instance.new("UICorner")
    detailsCorner.CornerRadius = UDim.new(0, 8)
    detailsCorner.Parent = detailsPanel
    
    -- Create empty state for details panel
    local emptyDetailsText = BaseUI.CreateLabel(
        "EmptyDetails",
        "Select a career to view details",
        UDim2.new(1, -20, 0, 30),
        UDim2.new(0, 10, 0.5, -15),
        COLORS.TEXT_SECONDARY,
        16,
        detailsPanel
    )
    emptyDetailsText.TextXAlignment = Enum.TextXAlignment.Center
    
    BaseUI.AddRef("modals", "career.emptyDetailsText", emptyDetailsText)
    
    -- Create details content (hidden initially)
    createDetailsContent(detailsPanel)
    
    -- Populate career list
    populateCareerList()
    
    -- Set up data listener for career changes
    setupDataListener()
    
    -- Clean up when modal is closed
    modalRefs.screenGui.AncestryChanged:Connect(function(_, newParent)
        if not newParent and dataListenerDisconnect then
            dataListenerDisconnect()
            dataListenerDisconnect = nil
            
            -- Clean up button connections
            for button, connection in pairs(buttonConnections) do
                connection:Disconnect()
            end
            buttonConnections = {}
            
            -- Clean up references when modal is closed
            BaseUI.RemoveRef("modals", "career")
        end
    end)
end

-- Create career details panel content
function createDetailsContent(parent)
    -- Career title
    local titleLabel = BaseUI.CreateLabel(
        "CareerTitle",
        "",
        UDim2.new(1, -20, 0, 40),
        UDim2.new(0, 10, 0, 10),
        COLORS.TEXT,
        24,
        parent
    )
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Visible = false
    
    BaseUI.AddRef("modals", "career.titleLabel", titleLabel)
    
    -- Career type badge
    local typeBadge = Instance.new("Frame")
    typeBadge.Name = "TypeBadge"
    typeBadge.Size = UDim2.new(0, 80, 0, 30)
    typeBadge.Position = UDim2.new(0, 10, 0, 60)
    typeBadge.BackgroundColor3 = COLORS.INFO
    typeBadge.BorderSizePixel = 0
    typeBadge.Visible = false
    typeBadge.Parent = parent
    
    -- Add rounded corners to type badge
    local badgeCorner = Instance.new("UICorner")
    badgeCorner.CornerRadius = UDim.new(0, 15)
    badgeCorner.Parent = typeBadge
    
    -- Badge label
    local typeLabel = BaseUI.CreateLabel(
        "TypeLabel",
        "",
        UDim2.new(1, -10, 1, 0),
        UDim2.new(0.5, 0, 0, 0),
        Color3.new(1, 1, 1),
        14,
        typeBadge
    )
    typeLabel.AnchorPoint = Vector2.new(0.5, 0)
    typeLabel.Font = Enum.Font.GothamBold
    typeLabel.TextXAlignment = Enum.TextXAlignment.Center
    
    BaseUI.AddRef("modals", "career.typeBadge", typeBadge)
    BaseUI.AddRef("modals", "career.typeLabel", typeLabel)
    
    -- Career image
    local image = Instance.new("ImageLabel")
    image.Name = "CareerImage"
    image.Size = UDim2.new(0, 120, 0, 120)
    image.Position = UDim2.new(0, 10, 0, 100)
    image.BackgroundColor3 = COLORS.BACKGROUND
    image.BorderSizePixel = 0
    image.Image = ""
    image.Visible = false
    image.Parent = parent
    
    -- Add rounded corners to image
    local imageCorner = Instance.new("UICorner")
    imageCorner.CornerRadius = UDim.new(0, 8)
    imageCorner.Parent = image
    
    BaseUI.AddRef("modals", "career.image", image)
    
    -- Description background
    local descriptionBg = Instance.new("Frame")
    descriptionBg.Name = "DescriptionBg"
    descriptionBg.Size = UDim2.new(1, -150, 0, 120)
    descriptionBg.Position = UDim2.new(0, 140, 0, 100)
    descriptionBg.BackgroundColor3 = COLORS.BACKGROUND
    descriptionBg.BorderSizePixel = 0
    descriptionBg.Visible = false
    descriptionBg.Parent = parent
    
    -- Add rounded corners to description
    local descCorner = Instance.new("UICorner")
    descCorner.CornerRadius = UDim.new(0, 8)
    descCorner.Parent = descriptionBg
    
    -- Description text
    local descriptionText = Instance.new("TextLabel")
    descriptionText.Name = "DescriptionText"
    descriptionText.Size = UDim2.new(1, -20, 1, -20)
    descriptionText.Position = UDim2.new(0, 10, 0, 10)
    descriptionText.BackgroundTransparency = 1
    descriptionText.Text = ""
    descriptionText.TextColor3 = COLORS.TEXT
    descriptionText.Font = Enum.Font.Gotham
    descriptionText.TextSize = 14
    descriptionText.TextXAlignment = Enum.TextXAlignment.Left
    descriptionText.TextYAlignment = Enum.TextYAlignment.Top
    descriptionText.TextWrapped = true
    descriptionText.Parent = descriptionBg
    
    BaseUI.AddRef("modals", "career.descriptionBg", descriptionBg)
    BaseUI.AddRef("modals", "career.descriptionText", descriptionText)
    
    -- Stats section title
    local statsTitle = BaseUI.CreateLabel(
        "StatsTitle",
        "Career Stats",
        UDim2.new(1, -20, 0, 30),
        UDim2.new(0, 10, 0, 230),
        COLORS.TEXT,
        18,
        parent
    )
    statsTitle.Font = Enum.Font.GothamBold
    statsTitle.Visible = false
    
    BaseUI.AddRef("modals", "career.statsTitle", statsTitle)
    
    -- Stats container
    local statsContainer = Instance.new("Frame")
    statsContainer.Name = "StatsContainer"
    statsContainer.Size = UDim2.new(1, -20, 0, 100)
    statsContainer.Position = UDim2.new(0, 10, 0, 270)
    statsContainer.BackgroundTransparency = 1
    statsContainer.Visible = false
    statsContainer.Parent = parent
    
    BaseUI.AddRef("modals", "career.statsContainer", statsContainer)
    
    -- Action button
    local actionButton = BaseUI.CreateStyledButton(
        "ActionButton",
        "Select Career",
        UDim2.new(0, 200, 0, 50),
        parent
    )
    actionButton.Position = UDim2.new(0.5, -100, 1, -70)
    actionButton.Visible = false
    
    BaseUI.AddRef("modals", "career.actionButton", actionButton)
    
    -- Level requirement warning
    local levelWarning = BaseUI.CreateLabel(
        "LevelWarning",
        "Requires Level: 5",
        UDim2.new(0, 200, 0, 30),
        UDim2.new(0.5, -100, 1, -110),
        COLORS.WARNING,
        14,
        parent
    )
    levelWarning.TextXAlignment = Enum.TextXAlignment.Center
    levelWarning.Visible = false
    
    BaseUI.AddRef("modals", "career.levelWarning", levelWarning)
end

-- Populate the career list with options
function populateCareerList()
    local careerList = BaseUI.GetRef("modals", "career.careerList")
    if not careerList then return end
    
    -- Clear existing items
    for _, child in pairs(careerList:GetChildren()) do
        if not child:IsA("UIListLayout") then
            child:Destroy()
                end
            end
    
    -- Get career data
    local careerData = ReplicatedStorage:FindFirstChild("GameData"):FindFirstChild("Careers")
    if not careerData then
        warn("Career data not found")
        return
    end
    
    -- Get player's current career
    local playerData = PlayerDataController.GetDataByPath("Player") or {}
    local currentCareer = playerData and playerData.career and playerData.career.id
    
    -- For each career, create a list item
    for _, career in pairs(careerData:GetChildren()) do
        if career:IsA("ModuleScript") then
            local careerInfo = require(career)
            
            -- Create career item button
            local itemButton = Instance.new("TextButton")
            itemButton.Name = career.Name
            itemButton.Size = UDim2.new(1, -10, 0, 50)
            itemButton.BackgroundColor3 = COLORS.BACKGROUND
            itemButton.BorderSizePixel = 0
            itemButton.Text = ""
            itemButton.Parent = careerList
            
            -- Add rounded corners
            local itemCorner = Instance.new("UICorner")
            itemCorner.CornerRadius = UDim.new(0, 6)
            itemCorner.Parent = itemButton
            
            -- Highlight current career
            if currentCareer and currentCareer == career.Name then
                itemButton.BackgroundColor3 = COLORS.PRIMARY:Lerp(Color3.new(1, 1, 1), 0.2)
            end
            
            -- Career name
            local nameLabel = BaseUI.CreateLabel(
                "NameLabel",
                careerInfo.name,
                UDim2.new(1, -20, 0, 20),
                UDim2.new(0, 10, 0, 5),
                COLORS.TEXT,
                16,
                itemButton
            )
            nameLabel.Font = Enum.Font.GothamBold
            
            -- Create career type label
            BaseUI.CreateLabel(
                "TypeLabel",
                careerInfo.type,
                UDim2.new(1, -20, 0, 16),
                UDim2.new(0, 10, 0, 25),
                COLORS.TEXT_SECONDARY,
                14,
                itemButton
            )
            
            -- Handle click
            itemButton.MouseButton1Click:Connect(function()
                displayCareerDetails(career.Name, careerInfo)
            end)
            
            -- Adjust list canvas size
            careerList.CanvasSize = UDim2.new(0, 0, 0, (#careerList:GetChildren() - 1) * 60)
        end
    end
end

-- Display career details in the right panel
function displayCareerDetails(careerId, careerInfo)
    selectedCareer = careerId
    
    -- Get references
    local emptyDetailsText = BaseUI.GetRef("modals", "career.emptyDetailsText")
    local titleLabel = BaseUI.GetRef("modals", "career.titleLabel") 
    local typeBadge = BaseUI.GetRef("modals", "career.typeBadge")
    local typeLabel = BaseUI.GetRef("modals", "career.typeLabel")
    local image = BaseUI.GetRef("modals", "career.image")
    local descriptionBg = BaseUI.GetRef("modals", "career.descriptionBg")
    local descriptionText = BaseUI.GetRef("modals", "career.descriptionText")
    local statsTitle = BaseUI.GetRef("modals", "career.statsTitle")
    local statsContainer = BaseUI.GetRef("modals", "career.statsContainer")
    local actionButton = BaseUI.GetRef("modals", "career.actionButton")
    local levelWarning = BaseUI.GetRef("modals", "career.levelWarning")
    
    -- Hide empty state
    if emptyDetailsText then
        emptyDetailsText.Visible = false
    end
    
    -- Update details
    if titleLabel then
        titleLabel.Text = careerInfo.name
        titleLabel.Visible = true
    end
    
    if typeBadge and typeLabel then
        -- Set badge color based on career type
        if careerInfo.type == "Business" then
            typeBadge.BackgroundColor3 = COLORS.SUCCESS
        elseif careerInfo.type == "Creative" then
            typeBadge.BackgroundColor3 = COLORS.INFO
        elseif careerInfo.type == "Service" then
            typeBadge.BackgroundColor3 = COLORS.WARNING
        else
            typeBadge.BackgroundColor3 = COLORS.PRIMARY
        end
        
        typeLabel.Text = careerInfo.type
        typeBadge.Visible = true
    end
    
    if image then
        image.Image = careerInfo.image or ""
        image.Visible = true
    end
    
    if descriptionBg and descriptionText then
        descriptionText.Text = careerInfo.description
        descriptionBg.Visible = true
    end
    
    if statsTitle then
        statsTitle.Visible = true
    end
    
    -- Clear previous stats
    if statsContainer then
        for _, child in pairs(statsContainer:GetChildren()) do
            child:Destroy()
        end
        
        -- Add stat bars
        local statY = 0
        for statName, statValue in pairs(careerInfo.stats) do
            -- Create a simple stat bar display
            local statContainer = Instance.new("Frame")
            statContainer.Name = "Stat_" .. statName
            statContainer.Size = UDim2.new(1, 0, 0, 25)
            statContainer.Position = UDim2.new(0, 0, 0, statY)
            statContainer.BackgroundTransparency = 1
            statContainer.Parent = statsContainer
            
            -- Stat name
            local nameLabel = BaseUI.CreateLabel(
                "StatName",
                statName .. ":",
                UDim2.new(0.4, 0, 1, 0),
                UDim2.new(0, 0, 0, 0),
                COLORS.TEXT_SECONDARY,
                14,
                statContainer
            )
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            
            -- Stat bar background
            local barBg = Instance.new("Frame")
            barBg.Name = "BarBackground"
            barBg.Size = UDim2.new(0.6, -10, 0, 15)
            barBg.Position = UDim2.new(0.4, 5, 0, 5)
            barBg.BackgroundColor3 = COLORS.BACKGROUND
            barBg.BorderSizePixel = 0
            barBg.Parent = statContainer
            
            -- Add rounded corners
            local barCorner = Instance.new("UICorner")
            barCorner.CornerRadius = UDim.new(0, 3)
            barCorner.Parent = barBg
            
            -- Stat bar fill
            local barFill = Instance.new("Frame")
            barFill.Name = "BarFill"
            barFill.Size = UDim2.new(statValue/100, 0, 1, 0)
            barFill.Position = UDim2.new(0, 0, 0, 0)
            barFill.BackgroundColor3 = COLORS.PRIMARY
            barFill.BorderSizePixel = 0
            barFill.Parent = barBg
            
            -- Add rounded corners to fill
            local fillCorner = Instance.new("UICorner")
            fillCorner.CornerRadius = UDim.new(0, 3)
            fillCorner.Parent = barFill
            
            statY = statY + 35
        end
        
        statsContainer.Visible = true
    end
    
    -- Set up action button
    if actionButton then
        local playerData = PlayerDataController.GetDataByPath("Player") or {}
        local currentCareer = playerData and playerData.career and playerData.career.id
        local playerLevel = playerData and playerData.stats and playerData.stats.level or 1
        
        if currentCareer and currentCareer == careerId then
            -- Already in this career
            actionButton.Text = "Current Career"
            actionButton.BackgroundColor3 = COLORS.INFO
            actionButton.Active = false
        else
            -- Different career
            actionButton.Text = "Select Career"
            actionButton.BackgroundColor3 = COLORS.PRIMARY
            actionButton.Active = true
            
            -- Clean up previous connection if it exists
            if buttonConnections[actionButton] then
                buttonConnections[actionButton]:Disconnect()
                buttonConnections[actionButton] = nil
            end
            
            -- Set up new click handler
            buttonConnections[actionButton] = actionButton.MouseButton1Click:Connect(function()
                selectCareer(careerId)
            end)
        end
        
        -- Show level requirement warning if applicable
        if levelWarning then
            if careerInfo.levelRequired and playerLevel < careerInfo.levelRequired then
                levelWarning.Text = "Requires Level: " .. careerInfo.levelRequired
                levelWarning.Visible = true
                actionButton.Active = false
                actionButton.BackgroundColor3 = COLORS.TEXT_SECONDARY
            else
                levelWarning.Visible = false
            end
        end
        
        actionButton.Visible = true
    end
end

-- Handle career selection
function selectCareer(careerId)
    -- This would typically call a remote function
    local RemoteFunctions = ReplicatedStorage:FindFirstChild("RemoteFunctions")
    if RemoteFunctions then
        local SelectCareerFunc = RemoteFunctions:FindFirstChild("SelectCareer")
        if SelectCareerFunc then
            local success, result = pcall(function()
                return SelectCareerFunc:InvokeServer(careerId)
            end)
            
            if success and result then
                print("Career selected successfully:", careerId)
                
                -- Update career list to show new selection
                local careerList = BaseUI.GetRef("modals", "career.careerList")
                if careerList then
                    for _, button in pairs(careerList:GetChildren()) do
                        if button:IsA("TextButton") then
                            if button.Name == careerId then
                                button.BackgroundColor3 = COLORS.PRIMARY:Lerp(Color3.new(1, 1, 1), 0.2)
                            else
                                button.BackgroundColor3 = COLORS.BACKGROUND
                            end
                        end
                    end
                end
                
                -- Update action button
                local actionButton = BaseUI.GetRef("modals", "career.actionButton")
                if actionButton then
                    actionButton.Text = "Current Career"
                    actionButton.BackgroundColor3 = COLORS.INFO
                    actionButton.Active = false
                end
            else
                warn("Failed to select career:", result)
            end
        else
            warn("SelectCareer remote function not found")
        end
    else
        warn("RemoteFunctions not found")
    end
end

-- Setup data listener for career changes
function setupDataListener()
    -- Clean up existing listener first
    if dataListenerDisconnect then
        dataListenerDisconnect()
    end
    
    dataListenerDisconnect = PlayerDataController.ListenForData("career", function()
        -- Refresh career list
        populateCareerList()
        
        -- Refresh career details if one is selected
        if selectedCareer then
            local careerData = ReplicatedStorage:FindFirstChild("GameData"):FindFirstChild("Careers")
            if careerData then
                local careerModule = careerData:FindFirstChild(selectedCareer)
                if careerModule then
                    local careerInfo = require(careerModule)
                    displayCareerDetails(selectedCareer, careerInfo)
                end
            end
        end
    end)
end

return CareerModal 