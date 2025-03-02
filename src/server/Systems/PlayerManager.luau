--[[
    PlayerManager.lua
    Central class for managing player state and lifecycle
]]

local PlayerManager = {}

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- Required modules
local DataService = require(ServerScriptService.Server.Services.DataService)
local PlayerStatsManager = require(ServerScriptService.Server.Systems.PlayerStatsManager)
local InventoryManager = require(ServerScriptService.Server.Systems.InventoryManager)
local ProgressionManager = require(ServerScriptService.Server.Systems.ProgressionManager)

-- Types
local PlayerTypes = require(ReplicatedStorage.Shared.Types.PlayerTypes)
type PlayerData = PlayerTypes.PlayerData
type SetupResult = {success: boolean, message: string, created: {string}?}

-- Remote events folder setup
local function EnsureRemoteEvents(): Folder
    local RemoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
    if not RemoteEvents then
        print("[PLAYER_INFO] Creating RemoteEvents folder")
        RemoteEvents = Instance.new("Folder")
        RemoteEvents.Name = "RemoteEvents"
        RemoteEvents.Parent = ReplicatedStorage
    end
    return RemoteEvents
end

local function EnsureRemoteFunctions(): Folder
    local RemoteFunctions = ReplicatedStorage:FindFirstChild("RemoteFunctions")
    if not RemoteFunctions then
        print("[PLAYER_INFO] Creating RemoteFunctions folder")
        RemoteFunctions = Instance.new("Folder")
        RemoteFunctions.Name = "RemoteFunctions"
        RemoteFunctions.Parent = ReplicatedStorage
    end
    return RemoteFunctions
end

-- Set up remote events
local function SetupRemoteEvents(): SetupResult
    local result: SetupResult = {
        success = true,
        message = "",
        created = {}
    }
    
    -- Use pcall to handle any errors during remote events setup
    local success, errorOrEvents = pcall(function()
        local RemoteEvents = EnsureRemoteEvents()
        
        -- Create necessary remote events if they don't exist
        local events = {
            "InitialDataReceived",
            "StatChanged",
            "InventoryChanged",
            "CareerProgressUpdated",
            "NewUnlock",
            "NotifyPlayer",
            "JobCompleted",
            "RequestStatUpdate"
        }
        
        local created = {}
        
        for _, eventName in ipairs(events) do
            if not RemoteEvents:FindFirstChild(eventName) then
                local event = Instance.new("RemoteEvent")
                event.Name = eventName
                event.Parent = RemoteEvents
                table.insert(created, eventName)
                print("[PLAYER_INFO] Created RemoteEvent: " .. eventName)
            end
        end
        
        return created
    end)
    
    if not success then
        result.success = false
        result.message = "[PLAYER_ERROR] Failed to set up remote events: " .. tostring(errorOrEvents)
        warn(result.message)
    else
        result.created = errorOrEvents
        if #errorOrEvents > 0 then
            result.message = "[PLAYER_INFO] Created remote events: " .. table.concat(errorOrEvents, ", ")
            print(result.message)
        else
            result.message = "[PLAYER_INFO] All remote events already exist"
        end
    end
    
    return result
end

-- Set up remote functions
local function SetupRemoteFunctions(): SetupResult
    local result: SetupResult = {
        success = true,
        message = "",
        created = {}
    }
    
    -- Use pcall to handle any errors during remote functions setup
    local success, errorOrFuncs = pcall(function()
        local RemoteFunctions = EnsureRemoteFunctions()
        
        -- Create necessary remote functions if they don't exist
        local functions = {
            "GetPlayerData",
            "UseItem",
            "PurchaseItem"
        }
        
        local created = {}
        
        for _, funcName in ipairs(functions) do
            if not RemoteFunctions:FindFirstChild(funcName) then
                local func = Instance.new("RemoteFunction")
                func.Name = funcName
                func.Parent = RemoteFunctions
                table.insert(created, funcName)
                print("[PLAYER_INFO] Created RemoteFunction: " .. funcName)
            end
        end
        
        return created
    end)
    
    if not success then
        result.success = false
        result.message = "[PLAYER_ERROR] Failed to set up remote functions: " .. tostring(errorOrFuncs)
        warn(result.message)
    else
        result.created = errorOrFuncs
        if #errorOrFuncs > 0 then
            result.message = "[PLAYER_INFO] Created remote functions: " .. table.concat(errorOrFuncs, ", ")
            print(result.message)
        else
            result.message = "[PLAYER_INFO] All remote functions already exist"
        end
    end
    
    return result
end

