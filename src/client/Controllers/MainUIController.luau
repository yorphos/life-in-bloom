--[[
    MainUIController.luau
    Main UI controller for the game
]]

local MainUIController = {}

-- Services
local Players = game:GetService("Players")

-- Modules
local PlayerDataController = require(script.Parent.PlayerDataController)

-- UI Modules
local MainScreen = require(script.Parent.Parent.UI.Screens.MainScreen)
local CareerModal = require(script.Parent.Parent.UI.Modals.CareerModal)
local HousingModal = require(script.Parent.Parent.UI.Modals.HousingModal)
local SettingsModal = require(script.Parent.Parent.UI.Modals.SettingsModal)
local ModalBase = require(script.Parent.Parent.UI.Modals.ModalBase)

-- Initialize the Main UI
function MainUIController.Initialize()
    local player = Players.LocalPlayer
    
    if not player then
        warn("MainUIController: Player not found")
        return false
    end
    
    print("MainUIController: Initializing UI...")
    
    -- Wait for player to be fully loaded before initializing UI
    if not player.Character then
        player.CharacterAdded:Wait()
    end
    
    -- Create UI components
    MainScreen.CreateMainUI()
    
    -- Connect stat listeners for UI updates
    MainScreen.ConnectStatListeners()
    
    -- Listen for player data initialization
    PlayerDataController.OnInitialized.Event:Connect(function()
        print("MainUIController: Player data initialized, updating UI")
        
        -- Check if this is a new player
        local isNewPlayer = PlayerDataController.GetDataByPath("Stats", "IsNewPlayer")
        
        if isNewPlayer then
            -- Show welcome message for new players
            MainScreen.ShowNotification(
                "Welcome to Life Simulator!",
                "Get started by exploring jobs and housing options.",
                "success",
                10
            )
            
            -- Mark player as no longer new
            -- This would typically be saved server-side via a RemoteEvent
            -- local markPlayerEvent = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("MarkPlayerStat")
            -- markPlayerEvent:FireServer("IsNewPlayer", false)
        end
    end)
    
    -- Connect inventory updates
    PlayerDataController.ListenForData("Inventory", function(inventoryData)
        if not inventoryData then return end
        MainScreen.UpdateInventoryIndicator(inventoryData)
    end)
    
    -- Connect housing updates
    PlayerDataController.ListenForData("Housing", function(housingData)
        -- Housing data is handled directly by HousingModal when it's open
    end)
    
    -- Connect career updates
    PlayerDataController.ListenForData("Career", function(careerData)
        -- Career data is handled directly by CareerModal when it's open
    end)
    
    print("MainUIController: UI initialization complete")
    return true
end

-- Show Career Modal
function MainUIController.ShowCareerModal()
    CareerModal.Show()
end

-- Show Housing Modal
function MainUIController.ShowHousingModal()
    HousingModal.Show()
end

-- Show Settings Modal
function MainUIController.ShowSettingsModal()
    SettingsModal.Show()
end

-- Show notification
function MainUIController.ShowNotification(title, message, type, duration)
    MainScreen.ShowNotification(title, message, type, duration)
end

-- Close all modals
function MainUIController.CloseAllModals()
    ModalBase.CloseAllModals()
end

-- Check if any modal is open
function MainUIController.IsAnyModalOpen()
    return ModalBase.AnyModalsActive()
end

return MainUIController 