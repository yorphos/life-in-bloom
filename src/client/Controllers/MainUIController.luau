--[[
    MainUIController.luau
    Main UI controller for the game
]]

local MainUIController = {}

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Remote Events - directly exposed at the top level
MainUIController.NotifyPlayer = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("NotifyPlayer") 
MainUIController.NewUnlock = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("NewUnlock")

-- Modules
local PlayerDataController = require(script.Parent.PlayerDataController)

-- UI Modules - use lazy loading for MainScreen to avoid cyclic dependencies
local MainScreen
local CareerModal = require(script.Parent.Parent.UI.Modals.CareerModal)
local HousingModal = require(script.Parent.Parent.UI.Modals.HousingModal)
local SettingsModal = require(script.Parent.Parent.UI.Modals.SettingsModal)
local InventoryModal = require(script.Parent.Parent.UI.Modals.InventoryModal)
local ModalBase = require(script.Parent.Parent.UI.Modals.ModalBase)

-- Helper function to lazy-load MainScreen
if not MainScreen then
    MainScreen = require(script.Parent.Parent.UI.Screens.MainScreen)
end

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
    
    -- Register modal callbacks
    MainScreen.RegisterModalCallback("Inventory", function()
        return MainUIController.ShowInventoryModal()
    end)
    
    MainScreen.RegisterModalCallback("Career", function()
        return MainUIController.ShowCareerModal()
    end)
    
    MainScreen.RegisterModalCallback("Housing", function()
        return MainUIController.ShowHousingModal()
    end)
    
    MainScreen.RegisterModalCallback("Settings", function()
        return MainUIController.ShowSettingsModal()
    end)
    
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
    
    -- Set up notification handlers
    if MainUIController.NotifyPlayer then
        MainUIController.NotifyPlayer.OnClientEvent:Connect(function(title, message, notifyType, duration)
            MainScreen.ShowNotification(title, message, notifyType, duration)
        end)
    end
    
    if MainUIController.NewUnlock then
        MainUIController.NewUnlock.OnClientEvent:Connect(function(unlockType, unlockId, unlockData)
            -- Handle new unlock notification
            local title = "New Unlock!"
            local message = "You've unlocked a new " .. unlockType
            
            if unlockType == "career" and unlockData and unlockData.name then
                message = "You've unlocked the " .. unlockData.name .. " career!"
            elseif unlockType == "item" and unlockData and unlockData.name then
                message = "You've unlocked the " .. unlockData.name .. " item!"
            elseif unlockType == "furniture" and unlockData and unlockData.name then
                message = "You've unlocked the " .. unlockData.name .. " furniture!"
            elseif unlockType == "vehicle" and unlockData and unlockData.name then
                message = "You've unlocked the " .. unlockData.name .. " vehicle!"
            end
            
            MainScreen.ShowNotification(title, message, "success", 10)
        end)
    end
    
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

-- Show Inventory Modal
function MainUIController.ShowInventoryModal()
    InventoryModal.Show()
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