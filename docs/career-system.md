# Life in Bloom - Career System

## Overview

The Career System is a core gameplay pillar that provides players with diverse professional paths, each offering unique gameplay, progression, and rewards. Players can freely choose and switch between different jobs to experience varied gameplay loops while building their virtual life.

## Key Features

- **Multiple Job Types**: Diverse career options with unique gameplay mechanics
- **Independent Progression**: Each job has its own XP pool and level system
- **Mini-Game Mechanics**: Job-specific activities that challenge different skills
- **Flexible Scheduling**: Players can switch jobs at any time
- **Reward Structure**: Currency, items, and unlocks tied to job performance
- **Skill Development**: Mastery system that improves job abilities

## Job Categories

Jobs are organized into four main categories, each offering distinct gameplay experiences:

### Service Careers

Jobs focused on helping others and providing services:

1. **Chef**
2. **Doctor**
3. **Police Officer**
4. **Teacher**
5. **Retail Worker**

### Technical Careers

Jobs centered on building, repairing, and operating:

1. **Mechanic**
2. **Taxi Driver**
3. **Delivery Driver**
4. **Engineer**
5. **Programmer**

### Creative Careers

Jobs emphasizing design, artistry, and performance:

1. **Musician**
2. **Artist**
3. **Fashion Designer**
4. **Interior Decorator**
5. **Game Developer**

### Management Careers

Jobs involving organization, planning, and leadership:

1. **Event Planner**
2. **Tour Guide**
3. **Business Owner**
4. **Real Estate Agent**
5. **Hotel Manager**

## Core Job Mechanics

### Job Selection

How players choose and switch between careers:

- **Job Hub**: Central location for browsing and selecting jobs
- **Job Cards**: Visual representation of each career option
- **Requirements**: Some jobs require specific level or achievements
- **Switching Process**: Simple process to change active job
- **Multiple Jobs**: Option to hold multiple part-time positions

### Job Progression

Each job features a dedicated progression system:

- **Experience Points (XP)**: Earned by completing job activities
- **Level System**: 20 levels per job with increasing XP requirements
- **Level-Up Rewards**: New abilities, items, and customization options
- **Prestige System**: Optional reset with special benefits (late-game)
- **Specializations**: Sub-paths within jobs at higher levels

### XP Formula

```
XP Required for Level N = Base XP × (Level Multiplier ^ (N-1))
```

Where:
- Base XP = 100
- Level Multiplier = 1.2
- N = Target Level

Example progression for initial levels:
- Level 1 to 2: 100 XP
- Level 2 to 3: 120 XP
- Level 3 to 4: 144 XP

### Work Schedule

How players engage with job activities:

- **Active Hours**: Real-time period when jobs are available
- **Shift System**: Optional timed work periods with bonus rewards
- **Breaks**: Cooldown periods to prevent excessive grinding
- **Job Board**: Daily and weekly special assignments

## Job-Specific Implementations

### Chef

The Chef career focuses on food preparation through timing and assembly challenges.

#### Core Gameplay Loop

1. Take customer orders
2. Prepare ingredients through mini-game interactions
3. Assemble dishes in the correct order
4. Serve completed meals for rewards

#### Mini-Game Mechanics

- **Chopping Game**: Rhythm-based knife control
- **Cooking Timer**: Manage multiple timers for different dishes
- **Plate Assembly**: Drag-and-drop ingredient placement
- **Order Management**: Priority-based task sequencing

#### Progression Path

| Level | Unlocks |
|-------|---------|
| 1-5   | Basic recipes, starter kitchen equipment |
| 6-10  | Intermediate recipes, improved tools |
| 11-15 | Advanced cuisine, specialty equipment |
| 16-20 | Master recipes, exclusive chef items |

#### Reward Structure

- **Currency**: Based on meal quality and customer satisfaction
- **XP Gain**: Determined by dish complexity and time efficiency
- **Unique Unlocks**: Chef outfits, personal kitchen items, recipe books

#### Workplace Environment

- **Restaurant Location**: Dedicated area with kitchen and dining section
- **Equipment Upgrade Path**: From basic to professional-grade tools
- **Visual Progression**: Kitchen station evolves with player level

