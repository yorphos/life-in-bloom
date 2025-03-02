--[[
    PlayerTypes.lua
    Defines the types and structures for player data
]]

export type PlayerStats = {
    Currency: number,
    PremiumCurrency: number,
    Energy: number,
    MaxEnergy: number,
    EnergyRegenRate: number,
    Happiness: number,
    Hygiene: number,
    Hunger: number
}

export type InventoryItem = {
    quantity: number,
    metadata: {[string]: any}
}

export type PlayerInventory = {
    Furniture: {[string]: InventoryItem},
    Clothing: {[string]: InventoryItem},
    Collectibles: {[string]: InventoryItem},
    Consumables: {[string]: InventoryItem}
}

export type CareerData = {
    Level: number,
    XP: number,
    Unlocks: {[string]: boolean},
    Stats: {
        CompletedJobs: number,
        TotalEarnings: number,
        TimeSpent: number
    }
}

export type PlayerHousing = {
    OwnedPlots: {[string]: boolean},
    Houses: {
        [string]: {
            Furniture: {[string]: any},
            Customization: {[string]: any},
            Layout: {[string]: any}
        }
    }
}

export type PlayerProfile = {
    JoinDate: number,
    LastLogin: number,
    PlayTime: number,
    Settings: {[string]: any},
    SchemaVersion: string
}

export type TransactionRecord = {
    Timestamp: number,
    CurrencyType: string,
    Amount: number,
    TransactionType: string,
    Description: string
}

export type PlayerData = {
    Profile: PlayerProfile,
    Stats: PlayerStats,
    Economy: {
        Transactions: {TransactionRecord}
    },
    Inventory: PlayerInventory,
    Housing: PlayerHousing,
    Careers: {[string]: CareerData},
    Vehicles: {
        OwnedVehicles: {[string]: boolean},
        Customizations: {[string]: any}
    },
    Achievements: {
        Completed: {[string]: boolean},
        Progress: {[string]: number}
    },
    Social: {
        Friends: {[string]: boolean},
        BlockedUsers: {[string]: boolean},
        RecentInteractions: {[string]: number}
    }
}

return {} 