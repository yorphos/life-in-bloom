# Life in Bloom - Technical Architecture

## System Overview

Life in Bloom uses a client-server architecture built on the Roblox platform. The system is designed with modularity, performance, and security as key considerations.

## Client-Server Architecture

The game architecture is divided into distinct client and server components:

### Server-Side Components

- **Authoritative game logic:** All critical game systems run on the server
- **Data persistence:** Manages saving and loading player data
- **Security validation:** Validates all client actions to prevent exploits
- **World management:** Controls NPC behavior, events, and world state

### Client-Side Components

- **User interface:** Manages all UI elements and player input
- **Visual effects:** Handles visual feedback and animations
- **Input handling:** Processes player controls and interactions
- **Predictive movement:** Provides responsive movement with server verification

### Shared Modules

- **Common utilities:** Functions used by both client and server
- **Configuration values:** Game settings and constants
- **Type definitions:** Shared data structures and types

## Core Systems

### Game Data System

The game data system centralizes management of all static game information:

- **GameDataService (Server):** Authoritative source for all static game data
  - Loads and validates data from ModuleScripts
  - Provides secure access to data via RemoteFunctions
  - Handles caching and optimization of frequently accessed data
  - Manages tiered access based on player permissions

- **GameDataController (Client):** Client-side interface for accessing game data
  - Provides a clean API for UI components
  - Implements client-side caching to minimize network requests
  - Maintains synchronization with server-side data

- **Data Categories:**
  - Careers and jobs information
  - Items and inventory definitions
  - Housing and furniture catalogs
  - Vehicle specifications
  - Game settings and configurations

### Building System

The house building system allows players to create and customize their homes:

- **Placement Engine:** Handles collision detection, snapping, and validation
- **Furniture Database:** Manages available items and their properties
- **Save/Load System:** Serializes house layouts for storage in DataStore
- **Customization Manager:** Controls textures, colors, and decoration options

### Job System

The job system manages player careers and progression:

- **Job Manager:** Controls job switching, status, and availability across all career types
- **Mini-Game Framework:** Provides foundation for diverse job-specific gameplay mechanics:
  - Rhythm-based (Chef, Musician)
  - Precision-based (Doctor, Electrician)
  - Puzzle-solving (Mechanic, Programmer, Engineer)
  - Driving simulation (Taxi Driver)
  - Memory challenges (Barista, Teacher, Tour Guide)
  - Action sequences (Firefighter, Police Officer)
  - Design interfaces (Architect, Fashion Designer, Interior Decorator)
  - Strategy management (Store Manager, Mayor, Hotel Manager)
  - Organizational tasks (Event Planner, Real Estate Agent, Retail Worker)
  - Creative expression (Artist)
- **Unified Progression System:** Ensures all careers follow identical XP requirements and reward structures
- **Career-Specific Abilities:** Manages unique gameplay mechanics for each career that differentiate the experience without affecting economic balance
- **Standardized Activity Framework:** Common structure for all job activities that ensures consistent reward calculations across career types

### Vehicle System

The vehicle system enables player transportation and exploration:

- **Vehicle Physics:** Controls movement, collision, and handling
- **Customization System:** Manages visual modifications and upgrades
- **Ownership Manager:** Tracks vehicle ownership and permissions
- **Spawn Controller:** Handles vehicle spawning and despawning

### World Management System

The world management system controls the game environment:

- **Zone Manager:** Handles different areas of the map and their properties
- **Weather System:** Controls environmental effects and day/night cycle
- **Event Scheduler:** Manages timed events and special activities
- **NPC Controller:** Directs non-player character behavior and interactions

### Social System

The social system facilitates player interactions:

- **Friend Manager:** Integrates with Roblox's friend system
- **Party System:** Allows players to form groups for activities
- **Trading Framework:** Enables secure item exchange between players
- **Communication Tools:** Provides chat and interaction mechanisms

## Data Management

### Player Data Structure

Player data is organized into distinct categories:

