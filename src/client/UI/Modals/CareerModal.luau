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
local GameDataController = require(script.Parent.Parent.Parent.Controllers.GameDataController)

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
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 10)
    listLayout.Parent = careerList
    
    -- Auto-adjust canvas size for career list
    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        careerList.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
    end)
    
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
        UDim2.new(0.6, -20, 0, 40),
        UDim2.new(0, 10, 0, 10),
        COLORS.TEXT,
        24,
        parent
    )
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Visible = false
    
    BaseUI.AddRef("modals", "career.titleLabel", titleLabel)
    
    -- Action button (moved to top right)
    local actionButton = BaseUI.CreateStyledButton(
        "ActionButton",
        "Select Career",
        UDim2.new(0, 200, 0, 40),
        parent
    )
    actionButton.Position = UDim2.new(1, -220, 0, 10)
    actionButton.Visible = false
    actionButton.ZIndex = 10  -- Ensure button is on top
    
    BaseUI.AddRef("modals", "career.actionButton", actionButton)
    
    -- Level requirement warning (moved below action button)
    local levelWarning = BaseUI.CreateLabel(
        "LevelWarning",
        "Requires Level: 5",
        UDim2.new(0, 200, 0, 25),
        UDim2.new(1, -220, 0, 55),
        COLORS.WARNING,
        14,
        parent
    )
    levelWarning.TextXAlignment = Enum.TextXAlignment.Center
    levelWarning.Visible = false
    levelWarning.ZIndex = 10  -- Ensure warning is on top
    
    BaseUI.AddRef("modals", "career.levelWarning", levelWarning)
    
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
    
    -- Career Details section title
    local statsTitle = BaseUI.CreateLabel(
        "StatsTitle",
        "Career Details",
        UDim2.new(1, -20, 0, 30),
        UDim2.new(0, 10, 0, 230),
        COLORS.TEXT,
        18,
        parent
    )
    statsTitle.Font = Enum.Font.GothamBold
    statsTitle.TextXAlignment = Enum.TextXAlignment.Left
    statsTitle.Visible = false
    
    BaseUI.AddRef("modals", "career.statsTitle", statsTitle)
    
    -- Side-by-side container for abilities and gameplay
    local detailsContainer = Instance.new("Frame")
    detailsContainer.Name = "DetailsContainer"
    detailsContainer.Size = UDim2.new(1, -20, 1, -280)
    detailsContainer.Position = UDim2.new(0, 10, 0, 270)
    detailsContainer.BackgroundTransparency = 1
    detailsContainer.BorderSizePixel = 0
    detailsContainer.Visible = false
    detailsContainer.Parent = parent
    
    BaseUI.AddRef("modals", "career.detailsContainer", detailsContainer)
    
    -- Left side - Abilities container
    local abilitiesPanel = Instance.new("Frame")
    abilitiesPanel.Name = "AbilitiesPanel"
    abilitiesPanel.Size = UDim2.new(0.48, 0, 1, 0)
    abilitiesPanel.Position = UDim2.new(0, 0, 0, 0)
    abilitiesPanel.BackgroundColor3 = COLORS.BACKGROUND
    abilitiesPanel.BorderSizePixel = 0
    abilitiesPanel.Parent = detailsContainer
    
    -- Rounded corners for abilities panel
    local abilitiesCorner = Instance.new("UICorner")
    abilitiesCorner.CornerRadius = UDim.new(0, 8)
    abilitiesCorner.Parent = abilitiesPanel
    
    -- Abilities header
    local abilitiesHeader = BaseUI.CreateLabel(
        "AbilitiesHeader",
        "Abilities:",
        UDim2.new(1, -20, 0, 30),
        UDim2.new(0, 10, 0, 10),
        COLORS.TEXT,
        16,
        abilitiesPanel
    )
    abilitiesHeader.Font = Enum.Font.GothamBold
    abilitiesHeader.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Abilities content container (scrollable)
    local abilitiesContainer = Instance.new("ScrollingFrame")
    abilitiesContainer.Name = "AbilitiesContainer"
    abilitiesContainer.Size = UDim2.new(1, -20, 1, -50)
    abilitiesContainer.Position = UDim2.new(0, 10, 0, 40)
    abilitiesContainer.BackgroundTransparency = 1
    abilitiesContainer.BorderSizePixel = 0
    abilitiesContainer.ScrollBarThickness = 4
    abilitiesContainer.ScrollBarImageColor3 = COLORS.PRIMARY
    abilitiesContainer.Parent = abilitiesPanel
    
    -- Add layout for abilities list
    local abilitiesLayout = Instance.new("UIListLayout")
    abilitiesLayout.SortOrder = Enum.SortOrder.LayoutOrder
    abilitiesLayout.Padding = UDim.new(0, 5)
    abilitiesLayout.Parent = abilitiesContainer
    
    -- Auto-adjust canvas size
    abilitiesLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        abilitiesContainer.CanvasSize = UDim2.new(0, 0, 0, abilitiesLayout.AbsoluteContentSize.Y + 5)
    end)
    
    -- Add padding to ensure content isn't right against the edge
    local abilitiesPadding = Instance.new("UIPadding")
    abilitiesPadding.PaddingLeft = UDim.new(0, 5)
    abilitiesPadding.PaddingRight = UDim.new(0, 5)
    abilitiesPadding.PaddingTop = UDim.new(0, 5)
    abilitiesPadding.PaddingBottom = UDim.new(0, 5)
    abilitiesPadding.Parent = abilitiesContainer
    
    BaseUI.AddRef("modals", "career.abilitiesPanel", abilitiesPanel)
    BaseUI.AddRef("modals", "career.abilitiesContainer", abilitiesContainer)
    
    -- Right side - Gameplay container
    local gameplayPanel = Instance.new("Frame")
    gameplayPanel.Name = "GameplayPanel"
    gameplayPanel.Size = UDim2.new(0.48, 0, 1, 0)
    gameplayPanel.Position = UDim2.new(0.52, 0, 0, 0)
    gameplayPanel.BackgroundColor3 = COLORS.BACKGROUND
    gameplayPanel.BorderSizePixel = 0
    gameplayPanel.Parent = detailsContainer
    
    -- Rounded corners for gameplay panel
    local gameplayCorner = Instance.new("UICorner")
    gameplayCorner.CornerRadius = UDim.new(0, 8)
    gameplayCorner.Parent = gameplayPanel
    
    -- Gameplay header
    local gameplayHeader = BaseUI.CreateLabel(
        "GameplayHeader",
        "Gameplay Style:",
        UDim2.new(1, -20, 0, 30),
        UDim2.new(0, 10, 0, 10),
        COLORS.TEXT,
        16,
        gameplayPanel
    )
    gameplayHeader.Font = Enum.Font.GothamBold
    gameplayHeader.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Gameplay content container
    local gameplayContainer = Instance.new("ScrollingFrame")
    gameplayContainer.Name = "GameplayContainer"
    gameplayContainer.Size = UDim2.new(1, -20, 1, -50)
    gameplayContainer.Position = UDim2.new(0, 10, 0, 40)
    gameplayContainer.BackgroundTransparency = 1
    gameplayContainer.BorderSizePixel = 0
    gameplayContainer.ScrollBarThickness = 4
    gameplayContainer.ScrollBarImageColor3 = COLORS.PRIMARY
    gameplayContainer.Parent = gameplayPanel
    
    -- Add layout for gameplay traits
    local gameplayLayout = Instance.new("UIListLayout")
    gameplayLayout.SortOrder = Enum.SortOrder.LayoutOrder
    gameplayLayout.Padding = UDim.new(0, 5)
    gameplayLayout.Parent = gameplayContainer
    
    -- Auto-adjust canvas size
    gameplayLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        gameplayContainer.CanvasSize = UDim2.new(0, 0, 0, gameplayLayout.AbsoluteContentSize.Y + 5)
    end)
    
    -- Add padding to ensure content isn't right against the edge
    local gameplayPadding = Instance.new("UIPadding")
    gameplayPadding.PaddingLeft = UDim.new(0, 5)
    gameplayPadding.PaddingRight = UDim.new(0, 5)
    gameplayPadding.PaddingTop = UDim.new(0, 5)
    gameplayPadding.PaddingBottom = UDim.new(0, 5)
    gameplayPadding.Parent = gameplayContainer
    
    BaseUI.AddRef("modals", "career.gameplayPanel", gameplayPanel)
    BaseUI.AddRef("modals", "career.gameplayContainer", gameplayContainer)
    
    -- Legacy stats container ref for backward compatibility
    local statsContainer = Instance.new("Folder")
    statsContainer.Name = "StatsContainer" 
    statsContainer.Parent = parent
    BaseUI.AddRef("modals", "career.statsContainer", statsContainer)
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
    
    -- Get career data using GameDataController
    local careerData = GameDataController.GetAllCareers()
    if not careerData or next(careerData) == nil then
        warn("Career data not found")
        return
    end
    
    -- Get player's current career
    local playerData = PlayerDataController.GetDataByPath("Player") or {}
    local currentCareer = playerData and playerData.career and playerData.career.id
    
    -- Group careers by type
    local careersByType = {}
    for careerId, careerInfo in pairs(careerData) do
        local careerType = careerInfo.type or "Other"
        if not careersByType[careerType] then
            careersByType[careerType] = {}
        end
        table.insert(careersByType[careerType], {id = careerId, info = careerInfo})
    end
    
    -- Sort career types alphabetically
    local sortedTypes = {}
    for careerType, _ in pairs(careersByType) do
        table.insert(sortedTypes, careerType)
    end
    table.sort(sortedTypes)
    
    -- Track expanded states for accordion sections
    if not _G.careerAccordionStates then
        _G.careerAccordionStates = {}
        -- Default all sections to expanded
        for _, careerType in ipairs(sortedTypes) do
            _G.careerAccordionStates[careerType] = true
        end
    end
    
    -- Create accordion sections for each career type
    local layoutIndex = 1
    for _, careerType in ipairs(sortedTypes) do
        local typeGroup = careersByType[careerType]
        
        -- Skip empty groups
        if #typeGroup == 0 then
            continue
        end
        
        -- Determine if this accordion is expanded
        local isExpanded = _G.careerAccordionStates[careerType] or false
        
        -- Create accordion header
        local accordionHeader = Instance.new("Frame")
        accordionHeader.Name = "TypeHeader_" .. careerType
        accordionHeader.Size = UDim2.new(1, -10, 0, 40)
        accordionHeader.BackgroundColor3 = COLORS.PRIMARY
        accordionHeader.BorderSizePixel = 0
        accordionHeader.LayoutOrder = layoutIndex
        accordionHeader.Parent = careerList
        layoutIndex = layoutIndex + 1
        
        -- Add rounded corners to header
        local headerCorner = Instance.new("UICorner")
        headerCorner.CornerRadius = UDim.new(0, 6)
        headerCorner.Parent = accordionHeader
        
        -- Type name
        local typeLabel = BaseUI.CreateLabel(
            "TypeName",
            careerType,
            UDim2.new(1, -50, 1, 0),
            UDim2.new(0, 10, 0, 0),
            Color3.new(1, 1, 1),
            16,
            accordionHeader
        )
        typeLabel.Font = Enum.Font.GothamBold
        typeLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        -- Create toggle indicator
        local toggleIndicator = Instance.new("TextLabel")
        toggleIndicator.Name = "ToggleIndicator"
        toggleIndicator.Size = UDim2.new(0, 30, 0, 30)
        toggleIndicator.Position = UDim2.new(1, -40, 0.5, -15)
        toggleIndicator.BackgroundTransparency = 1
        toggleIndicator.Text = isExpanded and "▼" or "►"
        toggleIndicator.TextColor3 = Color3.new(1, 1, 1)
        toggleIndicator.TextSize = 16
        toggleIndicator.Font = Enum.Font.GothamBold
        toggleIndicator.Parent = accordionHeader
        
        -- Make header clickable
        local headerButton = Instance.new("TextButton")
        headerButton.Name = "HeaderButton"
        headerButton.Size = UDim2.new(1, 0, 1, 0)
        headerButton.BackgroundTransparency = 1
        headerButton.Text = ""
        headerButton.Parent = accordionHeader
        
        -- Set color based on type
        if careerType == "Business" then
            accordionHeader.BackgroundColor3 = COLORS.SUCCESS
        elseif careerType == "Creative" then
            accordionHeader.BackgroundColor3 = COLORS.INFO
        elseif careerType == "Service" then
            accordionHeader.BackgroundColor3 = COLORS.WARNING
        elseif careerType == "Technical" then
            accordionHeader.BackgroundColor3 = COLORS.PRIMARY
        end
        
        -- Create container for career items
        local careerContainer = Instance.new("Frame")
        careerContainer.Name = "CareerContainer_" .. careerType
        careerContainer.Size = UDim2.new(1, -20, 0, 0)
        careerContainer.Position = UDim2.new(0, 10, 0, 0)
        careerContainer.BackgroundTransparency = 1
        careerContainer.BorderSizePixel = 0
        careerContainer.LayoutOrder = layoutIndex
        careerContainer.AutomaticSize = Enum.AutomaticSize.Y
        careerContainer.Visible = isExpanded
        careerContainer.Parent = careerList
        layoutIndex = layoutIndex + 1
        
        -- Add list layout to career container
        local containerLayout = Instance.new("UIListLayout")
        containerLayout.SortOrder = Enum.SortOrder.Name
        containerLayout.Padding = UDim.new(0, 10)
        containerLayout.Parent = careerContainer
        
        -- Auto-size based on content
        containerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            if careerContainer.Visible then
                careerContainer.Size = UDim2.new(1, -20, 0, containerLayout.AbsoluteContentSize.Y)
            else
                careerContainer.Size = UDim2.new(1, -20, 0, 0)
            end
        end)
        
        -- Populate career items
        for _, careerData in ipairs(typeGroup) do
            local careerId = careerData.id
            local careerInfo = careerData.info
            
            -- Create career item button
            local itemButton = Instance.new("TextButton")
            itemButton.Name = careerId
            itemButton.Size = UDim2.new(1, 0, 0, 50)
            itemButton.BackgroundColor3 = COLORS.BACKGROUND
            itemButton.BorderSizePixel = 0
            itemButton.Text = ""
            itemButton.Parent = careerContainer
            
            -- Add rounded corners
            local itemCorner = Instance.new("UICorner")
            itemCorner.CornerRadius = UDim.new(0, 6)
            itemCorner.Parent = itemButton
            
            -- Highlight current career
            if currentCareer and currentCareer == careerId then
                itemButton.BackgroundColor3 = COLORS.PRIMARY:Lerp(Color3.new(1, 1, 1), 0.2)
            end
            
            -- Career name
            local nameLabel = BaseUI.CreateLabel(
                "NameLabel",
                careerInfo.name,
                UDim2.new(1, -20, 0, 20),
                UDim2.new(0, 10, 0, 15),
                COLORS.TEXT,
                16,
                itemButton
            )
            nameLabel.Font = Enum.Font.GothamBold
            
            -- Handle click
            itemButton.MouseButton1Click:Connect(function()
                displayCareerDetails(careerId, careerInfo)
            end)
        end
        
        -- Toggle accordion when header is clicked
        headerButton.MouseButton1Click:Connect(function()
            isExpanded = not isExpanded
            _G.careerAccordionStates[careerType] = isExpanded
            
            toggleIndicator.Text = isExpanded and "▼" or "►"
            careerContainer.Visible = isExpanded
            
            -- Force layout update
            careerList.CanvasSize = UDim2.new(0, 0, 0, 0)
            task.defer(function()
                local careerListLayout = careerList:FindFirstChildOfClass("UIListLayout")
                if careerListLayout and careerListLayout.AbsoluteContentSize then
                    careerList.CanvasSize = UDim2.new(0, 0, 0, careerListLayout.AbsoluteContentSize.Y + 10)
                end
            end)
        end)
    end
    
    -- Force canvas size update
    task.defer(function()
        local careerListLayout = careerList:FindFirstChildOfClass("UIListLayout")
        if careerListLayout and careerListLayout.AbsoluteContentSize then
            careerList.CanvasSize = UDim2.new(0, 0, 0, careerListLayout.AbsoluteContentSize.Y + 10)
        end
    end)
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
    local detailsContainer = BaseUI.GetRef("modals", "career.detailsContainer")
    local abilitiesContainer = BaseUI.GetRef("modals", "career.abilitiesContainer")
    local gameplayContainer = BaseUI.GetRef("modals", "career.gameplayContainer")
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
        elseif careerInfo.type == "Technical" then
            typeBadge.BackgroundColor3 = COLORS.PRIMARY
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
    
    -- Show section title
    if statsTitle then
        statsTitle.Visible = true
    end
    
    -- Show details container
    if detailsContainer then
        detailsContainer.Visible = true
    end
    
    -- Clear and display abilities
    if abilitiesContainer then
        -- Clear existing abilities
        for _, child in pairs(abilitiesContainer:GetChildren()) do
            if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
                child:Destroy()
            end
        end
        
        if careerInfo.abilities and #careerInfo.abilities > 0 then
            -- List abilities
            for i, ability in ipairs(careerInfo.abilities) do
                local abilityLabel = BaseUI.CreateLabel(
                    "Ability_" .. i,
                    "• " .. ability,
                    UDim2.new(1, -10, 0, 0),
                    UDim2.new(0, 5, 0, 0),
                    COLORS.TEXT_SECONDARY,
                    14,
                    abilitiesContainer
                )
                abilityLabel.TextXAlignment = Enum.TextXAlignment.Left
                abilityLabel.TextWrapped = true
                abilityLabel.LayoutOrder = i
                abilityLabel.AutomaticSize = Enum.AutomaticSize.Y
            end
        else
            -- No abilities message
            local noAbilitiesLabel = BaseUI.CreateLabel(
                "NoAbilitiesMsg",
                "No special abilities for this career",
                UDim2.new(1, -10, 0, 0),
                UDim2.new(0, 5, 0, 0),
                COLORS.TEXT_SECONDARY,
                14,
                abilitiesContainer
            )
            noAbilitiesLabel.TextXAlignment = Enum.TextXAlignment.Left
            noAbilitiesLabel.TextWrapped = true
            noAbilitiesLabel.AutomaticSize = Enum.AutomaticSize.Y
        end
    end
    
    -- Clear and display gameplay info
    if gameplayContainer then
        -- Clear existing gameplay info
        for _, child in pairs(gameplayContainer:GetChildren()) do
            if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
                child:Destroy()
            end
        end
        
        if careerInfo.gameplay then
            -- Create gameplay info
            local index = 1
            for trait, value in pairs(careerInfo.gameplay) do
                local traitContainer = Instance.new("Frame")
                traitContainer.Name = "Trait_" .. trait
                traitContainer.Size = UDim2.new(1, -10, 0, 0)
                traitContainer.BackgroundTransparency = 1
                traitContainer.LayoutOrder = index
                traitContainer.AutomaticSize = Enum.AutomaticSize.Y
                traitContainer.Parent = gameplayContainer
                
                -- Trait name
                local traitLabel = BaseUI.CreateLabel(
                    "TraitName",
                    trait:sub(1,1):upper() .. trait:sub(2) .. ":",
                    UDim2.new(0.4, 0, 0, 0),
                    UDim2.new(0, 0, 0, 0),
                    COLORS.TEXT_SECONDARY,
                    14,
                    traitContainer
                )
                traitLabel.TextXAlignment = Enum.TextXAlignment.Left
                traitLabel.AutomaticSize = Enum.AutomaticSize.Y
                
                -- Trait value
                local valueLabel = BaseUI.CreateLabel(
                    "TraitValue",
                    value,
                    UDim2.new(0.6, -5, 0, 0),
                    UDim2.new(0.4, 0, 0, 0),
                    COLORS.TEXT,
                    14,
                    traitContainer
                )
                valueLabel.TextXAlignment = Enum.TextXAlignment.Left
                valueLabel.TextWrapped = true
                valueLabel.AutomaticSize = Enum.AutomaticSize.Y
                
                index = index + 1
            end
        else
            -- No gameplay info message
            local noGameplayLabel = BaseUI.CreateLabel(
                "NoGameplayMsg",
                "No gameplay information available",
                UDim2.new(1, -10, 0, 0),
                UDim2.new(0, 5, 0, 0),
                COLORS.TEXT_SECONDARY,
                14,
                gameplayContainer
            )
            noGameplayLabel.TextXAlignment = Enum.TextXAlignment.Left
            noGameplayLabel.TextWrapped = true
            noGameplayLabel.AutomaticSize = Enum.AutomaticSize.Y
        end
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
    
    -- Listen for player career data changes
    dataListenerDisconnect = PlayerDataController.ListenForData("career", function()
        -- Refresh career list
        populateCareerList()
        
        -- Refresh career details if one is selected
        if selectedCareer then
            local careerInfo = GameDataController.GetCareerById(selectedCareer)
            if careerInfo then
                displayCareerDetails(selectedCareer, careerInfo)
            end
        end
    end)
    
    -- Also listen for game data (career definitions) changes
    GameDataController.ListenForData("Careers", function()
        populateCareerList()
        
        -- Refresh career details if one is selected
        if selectedCareer then
            local careerInfo = GameDataController.GetCareerById(selectedCareer)
            if careerInfo then
                displayCareerDetails(selectedCareer, careerInfo)
            end
        end
    end)
end

return CareerModal 