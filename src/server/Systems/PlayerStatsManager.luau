--[[
    PlayerStatsManager.lua
    Manages player stats like currency, energy, hunger, etc.
]]

local PlayerStatsManager = {}

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- Modules
local Constants = require(ReplicatedStorage.Shared.Configurations.Constants)
local DataService = require(ServerScriptService.Server.Services.DataService)

-- Types
local PlayerTypes = require(ReplicatedStorage.Shared.Types.PlayerTypes)
type PlayerStats = PlayerTypes.PlayerStats
type ModifyResult = {success: boolean, message: string, oldValue: number?, newValue: number?}

-- Private stats data reference
local playerStats: {[number]: PlayerStats} = {}
local regenThreads: {[number]: thread} = {}

-- Initialize stats for a player
function PlayerStatsManager.InitializeStats(player: Player, statsData: PlayerStats?): PlayerStats
    local PlayerStats = Constants.PLAYER_STATS
    
    playerStats[player.UserId] = statsData or {
        Currency = PlayerStats.DEFAULT_STARTING_CURRENCY,
        PremiumCurrency = PlayerStats.DEFAULT_STARTING_PREMIUM_CURRENCY,
        Energy = PlayerStats.DEFAULT_ENERGY,
        MaxEnergy = PlayerStats.DEFAULT_MAX_ENERGY,
        EnergyRegenRate = PlayerStats.DEFAULT_ENERGY_REGEN_RATE,
        Happiness = PlayerStats.DEFAULT_HAPPINESS,
        Hygiene = PlayerStats.DEFAULT_HYGIENE,
        Hunger = PlayerStats.DEFAULT_HUNGER
    }
    
    -- Start stat regeneration
    PlayerStatsManager.StartStatRegeneration(player)
    
    return playerStats[player.UserId]
end

-- Modify a numeric stat
function PlayerStatsManager.ModifyStat(player: Player, statName: string, amount: number): ModifyResult
    local userId = player.UserId
    if not playerStats[userId] then 
        return {
            success = false, 
            message = "[STATS_ERROR] Player stats not initialized for " .. player.Name .. " (ID: " .. userId .. ")"
        }
    end
    
    -- Verify the stat exists
    if playerStats[userId][statName] == nil then
        return {
            success = false, 
            message = "[STATS_ERROR] Invalid stat name: '" .. statName .. "' for " .. player.Name .. " (ID: " .. userId .. ")"
        }
    end
    
    local oldValue = playerStats[userId][statName]
    
    -- Check if operation would result in negative value for protected stats
    if playerStats[userId][statName] + amount < 0 and 
       (statName == "Currency" or statName == "PremiumCurrency") then
        return {
            success = false, 
            message = "[STATS_ERROR] Insufficient " .. statName .. " (" .. oldValue .. ") to deduct " .. math.abs(amount),
            oldValue = oldValue
        }
    end
    
    -- Apply stat change
    playerStats[userId][statName] = playerStats[userId][statName] + amount
    
    -- Clamp values for stats with limits
    local maxValues = {
        Energy = playerStats[userId].MaxEnergy,
        Happiness = 100,
        Hygiene = 100,
        Hunger = 100
    }
    
    if maxValues[statName] then
        playerStats[userId][statName] = math.clamp(
            playerStats[userId][statName], 
            0, 
            maxValues[statName]
        )
    end
    
    local newValue = playerStats[userId][statName]
    
    -- Notify client of stat change
    PlayerStatsManager.NotifyStatChange(player, statName)
    
    -- Mark data as dirty for saving
    local playerData = DataService.GetPlayerData(player)
    if playerData and playerData.Stats then
        playerData.Stats[statName] = playerStats[userId][statName]
        DataService.MarkDataDirty(player.UserId)
    end
    
    return {
        success = true, 
        message = "Stat modified successfully", 
        oldValue = oldValue, 
        newValue = newValue
    }
end

-- Get current stat value
function PlayerStatsManager.GetStat(player: Player, statName: string): (number?, string?)
    local userId = player.UserId
    if not playerStats[userId] then 
        return nil, "[STATS_ERROR] Player stats not initialized for " .. player.Name .. " (ID: " .. userId .. ")"
    end
    
    if playerStats[userId][statName] == nil then 
        return nil, "[STATS_ERROR] Invalid stat name: '" .. statName .. "'"
    end
    
    return playerStats[userId][statName]
end

-- Get all stats for a player
function PlayerStatsManager.GetAllStats(player: Player): (PlayerStats?, string?)
    local userId = player.UserId
    if not playerStats[userId] then 
        return nil, "[STATS_ERROR] Player stats not initialized for " .. player.Name .. " (ID: " .. userId .. ")"
    end
    
    -- Return a copy to prevent external modification
    return table.clone(playerStats[userId])
end

-- Stat regeneration system
function PlayerStatsManager.StartStatRegeneration(player: Player)
    local userId = player.UserId
    
    -- Clean up any existing thread
    if regenThreads[userId] then
        task.cancel(regenThreads[userId])
    end
    
    -- Create regeneration thread
    regenThreads[userId] = task.spawn(function()
        while playerStats[userId] do
            -- Regenerate energy
            if playerStats[userId].Energy < playerStats[userId].MaxEnergy then
                PlayerStatsManager.ModifyStat(player, "Energy", playerStats[userId].EnergyRegenRate)
            end
            
            -- Decrease hunger over time
            if playerStats[userId].Hunger > 0 then
                -- Decrease hunger slightly every minute
                PlayerStatsManager.ModifyStat(player, "Hunger", -1)
            end
            
            -- Decrease hygiene over time
            if playerStats[userId].Hygiene > 0 then
                -- Decrease hygiene slightly every minute
                PlayerStatsManager.ModifyStat(player, "Hygiene", -0.5)
            end
            
            -- Happiness affected by hunger and hygiene
            if playerStats[userId].Hunger < 20 or playerStats[userId].Hygiene < 20 then
                PlayerStatsManager.ModifyStat(player, "Happiness", -2)
            end
            
            task.wait(60) -- Update stats every minute
        end
    end)
end

-- Notify client of stat changes
function PlayerStatsManager.NotifyStatChange(player: Player, statName: string): boolean
    local RemoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
    if not RemoteEvents then
        warn("[STATS_ERROR] RemoteEvents folder not found when trying to notify stat change: " .. statName)
        return false
    end
    
    local StatChangedEvent = RemoteEvents:FindFirstChild("StatChanged")
    if not StatChangedEvent then
        warn("[STATS_ERROR] StatChanged event not found when trying to notify stat change: " .. statName)
        return false
    end
    
    -- Verify player stats exist
    if not playerStats[player.UserId] or playerStats[player.UserId][statName] == nil then
        warn("[STATS_ERROR] Cannot notify client of stat change - invalid stat: " .. statName)
        return false
    end
    
    -- Send the update to client
    local success, err = pcall(function()
        StatChangedEvent:FireClient(player, statName, playerStats[player.UserId][statName])
    end)
    
    if not success then
        warn("[STATS_ERROR] Failed to notify client of stat change: " .. err)
        return false
    end
    
    return true
end

-- Clean up when player leaves
function PlayerStatsManager.CleanupPlayer(player: Player)
    local userId = player.UserId
    
    -- Cancel regeneration thread
    if regenThreads[userId] then
        task.cancel(regenThreads[userId])
        regenThreads[userId] = nil
    end
    
    -- Clear cached stats
    playerStats[userId] = nil
end

return PlayerStatsManager 