--[[
    GameDataService.luau
    Centralized management of static game data like careers, items, etc.
]]

local GameDataService = {}

-- Services
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- Remote function for accessing game data
local remoteFunction = nil

-- Cache for loaded game data
local gameData = {
    Careers = {},
    Items = {},
    Furniture = {},
    Vehicles = {}
}

-- Default data fallbacks (minimal examples, actual data comes from ModuleScripts)
local DEFAULT_CAREERS = {
    Chef = {
        id = "Chef",
        name = "Master Chef",
        type = "Creative",
        description = "Create culinary masterpieces in restaurants around town.",
        image = "rbxassetid://12345678",
        levelRequired = 2,
        stats = {
            Creativity = 85,
            Income = 60,
            Stress = 45,
            Advancement = 70
        }
    }
}

local DEFAULT_ITEMS = {
    apple = {
        id = "apple",
        name = "Apple",
        description = "A fresh, juicy apple",
        category = "Food",
        value = 5
    }
}

-- Setup remote function for client access
local function SetupRemoteFunction()
    -- Ensure RemoteFunctions folder exists
    local remoteFunctions = ReplicatedStorage:FindFirstChild("RemoteFunctions")
    if not remoteFunctions then
        remoteFunctions = Instance.new("Folder")
        remoteFunctions.Name = "RemoteFunctions"
        remoteFunctions.Parent = ReplicatedStorage
    end
    
    -- Create the GetGameData remote function if it doesn't exist
    remoteFunction = remoteFunctions:FindFirstChild("GetGameData")
    if not remoteFunction then
        remoteFunction = Instance.new("RemoteFunction")
        remoteFunction.Name = "GetGameData"
        remoteFunction.Parent = remoteFunctions
        print("[GAME_DATA] Created GetGameData RemoteFunction")
    end
    
    -- Set up the invoke handler
    remoteFunction.OnServerInvoke = function(player, dataType, specificId)
        return GameDataService.HandleGetGameData(player, dataType, specificId)
    end
end

-- Generic function to load data for a specific type
local function LoadDataType(dataType, defaultData)
    print("[GAME_DATA] Loading " .. dataType .. " data...")
    
    -- Try to load from the consolidated data ModuleScript
    local success, loadedData = pcall(function()
        -- Look for the module in ServerScriptService first (since we're creating files there)
        local dataModule = script.Parent.Parent:FindFirstChild("GameData")
        if dataModule then
            dataModule = dataModule:FindFirstChild(dataType .. "Data")
            if dataModule and dataModule:IsA("ModuleScript") then
                return require(dataModule)
            end
        end
        
        -- Try in ServerStorage as fallback
        dataModule = ServerStorage:FindFirstChild("GameData")
        if dataModule then
            dataModule = dataModule:FindFirstChild(dataType .. "Data")
            if dataModule and dataModule:IsA("ModuleScript") then
                return require(dataModule)
            end
        end
        
        -- If we can't find the module, return nil to trigger fallback
        return nil
    end)
    
    if success and loadedData then
        gameData[dataType] = loadedData
        print("[GAME_DATA] Loaded " .. tostring(tableLength(gameData[dataType])) .. " " .. dataType:lower() .. " from data module")
    else
        print("[GAME_DATA] No " .. dataType:lower() .. " data module found, using default data")
        -- Use default data as fallback
        gameData[dataType] = defaultData or {}
        if not success and loadedData then
            warn("[GAME_DATA] Error loading " .. dataType:lower() .. " data: " .. tostring(loadedData))
        end
    end
end

-- Helper function to get table length
function tableLength(tbl)
    local count = 0
    for _ in pairs(tbl) do
        count = count + 1
    end
    return count
end

-- Helper function to get table keys
function tableKeys(tbl)
    local keys = {}
    for key, _ in pairs(tbl) do
        table.insert(keys, key)
    end
    return keys
end

-- Initialize the service
function GameDataService.Initialize()
    print("[GAME_DATA] Initializing GameDataService")
    
    -- Load all static game data from consolidated ModuleScripts
    LoadDataType("Careers", DEFAULT_CAREERS)
    LoadDataType("Items", DEFAULT_ITEMS)
    LoadDataType("Furniture", {})
    LoadDataType("Vehicles", {})
    
    -- Setup remote functions for client access
    SetupRemoteFunction()
    
    print("[GAME_DATA] GameDataService initialized")
    return true
end

-- Handler for GetGameData remote function
function GameDataService.HandleGetGameData(player, dataType, specificId)
    -- Validate player has permission to access this data type
    -- (could implement access control here)
    
    -- Handle different data type requests
    if dataType == "Careers" then
        if specificId then
            -- Return specific career
            return gameData.Careers[specificId]
        else
            -- Return all careers
            return gameData.Careers
        end
    elseif dataType == "Items" then
        if specificId then
            return gameData.Items[specificId]
        else
            return gameData.Items
        end
    elseif dataType == "Furniture" then
        if specificId then
            return gameData.Furniture[specificId]
        else
            return gameData.Furniture
        end
    elseif dataType == "Vehicles" then
        if specificId then
            return gameData.Vehicles[specificId]
        else
            return gameData.Vehicles
        end
    end
    
    -- If data type is not recognized
    return nil
end

-- Public API to get career data (for server modules)
function GameDataService.GetAllCareers()
    return gameData.Careers
end

-- Get career by id
function GameDataService.GetCareerById(careerId)
    return gameData.Careers[careerId]
end

-- Get all items
function GameDataService.GetAllItems()
    return gameData.Items
end

-- Get item by id
function GameDataService.GetItemById(itemId)
    return gameData.Items[itemId]
end

-- Get all furniture
function GameDataService.GetAllFurniture()
    return gameData.Furniture
end

-- Get furniture by id
function GameDataService.GetFurnitureById(furnitureId)
    return gameData.Furniture[furnitureId]
end

-- Get all vehicles
function GameDataService.GetAllVehicles()
    return gameData.Vehicles
end

-- Get vehicle by id
function GameDataService.GetVehicleById(vehicleId)
    return gameData.Vehicles[vehicleId]
end

-- Check if player meets career requirements
function GameDataService.CanSelectCareer(player, careerId)
    local career = gameData.Careers[careerId]
    if not career then
        return false
    end
    
    -- Get player data (assuming DataService exists)
    local DataService = require(ServerScriptService.Server.Services.DataService)
    local playerData = DataService.GetPlayerData(player.UserId)
    
    -- Check level requirement
    if career.levelRequired and playerData and playerData.Stats then
        local playerLevel = playerData.Stats.level or 1
        return playerLevel >= career.levelRequired
    end
    
    -- Default to allowing if no requirements
    return true
end

return GameDataService 