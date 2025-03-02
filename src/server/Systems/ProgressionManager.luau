--[[
    ProgressionManager.lua
    Manages player levels, experience, and unlocks across different career paths
]]

local ProgressionManager = {}

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- Modules
local Constants = require(ReplicatedStorage.Shared.Configurations.Constants)
local JobTypes = require(ReplicatedStorage.Shared.Configurations.JobTypes)
local DataService = require(ServerScriptService.Server.Services.DataService)
local InventoryManager = require(ServerScriptService.Server.Systems.InventoryManager)

-- Types
local PlayerTypes = require(ReplicatedStorage.Shared.Types.PlayerTypes)
type CareerData = PlayerTypes.CareerData
type ProgressResult = {success: boolean, message: string, levelUp: boolean?, careers: {[string]: CareerData}?}
type UnlockData = {id: string, type: string, category: string?, itemId: string?, abilityId: string?}

-- Calculate XP required for a given level
function ProgressionManager.GetXPForLevel(level: number): number
    return Constants.CAREERS.BASE_XP_REQUIREMENT * (Constants.CAREERS.XP_MULTIPLIER ^ (level - 1))
end

-- Initialize progression for a player
function ProgressionManager.InitializeProgression(player: Player, careersData: {[string]: CareerData}?): {[string]: CareerData}
    local careers = careersData or {}
    
    -- Initialize default values for each job type if not present
    for _, job in ipairs(JobTypes.JobTypes) do
        if not careers[job.id] then
            careers[job.id] = {
                Level = 1,
                XP = 0,
                Unlocks = {},
                Stats = {
                    CompletedJobs = 0,
                    TotalEarnings = 0,
                    TimeSpent = 0
                }
            }
        end
    end
    
    return careers
end

-- Add experience to a career
function ProgressionManager.AddCareerXP(player: Player, jobType: string, amount: number): ProgressResult
    -- Get player data
    local playerData = DataService.GetPlayerData(player)
    
    if not playerData or not playerData.Careers or not playerData.Careers[jobType] then
        return {
            success = false, 
            message = "[PROGRESSION_ERROR] Career '" .. jobType .. "' not found for " .. player.Name
        }
    end
    
    local career = playerData.Careers[jobType]
    
    -- Add XP
    career.XP = career.XP + amount
    
    -- Check for level up
    local leveledUp = false
    while career.Level < Constants.CAREERS.MAX_LEVEL do
        local xpForNextLevel = ProgressionManager.GetXPForLevel(career.Level)
        
        if career.XP >= xpForNextLevel then
            -- Level up
            career.Level = career.Level + 1
            career.XP = career.XP - xpForNextLevel
            leveledUp = true
            
            -- Unlock new items/abilities for this level
            ProgressionManager.ProcessLevelUnlocks(player, jobType, career.Level)
        else
            break
        end
    end
    
    -- If at max level, cap XP
    if career.Level == Constants.CAREERS.MAX_LEVEL then
        career.XP = 0
    end
    
    -- Mark data as dirty
    DataService.MarkDataDirty(player.UserId)
    
    -- Notify client
    local success, errorMsg = pcall(function()
        local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents", 5)
        if not RemoteEvents then
            error("[PROGRESSION_ERROR] RemoteEvents folder not found when trying to notify career progress")
            return false
        end
        
        local CareerProgressEvent = RemoteEvents:WaitForChild("CareerProgressUpdated", 5)
        if not CareerProgressEvent then
            error("[PROGRESSION_ERROR] CareerProgressUpdated event not found when trying to notify career progress")
            return false
        end
        
        CareerProgressEvent:FireClient(
            player, 
            jobType, 
            career.Level, 
            career.XP, 
            ProgressionManager.GetXPForLevel(career.Level)
        )

        return true
    end)
    
    if not success then
        warn("[PROGRESSION_ERROR] Failed to notify client of career progress: " .. tostring(errorMsg))
    end
    
    return {
        success = true, 
        levelUp = leveledUp,
        message = leveledUp 
            and "Leveled up " .. jobType .. " to level " .. career.Level 
            or "Added " .. amount .. " XP to " .. jobType,
        careers = playerData.Careers
    }
end

