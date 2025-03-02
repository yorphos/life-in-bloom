--[[
    DataService.lua
    Handles data persistence using DataStoreService
]]

local DataService = {}

-- Services
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local Constants = require(game:GetService("ReplicatedStorage").Shared.Configurations.Constants)

-- Cache for player data
local playerDataCache = {}
local dirtyData = {} -- Track which players have unsaved changes
local saving = {} -- Track which players are currently saving

-- Get the main data store
local function GetDataStore()
    local success, result = pcall(function()
        return DataStoreService:GetDataStore(Constants.DATA_STORE.STORE_NAME)
    end)
    
    if not success then
        warn("Failed to get DataStore: " .. tostring(result))
        return nil
    end
    
    return result
end

-- Get the backup data store
local function GetBackupStore()
    local success, result = pcall(function()
        return DataStoreService:GetDataStore(Constants.DATA_STORE.BACKUP_STORE_NAME)
    end)
    
    if not success then
        warn("Failed to get Backup DataStore: " .. tostring(result))
        return nil
    end
    
    return result
end

-- Initialize default data structure
function DataService.GetDefaultData()
    local PlayerStats = Constants.PLAYER_STATS
    
    return {
        Profile = {
            JoinDate = os.time(),
            LastLogin = os.time(),
            PlayTime = 0,
            Settings = {},
            SchemaVersion = "1.0"
        },
        Stats = {
            Currency = PlayerStats.DEFAULT_STARTING_CURRENCY,
            PremiumCurrency = PlayerStats.DEFAULT_STARTING_PREMIUM_CURRENCY,
            Energy = PlayerStats.DEFAULT_ENERGY,
            MaxEnergy = PlayerStats.DEFAULT_MAX_ENERGY,
            EnergyRegenRate = PlayerStats.DEFAULT_ENERGY_REGEN_RATE,
            Happiness = PlayerStats.DEFAULT_HAPPINESS,
            Hygiene = PlayerStats.DEFAULT_HYGIENE,
            Hunger = PlayerStats.DEFAULT_HUNGER
        },
        Economy = {
            Transactions = {}
        },
        Inventory = {
            Furniture = {},
            Clothing = {},
            Collectibles = {},
            Consumables = {}
        },
        Housing = {
            OwnedPlots = {},
            Houses = {}
        },
        Careers = {},
        Vehicles = {
            OwnedVehicles = {},
            Customizations = {}
        },
        Achievements = {
            Completed = {},
            Progress = {}
        },
        Social = {
            Friends = {},
            BlockedUsers = {},
            RecentInteractions = {}
        }
    }
end

-- Migrate data to newer schema version if needed
local function MigrateData(data)
    if not data or not data.Profile or not data.Profile.SchemaVersion then
        -- If data is corrupt or missing version, return a fresh default
        return DataService.GetDefaultData()
    end
    
    local currentVersion = data.Profile.SchemaVersion
    
    -- Handle migrations based on version
    if currentVersion == "0.9" then
        -- Example migration from v0.9 to v1.0
        data.Profile.SchemaVersion = "1.0"
        
        -- Add new structures
        if not data.Stats then
            data.Stats = {
                Currency = data.Economy and data.Economy.Currency or Constants.PLAYER_STATS.DEFAULT_STARTING_CURRENCY,
                PremiumCurrency = data.Economy and data.Economy.PremiumCurrency or Constants.PLAYER_STATS.DEFAULT_STARTING_PREMIUM_CURRENCY,
                Energy = Constants.PLAYER_STATS.DEFAULT_ENERGY,
                MaxEnergy = Constants.PLAYER_STATS.DEFAULT_MAX_ENERGY,
                EnergyRegenRate = Constants.PLAYER_STATS.DEFAULT_ENERGY_REGEN_RATE,
                Happiness = Constants.PLAYER_STATS.DEFAULT_HAPPINESS,
                Hygiene = Constants.PLAYER_STATS.DEFAULT_HYGIENE,
                Hunger = Constants.PLAYER_STATS.DEFAULT_HUNGER
            }
        end
        
        -- Move old data if needed
        if data.Economy and data.Economy.Currency then
            data.Economy.Currency = nil
        end
        
        if data.Economy and data.Economy.PremiumCurrency then
            data.Economy.PremiumCurrency = nil
        end
    end
    
    -- Add more version migrations here
    
    return data
