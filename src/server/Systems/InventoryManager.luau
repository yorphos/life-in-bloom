--[[
    InventoryManager.lua
    Manages player inventory items
]]

local InventoryManager = {}

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- Required modules
local DataService = require(ServerScriptService.Server.Services.DataService)

-- Types
local PlayerTypes = require(ReplicatedStorage.Shared.Types.PlayerTypes)
type PlayerInventory = PlayerTypes.PlayerInventory
type InventoryItem = PlayerTypes.InventoryItem
type InventoryResult = {success: boolean, message: string, item: InventoryItem?, itemId: string?, category: string?}
type MetadataResult = {success: boolean, metadata: {[string]: any}?, message: string, itemId: string?, category: string?}

-- Private inventory references
local playerInventories: {[number]: PlayerInventory} = {}

-- Initialize inventory for a player
function InventoryManager.InitializeInventory(player: Player, inventoryData: PlayerInventory?): PlayerInventory
    playerInventories[player.UserId] = inventoryData or {
        Furniture = {},
        Clothing = {},
        Collectibles = {},
        Consumables = {}
    }
    
    return playerInventories[player.UserId]
end

-- Add item to inventory
function InventoryManager.AddItem(player: Player, category: string, itemId: string, quantity: number?, metadata: {[string]: any}?): InventoryResult
    local userId = player.UserId
    if not playerInventories[userId] then 
        return {
            success = false, 
            message = "[INVENTORY_ERROR] Inventory not initialized for " .. player.Name .. " (ID: " .. userId .. ")"
        }
    end
    
    -- Verify the category exists
    if playerInventories[userId][category] == nil then
        return {
            success = false, 
            message = "[INVENTORY_ERROR] Invalid inventory category: '" .. category .. "' for " .. player.Name,
            category = category
        }
    end
    
    quantity = quantity or 1
    
    local currentItem = playerInventories[userId][category][itemId]
    
    -- Add new item or increment existing quantity
    if currentItem then
        currentItem.quantity = currentItem.quantity + quantity
    else
        playerInventories[userId][category][itemId] = {
            quantity = quantity,
            metadata = metadata or {}
        }
    end
    
    -- Notify client of inventory change
    InventoryManager.NotifyInventoryChange(player, category)
    
    -- Mark data as dirty for saving
    local playerData = DataService.GetPlayerData(player)
    if playerData and playerData.Inventory then
        playerData.Inventory[category] = playerInventories[userId][category]
        DataService.MarkDataDirty(player.UserId)
    end
    
    return {
        success = true, 
        message = "Item " .. itemId .. " added successfully (quantity: " .. quantity .. ")",
        itemId = itemId,
        category = category,
        item = playerInventories[userId][category][itemId]
    }
end

-- Remove item from inventory
function InventoryManager.RemoveItem(player: Player, category: string, itemId: string, quantity: number?): InventoryResult
    local userId = player.UserId
    if not playerInventories[userId] then 
        return {
            success = false, 
            message = "[INVENTORY_ERROR] Inventory not initialized for " .. player.Name .. " (ID: " .. userId .. ")"
        }
    end
    
    -- Verify the category exists
    if playerInventories[userId][category] == nil then
        return {
            success = false, 
            message = "[INVENTORY_ERROR] Invalid inventory category: '" .. category .. "' for " .. player.Name,
            category = category
        }
    end
    
    -- Verify the item exists
    if not playerInventories[userId][category][itemId] then
        return {
            success = false, 
            message = "[INVENTORY_ERROR] Item '" .. itemId .. "' not in inventory for " .. player.Name,
            itemId = itemId,
            category = category
        }
    end
    
    quantity = quantity or 1
    local currentItem = playerInventories[userId][category][itemId]
    
    -- Check if player has enough of the item
    if currentItem.quantity < quantity then
        return {
            success = false, 
            message = "[INVENTORY_ERROR] Insufficient quantity of '" .. itemId .. "' (have: " .. currentItem.quantity .. ", need: " .. quantity .. ")",
            itemId = itemId,
            category = category,
            item = currentItem
        }
    end
    
    -- Store a copy of the item for the result
    local originalItem = table.clone(currentItem)
    
    -- Remove quantity from item
    currentItem.quantity = currentItem.quantity - quantity
    
    -- Remove item entry if quantity is zero
    if currentItem.quantity <= 0 then
        playerInventories[userId][category][itemId] = nil
    end
    
    -- Notify client of inventory change
    InventoryManager.NotifyInventoryChange(player, category)
    
    -- Mark data as dirty for saving
    local playerData = DataService.GetPlayerData(player)
    if playerData and playerData.Inventory then
        playerData.Inventory[category] = playerInventories[userId][category]
        DataService.MarkDataDirty(player.UserId)
    end
    
    return {
        success = true, 
        message = "Item '" .. itemId .. "' removed successfully (quantity: " .. quantity .. ")",
        itemId = itemId,
        category = category,
        item = originalItem
    }
end

