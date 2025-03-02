--[[
    FurnitureData.luau
    Defines all furniture available in the game
]]

return {
    sofa_red = {
        id = "sofa_red",
        name = "Red Sofa",
        description = "A comfortable red sofa for your living room.",
        category = "Seating",
        value = 250,
        image = "rbxassetid://12345682",
        model = "rbxassetid://9876543",
        comfort = 75,
        size = {x = 3, y = 1, z = 1}
    },
    table_wood = {
        id = "table_wood",
        name = "Wooden Table",
        description = "A sturdy wooden table for dining or working.",
        category = "Tables",
        value = 150,
        image = "rbxassetid://12345683",
        model = "rbxassetid://9876544",
        size = {x = 2, y = 1, z = 2}
    },
    bed_single = {
        id = "bed_single",
        name = "Single Bed",
        description = "A comfortable single bed for one person.",
        category = "Bedroom",
        value = 300,
        image = "rbxassetid://12345684",
        model = "rbxassetid://9876545",
        comfort = 80,
        energyRegen = 10,
        size = {x = 3, y = 1, z = 2}
    }
    -- Add more furniture here as needed
} 