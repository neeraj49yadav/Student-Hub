# 🎓 Student Utility Hub — Master Project Documentation

**Project Name:** Student Utility Hub  
**Platform:** Flutter (Android V1, iOS V2, Web V3)  
**Primary Target:** College, University, Competitive Exam, and School Students  
**Architecture:** Feature-First Layered Architecture with Offline-First Local Persistence  
**Design System:** Material 3 (Dynamic Color, Light & Dark Mode)  
**Initial Release:** Version 1.0.0+1 (Offline-First, Zero Backend Server Cost)

---

## 1. Executive Summary & Vision

Student Utility Hub is designed as an all-in-one student workspace that replaces fragmented single-purpose utilities (CGPA apps, attendance counters, Pomodoro timers, separate note apps, and deadline trackers).

### Core Value Proposition
> *"Everything a student needs for college, in one simple, fast, and privacy-respecting offline app."*

### Key Tenets
1. **Zero-Latency Offline-First**: No mandatory login, no backend API dependencies, zero cloud sync delay, and 100% privacy (student data resides exclusively on device).
2. **Action-Driven Utility**: Tools don't just calculate numbers—they answer practical student decisions (e.g., *"How many classes can I skip before 75%?"*, *"What marks do I need in finals to achieve an 8.5 SGPA?"*).
3. **Integrated Productivity**: Pomodoro sessions feed into weekly study analytics; timetable detects current & upcoming lectures; exam countdowns alert upcoming preparation sprints.

---

## 2. System Architecture

The application adopts a **Feature-First / Clean Layering** pattern for maintainability, zero circular dependencies, and high modularity:

```
lib/
├── main.dart                      # App entry point, Service initializers, Root MultiProvider/ChangeNotifier
├── core/
│   ├── constants/
│   │   ├── app_constants.dart     # Global keys, grade maps, conversion constants
│   │   └── app_colors.dart        # Material 3 color palettes & gradients
│   ├── theme/
│   │   └── app_theme.dart         # Material 3 light/dark ThemeData & typography
│   ├── services/
│   │   ├── storage_service.dart   # JSON/Key-Value persistent local repository
│   │   ├── notification_service.dart # Local schedule reminders abstraction
│   │   └── monetization_service.dart # AdMob & In-App Purchase mock/engine
│   └── widgets/
│       ├── custom_card.dart       # Reusable Glass/M3 card surface
│       ├── primary_button.dart    # Styled action buttons
│       └── ad_banner_placeholder.dart # Non-intrusive banner ad container
├── features/
│   ├── home/                      # Dynamic dashboard, progress rings, upcoming cards
│   ├── calculator/
│   │   ├── cgpa_calculator.dart   # Multi-semester CGPA engine (10-pt & 4-pt)
│   │   ├── sgpa_calculator.dart   # Semester GPA subject calculator
│   │   ├── attendance_calculator.dart # Smart attendance & skip/need predictor
│   │   ├── percentage_calculator.dart # Target marks & percentage solver
│   │   └── age_calculator.dart    # Precise age, days lived, birthday countdown
│   ├── converter/
│   │   ├── unit_converter.dart    # 8-category multi-unit conversion engine
│   │   └── number_system_converter.dart # Binary / Decimal / Octal / Hex converter
│   ├── timetable/                 # Weekly Mon-Sun timetable & current class detector
│   ├── pomodoro/                  # Focus/break timer, presets & focus session logs
│   ├── exam/                      # Multi-exam countdown & syllabus notes
│   ├── assignments/               # Deadlines, priority tags & progress tracking
│   ├── notes/                     # Quick subject notes, tags, search & pin
│   ├── checklist/                 # Interactive to-do checklists
│   ├── progress/                  # Study statistics & academic overview
│   ├── premium/                   # ₹49/₹99/₹149 one-time tiers & Pro feature unlock
│   └── settings/                  # Theme switcher, notifications, privacy policy
└── shared/
    └── models/
        ├── academic_models.dart   # Subject, Semester, CGPARecord
        ├── attendance_record.dart # Attendance data & target goals
        ├── timetable_entry.dart   # Weekly class schedule slot
        ├── task_models.dart       # Assignment, ChecklistItem, ExamEntry
        └── note_model.dart        # Note item with timestamps & tags
```

