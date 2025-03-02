--[[
    InventoryModal.luau
    Inventory UI modal for viewing and interacting with player's inventory items
]]

local InventoryModal = {}

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Modules
local BaseUI = require(script.Parent.Parent.BaseUI)
local ModalBase = require(script.Parent.ModalBase)
local CoreComponents = require(script.Parent.Parent.Components.CoreComponents)
local PlayerDataController = require(script.Parent.Parent.Parent.Controllers.PlayerDataController)

-- Constants
local COLORS = BaseUI.GetColors()
local TWEEN_INFO = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local CATEGORIES = {
    "All",
    "Consumables",
    "Equipment",
    "Collectibles",
    "Materials",
    "Furniture"
}

-- Local variables
local activeCategory = "All"
local selectedItem = nil
local dataListenerDisconnect = nil
local buttonConnections = {}  -- Store connections for proper cleanup

-- Create and show inventory modal
function InventoryModal.Show()
    print("InventoryModal.Show() called")
    
    local modalRefs = ModalBase.CreateBaseModal("Inventory", UDim2.new(0, 800, 0, 500))
    print("Modal base created")
    
    -- Check if modal creation failed
    if not modalRefs then
        print("ERROR: Modal creation failed")
        return
    end
    
    -- Store references in BaseUI
    BaseUI.AddRef("modals", "inventory.modal", modalRefs.modal)
    BaseUI.AddRef("modals", "inventory.content", modalRefs.content)
    BaseUI.AddRef("modals", "inventory.screenGui", modalRefs.screenGui)
    
    -- Create tabs for different inventory categories
    print("Creating tabs for inventory categories")
    local tabs = Instance.new("Frame")
    tabs.Name = "InventoryTabs"
    tabs.Size = UDim2.new(1, 0, 0, 40)
    tabs.BackgroundTransparency = 1
    tabs.LayoutOrder = 1
    tabs.Parent = modalRefs.content
    
    -- Create tab buttons
    local tabButtons = {}
    for i, category in ipairs(CATEGORIES) do
        local tabButton = BaseUI.CreateStyledButton(
            category .. "Tab",
            category,
            UDim2.new(0, 120, 1, 0),
            tabs
        )
        tabButton.Position = UDim2.new(0, (i-1) * 130, 0, 0)
        tabButton.Size = UDim2.new(0, 120, 1, 0)
        
        -- Set active tab style
        if category == activeCategory then
            tabButton.BackgroundColor3 = COLORS.PRIMARY:Lerp(Color3.new(1, 1, 1), 0.2)
        end
        
        -- Tab click handler
        tabButton.MouseButton1Click:Connect(function()
            switchCategory(category, tabButtons)
        end)
        
        tabButtons[category] = tabButton
    end
    
    -- Create search bar
    local searchContainer = Instance.new("Frame")
    searchContainer.Name = "SearchContainer"
    searchContainer.Size = UDim2.new(1, 0, 0, 40)
    searchContainer.BackgroundTransparency = 1
    searchContainer.LayoutOrder = 2
    searchContainer.Parent = modalRefs.content
    
    local searchBar = Instance.new("TextBox")
    searchBar.Name = "SearchBar"
    searchBar.Size = UDim2.new(1, -20, 1, -10)
    searchBar.Position = UDim2.new(0, 10, 0, 5)
    searchBar.BackgroundColor3 = COLORS.SECONDARY
    searchBar.BorderSizePixel = 0
    searchBar.PlaceholderText = "Search items..."
    searchBar.Text = ""
    searchBar.TextColor3 = COLORS.TEXT
    searchBar.PlaceholderColor3 = COLORS.TEXT_SECONDARY
    searchBar.Font = Enum.Font.Gotham
    searchBar.TextSize = 14
    searchBar.Parent = searchContainer
    
    -- Add rounded corners to search bar
    local searchCorner = Instance.new("UICorner")
    searchCorner.CornerRadius = UDim.new(0, 6)
    searchCorner.Parent = searchBar
    
    -- Store search bar reference
    BaseUI.AddRef("modals", "inventory.searchBar", searchBar)
    
    -- Create main layout container
    local layoutContainer = Instance.new("Frame")
    layoutContainer.Name = "LayoutContainer"
    layoutContainer.Size = UDim2.new(1, 0, 1, -100)
    layoutContainer.BackgroundTransparency = 1
    layoutContainer.LayoutOrder = 3
    layoutContainer.Parent = modalRefs.content
    
    -- Split into grid and details panels
    local itemGridContainer = Instance.new("ScrollingFrame")
    itemGridContainer.Name = "ItemGridContainer"
    itemGridContainer.Size = UDim2.new(0.65, 0, 1, 0)
    itemGridContainer.BackgroundTransparency = 1
    itemGridContainer.BorderSizePixel = 0
    itemGridContainer.ScrollBarThickness = 6
    itemGridContainer.ScrollBarImageColor3 = COLORS.PRIMARY
    itemGridContainer.Parent = layoutContainer
    
    -- Store item grid reference
    BaseUI.AddRef("modals", "inventory.itemGrid", itemGridContainer)
    
    -- Create grid layout for items
    local gridLayout = Instance.new("UIGridLayout")
    gridLayout.CellSize = UDim2.new(0, 140, 0, 140)
    gridLayout.CellPadding = UDim2.new(0, 10, 0, 10)
    gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
    gridLayout.Parent = itemGridContainer
    
    -- Add padding to grid
    local gridPadding = Instance.new("UIPadding")
    gridPadding.PaddingTop = UDim.new(0, 10)
    gridPadding.PaddingLeft = UDim.new(0, 10)
    gridPadding.PaddingRight = UDim.new(0, 10)
    gridPadding.PaddingBottom = UDim.new(0, 10)
    gridPadding.Parent = itemGridContainer
    
    -- Auto-adjust canvas size based on content
    gridLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        itemGridContainer.CanvasSize = UDim2.new(0, 0, 0, gridLayout.AbsoluteContentSize.Y + 20)
    end)
    
    -- Create item details panel
    local detailsPanel = Instance.new("Frame")
    detailsPanel.Name = "DetailsPanel"
    detailsPanel.Size = UDim2.new(0.35, -10, 1, 0)
    detailsPanel.Position = UDim2.new(0.65, 0, 0, 0)
    detailsPanel.BackgroundColor3 = COLORS.SECONDARY
    detailsPanel.BorderSizePixel = 0
    detailsPanel.Parent = layoutContainer
    
    -- Store details panel reference
    BaseUI.AddRef("modals", "inventory.detailsPanel", detailsPanel)
    
    -- Add rounded corners to details panel
    local detailsCorner = Instance.new("UICorner")
    detailsCorner.CornerRadius = UDim.new(0, 8)
    detailsCorner.Parent = detailsPanel
    
    -- Create empty state for details panel
    local emptyDetailsText = BaseUI.CreateLabel(
        "EmptyDetails",
        "Select an item to view details",
        UDim2.new(1, -20, 0, 30),
        UDim2.new(0, 10, 0.5, -15),
        COLORS.TEXT_SECONDARY,
        16,
        detailsPanel
    )
    emptyDetailsText.TextXAlignment = Enum.TextXAlignment.Center
    emptyDetailsText.TextYAlignment = Enum.TextYAlignment.Center
    
    -- Store empty details text reference
    BaseUI.AddRef("modals", "inventory.emptyDetailsText", emptyDetailsText)
    
    -- Create details content (hidden initially)
    createDetailsContent(detailsPanel)
    
    -- Load inventory data
    loadInventoryData()
    
    -- Set up search functionality
    searchBar.Changed:Connect(function(prop)
        if prop == "Text" then
            refreshItemDisplay(activeCategory, searchBar.Text)
        end
    end)
    
    -- Set up data listener for inventory changes
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
            BaseUI.RemoveRef("modals", "inventory")
        end
    end)
