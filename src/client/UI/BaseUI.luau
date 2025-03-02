--[[
    BaseUI.luau
    Base UI utility functions and common elements
]]

local BaseUI = {}

-- Services
local TweenService = game:GetService("TweenService")

-- Constants
local TWEEN_INFO = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local COLORS = {
    PRIMARY = Color3.fromRGB(65, 165, 238),    -- Light blue
    SECONDARY = Color3.fromRGB(45, 50, 60),    -- Dark blue-gray
    BACKGROUND = Color3.fromRGB(40, 45, 55),   -- Darker blue-gray
    TEXT = Color3.fromRGB(255, 255, 255),      -- White
    TEXT_SECONDARY = Color3.fromRGB(200, 200, 200), -- Light gray
    SUCCESS = Color3.fromRGB(76, 209, 55),     -- Green
    WARNING = Color3.fromRGB(255, 198, 42),    -- Yellow
    ERROR = Color3.fromRGB(235, 64, 52),       -- Red
    INFO = Color3.fromRGB(116, 118, 255),      -- Purple
    ENERGY = Color3.fromRGB(76, 209, 55),      -- Green for energy bar
    HEALTH = Color3.fromRGB(235, 64, 52),      -- Red for health bar
    MOOD = Color3.fromRGB(255, 198, 42),       -- Yellow for mood bar
    MONEY = Color3.fromRGB(255, 184, 51)       -- Gold for currency
}

-- Variables
local playerGui 
local uiRefs = {
    -- Core UI
    core = {},
    -- Modal windows
    modals = {},
    -- Screens
    screens = {},
    -- Components
    components = {}
}

-- Events for reference changes
local refChangedEvent = Instance.new("BindableEvent")

-- Initialize Player GUI reference
function BaseUI.Init(gui)
    playerGui = gui
    return true
end

-- Get Player GUI
function BaseUI.GetPlayerGui()
    return playerGui
end

-- UI Reference Management System