-- Check if player has an item
function InventoryManager.HasItem(player: Player, category: string, itemId: string, quantity: number?): (boolean, string?)
    local userId = player.UserId
    if not playerInventories[userId] then 
        return false, "[INVENTORY_ERROR] Inventory not initialized for " .. player.Name .. " (ID: " .. userId .. ")"
    end
    
    -- Verify the category exists
    if playerInventories[userId][category] == nil then
        return false, "[INVENTORY_ERROR] Invalid inventory category: '" .. category .. "'"
    end
    
    quantity = quantity or 1
    
    -- Check if player has the item and enough quantity
    return playerInventories[userId][category][itemId] ~= nil and 
           playerInventories[userId][category][itemId].quantity >= quantity
end

-- Get item metadata
function InventoryManager.GetItemMetadata(player: Player, category: string, itemId: string): MetadataResult
    local userId = player.UserId
    if not playerInventories[userId] then 
        return {
            success = false, 
            message = "[INVENTORY_ERROR] Inventory not initialized for " .. player.Name .. " (ID: " .. userId .. ")"
        }
    end
    
    -- Verify the category exists
    if playerInventories[userId][category] == nil then
        return {
            success = false, 
            message = "[INVENTORY_ERROR] Invalid inventory category: '" .. category .. "' for " .. player.Name,
            category = category
        }
    end
    
    -- Check if player has the item
    if not playerInventories[userId][category][itemId] then
        return {
            success = false, 
            message = "[INVENTORY_ERROR] Item '" .. itemId .. "' not in inventory for " .. player.Name,
            itemId = itemId,
            category = category
        }
    end
    
    -- Return a copy of metadata to prevent external modification
    return {
        success = true,
        metadata = table.clone(playerInventories[userId][category][itemId].metadata or {}),
        message = "Metadata retrieved successfully",
        itemId = itemId,
        category = category
    }
end

-- Update item metadata
function InventoryManager.UpdateItemMetadata(player: Player, category: string, itemId: string, metadata: {[string]: any}?): InventoryResult
    local userId = player.UserId
    if not playerInventories[userId] then 
        return {
            success = false, 
            message = "[INVENTORY_ERROR] Inventory not initialized for " .. player.Name .. " (ID: " .. userId .. ")"
        }
    end
    
    -- Verify the category exists
    if playerInventories[userId][category] == nil then
        return {
            success = false, 
            message = "[INVENTORY_ERROR] Invalid inventory category: '" .. category .. "' for " .. player.Name,
            category = category
        }
    end
    
    -- Check if player has the item
    if not playerInventories[userId][category][itemId] then
        return {
            success = false, 
            message = "[INVENTORY_ERROR] Item '" .. itemId .. "' not in inventory for " .. player.Name,
            itemId = itemId,
            category = category
        }
    end
    
    -- Update metadata
    playerInventories[userId][category][itemId].metadata = metadata or {}
    
    -- Notify client of inventory change
    InventoryManager.NotifyInventoryChange(player, category)
    
    -- Mark data as dirty for saving
    local playerData = DataService.GetPlayerData(player)
    if playerData and playerData.Inventory then
        playerData.Inventory[category] = playerInventories[userId][category]
        DataService.MarkDataDirty(player.UserId)
    end
    
    return {
        success = true, 
        message = "Metadata for '" .. itemId .. "' updated successfully",
        itemId = itemId,
        category = category,
        item = playerInventories[userId][category][itemId]
    }
end

-- Get the entire inventory for a category
function InventoryManager.GetCategoryItems(player: Player, category: string): ({[string]: InventoryItem}?, string?)
    local userId = player.UserId
    if not playerInventories[userId] then 
        return nil, "[INVENTORY_ERROR] Inventory not initialized for " .. player.Name .. " (ID: " .. userId .. ")"
    end
    
    -- Verify the category exists
    if playerInventories[userId][category] == nil then
        return nil, "[INVENTORY_ERROR] Invalid inventory category: '" .. category .. "' for " .. player.Name
    end
    
    -- Return a deep copy to prevent external modification
    local result = {}
    for itemId, itemData in pairs(playerInventories[userId][category]) do
        result[itemId] = table.clone(itemData)
    end
    
    return result
end

-- Notify client of inventory changes
function InventoryManager.NotifyInventoryChange(player: Player, category: string): boolean
    local RemoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
    if not RemoteEvents then
        warn("[INVENTORY_ERROR] RemoteEvents folder not found when trying to notify inventory change for category: " .. category)
        return false
    end
    
    local InventoryChangedEvent = RemoteEvents:FindFirstChild("InventoryChanged")
    if not InventoryChangedEvent then
        warn("[INVENTORY_ERROR] InventoryChanged event not found when trying to notify inventory change")
        return false
    end
    
    -- Get category items
    local items, errorMsg = InventoryManager.GetCategoryItems(player, category)
    if not items then
        warn("[INVENTORY_ERROR] Failed to get category items: " .. (errorMsg or "unknown error"))
        return false
    end
    
    -- Send the entire category to keep client in sync
    local success, err = pcall(function()
        InventoryChangedEvent:FireClient(player, category, items)
    end)
    
    if not success then
        warn("[INVENTORY_ERROR] Failed to notify client of inventory change: " .. tostring(err))
        return false
    end
    
    return true
end

-- Clean up when player leaves
function InventoryManager.CleanupPlayer(player: Player)
    playerInventories[player.UserId] = nil
    print("[INVENTORY_INFO] Cleaned up inventory data for " .. player.Name .. " (ID: " .. player.UserId .. ")")
end

return InventoryManager 