end

-- Create details panel content
function createDetailsContent(parent)
    -- Item image
    local itemImage = Instance.new("ImageLabel")
    itemImage.Name = "ItemImage"
    itemImage.Size = UDim2.new(0, 100, 0, 100)
    itemImage.Position = UDim2.new(0.5, 0, 0, 20)
    itemImage.AnchorPoint = Vector2.new(0.5, 0)
    itemImage.BackgroundTransparency = 1
    itemImage.Image = ""
    itemImage.Visible = false
    itemImage.Parent = parent
    
    BaseUI.AddRef("modals", "inventory.itemImage", itemImage)
    
    -- Item name
    local nameLabel = BaseUI.CreateLabel(
        "ItemNameLabel",
        "",
        UDim2.new(1, -20, 0, 25),
        UDim2.new(0, 10, 0, 130),
        COLORS.TEXT,
        18,
        parent
    )
    nameLabel.TextXAlignment = Enum.TextXAlignment.Center
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.Visible = false
    
    BaseUI.AddRef("modals", "inventory.nameLabel", nameLabel)
    
    -- Item description background
    local descriptionBg = Instance.new("Frame")
    descriptionBg.Name = "DescriptionBackground"
    descriptionBg.Size = UDim2.new(1, -20, 0, 100)
    descriptionBg.Position = UDim2.new(0, 10, 0, 165)
    descriptionBg.BackgroundColor3 = COLORS.BACKGROUND
    descriptionBg.BorderSizePixel = 0
    descriptionBg.Visible = false
    
    -- Add rounded corners to description background
    local descCorner = Instance.new("UICorner")
    descCorner.CornerRadius = UDim.new(0, 6)
    descCorner.Parent = descriptionBg
    
    descriptionBg.Parent = parent
    
    BaseUI.AddRef("modals", "inventory.descriptionBg", descriptionBg)
    
    -- Item description
    local descriptionLabel = Instance.new("TextLabel")
    descriptionLabel.Name = "DescriptionLabel"
    descriptionLabel.Size = UDim2.new(1, -20, 1, -10)
    descriptionLabel.Position = UDim2.new(0, 10, 0, 5)
    descriptionLabel.BackgroundTransparency = 1
    descriptionLabel.Text = ""
    descriptionLabel.TextColor3 = COLORS.TEXT
    descriptionLabel.Font = Enum.Font.Gotham
    descriptionLabel.TextSize = 14
    descriptionLabel.TextWrapped = true
    descriptionLabel.TextXAlignment = Enum.TextXAlignment.Left
    descriptionLabel.TextYAlignment = Enum.TextYAlignment.Top
    descriptionLabel.Parent = descriptionBg
    
    BaseUI.AddRef("modals", "inventory.descriptionLabel", descriptionLabel)
    
    -- Action buttons container
    local actionContainer = Instance.new("Frame")
    actionContainer.Name = "ActionContainer"
    actionContainer.Size = UDim2.new(1, -20, 0, 50)
    actionContainer.Position = UDim2.new(0, 10, 0, 275)
    actionContainer.BackgroundTransparency = 1
    actionContainer.Visible = false
    actionContainer.Parent = parent
    
    BaseUI.AddRef("modals", "inventory.actionContainer", actionContainer)
    
    -- Use button
    local useButton = BaseUI.CreateStyledButton(
        "UseButton",
        "Use Item",
        UDim2.new(0.48, 0, 1, 0),
        actionContainer
    )
    
    BaseUI.AddRef("modals", "inventory.useButton", useButton)
    
    -- Sell button
    local sellButton = BaseUI.CreateStyledButton(
        "SellButton",
        "Sell Item",
        UDim2.new(0.48, 0, 1, 0),
        actionContainer
    )
    sellButton.Position = UDim2.new(0.52, 0, 0, 0)
    sellButton.BackgroundColor3 = COLORS.WARNING
    
    BaseUI.AddRef("modals", "inventory.sellButton", sellButton)
