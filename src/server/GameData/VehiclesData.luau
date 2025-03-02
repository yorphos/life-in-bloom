--[[
    VehiclesData.luau
    Defines all vehicles available in the game
]]

return {
    sedan_basic = {
        id = "sedan_basic",
        name = "Basic Sedan",
        description = "An affordable and reliable car for everyday use.",
        category = "Cars",
        value = 5000,
        image = "rbxassetid://12345684",
        model = "rbxassetid://9876545",
        stats = {
            Speed = 50,
            Acceleration = 40,
            Handling = 60
        },
        levelRequired = 2
    },
    taxi = {
        id = "taxi",
        name = "Taxi",
        description = "A yellow taxi cab. Perfect for the taxi driver career.",
        category = "Cars",
        value = 7500,
        image = "rbxassetid://12345685",
        model = "rbxassetid://9876546",
        stats = {
            Speed = 55,
            Acceleration = 50,
            Handling = 65
        },
        levelRequired = 1,
        careerRestriction = "TaxiDriver"
    },
    sports_car = {
        id = "sports_car",
        name = "Sports Car",
        description = "A high-performance sports car with excellent speed and handling.",
        category = "Cars",
        value = 25000,
        image = "rbxassetid://12345686",
        model = "rbxassetid://9876547",
        stats = {
            Speed = 90,
            Acceleration = 85,
            Handling = 80
        },
        levelRequired = 10
    }
    -- Add more vehicles here as needed
} 