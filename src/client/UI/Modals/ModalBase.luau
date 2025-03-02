--[[
    ModalBase.luau
    Base functionality for all modal windows
]]

local ModalBase = {}

-- Services
local TweenService = game:GetService("TweenService")

-- Modules
local BaseUI = require(script.Parent.Parent.BaseUI)

-- Local variables
local COLORS = BaseUI.GetColors()
local TWEEN_INFO = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- Active modals tracking
local activeModals = {}

-- Create base modal window
function ModalBase.CreateBaseModal(title, size, parent)
    print("ModalBase.CreateBaseModal called for: " .. title)
    
    -- Get PlayerGui for parent
    local playerGui = parent
    if not playerGui then
        local Players = game:GetService("Players")
        local player = Players.LocalPlayer
        playerGui = player and player:FindFirstChild("PlayerGui")
        if not playerGui then
            print("ERROR: No PlayerGui found for modal parent")
            return nil
        end
    end
    
    -- Create a separate ScreenGui for this modal (Roblox recommended approach)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = title .. "ModalGui"
    screenGui.ResetOnSpawn = false
    screenGui.DisplayOrder = 100  -- Very high to ensure it's above other UIs
    screenGui.IgnoreGuiInset = true  -- Ignore the top inset for mobile/tablet devices
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling  -- Proper Z-index behavior
    screenGui.Enabled = true  -- Explicitly enable
    screenGui.Parent = playerGui
    print("Created ScreenGui with DisplayOrder " .. screenGui.DisplayOrder)
    
    -- Create overlay
    local overlay = Instance.new("Frame")
    overlay.Name = title .. "Overlay"
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.Position = UDim2.new(0, 0, 0, 0)
    overlay.BackgroundColor3 = Color3.new(0, 0, 0)
    overlay.BackgroundTransparency = 0.5 -- Semi-transparent overlay
    overlay.BorderSizePixel = 0
    overlay.ZIndex = 1
    overlay.Visible = true  -- Explicitly set visible
    overlay.Parent = screenGui
    print("Overlay parented to ScreenGui")
    
    -- Create modal container
    local modal = Instance.new("Frame")
    modal.Name = title .. "Modal"
    modal.Size = size or UDim2.new(0, 600, 0, 400)
    modal.Position = UDim2.new(0.5, 0, 0.5, 0)
    modal.AnchorPoint = Vector2.new(0.5, 0.5)
    modal.BackgroundColor3 = COLORS.BACKGROUND
    modal.BorderSizePixel = 0
    modal.ZIndex = 2
    modal.BackgroundTransparency = 0.2
    modal.Visible = true  -- Explicitly set visible
    modal.Parent = overlay
    print("Modal parented to overlay")
    
    -- Debug modal position
    print("Modal Position: " .. tostring(modal.Position))
    print("Modal AnchorPoint: " .. tostring(modal.AnchorPoint))
    print("Modal Size: " .. tostring(modal.Size))
    
    -- Add rounded corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = modal
    
    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = COLORS.PRIMARY
    titleBar.BorderSizePixel = 0
    titleBar.ZIndex = 3
    titleBar.Parent = modal
    
    -- Title bar corners
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = titleBar
    
    -- Fix bottom corners of title bar
    local bottomEdge = Instance.new("Frame")
    bottomEdge.Name = "BottomEdge"
    bottomEdge.Size = UDim2.new(1, 0, 0, 10)
    bottomEdge.Position = UDim2.new(0, 0, 1, -8)
    bottomEdge.BackgroundColor3 = COLORS.PRIMARY
    bottomEdge.BorderSizePixel = 0
    bottomEdge.ZIndex = 3
    bottomEdge.Parent = titleBar
    
    -- Title text
    local titleText = Instance.new("TextLabel")
    titleText.Name = "Title"
    titleText.Size = UDim2.new(1, -100, 1, 0)
    titleText.Position = UDim2.new(0, 15, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = title
    titleText.TextColor3 = COLORS.TEXT
    titleText.Font = Enum.Font.GothamBold
    titleText.TextSize = 18
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.ZIndex = 4
    titleText.Parent = titleBar
    
    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -40, 0, 5)
    closeButton.BackgroundColor3 = COLORS.ERROR
    closeButton.BorderSizePixel = 0
    closeButton.Text = "✕"
    closeButton.TextColor3 = COLORS.TEXT
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 18
    closeButton.ZIndex = 4
    closeButton.Parent = titleBar
    
    -- Close button corners
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = closeButton
    
    -- Content container
    local content = Instance.new("ScrollingFrame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -20, 1, -50)
    content.Position = UDim2.new(0, 10, 0, 45)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.ZIndex = 5
    content.ScrollBarThickness = 6
    content.ScrollBarImageColor3 = COLORS.PRIMARY
    content.CanvasSize = UDim2.new(0, 0, 0, 0) -- This will be adjusted based on content
    
    -- Add padding to content
    local contentPadding = Instance.new("UIPadding")
    contentPadding.PaddingTop = UDim.new(0, 10)
    contentPadding.PaddingBottom = UDim.new(0, 10)
    contentPadding.PaddingLeft = UDim.new(0, 10)
    contentPadding.PaddingRight = UDim.new(0, 10)
    contentPadding.Parent = content
    
    -- Layout for content
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Padding = UDim.new(0, 10)
    contentLayout.Parent = content
    
    content.Parent = modal
    
    -- Apply shadow to modal
    BaseUI.ApplyShadow(modal, 40)
    
    -- Run animations for modal appearance
    print("Starting modal animations")
    -- Force a yield to ensure the previous operations complete
    task.wait()
    
    TweenService:Create(overlay, TWEEN_INFO, {BackgroundTransparency = 0.5}):Play()
    
    TweenService:Create(modal, TWEEN_INFO, {
        Size = size or UDim2.new(0, 600, 0, 400),
        BackgroundTransparency = 0
    }):Play()
    
    print("Modal animations started")
    
    -- Close a modal with proper cleanup
    closeButton.MouseButton1Click:Connect(function()
        print("Close button clicked")
        screenGui:Destroy()  -- Destroy the entire ScreenGui
        activeModals[screenGui] = nil
    end)
    
    -- Close on overlay click if enabled
    overlay.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            print("Overlay clicked")
            screenGui:Destroy()  -- Destroy the entire ScreenGui
            activeModals[screenGui] = nil
        end
    end)
    
    -- Auto-adjust content canvas size based on content
    contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        content.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 20)
    end)
    
    -- Track active modal
    activeModals[screenGui] = true
    
    return {
        screenGui = screenGui,
        overlay = overlay,
        modal = modal,
        content = content,
        titleBar = titleBar,
        titleText = titleText
    }
end

-- Close a modal
function ModalBase.CloseModal(modal)
    local screenGui = nil
    
    -- Find the ScreenGui parent
    if modal and modal.Parent then
        if modal.Parent.ClassName == "ScreenGui" then
            screenGui = modal.Parent
        elseif modal.Parent.Parent and modal.Parent.Parent.ClassName == "ScreenGui" then
            screenGui = modal.Parent.Parent
        end
    end
    
    if screenGui then
        print("Closing modal by destroying ScreenGui")
        activeModals[screenGui] = nil
        screenGui:Destroy()
    end
end

-- Close all active modals
function ModalBase.CloseAllModals()
    for modal, _ in pairs(activeModals) do
        ModalBase.CloseModal(modal)
    end
end

-- Check if any modals are active
function ModalBase.AnyModalsActive()
    for _, _ in pairs(activeModals) do
        return true
    end
    return false
end

return ModalBase 