-- Add a UI reference to the repository
-- @param category: string - The category to add to (core, modals, screens, components)
-- @param path: string - The path to the element (dot notation, e.g. "inventory.itemGrid")
-- @param ref: any - The reference to store
-- @return: boolean - Success or failure
function BaseUI.AddRef(category, path, ref)
    if not uiRefs[category] then
        uiRefs[category] = {}
    end
    
    local pathParts = string.split(path, ".")
    local current = uiRefs[category]
    
    -- Navigate to the nest level
    for i = 1, #pathParts - 1 do
        local part = pathParts[i]
        if not current[part] then
            current[part] = {}
        end
        current = current[part]
    end
    
    -- Set the final reference
    local lastPart = pathParts[#pathParts]
    current[lastPart] = ref
    
    -- Fire changed event
    refChangedEvent:Fire(category, path, ref)
    
    return true
end

-- Get a UI reference from the repository
-- @param category: string - The category to get from
-- @param path: string - The path to the element (dot notation)
-- @return: any - The reference, or nil if not found
function BaseUI.GetRef(category, path)
    if not uiRefs[category] then
        return nil
    end
    
    local pathParts = string.split(path, ".")
    local current = uiRefs[category]
    
    -- Navigate to the desired reference
    for i = 1, #pathParts do
        local part = pathParts[i]
        if not current[part] then
            return nil
        end
        current = current[part]
    end
    
    return current
end

-- Update an existing UI reference
-- @param category: string - The category to update
-- @param path: string - The path to the element (dot notation)
-- @param ref: any - The new reference
-- @return: boolean - Success or failure
function BaseUI.UpdateRef(category, path, ref)
    -- Same implementation as AddRef, but we ensure the path exists first
    local exists = BaseUI.GetRef(category, path) ~= nil
    if exists or BaseUI.AddRef(category, path, ref) then
        -- Fire changed event
        refChangedEvent:Fire(category, path, ref)
        return true
    end
    return false
end

-- Remove a UI reference
-- @param category: string - The category to remove from
-- @param path: string - The path to the element (dot notation)
-- @return: boolean - Success or failure
function BaseUI.RemoveRef(category, path)
    if not uiRefs[category] then
        return false
    end
    
    local pathParts = string.split(path, ".")
    local current = uiRefs[category]
    local parent = nil
    
    -- Navigate to the parent of the reference to remove
    for i = 1, #pathParts - 1 do
        local part = pathParts[i]
        if not current[part] then
            return false
        end
        parent = current
        current = current[part]
    end
    
    -- Remove the reference
    local lastPart = pathParts[#pathParts]
    if parent then
        parent[lastPart] = nil
    else
        uiRefs[category][lastPart] = nil
    end
    
    -- Fire changed event
    refChangedEvent:Fire(category, path, nil)
    
    return true
end

-- Get all references in a category or path
-- @param category: string - The category to get from
-- @param basePath: string? - Optional base path to get references from
-- @return: table - All references in the given category/path
function BaseUI.GetRefs(category, basePath)
    if not uiRefs[category] then
        return {}
    end
    
    if not basePath then
        return uiRefs[category]
    end
    
    local pathRef = BaseUI.GetRef(category, basePath)
    if type(pathRef) == "table" then
        return pathRef
    end
    
    return {}
end

-- Set up a listener for UI reference changes
-- @param callback: function - Function to call when references change
-- @return: function - Disconnect function
function BaseUI.ListenForRefChanges(callback)
    local connection = refChangedEvent.Event:Connect(callback)
    return function()
        connection:Disconnect()
    end
end

-- Backward compatibility for old code
function BaseUI.GetUIRefs()
    return uiRefs
end

-- Set UI references (legacy support)
function BaseUI.SetUIRefs(refs)
    warn("BaseUI.SetUIRefs is deprecated. Use BaseUI.AddRef or BaseUI.UpdateRef instead.")
    -- Add refs to the core category for backward compatibility
    for key, value in pairs(refs) do
        BaseUI.AddRef("core", key, value)
    end
end

-- Create styled button
function BaseUI.CreateStyledButton(name, text, size, parent)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = size or UDim2.new(0, 200, 0, 40)
    button.BackgroundColor3 = COLORS.PRIMARY
    button.BorderSizePixel = 0
    button.Text = text or name
    button.TextColor3 = COLORS.TEXT
    button.Font = Enum.Font.GothamMedium
    button.TextSize = 14
    button.AutoButtonColor = true
    
    -- Add corner and padding
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button
    
    -- Create hover and click effects
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TWEEN_INFO, {BackgroundColor3 = COLORS.PRIMARY:Lerp(Color3.new(1, 1, 1), 0.2)}):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TWEEN_INFO, {BackgroundColor3 = COLORS.PRIMARY}):Play()
    end)
    
    if parent then
        button.Parent = parent
    end
    
    return button
end

-- Create a frame with specified properties
function BaseUI.CreateFrame(name, size, position, bgColor, parent)
    local frame = Instance.new("Frame")
    frame.Name = name
    frame.Size = size or UDim2.new(0, 200, 0, 200)
    frame.Position = position or UDim2.new(0.5, 0, 0.5, 0)
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.BackgroundColor3 = bgColor or COLORS.BACKGROUND
    frame.BorderSizePixel = 0
    
    -- Add corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    if parent then
        frame.Parent = parent
    end
    
    return frame
end

-- Create text label
function BaseUI.CreateLabel(name, text, size, position, textColor, fontSize, parent)
    local label = Instance.new("TextLabel")
    label.Name = name
    label.Size = size or UDim2.new(1, 0, 0, 20)
    label.Position = position or UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text or ""
    label.TextColor3 = textColor or COLORS.TEXT
    label.Font = Enum.Font.Gotham
    label.TextSize = fontSize or 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    if parent then
        label.Parent = parent
    end
    
    return label
end

-- Apply shadow to UI element
function BaseUI.ApplyShadow(element, shadowSize)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.BackgroundTransparency = 1
    shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    shadow.Size = UDim2.new(1, shadowSize or 30, 1, shadowSize or 30)
    shadow.ZIndex = element.ZIndex - 1
    shadow.Image = "rbxassetid://1316045217"
    shadow.ImageColor3 = Color3.new(0, 0, 0)
    shadow.ImageTransparency = 0.7
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.Parent = element
    
    return shadow
end

-- Get colors table
function BaseUI.GetColors()
    return COLORS
end

return BaseUI 