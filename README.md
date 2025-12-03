# Family Tree (SwiftUI · macOS)

An interactive family-tree builder for macOS that lets you create profiles, connect relatives (and pets), and arrange a visual graph with drag-and-drop, zoom/pan, and inline editing. State is persisted locally so members, connections, and layout survive app restarts.

## Quick Views:

![Member Page](img/Edit_members.png)

![Family Tree Page](img/Edit_family_tree.png)


## Features
- Main menu with story/onboarding, profile setup, add/edit member flows, and dual “My Tree” views (list vs. graph).
- Member profiles: emoji/avatar picker, age/relationship fields, validation, and inline success feedback.
- Graph editing: drag from the member list onto the canvas, reposition nodes, pinch/scroll zoom, pan, draw/delete connections (double-tap a line), and hide members without losing data.
- Relationship logic: bidirectional edges with per-edge counts (capped at 5) and role-aware mapping for pets, spouses, and multi-generation ties to keep labels sensible.
- Persistence: members, user profile, and node positions are JSON-encoded to `UserDefaults` for instant, offline storage.
- UX helpers: movable “💡” tip button with contextual guidance on each screen.

## Architecture
- `Member` (Data): Codable, Identifiable node with connections and connection counts; initialization backfills counts for legacy data.
- `TreeDataManager` (State): `ObservableObject` holding members, user profile, positions, and view flags; centralizes add/update/delete, drag position updates, and relationship cleanup when hiding/removing nodes.
- Views:
  - `MainMenuView` hosts navigation and landing.
  - `ProfileSetupView`, `AddMemberView`, `EditMemberView`/`EditMemberFormView` handle profile CRUD with emoji picker.
  - `TreeView` offers list vs. graph modes; list shows connection summaries, graph renders nodes/edges with hide/delete controls.
  - `CombinedTreeView` + `FamilyTreeViewWithDrop` power the editable canvas with drag-and-drop, zoom/pan, and connection drawing/deletion.
  - Shared components: `MemberNode`, `ConnectionLine`, `TipButton`, `TipBoxView`, `EmojiPickerView`.

## Running Locally
1) Requirements: macOS 13+ and Xcode 15+ (SwiftUI + AppKit).  
2) Open `FM_test.xcodeproj` in Xcode.  
3) Select the `FM_testApp` scheme and run (⌘R).  
4) In the app: open the menu (tree icon), set up “My Profile,” then add members, connect them on “Edit Tree,” and explore “My Tree.”

## Project Layout
- `FM_testApp.swift` – app entry.
- `ContentView.swift` – root view wiring `TreeDataManager` into `MainMenuView`.
- `Member.swift` – data model with connection counts.
- `TreeDataManager.swift` – state/persistence layer.
- `MainMenuView.swift`, `MenuTab.swift` – navigation shell.
- `ProfileSetupView.swift`, `AddMemberView.swift`, `EditMemberView.swift`, `EditMemberFormView.swift` – profile/member CRUD.
- `TreeView.swift` – list + read-only graph view with hide/delete.
- `CombinedTreeView.swift`, `FamilyTreeViewWithDrop.swift` – editable graph canvas with drag/drop, zoom/pan, connection logic.
- `SharedComponents.swift`, `EmojiPickerView.swift`, `StoryView.swift` – reusable UI and onboarding.

## Notes and Future Ideas
- Persistence is local to the device (UserDefaults); consider CloudKit/Core Data for sync.
- Connection roles are heuristic; extending them with explicit relation metadata could improve clarity for complex trees.
- No automated tests are included; snapshot/UI tests would help guard gesture-heavy flows.
