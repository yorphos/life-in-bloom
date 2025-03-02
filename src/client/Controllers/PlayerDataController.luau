--[[
    PlayerDataController.lua
    Client-side controller for managing player data
]]

local PlayerDataController = {}
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Remote Events - directly exposed at the top level 
PlayerDataController.InitialDataReceived = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("InitialDataReceived")
PlayerDataController.StatChanged = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("StatChanged")
PlayerDataController.InventoryChanged = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("InventoryChanged")
PlayerDataController.JobCompleted = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("JobCompleted")
PlayerDataController.CareerProgressUpdated = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("CareerProgressUpdated")

-- Remote Functions
PlayerDataController.GetPlayerData = ReplicatedStorage:WaitForChild("RemoteFunctions"):WaitForChild("GetPlayerData")

-- Types
local PlayerTypes = require(ReplicatedStorage.Shared.Types.PlayerTypes)
type PlayerData = PlayerTypes.PlayerData

-- Local cache of player data
local cachedPlayerData: PlayerData = {
    Achievements = {
        Completed = {},
        Progress = {}
    },
    Careers = {},
    Economy = {
        Transactions = {}
    },
    Housing = {
        Houses = {},
        OwnedPlots = {}
    },
    Inventory = {
        Clothing = {},
        Collectibles = {},
        Consumables = {},
        Furniture = {}
    },
    Profile = {
        JoinDate = 0,
        LastLogin = 0,
        PlayTime = 0,
        SchemaVersion = 1,
        Settings = {}
    },
    Social = {
        BlockedUsers = {},
        Friends = {},
        RecentInteractions = {}
    },
    Stats = {
        Currency = 0,
        Energy = 0,
        EnergyRegenRate = 0,
        Happiness = 0,
        Hunger = 0,
        Hygiene = 0,
        MaxEnergy = 0,
        PremiumCurrency = 0
    },
    Vehicles = {
        Customizations = {},
        OwnedVehicles = {}
    }
}
local dataListeners = {}
local initialized = false
local temporaryData = {} -- For storing temporary UI state, not persisted

-- Create an initialization event
PlayerDataController.OnInitialized = Instance.new("BindableEvent")
PlayerDataController.CareerChanged = Instance.new("BindableEvent")

-- Variables for career tracking
local currentCareer = nil
local careerListeners = {}

-- Process initial data from server
function ProcessInitialData(data)
    if not data then
        warn("[CLIENT_ERROR] Received empty initial data")
        return false
    end

    -- Notify listeners for each data category
    for category, categoryData in pairs(data) do
        if dataListeners[category] then
            for _, listener in ipairs(dataListeners[category]) do
                task.spawn(function()
                    local success, err = pcall(function()
                        listener(categoryData)
                    end)
                    
                    if not success then
                        warn("[CLIENT_ERROR] Failed to notify listener for " .. category .. ": " .. tostring(err))
                    end
                end)
            end
        end
    end
    
    -- Mark as initialized
    initialized = true
    
    -- Fire the initialization event to notify other systems
    task.spawn(function()
        PlayerDataController.OnInitialized:Fire()
    end)
    
    print("[CLIENT_INFO] Initial player data processed")
    return true
end

