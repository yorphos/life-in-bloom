--[[
    Constants.lua
    Game-wide constants and configuration values
]]

local Constants = {}

-- Data Store Constants
Constants.DATA_STORE = {
    STORE_NAME = "PlayerData_v1",
    BACKUP_STORE_NAME = "PlayerData_Backup_v1",
    AUTO_SAVE_INTERVAL = 300, -- 5 minutes
    MAX_DATA_SIZE = 4000000, -- ~4MB in bytes
    SHARD_STORE_PREFIX = "PlayerShard_v1_",
}

-- Player Stats Constants
Constants.PLAYER_STATS = {
    DEFAULT_ENERGY = 100,
    DEFAULT_MAX_ENERGY = 100,
    DEFAULT_ENERGY_REGEN_RATE = 1,
    DEFAULT_HAPPINESS = 100,
    DEFAULT_HYGIENE = 100,
    DEFAULT_HUNGER = 100,
    DEFAULT_STARTING_CURRENCY = 100,
    DEFAULT_STARTING_PREMIUM_CURRENCY = 0,
}

-- Career Constants
Constants.CAREERS = {
    XP_MULTIPLIER = 1.5, -- Experience scaling factor between levels
    BASE_XP_REQUIREMENT = 100, -- XP needed for first level
    MAX_LEVEL = 50, -- Maximum level for careers
}

-- Transaction Types
Constants.TRANSACTION_TYPES = {
    PURCHASE = "purchase",
    SALE = "sale",
    JOB_INCOME = "job_income",
    ADMIN_GRANT = "admin_grant",
}

-- Security Constants
Constants.SECURITY = {
    VELOCITY_THRESHOLD = 100, -- Maximum allowed velocity magnitude
    POSITION_DELTA_THRESHOLD = 50, -- Maximum allowed position change per check
    SUSPICIOUS_ACTIVITY_THRESHOLD = 5, -- Number of violations before action
    CHECK_INTERVAL = 1, -- Seconds between checks
}

return Constants 