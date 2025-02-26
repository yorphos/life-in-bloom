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
- **Sprint Planning:** First day of sprint (1-2 hours)
- **Daily Progress Check:** Brief daily review of progress (5-10 minutes)
- **Sprint Review:** Last day of sprint (30-60 minutes)
- **Sprint Retrospective:** Last day of sprint (30 minutes)

### Task Estimation

Tasks are estimated using story points on a Fibonacci scale (1, 2, 3, 5, 8, 13):

- **1 point:** Very simple task, few hours of work
- **2-3 points:** Straightforward task, 1-2 days of work
- **5 points:** Moderate complexity, 3-4 days of work
- **8 points:** Complex task, up to a week of work
- **13 points:** Very complex task, should be broken down further

### Team Capacity

- **Solo Developer:** ~40-50 points per sprint (handling all aspects of development)

---

## Sprint 1: Technical Foundation

**Duration:** Weeks 1-2  
**Goal:** Establish core architecture and basic world

### Sprint Backlog

#### Development Tasks

| Task ID | Description                                                   | Story Points | Priority |
| ------- | ------------------------------------------------------------- | ------------ | -------- |
| T1-01   | Set up project structure and coding standards                 | 3            | High     |
| T1-02   | Implement player controller with basic movement               | 5            | High     |
| T1-03   | Create camera system with first/third person views            | 5            | High     |
| T1-04   | Develop data service for saving/loading                       | 8            | High     |
| T1-05   | Implement basic world streaming                               | 5            | Medium   |
| T1-06   | Create simple terrain and zone boundaries                     | 5            | High     |
| T1-07   | Establish remote event system for client-server communication | 8            | High     |
| T1-08   | Set up basic UI framework                                     | 5            | Medium   |
| T1-09   | Create basic player character model                           | 5            | High     |
| T1-10   | Design simple environment assets (trees, buildings)           | 8            | High     |
| T1-11   | Create basic textures for terrain                             | 5            | High     |
| T1-12   | Design placeholder UI elements                                | 5            | Medium   |
| T1-13   | Create simple NPC models                                      | 5            | Medium   |
| T1-14   | Define world layout and zone purposes                         | 5            | High     |
| T1-15   | Design player controls and camera behavior                    | 3            | High     |

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

#### Development Tasks

| Task ID | Description                                          | Story Points | Priority |
| ------- | ---------------------------------------------------- | ------------ | -------- |
| T2-01   | Develop grid system for placement                    | 8            | High     |
| T2-02   | Implement furniture placement logic                  | 5            | High     |
| T2-03   | Create collision detection for placement             | 5            | High     |
| T2-04   | Implement furniture data structure                   | 3            | High     |
| T2-05   | Create customization system for colors and textures  | 8            | High     |
| T2-06   | Build save/load functionality for houses             | 5            | High     |
| T2-07   | Develop build mode UI with catalog                   | 8            | High     |
| T2-08   | Implement undo/redo functionality                    | 5            | Medium   |
| T2-09   | Create preview mode for placement                    | 3            | Medium   |
| T2-10   | Create basic furniture models (beds, tables, chairs) | 8            | High     |
| T2-11   | Design kitchen and bathroom items                    | 8            | High     |
| T2-12   | Create wall and floor textures                       | 5            | High     |
| T2-13   | Design build mode UI elements                        | 8            | High     |
| T2-14   | Design furniture catalog organization                | 3            | High     |
| T2-15   | Create build mode UX flow                            | 5            | High     |

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

#### Development Tasks