end

-- Switch inventory category
function switchCategory(category, tabButtons)
    if category == activeCategory then return end
    
    -- Update active category
    activeCategory = category
    
    -- Update tab button styles
    for name, button in pairs(tabButtons) do
        if name == category then
            TweenService:Create(button, TWEEN_INFO, {
                BackgroundColor3 = COLORS.PRIMARY:Lerp(Color3.new(1, 1, 1), 0.2)
            }):Play()
        else
            TweenService:Create(button, TWEEN_INFO, {
                BackgroundColor3 = COLORS.PRIMARY
            }):Play()
        end
    end
    
    -- Refresh item display
    local searchBar = BaseUI.GetRef("modals", "inventory.searchBar")
    refreshItemDisplay(category, searchBar and searchBar.Text or "")
    
    -- Reset selection
    displayItemDetails(nil)
end

-- Display item details in the details panel
function displayItemDetails(itemData)
    selectedItem = itemData
    
    -- Get references
    local emptyDetailsText = BaseUI.GetRef("modals", "inventory.emptyDetailsText")
    local itemImage = BaseUI.GetRef("modals", "inventory.itemImage")
    local nameLabel = BaseUI.GetRef("modals", "inventory.nameLabel")
    local descriptionBg = BaseUI.GetRef("modals", "inventory.descriptionBg")
    local descriptionLabel = BaseUI.GetRef("modals", "inventory.descriptionLabel")
    local actionContainer = BaseUI.GetRef("modals", "inventory.actionContainer")
    local useButton = BaseUI.GetRef("modals", "inventory.useButton")
    local sellButton = BaseUI.GetRef("modals", "inventory.sellButton")
    
    -- Handle no selection
    if not itemData then
        if emptyDetailsText then emptyDetailsText.Visible = true end
        if itemImage then itemImage.Visible = false end
        if nameLabel then nameLabel.Visible = false end
        if descriptionBg then descriptionBg.Visible = false end
        if actionContainer then actionContainer.Visible = false end
        return
    end
    
    -- Update details panel
    if emptyDetailsText then emptyDetailsText.Visible = false end
    
    -- Update item image
    if itemImage then
        itemImage.Image = itemData.icon or "rbxassetid://0"
        itemImage.Visible = true
    end
    
    -- Update item name
    if nameLabel then
        nameLabel.Text = itemData.name or "Unknown Item"
        nameLabel.Visible = true
    end
    
    -- Update item description
    if descriptionLabel then
        descriptionLabel.Text = itemData.description or "No description available."
    end
    if descriptionBg then
        descriptionBg.Visible = true
    end
    
    -- Update action buttons
    if useButton and itemData.usable then
        useButton.Visible = true
        
        -- Clean up previous connection if it exists
        if buttonConnections[useButton] then
            buttonConnections[useButton]:Disconnect()
            buttonConnections[useButton] = nil
        end
        
        -- Set up new connection
        buttonConnections[useButton] = useButton.MouseButton1Click:Connect(function()
            useItem(itemData.id)
        end)
    elseif useButton then
        useButton.Visible = false
    end
    
    if sellButton then
        -- Clean up previous connection if it exists
        if buttonConnections[sellButton] then
            buttonConnections[sellButton]:Disconnect()
            buttonConnections[sellButton] = nil
        end
        
        -- Set up new connection
        buttonConnections[sellButton] = sellButton.MouseButton1Click:Connect(function()
            sellItem(itemData.id)
        end)
    end
    
    if actionContainer then
        actionContainer.Visible = true
    end
