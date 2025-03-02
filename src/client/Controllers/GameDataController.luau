--[[
    GameDataController.luau
    Client-side controller for accessing static game data like careers, items, etc.
]]

local GameDataController = {}

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Data caches
local cachedData = {
    Careers = nil,
    Items = nil,
    Furniture = nil,
    Vehicles = nil
}

-- Cache lifetimes (in seconds)
local CACHE_LIFETIME = {
    Careers = 300, -- 5 minutes
    Items = 300,
    Furniture = 300,
    Vehicles = 300
}

-- Cache timestamps
local cacheTimestamps = {
    Careers = 0,
    Items = 0, 
    Furniture = 0,
    Vehicles = 0
}

-- Data change listeners
local dataListeners = {}

-- Initialize the controller
function GameDataController.Initialize()
    print("[GAME_DATA] Initializing GameDataController")
    
    -- Perform any initial loading here
    -- We'll load data on-demand instead of preloading everything
    
    print("[GAME_DATA] GameDataController initialized")
    return true
end

-- Helper function to invoke the remote function
local function InvokeGameDataFunction(dataType, specificId)
    -- Ensure RemoteFunctions folder exists
    local remoteFunctions = ReplicatedStorage:FindFirstChild("RemoteFunctions")
    if not remoteFunctions then
        warn("[GAME_DATA] RemoteFunctions folder not found")
        return nil
    end
    
    -- Get the GetGameData function
    local getGameDataFunc = remoteFunctions:FindFirstChild("GetGameData")
    if not getGameDataFunc then
        warn("[GAME_DATA] GetGameData function not found")
        return nil
    end
    
    -- Call the function
    local success, result = pcall(function()
        return getGameDataFunc:InvokeServer(dataType, specificId)
    end)
    
    if not success then
        warn("[GAME_DATA] Error fetching " .. dataType .. " data: " .. tostring(result))
        return nil
    end
    
    return result
end

-- Check if cache is valid
local function IsCacheValid(dataType)
    if not cachedData[dataType] then
        return false
    end
    
    local currentTime = os.time()
    local cacheTime = cacheTimestamps[dataType] or 0
    local lifetime = CACHE_LIFETIME[dataType] or 300
    
    return (currentTime - cacheTime) <= lifetime
end

-- Refresh cache for a data type
local function RefreshCache(dataType)
    local data = InvokeGameDataFunction(dataType)
    
    if data then
        cachedData[dataType] = data
        cacheTimestamps[dataType] = os.time()
        
        -- Notify listeners
        if dataListeners[dataType] then
            for _, listener in ipairs(dataListeners[dataType]) do
                task.spawn(function()
                    local success, err = pcall(function()
                        listener(data)
                    end)
                    
                    if not success then
                        warn("[GAME_DATA] Failed to notify listener for " .. dataType .. ": " .. tostring(err))
                    end
                end)
            end
        end
    end
    
    return data
end

-- Get all careers
function GameDataController.GetAllCareers()
    if not IsCacheValid("Careers") then
        RefreshCache("Careers")
    end
    
    return cachedData.Careers or {}
end

-- Get a specific career by ID
function GameDataController.GetCareerById(careerId)
    -- Check if we already have careers cached
    if IsCacheValid("Careers") and cachedData.Careers and cachedData.Careers[careerId] then
        return cachedData.Careers[careerId]
    end
    
    -- Try to get specific career directly
    local career = InvokeGameDataFunction("Careers", careerId)
    
    -- If not found, refresh the whole cache and try again
    if not career then
        RefreshCache("Careers")
        return cachedData.Careers and cachedData.Careers[careerId]
    end
    
    return career
end

-- Get all items
function GameDataController.GetAllItems()
    if not IsCacheValid("Items") then
        RefreshCache("Items")
    end
    
    return cachedData.Items or {}
end

-- Get a specific item by ID
function GameDataController.GetItemById(itemId)
    -- Similar pattern to GetCareerById
    if IsCacheValid("Items") and cachedData.Items and cachedData.Items[itemId] then
        return cachedData.Items[itemId]
    end
    
    local item = InvokeGameDataFunction("Items", itemId)
    
    if not item then
        RefreshCache("Items")
        return cachedData.Items and cachedData.Items[itemId]
    end
    
    return item
end

-- Get all furniture
function GameDataController.GetAllFurniture()
    if not IsCacheValid("Furniture") then
        RefreshCache("Furniture")
    end
    
    return cachedData.Furniture or {}
end

-- Get all vehicles
function GameDataController.GetAllVehicles()
    if not IsCacheValid("Vehicles") then
        RefreshCache("Vehicles")
    end
    
    return cachedData.Vehicles or {}
end

-- Force refresh a specific data type
function GameDataController.ForceRefresh(dataType)
    if not cachedData[dataType] then
        warn("[GAME_DATA] Unknown data type: " .. dataType)
        return false
    end
    
    return RefreshCache(dataType) ~= nil
end

-- Register a listener for data changes
function GameDataController.ListenForData(dataType, callback)
    if not dataListeners[dataType] then
        dataListeners[dataType] = {}
    end
    
    table.insert(dataListeners[dataType], callback)
    
    -- Return a function to disconnect the listener
    return function()
        local index = table.find(dataListeners[dataType], callback)
        if index then
            table.remove(dataListeners[dataType], index)
        end
    end
end

-- Check if player can select a career (client-side prediction)
function GameDataController.CanSelectCareer(careerId)
    -- Get the career data
    local career = GameDataController.GetCareerById(careerId)
    if not career then
        return false
    end
    
    -- Get player data (assuming PlayerDataController exists)
    local PlayerDataController = require(script.Parent.PlayerDataController)
    local playerLevel = PlayerDataController.GetDataByPath("Stats.level") or 1
    
    -- Check requirements
    if career.levelRequired and playerLevel < career.levelRequired then
        return false
    end
    
    return true
end

return GameDataController 