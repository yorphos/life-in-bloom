--[[
    DebugGUIController.lua
    Client-side debug GUI for displaying player data
]]

local DebugGUIController = {}

-- Services
local Players = game:GetService("Players")

-- Modules
local PlayerDataController

-- Constants
local GUI_WIDTH = 300
local GUI_HEIGHT = 400
local FONT = Enum.Font.SourceSans
local TEXT_SIZE = 14
local HEADER_SIZE = 18
local COLORS = {
    BACKGROUND = Color3.fromRGB(40, 40, 40),
    TEXT = Color3.fromRGB(255, 255, 255),
    HEADER = Color3.fromRGB(60, 120, 220),
    CATEGORY = Color3.fromRGB(80, 180, 120),
    VALUE_STRING = Color3.fromRGB(200, 180, 100),
    VALUE_NUMBER = Color3.fromRGB(100, 200, 255),
    VALUE_BOOLEAN = Color3.fromRGB(255, 100, 100),
    BORDER = Color3.fromRGB(60, 60, 60),
    BUTTON = Color3.fromRGB(60, 60, 70),
    BUTTON_HOVER = Color3.fromRGB(80, 80, 90),
    SCROLL_BAR = Color3.fromRGB(80, 80, 80),
}

-- GUI elements
local debugGui = nil
local mainFrame = nil
local contentFrame = nil
local expandedCategories = {}

-- Helper function to create styled text labels
local function createTextLabel(parent, text, position, size, textColor, fontSize)
    local label = Instance.new("TextLabel")
    label.Text = text
    label.Position = position
    label.Size = size
    label.TextColor3 = textColor or COLORS.TEXT
    label.BackgroundTransparency = 1
    label.Font = FONT
    label.TextSize = fontSize or TEXT_SIZE
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextWrapped = true
    label.Parent = parent
    
    return label
end

-- Helper function to create expand/collapse buttons
local function createExpandButton(parent, position, isExpanded, callback)
    local button = Instance.new("TextButton")
    button.Text = isExpanded and "-" or "+"
    button.Position = position
    button.Size = UDim2.new(0, 20, 0, 20)
    button.TextColor3 = COLORS.TEXT
    button.BackgroundColor3 = COLORS.BUTTON
    button.Font = FONT
    button.TextSize = TEXT_SIZE
    button.BorderSizePixel = 0
    button.Parent = parent
    
    button.MouseButton1Click:Connect(callback)
    
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = COLORS.BUTTON_HOVER
    end)
    
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = COLORS.BUTTON
    end)
    
    return button
end

-- Clear and rebuild the entire display
local function rebuildDisplay()
    if not contentFrame then return end
    
    -- Clear existing content
    for _, child in pairs(contentFrame:GetChildren()) do
        if child:IsA("GuiObject") then
            child:Destroy()
        end
    end
    
    -- Get the current player data
    local playerData = PlayerDataController.GetData()
    if not playerData or not next(playerData) then
        createTextLabel(contentFrame, "No player data available yet", UDim2.new(0, 5, 0, 5), UDim2.new(1, -10, 0, 30))
        return
    end
    
    -- Create header label
    createTextLabel(
        contentFrame, 
        "Player Data Debug View", 
        UDim2.new(0, 5, 0, 5), 
        UDim2.new(1, -10, 0, 30),
        COLORS.HEADER,
        HEADER_SIZE
    )
    
    local yPosition = 40
    
    -- Process each data category
    for category, data in pairs(playerData) do
        if type(data) == "table" then
            -- Create category header with expand/collapse button
            local isExpanded = expandedCategories[category] == true
            
            -- Create expand categories button
            createExpandButton(
                contentFrame,
                UDim2.new(0, 5, 0, yPosition),
                isExpanded,
                function()
                    expandedCategories[category] = not expandedCategories[category]
                    rebuildDisplay()
                end
            )
            
            -- Create category label
            createTextLabel(
                contentFrame,
                category,
                UDim2.new(0, 30, 0, yPosition),
                UDim2.new(1, -35, 0, 20),
                COLORS.CATEGORY,
                TEXT_SIZE + 2
            )
            
            yPosition = yPosition + 25
            
            -- Show contents if expanded
            if isExpanded then
                yPosition = displayTableData(contentFrame, data, yPosition, 1)
            end
            
            -- Add a separator
            local separator = Instance.new("Frame")
            separator.Position = UDim2.new(0, 5, 0, yPosition)
            separator.Size = UDim2.new(1, -10, 0, 1)
            separator.BackgroundColor3 = COLORS.BORDER
            separator.BorderSizePixel = 0
            separator.Parent = contentFrame
            
            yPosition = yPosition + 10
        end
    end
    
    -- Update scrolling frame content size
    contentFrame.CanvasSize = UDim2.new(0, 0, 0, yPosition + 10)