end

-- Load player data
function DataService.LoadPlayerData(player)
    local userId = player.UserId
    local key = "Player_" .. userId
    
    -- Check if data is already cached
    if playerDataCache[userId] then
        return playerDataCache[userId]
    end
    
    local dataStore = GetDataStore()
    if not dataStore then
        -- If DataStore is unavailable, use default data
        playerDataCache[userId] = DataService.GetDefaultData()
        return playerDataCache[userId]
    end
    
    -- Attempt to load data
    local data
    local success, result = pcall(function()
        return dataStore:GetAsync(key)
    end)
    
    if success and result then
        data = result
    else
        warn("Failed to load data for " .. player.Name .. ": " .. tostring(result))
        
        -- Try to load from backup
        local backupStore = GetBackupStore()
        if backupStore then
            success, result = pcall(function()
                return backupStore:GetAsync(key)
            end)
            
            if success and result then
                data = result
                print("Loaded backup data for " .. player.Name)
            end
        end
    end
    
    -- If no data found or error, use default
    if not data then
        data = DataService.GetDefaultData()
    else
        -- Update login time and playtime tracking
        data.Profile.LastLogin = os.time()
    end
    
    -- Migrate data if needed
    data = MigrateData(data)
    
    -- Cache the data
    playerDataCache[userId] = data
    
    return data
end

-- Save player data
function DataService.SavePlayerData(userId, immediate)
    if saving[userId] then
        return false, "Already saving"
    end
    
    -- Mark as saving to prevent concurrent saves
    saving[userId] = true
    
    local key = "Player_" .. userId
    local data = playerDataCache[userId]
    
    if not data then
        saving[userId] = nil
        return false, "No data to save"
    end
    
    -- Update playtime
    if data.Profile.LastLogin then
        local sessionTime = os.time() - data.Profile.LastLogin
        data.Profile.PlayTime = (data.Profile.PlayTime or 0) + sessionTime
        data.Profile.LastLogin = os.time()
    end
    
    local dataStore = GetDataStore()
    if not dataStore then
        saving[userId] = nil
        return false, "DataStore unavailable"
    end
    
    -- Attempt to save data
    local success, result = pcall(function()
        return dataStore:SetAsync(key, data)
    end)
    
    -- Also save to backup store if immediate save was requested
    if immediate and success then
        local backupStore = GetBackupStore()
        if backupStore then
            pcall(function()
                backupStore:SetAsync(key, data)
            end)
        end
    end
    
    -- Clear dirty flag if save was successful
    if success then
        dirtyData[userId] = nil
    else
        warn("Failed to save data for " .. userId .. ": " .. tostring(result))
    end
    
    saving[userId] = nil
    return success, result
end

-- Mark player data as dirty (needs saving)
function DataService.MarkDataDirty(userId)
    dirtyData[userId] = true
end

-- Get player data from cache
function DataService.GetPlayerData(userIdOrPlayer)
    local userId
    
    -- Handle both player objects and userIds
    if typeof(userIdOrPlayer) == "Instance" and userIdOrPlayer:IsA("Player") then
        userId = userIdOrPlayer.UserId
    else
        userId = userIdOrPlayer
    end
    
    -- Check if data is already cached
    if playerDataCache[userId] then
        return playerDataCache[userId]
    end
    
    -- If not cached for a player, try to load it
    if typeof(userIdOrPlayer) == "Instance" and userIdOrPlayer:IsA("Player") then
        -- Load the data
        return DataService.LoadPlayerData(userIdOrPlayer)
    end
    
    -- If we just have a userId and no cached data, return default
    return DataService.GetDefaultData()