-- Initialize player systems
function PlayerManager.InitializePlayer(player: Player): boolean
    -- Load player data
    local playerData = DataService.LoadPlayerData(player)
    
    -- Check if the response is in the format {success=boolean, data=table, error=string}
    if type(playerData) == "table" and playerData.success ~= nil then
        if not playerData.success or not playerData.data then
            warn("[PLAYER_ERROR] Failed to load data for " .. player.Name .. ": " .. (playerData.error or "unknown error"))
            return false
        end
        playerData = playerData.data
    elseif not playerData then
        warn("[PLAYER_ERROR] Failed to load data for " .. player.Name .. ": unknown error")
        return false
    end
    
    -- Initialize subsystems
    PlayerStatsManager.InitializeStats(player, playerData.Stats)
    InventoryManager.InitializeInventory(player, playerData.Inventory)
    
    -- Initialize career progression
    if ProgressionManager then
        playerData.Careers = ProgressionManager.InitializeProgression(player, playerData.Careers)
    end
    
    -- Send initial data to client
    PlayerManager.SendInitialData(player, playerData)
    
    -- Set up player attributes
    player:SetAttribute("Initialized", true)
    
    -- Set up authentication for remote events
    PlayerManager.SetupRemoteEventHandlers(player)
    
    -- Mark player as loaded
    print("[PLAYER_INFO] " .. player.Name .. " fully initialized")
    return true
end

-- Send initial data to client
function PlayerManager.SendInitialData(player: Player, playerData: PlayerData): boolean
    -- Create a filtered version of player data safe to send to client
    local clientData = {
        Profile = {
            JoinDate = playerData.Profile.JoinDate,
            PlayTime = playerData.Profile.PlayTime,
            Settings = playerData.Profile.Settings
        },
        Stats = playerData.Stats,
        Inventory = playerData.Inventory,
        Housing = {
            OwnedPlots = playerData.Housing.OwnedPlots
        },
        Careers = playerData.Careers,
        Vehicles = {
            OwnedVehicles = playerData.Vehicles.OwnedVehicles
        },
        Achievements = playerData.Achievements
    }
    
    -- Send to client
    local success, err = pcall(function()
        local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents", 5)
        if not RemoteEvents then
            error("[PLAYER_ERROR] RemoteEvents folder not found when trying to send initial data")
            return false
        end
        
        local InitDataEvent = RemoteEvents:WaitForChild("InitialDataReceived", 5)
        if not InitDataEvent then
            error("[PLAYER_ERROR] InitialDataReceived event not found when trying to send initial data")
            return false
        end
        
        InitDataEvent:FireClient(player, clientData)

        return true
    end)
    
    if not success then
        warn("[PLAYER_ERROR] Failed to send initial data to " .. player.Name .. ": " .. tostring(err))
        return false
    end
    
    print("[PLAYER_INFO] Sent initial data to " .. player.Name)
    return true
end

