# Life in Bloom – MVP Phase

## Table of Contents

1. [MVP Overview](#mvp-overview)
2. [Core Features](#core-features)
3. [Technical Foundation](#technical-foundation)
4. [Sprint Breakdown](#sprint-breakdown)
5. [Acceptance Criteria](#acceptance-criteria)
6. [Testing Strategy](#testing-strategy)

---

## MVP Overview

The Minimum Viable Product (MVP) phase focuses on implementing the core gameplay systems and features necessary to create a playable prototype of Life in Bloom. This phase will establish the technical foundation, implement basic versions of key gameplay mechanics, and create a small but functional game world.

**Duration:** 8 weeks (4 two-week sprints)  
**Team Size:** 3 developers, 2 artists, 1 designer, 1 part-time QA tester

**MVP Goals:**

- Implement core gameplay systems (building, jobs, vehicles, progression)
- Create a small but functional open world
- Establish the technical architecture and data persistence
- Develop 2-3 job types with basic mini-games
- Create a playable experience that demonstrates the game's potential

---

## Core Features

### 1. Building System

**MVP Scope:**

- Basic house building with grid-based placement
- Limited furniture catalog (20-30 essential items)
- Simple customization options (colors, basic textures)
- Ability to save and load house layouts
- Functional furniture items (beds, chairs, tables, appliances)

**Out of Scope for MVP:**

- Advanced placement options (rotation, scaling)
- Extensive furniture catalog
- Complex customization (patterns, materials)
- Multi-floor buildings
- Terrain modification

### 2. Job System

**MVP Scope:**

- 2-3 job types (Chef, Taxi Driver, Police Officer)
- Basic mini-games for each job
- Simple progression system (XP and levels)
- Job-specific rewards and unlocks
- Job switching functionality

**Out of Scope for MVP:**

- Advanced mini-games with multiple variations
- Full job catalog (remaining 7-8 jobs)
- Job-specific vehicles and tools
- Special missions and events

### 3. Vehicle System

**MVP Scope:**

- 1-2 basic vehicle types (car, bicycle)
- Simple driving mechanics
- Basic collision and physics
- Vehicle spawning and despawning
- Rudimentary customization (colors)

**Out of Scope for MVP:**

- Advanced vehicle physics
- Full vehicle catalog
- Extensive customization options
- Vehicle ownership and garage system
- Special vehicle abilities

### 4. World Design

**MVP Scope:**

- Small open world with 3 key zones:
  - Residential area (player homes)
  - Commercial district (jobs and shops)
  - Social hub (central meeting area)
- Basic NPC population
- Day/night cycle
- Simple navigation system

**Out of Scope for MVP:**

- Full-sized world with all planned zones
- Dynamic weather system
- Seasonal changes
- Special event areas
- Complex NPC behaviors

### 5. UI/UX

**MVP Scope:**

- Main HUD with essential information
- Build mode interface
- Job selection and progress UI
- Basic inventory system
- Settings menu
- Tutorial prompts

**Out of Scope for MVP:**

- Advanced customization interfaces
- Social and trading UI
- Comprehensive achievement tracking
- Detailed statistics and progress visualization

### 6. Progression System

**MVP Scope:**

- Basic XP and leveling for jobs
- Simple daily quests
- Core achievements
- Currency earning and spending

**Out of Scope for MVP:**

- Complex achievement trees
- Seasonal progression
- Collections and special rewards
- Reputation systems

---

## Technical Foundation

### Data Architecture

- Player data structure with essential categories
- Basic data persistence using DataStoreService
- Auto-save functionality
- Data validation and error handling

### Core Systems

- Server-client communication framework
- Remote event structure for key actions
- Asset loading and management system
- Performance monitoring tools

### Development Infrastructure

- Version control setup
- Basic testing framework
- Development, staging, and production environments
- Bug tracking system

---

## Sprint Breakdown

### Sprint 1: Technical Foundation (Weeks 1-2)

**Focus:** Establish core architecture and basic world

**Key Deliverables:**

- Project structure and coding standards
- Basic player movement and camera controls
- Simple open world with placeholder zones
- Data persistence framework
- Server-client communication system
- Initial UI framework

**Technical Tasks:**

- Set up project in Roblox Studio with proper organization
- Implement player controller with basic movement
- Create simple terrain and zone boundaries
- Develop data service for saving/loading
- Establish remote event system for client-server communication
- Create UI framework with main HUD elements

**Art Tasks:**

- Basic character models
- Simple environment assets
- Placeholder UI elements

**End of Sprint Goal:** Players can move around a simple world with persistent data saving.

### Sprint 2: Building System (Weeks 3-4)

**Focus:** Implement house building and customization

**Key Deliverables:**

- Grid-based building system
- Basic furniture placement
- Simple customization options
- House saving and loading
- Build mode UI

**Technical Tasks:**

- Develop grid system for placement
- Implement furniture placement logic
- Create customization system for colors and textures
- Build save/load functionality for houses
- Develop build mode UI with catalog and controls

**Art Tasks:**

- Basic furniture models (20-30 items)
- Textures for walls, floors, and furniture
- Build mode UI elements

**End of Sprint Goal:** Players can build and customize simple houses with basic furniture.

### Sprint 3: Job System (Weeks 5-6)

**Focus:** Implement initial jobs and progression

**Key Deliverables:**

- 2-3 job types with locations
- Basic mini-games for each job
- Job progression system
- Currency and rewards
- Job UI

**Technical Tasks:**

- Develop job framework with progression tracking
- Implement Chef mini-game (cooking puzzle)
- Create Taxi Driver gameplay (passenger delivery)
- Build Police Officer activities (simple patrol and response)
- Implement currency system and rewards
- Develop job selection and progress UI

**Art Tasks:**

- Job-specific locations and props
- Mini-game UI elements
- Job uniforms and icons

**End of Sprint Goal:** Players can take on jobs, complete mini-games, earn currency, and progress through job levels.

### Sprint 4: Vehicles & Integration (Weeks 7-8)

**Focus:** Add vehicles and integrate all systems

**Key Deliverables:**

- Basic vehicle system
- System integration
- Performance optimization
- Bug fixes
- Tutorial and onboarding

**Technical Tasks:**

- Implement vehicle controls and physics
- Create vehicle spawning system
- Integrate all systems (building, jobs, vehicles)
- Optimize performance for target devices
- Fix critical bugs
- Implement basic tutorial and onboarding

**Art Tasks:**

- Vehicle models and textures
- Tutorial UI elements
- Final polish on existing assets

**End of Sprint Goal:** Complete MVP with all core systems working together, ready for initial testing.

---

## Acceptance Criteria

### Building System

- [x] Players can place furniture on a grid system
- [x] At least 20 furniture items are available
- [x] Players can change colors of walls, floors, and furniture
- [x] Houses can be saved and loaded correctly
- [x] Build mode UI is intuitive and functional

### Job System

- [x] 3 job types are implemented with unique gameplay
- [x] Jobs award XP and currency based on performance
- [x] Players can level up jobs to unlock rewards
- [x] Job locations are properly set up in the world
- [x] Job UI clearly shows progress and available jobs

### Vehicle System

- [x] Players can spawn and drive at least 2 vehicle types
- [x] Vehicle controls are responsive and intuitive
- [x] Collision detection works properly
- [x] Vehicles can navigate the world without major issues
- [x] Basic vehicle customization (colors) is functional

### World Design

- [x] 3 distinct zones are implemented with appropriate aesthetics
- [x] World size is appropriate for the MVP scope
- [x] Day/night cycle functions correctly
- [x] NPCs populate the world appropriately
- [x] Navigation between zones is clear and intuitive

### Technical Requirements

- [x] Game runs at minimum 30 FPS on target devices
- [x] Data saving/loading works reliably without corruption
- [x] No critical bugs that prevent core gameplay
- [x] Server-client communication is stable
- [x] Memory usage remains within acceptable limits

## Post-MVP Implementation Priorities

### Short-term (1-3 months post-launch)

#### Performance Optimization

- [ ] Implement basic Level of Detail (LOD) system for high-polygon assets
- [ ] Add priority-based asset loading for essential vs. decorative items
- [ ] Optimize memory management with object pooling for frequent objects
- [ ] Implement basic occlusion culling for complex interiors

#### UI/UX Improvements

- [ ] Enhance tutorial based on initial player feedback
- [ ] Add contextual help for complex features
- [ ] Improve navigation and wayfinding in the game world
- [ ] Refine control schemes based on player feedback

#### Bug Fixes and Stability

- [ ] Address critical bugs identified during initial release
- [ ] Improve error handling and recovery
- [ ] Enhance data backup and recovery systems
- [ ] Optimize network code for better stability

#### Initial Content Expansion

- [ ] Add 1-2 new job types based on player demand
- [ ] Expand furniture catalog with themed collections
- [ ] Add more vehicle customization options
- [ ] Introduce first seasonal event

---

## Testing Strategy

### Internal Testing

- Daily developer playtests during implementation
- Weekly team-wide playtest sessions
- Bug tracking and prioritization
- Performance monitoring on target devices

### QA Testing

- Focused testing on each core system
- Integration testing across systems
- Edge case identification and testing
- Regression testing after bug fixes

### User Testing

- Small group of testers (5-10) at end of MVP phase
- Guided testing sessions with specific tasks
- Feedback collection via surveys and interviews
- Usability observation and analysis

### Performance Testing

- FPS monitoring across different scenarios
- Memory usage tracking
- Network traffic analysis
- Load testing with simulated players
