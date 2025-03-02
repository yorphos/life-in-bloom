--[[
    PlayerMovementController.luau
    Handles enhanced player movement features such as sprinting
]]

local PlayerMovementController = {}

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

-- Constants
local NORMAL_WALKSPEED = 16
local SPRINT_WALKSPEED = 24
local SPRINT_TOGGLE_KEY = Enum.KeyCode.LeftShift

-- Variables
local player = Players.LocalPlayer
local sprintEnabled = false
local connections = {}

-- Create an event for sprint state changes
local SprintStateChanged = Instance.new("BindableEvent")
PlayerMovementController.SprintStateChanged = SprintStateChanged

-- Update character's walk speed based on sprint state
local function updateWalkSpeed()
    if not player or not player.Character then return end
    
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    humanoid.WalkSpeed = sprintEnabled and SPRINT_WALKSPEED or NORMAL_WALKSPEED
    print("[MOVEMENT] Walk speed updated to: " .. humanoid.WalkSpeed)
end

-- Handler for when a character is added
local function onCharacterAdded(character)
    if not character then return end
    
    task.wait(0.5) -- Wait for character to fully load
    updateWalkSpeed() 
end

-- Toggle sprint state
local function toggleSprint()
    sprintEnabled = not sprintEnabled
    updateWalkSpeed()
    
    -- Fire the sprint state changed event
    SprintStateChanged:Fire(sprintEnabled)
    
    print("[MOVEMENT] Sprint " .. (sprintEnabled and "enabled" or "disabled"))
end

-- Public function to toggle sprint
function PlayerMovementController.ToggleSprint()
    toggleSprint()
end

-- Function to get current sprint state
function PlayerMovementController.IsSprintEnabled()
    return sprintEnabled
end

-- Initialize the controller
function PlayerMovementController.Initialize()
    print("[MOVEMENT] Initializing PlayerMovementController")
    
    -- Set up input connection for sprint toggle
    connections.inputBegan = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        -- Only handle if the game isn't already processing this input (e.g., in a text box)
        if gameProcessed then return end
        
        if input.KeyCode == SPRINT_TOGGLE_KEY then
            toggleSprint()
        end
    end)
    
    -- Connect to CharacterAdded event
    connections.characterAdded = player.CharacterAdded:Connect(onCharacterAdded)
    
    -- Initialize with current character if it exists
    if player.Character then
        onCharacterAdded(player.Character)
    end
    
    -- Fire the event with initial state to sync UI
    SprintStateChanged:Fire(sprintEnabled)
    
    print("[MOVEMENT] PlayerMovementController initialized")
    return true
end

-- For backward compatibility
PlayerMovementController.Init = PlayerMovementController.Initialize

-- Clean up connections
function PlayerMovementController.Cleanup()
    for name, connection in pairs(connections) do
        if connection and typeof(connection) == "RBXScriptConnection" then
            connection:Disconnect()
        end
    end
    
    connections = {}
    print("[MOVEMENT] PlayerMovementController cleaned up")
end

return PlayerMovementController 