-- Set up handlers for remote events
function PlayerManager.SetupRemoteEventHandlers(player: Player): boolean
    local success, err = pcall(function()
        -- Stats update requests
        local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents", 5)
        if not RemoteEvents then
            error("[PLAYER_ERROR] RemoteEvents folder not found when setting up event handlers")
            return false
        end
        
        local UpdateStatEvent = RemoteEvents:WaitForChild("RequestStatUpdate", 5)
        if not UpdateStatEvent then
            error("[PLAYER_ERROR] RequestStatUpdate event not found when setting up event handlers")
            return false
        end
        
        UpdateStatEvent.OnServerEvent:Connect(function(client, statName, value)
            -- Verify sender
            if client ~= player then return end
            
            -- Only allow updating certain client-authoritative stats
            local allowedStats = {
                "Settings" -- Allow updating settings
            }
            
            if table.find(allowedStats, statName) then
                local playerData = DataService.GetPlayerData(player)
                
                if playerData and playerData.Profile then
                    playerData.Profile[statName] = value
                    DataService.MarkDataDirty(player.UserId)
                end
            end
        end)
        
        -- Set up remote functions
        local RemoteFunctions = ReplicatedStorage:WaitForChild("RemoteFunctions", 5)
        if not RemoteFunctions then
            error("[PLAYER_ERROR] RemoteFunctions folder not found when setting up function handlers")
            return false
        end
        
        -- GetPlayerData remote function
        local GetPlayerDataFunc = RemoteFunctions:WaitForChild("GetPlayerData", 5)
        if not GetPlayerDataFunc then
            error("[PLAYER_ERROR] GetPlayerData function not found when setting up function handlers")
            return false
        end
        
        GetPlayerDataFunc.OnServerInvoke = function(client, dataType)
            -- Verify sender
            if client ~= player then return nil end
            
            -- Return requested data
            local playerData = DataService.GetPlayerData(player)
            
            if not playerData then return nil end
            
            local result
            
            if dataType == "Stats" then
                result = PlayerStatsManager.GetAllStats(player)
            elseif dataType == "Inventory" then
                result = {
                    Furniture = InventoryManager.GetCategoryItems(player, "Furniture"),
                    Clothing = InventoryManager.GetCategoryItems(player, "Clothing"),
                    Collectibles = InventoryManager.GetCategoryItems(player, "Collectibles"),
                    Consumables = InventoryManager.GetCategoryItems(player, "Consumables")
                }
            elseif dataType == "Careers" then
                result = playerData.Careers
            elseif dataType == "Profile" then
                result = {
                    JoinDate = playerData.Profile.JoinDate,
                    PlayTime = playerData.Profile.PlayTime,
                    Settings = playerData.Profile.Settings
                }
            end
            
            return result
        end
        
        -- UseItem remote function
        local UseItemFunc = RemoteFunctions:WaitForChild("UseItem", 5)
        if not UseItemFunc then
            error("[PLAYER_ERROR] UseItem function not found when setting up function handlers")
            return false
        end
        
        UseItemFunc.OnServerInvoke = function(client, category, itemId, useParams)
            -- Verify sender
            if client ~= player then return false, "Authentication failed" end
            
            -- Handle item use logic
            
            -- Check if player has the item
            local hasItem, errorMsg = InventoryManager.HasItem(player, category, itemId)
            if not hasItem then
                return false, errorMsg or "Item not in inventory"
            end
            
            -- This would call ItemUseManager when implemented
            -- For now, just handle basic item use
            local success = true
            local message = "Item used successfully"
            
            -- Perform basic item consumption
            if category == "Consumables" then
                -- Apply some basic effects based on item type
                -- This would be more sophisticated with an ItemsConfig system
                
                if itemId:find("food") then
                    PlayerStatsManager.ModifyStat(player, "Hunger", 20)
                elseif itemId:find("drink") then
                    PlayerStatsManager.ModifyStat(player, "Energy", 15)
                elseif itemId:find("soap") then
                    PlayerStatsManager.ModifyStat(player, "Hygiene", 25)
                end
                
                -- Remove the item
                local removeResult = InventoryManager.RemoveItem(player, category, itemId, 1)
                if not removeResult.success then
                    return false, removeResult.message
                end
            end
            
            return success, message
        end
        
        -- PurchaseItem remote function
        local PurchaseItemFunc = RemoteFunctions:WaitForChild("PurchaseItem", 5)
        if not PurchaseItemFunc then
            error("[PLAYER_ERROR] PurchaseItem function not found when setting up function handlers")
            return false
        end
        
        PurchaseItemFunc.OnServerInvoke = function(client, itemId, category, price)
            -- Verify sender
            if client ~= player then return false, "Authentication failed" end
            
            -- This would use a proper shop/items configuration system
            -- For now, implement basic purchasing
            
            -- Check if player has enough currency
            local currentCurrency = PlayerStatsManager.GetStat(player, "Currency")
            if not currentCurrency or currentCurrency < price then
                return false, "Insufficient funds"
            end
            
            -- Deduct currency
            local modifyResult = PlayerStatsManager.ModifyStat(player, "Currency", -price)
            if not modifyResult.success then
                return false, modifyResult.message
            end
            
            -- Add item to inventory
            local addResult = InventoryManager.AddItem(player, category, itemId, 1)
            if not addResult.success then
                -- Refund currency if item couldn't be added
                PlayerStatsManager.ModifyStat(player, "Currency", price)
                return false, addResult.message
            end
            
            return true, "Item purchased successfully"
        end
        
        return true
    end)
    
    if not success then
        warn("[PLAYER_ERROR] Failed to set up event handlers: " .. tostring(err))
        return false
    end
    
    return true
end

-- Clean up when player leaves
function PlayerManager.CleanupPlayer(player: Player)
    -- Clean up subsystems
    PlayerStatsManager.CleanupPlayer(player)
    InventoryManager.CleanupPlayer(player)
    
    print("[PLAYER_INFO] " .. player.Name .. " cleaned up")
end

-- Initialize the manager
function PlayerManager.Initialize(): boolean
    print("[PLAYER_INFO] Initializing PlayerManager...")
    
    -- Setup remote events and functions first
    local eventsSetup = SetupRemoteEvents()
    if not eventsSetup.success then
        warn("[PLAYER_ERROR] Failed to set up remote events: " .. eventsSetup.message)
    else
        print(eventsSetup.message)
    end
    
    local functionsSetup = SetupRemoteFunctions()
    if not functionsSetup.success then
        warn("[PLAYER_ERROR] Failed to set up remote functions: " .. functionsSetup.message)
    else
        print(functionsSetup.message)
    end
    
    -- Handle existing players
    for _, player in ipairs(Players:GetPlayers()) do
        task.spawn(function()
            local success = PlayerManager.InitializePlayer(player)
            if not success then
                warn("[PLAYER_ERROR] Failed to initialize " .. player.Name)
            end
        end)
    end
    
    -- Handle future players
    Players.PlayerAdded:Connect(function(player)
        task.spawn(function()
            local success = PlayerManager.InitializePlayer(player)
            if not success then
                warn("[PLAYER_ERROR] Failed to initialize " .. player.Name)
                
                -- Retry initialization after a delay
                task.delay(5, function()
                    print("[PLAYER_INFO] Retrying initialization for " .. player.Name)
                    PlayerManager.InitializePlayer(player)
                end)
            end
        end)
    end)
    
    -- Handle players leaving
    Players.PlayerRemoving:Connect(function(player)
        PlayerManager.CleanupPlayer(player)
    end)
    
    print("[PLAYER_INFO] PlayerManager initialized successfully")
    return true
end

return PlayerManager 