end

-- Recursive function to display nested table data
function displayTableData(parent, data, yPosition, depth)
    local indent = depth * 20
    
    -- Check if this is an array-like table
    local isArray = (function()
        local count = 0
        for _ in pairs(data) do
            count = count + 1
        end
        
        -- If all keys are sequential numbers starting from 1
        for i = 1, count do
            if data[i] == nil then
                return false
            end
        end
        
        return count > 0
    end)()
    
    -- Sort keys for consistent display order
    local keys = {}
    for key in pairs(data) do
        table.insert(keys, key)
    end
    
    -- For non-array tables, sort alphabetically
    if not isArray then
        table.sort(keys, function(a, b)
            if type(a) == "string" and type(b) == "string" then
                return a:lower() < b:lower()
            elseif type(a) == "number" and type(b) == "number" then
                return a < b
            else
                return tostring(a) < tostring(b)
            end
        end)
    end
    
    for _, key in ipairs(keys) do
        local value = data[key]
        local valueType = type(value)
        local valueText = tostring(value)
        local valueColor = COLORS.TEXT
        
        -- Determine color based on value type
        if valueType == "string" then
            valueText = '"' .. valueText .. '"'
            valueColor = COLORS.VALUE_STRING
        elseif valueType == "number" then
            valueColor = COLORS.VALUE_NUMBER
        elseif valueType == "boolean" then
            valueColor = COLORS.VALUE_BOOLEAN
        end
        
        if valueType == "table" then
            -- All tables should be expandable, even empty ones
            local subCategoryKey = tostring(key)
            local fullKey = string.format("%d_%s", depth, subCategoryKey)
            local isExpanded = expandedCategories[fullKey] == true
            
            -- Create expand button and key label
            createExpandButton(
                parent,
                UDim2.new(0, indent + 5, 0, yPosition),
                isExpanded,
                function()
                    expandedCategories[fullKey] = not expandedCategories[fullKey]
                    rebuildDisplay()
                end
            )
            
            -- Add entry count for tables
            local count = 0
            for _ in pairs(value) do
                count = count + 1
            end
            
            local label = subCategoryKey .. ": " .. (count > 0 and "(" .. count .. " items)" or "(empty)")
            
            createTextLabel(
                parent,
                label,
                UDim2.new(0, indent + 30, 0, yPosition),
                UDim2.new(1, -(indent + 35), 0, 20)
            )
            
            yPosition = yPosition + 25
            
            -- Show nested table data if expanded
            if isExpanded then
                if count > 0 then
                    yPosition = displayTableData(parent, value, yPosition, depth + 1)
                else
                    createTextLabel(
                        parent,
                        "(empty table)",
                        UDim2.new(0, indent + 50, 0, yPosition),
                        UDim2.new(1, -(indent + 55), 0, 20),
                        COLORS.VALUE_STRING
                    )
                    yPosition = yPosition + 25
                end
            end
        else
            -- For simple values, just display key-value pair
            createTextLabel(
                parent,
                tostring(key) .. ":",
                UDim2.new(0, indent + 5, 0, yPosition),
                UDim2.new(0.4, -(indent + 10), 0, 20)
            )
            
            createTextLabel(
                parent,
                valueText,
                UDim2.new(0.4, indent, 0, yPosition),
                UDim2.new(0.6, -(indent + 5), 0, 20),
                valueColor
            )
            
            yPosition = yPosition + 25
        end
    end
    
    return yPosition
end