end

-- Load inventory data from PlayerDataController
function loadInventoryData()
    print("Loading inventory data")
    
    -- Clear grid
    local itemGrid = BaseUI.GetRef("modals", "inventory.itemGrid")
    if itemGrid then
        for _, child in pairs(itemGrid:GetChildren()) do
            if not child:IsA("UIGridLayout") and not child:IsA("UIPadding") then
                child:Destroy()
            end
        end
    end
    
    -- Get inventory data
    local inventoryData = PlayerDataController.GetCategoryData("Inventory") or {}
    
    -- Check if data is empty
    if not inventoryData or not next(inventoryData) then
        displayEmptyInventory()
        return
    end
    
    -- Refresh the display with the data
    refreshItemDisplay(activeCategory)
end

-- Display empty inventory message
function displayEmptyInventory()
    print("Displaying empty inventory message")
    
    local itemGrid = BaseUI.GetRef("modals", "inventory.itemGrid")
    if not itemGrid then return end
    
    local emptyContainer = Instance.new("Frame")
    emptyContainer.Name = "EmptyContainer"
    emptyContainer.Size = UDim2.new(1, -20, 0, 150)
    emptyContainer.Position = UDim2.new(0.5, 0, 0, 50)
    emptyContainer.AnchorPoint = Vector2.new(0.5, 0)
    emptyContainer.BackgroundTransparency = 1
    emptyContainer.Parent = itemGrid
    
    local emptyText = BaseUI.CreateLabel(
        "EmptyText",
        "Your inventory is empty!",
        UDim2.new(1, 0, 0, 40),
        UDim2.new(0.5, 0, 0, 0),
        COLORS.TEXT_SECONDARY,
        18,
        emptyContainer
    )
    emptyText.TextXAlignment = Enum.TextXAlignment.Center
    emptyText.AnchorPoint = Vector2.new(0.5, 0)
    
    local helpText = BaseUI.CreateLabel(
        "HelpText",
        "Complete activities to earn items.",
        UDim2.new(1, 0, 0, 40),
        UDim2.new(0.5, 0, 0, 50),
        COLORS.TEXT_SECONDARY,
        14,
        emptyContainer
    )
    helpText.TextXAlignment = Enum.TextXAlignment.Center
    helpText.AnchorPoint = Vector2.new(0.5, 0)
end

