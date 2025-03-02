--[[
    PlayerDataController.lua
    Client-side controller for managing player data
]]

local PlayerDataController = {}
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

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
    
    -- Retry logic for finding RemoteEvents folder
    local maxRetries = 5
    local retryDelay = 2 -- seconds
    local RemoteEvents = nil
    
    for attempt = 1, maxRetries do
        print("[CLIENT_INFO] Attempting to find RemoteEvents folder (Attempt " .. attempt .. "/" .. maxRetries .. ")")
        local success, result = pcall(function()
            return ReplicatedStorage:WaitForChild("RemoteEvents", retryDelay)
        end)
        
        if success and result then
            RemoteEvents = result
            print("[CLIENT_INFO] Successfully found RemoteEvents folder")
            break
        end
        
        if attempt == maxRetries then
            warn("[CLIENT_ERROR] Failed to find RemoteEvents folder after " .. maxRetries .. " attempts")
            return false
        end
        
        print("[CLIENT_INFO] RemoteEvents folder not found, retrying in " .. retryDelay .. " seconds...")
        task.wait(retryDelay)
    end
    
    if not RemoteEvents then
        warn("[CLIENT_ERROR] RemoteEvents folder not found, initialization failed")
        return false
    end
    
    -- Listen for initial data with retry logic
    local InitialDataEvent = nil
    for attempt = 1, maxRetries do
        print("[CLIENT_INFO] Attempting to find InitialDataReceived event (Attempt " .. attempt .. "/" .. maxRetries .. ")")
        local success, result = pcall(function()
            return RemoteEvents:WaitForChild("InitialDataReceived", retryDelay)
        end)
        
        if success and result then
            InitialDataEvent = result
            print("[CLIENT_INFO] Successfully found InitialDataReceived event")
            break
        end
        
        if attempt == maxRetries then
            warn("[CLIENT_ERROR] Failed to find InitialDataReceived event after " .. maxRetries .. " attempts")
            -- Continue with other events even if this one fails
        else
            print("[CLIENT_INFO] InitialDataReceived event not found, retrying in " .. retryDelay .. " seconds...")
            task.wait(retryDelay)
        end
    end
    
    if InitialDataEvent then
        print("[CLIENT_INFO] Connected to InitialDataReceived event")
        InitialDataEvent.OnClientEvent:Connect(ProcessInitialData)
    else
        warn("[CLIENT_ERROR] InitialDataReceived event not found, some functionality may be limited")
    end
    
    -- Listen for stat changes with similar retry logic
    local StatChangedEvent = nil
    for attempt = 1, maxRetries do
        local success, result = pcall(function()
            return RemoteEvents:WaitForChild("StatChanged", retryDelay)
        end)
        
        if success and result then
            StatChangedEvent = result
            break
        end
        
        if attempt == maxRetries then
            warn("[CLIENT_ERROR] Failed to find StatChanged event after " .. maxRetries .. " attempts")
            break
        end
        
        task.wait(retryDelay)
    end
    
    if StatChangedEvent then
        print("[CLIENT_INFO] Connected to StatChanged event")
        StatChangedEvent.OnClientEvent:Connect(function(statName, newValue)
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
    
    -- Listen for inventory changes with retry logic
    local InventoryChangedEvent = nil
    for attempt = 1, maxRetries do
        local success, result = pcall(function()
            return RemoteEvents:WaitForChild("InventoryChanged", retryDelay)
        end)
        
        if success and result then
            InventoryChangedEvent = result
            break
        end
        
        if attempt == maxRetries then
            warn("[CLIENT_ERROR] Failed to find InventoryChanged event after " .. maxRetries .. " attempts")
            break
        end
        
        task.wait(retryDelay)
    end
    
    if InventoryChangedEvent then
        print("[CLIENT_INFO] Connected to InventoryChanged event")
        InventoryChangedEvent.OnClientEvent:Connect(function(category, items)
            if not cachedPlayerData.Inventory then
                cachedPlayerData.Inventory = {
                    Clothing = {},
                    Collectibles = {},
                    Consumables = {},
                    Furniture = {}
                }
            end
            
            cachedPlayerData.Inventory[category] = items
            
            -- Notify category-specific inventory listeners
            if dataListeners["Inventory_" .. category] then
                for _, callback in ipairs(dataListeners["Inventory_" .. category]) do
                    task.spawn(function()
                        local success, err = pcall(callback, items)
                        if not success then
                            warn("[CLIENT_ERROR] Error in inventory listener for " .. category .. ": " .. tostring(err))
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
    local CareerProgressEvent = RemoteEvents:WaitForChild("CareerProgressUpdated", 5)
    if CareerProgressEvent then
        print("[CLIENT_INFO] Connected to CareerProgressUpdated event")
        CareerProgressEvent.OnClientEvent:Connect(function(jobType, level, xp, nextLevelXP)
            if not cachedPlayerData.Careers then
                cachedPlayerData.Careers = {}
            end
            
            if not cachedPlayerData.Careers[jobType] then
                cachedPlayerData.Careers[jobType] = {
                    Level = 0,
                    XP = 0,
                    Stats = {
                        CompletedJobs = 0,
                        TimeSpent = 0,
                        TotalEarnings = 0
                    },
                    Unlocks = {}
                }
            end
            
            cachedPlayerData.Careers[jobType].Level = level
            cachedPlayerData.Careers[jobType].XP = xp
            -- Store nextLevelXP in a temporary variable for UI purposes
            -- since it's not part of the CareerData type
            PlayerDataController.SetTemporaryData("NextLevelXP_" .. jobType, nextLevelXP)
            
            -- Notify listeners for this specific career
            if dataListeners["Career_" .. jobType] then
                for _, callback in ipairs(dataListeners["Career_" .. jobType]) do
                    task.spawn(function()
                        local success, err = pcall(callback, cachedPlayerData.Careers[jobType])
                        if not success then
                            warn("[CLIENT_ERROR] Error in career listener for " .. jobType .. ": " .. tostring(err))
                        end
                    end)
                end
            end
            
            -- Notify general career listeners
            if dataListeners["Careers"] then
                for _, callback in ipairs(dataListeners["Careers"]) do
                    task.spawn(function()
                        local success, err = pcall(callback, cachedPlayerData.Careers)
                        if not success then
                            warn("[CLIENT_ERROR] Error in careers listener: " .. tostring(err))
                        end
                    end)
                end
            end
        end)
    else
        warn("[CLIENT_WARNING] CareerProgressUpdated event not found (non-critical)")
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

return PlayerDataController 