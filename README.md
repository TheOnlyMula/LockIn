# LockIn

LockIn is a **deliberately minimal focus and productivity app** built for people who want to commit to deep work without ads, or paywalls.

It combines a **timer**, **stopwatch**, and **automatic session logging** into a single, calm experience focused on consistency and intent.

The app is currently in **pre‑alpha** and under active development. See changelogs for current version and features. 

---

## Core Features

- Focus using a **Timer** or **Stopwatch**
- Controls lock shortly after starting to reduce mid‑session distractions
- Sessions are **automatically recorded on completion**
- Accurate time tracking even when the app is backgrounded
- Organise sessions using **custom categories with icons**
- No ads, paywalls, or artificial pressure systems

---

## How the Focus System Works

1. Choose **Timer** or **Stopwatch**
2. Select an optional category
3. Start a session intentionally
4. Controls lock after a short grace period
5. On completion, the session is logged automatically

Categories are used to understand *what* you focused on.

---

## Current State

- **Status:** Pre‑alpha / Prototype  
- **Platform:** iOS  
- **UI:** SwiftUI
- **Architecture:** MVVM 
- **Backend:** Supabase (PostgreSQL + Auth + RLS)

Breaking changes are expected while the app is under active development.

---

## Database & Privacy Model

LockIn uses **Supabase** for authentication and data storage.

### Authentication
- Supabase Auth is used
- `auth.users.id` (UUID) is the canonical user identifier
- All user‑owned data is associated with this ID

### Row Level Security (RLS)
All user‑owned tables have **RLS enabled**.

Policies ensure:
- Users can only **read, insert, update, and delete their own data**
- Access is restricted using `auth.uid() = userID`
- Cross‑user access is not possible via the Data API

### Tables
- **Category** – user‑defined focus categories
- **FocusSession** – completed focus sessions (auto‑logged)
- **Relationship** – friend / connection relationships (RLS enabled, policies pending)

> Full schema and security documentation lives in `schema.sql`.

---

## Planned Features

- Improved Light / Dark mode theming
- Haptic feedback for key interactions
- Better session summaries and insights
- Optional friend features for accountability
- Long‑term focus trends

---

## Project Structure

```
LockIn
├── LockIn
│   ├── ConfigFiles
│   │   ├── Configs
│   │   ├── DatabaseManager
│   │   ├── Secrets
│   │   └── Supabase
│   ├── Views
│   │   ├── AuthenticationViews
│   │   ├── CategoryViews
│   │   ├── ClockControlViews
│   │   ├── FocusSessionViews
│   │   ├── RelationshipViews
│   │   ├── ModifierViews
│   │   └── SettingViews
│   ├── Assets
│   ├── Info
│   ├── LockInApp.swift
│   └── MainView.swift
├── Changelog
├── .gitignore
├── README.md
└── schema.sql
```

---

## Version History

See **`CHANGELOG.md`** for detailed updates and release notes.

---

## Author

Built by **Multazim Mesbah**  
📧 multazim.mesbah@gmail.com  
🔗 [LinkedIn](https://www.linkedin.com/in/multazim-mesbah)

An independent project developed in public as both a learning exercise and a long‑term personal tool.
