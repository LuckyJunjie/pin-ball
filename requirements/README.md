# Pinball Game - Requirements Documentation

This folder contains the requirements specification for the Pinball game project.

## Document Structure

### Version 1.0 Requirements
- **[Requirements.md](Requirements.md)** - Functional and non-functional requirements v1.0
- **[Technical-Requirements.md](Technical-Requirements.md)** - Platform, performance, and technical constraints v1.0

### Version 2.0 Requirements (NEW)
- **[Requirements-v2.0.md](Requirements-v2.0.md)** - Functional and non-functional requirements v2.0 (inherits v1.0 + adds monetization, mobile, upgrades)
- **[Technical-Requirements-v2.0.md](Technical-Requirements-v2.0.md)** - Technical requirements v2.0 (inherits v1.0 + adds mobile platform, IAP, ads, save system)

## Overview

Requirements documents specify **what** the game needs to do, without prescribing **how** it should be implemented. These documents define:

- Functional requirements (features and behaviors)
- Non-functional requirements (performance, usability, quality)
- Technical requirements (platform, engine, constraints)

## Requirements Categories

### Functional Requirements
Define what the game must do:
- Core gameplay mechanics (ball physics, flippers, obstacles)
- Scoring system
- Game state management
- User interface elements
- Visual feedback

### Non-Functional Requirements
Define quality attributes:
- Performance targets (60 FPS)
- Responsiveness (input latency)
- Usability (intuitive controls, visual clarity)
- Code quality (maintainability, extensibility)

### Technical Requirements
Define technical constraints:
- Platform and engine requirements (Godot 4.5)
- Input system specifications
- Physics system configuration
- Rendering requirements
- Architecture constraints

## Related Documentation

### Version 1.0 Design Documents
For v1.0 design and implementation details, see the [design/](../design/) folder:
- [Game Design Document (GDD)](../design/GDD.md) - Comprehensive game design v1.0
- [Technical Design](../design/Technical-Design.md) - Architecture and implementation v1.0
- [Component Specifications](../design/Component-Specifications.md) - Detailed component specs v1.0

### Version 2.0 Design Documents (NEW)
For v2.0 design and implementation details, see the [design-v2.0/](../design-v2.0/) folder:
- [Game Design Document v2.0](../design-v2.0/GDD-v2.0.md) - Comprehensive game design v2.0
- [Monetization Design](../design-v2.0/Monetization-Design.md) - Revenue systems design
- [Upgrade Systems](../design-v2.0/Upgrade-Systems.md) - Upgrade mechanics
- [Technical Design v2.0](../design-v2.0/Technical-Design-v2.0.md) - Architecture with monetization
- [Component Specifications v2.0](../design-v2.0/Component-Specifications-v2.0.md) - Enhanced component specs
- [Mobile Platform Specs](../design-v2.0/Mobile-Platform-Specs.md) - iOS/Android specifications
- See [design-v2.0/README.md](../design-v2.0/README.md) for complete document index

## Requirements Traceability

Requirements are numbered for traceability:
- **FR-X.Y**: Functional Requirements (v1.0)
- **FR-v2.X.Y**: Functional Requirements (v2.0 new)
- **NFR-X.Y**: Non-Functional Requirements (v1.0)
- **NFR-v2.X.Y**: Non-Functional Requirements (v2.0 enhanced)
- **TR-X.Y**: Technical Requirements (v1.0)
- **TR-v2.X.Y**: Technical Requirements (v2.0 new)

Each requirement can be traced from specification through design to implementation.

## Version Comparison

**v1.0 Requirements**:
- Desktop platform (Windows, macOS, Linux)
- Core pinball gameplay mechanics
- Keyboard controls
- Basic scoring system
- Sound effects

**v2.0 Requirements** (inherits all v1.0 + adds):
- Mobile platform (iOS, Android) - Primary
- Monetization systems (Shop, IAP, Ads, Battle Pass)
- Currency system (Coins and Gems)
- Upgrade systems (Ball, Flipper, Ramp upgrades)
- Daily systems (Login rewards, Challenges)
- Cosmetic customization
- Touch controls
- Data persistence and save system
- Platform-specific integrations (StoreKit, Google Play Billing, AdMob)