| Task ID | Description                                           | Story Points | Priority |
| ------- | ----------------------------------------------------- | ------------ | -------- |
| T3-01   | Develop job framework with progression tracking       | 8            | High     |
| T3-02   | Implement Chef mini-game (cooking puzzle)             | 8            | High     |
| T3-03   | Create Taxi Driver gameplay (passenger delivery)      | 8            | High     |
| T3-04   | Build Police Officer activities (patrol and response) | 8            | High     |
| T3-05   | Implement currency system and rewards                 | 5            | High     |
| T3-06   | Develop job selection and progress UI                 | 5            | High     |
| T3-07   | Create job locations in the world                     | 5            | High     |
| T3-08   | Implement job-specific animations                     | 5            | Medium   |
| T3-09   | Create job switching functionality                    | 3            | Medium   |
| T3-10   | Create Chef job assets and location                   | 8            | High     |
| T3-11   | Design Taxi Driver assets and location                | 8            | High     |
| T3-12   | Create Police Officer assets and location             | 8            | High     |
| T3-13   | Design job UI elements                                | 5            | High     |
| T3-14   | Design Chef mini-game mechanics                       | 5            | High     |
| T3-15   | Create Taxi Driver route system                       | 5            | High     |

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

#### Development Tasks

| Task ID | Description                                  | Story Points | Priority |
| ------- | -------------------------------------------- | ------------ | -------- |
| T4-01   | Implement vehicle controls and physics       | 8            | High     |
| T4-02   | Create vehicle spawning system               | 5            | High     |
| T4-03   | Implement basic vehicle customization        | 5            | Medium   |
| T4-04   | Create vehicle collision system              | 5            | High     |
| T4-05   | Integrate building, job, and vehicle systems | 8            | High     |
| T4-06   | Implement basic tutorial and onboarding      | 5            | High     |
| T4-07   | Optimize performance for target devices      | 8            | High     |
| T4-08   | Fix critical bugs                            | 13           | High     |
| T4-09   | Implement basic achievement system           | 5            | Low      |
| T4-10   | Create settings menu                         | 3            | Medium   |
| T4-11   | Create car model and textures                | 8            | High     |
| T4-12   | Design bicycle model and textures            | 5            | High     |
| T4-13   | Create vehicle customization assets          | 5            | Medium   |
| T4-14   | Design tutorial UI elements                  | 5            | High     |
| T4-15   | Design vehicle controls and handling         | 5            | High     |

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

#### Development Tasks

| Task ID | Description                                   | Story Points | Priority |
| ------- | --------------------------------------------- | ------------ | -------- |
| T5-01   | Implement basic LOD system for complex assets | 8            | High     |
| T5-02   | Add priority-based asset loading              | 5            | High     |
| T5-03   | Enhance object pooling for frequent objects   | 5            | High     |
| T5-04   | Implement basic occlusion culling             | 8            | Medium   |
| T5-05   | Address critical bugs from initial feedback   | 13           | Critical |
| T5-06   | Improve error handling and recovery           | 5            | High     |
| T5-07   | Enhance data backup and recovery systems      | 8            | High     |
| T5-08   | Optimize network code for better stability    | 8            | High     |
| T5-09   | Create LOD versions of high-polygon assets    | 13           | High     |
| T5-10   | Optimize texture sizes and formats            | 5            | High     |
| T5-11   | Reduce polygon count on non-essential items   | 8            | Medium   |
| T5-12   | Analyze player feedback and prioritize fixes  | 5            | High     |
| T5-13   | Refine tutorial based on player confusion     | 8            | High     |
| T5-14   | Balance economy based on initial metrics      | 5            | High     |
| T5-15   | Perform testing across different device types | 8            | High     |

## Sprint 6: UI/UX Improvements

**Duration:** 2 weeks  
**Goal:** Enhance the user experience based on initial player feedback

### Sprint Backlog

#### Development Tasks

| Task ID | Description                                 | Story Points | Priority |
| ------- | ------------------------------------------- | ------------ | -------- |
| T6-01   | Implement contextual help system            | 8            | High     |
| T6-02   | Add improved navigation and wayfinding      | 5            | High     |
| T6-03   | Refine control schemes based on feedback    | 5            | High     |
| T6-04   | Implement UI customization options          | 8            | Medium   |
| T6-05   | Create in-game wiki framework               | 8            | Medium   |
| T6-06   | Add milestone rewards for early progression | 5            | High     |
| T6-07   | Implement favorites bar for quick access    | 5            | Medium   |
| T6-08   | Add UI themes and visual styles             | 8            | Low      |
| T6-09   | Enhance accessibility features              | 8            | High     |
| T6-10   | Design contextual help UI elements          | 5            | High     |
| T6-11   | Create improved navigation indicators       | 5            | High     |
| T6-12   | Design UI theme variations                  | 8            | Medium   |
| T6-13   | Create icons for favorites bar              | 3            | Medium   |
| T6-14   | Design contextual help content              | 8            | High     |
| T6-15   | Test accessibility and UI customization     | 5            | High     |