-- Initialize listeners for data changes
local function SetupDataListeners()
    print("[CLIENT_INFO] Setting up data listeners...")
    
    -- Connect to events directly from top-level properties
    if PlayerDataController.InitialDataReceived then
        print("[CLIENT_INFO] Connected to InitialDataReceived event")
        PlayerDataController.InitialDataReceived.OnClientEvent:Connect(ProcessInitialData)
    else
        warn("[CLIENT_ERROR] InitialDataReceived event not found, some functionality may be limited")
    end
    
    if PlayerDataController.StatChanged then
        print("[CLIENT_INFO] Connected to StatChanged event")
        PlayerDataController.StatChanged.OnClientEvent:Connect(function(statName, newValue)
            if not cachedPlayerData.Stats then
                cachedPlayerData.Stats = {
                    Currency = 0,
                    Energy = 0,
                    EnergyRegenRate = 0,
                    Happiness = 0,
                    Hunger = 0,
                    Hygiene = 0,
                    MaxEnergy = 0,
                    PremiumCurrency = 0
                }
            end
            
            cachedPlayerData.Stats[statName] = newValue
            
            -- Notify listeners for this specific stat
            if dataListeners["Stat_" .. statName] then
                for _, callback in ipairs(dataListeners["Stat_" .. statName]) do
                    task.spawn(function()
                        local success, err = pcall(callback, newValue)
                        if not success then
                            warn("[CLIENT_ERROR] Error in stat listener for " .. statName .. ": " .. tostring(err))
                        end
                    end)
                end
            end
            
            -- Notify general stat listeners
            if dataListeners["Stats"] then
                for _, callback in ipairs(dataListeners["Stats"]) do
                    task.spawn(function()
                        local success, err = pcall(callback, cachedPlayerData.Stats)
                        if not success then
                            warn("[CLIENT_ERROR] Error in general stats listener: " .. tostring(err))
                        end
                    end)
                end
            end
        end)
    else
        warn("[CLIENT_ERROR] StatChanged event not found, stats updates will not work")
    end
    
    if PlayerDataController.InventoryChanged then
        print("[CLIENT_INFO] Connected to InventoryChanged event")
        PlayerDataController.InventoryChanged.OnClientEvent:Connect(function(inventoryType, itemData)
            if not cachedPlayerData.Inventory then
                cachedPlayerData.Inventory = {
                    Clothing = {},
                    Collectibles = {},
                    Consumables = {},
                    Furniture = {}
                }
            end
            
            cachedPlayerData.Inventory[inventoryType] = itemData
            
            -- Notify category-specific inventory listeners
            if dataListeners["Inventory_" .. inventoryType] then
                for _, callback in ipairs(dataListeners["Inventory_" .. inventoryType]) do
                    task.spawn(function()
                        local success, err = pcall(callback, itemData)
                        if not success then
                            warn("[CLIENT_ERROR] Error in inventory listener for " .. inventoryType .. ": " .. tostring(err))
                        end
                    end)
                end
            end
            
            -- Notify general inventory listeners
            if dataListeners["Inventory"] then
                for _, callback in ipairs(dataListeners["Inventory"]) do
                    task.spawn(function()
                        local success, err = pcall(callback, cachedPlayerData.Inventory)
                        if not success then
                            warn("[CLIENT_ERROR] Error in general inventory listener: " .. tostring(err))
                        end
                    end)
                end
            end
        end)
    else
        warn("[CLIENT_ERROR] InventoryChanged event not found, inventory updates will not work")
    end
    
    -- Listen for career progress updates
    if PlayerDataController.CareerProgressUpdated then
        print("[CLIENT_INFO] Connected to CareerProgressUpdated event")
        PlayerDataController.CareerProgressUpdated.OnClientEvent:Connect(function(careerId, level, experience, nextLevelXP)
            print("[CLIENT_INFO] Career progress updated: " .. careerId .. ", Level: " .. level .. ", XP: " .. experience .. "/" .. nextLevelXP)
            
            -- Update current career if it matches
            if currentCareer and currentCareer.id == careerId then
                currentCareer.level = level
                currentCareer.experience = experience
                currentCareer.nextLevelXP = nextLevelXP
                
                -- Fire change event
                PlayerDataController.CareerChanged:Fire(currentCareer)
            end
            
            -- Notify specific listeners
            if careerListeners[careerId] then
                for _, callback in ipairs(careerListeners[careerId]) do
                    task.spawn(function()
                        local success, err = pcall(function()
                            callback(level, experience, nextLevelXP)
                        end)
                        
                        if not success then
                            warn("[CLIENT_ERROR] Error in career listener: " .. tostring(err))
                        end
                    end)
                end
            end
        end)
    else
        warn("[CLIENT_ERROR] CareerProgressUpdated event not found, career updates will not work")
    end
    
    -- Listen for job completions
    if PlayerDataController.JobCompleted then
        print("[CLIENT_INFO] Connected to JobCompleted event")
        PlayerDataController.JobCompleted.OnClientEvent:Connect(function(jobId, reward, experience)
            print("[CLIENT_INFO] Job completed: " .. jobId .. ", Reward: " .. reward .. ", XP: " .. experience)
            
            -- Handle job completion feedback (UI feedback is handled by MainUIController)
            -- Notify listeners through existing data change system
        end)
    else
        warn("[CLIENT_ERROR] JobCompleted event not found, job completion notifications will not work")
    end
    
    return true