---

## 3. Data Flow & Offline Strategy

1. **Local State & Persistence**:
   - `StorageService` initializes with `SharedPreferences` to manage structured JSON datasets:
     - `hub_settings`: Theme mode, notification permissions, Pro/Remove-Ads status.
     - `hub_semesters`: Array of semester GPA calculations & subjects.
     - `hub_attendance`: List of tracked subjects with attended/total class counts.
     - `hub_timetable`: Mon-Sun scheduled lectures.
     - `hub_assignments`: Course assignments with deadlines & priority.
     - `hub_exams`: Exams with countdown dates and locations.
     - `hub_notes`: Saved student notes with pinned status.
     - `hub_checklist`: Interactive todo items.
     - `hub_pomodoro_stats`: Today's completed focus minutes & session history.
2. **Zero Cloud Infrastructure Cost**:
   - \$0/month operating cost.
   - Device migration via JSON Export/Import in Settings.

---

## 4. Feature Specifications & Algorithms

### 4.1 Attendance Calculator & Smart Predictor
- **Standard Formula:**
  $$\text{Attendance \%} = \left(\frac{\text{Attended}}{\text{Total}}\right) \times 100$$
- **On-Duty (OD) / Medical Certificate Waiver Formula:**
  $$\text{Effective Attendance \%} = \left(\frac{\text{Attended} + \text{Approved OD/Medical Leaves}}{\text{Total}}\right) \times 100$$
- **"Can I Skip?" Prediction (with OD Waiver):**
  $$\text{Skippable Classes} = \left\lfloor \frac{(\text{Attended} + \text{OD}) - (\text{Required \%} / 100) \times \text{Total}}{\text{Required \%} / 100} \right\rfloor$$
- **"Classes Needed" Prediction (with OD Waiver):**
  $$\text{Needed Classes} = \left\lceil \frac{(\text{Required \%} / 100) \times \text{Total} - (\text{Attended} + \text{OD})}{1 - (\text{Required \%} / 100)} \right\rceil$$
- **Vacation / Bunk Simulator Prediction:**
  $$\text{Projected Attendance \%} = \left(\frac{\text{Attended} + \text{OD}}{\text{Total} + \text{Planned Bunks}}\right) \times 100$$
  $$\text{Max Safe Bunks} = \left\lfloor \frac{(\text{Attended} + \text{OD}) - (\text{Required \%} / 100) \times \text{Total}}{\text{Required \%} / 100} \right\rfloor$$

### 4.2 Internal + External Passing Marks Solver
- **Conditions for Passing without Backlog:**
  1. $\text{External Marks} \ge (\text{Min External \%} / 100) \times \text{Max External}$
  2. $\text{Internal} + \text{External} \ge (\text{Min Overall \%} / 100) \times (\text{Max Internal} + \text{Max External})$
- **Formula:**
  $$\text{Required External} = \max\left( \text{Total Overall Needed} - \text{Internal Scored},\; \text{Min External Passing Rule} \right)$$

### 4.3 CGPA & SGPA Engine & University Presets
- **Formula:**
  $$\text{SGPA} = \frac{\sum (\text{Credits}_i \times \text{GradePoint}_i)}{\sum \text{Credits}_i}$$
  $$\text{CGPA} = \frac{\sum (\text{SGPA}_j \times \text{TotalCredits}_j)}{\sum \text{TotalCredits}_j}$$
- **Grading Systems Supported:**
  - **10-Point Scale (Standard UGC / AICTE / VTU / AKTU):** O:10, A+:9, A:8, B+:7, B:6, C:5, P:4, F:0
  - **Anna University (10-Point):** O:10, A+:9, A:8, B+:7, B:6, C:5, RA:0 (Re-Appear)
  - **Mumbai University (10-Point):** O:10, A:9, B:8, C:7, D:6, E:5, P:4, F:0
  - **4-Point Scale (US/International):** A:4.0, A-:3.7, B+:3.3, B:3.0, B-:2.7, C+:2.3, C:2.0, F:0
  - Custom grade point entry per course.