## Sprint 7: Initial Content Expansion

**Duration:** 2 weeks  
**Goal:** Add new content based on player demand and engagement metrics

### Sprint Backlog

#### Development Tasks

| Task ID | Description                                     | Story Points | Priority |
| ------- | ----------------------------------------------- | ------------ | -------- |
| T7-01   | Implement 1-2 new job types                     | 13           | High     |
| T7-02   | Add new furniture sets and categories           | 8            | High     |
| T7-03   | Expand vehicle customization options            | 8            | Medium   |
| T7-04   | Create framework for seasonal events            | 8            | High     |
| T7-05   | Implement first seasonal event                  | 13           | High     |
| T7-06   | Add themed furniture collections                | 5            | Medium   |
| T7-07   | Implement basic blueprint sharing system        | 8            | Medium   |
| T7-08   | Add job specialization framework                | 8            | Medium   |
| T7-09   | Create vehicle showcase event system            | 5            | Low      |
| T7-10   | Create assets for new job types                 | 13           | High     |
| T7-11   | Design new furniture sets                       | 8            | High     |
| T7-12   | Create seasonal event assets                    | 8            | High     |
| T7-13   | Design new job gameplay mechanics               | 8            | High     |
| T7-14   | Create seasonal event activities                | 8            | High     |
| T7-15   | Test new content and balance with existing game | 8            | High     |

---

## Sprint Planning Best Practices

### Before the Sprint

1. **Backlog Refinement:**

   - Review and update the product backlog
   - Ensure stories are properly sized and prioritized
   - Clarify acceptance criteria for each task

2. **Capacity Planning:**

   - Consider personal availability and energy levels
   - Account for non-development tasks (admin, planning, etc.)
   - Be realistic about velocity as a solo developer

3. **Dependencies:**
   - Identify dependencies between tasks
   - Sequence work to minimize blocking issues
   - Prepare alternative tasks to work on if blockers occur

### During Sprint Planning

1. **Goal Setting:**

   - Establish a clear, focused sprint goal
   - Keep the goal visible during the sprint
   - Connect tasks to the overall project vision

2. **Task Breakdown:**

   - Break down stories into specific, manageable tasks
   - Ensure tasks are small enough (ideally 1 day or less)
   - Group similar tasks for efficiency (e.g., all UI work together)

3. **Commitment:**
   - Be honest about what can realistically be accomplished
   - Avoid overcommitting to prevent burnout
   - Leave buffer for unexpected issues and challenges

### During the Sprint

1. **Daily Progress Check:**

   - Brief daily review of progress toward sprint goal
   - Identify any blockers or challenges early
   - Adjust plans as needed based on progress

2. **Visibility:**

   - Keep a visual task board to track progress
   - Update task status regularly
   - Document issues and decisions for future reference

3. **Focus & Balance:**
   - Minimize context switching between different types of tasks
   - Balance creative and technical work to maintain energy
   - Take regular breaks to maintain productivity and perspective

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
- Self-review of code quality and structure
- Performance meets target requirements

### For Art Tasks

- Assets meet visual style guidelines
- Assets are properly optimized
- Assets are integrated into the game
- Visual consistency is maintained across assets

### For Design Tasks

- Design documentation is complete
- Design is consistent with overall game vision
- Implementation matches design intent
- User experience has been self-tested

### For Testing Tasks

- Test cases are documented
- All test scenarios have been executed
- Issues are properly documented with reproduction steps
- Fixes have been verified through regression testing
