--[[
    CoreComponents.luau
    Core UI components used throughout the application
]]

local CoreComponents = {}

-- Services
local TweenService = game:GetService("TweenService")

-- Modules
local BaseUI = require(script.Parent.Parent.BaseUI)

-- Local variables
local COLORS = BaseUI.GetColors()
local TWEEN_INFO = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- Notification queue system
local notificationQueue = {}
local isProcessingQueue = false

-- Helper function to process notification queue
local function processNotificationQueue()
    if isProcessingQueue or #notificationQueue == 0 then return end
    
    isProcessingQueue = true
    local nextNotification = table.remove(notificationQueue, 1)
    
    -- Create and display the notification
    local container = nextNotification.createFunc()
    
    -- When this notification is done, process the next one
    task.delay(nextNotification.duration, function()
        TweenService:Create(container, TWEEN_INFO, {Position = UDim2.new(1, 20, 0, 20)}):Play()
        task.delay(0.5, function()
            container:Destroy()
            isProcessingQueue = false
            processNotificationQueue() -- Process next in queue
        end)
    end)
end

-- Create a stat display component (currency, energy, etc.)
function CoreComponents.CreateStatDisplay(name, iconId, initialValue, parent)
    local container = Instance.new("Frame")
    container.Name = name .. "Display"
    container.Size = UDim2.new(0, 110, 0, 40)
    container.BackgroundColor3 = COLORS.SECONDARY
    container.BorderSizePixel = 0
    
    -- Add rounded corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = container
    
    -- Icon
    local icon = Instance.new("ImageLabel")
    icon.Name = "Icon"
    icon.Size = UDim2.new(0, 24, 0, 24)
    icon.Position = UDim2.new(0, 8, 0, 8)
    icon.BackgroundTransparency = 1
    icon.Image = iconId or "rbxassetid://0"
    icon.Parent = container
    
    -- Value text
    local valueText = Instance.new("TextLabel")
    valueText.Name = "Value"
    valueText.Size = UDim2.new(0, 70, 0, 20)
    valueText.Position = UDim2.new(0, 40, 0, 10)
    valueText.BackgroundTransparency = 1
    valueText.Text = tostring(initialValue or 0)
    valueText.TextColor3 = COLORS.TEXT
    valueText.Font = Enum.Font.GothamMedium
    valueText.TextSize = 16
    valueText.TextXAlignment = Enum.TextXAlignment.Right
    valueText.Parent = container
    
    if parent then
        container.Parent = parent
    end
    
    -- Return the container and value text for reference
    return {
        container = container,
        icon = icon,
        valueText = valueText
    }
end

-- Create a progress bar component
function CoreComponents.CreateProgressBar(name, initialValue, maxValue, color, size, parent)
    local container = Instance.new("Frame")
    container.Name = name .. "ProgressBar"
    container.Size = size or UDim2.new(0, 200, 0, 10)
    container.BackgroundColor3 = COLORS.SECONDARY
    container.BorderSizePixel = 0
    
    -- Add rounded corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = container
    
    -- Progress fill
    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.new(initialValue / maxValue, 0, 1, 0)
    fill.BackgroundColor3 = color or COLORS.PRIMARY
    fill.BorderSizePixel = 0
    fill.Parent = container
    
    -- Add corners to fill
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 4)
    fillCorner.Parent = fill
    
    if parent then
        container.Parent = parent
    end
    
    -- Function to update the progress bar
    local function updateProgress(value, max)
        local percent = value / max
        TweenService:Create(fill, TWEEN_INFO, {Size = UDim2.new(percent, 0, 1, 0)}):Play()
    end
    
    -- Return the container and update function
    return {
        container = container,
        fill = fill,
        updateProgress = updateProgress
    }
end