end

-- Auto-save system
local function StartAutoSave()
    while true do
        -- Save all dirty data
        for userId in pairs(dirtyData) do
            if playerDataCache[userId] and not saving[userId] then
                -- Check if player is still in game
                local stillInGame = false
                for _, player in ipairs(Players:GetPlayers()) do
                    if player.UserId == userId then
                        stillInGame = true
                        break
                    end
                end
                
                -- Only save if player is still in game
                if stillInGame then
                    DataService.SavePlayerData(userId, false)
                else
                    -- Player left but data wasn't saved
                    dirtyData[userId] = nil
                    playerDataCache[userId] = nil
                end
            end
        end
        
        task.wait(Constants.DATA_STORE.AUTO_SAVE_INTERVAL)
    end
end

-- Handle player leaving
function DataService.OnPlayerLeaving(player)
    local userId = player.UserId
    
    -- Save data immediately when player leaves
    if playerDataCache[userId] then
        DataService.SavePlayerData(userId, true)
    end
    
    -- Clear from cache after saving
    task.delay(5, function() -- Small delay to ensure save completes
        playerDataCache[userId] = nil
        dirtyData[userId] = nil
    end)
end

-- Request budget management
function DataService.GetDataStoreBudget()
    return DataStoreService:GetRequestBudgetForRequestType(Enum.DataStoreRequestType.SetIncrementAsync)
end

-- Set up remote events
function DataService.SetupRemoteEvents()
    print("Setting up DataService remote events...")
    local RemoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
    
    if not RemoteEvents then
        warn("RemoteEvents folder not found in ReplicatedStorage. It should be created in server init.")
        return
    end
    
    -- Create all needed remote events if they don't exist
    local remoteEventsList = {
        "InitialDataReceived",
        "StatChanged",
        "InventoryChanged",
        "CareerProgressUpdated",
        "NewUnlock"
    }
    
    for _, eventName in ipairs(remoteEventsList) do
        if not RemoteEvents:FindFirstChild(eventName) then
            local newEvent = Instance.new("RemoteEvent")
            newEvent.Name = eventName
            newEvent.Parent = RemoteEvents
            print("Created RemoteEvent: " .. eventName)
        end
    end
    
    print("DataService remote events setup complete")
end

-- Initialize the service
function DataService.Initialize()
    -- Set up remote events
    DataService.SetupRemoteEvents()
    
    -- Connect player leaving event
    Players.PlayerRemoving:Connect(function(player)
        DataService.OnPlayerLeaving(player)
    end)
    
    -- Handle player joining to send initial data
    Players.PlayerAdded:Connect(function(player)
        
        -- Wait for player to fully load
        player.CharacterAdded:Wait()
        task.wait(1)
        
        -- Send initial data to the client
        local playerData = DataService.GetPlayerData(player)
        local RemoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
        
        if RemoteEvents and RemoteEvents:FindFirstChild("InitialDataReceived") then
            RemoteEvents.InitialDataReceived:FireClient(player, playerData)
            print("Sent initial data to " .. player.Name)
        else
            warn("Could not send initial data to client - RemoteEvent not found")
        end
    end)
    
    -- Start auto-save system
    task.spawn(StartAutoSave)
    
    -- Handle game closure
    game:BindToClose(function()
        -- Save all player data
        for _, player in ipairs(Players:GetPlayers()) do
            DataService.OnPlayerLeaving(player)
        end
        
        -- Wait for all saves to complete (up to 10 seconds)
        local startTime = os.time()
        while os.time() - startTime < 10 do
            local stillSaving = false
            for _, isSaving in pairs(saving) do
                if isSaving then
                    stillSaving = true
                    break
                end
            end
            
            if not stillSaving then
                break
            end
            
            task.wait(0.5)
        end
    end)
    
    print("DataService initialized")
end

return DataService 