# LockIn

LockIn is a clean, distraction-free focus and productivity app designed to help you commit to deep work without pressure, ads, or gimmicks.

It combines a **timer**, **stopwatch**, and **automatic session tracking** into a single, intentional experience focused on consistency rather than intensity.

The app is currently in **pre-alpha** and under active development.

---

## What LockIn Does

- Focus using a **Timer** or **Stopwatch**
- Locks controls once a session is underway to reduce distraction
- Automatically tracks completed focus sessions
- Keeps accurate time even when the app is backgrounded
- Organise sessions using **custom categories with icons**
- Stores productivity history privately
- No ads, paywalls, or artificial pressure systems

---

## How the Focus System Works

- Choose **Timer** or **Stopwatch**
- Start a session intentionally
- Controls lock after a short grace period
- Sessions are recorded automatically on completion
- Categories help you understand *what* you’re focusing on, not just *how long*

The goal is commitment and clarity — not gamification.

---

## Design Philosophy

LockIn is built around a few simple principles:

- No ads  
- No dark patterns  
- No aggressive streaks or punishments  
- No selling attention  

Your data stays private.  
Any future monetisation would be optional and donation-based.

---

## Current State

- Status: **Pre-alpha / Prototype**
- Platform: **iOS**
- Backend: **Supabase**
- Architecture: **SwiftUI + MVVM**

Breaking changes are expected while the app is in active development.

---

## Planned Features

- Improved Light / Dark mode theming
- Haptic feedback for key interactions
- Better session summaries and insights
- Optional friend features for accountability
- Long-term progress trends

---

## Project Structure

```
LockIn2
├── LockIn2
│   ├── ConfigFiles
│   │   ├── Configs
│   │   ├── DatabaseManager
│   │   ├── Secrets
│   │   └── Supabase
│   ├── Views
│   │   ├── AuthenticationViews
│   │   │   └── AuthViewModel
│   │   ├── CategoryViews
│   │   │   ├── AddCategoryCardView
│   │   │   ├── CategoriesCardView
│   │   │   ├── CategoryView
│   │   │   └── CategoryViewModel
│   │   ├── ClockControlViews
│   │   │   ├── ClockControlView
│   │   │   ├── StopwatchControlView
│   │   │   └── TimerControlView
│   │   ├── FocusSessionViews
│   │   │   ├── FocusSessionView
│   │   │   └── FocusSessionViewModel
│   │   ├── FriendListViews
│   │   │   └── FriendListView
│   │   ├── ModifierViews
│   │   │   ├── AppBackgroundModifier
│   │   │   ├── ButtonStyles
│   │   │   ├── CapsuleSegmentPicker
│   │   │   ├── FloatingTabView
│   │   │   └── PopupOverlayView
│   │   └── SettingViews
│   │       └── SettingsView
│   ├── Assets
│   ├── Changelog
│   ├── LockIn2App
│   └── MainView
├── README.md
└── Info
```

---

## Database Overview

LockIn uses **Supabase** for authentication and data storage.

### Authentication (`auth.users`)
Managed by Supabase Auth.

- `id` (`uuid`) — primary identifier for each user  
All user data tables reference this via `userID`.

---

### FocusSession
Stores completed focus sessions.

| Column | Type | Description |
|---|---|---|
| `id` | `int8` | Primary key |
| `createdAt` | `timestamptz` | Session creation time |
| `category` | `text` | Category name at time of session |
| `duration` | `int4` | Session length |
| `userID` | `uuid` | References `auth.users.id` |

---

### Category
User-defined categories for organising sessions.

| Column | Type | Description |
|---|---|---|
| `id` | `int8` | Primary key |
| `userID` | `uuid` | References `auth.users.id` |
| `text` | `text` | Category name |
| `categoryIcon` | `text` | Optional SF Symbol name |

---

### Friendship
Models friend relationships (future feature).

| Column | Type | Description |
|---|---|---|
| `id` | `int8` | Primary key |
| `status` | `friendshipStatus` | pending / accepted / blocked |
| `created_at` | `timestamptz` | Creation time |
| `requesterID` | `uuid` | Request sender |
| `addresseeID` | `uuid` | Request receiver |

---

## Version History

See **`CHANGELOG.md`** for detailed updates and release notes.

---

## Author

Built by **Multazim Mesbah**
📧 multazim.mesbah@gmail.com  
🔗 [LinkedIn](https://www.linkedin.com/in/multazim-mesbah)


An independent project developed in public as both a learning exercise and a long-term personal tool.

---