```lua
PlayerData = {
    -- Basic player information
    Info = {
        PlayerId = "123456789",
        Username = "PlayerName",
        LastSave = 1645729844,
        TotalPlayTime = 12345
    },
    
    -- Progression data
    Progression = {
        Currency = 1000,
        PremiumCurrency = 50,
        Level = 10,
        Experience = 1500
    },
    
    -- House data
    Housing = {
        OwnedProperties = {
            -- Property data
            {
                PropertyId = "house_1",
                Location = Vector3.new(100, 0, 200),
                Furniture = {
                    -- Furniture items
                    {
                        ItemId = "sofa_red",
                        Position = Vector3.new(1, 0, 2),
                        Rotation = Vector3.new(0, 90, 0),
                        CustomData = {
                            Color = Color3.fromRGB(255, 0, 0)
                        }
                    },
                    -- More furniture...
                }
            }
            -- More properties...
        }
    },
    
    -- Job data
    Jobs = {
        Chef = {
            Level = 5,
            Experience = 750,
            Unlocks = {"recipe_cake", "chef_hat"}
        },
        TaxiDriver = {
            Level = 3,
            Experience = 450,
            Unlocks = {"taxi_yellow", "driving_glasses"}
        }
        -- More jobs...
    },
    
    -- Vehicle data
    Vehicles = {
        OwnedVehicles = {
            {
                VehicleId = "car_sedan",
                Customizations = {
                    Color = Color3.fromRGB(0, 0, 255),
                    Decals = {"flame_decal"}
                }
            }
            -- More vehicles...
        },
        ActiveVehicle = "car_sedan"
    },
    
    -- Inventory data
    Inventory = {
        Items = {
            {ItemId = "apple", Quantity = 5},
            {ItemId = "hammer", Quantity = 1}
            -- More items...
        },
        EquippedItems = {"chef_hat", "apron"}
    },
    
    -- Settings and preferences
    Settings = {
        MusicVolume = 0.8,
        SfxVolume = 1.0,
        UiScale = 1.0
    }
}
```

### Data Persistence

Player data is saved and loaded using Roblox's DataStoreService:

- **Auto-Save:** Player data is automatically saved at regular intervals (every 3-5 minutes)
- **Manual Save:** Data is saved when players perform significant actions (buying property, completing job)
- **Save on Exit:** Data is saved when players leave the game
- **Backup System:** Multiple backup slots are maintained to prevent data loss
- **Data Versioning:** Version numbers are included to handle data format changes

### Security Measures

To maintain game integrity and prevent exploits:

- **Server Authority:** All critical actions are validated on the server
- **Rate Limiting:** Actions are rate-limited to prevent spam or DoS attacks
- **Data Validation:** All incoming data is validated before processing
- **Anti-Cheat Measures:** Detection systems monitor for suspicious behavior
- **Secure RemoteEvents:** All client-server communication uses secure patterns

## Performance Optimization

### Client-Side Optimization

- **Asset Streaming:** Load assets dynamically based on player proximity
- **Level of Detail:** Use simplified models for distant objects
- **Effect Throttling:** Reduce visual effects during performance drops
- **Memory Management:** Properly destroy unused objects and disconnect events

### Server-Side Optimization

- **Zone-Based Processing:** Only update entities near players
- **Efficient DataStore Usage:** Minimize API calls and batch operations
- **Task Scheduling:** Distribute heavy computations across multiple frames
- **Instance Pooling:** Reuse common instances instead of creating new ones

## Server Infrastructure

### Instance Management

- **Player Capacity:** Target 20-50 players per server
- **Server Regions:** Deploy to multiple regions for global coverage
- **Instance Balancing:** Distribute players to maintain optimal server loads

### Teleportation System

- **Zone Transitions:** Use TeleportService for seamless transitions between areas
- **Party Teleportation:** Allow groups to teleport together
- **Reserved Servers:** Create private instances for special events

## Network Communication

### RemoteEvent Patterns

- **Command Pattern:** Client sends action request, server validates and executes
- **Notification Pattern:** Server informs clients of world changes
- **Query Pattern:** Client requests data, server responds with information

### Data Synchronization

- **Initial State:** Send complete state on player join
- **Delta Updates:** Send only changed data during gameplay
- **Entity Interpolation:** Smooth movement of remote entities
- **Prediction and Reconciliation:** Handle client-side prediction with server correction

## Debugging and Monitoring

### Logging System

- **Error Logging:** Capture and report errors to diagnostics
- **Performance Metrics:** Track frame rates, memory usage, and network activity
- **Player Statistics:** Monitor engagement, progression, and activity patterns

### Developer Tools

- **Debug Mode:** Special tools and visualizations for developers
- **Command Console:** Admin commands for testing and troubleshooting
- **Analytics Dashboard:** Real-time monitoring of game metrics

## Future Technical Considerations

- **Cross-Platform Support:** Ensure compatibility with mobile devices
- **Voice Chat Integration:** Implement proximity voice chat for 13+ players
- **Cloud Save Integration:** Explore additional backup and synchronization options
- **Machine Learning Analytics:** Implement advanced player behavior analysis
- **Content Delivery Optimization:** Improve asset streaming and caching 