### 4.4 Realism Modules (Campus Life Workflow)
1. **Digital Student ID Card:**
   - Real college identity badge on HomeScreen displaying College Name, Student Name, Roll/Registration No, Degree & Branch, Current Semester, and live CGPA/Attendance/Streak chips.
   - Customizable via 1-tap in-app profile editor.
2. **5-Unit Exam Syllabus Prep Tracker:**
   - Standard 5-unit syllabus checklist per semester exam.
   $$\text{Syllabus Prep \%} = \left(\frac{\text{Completed Units}}{\text{Total Units}}\right) \times 100$$
   - Interactive checklist toggles with instant progress bar update.
3. **Period Bells, Practical Labs & Lunch Break Timetable:**
   - Period-based schedule (`Period 1` to `Period 6`) and `2h Lab Block` indicators with professor names.
   - Automatic lunch break delimiter between morning and afternoon lectures (`12:45 PM – 01:30 PM`).
   - 1-tap lecture cancellation toggle for faculty leaves or mass bunks.
4. **Campus Pocket-Money & Expense Logger:**
   - 1-tap quick log buttons for college life: Chai (₹15), Samosa (₹20), Xerox (₹20), Metro (₹40), Stationery (₹30).
   - Category filtering across Canteen, Xerox & Prints, Travel & Metro, Stationery, and Hostel & Mess.
   - Daily and total campus spend summaries.

### 4.5 Number System Converter
- Live bidirectional conversion between Base 2 (Binary), Base 8 (Octal), Base 10 (Decimal), and Base 16 (Hexadecimal).

### 4.6 Multi-Category Unit Converter
Supports 8 vital academic domains: Length, Weight, Temperature, Area, Volume, Time, Data Storage, and Speed.

### 4.7 Interactive Weekly Study Analytics & Hover Inspection
- **Interactive Inspection:**
  - Bar graph on `ProgressScreen` supports both desktop/web cursor hover (`MouseRegion`) and mobile tap (`GestureDetector`).
  - Hovering/tapping any day displays:
    1. Exact study duration in hours (e.g., `3.6h`).
    2. Number of Pomodoro sessions logged (e.g., `4 sessions`).
    3. Status badge (e.g., `⭐ Peak Study Day`, `🎯 Goal Met`, `⚡ Steady Effort`, `🌱 Rest / Light Day`).
  - Bar height expands dynamically on hover with a glowing white border highlight and an animated badge above the bar.
  - Live top header chips update instantaneously to show full weekday metrics.

### 4.8 Study Focus Timer & Custom Time Engine
- **Streamlined Pure Focus:** Removed forced short/long break states in favor of a distraction-free student focus timer.
- **Custom Time Setting:**
  - Direct minute entry (1 to 360 minutes).
  - Quick additive chips: `+5m`, `+10m`, `+15m`, `+30m`, `+45m`, `+60m`.
  - Instant presets: `15m (Quick Sprint)`, `25m (Pomodoro)`, `45m (Lecture Block)`, `60m (Deep Study)`.
  - Accessible via AppBar icon, duration pill badge, digit tap, or preset card button.
- **Focus Logging:** Automatically writes focus minutes to daily and weekly productivity records upon completion.

### 4.9 Master Weekly Timetable 2D Grid Engine
- **Unified Matrix Architecture:** Replaced disconnected daily tabs with a single 2D interactive matrix grid showing the entire week.
- **User-Decided Grid Dimensions:**
  - Columns (Days): Configurable from 3 to 7 days (e.g. 5 Days Mon–Fri, 6 Days Mon–Sat, 7 Days Mon–Sun).
  - Rows (Periods): Configurable from 3 to 10 periods per day.
  - Persistent offline storage in `StorageService`.
- **Full Cell Editability:**
  - Every grid cell (empty or scheduled) is directly editable on tap.
  - Supports Subject Name, Quick Subject Chips, Room/Lab, Faculty name, Start/End times, Lab block flag, Cancelled lecture status, 7 custom student accent colors, and 1-tap slot clearing.
