# Life in Bloom

A life simulation game built on the Roblox platform that combines creative freedom with dynamic multiplayer interactions.

## 🌟 Overview

**Life in Bloom** is an expansive life simulation game that combines the creative freedom of Sims-style house building with dynamic, open-world multiplayer interactions. Players can craft their own homes, build careers in various flexible jobs, own and customize vehicles, and explore a richly detailed environment—all while enjoying cooperative and solo play.

**Target Audience:** Teens  
**Platform:** Roblox  
**Monetization Model:** Free-to-play with cosmetic and convenience-based purchases (no pay-to-win)

## 🎮 Core Gameplay

### 🏠 Home & Creative Building

- Start with a modest plot and a "starter" house
- Use an intuitive building tool to place furniture, change wall textures, and expand rooms/floors
- Homes act as a personal retreat and social hub, and can be shared with friends

### 💼 Career & Progression

- Choose from a variety of flexible job roles (Chef, Taxi Driver, Police Officer, and more)
- Each job has its own independent XP pool and level system
- Switch jobs freely, with mini-games/tasks that unlock recipes, tools, or abilities as you progress

### 🚗 Vehicle Ownership & Exploration

- Purchase and customize vehicles ranging from basic bikes to sports cars
- Navigate a large open world featuring distinct zones and hidden secrets
- Experience seasonal changes and occasional travel events

### 👥 Social & Cooperative Play

- Meet other players in the central town hub
- Form groups for cooperative activities
- Trade items and collectibles through a secure system
- Participate in community events, building contests, and seasonal festivals

## 🛠️ Technical Architecture

The game is built using Roblox's platform capabilities with a client-server architecture:

- **Server-Side:** Handles authoritative game logic, data persistence, and security validation
- **Client-Side:** Manages user interface, input handling, and visual effects
- **Shared Modules:** Common utilities and configuration used by both client and server

### Core Systems

- Building System
- Job System
- Vehicle System
- World Management
- Social System
- Progression System
- Economy System

### UI System Architecture

The game uses a modular UI architecture designed for maintainability and consistency:

- **BaseUI:** Foundation layer with utility functions for creating basic UI elements and consistent styling
- **CoreComponents:** Reusable UI components (stat displays, progress bars, notifications) used throughout the game
- **Modal System:** Modular window framework using `ModalBase` as a foundation for all dialog windows
- **Screens:** Full-screen UI layouts including the main game interface and menus
- **Controllers:** Handle the logic and data flow between game systems and UI elements

Key UI Features:
- Consistent visual styling with shared color schemes and animations
- Responsive design that adapts to different screen sizes
- Streamlined notification system for player feedback
- Modular components that can be reused across different screens
- Clean separation between UI presentation and game logic

### Data Management

Player data is securely stored using Roblox's DataStoreService, with regular auto-saves and backup systems to prevent data loss.

## 📅 Development Roadmap

The development is structured into four main phases:

### Phase 1: MVP Development (8 weeks)

- Core gameplay systems functional
- Basic world and building mechanics
- 2-3 job types playable
- Initial testing complete

### Phase 2: Content Expansion (8 weeks)

- Additional job types
- Expanded furniture catalog and building options
- More vehicle types and customization
- Enhanced world with all planned zones

### Phase 3: Social & Community Features (6 weeks)

- Friend system and social hub enhancements
- Party and group mechanics
- Trading system
- Community events framework

### Phase 4: Polish & Optimization (4 weeks)

- Performance optimization
- Bug fixes and stability improvements
- Visual polish and effects
- Final balance adjustments

### Post-Launch Support

- Weekly maintenance and bug fixes
- Monthly content updates
- Seasonal events and major features
- Community-driven improvements

## 🔄 Current Development Status

The project is currently in the MVP development phase, focusing on implementing core gameplay systems and establishing the technical foundation.

### Current Sprint Focus

- Building system implementation
- Initial job mini-games
- Basic vehicle controls
- World environment development

## 💰 Monetization Strategy

Life in Bloom uses a fair monetization model that focuses on cosmetic and convenience items:

- **All core gameplay** is accessible to free players
- **Premium items** are primarily cosmetic or convenience-based
- **Dual currency system** with in-game currency earned through gameplay and premium currency purchased with Robux

## 👥 Team

- Developers: 3
- Artists: 2
- Game Designer: 1
- QA Tester: 1 (part-time)

## 📚 Documentation

Detailed documentation is available in the `docs/` directory:

- [Technical Design Document](docs/technical-design-draft.md)
- [Gameplay Documentation](docs/gameplay/gameplay-documentation.md)
- [Infrastructure Development](docs/technical/infrastructure-development-documentation.md)
- [Project Roadmap](docs/roadmap/project-roadmap.md)
- [MVP Phase](docs/roadmap/mvp-phase.md)
- [Sprint Planning](docs/roadmap/sprint-planning.md)

## 📝 License

© 2025 Life in Bloom Team. All rights reserved.
