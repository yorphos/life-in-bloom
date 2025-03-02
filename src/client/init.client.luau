--[[
    Client init.lua
    Main entry point for the client-side code
]]

print("localScript LOADED: Client init.client.lua") -- Debug print to confirm script is loaded

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

print("SERVICES LOADED") -- Debug print after services are loaded

-- Types
type RemotesStatus = {
    eventsFound: boolean,
    functionsFound: boolean,
    missingEvents: {string},
    retry: number
}

-- Variables
local localPlayer = Players.LocalPlayer
print("LOCAL PLAYER REFERENCE CREATED: " .. (localPlayer and localPlayer.Name or "nil"))

-- Initialize all controllers
local function InitializeControllers(): boolean
    print("Initializing controllers...")
    
    -- Ensure Controllers folder exists
    if not script:FindFirstChild("Controllers") then
        warn("[CLIENT_WARNING] Controllers folder not found, attempting to create it...")
        local success, err = pcall(function()
            local controllersFolder = Instance.new("Folder")
            controllersFolder.Name = "Controllers"
            controllersFolder.Parent = script
            print("[CLIENT_INFO] Created Controllers folder")
        end)
        
        if not success then
            warn("[CLIENT_ERROR] Failed to create Controllers folder: " .. tostring(err))
            return false
        end
        
        -- Wait for potential PlayerDataController to be added
        task.wait(1)
    end
    
    -- Player Data Controller
    local playerDataControllerSuccess, playerDataControllerErrorMsg = pcall(function()
        local PlayerDataController = require(script.Controllers.PlayerDataController)
        PlayerDataController.Initialize()
    end)
    
    if not playerDataControllerSuccess then
        warn("[CLIENT_ERROR] Controller initialization failed: " .. tostring(playerDataControllerErrorMsg))
        return false
    end
    
    -- Game Data Controller (for static game data)
    local gameDataControllersuccess, gameDataControllerErrorMsg = pcall(function()
        local GameDataController = require(script.Controllers.GameDataController)
        GameDataController.Initialize()
    end)
    
    if not gameDataControllersuccess then
        warn("[CLIENT_ERROR] Game data controller initialization failed: " .. tostring(gameDataControllerErrorMsg))
        -- We continue even if this fails, as it's not critical for initial gameplay
        -- The controller will retry loading data when needed
    end
    
    -- Main UI Controller (depends on PlayerDataController)
    local mainUIControllerSuccess, mainUIControllerErrorMsg = pcall(function()
        local MainUIController = require(script.Controllers.MainUIController)
        MainUIController.Initialize()
    end)
    
    if not mainUIControllerSuccess then
        warn("[CLIENT_ERROR] UI controller initialization failed: " .. tostring(mainUIControllerErrorMsg))
        return false
    end
    
    -- Debug GUI Controller
    local debugUIControllerSuccess, debugUIErrorMsg = pcall(function()
        local DebugGUIController = require(script.Controllers.DebugGUIController)
        DebugGUIController.Initialize()
    end)
    
    if not debugUIControllerSuccess then
        warn("[CLIENT_WARNING] Debug GUI controller initialization failed: " .. tostring(debugUIErrorMsg))
        -- We don't return false here since this is not critical for gameplay
    end
    
    print("All controllers initialized")
    return true
end

-- Wait for necessary resources with retry logic
local function WaitForResources(): RemotesStatus
    print("Waiting for resources...")
    
    -- Maximum number of retries
    local maxRetries = 5
    local retryDelay = 5 -- seconds between retries
    local currentRetry = 0
    
    local status: RemotesStatus = {
        eventsFound = false,
        functionsFound = false,
        missingEvents = {},
        retry = 0
    }
    
    while currentRetry < maxRetries do
        -- Wait for RemoteEvents folder
        local RemoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
        if not RemoteEvents then
            print("Remote Events folder not found, waiting for it to be created... (Attempt " .. currentRetry + 1 .. "/" .. maxRetries .. ")")
            -- Try to wait for it directly
            RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents", retryDelay)
            
            if not RemoteEvents then
                currentRetry = currentRetry + 1
                status.retry = currentRetry
                if currentRetry >= maxRetries then
                    warn("[CLIENT_ERROR] RemoteEvents folder not found after " .. maxRetries .. " retries! Server may not be fully initialized.")
                    return status
                end
            else
                print("RemoteEvents folder found!")
                status.eventsFound = true
                break
            end
        else
            print("RemoteEvents folder found immediately!")
            status.eventsFound = true
            break
        end
    end
    
    -- Check for RemoteFunctions after successfully finding RemoteEvents
    local RemoteFunctions = ReplicatedStorage:FindFirstChild("RemoteFunctions")
    if not RemoteFunctions then
        print("Remote Functions folder not found, waiting for it to be created...")
        RemoteFunctions = ReplicatedStorage:WaitForChild("RemoteFunctions", 10)
        
        if not RemoteFunctions then
            warn("[CLIENT_ERROR] RemoteFunctions folder not found within timeout!")
            -- We can continue even without RemoteFunctions as they may not be critical
            print("Continuing initialization despite missing RemoteFunctions")
        else
            print("RemoteFunctions folder found!")
            status.functionsFound = true
        end
    else
        print("RemoteFunctions folder found immediately!")
        status.functionsFound = true
    end
    
    -- Validate critical RemoteEvents exist
    if status.eventsFound then
        local RemoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
        local requiredEvents = {"InitialDataReceived", "StatChanged", "InventoryChanged"}
        status.missingEvents = {}
        
        for _, eventName in ipairs(requiredEvents) do
            if not RemoteEvents:FindFirstChild(eventName) then
                table.insert(status.missingEvents, eventName)
            end
        end
        
        if status.missingEvents and #status.missingEvents > 0 then
            warn("[CLIENT_ERROR] Missing critical RemoteEvents: " .. table.concat(status.missingEvents, ", "))
        end
    end
    
    return status
end

-- Main initialization
local function Initialize(): boolean
    print("Client initializing...")
    
    -- Wait for resources
    local resourceStatus = WaitForResources()
    if not resourceStatus.eventsFound then
        warn("[CLIENT_ERROR] Failed to initialize client: Remote events not found (Player: " .. localPlayer.Name .. ", ID: " .. localPlayer.UserId .. ")")
        -- Retry initialization after a delay
        print("Retrying initialization in 15 seconds...")
        task.delay(15, function()
            print("Attempting to reinitialize client...")
            Initialize()
        end)
        return false
    end
    
    -- Warn about missing events, but continue
    if resourceStatus.missingEvents and #resourceStatus.missingEvents > 0 then
        warn("[CLIENT_WARNING] Proceeding with initialization despite missing events: " .. table.concat(resourceStatus.missingEvents, ", "))
    end
    
    -- Initialize controllers
    if not InitializeControllers() then
        warn("[CLIENT_ERROR] Controller initialization failed, will retry in 10 seconds...")
        task.delay(10, function()
            print("Attempting to reinitialize controllers...")
            Initialize()
        end)
        return false
    end
    
    print("Client initialization complete")
    return true
end

-- Start the client when module is required
print("ABOUT TO START INITIALIZATION")

local success, errorMsg = pcall(function()
    Initialize()
end)

if not success then
    warn("[CLIENT_ERROR] INITIALIZATION FAILED: " .. tostring(errorMsg) .. " (Player: " .. localPlayer.Name .. ", ID: " .. localPlayer.UserId .. ")")
    -- Retry initialization after error
    task.delay(10, function()
        print("Attempting to reinitialize client after error...")
        Initialize()
    end)
end