end

-- Request data from server
function PlayerDataController.RefreshData(category: string): boolean
    -- Ensure RemoteFunctions exists
    local RemoteFunctions = ReplicatedStorage:WaitForChild("RemoteFunctions", 5)
    if not RemoteFunctions then
        warn("[CLIENT_ERROR] RemoteFunctions folder not found")
        return false
    end
    
    -- Get data remote function
    local GetPlayerDataFunc = RemoteFunctions:WaitForChild("GetPlayerData", 5)
    if not GetPlayerDataFunc then
        warn("[CLIENT_ERROR] GetPlayerData function not found")
        return false
    end
    
    -- Request data
    local success, data = pcall(function()
        return GetPlayerDataFunc:InvokeServer(category)
    end)
    
    if not success or not data then
        warn("[CLIENT_ERROR] Failed to refresh " .. category .. " data: " .. tostring(data))
        return false
    end
    
    -- Update cached data
    if category == "Stats" then
        cachedPlayerData.Stats = data
    elseif category == "Inventory" then
        cachedPlayerData.Inventory = data
    elseif category == "Careers" then
        cachedPlayerData.Careers = data
    elseif category == "Profile" then
        cachedPlayerData.Profile = data
    end
    
    -- Notify listeners
    if dataListeners[category] then
        for _, callback in ipairs(dataListeners[category]) do
            task.spawn(function()
                local success, err = pcall(callback, data)
                if not success then
                    warn("[CLIENT_ERROR] Error in data listener for " .. category .. ": " .. tostring(err))
                end
            end)
        end
    end
    
    return true
end

-- Get all player data
function PlayerDataController.GetData()
    return cachedPlayerData or {}
end

-- Get specific category of data
function PlayerDataController.GetCategoryData(category: string)
    if not cachedPlayerData then
        return {}
    end
    return cachedPlayerData[category] or {}
end

-- Get data from cache (original function, maintained for compatibility)
function PlayerDataController.GetDataByPath(category: string?, key: string?): any
    if not category then
        return cachedPlayerData or {}
    end
    
    if not cachedPlayerData or not cachedPlayerData[category] then
        return nil
    end
    
    if key then
        return cachedPlayerData[category][key]
    else
        return cachedPlayerData[category]
    end
end

-- Listen for data changes
function PlayerDataController.ListenForData(category: string, callback: (any) -> ()): () -> ()
    if not dataListeners[category] then
        dataListeners[category] = {}
    end
    
    table.insert(dataListeners[category], callback)
    
    -- If data is already loaded, call the callback immediately
    if initialized and cachedPlayerData[category] then
        task.spawn(function()
            local success, err = pcall(callback, cachedPlayerData[category])
            if not success then
                warn("[CLIENT_ERROR] Error in initial data listener for " .. category .. ": " .. tostring(err))
            end
        end)
    end
    
    -- Return a function to remove the listener
    return function()
        if dataListeners[category] then
            for i, cb in ipairs(dataListeners[category]) do
                if cb == callback then
                    table.remove(dataListeners[category], i)
                    break
                end
            end
        end
    end
end

-- Listen for a specific stat
function PlayerDataController.ListenForStat(statName: string, callback: (any) -> ()): () -> ()
    return PlayerDataController.ListenForData("Stat_" .. statName, callback)
end

-- Listen for when all data is ready
function PlayerDataController.WhenDataReady(callback: (PlayerData) -> ()): () -> ()
    if initialized then
        -- Data is already ready, call immediately
        task.spawn(function()
            local success, err = pcall(callback, cachedPlayerData)
            if not success then
                warn("[CLIENT_ERROR] Error in data ready listener: " .. tostring(err))
            end
        end)
        
        -- Return a no-op cleanup function
        return function() end
    else
        -- Register for future notification
        return PlayerDataController.ListenForData("__DataReady", callback)
    end
