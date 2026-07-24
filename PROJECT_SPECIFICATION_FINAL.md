
# Habit Tracker Project Specification (Final)

> **Status:** Architecture Freeze (V2 Approved)
>
> This document is the single source of truth for the implementation of the Habit Tracker application. All implementation decisions must follow this specification unless an explicit change is approved.

# Table of Contents
1. Project Vision
2. Technology Stack
3. Core Principles
4. Project Rules
5. Architecture
6. Folder Structure
7. Database
8. Features
9. UI / UX
10. Widget System
11. Notifications
12. Gamification
13. AI Coach
14. Coding Standards
15. Design Tokens
16. Development Roadmap
17. AI Development Instructions

---

# 1. Project Vision

Mission:
Build the most frictionless, aesthetically refined, reliable, offline-first habit tracking application available.

Primary goals:

- Offline-first
- Zero-latency interactions
- Beautiful premium UI
- Reliable reminders
- Interactive widgets
- Long-term habit retention
- Scalable architecture

---

# 2. Technology Stack

Framework
- Flutter (latest stable)

Native
- Kotlin
- Swift

Architecture
- Feature-first Clean Architecture

State
- flutter_bloc

Database
- Drift (SQLite)

Navigation
- go_router

Dependency Injection
- get_it
- injectable

Models
- freezed
- json_serializable

Sync
- Local-first architecture
- PowerSync/ElectricSQL (or equivalent)

---

# 3. Core Principles

The application must prioritize:

- Readability
- Maintainability
- Scalability
- Performance
- Accessibility
- Testability
- Offline-first reliability
- Consistent UX

Code should remain understandable years later.

---

# 4. Project Rules

These rules are mandatory.

- Never rewrite approved architecture.
- Never change folder structure without justification.
- Never introduce packages without explanation.
- Never generate placeholder implementations.
- Every phase must compile.
- Follow Clean Architecture.
- Feature-first organization only.
- Immutable models with freezed.
- BLoC only.
- Production-quality code.
- Never remove existing functionality.
- Never simplify features for convenience.

---

# 5. Architecture

Layers:

Domain
- Entities
- Repository Interfaces
- Use Cases

Data
- Drift
- DTOs
- Mappers
- Repository Implementations

Presentation
- Pages
- Widgets
- BLoCs

Native
- Widgets
- Notifications
- Health integrations
- Platform channels

---

# 6. Folder Structure

```text
lib/
 core/
 features/
   analytics/
   gamification/
   habit_tracking/
 main.dart

android/
ios/
```

Feature folders contain:

- data
- domain
- presentation

---

# 7. Database

Engine:

Drift SQLite

Habits

- id
- title
- icon
- color
- frequency_type
- habit_type
- target_value
- target_unit
- health_metric_id
- is_archived

Habit Logs

- id
- habit_id
- target_date
- status
- current_value
- is_frozen

---

# 8. Features

Core

- Boolean habits
- Numeric habits
- Timer habits

Advanced

- NLP habit creation
- Vacation Mode
- Health Connect
- HealthKit
- Offline support
- Cloud sync
- Statistics
- Streaks
- Categories
- Templates
- Import / Export

---

# 9. UI / UX

Design goals

- Material Design 3
- Dynamic colors
- One-handed usability
- Premium animations
- High information density
- Minimalist interface

---

# 10. Widget System

Interactive widgets

Android

- Glance
- Checkbox widgets

iOS

- Interactive WidgetKit

Widget Types

- Quick Complete
- Dashboard
- Heatmap

Future Enhancements

- Adaptive time-of-day widgets
- Location-aware widgets
- Focus widgets

---

# 11. Notifications

Requirements

- Local-first
- Action buttons
- Exact alarms
- Battery optimization onboarding
- BOOT_COMPLETED recovery
- Offline capable

---

# 12. Gamification

Quest Lines

Skill Trees

Visual Unlocks

Regional Milestones

Rare cosmetic rewards

---

# 13. AI Coach

Not a chatbot.

Responsibilities

- Habit suggestions
- Reminder optimization
- Monthly insights
- Friction detection
- Behavioral coaching

---

# 14. Coding Standards

- Conventional Commits
- const where possible
- RepaintBoundary for heavy UI
- Golden tests
- Unit tests for BLoCs
- Repository testing
- Immutable state

---

# 15. Design Tokens

Primary: #2563EB

Success: #10B981

Error: #EF4444

Warning: #F59E0B

Radius

- 16dp

Spacing

- 8
- 16
- 24
- 32

Animation

- 300ms default

Typography

- Material 3

---

# 16. Development Roadmap

Phase 1

Infrastructure

- Project setup
- Theme
- Routing
- DI
- Drift initialization
- Sync scaffold

Phase 2

Domain & Data

Phase 3

Dashboard

Phase 4

Habit CRUD

Phase 5

Habit Loop

Phase 6

Notifications

Phase 7

Widgets

Phase 8

Gamification

Phase 9

Analytics

Phase 10

Cloud Sync

Phase 11

AI Coach

Phase 12

Testing & Polish

---

# 17. AI Development Instructions

Treat this document as the project constitution.

Before generating code:

1. Read this specification completely.
2. Follow the approved architecture.
3. Generate code only for the requested phase.
4. Explain every dependency.
5. List every created file.
6. Show updated folder structure.
7. Ensure the project compiles.
8. Perform a self-review.
9. Report bugs before finishing.
10. Do not generate future phases unless requested.
11. Do not contradict this specification without explaining why.