### Taxi Driver

The Taxi Driver career focuses on navigation, driving skill, and time management.

#### Core Gameplay Loop

1. Accept passenger requests
2. Navigate to pickup location
3. Transport passengers to destinations
4. Receive payment based on distance and efficiency

#### Mini-Game Mechanics

- **Navigation Challenge**: Find optimal routes through the city
- **Driving Skill Test**: Avoid obstacles while maintaining speed
- **Time Management**: Balance multiple pickup requests
- **Passenger Satisfaction**: Maintain comfort through driving style

#### Progression Path

| Level | Unlocks |
|-------|---------|
| 1-5   | Basic taxi models, city map |
| 6-10  | Improved vehicles, shortcuts, passenger bonuses |
| 11-15 | VIP services, exclusive areas |
| 16-20 | Luxury vehicles, special driving abilities |

#### Reward Structure

- **Currency**: Based on fare distance and time efficiency
- **XP Gain**: Determined by successful deliveries and route optimization
- **Unique Unlocks**: Vehicle customizations, driver accessories, special license plates

#### Workplace Environment

- **Taxi Depot**: Central hub for starting shifts
- **City Navigation**: Dynamic urban environment with traffic
- **Passenger Types**: Various NPCs with different needs and destinations

### Police Officer

The Police Officer career focuses on patrol, investigation, and community protection.

#### Core Gameplay Loop

1. Receive dispatch alerts
2. Respond to incidents around the city
3. Resolve situations through appropriate actions
4. Complete reports for commendation

#### Mini-Game Mechanics

- **Patrol Activity**: Scan environment for suspicious activity
- **Chase Sequence**: Pursue and apprehend suspects
- **Investigation Mode**: Find clues and evidence
- **Conflict Resolution**: Choose appropriate responses to situations

#### Progression Path

| Level | Unlocks |
|-------|---------|
| 1-5   | Basic equipment, patrol routes |
| 6-10  | Expanded jurisdiction, special tools |
| 11-15 | Advanced vehicles, investigation techniques |
| 16-20 | Special operations, exclusive police gear |

#### Reward Structure

- **Currency**: Based on successful incident resolution
- **XP Gain**: Determined by patrol activity and case complexity
- **Unique Unlocks**: Police uniforms, vehicle lights, badges

#### Workplace Environment

- **Police Station**: Central hub with briefing room and equipment
- **Patrol Zones**: Different areas with unique challenges
- **Incident Types**: Various situations requiring different approaches

### Delivery Driver

The Delivery Driver career focuses on logistics, route optimization, and time management.

#### Core Gameplay Loop

1. Collect packages from distribution center
2. Plan efficient delivery routes
3. Navigate to delivery locations
4. Complete deliveries within time constraints

#### Mini-Game Mechanics

- **Package Sorting**: Organize deliveries by location
- **Route Planning**: Create optimal path through multiple stops
- **Driving Challenge**: Navigate streets while maintaining package safety
- **Time Trials**: Complete deliveries within specific timeframes

#### Progression Path

| Level | Unlocks |
|-------|---------|
| 1-5   | Basic delivery van, city zones |
| 6-10  | Improved vehicles, route planning tools |
| 11-15 | Special delivery types, efficiency bonuses |
| 16-20 | Premium delivery service, exclusive vehicle features |

#### Reward Structure

- **Currency**: Based on delivery speed and package condition
- **XP Gain**: Determined by route efficiency and completion time
- **Unique Unlocks**: Vehicle customizations, delivery uniform upgrades, navigation tools

#### Workplace Environment

- **Distribution Center**: Package collection and sorting area
- **Delivery Map**: Interactive route planning interface
- **Vehicle Garage**: Selection of delivery vehicles

## Career Advancement Mechanics

### Job Mastery System

Beyond the basic level progression:

- **Mastery Points**: Earned after reaching maximum level
- **Specialization Paths**: Branch into expert roles within each career
- **Mastery Challenges**: Special high-difficulty tasks for dedicated players
- **Recognition System**: Visible indicators of expertise (titles, badges)

