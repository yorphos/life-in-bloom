--[[
    CareersData.luau
    Defines all career options available in the game
]]

-- Career data with standardized economic rewards and varied gameplay attributes
return {
    Chef = {
        id = "Chef",
        name = "Master Chef",
        type = "Creative",
        description = "Create culinary masterpieces in restaurants around town.",
        image = "rbxassetid://12345678",
        levelRequired = 2,
        abilities = {
            "QuickPrep", -- Cook dishes faster
            "RecipeMastery", -- Unlock special recipes 
            "QualityIngredients" -- Use better ingredients for higher quality meals
        },
        gameplay = {
            style = "Rhythm",
            difficulty = "Medium",
            pacing = "Fast"
        }
    },
    
    TaxiDriver = {
        id = "TaxiDriver",
        name = "Taxi Driver",
        type = "Service",
        description = "Transport passengers around the city quickly and safely.",
        image = "rbxassetid://12345679",
        levelRequired = 1,
        abilities = {
            "ShortcutExpert", -- Access special routes
            "SmoothDriver", -- Better vehicle handling
            "CityNavigator" -- Faster route finding
        },
        gameplay = {
            style = "Driving",
            difficulty = "Easy",
            pacing = "Medium"
        }
    },
    
    Programmer = {
        id = "Programmer",
        name = "Software Developer",
        type = "Technical",
        description = "Design and develop software applications and games.",
        image = "rbxassetid://12345680",
        levelRequired = 3,
        abilities = {
            "CleanCoder", -- Fewer bugs in code
            "Optimization", -- Faster program completion
            "AlgorithmMaster" -- Solve complex problems
        },
        gameplay = {
            style = "Puzzle",
            difficulty = "Hard",
            pacing = "Slow"
        }
    },
    
    Doctor = {
        id = "Doctor",
        name = "Medical Doctor",
        type = "Service",
        description = "Diagnose and treat patients in the hospital and clinic.",
        image = "rbxassetid://12345681",
        levelRequired = 5,
        abilities = {
            "QuickDiagnosis", -- Faster identification of patient symptoms
            "SteadyHands", -- Better precision in treatment mini-games
            "BedSideManners" -- Improved patient satisfaction
        },
        gameplay = {
            style = "Precision",
            difficulty = "Hard",
            pacing = "Variable"
        }
    },
    
    Barista = {
        id = "Barista",
        name = "Coffee Artisan",
        type = "Service",
        description = "Create and serve coffee beverages in the town's cafes.",
        image = "rbxassetid://12345682",
        levelRequired = 1,
        abilities = {
            "BeanMastery", -- Better coffee quality
            "MemoryMaster", -- Remember complex orders
            "SpeedBrewing" -- Create drinks faster
        },
        gameplay = {
            style = "Memory",
            difficulty = "Easy",
            pacing = "Fast"
        }
    },
    
    Firefighter = {
        id = "Firefighter",
        name = "Firefighter",
        type = "Service",
        description = "Respond to emergencies and save lives around town.",
        image = "rbxassetid://12345683",
        levelRequired = 3,
        abilities = {
            "RapidResponse", -- Faster movement during emergencies
            "HeatResistance", -- Better endurance in fire scenarios
            "RescueTechniques" -- Special moves for saving NPCs
        },
        gameplay = {
            style = "Action",
            difficulty = "Medium",
            pacing = "Fast"
        }
    },
    
    Mechanic = {
        id = "Mechanic",
        name = "Auto Mechanic",
        type = "Technical",
        description = "Repair and upgrade vehicles at the town garage.",
        image = "rbxassetid://12345684",
        levelRequired = 3,
        abilities = {
            "PrecisionTuning", -- Better accuracy in repair mini-games
            "RapidDiagnostic", -- Faster vehicle problem identification
            "ResourcefulRepairs" -- Creative solutions to complex problems
        },
        gameplay = {
            style = "Puzzle",
            difficulty = "Medium",
            pacing = "Medium"
        }
    },
    
    Architect = {
        id = "Architect",
        name = "Building Architect",
        type = "Technical",
        description = "Design buildings and structures throughout the town.",
        image = "rbxassetid://12345685",
        levelRequired = 7,
        abilities = {
            "PrecisionDesign", -- More accurate building placement
            "MaterialExpertise", -- Better material selection options
            "StructuralVision" -- Ability to see building framework
        },
        gameplay = {
            style = "Design",
            difficulty = "Medium",
            pacing = "Slow"
        }
    },
    
    Electrician = {
        id = "Electrician",
        name = "Master Electrician",
        type = "Technical",
        description = "Install and repair electrical systems in buildings.",
        image = "rbxassetid://12345686",
        levelRequired = 4,
        abilities = {
            "CircuitSense", -- Identify electrical problems faster
            "SafetyExpert", -- Reduced risk in hazardous mini-games
            "PowerEfficiency" -- Optimize electrical systems
        },
        gameplay = {
            style = "Precision",
            difficulty = "Hard",
            pacing = "Medium"
        }
    },
    
    Musician = {
        id = "Musician",
        name = "Professional Musician",
        type = "Creative",
        description = "Perform music at venues around town and create original compositions.",
        image = "rbxassetid://12345687",
        levelRequired = 3,
        abilities = {
            "PerfectPitch", -- Better accuracy in note-matching
            "StagePresence", -- Improved audience satisfaction
            "MusicalMemory" -- Remember longer sequences
        },
        gameplay = {
            style = "Rhythm",
            difficulty = "Variable",
            pacing = "Medium"
        }
    },
    
    Artist = {
        id = "Artist",
        name = "Visual Artist",
        type = "Creative",
        description = "Create paintings and artwork to display and sell around town.",
        image = "rbxassetid://12345688",
        levelRequired = 2,
        abilities = {
            "ColorTheory", -- Better color selection options
            "DetailFocus", -- More precise brush control
            "CreativeVision" -- Unique perspective options
        },
        gameplay = {
            style = "Precision",
            difficulty = "Medium",
            pacing = "Slow"
        }
    },
    
    FashionDesigner = {
        id = "FashionDesigner",
        name = "Fashion Designer",
        type = "Creative",
        description = "Create clothing designs and fashion collections.",
        image = "rbxassetid://12345689",
        levelRequired = 4,
        abilities = {
            "TrendSpotter", -- Early access to popular style options
            "FabricMastery", -- Better control over material options
            "QuickStitching" -- Faster creation of clothing items
        },
        gameplay = {
            style = "Design",
            difficulty = "Medium",
            pacing = "Medium"
        }
    },
    
    StoreManager = {
        id = "StoreManager",
        name = "Retail Manager",
        type = "Management",
        description = "Run a retail store, manage inventory and staff.",
        image = "rbxassetid://12345690",
        levelRequired = 6,
        abilities = {
            "SupplyChainOptimizer", -- Better inventory management
            "CustomerInsight", -- Better prediction of customer needs
            "TeamMotivator" -- Improved staff performance
        },
        gameplay = {
            style = "Strategy",
            difficulty = "Medium",
            pacing = "Medium"
        }
    },
    
    EventPlanner = {
        id = "EventPlanner",
        name = "Event Coordinator",
        type = "Management",
        description = "Organize and execute special events throughout the town.",
        image = "rbxassetid://12345691",
        levelRequired = 5,
        abilities = {
            "VenueVision", -- Better venue selection options
            "DetailOriented", -- Improved event quality
            "CrisisManager" -- Better problem-solving during events
        },
        gameplay = {
            style = "Organization",
            difficulty = "Hard",
            pacing = "Variable"
        }
    },
    
    Mayor = {
        id = "Mayor",
        name = "Town Mayor",
        type = "Management",
        description = "Manage town affairs, make policy decisions, and oversee development.",
        image = "rbxassetid://12345692",
        levelRequired = 10,
        abilities = {
            "PublicSpeaker", -- Better community influence
            "BudgetMaster", -- More efficient resource allocation
            "VisionaryLeader" -- Unique town development options
        },
        gameplay = {
            style = "Strategy",
            difficulty = "Hard",
            pacing = "Slow"
        }
    },
    
    PoliceOfficer = {
        id = "PoliceOfficer",
        name = "Police Officer",
        type = "Service",
        description = "Enforce the law, solve crimes, and keep the town safe.",
        image = "rbxassetid://12345693",
        levelRequired = 4,
        abilities = {
            "EagleEye", -- Better at spotting clues and suspects
            "QuickResponse", -- Faster movement during emergencies
            "Interrogation" -- Extract more information during questioning
        },
        gameplay = {
            style = "Action",
            difficulty = "Medium",
            pacing = "Variable"
        }
    },
    
    Teacher = {
        id = "Teacher",
        name = "Educator",
        type = "Service",
        description = "Teach students and help them develop skills at the town school.",
        image = "rbxassetid://12345694",
        levelRequired = 5,
        abilities = {
            "Inspiration", -- Improve student engagement
            "LessonPlanning", -- Create more effective learning activities
            "PatientExplanation" -- Better at conveying complex information
        },
        gameplay = {
            style = "Memory",
            difficulty = "Medium",
            pacing = "Medium"
        }
    },
    
    RetailWorker = {
        id = "RetailWorker",
        name = "Retail Associate",
        type = "Service",
        description = "Help customers find products and manage store operations.",
        image = "rbxassetid://12345695",
        levelRequired = 1,
        abilities = {
            "ProductKnowledge", -- Better product recommendations
            "DisplayMastery", -- Create more attractive product displays
            "CustomerService" -- Handle customer issues more effectively
        },
        gameplay = {
            style = "Memory",
            difficulty = "Easy",
            pacing = "Medium"
        }
    },
    
    Engineer = {
        id = "Engineer",
        name = "Civil Engineer",
        type = "Technical",
        description = "Design and develop infrastructure projects around town.",
        image = "rbxassetid://12345697",
        levelRequired = 8,
        abilities = {
            "StructuralAnalysis", -- Better problem identification
            "ResourceCalculation", -- More accurate material estimates
            "InnovativeSolutions" -- Create unique project designs
        },
        gameplay = {
            style = "Puzzle",
            difficulty = "Hard",
            pacing = "Slow"
        }
    },
    
    InteriorDecorator = {
        id = "InteriorDecorator",
        name = "Interior Designer",
        type = "Creative",
        description = "Transform spaces with stylish decorations and furniture arrangements.",
        image = "rbxassetid://12345698",
        levelRequired = 4,
        abilities = {
            "StyleVision", -- Better matching of design elements
            "SpacePlanning", -- More effective use of available space
            "ColorCoordination" -- Create harmonious color schemes
        },
        gameplay = {
            style = "Design",
            difficulty = "Medium",
            pacing = "Medium"
        }
    },
    
    TourGuide = {
        id = "TourGuide",
        name = "Tour Guide",
        type = "Management",
        description = "Lead groups through special locations and share knowledge about the town.",
        image = "rbxassetid://12345700",
        levelRequired = 3,
        abilities = {
            "EngagingNarration", -- Better storytelling during tours
            "GroupManagement", -- Keep tour groups organized
            "LocalHistory" -- Access to special historical facts
        },
        gameplay = {
            style = "Memory",
            difficulty = "Medium",
            pacing = "Medium"
        }
    },
    
    HotelManager = {
        id = "HotelManager",
        name = "Hotel Manager",
        type = "Management",
        description = "Run a successful hotel, manage staff, and ensure guest satisfaction.",
        image = "rbxassetid://12345701",
        levelRequired = 8,
        abilities = {
            "HospitalityExpert", -- Improve guest satisfaction
            "StaffCoordination", -- Better employee management
            "AmenityPlanning" -- Optimize hotel features and services
        },
        gameplay = {
            style = "Strategy",
            difficulty = "Hard",
            pacing = "Slow"
        }
    },
    
    RealEstateAgent = {
        id = "RealEstateAgent",
        name = "Real Estate Agent",
        type = "Management",
        description = "Help players find and purchase properties around town.",
        image = "rbxassetid://12345702",
        levelRequired = 5,
        abilities = {
            "PropertyValuation", -- Better at estimating property value
            "MarketingExpertise", -- Create more attractive property listings
            "NegotiationMastery" -- Close deals more effectively
        },
        gameplay = {
            style = "Organization",
            difficulty = "Medium",
            pacing = "Medium"
        }
    }
} 