# Life in Bloom - Data Management

## Overview

The data management system is responsible for storing, retrieving, and securing all player and game data in Life in Bloom. This document outlines the data architecture, persistence strategies, and security measures implemented to ensure reliable data handling.

## Data Architecture

### Player Data Model

The player data model is structured hierarchically to organize different aspects of player progress and customization:

```lua
PlayerData = {
    -- Version information for migration
    Version = "1.0.0",
    
    -- Basic player information
    Info = {
        PlayerId = "123456789",
        Username = "PlayerName",
        LastSave = 1645729844,
        TotalPlayTime = 12345,
        JoinDate = 1645729000
    },
    
    -- Progression data
    Progression = {
        Currency = 1000,
        PremiumCurrency = 50,
        Level = 10,
        Experience = 1500,
        Achievements = {
            "first_house",
            "master_chef_level_1"
            -- More achievements...
        }
    },
    
    -- Housing data
    Housing = {
        OwnedProperties = {
            -- Property data
            {
                PropertyId = "house_1",
                Location = Vector3.new(100, 0, 200),
                LastModified = 1645729800,
                Furniture = {
                    -- Furniture items
                    {
                        ItemId = "sofa_red",
                        Position = Vector3.new(1, 0, 2),
                        Rotation = Vector3.new(0, 90, 0),
                        Scale = Vector3.new(1, 1, 1),
                        CustomData = {
                            Color = Color3.fromRGB(255, 0, 0),
                            Material = "fabric"
                        }
                    },
                    -- More furniture...
                }
            }
            -- More properties...
        },
        ActiveProperty = "house_1"
    },
    
    -- Job data
    Jobs = {
        Chef = {
            Level = 5,
            Experience = 750,
            Unlocks = {"recipe_cake", "chef_hat"},
            Stats = {
                MealsCooked = 42,
                PerfectDishes = 12
            }
        },
        TaxiDriver = {
            Level = 3,
            Experience = 450,
            Unlocks = {"taxi_yellow", "driving_glasses"},
            Stats = {
                PassengersDelivered = 28,
                TotalDistance = 1250
            }
        }
        -- More jobs...
    },
    
    -- Vehicle data
    Vehicles = {
        OwnedVehicles = {
            {
                VehicleId = "car_sedan",
                PurchaseDate = 1645729300,
                Customizations = {
                    Color = Color3.fromRGB(0, 0, 255),
                    Decals = {"flame_decal"},
                    Wheels = "sport_rims"
                }
            }
            -- More vehicles...
        },
        ActiveVehicle = "car_sedan"
    },
    
    -- Inventory data
    Inventory = {
        Items = {
            {ItemId = "apple", Quantity = 5, Acquired = 1645729400},
            {ItemId = "hammer", Quantity = 1, Acquired = 1645729500}
            -- More items...
        },
        EquippedItems = {"chef_hat", "apron"},
        Collectibles = {"rare_painting_1", "trophy_cooking"}
    },
    
    -- Social data
    Social = {
        FriendVisits = 12,
        RecentVisitors = {"player123", "player456"},
        Reputation = 85,
        TradeHistory = {
            {
                Partner = "player789",
                Date = 1645729600,
                ItemsGiven = {"apple"},
                ItemsReceived = {"orange"}
            }
            -- More trades...
        }
    },
    
    -- Settings and preferences
    Settings = {
        MusicVolume = 0.8,
        SfxVolume = 1.0,
        UiScale = 1.0,
        NotificationsEnabled = true,
        PrivacySettings = {
            AllowHouseVisits = "friends",
            VisibilityStatus = "online"
        }
    }
}
```

### Game State Data

In addition to player data, the system manages global game state information:

```lua
GameState = {
    -- Server information
    ServerInfo = {
        ServerId = "server_12345",
        Region = "us-east",
        StartTime = 1645729000,
        Version = "1.0.0"
    },
    
    -- Global event data
    Events = {
        ActiveEvents = {"summer_festival", "cooking_competition"},
        EventProgress = {
            summer_festival = {
                StartTime = 1645729000,
                EndTime = 1645815400,
                GlobalProgress = 0.65
            }
            -- More events...
        }
    },
    
    -- Economy data
    Economy = {
        MarketItems = {
            {ItemId = "rare_chair", Price = 500, Stock = 10},
            {ItemId = "luxury_car", Price = 5000, Stock = 3}
            -- More items...
        },
        ItemDemand = {
            -- Historical price data
            rare_chair = {1645729000, 400, 1645730000, 450, 1645731000, 500}
        }
    },
    
    -- World state
    World = {
        Weather = "sunny",
        TimeOfDay = 0.75, -- 0-1 representing day cycle
        ActiveZones = {"downtown", "residential_east", "beach"}
    }
}
```

## Data Persistence

### DataStore Strategy

Life in Bloom uses Roblox's DataStoreService as the primary persistence mechanism. The implementation includes:

#### Primary Player DataStore

```lua
local DataStoreService = game:GetService("DataStoreService")
local PlayerDataStore = DataStoreService:GetDataStore("PlayerData_v1")
```