-- Create a notification component
function CoreComponents.CreateNotification(title, message, type, duration, parent)
    -- Create a function that will generate the notification
    local createNotificationFunc = function()
        local container = Instance.new("Frame")
        container.Name = "Notification"
        container.Size = UDim2.new(0, 300, 0, 80)
        container.Position = UDim2.new(1, -320, 0, 20)
        container.BackgroundColor3 = COLORS.SECONDARY
        container.BorderSizePixel = 0
        container.ZIndex = 100
        
        -- Add rounded corners
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = container
        
        -- Status color bar
        local statusBar = Instance.new("Frame")
        statusBar.Name = "StatusBar"
        statusBar.Size = UDim2.new(0, 6, 1, 0)
        statusBar.BackgroundColor3 = COLORS.INFO
        statusBar.BorderSizePixel = 0
        statusBar.ZIndex = 101
        statusBar.Parent = container
        
        -- Set color based on type
        if type == "success" then
            statusBar.BackgroundColor3 = COLORS.SUCCESS
        elseif type == "warning" then
            statusBar.BackgroundColor3 = COLORS.WARNING
        elseif type == "error" then
            statusBar.BackgroundColor3 = COLORS.ERROR
        end
        
        -- Title
        local titleLabel = Instance.new("TextLabel")
        titleLabel.Name = "Title"
        titleLabel.Size = UDim2.new(1, -20, 0, 24)
        titleLabel.Position = UDim2.new(0, 16, 0, 10)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = title or "Notification"
        titleLabel.TextColor3 = COLORS.TEXT
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.TextSize = 16
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.ZIndex = 101
        titleLabel.Parent = container
        
        -- Message
        local messageLabel = Instance.new("TextLabel")
        messageLabel.Name = "Message"
        messageLabel.Size = UDim2.new(1, -20, 0, 36)
        messageLabel.Position = UDim2.new(0, 16, 0, 34)
        messageLabel.BackgroundTransparency = 1
        messageLabel.Text = message or ""
        messageLabel.TextColor3 = COLORS.TEXT_SECONDARY
        messageLabel.Font = Enum.Font.Gotham
        messageLabel.TextSize = 14
        messageLabel.TextXAlignment = Enum.TextXAlignment.Left
        messageLabel.TextWrapped = true
        messageLabel.ZIndex = 101
        messageLabel.Parent = container
        
        -- Apply shadow
        BaseUI.ApplyShadow(container, 40)
        
        -- Display animation
        container.Position = UDim2.new(1, 20, 0, 20) -- Start off-screen
        container.Visible = true
        
        if parent then
            container.Parent = parent
        end
        
        -- Animation in
        TweenService:Create(container, TWEEN_INFO, {Position = UDim2.new(1, -320, 0, 20)}):Play()
        
        return container
    end
    
    -- Add to queue
    table.insert(notificationQueue, {
        createFunc = createNotificationFunc,
        duration = duration or 3
    })
    
    -- Start processing queue if not already processing
    processNotificationQueue()
    
    -- Return a placeholder - the actual container will be created when processed
    return {}
end

-- Create an inventory item card
function CoreComponents.CreateItemCard(itemId, name, description, quantity, iconId, onClickCallback, parent)
    local card = Instance.new("Frame")
    card.Name = "ItemCard_" .. itemId
    card.Size = UDim2.new(0, 140, 0, 140)
    card.BackgroundColor3 = COLORS.SECONDARY
    card.BorderSizePixel = 0
    
    -- Add rounded corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = card
    
    -- Item icon
    local icon = Instance.new("ImageLabel")
    icon.Name = "Icon"
    icon.Size = UDim2.new(0, 80, 0, 80)
    icon.Position = UDim2.new(0.5, 0, 0, 10)
    icon.AnchorPoint = Vector2.new(0.5, 0)
    icon.BackgroundTransparency = 1
    icon.Image = iconId or "rbxassetid://0"
    icon.Parent = card
    
    -- Item name
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "ItemName"
    nameLabel.Size = UDim2.new(1, -10, 0, 20)
    nameLabel.Position = UDim2.new(0, 5, 0, 95)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = name or "Item Name"
    nameLabel.TextColor3 = COLORS.TEXT
    nameLabel.Font = Enum.Font.GothamMedium
    nameLabel.TextSize = 14
    nameLabel.TextXAlignment = Enum.TextXAlignment.Center
    nameLabel.TextWrapped = true
    nameLabel.Parent = card
    
    -- Quantity
    local quantityLabel = Instance.new("TextLabel")
    quantityLabel.Name = "Quantity"
    quantityLabel.Size = UDim2.new(0, 40, 0, 20)
    quantityLabel.Position = UDim2.new(1, -45, 0, 5)
    quantityLabel.BackgroundColor3 = COLORS.PRIMARY
    quantityLabel.BorderSizePixel = 0
    quantityLabel.Text = tostring(quantity or 1)
    quantityLabel.TextColor3 = COLORS.TEXT
    quantityLabel.Font = Enum.Font.GothamBold
    quantityLabel.TextSize = 12
    
    -- Quantity corners
    local quantityCorner = Instance.new("UICorner")
    quantityCorner.CornerRadius = UDim.new(0, 10)
    quantityCorner.Parent = quantityLabel
    
    quantityLabel.Parent = card
    
    -- Click detection button (invisible)
    local button = Instance.new("TextButton")
    button.Name = "ClickDetector"
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Text = ""
    button.Parent = card
    
    -- Click handler
    if onClickCallback then
        button.MouseButton1Click:Connect(function()
            onClickCallback(itemId, name, quantity)
        end)
        
        -- Highlight on hover
        button.MouseEnter:Connect(function()
            TweenService:Create(card, TWEEN_INFO, {BackgroundColor3 = COLORS.SECONDARY:Lerp(COLORS.PRIMARY, 0.1)}):Play()
        end)
        
        button.MouseLeave:Connect(function()
            TweenService:Create(card, TWEEN_INFO, {BackgroundColor3 = COLORS.SECONDARY}):Play()
        end)
    end
    
    if parent then
        card.Parent = parent
    end
    
    return {
        card = card,
        icon = icon,
        nameLabel = nameLabel,
        quantityLabel = quantityLabel,
        updateQuantity = function(newQuantity)
            quantityLabel.Text = tostring(newQuantity)
        end
    }
end

return CoreComponents 