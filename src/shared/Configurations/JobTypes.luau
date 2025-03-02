--[[
    JobTypes.lua
    Configuration for all available job types in the game
]]

local JobTypes = {
    {
        id = "chef",
        name = "Chef",
        description = "Create delicious meals in restaurants",
        icon = "rbxassetid://123456789", -- Placeholder asset ID
        baseIncome = 25,
        baseXP = 20,
        energyCost = 10,
        locations = {"Restaurant", "Cafe", "Hotel"},
        skills = {"Cooking", "Creativity", "Speed"}
    },
    {
        id = "doctor",
        name = "Doctor",
        description = "Treat patients and save lives",
        icon = "rbxassetid://123456790", -- Placeholder asset ID
        baseIncome = 50,
        baseXP = 30,
        energyCost = 15,
        locations = {"Hospital", "Clinic"},
        skills = {"Intelligence", "Focus", "Caregiving"}
    },
    {
        id = "builder",
        name = "Builder",
        description = "Construct and improve buildings",
        icon = "rbxassetid://123456791", -- Placeholder asset ID
        baseIncome = 30,
        baseXP = 25,
        energyCost = 20,
        locations = {"Construction Site", "Residential Area"},
        skills = {"Strength", "Precision", "Planning"}
    },
    {
        id = "driver",
        name = "Driver",
        description = "Transport people and goods across town",
        icon = "rbxassetid://123456792", -- Placeholder asset ID
        baseIncome = 20,
        baseXP = 15,
        energyCost = 8,
        locations = {"City Streets", "Highway"},
        skills = {"Driving", "Navigation", "Patience"}
    }
}

local function GetJobById(jobId)
    for _, job in ipairs(JobTypes) do
        if job.id == jobId then
            return job
        end
    end
    return nil
end

return {
    JobTypes = JobTypes,
    GetJobById = GetJobById
} 