end

-- Use an item
function PlayerDataController.UseItem(category: string, itemId: string, params: {[string]: any}?): (boolean, string)
    -- Ensure RemoteFunctions exists
    local RemoteFunctions = ReplicatedStorage:WaitForChild("RemoteFunctions", 5)
    if not RemoteFunctions then
        return false, "[CLIENT_ERROR] RemoteFunctions folder not found"
    end
    
    -- Get use item function
    local UseItemFunc = RemoteFunctions:WaitForChild("UseItem", 5)
    if not UseItemFunc then
        return false, "[CLIENT_ERROR] UseItem function not found"
    end
    
    -- Call server
    local success, result, message = pcall(function()
        return UseItemFunc:InvokeServer(category, itemId, params)
    end)
    
    if not success then
        return false, "[CLIENT_ERROR] Error using item: " .. tostring(result)
    end
    
    return result, message or "Item used"
end

-- Purchase an item
function PlayerDataController.PurchaseItem(itemId: string, category: string, price: number): (boolean, string)
    -- Ensure RemoteFunctions exists
    local RemoteFunctions = ReplicatedStorage:WaitForChild("RemoteFunctions", 5)
    if not RemoteFunctions then
        return false, "[CLIENT_ERROR] RemoteFunctions folder not found"
    end
    
    -- Get purchase function
    local PurchaseItemFunc = RemoteFunctions:WaitForChild("PurchaseItem", 5)
    if not PurchaseItemFunc then
        return false, "[CLIENT_ERROR] PurchaseItem function not found"
    end
    
    -- Call server
    local success, result, message = pcall(function()
        return PurchaseItemFunc:InvokeServer(itemId, category, price)
    end)
    
    if not success then
        return false, "[CLIENT_ERROR] Error purchasing item: " .. tostring(result)
    end
    
    return result, message or "Item purchased"
end

-- Initialize the controller
function PlayerDataController.Initialize(): boolean
    if initialized then
        warn("[CLIENT_WARNING] PlayerDataController already initialized")
        return true
    end
    
    print("[CLIENT_INFO] PlayerDataController initializing...")
    
    -- Set up data listeners with retry logic
    local success, err = pcall(function()
        return SetupDataListeners()
    end)
    
    if not success then
        warn("[CLIENT_ERROR] Failed to set up data listeners: " .. tostring(err))
        
        -- Retry initialization after a delay
        task.delay(5, function()
            print("[CLIENT_INFO] Retrying PlayerDataController initialization...")
            PlayerDataController.Initialize()
        end)
        
        return false
    end
    
    -- Set up additional event handlers for career progression, etc.
    -- (omitted for brevity in this example)
    
    initialized = true
    print("[CLIENT_INFO] PlayerDataController initialized successfully")
    
    -- Return initialization status
    return true
end

-- Check if controller is initialized
function PlayerDataController.IsInitialized(): boolean
    return initialized
end

-- Store temporary data (not persisted, just for the session)
function PlayerDataController.SetTemporaryData(key: string, value: any): ()
    temporaryData[key] = value
end

-- Get temporary data
function PlayerDataController.GetTemporaryData(key: string): any
    return temporaryData[key]
end

-- Manually trigger data listeners for a category
function PlayerDataController.TriggerDataListeners(category: string, data: any): ()
    if not dataListeners[category] then return end
    
    for _, listener in ipairs(dataListeners[category]) do
        task.spawn(function()
            local success, err = pcall(function()
                listener(data)
            end)
            
            if not success then
                warn("[CLIENT_ERROR] Failed to execute data listener for category '" .. category .. "': " .. tostring(err))
            end
        end)
    end
end

-- Get the player's current active career
function PlayerDataController.GetCurrentCareer()
    if not currentCareer then
        -- Try to load from cached data
        local careerData = PlayerDataController.GetDataByPath("Career.Current")
        if careerData then
            currentCareer = careerData
        end
    end
    
    return currentCareer
end