-- Process unlocks for a new level
function ProgressionManager.ProcessLevelUnlocks(player: Player, jobType: string, level: number): {UnlockData}
    -- This would use a proper JobUnlocks configuration
    -- For now, use basic unlock logic
    
    -- Example unlocks based on job type and level
    local unlocks: {UnlockData} = {}
    
    -- Chef unlocks
    if jobType == "chef" then
        if level == 2 then
            unlocks = {
                {id = "basic_knife", type = "item", category = "Consumables", itemId = "basic_knife"}
            }
        elseif level == 5 then
            unlocks = {
                {id = "chef_hat", type = "item", category = "Clothing", itemId = "chef_hat"}
            }
        elseif level == 10 then
            unlocks = {
                {id = "master_cooking", type = "ability", abilityId = "master_cooking"}
            }
        end
    end
    
    -- Doctor unlocks
    if jobType == "doctor" then
        if level == 2 then
            unlocks = {
                {id = "basic_medkit", type = "item", category = "Consumables", itemId = "basic_medkit"}
            }
        elseif level == 5 then
            unlocks = {
                {id = "doctor_coat", type = "item", category = "Clothing", itemId = "doctor_coat"}
            }
        elseif level == 10 then
            unlocks = {
                {id = "advanced_healing", type = "ability", abilityId = "advanced_healing"}
            }
        end
    end
    
    -- Process each unlock
    local playerData = DataService.GetPlayerData(player)
    
    for _, unlock in ipairs(unlocks) do
        -- Add to player's unlocks
        if not playerData.Careers[jobType].Unlocks[unlock.id] then
            playerData.Careers[jobType].Unlocks[unlock.id] = true
            
            -- Process special unlocks
            if unlock.type == "item" then
                -- Give inventory item
                local result = InventoryManager.AddItem(player, unlock.category, unlock.itemId, 1)
                if not result.success then
                    warn("[PROGRESSION_ERROR] Failed to add unlock item: " .. result.message)
                end
            elseif unlock.type == "ability" then
                -- Grant ability (would be handled by specific job systems)
                -- Implementation would depend on how abilities are managed
                print("[PROGRESSION_INFO] Granted ability: " .. unlock.abilityId .. " to " .. player.Name)
            elseif unlock.type == "vehicle" then
                -- Grant vehicle access (would be handled by a VehicleSystem)
                print("[PROGRESSION_INFO] Granted vehicle: " .. unlock.id .. " to " .. player.Name)
            end
            
            -- Notify player about unlock
            local success, errorMsg = pcall(function()
                local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents", 5)
                if not RemoteEvents then
                    error("[PROGRESSION_ERROR] RemoteEvents folder not found when trying to notify unlock")
                    return false
                end
                
                local NewUnlockEvent = RemoteEvents:WaitForChild("NewUnlock", 5)
                if not NewUnlockEvent then
                    error("[PROGRESSION_ERROR] NewUnlock event not found when trying to notify unlock")
                    return false
                end
                
                NewUnlockEvent:FireClient(player, {
                    jobType = jobType,
                    level = level,
                    unlock = unlock
                })

                return true
            end)
            
            if not success then
                warn("[PROGRESSION_ERROR] Failed to notify client of new unlock: " .. tostring(errorMsg))
            end
        end
    end
    
    -- Mark data as dirty
    DataService.MarkDataDirty(player.UserId)
    
    return unlocks
end

-- Update career stats
function ProgressionManager.UpdateCareerStats(player: Player, jobType: string, statName: string, value: number, isIncrement: boolean): ProgressResult
    -- Get player data
    local playerData = DataService.GetPlayerData(player)
    
    if not playerData or not playerData.Careers or not playerData.Careers[jobType] then
        return {
            success = false, 
            message = "[PROGRESSION_ERROR] Career '" .. jobType .. "' not found for " .. player.Name
        }
    end
    
    local stats = playerData.Careers[jobType].Stats
    
    -- Update stat
    if isIncrement then
        stats[statName] = (stats[statName] or 0) + value
    else
        stats[statName] = value
    end
    
    -- Mark data as dirty
    DataService.MarkDataDirty(player.UserId)
    
    return {
        success = true,
        message = "Updated " .. jobType .. " career stat " .. statName .. " to " .. tostring(stats[statName]),
        careers = playerData.Careers
    }
end

-- Get career progress
function ProgressionManager.GetCareerProgress(player: Player, jobType: string): ({
    Level: number,
    XP: number,
    NextLevelXP: number,
    Unlocks: {[string]: boolean},
    Stats: {[string]: number}
}?, string?)
    -- Get player data
    local playerData = DataService.GetPlayerData(player)
    
    if not playerData or not playerData.Careers or not playerData.Careers[jobType] then
        return nil, "[PROGRESSION_ERROR] Career '" .. jobType .. "' not found for " .. player.Name
    end
    
    local career = playerData.Careers[jobType]
    
    return {
        Level = career.Level,
        XP = career.XP,
        NextLevelXP = ProgressionManager.GetXPForLevel(career.Level),
        Unlocks = career.Unlocks,
        Stats = career.Stats
    }
end

return ProgressionManager 