# Life in Bloom – Sprint Planning

## Table of Contents

1. [Sprint Planning Overview](#sprint-planning-overview)
2. [Sprint 1: Technical Foundation](#sprint-1-technical-foundation)
3. [Sprint 2: Building System](#sprint-2-building-system)
4. [Sprint 3: Job System](#sprint-3-job-system)
5. [Sprint 4: Vehicles & Integration](#sprint-4-vehicles--integration)
6. [Sprint Planning Best Practices](#sprint-planning-best-practices)
7. [Definition of Done](#definition-of-done)

---

## Sprint Planning Overview

This document provides a detailed breakdown of the MVP phase sprints, including specific tasks, assignments, and deliverables. Each sprint is two weeks long and follows an agile methodology with daily stand-ups, sprint planning, and retrospectives.

### Sprint Cadence

- **Sprint Duration:** 2 weeks
- **Sprint Planning:** First day of sprint (2 hours)
- **Daily Stand-ups:** Every workday (15 minutes)
- **Sprint Review:** Last day of sprint (1 hour)
- **Sprint Retrospective:** Last day of sprint (1 hour)

### Task Estimation

Tasks are estimated using story points on a Fibonacci scale (1, 2, 3, 5, 8, 13):

- **1 point:** Very simple task, few hours of work
- **2-3 points:** Straightforward task, 1-2 days of work
- **5 points:** Moderate complexity, 3-4 days of work
- **8 points:** Complex task, up to a week of work
- **13 points:** Very complex task, should be broken down further

### Team Capacity

- **Developers (3):** ~30 points per developer per sprint
- **Artists (2):** ~25 points per artist per sprint
- **Designer (1):** ~30 points per sprint
- **QA (1, part-time):** ~15 points per sprint

---

## Sprint 1: Technical Foundation

**Duration:** Weeks 1-2  
**Goal:** Establish core architecture and basic world

### Sprint Backlog

#### Programming Tasks

| Task ID | Description                                                   | Assignee | Story Points | Priority |
| ------- | ------------------------------------------------------------- | -------- | ------------ | -------- |
| P1-01   | Set up project structure and coding standards                 | Lead Dev | 3            | High     |
| P1-02   | Implement player controller with basic movement               | Dev 1    | 5            | High     |
| P1-03   | Create camera system with first/third person views            | Dev 1    | 5            | High     |
| P1-04   | Develop data service for saving/loading                       | Dev 2    | 8            | High     |
| P1-05   | Implement basic world streaming                               | Dev 2    | 5            | Medium   |
| P1-06   | Create simple terrain and zone boundaries                     | Dev 3    | 5            | High     |
| P1-07   | Establish remote event system for client-server communication | Dev 3    | 8            | High     |
| P1-08   | Set up basic UI framework                                     | Lead Dev | 5            | Medium   |
| P1-09   | Implement day/night cycle                                     | Dev 1    | 3            | Low      |
| P1-10   | Create basic NPC spawning system                              | Dev 2    | 5            | Medium   |

#### Art Tasks

| Task ID | Description                                         | Assignee | Story Points | Priority |
| ------- | --------------------------------------------------- | -------- | ------------ | -------- |
| A1-01   | Create basic player character model                 | Artist 1 | 5            | High     |
| A1-02   | Design simple environment assets (trees, buildings) | Artist 1 | 8            | High     |
| A1-03   | Create basic textures for terrain                   | Artist 2 | 5            | High     |
| A1-04   | Design placeholder UI elements                      | Artist 2 | 5            | Medium   |
| A1-05   | Create simple NPC models                            | Artist 1 | 5            | Medium   |

#### Design Tasks

| Task ID | Description                                  | Assignee | Story Points | Priority |
| ------- | -------------------------------------------- | -------- | ------------ | -------- |
| D1-01   | Define world layout and zone purposes        | Designer | 5            | High     |
| D1-02   | Design player controls and camera behavior   | Designer | 3            | High     |
| D1-03   | Create initial UI wireframes                 | Designer | 5            | Medium   |
| D1-04   | Define data structure for player information | Designer | 5            | High     |
| D1-05   | Document technical architecture              | Designer | 8            | Medium   |

#### QA Tasks

| Task ID | Description                             | Assignee | Story Points | Priority |
| ------- | --------------------------------------- | -------- | ------------ | -------- |
| Q1-01   | Test player movement and controls       | QA       | 3            | High     |
| Q1-02   | Verify data saving/loading              | QA       | 5            | High     |
| Q1-03   | Test performance in different scenarios | QA       | 3            | Medium   |
| Q1-04   | Document bugs and issues                | QA       | 2            | High     |

### Sprint 1 Deliverables

- Functional player movement and camera controls
- Basic world with defined zones
- Working data persistence system
- Initial UI framework
- Technical documentation

### Sprint 1 Risks

- Data persistence implementation may take longer than expected
- Performance issues with initial world streaming
- Integration challenges between systems

---

## Sprint 2: Building System

**Duration:** Weeks 3-4  
**Goal:** Implement house building and customization

### Sprint Backlog

#### Programming Tasks

| Task ID | Description                                         | Assignee | Story Points | Priority |
| ------- | --------------------------------------------------- | -------- | ------------ | -------- |
| P2-01   | Develop grid system for placement                   | Dev 1    | 8            | High     |
| P2-02   | Implement furniture placement logic                 | Dev 1    | 5            | High     |
| P2-03   | Create collision detection for placement            | Dev 2    | 5            | High     |
| P2-04   | Implement furniture data structure                  | Dev 2    | 3            | High     |
| P2-05   | Create customization system for colors and textures | Dev 3    | 8            | High     |
| P2-06   | Build save/load functionality for houses            | Dev 3    | 5            | High     |
| P2-07   | Develop build mode UI with catalog                  | Lead Dev | 8            | High     |
| P2-08   | Implement undo/redo functionality                   | Dev 1    | 5            | Medium   |
| P2-09   | Create preview mode for placement                   | Dev 2    | 3            | Medium   |
| P2-10   | Implement basic furniture interactions              | Dev 3    | 5            | Low      |

#### Art Tasks

| Task ID | Description                                          | Assignee | Story Points | Priority |
| ------- | ---------------------------------------------------- | -------- | ------------ | -------- |
| A2-01   | Create basic furniture models (beds, tables, chairs) | Artist 1 | 8            | High     |
| A2-02   | Design kitchen and bathroom items                    | Artist 1 | 8            | High     |
| A2-03   | Create wall and floor textures                       | Artist 2 | 5            | High     |
| A2-04   | Design build mode UI elements                        | Artist 2 | 8            | High     |
| A2-05   | Create furniture placement effects                   | Artist 1 | 3            | Medium   |

#### Design Tasks

| Task ID | Description                             | Assignee | Story Points | Priority |
| ------- | --------------------------------------- | -------- | ------------ | -------- |
| D2-01   | Design furniture catalog organization   | Designer | 3            | High     |
| D2-02   | Create build mode UX flow               | Designer | 5            | High     |
| D2-03   | Define customization options and limits | Designer | 3            | High     |
| D2-04   | Balance initial furniture costs         | Designer | 3            | Medium   |
| D2-05   | Document building system                | Designer | 5            | Medium   |

#### QA Tasks

| Task ID | Description                                   | Assignee | Story Points | Priority |
| ------- | --------------------------------------------- | -------- | ------------ | -------- |
| Q2-01   | Test furniture placement in various scenarios | QA       | 5            | High     |
| Q2-02   | Verify customization options                  | QA       | 3            | High     |
| Q2-03   | Test house saving/loading                     | QA       | 5            | High     |
| Q2-04   | Verify build mode UI functionality            | QA       | 3            | High     |

### Sprint 2 Deliverables

- Functional grid-based building system
- 20-30 placeable furniture items
- Basic customization options
- Build mode UI
- House saving and loading

### Sprint 2 Risks

- Grid system complexity may exceed estimates
- Performance issues with many placed objects
- Save/load system may require additional work

---

## Sprint 3: Job System

**Duration:** Weeks 5-6  
**Goal:** Implement initial jobs and progression

### Sprint Backlog

#### Programming Tasks

| Task ID | Description                                           | Assignee | Story Points | Priority |
| ------- | ----------------------------------------------------- | -------- | ------------ | -------- |
| P3-01   | Develop job framework with progression tracking       | Lead Dev | 8            | High     |
| P3-02   | Implement Chef mini-game (cooking puzzle)             | Dev 1    | 8            | High     |
| P3-03   | Create Taxi Driver gameplay (passenger delivery)      | Dev 2    | 8            | High     |
| P3-04   | Build Police Officer activities (patrol and response) | Dev 3    | 8            | High     |
| P3-05   | Implement currency system and rewards                 | Lead Dev | 5            | High     |
| P3-06   | Develop job selection and progress UI                 | Dev 1    | 5            | High     |
| P3-07   | Create job locations in the world                     | Dev 2    | 5            | High     |
| P3-08   | Implement job-specific animations                     | Dev 3    | 5            | Medium   |
| P3-09   | Create job switching functionality                    | Lead Dev | 3            | Medium   |
| P3-10   | Implement basic daily quests                          | Dev 1    | 5            | Low      |

#### Art Tasks

| Task ID | Description                               | Assignee | Story Points | Priority |
| ------- | ----------------------------------------- | -------- | ------------ | -------- |
| A3-01   | Create Chef job assets and location       | Artist 1 | 8            | High     |
| A3-02   | Design Taxi Driver assets and location    | Artist 1 | 8            | High     |
| A3-03   | Create Police Officer assets and location | Artist 2 | 8            | High     |
| A3-04   | Design job UI elements                    | Artist 2 | 5            | High     |
| A3-05   | Create job-specific animations            | Artist 1 | 5            | Medium   |

#### Design Tasks

| Task ID | Description                            | Assignee | Story Points | Priority |
| ------- | -------------------------------------- | -------- | ------------ | -------- |
| D3-01   | Design Chef mini-game mechanics        | Designer | 5            | High     |
| D3-02   | Create Taxi Driver route system        | Designer | 5            | High     |
| D3-03   | Design Police Officer patrol mechanics | Designer | 5            | High     |
| D3-04   | Balance job rewards and progression    | Designer | 8            | High     |
| D3-05   | Document job system                    | Designer | 5            | Medium   |

#### QA Tasks

| Task ID | Description                        | Assignee | Story Points | Priority |
| ------- | ---------------------------------- | -------- | ------------ | -------- |
| Q3-01   | Test Chef mini-game                | QA       | 3            | High     |
| Q3-02   | Verify Taxi Driver gameplay        | QA       | 3            | High     |
| Q3-03   | Test Police Officer activities     | QA       | 3            | High     |
| Q3-04   | Verify job progression and rewards | QA       | 5            | High     |

### Sprint 3 Deliverables

- 3 functional job types with mini-games
- Job progression system with XP and levels
- Currency and reward system
- Job locations in the world
- Job selection and progress UI

### Sprint 3 Risks

- Mini-game complexity may exceed estimates
- Balancing job rewards may require iteration
- Integration with existing systems may be challenging

---

## Sprint 4: Vehicles & Integration

**Duration:** Weeks 7-8  
**Goal:** Add vehicles and integrate all systems

### Sprint Backlog

#### Programming Tasks

| Task ID | Description                                  | Assignee | Story Points | Priority |
| ------- | -------------------------------------------- | -------- | ------------ | -------- |
| P4-01   | Implement vehicle controls and physics       | Dev 1    | 8            | High     |
| P4-02   | Create vehicle spawning system               | Dev 1    | 5            | High     |
| P4-03   | Implement basic vehicle customization        | Dev 2    | 5            | Medium   |
| P4-04   | Create vehicle collision system              | Dev 2    | 5            | High     |
| P4-05   | Integrate building, job, and vehicle systems | Dev 3    | 8            | High     |
| P4-06   | Implement basic tutorial and onboarding      | Dev 3    | 5            | High     |
| P4-07   | Optimize performance for target devices      | Lead Dev | 8            | High     |
| P4-08   | Fix critical bugs                            | All Devs | 13           | High     |
| P4-09   | Implement basic achievement system           | Dev 1    | 5            | Low      |
| P4-10   | Create settings menu                         | Dev 2    | 3            | Medium   |

#### Art Tasks

| Task ID | Description                         | Assignee     | Story Points | Priority |
| ------- | ----------------------------------- | ------------ | ------------ | -------- |
| A4-01   | Create car model and textures       | Artist 1     | 8            | High     |
| A4-02   | Design bicycle model and textures   | Artist 1     | 5            | High     |
| A4-03   | Create vehicle customization assets | Artist 2     | 5            | Medium   |
| A4-04   | Design tutorial UI elements         | Artist 2     | 5            | High     |
| A4-05   | Final polish on existing assets     | Both Artists | 8            | High     |

#### Design Tasks

| Task ID | Description                          | Assignee | Story Points | Priority |
| ------- | ------------------------------------ | -------- | ------------ | -------- |
| D4-01   | Design vehicle controls and handling | Designer | 5            | High     |
| D4-02   | Create tutorial flow and content     | Designer | 8            | High     |
| D4-03   | Balance vehicle performance          | Designer | 3            | Medium   |
| D4-04   | Design achievement system            | Designer | 5            | Low      |
| D4-05   | Final gameplay balance adjustments   | Designer | 8            | High     |

#### QA Tasks

| Task ID | Description                       | Assignee | Story Points | Priority |
| ------- | --------------------------------- | -------- | ------------ | -------- |
| Q4-01   | Test vehicle controls and physics | QA       | 5            | High     |
| Q4-02   | Verify system integration         | QA       | 8            | High     |
| Q4-03   | Test tutorial and onboarding      | QA       | 3            | High     |
| Q4-04   | Perform final MVP testing         | QA       | 8            | High     |

### Sprint 4 Deliverables

- Functional vehicle system with 2 vehicle types
- Complete system integration
- Basic tutorial and onboarding
- Performance optimization
- Bug fixes and polish

### Sprint 4 Risks

- Vehicle physics may require additional tuning
- Integration issues between systems
- Performance optimization may take longer than expected

## Post-MVP Sprint Planning

The following sprints outline the work to be done in the first 3 months after launch, focusing on the priorities identified in the suggestions document.

## Sprint 5: Performance & Stability

**Duration:** 2 weeks  
**Goal:** Optimize performance and address critical issues identified during initial release

### Sprint Backlog

#### Programming Tasks

| Task ID | Description                                      | Assignee | Story Points | Priority |
| ------- | ------------------------------------------------ | -------- | ------------ | -------- |
| P5-01   | Implement basic LOD system for complex assets    | Dev 1    | 8            | High     |
| P5-02   | Add priority-based asset loading                 | Dev 1    | 5            | High     |
| P5-03   | Enhance object pooling for frequent objects      | Dev 2    | 5            | High     |
| P5-04   | Implement basic occlusion culling                | Dev 2    | 8            | Medium   |
| P5-05   | Address critical bugs from initial feedback      | Dev 3    | 13           | Critical |
| P5-06   | Improve error handling and recovery              | Dev 3    | 5            | High     |
| P5-07   | Enhance data backup and recovery systems         | Lead Dev | 8            | High     |
| P5-08   | Optimize network code for better stability       | Lead Dev | 8            | High     |
| P5-09   | Implement memory profiling for development build | Dev 1    | 5            | Medium   |
| P5-10   | Add performance monitoring tools                 | Dev 2    | 5            | Medium   |

#### Art Tasks

| Task ID | Description                                 | Assignee     | Story Points | Priority |
| ------- | ------------------------------------------- | ------------ | ------------ | -------- |
| A5-01   | Create LOD versions of high-polygon assets  | Artist 1     | 13           | High     |
| A5-02   | Optimize texture sizes and formats          | Artist 1     | 5            | High     |
| A5-03   | Reduce polygon count on non-essential items | Artist 2     | 8            | Medium   |
| A5-04   | Create optimized versions of effects        | Artist 2     | 5            | Medium   |
| A5-05   | Fix visual bugs identified post-launch      | Both Artists | 8            | High     |

#### Design Tasks

| Task ID | Description                                  | Assignee | Story Points | Priority |
| ------- | -------------------------------------------- | -------- | ------------ | -------- |
| D5-01   | Analyze player feedback and prioritize fixes | Designer | 5            | High     |
| D5-02   | Refine tutorial based on player confusion    | Designer | 8            | High     |
| D5-03   | Balance economy based on initial metrics     | Designer | 5            | High     |
| D5-04   | Identify performance bottlenecks in gameplay | Designer | 5            | Medium   |
| D5-05   | Document technical debt and prioritize fixes | Designer | 3            | Medium   |

#### QA Tasks

| Task ID | Description                               | Assignee | Story Points | Priority |
| ------- | ----------------------------------------- | -------- | ------------ | -------- |
| Q5-01   | Performance testing across device types   | QA       | 8            | High     |
| Q5-02   | Regression testing after optimizations    | QA       | 5            | High     |
| Q5-03   | Stress testing with simulated player load | QA       | 5            | Medium   |
| Q5-04   | Verify bug fixes from initial release     | QA       | 8            | Critical |

## Sprint 6: UI/UX Improvements

**Duration:** 2 weeks  
**Goal:** Enhance the user experience based on initial player feedback

### Sprint Backlog

#### Programming Tasks

| Task ID | Description                                 | Assignee | Story Points | Priority |
| ------- | ------------------------------------------- | -------- | ------------ | -------- |
| P6-01   | Implement contextual help system            | Dev 1    | 8            | High     |
| P6-02   | Add improved navigation and wayfinding      | Dev 1    | 5            | High     |
| P6-03   | Refine control schemes based on feedback    | Dev 2    | 5            | High     |
| P6-04   | Implement UI customization options          | Dev 2    | 8            | Medium   |
| P6-05   | Create in-game wiki framework               | Dev 3    | 8            | Medium   |
| P6-06   | Add milestone rewards for early progression | Dev 3    | 5            | High     |
| P6-07   | Implement favorites bar for quick access    | Lead Dev | 5            | Medium   |
| P6-08   | Add UI themes and visual styles             | Lead Dev | 8            | Low      |
| P6-09   | Enhance accessibility features              | Dev 1    | 8            | High     |
| P6-10   | Implement mobile-specific UI optimizations  | Dev 2    | 8            | Medium   |

#### Art Tasks

| Task ID | Description                           | Assignee     | Story Points | Priority |
| ------- | ------------------------------------- | ------------ | ------------ | -------- |
| A6-01   | Design contextual help UI elements    | Artist 1     | 5            | High     |
| A6-02   | Create improved navigation indicators | Artist 1     | 5            | High     |
| A6-03   | Design UI theme variations            | Artist 2     | 8            | Medium   |
| A6-04   | Create icons for favorites bar        | Artist 2     | 3            | Medium   |
| A6-05   | Design mobile-optimized UI layouts    | Both Artists | 8            | Medium   |

#### Design Tasks

| Task ID | Description                                  | Assignee | Story Points | Priority |
| ------- | -------------------------------------------- | -------- | ------------ | -------- |
| D6-01   | Design contextual help content               | Designer | 8            | High     |
| D6-02   | Create milestone reward structure            | Designer | 5            | High     |
| D6-03   | Design in-game wiki organization             | Designer | 5            | Medium   |
| D6-04   | Refine control schemes for different devices | Designer | 5            | High     |
| D6-05   | Design accessibility improvements            | Designer | 5            | High     |

#### QA Tasks

| Task ID | Description                           | Assignee | Story Points | Priority |
| ------- | ------------------------------------- | -------- | ------------ | -------- |
| Q6-01   | Test contextual help system           | QA       | 5            | High     |
| Q6-02   | Verify UI customization options       | QA       | 5            | Medium   |
| Q6-03   | Test accessibility features           | QA       | 5            | High     |
| Q6-04   | Mobile UI testing across device types | QA       | 8            | Medium   |

## Sprint 7: Initial Content Expansion

**Duration:** 2 weeks  
**Goal:** Add new content based on player demand and engagement metrics

### Sprint Backlog

#### Programming Tasks

| Task ID | Description                                     | Assignee | Story Points | Priority |
| ------- | ----------------------------------------------- | -------- | ------------ | -------- |
| P7-01   | Implement 1-2 new job types                     | Dev 1    | 13           | High     |
| P7-02   | Add new furniture sets and categories           | Dev 1    | 8            | High     |
| P7-03   | Expand vehicle customization options            | Dev 2    | 8            | Medium   |
| P7-04   | Create framework for seasonal events            | Dev 2    | 8            | High     |
| P7-05   | Implement first seasonal event                  | Dev 3    | 13           | High     |
| P7-06   | Add themed furniture collections                | Dev 3    | 5            | Medium   |
| P7-07   | Implement basic blueprint sharing system        | Lead Dev | 8            | Medium   |
| P7-08   | Add job specialization framework                | Lead Dev | 8            | Medium   |
| P7-09   | Create vehicle showcase event system            | Dev 1    | 5            | Low      |
| P7-10   | Implement enhanced mini-games for existing jobs | Dev 2    | 8            | Medium   |

#### Art Tasks

| Task ID | Description                          | Assignee     | Story Points | Priority |
| ------- | ------------------------------------ | ------------ | ------------ | -------- |
| A7-01   | Create assets for new job types      | Artist 1     | 13           | High     |
| A7-02   | Design new furniture sets            | Artist 1     | 8            | High     |
| A7-03   | Create seasonal event assets         | Artist 2     | 8            | High     |
| A7-04   | Design vehicle customization options | Artist 2     | 5            | Medium   |
| A7-05   | Create themed collection assets      | Both Artists | 8            | Medium   |

#### Design Tasks

| Task ID | Description                               | Assignee | Story Points | Priority |
| ------- | ----------------------------------------- | -------- | ------------ | -------- |
| D7-01   | Design new job gameplay mechanics         | Designer | 8            | High     |
| D7-02   | Create seasonal event activities          | Designer | 8            | High     |
| D7-03   | Design job specialization paths           | Designer | 5            | Medium   |
| D7-04   | Balance new content with existing systems | Designer | 5            | High     |
| D7-05   | Design vehicle showcase event rules       | Designer | 3            | Low      |

#### QA Tasks

| Task ID | Description                          | Assignee | Story Points | Priority |
| ------- | ------------------------------------ | -------- | ------------ | -------- |
| Q7-01   | Test new job gameplay                | QA       | 8            | High     |
| Q7-02   | Verify seasonal event functionality  | QA       | 5            | High     |
| Q7-03   | Test furniture and vehicle additions | QA       | 5            | Medium   |
| Q7-04   | Balance testing for new content      | QA       | 5            | High     |

---

## Sprint Planning Best Practices

### Before the Sprint

1. **Backlog Refinement:**

   - Review and update the product backlog
   - Ensure stories are properly sized and prioritized
   - Clarify acceptance criteria

2. **Capacity Planning:**

   - Consider team availability (vacations, meetings, etc.)
   - Account for non-development tasks
   - Be realistic about velocity

3. **Dependencies:**
   - Identify dependencies between tasks
   - Plan work to minimize blocking issues
   - Prepare contingency plans for critical dependencies

### During Sprint Planning

1. **Goal Setting:**

   - Establish a clear sprint goal
   - Ensure the team understands the purpose of the sprint
   - Connect tasks to the overall project vision

2. **Task Breakdown:**

   - Break down stories into specific tasks
   - Ensure tasks are small enough (1-2 days of work)
   - Assign clear owners for each task

3. **Commitment:**
   - Team should commit to the sprint backlog
   - Avoid overcommitting
   - Leave buffer for unexpected issues

### During the Sprint

1. **Daily Stand-ups:**

   - Focus on progress toward sprint goal
   - Identify blockers quickly
   - Adjust plans as needed

2. **Visibility:**

   - Keep the sprint board updated
   - Track progress visually
   - Highlight risks and issues

3. **Collaboration:**
   - Encourage pair programming for complex tasks
   - Hold design reviews for critical components
   - Maintain open communication channels

---

## Definition of Done

A task is considered "Done" when it meets all of the following criteria:

### For All Tasks

- Functionality is complete according to requirements
- Code/assets are committed to version control
- Documentation is updated
- Passes QA testing
- No known critical bugs

### For Programming Tasks

- Code follows established style guidelines
- Unit tests are written and passing
- Code has been reviewed by at least one other developer
- Performance meets target requirements

### For Art Tasks

- Assets meet visual style guidelines
- Assets are properly optimized
- Assets are integrated into the game
- Assets have been reviewed by the art lead

### For Design Tasks

- Design documentation is complete
- Design has been reviewed by the team
- Implementation matches design intent
- User experience has been validated

### For QA Tasks

- Test cases are documented
- All test scenarios have been executed
- Bug reports include clear reproduction steps
- Verification of fixes has been completed