-- Listen for changes to a specific career
function PlayerDataController.ListenForCareerProgress(careerId, callback)
    if not careerListeners[careerId] then
        careerListeners[careerId] = {}
    end
    
    table.insert(careerListeners[careerId], callback)
    
    -- Return disconnect function
    return function()
        local index = table.find(careerListeners[careerId], callback)
        if index then
            table.remove(careerListeners[careerId], index)
        end
    end
end

-- Request to start a job (stub for future implementation)
function PlayerDataController.StartJob(jobId)
    -- This would typically use a remote function
    print("[CLIENT_INFO] StartJob not yet implemented")
    return false, "Not implemented"
end

-- Select a career for the player
function PlayerDataController.SelectCareer(careerId: string): (boolean, string)
    -- Ensure RemoteFunctions exists
    local RemoteFunctions = ReplicatedStorage:WaitForChild("RemoteFunctions", 5)
    if not RemoteFunctions then
        return false, "[CLIENT_ERROR] RemoteFunctions folder not found"
    end
    
    -- Get select career function
    local SelectCareerFunc = RemoteFunctions:FindFirstChild("SelectCareer")
    if not SelectCareerFunc then
        return false, "[CLIENT_ERROR] SelectCareer function not found"
    end
    
    -- Call server
    local success, result = pcall(function()
        return SelectCareerFunc:InvokeServer(careerId)
    end)
    
    if not success then
        return false, "[CLIENT_ERROR] Error selecting career: " .. tostring(result)
    end
    
    -- Update current career if selection was successful
    if result then
        -- We'll need to refresh career data
        task.spawn(function()
            PlayerDataController.RefreshData("Careers")
        end)
    end
    
    return true, "Career selected successfully"
end

-- Sell an item from the player's inventory
function PlayerDataController.SellItem(category: string, itemId: string): (boolean, string | number)
    -- Ensure RemoteFunctions exists
    local RemoteFunctions = ReplicatedStorage:WaitForChild("RemoteFunctions", 5)
    if not RemoteFunctions then
        return false, "[CLIENT_ERROR] RemoteFunctions folder not found"
    end
    
    -- Get sell item function
    local SellItemFunc = RemoteFunctions:FindFirstChild("SellItem")
    if not SellItemFunc then
        return false, "[CLIENT_ERROR] SellItem function not found"
    end
    
    -- Call server
    local success, result = pcall(function()
        return SellItemFunc:InvokeServer(category, itemId)
    end)
    
    if not success then
        return false, "[CLIENT_ERROR] Error selling item: " .. tostring(result)
    end
    
    return true, result  -- result should be the amount of currency received
end

-- Teleport to a owned house (placeholder implementation)
function PlayerDataController.TeleportToHouse(houseId: string): (boolean, string)
    -- Ensure RemoteEvents exists
    local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents", 5)
    if not RemoteEvents then
        return false, "[CLIENT_ERROR] RemoteEvents folder not found"
    end
    
    -- Get teleport event
    local TeleportEvent = RemoteEvents:FindFirstChild("TeleportToHouse")
    if not TeleportEvent then
        return false, "[CLIENT_ERROR] TeleportToHouse event not found"
    end
    
    -- Fire server event
    TeleportEvent:FireServer(houseId)
    
    -- Since this is a FireServer call, we don't know immediately if it succeeded
    -- We assume success and let the server handle any errors
    return true, "Teleport request sent to server"
end

-- Purchase a house (placeholder implementation)
function PlayerDataController.PurchaseHouse(houseId: string): (boolean, string)
    -- Ensure RemoteEvents exists
    local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents", 5)
    if not RemoteEvents then
        return false, "[CLIENT_ERROR] RemoteEvents folder not found"
    end
    
    -- Get purchase event
    local PurchaseEvent = RemoteEvents:FindFirstChild("PurchaseHouse")
    if not PurchaseEvent then
        return false, "[CLIENT_ERROR] PurchaseHouse event not found"
    end
    
    -- Fire server event
    PurchaseEvent:FireServer(houseId)
    
    -- Since this is a FireServer call, we don't know immediately if it succeeded
    -- We assume success and let the server handle any errors
    return true, "Purchase request sent to server"
end

return PlayerDataController 