#### Backup DataStore

```lua
local PlayerDataBackup = DataStoreService:GetDataStore("PlayerData_Backup_v1")
```

#### Specialized DataStores

```lua
local HousingDataStore = DataStoreService:GetDataStore("HousingData_v1")
local GlobalStatsStore = DataStoreService:GetDataStore("GlobalStats_v1")
local LeaderboardStore = DataStoreService:GetOrderedDataStore("Leaderboards_v1")
```

### Save Frequency

The save strategy balances data security with DataStore rate limits:

1. **Automatic periodic saves:**
   - Every 5 minutes during active gameplay
   - Uses a staggered schedule to avoid hitting rate limits

2. **Event-based saves:**
   - After significant transactions (property purchase, job completion)
   - When changing zones or teleporting
   - Upon major achievement unlocks

3. **Exit saves:**
   - When player leaves the game
   - Final comprehensive save with all player data

### Save Process

```lua
function SavePlayerData(player, playerData)
    local success, errorMessage = pcall(function()
        -- Add metadata
        playerData.Info.LastSave = os.time()
        
        -- Generate a unique key based on player ID
        local key = "Player_" .. player.UserId
        
        -- Primary save
        PlayerDataStore:SetAsync(key, playerData)
        
        -- Backup every 3rd save
        if playerData.Info.SaveCount % 3 == 0 then
            PlayerDataBackup:SetAsync(key, playerData)
        end
        
        -- Update player save counter
        playerData.Info.SaveCount = playerData.Info.SaveCount + 1
        
        return true
    end)
    
    if success then
        print("Successfully saved data for player: " .. player.Name)
        return true
    else
        warn("Failed to save data for player: " .. player.Name .. " - Error: " .. errorMessage)
        return false, errorMessage
    end
end
```

### Load Process

```lua
function LoadPlayerData(player)
    local key = "Player_" .. player.UserId
    local data = nil
    local errorMessage = nil
    
    -- Try loading from primary store
    local success, result = pcall(function()
        return PlayerDataStore:GetAsync(key)
    end)
    
    if success and result then
        data = result
    else
        errorMessage = result
        warn("Failed to load primary data for player: " .. player.Name .. " - Error: " .. errorMessage)
        
        -- Try loading from backup store
        local backupSuccess, backupResult = pcall(function()
            return PlayerDataBackup:GetAsync(key)
        end)
        
        if backupSuccess and backupResult then
            data = backupResult
            warn("Successfully loaded backup data for player: " .. player.Name)
        else
            warn("Failed to load backup data for player: " .. player.Name)
        end
    end
    
    -- If we still don't have data, create default data
    if not data then
        data = CreateDefaultPlayerData(player)
        warn("Created default data for new player: " .. player.Name)
    else
        -- Check if data migration is needed
        data = MigratePlayerDataIfNeeded(data)
    end
    
    return data
end
```

### Data Migration

When the data structure changes, migration logic ensures backward compatibility:

```lua
function MigratePlayerDataIfNeeded(data)
    -- Check the version and apply migrations as needed
    if not data.Version then
        -- Very old data, apply initial versioning
        data.Version = "0.5.0"
    end
    
    if data.Version == "0.5.0" then
        -- Migrate from 0.5.0 to 0.6.0
        if not data.Social then
            data.Social = {
                FriendVisits = 0,
                RecentVisitors = {},
                Reputation = 50
            }
        end
        data.Version = "0.6.0"
    end
    
    if data.Version == "0.6.0" then
        -- Migrate from 0.6.0 to 1.0.0
        if not data.Settings then
            data.Settings = {
                MusicVolume = 0.8,
                SfxVolume = 1.0,
                UiScale = 1.0
            }
        end
        data.Version = "1.0.0"
    end
    
    return data
end
```

## Data Security

### Validation Measures

1. **Schema Validation:**
   - All data is validated against a schema before processing
   - Ensures proper types and value ranges

2. **Anti-Exploitation:**
   - Server-side verification of all gameplay actions
   - Rate limiting on actions and transactions
   - Value bounds checking for currency and resources

3. **Data Sanitization:**
   - Filtering of user-generated content
   - Removal of invalid or harmful data structures

### Example Validation Functions

