--[[
    Server init.lua
    Main entry point for the server-side code
]]

-- Services
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

-- Types
type RemotesSetupResult = {
    success: boolean,
    eventsFolder: Folder?,
    functionsFolder: Folder?,
    error: string?
}

-- Setup RemoteEvents and RemoteFunctions
local function SetupRemotes(): RemotesSetupResult
    print("Setting up remote events and functions...")
    
    local result: RemotesSetupResult = {
        success = true,
        eventsFolder = nil,
        functionsFolder = nil
    }

    -- Create RemoteEvents folder if it doesn't exist
    local success, errorMsg = pcall(function()
        if not ReplicatedStorage:FindFirstChild("RemoteEvents") then
            local remoteEvents = Instance.new("Folder")
            remoteEvents.Name = "RemoteEvents"
            remoteEvents.Parent = ReplicatedStorage
            print("[SERVER] Created RemoteEvents folder")
            result.eventsFolder = remoteEvents
            
            -- Create critical RemoteEvents
            local criticalEvents = {
                "InitialDataReceived",
                "StatChanged",
                "InventoryChanged",
                "CareerProgressUpdated",
                "NewUnlock",
                "NotifyPlayer",
                "JobCompleted",
                "RequestStatUpdate"
            }
            
            for _, eventName in ipairs(criticalEvents) do
                local event = Instance.new("RemoteEvent")
                event.Name = eventName
                event.Parent = remoteEvents
                print("[SERVER] Created critical RemoteEvent: " .. eventName)
            end
        else
            result.eventsFolder = ReplicatedStorage:FindFirstChild("RemoteEvents")
            print("[SERVER] RemoteEvents folder already exists")
            
            -- Ensure critical events exist
            local criticalEvents = {
                "InitialDataReceived",
                "StatChanged",
                "InventoryChanged"
            }
            
            for _, eventName in ipairs(criticalEvents) do
                if not result.eventsFolder:FindFirstChild(eventName) then
                    local event = Instance.new("RemoteEvent")
                    event.Name = eventName
                    event.Parent = result.eventsFolder
                    print("[SERVER] Created missing critical RemoteEvent: " .. eventName)
                end
            end
        end
        
        -- Create RemoteFunctions folder if it doesn't exist
        if not ReplicatedStorage:FindFirstChild("RemoteFunctions") then
            local remoteFunctions = Instance.new("Folder")
            remoteFunctions.Name = "RemoteFunctions"
            remoteFunctions.Parent = ReplicatedStorage
            print("[SERVER] Created RemoteFunctions folder")
            result.functionsFolder = remoteFunctions
            
            -- Create critical RemoteFunctions
            local criticalFunctions = {
                "GetPlayerData",
                "UseItem",
                "PurchaseItem"
            }
            
            for _, funcName in ipairs(criticalFunctions) do
                local func = Instance.new("RemoteFunction")
                func.Name = funcName
                func.Parent = remoteFunctions
                print("[SERVER] Created critical RemoteFunction: " .. funcName)
            end
        else
            result.functionsFolder = ReplicatedStorage:FindFirstChild("RemoteFunctions")
            print("[SERVER] RemoteFunctions folder already exists")
            
            -- Ensure critical functions exist
            local criticalFunctions = {
                "GetPlayerData",
                "UseItem",
                "PurchaseItem"
            }
            
            for _, funcName in ipairs(criticalFunctions) do
                if not result.functionsFolder:FindFirstChild(funcName) then
                    local func = Instance.new("RemoteFunction")
                    func.Name = funcName
                    func.Parent = result.functionsFolder
                    print("[SERVER] Created missing critical RemoteFunction: " .. funcName)
                end
            end
        end
    end)
    
    if not success then
        result.success = false
        result.error = "Failed to setup remote folders: " .. tostring(errorMsg)
        warn("[SERVER_ERROR] " .. result.error)
    end
    
    return result
end

-- Initialize all services
local function InitializeServices(): {string: boolean}
    local serviceStatuses = {}
    
    -- Data Services
    local success, errorMsg = pcall(function()
        local DataService = require(script.Services.DataService)
        DataService.Initialize()
        serviceStatuses["DataService"] = true
    end)
    
    if not success then
        serviceStatuses["DataService"] = false
        warn("[SERVER_ERROR] Failed to initialize DataService: " .. tostring(errorMsg))
    else
        print("[SERVER] DataService initialized")
    end
    
    return serviceStatuses
end

-- Initialize all systems
local function InitializeSystems(): {string: boolean}
    local systemStatuses = {}
    
    -- Player Manager (handles player lifecycle)
    local success, errorMsg = pcall(function()
        local PlayerManager = require(script.Systems.PlayerManager)
        PlayerManager.Initialize()
        systemStatuses["PlayerManager"] = true
    end)
    
    if not success then
        systemStatuses["PlayerManager"] = false
        warn("[SERVER_ERROR] Failed to initialize PlayerManager: " .. tostring(errorMsg))
    else
        print("[SERVER] All systems initialized")
    end
    
    return systemStatuses
end

-- Main initialization
local function Initialize(): boolean
    print("[SERVER] Server initializing...")
    
    -- Set up remote events and functions first
    local remotesSetup = SetupRemotes()
    if not remotesSetup.success then
        warn("[SERVER_ERROR] Failed to setup remotes: " .. tostring(remotesSetup.error))
        -- Critical error, but continue trying to initialize other systems
    end
    
    -- Initialize in the correct order
    local serviceStatuses = InitializeServices()
    local systemStatuses = InitializeSystems()
    
    -- Check for any initialization failures
    local allSuccessful = true
    local failureLog = {}
    
    for service, status in pairs(serviceStatuses) do
        if not status then
            table.insert(failureLog, service)
            allSuccessful = false
        end
    end
    
    for system, status in pairs(systemStatuses) do
        if not status then
            table.insert(failureLog, system)
            allSuccessful = false
        end
    end
    
    if not allSuccessful then
        warn("[SERVER_ERROR] Server initialization incomplete. Failed components: " .. table.concat(failureLog, ", "))
        return false
    end
    
    print("[SERVER] Server initialization complete with ID: " .. HttpService:GenerateGUID(false))
    return true
end

-- Start the game with error handling
local success, errorMsg = pcall(function()
    Initialize()
end)

if not success then
    warn("[SERVER_ERROR] CRITICAL INITIALIZATION FAILURE: " .. tostring(errorMsg))
end 