- **Real-Time Context:** Active highlight badge for today's column (`TODAY`).

---




## 5. Google Play Console & AdMob Policy Compliant Monetization
- **Strict Google Play Ad Guidelines Implemented:**
  1. **Clear Labeling:** All ad units are explicitly marked with an amber `[SPONSORED]` or `[AD]` badge to prevent confusing ads with app content.
  2. **Accidental Click Prevention:** Ads are isolated in dedicated containers with 14–18px vertical margins, never placed adjacent to input forms, steppers, or primary action buttons.
  3. **Zero Focus Interruption:** Ads are strictly suppressed during active Pomodoro study sessions (`if (!_isRunning)`) and disabled during note/checklist typing.
  4. **Pro Tier Suppression:** Instant total removal across all screens when `storage.isProUser == true`.
  5. **Non-Disruptive Formats:** Standard 320x50 banners and native inline summary cards placed neatly below calculation results.
- **One-Time Micro-Transactions (No Monthly Subscriptions):**
  - ₹49: Remove Ads Forever
  - ₹99: Remove Ads + Custom Themes & Accent Colors
  - ₹149: Lifetime Ultimate Scholar (All future tools + Priority cloud backup)

---


## 6. Offline Data Backup & Portability Schema (v1.2.0)
The application exports and imports a unified, human-readable JSON payload:
```json
{
  "version": "1.2.0",
  "exportedAt": "2026-10-05T04:30:00.000Z",
  "userName": "Neeraj Yadav",
  "collegeName": "Delhi Technological University",
  "degreeBranch": "B.Tech Computer Science",
  "semesterName": "Semester 5",
  "rollNumber": "21/CS/104",
  "themeMode": "system",
  "isPro": false,
  "studyStreak": 3,
  "semesters": [...],
  "attendance": [...],
  "timetable": [...],
  "assignments": [...],
  "exams": [...],
  "expenses": [...],
  "checklist": [...],
  "notes": [...],
  "studyLogs": [...],
  "favorites": ["cgpa", "attendance", "pomodoro", "exams"]
}
```

---

## 7. Visual Design System & Duplicacy Auditing Standards (v1.4.0)

### 7.1 Modern Collegiate Color Palette
- **Primary Brand:** Electric Academic Iris (`#4F46E5`), Vivid Indigo (`#6366F1`), Deep Academic Violet (`#3730A3`).
- **Secondary Accent:** Radiant Oceanic Sky / Teal (`#0EA5E9`), Highlight Sky (`#38BDF8`).
- **Urgency / Alerts:** Coral Rose (`#F43F5E`), Amber Gold (`#F59E0B`), Emerald Success (`#10B981`).
- **Dark Mode Architecture:** Obsidian Midnight (`#0B0F19`) scaffolding, Deep Navy (`#131D31`) surfaces, and Slate (`#1A263E`) elevated cards.
- **Light Mode Architecture:** Arctic Pearl (`#F8FAFC`) background, Pure White (`#FFFFFF`) surface cards, and Ceramic (`#F1F5F9`) input fields.

### 7.2 UI Consistency & Anti-Duplicacy Invariants
1. **Single Add Trigger Invariant:** Every screen featuring an item creation flow must provide exactly one primary `+` trigger placed consistently in the AppBar actions (or an explicit inline input bar), never combining both an AppBar action and an overlapping `FloatingActionButton`.
2. **Unobstructed Ad Placement:** Bottom-pinned Google Play compliant banners must maintain independent vertical layout flow, never obstructed by floating buttons or overlapping lists.
3. **Flutter 3.41 API Modernization:** All alpha channel manipulation strictly uses `.withValues(alpha: ...)`, eliminating deprecated `.withOpacity(...)`.
4. **Preservation Guarantee:** All academic algorithms (OD credit waivers, minimum passing score solvers, multi-semester SGPA/CGPA calculations, and the 2D user-sized timetable matrix) remain 100% functional and offline.