```lua
function ValidateHousingData(housingData)
    -- Validate property data
    if not housingData.OwnedProperties then
        return false, "Missing owned properties"
    end
    
    -- Check each property
    for i, property in ipairs(housingData.OwnedProperties) do
        -- Validate required fields
        if not property.PropertyId then
            return false, "Missing property ID"
        end
        
        -- Validate furniture
        if property.Furniture then
            for j, furniture in ipairs(property.Furniture) do
                -- Check furniture has valid ID
                if not furniture.ItemId then
                    return false, "Missing furniture item ID"
                end
                
                -- Validate position is within property bounds
                if furniture.Position then
                    if math.abs(furniture.Position.X) > MAX_PROPERTY_SIZE or
                       math.abs(furniture.Position.Y) > MAX_PROPERTY_HEIGHT or
                       math.abs(furniture.Position.Z) > MAX_PROPERTY_SIZE then
                        return false, "Furniture position out of bounds"
                    end
                end
            end
        end
    end
    
    return true
end

function ValidateJobData(jobData)
    -- Check for valid job types
    for jobName, job in pairs(jobData) do
        if not VALID_JOB_TYPES[jobName] then
            return false, "Invalid job type: " .. jobName
        end
        
        -- Check level is within valid range
        if job.Level < 1 or job.Level > MAX_JOB_LEVEL then
            return false, "Invalid job level for " .. jobName
        end
        
        -- Validate unlocks
        if job.Unlocks then
            for _, unlock in ipairs(job.Unlocks) do
                if not IsValidUnlock(jobName, unlock) then
                    return false, "Invalid unlock item: " .. unlock
                end
            end
        end
    end
    
    return true
end
```

## Analytics and Monitoring

### Data Collection

The system collects analytics data to monitor game health and player behavior:

1. **Player Metrics:**
   - Session length and frequency
   - Feature engagement rates
   - Progression speed
   - Retention patterns

2. **Economic Metrics:**
   - Currency inflow and outflow
   - Item popularity and usage
   - Transaction patterns
   - Inflation indicators

3. **Performance Metrics:**
   - Save/load success rates
   - DataStore usage and limits
   - Error frequencies
   - Server performance

### DataStore Usage Monitoring

```lua
local DataStoreQuota = {}

function DataStoreQuota.TrackUsage(storeType, operationType)
    if not DataStoreQuota[storeType] then
        DataStoreQuota[storeType] = {
            GetAsync = 0,
            SetAsync = 0,
            RemoveAsync = 0,
            IncrementAsync = 0,
            UpdateAsync = 0
        }
    end
    
    DataStoreQuota[storeType][operationType] = DataStoreQuota[storeType][operationType] + 1
    
    -- Check if approaching limits
    local usageWarningThreshold = 0.8 -- 80% of limit
    local currentUsage = DataStoreQuota[storeType][operationType]
    local operationLimit = GetOperationLimit(operationType)
    
    if currentUsage >= operationLimit * usageWarningThreshold then
        warn("DataStore usage warning: " .. storeType .. " - " .. operationType .. 
              " at " .. math.floor((currentUsage / operationLimit) * 100) .. "% of limit")
    end
end

function GetOperationLimit(operationType)
    -- Return appropriate limits based on operation type
    if operationType == "GetAsync" then
        return 60 -- 60 requests per minute
    elseif operationType == "SetAsync" then
        return 60
    else
        return 30 -- Other operations have stricter limits
    end
end
```

## Disaster Recovery

### Data Backup Strategy

1. **Regular Backups:**
   - Secondary DataStore for complete player data
   - Periodic export of critical data for offline storage

2. **Recovery Procedures:**
   - Automated fallback to backup DataStore
   - Manual restoration tools for admin use
   - Data reconstruction from partial saves

3. **Contingency Planning:**
   - Emergency maintenance protocols
   - Player compensation mechanisms
   - Communication templates for data incidents

### Example Recovery Function

```lua
function AttemptDataRecovery(player)
    local userId = player.UserId
    local recoveryOptions = {
        "main",
        "backup",
        "periodic",
        "legacy",
        "incremental"
    }
    
    local recoveredData = nil
    
    -- Try each recovery option in sequence
    for _, option in ipairs(recoveryOptions) do
        local success, data = pcall(function()
            return LoadDataFromSource(userId, option)
        end)
        
        if success and data then
            print("Successfully recovered data for player " .. player.Name .. " using " .. option .. " recovery")
            recoveredData = data
            break
        end
    end
    
    if recoveredData then
        -- Validate recovered data
        local isValid, errorMessage = ValidatePlayerData(recoveredData)
        
        if isValid then
            return recoveredData
        else
            warn("Recovered data failed validation: " .. errorMessage)
            -- Log the invalid data for further investigation
            LogInvalidRecoveredData(userId, recoveredData, errorMessage)
        end
    end
    
    -- If all recovery options fail, create new data with compensation
    local newData = CreateDefaultPlayerData(player)
    -- Add compensation items/currency
    newData.Progression.Currency = newData.Progression.Currency + 5000 -- Compensation
    newData.Inventory.Items["compensation_package"] = {Quantity = 1}
    
    return newData
end
```

## Best Practices and Guidelines

1. **Data Conservation:**
   - Store only necessary data
   - Use efficient data structures
   - Consider compression for large datasets

2. **Error Handling:**
   - Always use pcall for DataStore operations
   - Implement retry logic with exponential backoff
   - Log detailed error information

3. **Rate Limit Management:**
   - Distribute saves throughout gameplay
   - Prioritize critical data during high traffic
   - Implement queuing for non-urgent operations

4. **Testing and Verification:**
   - Thorough testing of save/load workflows
   - Stress testing under heavy load
   - Simulated failure scenarios

5. **Documentation:**
   - Maintain updated data schema documentation
   - Document migration paths for version changes
   - Clear protocols for data emergencies 