-- Create the main debug GUI
local function createDebugGUI()
    local localPlayer = Players.LocalPlayer
    if not localPlayer then return end
    
    -- Get the PlayerGui (should already exist)
    local playerGui = localPlayer:FindFirstChild("PlayerGui")
    if not playerGui then
        warn("[DEBUG_GUI] PlayerGui not found, waiting for it...")
        playerGui = localPlayer:WaitForChild("PlayerGui", 5)
        if not playerGui then
            warn("[DEBUG_GUI] Could not find PlayerGui after waiting, attempting to create it")
            playerGui = Instance.new("ScreenGui")
            playerGui.Name = "PlayerGui"
            playerGui.Parent = localPlayer
        end
    end
    
    -- Check if the debug GUI already exists and remove it
    local existingGui = playerGui:FindFirstChild("DebugDataGUI")
    if existingGui then
        existingGui:Destroy()
    end
    
    -- Create ScreenGui
    debugGui = Instance.new("ScreenGui")
    debugGui.Name = "DebugDataGUI"
    debugGui.ResetOnSpawn = false
    debugGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    debugGui.Parent = playerGui
    
    -- Create toggle button (fixed in corner)
    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "ToggleButton"
    toggleButton.Text = "Debug"
    toggleButton.Size = UDim2.new(0, 60, 0, 30)
    toggleButton.Position = UDim2.new(1, -65, 0, 5)
    toggleButton.BackgroundColor3 = COLORS.BUTTON
    toggleButton.TextColor3 = COLORS.TEXT
    toggleButton.Font = FONT
    toggleButton.TextSize = TEXT_SIZE
    toggleButton.BorderSizePixel = 1
    toggleButton.BorderColor3 = COLORS.BORDER
    toggleButton.Parent = debugGui
    
    -- Add toggle button behavior
    toggleButton.MouseButton1Click:Connect(function()
        mainFrame.Visible = not mainFrame.Visible
        -- If showing, refresh the display
        if mainFrame.Visible then
            rebuildDisplay()
        end
    end)
    
    -- Create main frame (initially visible)
    mainFrame = Instance.new("Frame")
    mainFrame.Name = "DebugFrame"
    mainFrame.Size = UDim2.new(0, GUI_WIDTH, 0, GUI_HEIGHT)
    mainFrame.Position = UDim2.new(1, -GUI_WIDTH - 5, 0, 40)
    mainFrame.BackgroundColor3 = COLORS.BACKGROUND
    mainFrame.BorderSizePixel = 1
    mainFrame.BorderColor3 = COLORS.BORDER
    mainFrame.Visible = true -- Show by default
    mainFrame.Parent = debugGui
    
    -- Make frame draggable
    local isDragging = false
    local dragStart
    local startPos
    
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundColor3 = COLORS.HEADER
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    
    -- Create title label
    createTextLabel(
        titleBar,
        "Player Data Debug",
        UDim2.new(0, 10, 0, 0),
        UDim2.new(1, -20, 1, 0),
        COLORS.TEXT,
        16
    )
    
    local closeButton = Instance.new("TextButton")
    closeButton.Text = "X"
    closeButton.Size = UDim2.new(0, 25, 0, 25)
    closeButton.Position = UDim2.new(1, -30, 0, 2)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    closeButton.TextColor3 = COLORS.TEXT
    closeButton.Font = FONT
    closeButton.TextSize = 16
    closeButton.BorderSizePixel = 0
    closeButton.Parent = titleBar
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)
    
    titleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)
    
    titleBar.InputChanged:Connect(function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    -- Create refresh button
    local refreshButton = Instance.new("TextButton")
    refreshButton.Text = "Refresh"
    refreshButton.Size = UDim2.new(0, 80, 0, 25)
    refreshButton.Position = UDim2.new(0, 10, 0, 35)
    refreshButton.BackgroundColor3 = COLORS.BUTTON
    refreshButton.TextColor3 = COLORS.TEXT
    refreshButton.Font = FONT
    refreshButton.TextSize = TEXT_SIZE
    refreshButton.BorderSizePixel = 1
    refreshButton.BorderColor3 = COLORS.BORDER
    refreshButton.Parent = mainFrame
    
    -- Create expand all button
    local expandButton = Instance.new("TextButton")
    expandButton.Text = "Expand All"
    expandButton.Size = UDim2.new(0, 80, 0, 25)
    expandButton.Position = UDim2.new(0.5, -40, 0, 35)
    expandButton.BackgroundColor3 = COLORS.BUTTON
    expandButton.TextColor3 = COLORS.TEXT
    expandButton.Font = FONT
    expandButton.TextSize = TEXT_SIZE
    expandButton.BorderSizePixel = 1
    expandButton.BorderColor3 = COLORS.BORDER
    expandButton.Parent = mainFrame
    
    -- Create collapse all button
    local collapseButton = Instance.new("TextButton")
    collapseButton.Text = "Collapse All"
    collapseButton.Size = UDim2.new(0, 80, 0, 25)
    collapseButton.Position = UDim2.new(1, -90, 0, 35)
    collapseButton.BackgroundColor3 = COLORS.BUTTON
    collapseButton.TextColor3 = COLORS.TEXT
    collapseButton.Font = FONT
    collapseButton.TextSize = TEXT_SIZE
    collapseButton.BorderSizePixel = 1
    collapseButton.BorderColor3 = COLORS.BORDER
    collapseButton.Parent = mainFrame
    
    -- Create scrolling content frame
    contentFrame = Instance.new("ScrollingFrame")
    contentFrame.Name = "ContentFrame"
    contentFrame.Size = UDim2.new(1, -10, 1, -70)
    contentFrame.Position = UDim2.new(0, 5, 0, 65)
    contentFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    contentFrame.BorderSizePixel = 1
    contentFrame.BorderColor3 = COLORS.BORDER
    contentFrame.ScrollBarThickness = 8
    contentFrame.ScrollBarImageColor3 = COLORS.SCROLL_BAR
    contentFrame.CanvasSize = UDim2.new(0, 0, 0, 1000) -- Will be adjusted dynamically
    contentFrame.Parent = mainFrame
    
    -- Add resize handle in the bottom-right corner
    local resizeHandle = Instance.new("TextButton")
    resizeHandle.Name = "ResizeHandle"
    resizeHandle.Text = "⬊"
    resizeHandle.Size = UDim2.new(0, 20, 0, 20)
    resizeHandle.Position = UDim2.new(1, -20, 1, -20)
    resizeHandle.BackgroundTransparency = 0.5
    resizeHandle.BackgroundColor3 = COLORS.HEADER
    resizeHandle.TextColor3 = COLORS.TEXT
    resizeHandle.Font = FONT
    resizeHandle.TextSize = 16
    resizeHandle.Parent = mainFrame
    
    -- Make the frame resizable
    local isResizing = false
    local resizeStart
    local startSize
    
    resizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isResizing = true
            resizeStart = input.Position
            startSize = mainFrame.Size
        end
    end)
    
    resizeHandle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isResizing = false
        end
    end)
    
    resizeHandle.InputChanged:Connect(function(input)
        if isResizing and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - resizeStart
            local newWidth = math.max(300, startSize.X.Offset + delta.X)
            local newHeight = math.max(200, startSize.Y.Offset + delta.Y)
            
            -- Ensure the frame stays within screen bounds
            local absoluteSize = debugGui.AbsoluteSize
            newWidth = math.min(newWidth, absoluteSize.X - mainFrame.AbsolutePosition.X)
            newHeight = math.min(newHeight, absoluteSize.Y - mainFrame.AbsolutePosition.Y)
            
            mainFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
            
            -- Update content frame size
            contentFrame.Size = UDim2.new(1, -10, 1, -95)
        end
    end)
    
    -- Connect button functionality
    closeButton.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
    end)
    
    refreshButton.MouseButton1Click:Connect(function()
        rebuildDisplay()
    end)
    
    expandButton.MouseButton1Click:Connect(function()
        -- Expand all categories
        for category, data in pairs(PlayerDataController.GetData() or {}) do
            if type(data) == "table" then
                expandedCategories[category] = true
                expandAllTables(data, 1, category)
            end
        end
        rebuildDisplay()
    end)
    
    collapseButton.MouseButton1Click:Connect(function()
        -- Collapse all categories
        expandedCategories = {}
        rebuildDisplay()
    end)
    
    -- Initialize the display
    rebuildDisplay()
