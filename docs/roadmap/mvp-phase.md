# Life in Bloom – MVP Phase

## Table of Contents

1. [MVP Overview](#mvp-overview)
2. [Core Features](#core-features)
3. [Technical Foundation](#technical-foundation)
4. [Sprint Breakdown](#sprint-breakdown)
5. [Acceptance Criteria](#acceptance-criteria)
6. [Testing Strategy](#testing-strategy)
7. [System Integration](#system-integration)
8. [User Experience Iteration](#user-experience-iteration)

---

## MVP Overview

The Minimum Viable Product (MVP) phase focuses on implementing the core gameplay systems and features necessary to create a playable prototype of Life in Bloom. This phase will establish the technical foundation, implement basic versions of key gameplay mechanics, and create a small but functional game world.

**Duration:** 10-12 weeks (5-6 two-week sprints)  
**Team Size:** 1 solo developer handling all aspects of development

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
- Limited furniture catalog (15-20 essential items)
- Simple customization options (colors, basic textures)
- Ability to save and load house layouts
- Functional furniture items (beds, chairs, tables, appliances)

**Simplified MVP Approach:**

- Focus on single-room construction initially rather than full houses
- Implement a "room template" system with pre-configured layouts that can be customized
- Limit furniture placement to predefined slots in early versions
- Prioritize visual appeal and basic functionality over complex customization

**Out of Scope for MVP:**

- Advanced placement options (rotation, scaling)
- Extensive furniture catalog
- Complex customization (patterns, materials)
- Multi-floor buildings
- Terrain modification

_Note: These out-of-scope items may be revisited in future updates post-launch._

### 2. Job System

**MVP Scope:**

- 2-3 job types (Chef, Taxi Driver, Police Officer)
- Basic mini-games for each job
- Simple progression system (XP and levels)
- Job-specific rewards and unlocks
- Job switching functionality

**Simplified MVP Approach:**

- Start with just 2 job types that demonstrate different gameplay styles
- Create "toy versions" of job mini-games with core mechanics only
- Implement a unified progression system that works across all jobs
- Focus on making each job feel distinct and engaging rather than complex

**Out of Scope for MVP:**

- Advanced mini-games with multiple variations
- Full job catalog (remaining 7-8 jobs)
- Job-specific vehicles and tools
- Special missions and events

_Note: These out-of-scope items may be revisited in future updates post-launch._

### 3. Vehicle System

**MVP Scope:**

- 1-2 basic vehicle types (car, bicycle)
- Simple driving mechanics
- Basic collision and physics
- Vehicle spawning and despawning
- Rudimentary customization (colors)

**Simplified MVP Approach:**

- Start with a single vehicle type with polished controls
- Focus on making the driving experience smooth and enjoyable
- Implement simplified physics that prioritize fun over realism
- Create a basic garage system for vehicle storage and retrieval

**Out of Scope for MVP:**

- Advanced vehicle physics
- Full vehicle catalog
- Extensive customization options
- Vehicle ownership and garage system
- Special vehicle abilities

_Note: These out-of-scope items may be revisited in future updates post-launch._

### 4. World Design

**MVP Scope:**

- Small open world with 3 key zones:
  - Residential area (player homes)
  - Commercial district (jobs and shops)
  - Social hub (central meeting area)
- Basic NPC population
- Day/night cycle
- Simple navigation system

**Simplified MVP Approach:**

- Create a compact world layout that minimizes travel time between key areas
- Use environmental storytelling to make the world feel alive with fewer assets
- Implement a simplified NPC system with scheduled behaviors
- Focus on visual polish in high-traffic areas

**Out of Scope for MVP:**

- Full-sized world with all planned zones
- Dynamic weather system
- Seasonal changes
- Special event areas
- Complex NPC behaviors

_Note: These out-of-scope items may be revisited in future updates post-launch._

### 5. UI/UX

**MVP Scope:**

- Main HUD with essential information
- Build mode interface
- Job selection and progress UI
- Basic inventory system
- Settings menu
- Tutorial prompts

**Simplified MVP Approach:**

- Design a minimalist UI that focuses on core functionality
- Implement contextual controls that appear only when needed
- Create a unified style guide for consistent visual language
- Prioritize readability and ease of use over visual complexity

**Out of Scope for MVP:**

- Advanced customization interfaces
- Social and trading UI
- Comprehensive achievement tracking
- Detailed statistics and progress visualization

_Note: These out-of-scope items may be revisited in future updates post-launch._

### 6. Progression System

**MVP Scope:**

- Basic XP and leveling for jobs
- Simple daily quests
- Core achievements
- Currency earning and spending

**Simplified MVP Approach:**

- Create a unified progression system that works across all game activities
- Implement a small set of meaningful rewards that impact gameplay
- Design a simple economy with clear value propositions
- Focus on short-term goals that provide regular satisfaction

**Out of Scope for MVP:**

- Complex achievement trees
- Seasonal progression
- Collections and special rewards
- Reputation systems

_Note: These out-of-scope items may be revisited in future updates post-launch._

---

## Technical Foundation

### Data Architecture

- Player data structure with essential categories
- Basic data persistence using DataStoreService
- Auto-save functionality
- Data validation and error handling
- Backup and recovery systems for critical data

### Core Systems

- Server-client communication framework
- Remote event structure for key actions
- Asset loading and management system
- Performance monitoring tools
- Error logging and reporting

### Development Infrastructure

- Version control setup
- Basic testing framework
- Development, staging, and production environments
- Bug tracking system
- Automated build and deployment process

### Roblox Platform Considerations

- DataStore rate limit management
  - Batched saving for non-critical data
  - Priority queue for important updates
  - Fallback mechanisms for throttling scenarios
- Asset streaming optimization
  - Distance-based loading
  - Priority-based asset streaming
  - LOD system for complex objects
- Server resource management
  - Efficient heartbeat usage
  - Task scheduling for heavy operations
  - Memory usage optimization

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
- Create basic character models
- Design simple environment assets
- Create placeholder UI elements

**End of Sprint Goal:** Players can move around a simple world with persistent data saving.

### Sprint 2: Building System (Weeks 3-4)

**Focus:** Implement house building and customization

**Key Deliverables:**

- Grid-based building system
- Basic furniture placement
- Simple customization options
- House saving and loading
- Build mode UI

**Art Tasks:**

- Develop grid system for placement
- Implement furniture placement logic
- Create customization system for colors and textures
- Build save/load functionality for houses
- Develop build mode UI with catalog and controls
- Create basic furniture models (15-20 items)
- Design textures for walls, floors, and furniture
- Create build mode UI elements

**End of Sprint Goal:** Players can build and customize simple houses with basic furniture.

### Sprint 3: Job System (Weeks 5-6)

**Focus:** Implement initial jobs and progression

**Key Deliverables:**

- 2 job types with locations
- Basic mini-games for each job
- Job progression system
- Currency and rewards
- Job UI

**Tasks:**

- Develop job framework with progression tracking
- Implement Chef mini-game (cooking puzzle)
- Create Taxi Driver gameplay (passenger delivery)
- Implement currency system and rewards
- Develop job selection and progress UI
- Create job-specific locations and props
- Design mini-game UI elements
- Create job uniforms and icons

**End of Sprint Goal:** Players can take on jobs, complete mini-games, earn currency, and progress through job levels.

### Sprint 4: Vehicles & Basic Integration (Weeks 7-8)

**Focus:** Add vehicles and begin system integration

**Key Deliverables:**

- Basic vehicle system
- Initial system integration
- Performance optimization
- Bug fixes
- Tutorial and onboarding

**Tasks:**

- Implement vehicle controls and physics
- Create vehicle spawning system
- Begin integration of building and job systems
- Optimize performance for target devices
- Fix critical bugs
- Implement basic tutorial and onboarding
- Create vehicle models and textures
- Design tutorial UI elements
- Apply final polish on existing assets

**End of Sprint Goal:** Players can drive vehicles and experience basic integration between systems.

### Sprint 5: Full Integration & Polish (Weeks 9-10)

**Focus:** Complete system integration and polish the experience

**Key Deliverables:**

- Complete system integration
- Refined user experience
- Performance optimization
- Bug fixes
- Final polish

**Tasks:**

- Complete integration between all systems
- Refine user interface and controls
- Optimize performance across all systems
- Fix remaining bugs and issues
- Add final polish to visuals and audio
- Implement feedback from initial testing
- Create comprehensive tutorial flow
- Prepare for initial playtesting

**End of Sprint Goal:** Complete MVP with all core systems working together, ready for initial testing.

### Sprint 6 (Contingency): Testing & Refinement (Weeks 11-12)

**Focus:** Address feedback and refine the experience

**Key Deliverables:**

- Bug fixes based on testing feedback
- Performance improvements
- UX refinements
- Final polish

**Tasks:**

- Conduct focused playtesting sessions
- Address critical issues identified in testing
- Refine user experience based on feedback
- Optimize performance for target devices
- Document known issues and limitations
- Prepare for MVP release

**End of Sprint Goal:** Refined MVP ready for release to initial players.

---

## Acceptance Criteria

### Building System

- [x] Players can place furniture on a grid system
- [x] At least 15 furniture items are available
- [x] Players can change colors of walls, floors, and furniture
- [x] Houses can be saved and loaded correctly
- [x] Build mode UI is intuitive and functional
- [x] Performance remains stable with multiple furniture items placed
- [x] Data saving is reliable with 99.5% success rate

### Job System

- [x] 2 job types are implemented with unique gameplay
- [x] Jobs award XP and currency based on performance
- [x] Players can level up jobs to unlock rewards
- [x] Job locations are properly set up in the world
- [x] Job UI clearly shows progress and available jobs
- [x] Mini-games are engaging and function correctly
- [x] Job progression data saves correctly

### Vehicle System

- [x] Players can spawn and drive at least 1 vehicle type
- [x] Vehicle controls are responsive and intuitive
- [x] Collision detection works properly
- [x] Vehicles can navigate the world without major issues
- [x] Basic vehicle customization (colors) is functional
- [x] Vehicle performance is stable on target devices

### World Design

- [x] 3 distinct zones are implemented with appropriate aesthetics
- [x] World size is appropriate for the MVP scope
- [x] Day/night cycle functions correctly
- [x] NPCs populate the world appropriately
- [x] Navigation between zones is clear and intuitive
- [x] World streaming performs well on target devices

### Technical Requirements

- [x] Game runs at minimum 30 FPS on target devices
- [x] Data saving/loading works reliably with 99.5% success rate
- [x] No critical bugs that prevent core gameplay
- [x] Server-client communication is stable
- [x] Memory usage remains within acceptable limits
- [x] DataStore operations handle rate limits appropriately
- [x] Error handling captures and logs issues properly

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

### Functional Testing

- **Core Gameplay Testing:**

  - Systematic testing of all gameplay features
  - Verification of feature interactions
  - Edge case testing for unusual player behaviors
  - Measurement of completion times for core loops

- **Data Persistence Testing:**

  - Verification of data saving/loading with 99.5% success rate target
  - Stress testing with rapid save/load cycles
  - Corruption recovery testing
  - Testing of DataStore throttling scenarios

- **Cross-System Integration Testing:**
  - Verification of interactions between building, job, and vehicle systems
  - Testing of progression across different gameplay activities
  - Validation of economy balance across systems

### Performance Testing

- **Device Testing Matrix:**

  - Testing on low-end devices (minimum spec)
  - Testing on medium-spec devices (target spec)
  - Testing on high-end devices (optimal spec)
  - Documentation of performance metrics for each tier

- **Performance Metrics:**

  - FPS monitoring with target of 30+ FPS on minimum spec
  - Memory usage tracking with defined thresholds
  - Asset loading time measurement (target <10 seconds for initial load)
  - Network bandwidth monitoring

- **Stress Testing:**
  - Maximum furniture placement tests
  - Multiple player testing in shared spaces
  - Rapid system switching tests
  - Long play session stability tests (4+ hours)

### User Experience Testing

- **Small Group Testing:**

  - 5-10 external testers for focused feedback
  - Structured testing scenarios with specific tasks
  - Observation of player behavior and pain points
  - Post-test interviews and surveys

- **Usability Metrics:**

  - Time to complete core tasks (building, job completion)
  - Error rate during common interactions
  - Navigation efficiency between game areas
  - Feature discovery rate for new players

- **Feedback Collection:**
  - In-game feedback mechanism for testers
  - Structured survey for overall experience
  - Specific questions about pain points and enjoyment
  - Prioritization framework for addressing feedback

### Automated Testing

- **Unit Tests:**

  - Core system functionality tests
  - Data validation tests
  - Economy balance simulations

- **Performance Monitoring:**
  - Automated FPS tracking during test scenarios
  - Memory leak detection
  - Loading time measurements
  - DataStore operation success rate monitoring

---

## System Integration

### Integration Architecture

The MVP will implement a modular integration approach where core systems communicate through well-defined interfaces. This approach allows for independent development and testing while ensuring systems work together cohesively.

#### Building-Job Integration

- **Property Ownership:**

  - Jobs provide currency for purchasing building materials and furniture
  - Building progress unlocks certain job opportunities
  - Building quality affects job performance bonuses

- **Location-Based Integration:**
  - Job locations are positioned strategically near residential areas
  - Building placement considers proximity to job locations
  - Navigation system provides guidance between homes and jobs

#### Vehicle-Job Integration

- **Job-Specific Vehicles:**

  - Taxi Driver job utilizes the vehicle system directly
  - Vehicle performance affects job efficiency
  - Job progression unlocks vehicle customizations

- **Transportation Network:**
  - Vehicle system provides transportation between job locations
  - Job system defines optimal routes and destinations
  - Reward system considers distance and time factors

#### Building-Vehicle Integration

- **Garage System:**
  - Buildings include vehicle parking/spawning areas
  - Vehicle customization tied to building progression
  - Building locations determine vehicle spawn points

### Communication Patterns

- **Event-Based Communication:**

  - Systems communicate through a centralized event system
  - Events are validated and processed by the server
  - Client prediction provides responsive feedback

- **Data Sharing:**

  - Core player data is accessible to all systems
  - Systems maintain their own specialized data
  - Centralized data service manages persistence

- **State Synchronization:**
  - Regular state updates between systems
  - Conflict resolution handled by server authority
  - Optimized network usage for state synchronization

### Integration Testing

- **Cross-System Test Cases:**

  - Building a house, taking a job, and driving between them
  - Earning currency through jobs and spending on building
  - Completing job tasks with vehicles
  - Full gameplay loop testing

- **Integration Metrics:**
  - System response time during cross-system interactions
  - Data consistency across systems
  - Performance impact during system transitions

---

## User Experience Iteration

### Feedback Collection

- **In-Game Feedback:**

  - Contextual feedback prompts during gameplay
  - Simple rating system for features
  - Optional detailed feedback form
  - Screenshot submission for bug reports

- **Playtesting Sessions:**

  - Structured testing with 5-10 trusted testers
  - Observation of player behavior and pain points
  - Post-session interviews and surveys
  - Recorded gameplay sessions for analysis

- **Metrics Collection:**
  - Session length and frequency
  - Feature usage patterns
  - Progression rate through content
  - Abandonment points in gameplay flows

### Iteration Process

- **Feedback Analysis:**

  - Categorization of feedback by system and severity
  - Identification of common pain points
  - Prioritization based on impact and implementation effort
  - Creation of actionable improvement tasks

- **Rapid Prototyping:**

  - Quick implementation of potential solutions
  - A/B testing of alternative approaches
  - Iterative refinement based on results
  - Documentation of design decisions

- **Implementation Cycle:**
  - Biweekly UX improvement sprints
  - Focus on highest-priority issues first
  - Validation with original feedback providers
  - Measurement of improvement impact

### UX Success Metrics

- **Engagement Metrics:**

  - Average session length (target: 30+ minutes)
  - Return rate (target: 80%+ daily active users)
  - Feature adoption rate (target: 90% of players trying each core feature)
  - Progression depth (target: 70% of players reaching level 5 in at least one job)

- **Satisfaction Metrics:**

  - Overall satisfaction rating (target: 4.5/5)
  - Feature-specific ratings (target: 4/5 for each core feature)
  - Net Promoter Score (target: 40+)
  - Qualitative feedback sentiment analysis

- **Performance Metrics:**
  - Task completion rate (target: 95% for core tasks)
  - Error rate (target: <5% for common interactions)
  - Time-to-competence (target: <15 minutes for basic proficiency)
  - Help system usage (target: decreasing over time)