### Certification System

Special achievements within each career path:

- **Certification Tests**: Skill-based challenges to earn credentials
- **Certificate Levels**: Bronze, Silver, Gold, Platinum
- **Career Benefits**: Bonuses that apply after earning certifications
- **Display System**: Showcasing earned credentials to other players

### Career Statistics

Tracked metrics for each job:

- **Performance Stats**: Job-specific metrics (deliveries made, meals cooked)
- **Efficiency Rating**: Quality of work based on accuracy and speed
- **Total Earnings**: Cumulative career income
- **Time Invested**: Hours spent in each career
- **Special Achievements**: Unique milestones reached

## Reward Structures

### Economic Rewards

Monetary compensation for job activities:

- **Base Pay**: Standard earnings for completing job activities
- **Performance Bonuses**: Additional rewards for exceptional work
- **Tips/Commissions**: Extra earnings based on customer satisfaction
- **Shift Bonuses**: Increased pay for working during peak hours
- **Career Milestones**: Large bonuses for reaching significant achievements

### Progression Rewards

Items and features unlocked through career advancement:

- **Work Equipment**: Job-specific tools and functional items
- **Cosmetic Items**: Career-themed clothing and accessories
- **Furniture/Decorations**: Home items related to each career
- **Special Abilities**: Unique gameplay advantages within job activities
- **Exclusive Vehicles**: Career-specific transportation options

### Social Recognition

Status indicators for career achievements:

- **Job Titles**: Displayed name prefixes based on career level
- **Uniform Options**: Special clothing indicating expertise
- **Achievement Badges**: Visible indicators of accomplishments
- **Workplace Perks**: Special access or benefits in job locations
- **Community Role**: Special functions in community events

## Technical Implementation

### Job Activity System

How job activities are structured and managed:

```lua
-- Job Activity Base Class
JobActivity = {
    Name = "",
    Description = "",
    DurationSeconds = 60,
    BaseCurrencyReward = 50,
    BaseXPReward = 10,
    RequiredLevel = 1,
    Difficulty = 1, -- 1-5 scale
    
    -- Core methods
    Start = function(self, player) end,
    Complete = function(self, player, performanceScore) end,
    Cancel = function(self, player) end,
    
    -- Reward calculation
    CalculateRewards = function(self, performanceScore)
        local currencyMultiplier = 1 + (performanceScore / 100)
        local xpMultiplier = 1 + (performanceScore / 200)
        
        return {
            Currency = math.floor(self.BaseCurrencyReward * currencyMultiplier),
            XP = math.floor(self.BaseXPReward * xpMultiplier)
        }
    end
}
```

### Job Manager

Central system that coordinates job selection and tracking:

```lua
JobManager = {
    -- Player job data
    PlayerJobs = {}, -- [PlayerId] = {ActiveJob, JobData}
    
    -- Core methods
    SelectJob = function(self, player, jobType) end,
    StartActivity = function(self, player, activityId) end,
    CompleteActivity = function(self, player, activityId, performanceScore) end,
    
    -- Progression handling
    AwardXP = function(self, player, jobType, xpAmount) end,
    CheckLevelUp = function(self, player, jobType) end,
    UnlockJobRewards = function(self, player, jobType, level) end,
    
    -- Data management
    SaveJobData = function(self, player) end,
    LoadJobData = function(self, player) end
}
```

### Client-Server Communication

How job actions are validated and synchronized:

- **Activity Start**: Client request → Server validation → Activity initiation
- **Progress Updates**: Server-controlled milestones → Client UI updates
- **Completion Validation**: Server verification of results → Reward distribution
- **Anti-Exploitation**: Server-side timing and performance verification

## User Interface

### Job Hub Interface

Central UI for managing career options:

```
┌─────────────────────────────────────────────────────┐
│ CAREER CENTER                                       │
├─────────────────────────────────────────────────────┤
│ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐     │
│ │         │ │         │ │         │ │         │     │
│ │  CHEF   │ │  TAXI   │ │ POLICE  │ │ DELIVERY│     │
│ │ Level 5 │ │ Level 2 │ │ Level 8 │ │ Level 1 │     │
│ │         │ │         │ │         │ │         │     │
│ └─────────┘ └─────────┘ └─────────┘ └─────────┘     │
│                                                     │
│ ┌─────────────────────────────────────────────────┐ │
│ │                                                 │ │
│ │             SELECTED JOB DETAILS               │ │
│ │                                                 │ │
│ │  • Current level: 5                            │ │
│ │  • XP: 450/600                                 │ │
│ │  • Unlocked items: 12/25                       │ │
│ │  • Special abilities: Quick Prep, Food Critic   │ │
│ │                                                 │ │
│ │  [BEGIN SHIFT]    [VIEW UNLOCKS]    [TUTORIAL] │ │
│ │                                                 │ │
│ └─────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────┘
```

### Job Activity Interface

UI during active job gameplay:

- **Progress Indicators**: Visual representation of activity completion
- **Timer Displays**: Countdown for timed activities
- **Performance Metrics**: Real-time feedback on quality and efficiency
- **Objective Trackers**: Checklist of current tasks
- **Reward Previews**: Estimated earnings based on current performance

### Career Progression UI

Interface for tracking advancement:

- **XP Bar**: Visual indicator of progress to next level
- **Level Tree**: Branching visualization of career path
- **Unlock Preview**: Upcoming rewards for level advancement
- **Statistics Dashboard**: Performance metrics and history
- **Achievement Gallery**: Collection of earned recognitions

## Onboarding & Tutorials

### New Player Experience

Introduction to the career system:

- **Career Advisor NPC**: Introduces job options
- **Starter Jobs**: Simplified versions of core careers
- **Guided Tour**: Walkthrough of job locations
- **Trial Shifts**: Sample gameplay for each job type
- **Starter Pack**: Initial equipment for chosen career

### Job-Specific Tutorials

Learning path for each career:

1. **Basic Introduction**: Overview of job mechanics
2. **Guided Practice**: Step-by-step walkthrough of core activities
3. **Skill Challenges**: Progressive difficulty tests
4. **Advanced Techniques**: Tips and strategies for optimization
5. **Master Class**: Expert-level instruction for high performance

## Balance Considerations

### Economy Balance

Ensuring fair and consistent income:

- **Job Income Parity**: Comparable earnings across different jobs
- **Skill/Reward Ratio**: Higher skill requirements yield higher rewards
- **Time Investment Balance**: Rewards proportional to time spent
- **Progression Scaling**: Income increases with level and skill
- **Economic Impact**: Job earnings balanced against item costs

### Progression Pacing

Creating satisfying advancement:

- **Early Milestones**: Quick initial level-ups to build engagement
- **Mid-Game Challenge**: Increasing difficulty and XP requirements
- **Long-Term Goals**: Stretch achievements for dedicated players
- **Multiple Paths**: Parallel progression tracks for variety
- **Catch-Up Mechanics**: Features that help less active players

### Gameplay Variety

Maintaining engagement through diversity:

- **Activity Rotation**: Regular cycling of available tasks
- **Special Events**: Limited-time job opportunities
- **Difficulty Modes**: Optional challenges for increased rewards
- **Random Elements**: Unpredictable factors that require adaptation
- **Cross-Job Opportunities**: Activities that combine multiple career skills

## Future Expansion Opportunities

### Planned Enhancements

Features identified for future updates:

1. **Career Mentorship System**
   - Player-to-player teaching mechanics
   - Shared rewards for mentor and apprentice
   - Knowledge transfer bonuses

2. **Business Ownership**
   - Evolution from employee to business owner
   - Staff management and business development
   - Property and equipment investment

3. **Specialized Career Branches**
   - Sub-specialties within each career
   - Unique gameplay mechanics for each branch
   - Specialized rewards and recognition

4. **Career Challenges and Events**
   - Competitive career-based events
   - Time-limited special assignments
   - Career Olympics with multi-job competitions

5. **Work-Life Integration**
   - Career impacts on home life and social status
   - Balance mechanics between work and leisure
   - Career stress and satisfaction systems 