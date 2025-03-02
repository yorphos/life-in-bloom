--[[
    ItemsData.luau
    Defines all items available in the game
]]

return {
    apple = {
        id = "apple",
        name = "Apple",
        description = "A fresh, juicy apple that restores a small amount of energy.",
        category = "Food",
        value = 5,
        image = "rbxassetid://12345679",
        effects = {
            Energy = 10,
            Hunger = 15
        }
    },
    hammer = {
        id = "hammer",
        name = "Hammer",
        description = "A basic tool for home repairs and building projects.",
        category = "Tools",
        value = 25,
        image = "rbxassetid://12345680",
        durability = 100
    },
    chef_hat = {
        id = "chef_hat",
        name = "Chef's Hat",
        description = "A professional chef's hat. Increases cooking quality when worn.",
        category = "Clothing",
        value = 75,
        image = "rbxassetid://12345681",
        bonuses = {
            CookingQuality = 10
        }
    }
    -- Add more items here as needed
} 