end

-- Helper function to recursively expand all tables
function expandAllTables(data, depth, prefix)
    for key, value in pairs(data) do
        if type(value) == "table" and next(value) ~= nil then
            local fullKey = string.format("%d_%s", depth, key)
            if prefix then
                fullKey = prefix .. "_" .. fullKey
            end
            expandedCategories[fullKey] = true
            expandAllTables(value, depth + 1, fullKey)
        end
    end
end

-- Set up data listeners to automatically update the display
local function setupDataListeners()
    -- Listen for any data changes
    PlayerDataController.WhenDataReady(function()
        rebuildDisplay()
    end)
    
    -- Listen for specific data categories
    local categories = {"Stats", "Inventory", "Careers", "Profile"}
    for _, category in ipairs(categories) do
        PlayerDataController.ListenForData(category, function()
            if mainFrame and mainFrame.Visible then
                rebuildDisplay()
            end
        end)
    end
end

-- Initialize the controller
function DebugGUIController.Initialize()
    local success, err = pcall(function()
        -- Reference PlayerDataController
        PlayerDataController = require(script.Parent.PlayerDataController)
        
        -- Create the debug GUI
        createDebugGUI()
        
        -- Set up data change listeners
        setupDataListeners()
    end)
    
    if not success then
        warn("[DEBUG_GUI] Failed to initialize: " .. tostring(err))
        return false
    end
    
    print("[DEBUG_GUI] Debug GUI controller initialized")
    return true
end

return DebugGUIController 