-- Refresh item display based on category and search
function refreshItemDisplay(category, searchQuery)
    print("Refreshing item display for category:", category)
    
    local itemGrid = BaseUI.GetRef("modals", "inventory.itemGrid")
    if not itemGrid then return end
    
    -- Clean up any existing "No items" overlays first to prevent duplication
    if itemGrid.Parent then
        for _, child in pairs(itemGrid.Parent:GetChildren()) do
            if child:GetAttribute("NoItemsOverlay") then
                child:Destroy()
            end
        end
    end
    
    -- Clear grid except for layout components
    for _, child in pairs(itemGrid:GetChildren()) do
        if not child:IsA("UIGridLayout") and not child:IsA("UIPadding") then
            child:Destroy()
        end
    end
    
    -- Get inventory data
    local inventoryData = PlayerDataController.GetCategoryData("Inventory") or {}
    
    -- Check if data is empty
    if not inventoryData or not next(inventoryData) then
        displayEmptyInventory()
        return
    end
    
    local hasDisplayedItems = false
    local layoutIndex = 1
    
    -- Convert to array for easier manipulation
    local itemsArray = {}
    for id, itemData in pairs(inventoryData) do
        itemData.id = id -- Store the ID in the data
        table.insert(itemsArray, itemData)
    end
    
    -- Sort by name
    table.sort(itemsArray, function(a, b)
        return (a.name or "") < (b.name or "")
    end)
    
    -- Filter and display items
    for _, itemData in ipairs(itemsArray) do
        -- Apply category filter
        if category == "All" or itemData.category == category then
            -- Apply search filter if needed
            if not searchQuery or searchQuery == "" or 
               string.find(string.lower(itemData.name or ""), string.lower(searchQuery)) then
                
                -- Create item card
                local itemCard = CoreComponents.CreateItemCard(
                    itemData.id,
                    itemData.name,
                    itemData.description,
                    itemData.quantity,
                    itemData.icon,
                    function(id, name, quantity)
                        displayItemDetails(itemData)
                    end,
                    itemGrid
                )
                
                itemCard.card.LayoutOrder = layoutIndex
                layoutIndex = layoutIndex + 1
                hasDisplayedItems = true
            end
        end
    end
    
    -- If no items match the filters, show message
    if not hasDisplayedItems then
        -- Create an overlay frame that will display on top of the grid
        local messageOverlay = Instance.new("Frame")
        messageOverlay.Name = "NoItemsOverlay"
        messageOverlay.Size = UDim2.new(1, 0, 1, 0)
        messageOverlay.Position = UDim2.new(0, 0, 0, 0)
        messageOverlay.BackgroundTransparency = 1
        messageOverlay.ZIndex = 10 -- Make sure it appears on top
        
        -- Use Roblox's SetAttribute to mark it for future identification
        messageOverlay:SetAttribute("NoItemsOverlay", true)
        
        -- Anchor the message overlay to parent it outside the grid layout influence
        messageOverlay.Parent = itemGrid.Parent
        
        -- Create the no items message in the overlay
        local noItemsText = BaseUI.CreateLabel(
            "NoItemsText",
            "No items found.",
            UDim2.new(0, 300, 0, 40),
            UDim2.new(0.5, 0, 0.3, 0),
            COLORS.TEXT_SECONDARY,
            18,
            messageOverlay
        )
        noItemsText.TextXAlignment = Enum.TextXAlignment.Center
        noItemsText.AnchorPoint = Vector2.new(0.5, 0.5)
        noItemsText.ZIndex = 11
        
        -- Position the overlay directly over the item grid
        messageOverlay.Position = itemGrid.Position
        messageOverlay.Size = itemGrid.Size
    end
end

-- Setup data listener for inventory updates
function setupDataListener()
    -- Clean up existing listener first
    if dataListenerDisconnect then
        dataListenerDisconnect()
    end
    
    dataListenerDisconnect = PlayerDataController.ListenForData("Inventory", function(newData)
        print("Inventory data updated")
        
        local searchBar = BaseUI.GetRef("modals", "inventory.searchBar")
        refreshItemDisplay(activeCategory, searchBar and searchBar.Text or "")
        
        -- Update selected item details if needed
        if selectedItem then
            local updatedItemData = newData[selectedItem.id]
            if updatedItemData then
                -- Update with new data but preserve ID
                updatedItemData.id = selectedItem.id
                displayItemDetails(updatedItemData)
            else
                -- Item was removed
                displayItemDetails(nil)
            end
        end
    end)
end

-- Use item function
function useItem(itemId)
    print("Using item:", itemId)
    
    -- Get the item category from the selectedItem data
    local category = selectedItem and selectedItem.category or "Consumables"
    
    -- Use the PlayerDataController to handle the remote call
    local success, result = PlayerDataController.UseItem(category, itemId)
    
    if success then
        print("Item used successfully:", result)
    else
        warn("Failed to use item:", result)
    end
end

-- Sell item function
function sellItem(itemId)
    print("Selling item:", itemId)
    
    -- Get the item category from the selectedItem data
    local category = selectedItem and selectedItem.category or "Consumables"
    
    -- Use the PlayerDataController to handle the remote call
    local success, result = PlayerDataController.SellItem(category, itemId)
    
    if success then
        print("Item sold successfully for", result, "coins")
    else
        warn("Failed to sell item:", result)
    end
end

return InventoryModal