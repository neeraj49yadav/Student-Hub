# 📜 CHANGELOG — Student Utility Hub

All notable changes, additions, technical decisions, and architecture milestones of this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [1.0.0] - 2026-10-05

### 🚀 Complete V1 Full-Stack Offline Implementation
- **When:** 2026-10-05 02:40 AM – 02:52 AM IST
- **What Was Changed / Added:**

#### Phase 1: Core Foundation & Offline Storage
- **Added:** `lib/core/theme/app_theme.dart`
  - *Why:* Defined complete Material 3 Light and Dark theme palettes with Google Fonts (`Inter`), customized card radii, button themes, and input decorations.
- **Added:** `lib/shared/models/app_models.dart`
  - *Why:* Implemented typed data models for `Subject`, `Semester`, `AttendanceSubject` (with embedded prediction getters), `TimetableSlot`, `Assignment`, `ExamEntry`, `ChecklistItem`, `NoteItem`, and `StudySessionLog`.
- **Added:** `lib/core/services/storage_service.dart`
  - *Why:* Created an offline reactive state manager utilizing `SharedPreferences` to manage JSON persistence for semesters, attendance, timetable, assignments, exams, checklist, notes, and study logs. Seeded initial demo data so first launch is immediately interactive.
- **Added:** `lib/core/widgets/common_widgets.dart`
  - *Why:* Built reusable `CustomCard` surface and non-intrusive `AdBannerPlaceholder` that hides when Pro is active.

#### Phase 2: Complete Calculator & Converter Suite
- **Added:** `lib/features/calculator/attendance_calculator_screen.dart`
  - *Why:* Implemented smart attendance calculator with mathematical "Can I Skip?" and "Classes Needed to Reach Target %" prediction formulas, plus a multi-subject tracker with quick `+ Attended` / `+ Missed` counters.
- **Added:** `lib/features/calculator/sgpa_calculator_screen.dart`
  - *Why:* Created weighted semester GPA calculator supporting 10-point (UGC/AICTE) and 4-point scales, with save-to-history capability.
- **Added:** `lib/features/calculator/cgpa_calculator_screen.dart`
  - *Why:* Implemented multi-semester cumulative CGPA calculation, semester history management, and future target CGPA estimator ("What SGPA do I need next semester?").
- **Added:** `lib/features/calculator/percentage_calculator_screen.dart`
  - *Why:* Implemented basic percentage calculator, upcoming exam target score solver ("How many marks do I need to reach 75%?"), and standard AICTE/CBSE CGPA $\leftrightarrow$ Percentage conversion.
- **Added:** `lib/features/calculator/age_calculator_screen.dart`
  - *Why:* Built accurate age calculator with year/month/day breakdown, next birthday countdown in days, total days/weeks/hours lived, and Zodiac sign indicator.
- **Added:** `lib/features/converter/unit_converter_screen.dart`
  - *Why:* Built multi-category real-time unit converter spanning Length, Weight, Temperature, Area, Volume, Time, Data storage, and Speed.
- **Added:** `lib/features/converter/number_system_converter_screen.dart`
  - *Why:* Created bidirectional CS number system converter for live synchronization between Binary (Base 2), Octal (Base 8), Decimal (Base 10), and Hexadecimal (Base 16) with copy-to-clipboard support.

#### Phase 3: Productivity Suite
- **Added:** `lib/features/timetable/timetable_screen.dart`
  - *Why:* Built weekly Monday–Sunday timetable planner with room details, time pickers, and color coding.
- **Added:** `lib/features/pomodoro/pomodoro_screen.dart`
  - *Why:* Implemented Pomodoro study timer with 25/5, 50/10, and 90/20 presets, circular progress indicator, interval switching, and automatic focus time logging into daily analytics.
- **Added:** `lib/features/exam/exam_countdown_screen.dart`
  - *Why:* Built upcoming exam tracker with priority ratings (High/Medium/Low), location, syllabus notes, and visual remaining days badge.
- **Added:** `lib/features/assignments/assignments_screen.dart`
  - *Why:* Built college assignment submission tracker with urgency status indicators (🔴 Tomorrow, 🟡 4 days, 🟢 8 days) and completion status filters.
- **Added:** `lib/features/checklist/checklist_screen.dart`
  - *Why:* Created interactive to-do checklist with Study, College, Exams, and Personal category filters and progress bar.
- **Added:** `lib/features/notes/notes_screen.dart`
  - *Why:* Created note-taking module with keyword search, tags, pin-to-top feature, and subject categorization.

#### Phase 4: Integrated Dashboard & Navigation
- **Added:** `lib/features/home/home_screen.dart`
  - *Why:* Created personalized dashboard featuring dynamic greeting, today's productivity stats, smart upcoming cards (Next Lecture, Next Exam, Next Assignment), quick tools launcher, and global modal search.
- **Added:** `lib/features/tools_hub_screen.dart`
  - *Why:* Categorized tools menu with star/favorite toggles and quick access to all 7 calculators and converters.
- **Added:** `lib/features/study_hub_screen.dart` & `lib/features/tasks_hub_screen.dart`
  - *Why:* Unified navigation hubs for study utilities and task organizers.
- **Added:** `lib/features/progress/progress_screen.dart`
  - *Why:* Built academic analytics screen with weekly study hours bar visualization, attendance health score, and task completion metrics.
- **Added:** `lib/main.dart`
  - *Why:* Unified all 5 core navigation tabs (`Home`, `Tools`, `Study`, `Tasks`, `Settings`) into a clean Material 3 `NavigationBar` with reactive state synchronization.

#### Phase 5: Monetization, Settings & Quality Assurance
- **Added:** `lib/features/premium/premium_screen.dart`
  - *Why:* Implemented student-friendly one-time purchase tiers (₹49 Remove Ads, ₹99 Pro Student, ₹149 Lifetime Ultimate) with live simulation toggle.
- **Added:** `lib/features/settings/settings_screen.dart`
  - *Why:* Added theme switcher (Light / Dark / System), notification toggle, profile name editor, reset data tool, and offline privacy statement.
- **Added:** `test/widget_test.dart`
  - *Why:* Created comprehensive unit test suite verifying attendance calculation logic, skippable predictions, and credit-weighted SGPA formulas. All tests pass with 0 errors.

---

## [1.1.0] - 2026-10-05

### ⚡ Power Features & Gamification Upgrade (Options A, B, C & D)
- **When:** 2026-10-05 03:30 AM – 03:45 AM IST
- **What Was Changed / Added:**

#### Option A: Offline Backup & Restore (JSON) + Haptics
- **Added:** Complete JSON Export & Import engine in `StorageService` (`exportDataAsJson()` and `importDataFromJson()`).
- **Added:** Backup & Restore UI modals in `SettingsScreen` allowing 1-tap clipboard copy, file sharing, and JSON text restoration.
- **Added:** Tactile haptic feedback (`HapticFeedback.lightImpact()` and `vibrate()`) across attendance buttons, checklist toggles, and Pomodoro timer intervals.
- *Why:* Guarantees student data portability when switching phones without needing a paid cloud server, plus creates a responsive, tactile app feel.

#### Option B: Bunk Planner + Internal Passing Marks Solver
- **Added:** **Vacation / Fest Bunk Simulator** (3rd tab in `AttendanceCalculatorScreen`) calculating projected attendance drop after missing classes, safe bunk limits, and recovery counts.
- **Added:** `lib/features/calculator/exam_passing_calculator_screen.dart` — Internal + External passing marks solver with standard university presets (30+70, 40+60, 20+80) and backlog warnings.
- *Why:* Solves two of the most critical student anxiety points: planning fest leaves safely and knowing the exact minimum marks needed to avoid backlogs.

#### Option C: 1-Tap Academic & Attendance Summary Card Export
- **Added:** Integrated `share_plus` to generate clean, shareable ASCII/Markdown summary cards for:
  - CGPA & Semester Performance Report (in `CgpaCalculatorScreen`)
  - Overall Attendance Summary (in `AttendanceCalculatorScreen`)
  - Exam Passing Calculation (in `ExamPassingCalculatorScreen`)
- *Why:* Allows students to immediately share results with classmates, study groups, or parents on WhatsApp.

#### Option D: Daily Study Streak & Gamification
- **Added:** Daily Study Streak tracking logic in `StorageService` (`studyStreak`, `lastActiveDate`, `checkDailyStreak()`).
- **Added:** Prominent **"🔥 Study Streak"** hero banner on `HomeScreen` with active/gold status badges and motivational scholar prompts.
- **Added:** Automatic streak progress triggers when completing Pomodoro sessions or checking off to-do tasks.
- *Why:* Drives daily active app retention by turning studying and task completion into a rewarding daily habit.

---

## [1.2.0] - 2026-10-05

### 🎓 Campus Realism & College Workflow Suite ("Go for All")
- **When:** 2026-10-05 04:30 AM – 04:45 AM IST
- **What Was Changed / Added:**

#### 1. Official Digital Student ID Card (`HomeScreen`)
- **Added:** Realistic Indian/International College ID badge card as the primary hero header on the Home dashboard.
- **Features:** College Name, Student Name, Roll/Registration Number, Department & Branch, Current Semester, verified check badge, and live academic performance chips (CGPA, Attendance %, Study Streak).
- **Customization:** Added 1-tap `_showEditProfileDialog` so students can easily customize their college name, roll number, and degree.
- *Why:* Replaces generic app dashboards with an authentic personal college badge that feels like their genuine student identity card.

#### 2. On-Duty (OD) & Medical Leave Waiver (`AttendanceCalculatorScreen`)
- **Added:** `medicalLeaves` field and `effectivePercentage` getter to `AttendanceSubject`.
- **Features:** Direct `+ OD/Med` action button in the subject tracker alongside `+ Attended` and `+ Missed`.
- **Logic:** Distinguishes between raw attendance and effective attendance waiver with an approved duty leave badge (`🎖️ +X Approved OD/Medical leaves`).
- *Why:* In Indian universities (Anna Univ, VTU, AKTU, DTU, IITs/NITs), students frequently attend hackathons, sports fests, or fall sick and submit medical/OD certificates to waive attendance shortages.

#### 3. Period Numbers, Practical Labs, Lunch Break & Cancelled Lectures (`TimetableScreen`)
- **Added:** `periodNumber`, `professorName`, `isLab`, and `isCancelled` properties to `TimetableSlot`.
- **Features:**
  - Distinct period tags (`[Period 1]`, `[Period 2]`) and cyan/purple tags for `[🔬 2h Lab Block]`.
  - Faculty instructor names displayed directly under subjects.
  - Automatic Campus Lunch & Break Interval indicator (`🍽️ CAMPUS LUNCH & BREAK INTERVAL 12:45 PM – 01:30 PM`).
  - 1-tap Lecture Cancellation toggle (`🚫 LECTURE CANCELLED TODAY (FACULTY LEAVE / MASS BUNK)`) with strikethrough styling.
- *Why:* Real college timetables don't just have generic times; they run on period bells, multi-hour practical lab sessions, professor schedules, and occasional faculty leaves or mass bunks.

#### 4. 5-Unit Exam Syllabus Checklists & Prep Tracker (`ExamCountdownScreen`)
- **Added:** `syllabusUnits` and `completedUnits` to `ExamEntry` with real-time `preparationPercentage` calculation.
- **Features:** Interactive 5-unit syllabus checklist inside each exam countdown card, interactive check/uncheck toggles, unit completion counter (`3/5 Units Done`), and live animated preparation progress bar.
- *Why:* Indian university semester exams universally follow a 5-unit syllabus structure; tracking unit readiness relieves exam panic.

#### 5. Campus Pocket-Money & Expense Logger (`CampusExpenseScreen`)
- **Added:** `lib/features/expenses/campus_expense_screen.dart` and integrated into `ToolsHubScreen` and `HomeScreen` Quick Tools.
- **Features:** Today's campus spend total, total logged banner, 1-tap quick buttons (`☕ Chai ₹15`, `🥟 Samosa ₹20`, `📄 Xerox ₹20`, `🚇 Metro ₹40`, `✏️ Pen ₹30`), category filters (Canteen, Xerox & Prints, Travel & Metro, Stationery, Hostel & Mess), and custom expense dialog.
- *Why:* Students spend pocket money daily on canteen snacks, xerox printouts, metro fares, and lab manuals; this allows them to track daily spending offline with zero hassle.

#### 6. University Grading Scale Presets (`SgpaCalculatorScreen`)
- **Added:** Built-in grading presets for:
  - 10-Point (UGC / AICTE / VTU / AKTU) `[O=10, A+=9, A=8, B+=7, B=6, C=5, P=4, F=0]`
  - Anna University (10-Point) `[O=10, A+=9, A=8, B+=7, B=6, C=5, RA=0]`
  - Mumbai University (10-Point) `[O=10, A=9, B=8, C=7, D=6, E=5, P=4, F=0]`
  - 4-Point US / International `[A=4.0, A-=3.7, B+=3.3, B=3.0, B-=2.7, C+=2.3, C=2.0, F=0]`
- *Why:* Standardizes grade calculations across state, central, and autonomous universities without manual point entry.

---

## [1.2.1] - 2026-10-05

### 🧹 Home Screen Declutter & Polish
- **When:** 2026-10-05 04:40 AM IST
- **What Was Changed:**
  - Removed the standalone wide "3-Day Study Streak" banner card from [`HomeScreen`](file:///c:/Users/neeraj49yadav/OneDrive/Desktop/Student%20Utilitty%20Hub/lib/features/home/home_screen.dart).
  - *Why:* The daily streak is already cleanly integrated into the top Digital Student ID Card (`STREAK: 3d 🔥`), so removing the extra banner removes visual redundancy and brings Today's Productivity & Smart Cards higher up on the screen.

---

## [1.2.2] - 2026-10-05

### 🎯 Expense Screen Button Consolidation
- **When:** 2026-10-05 04:45 AM IST
- **What Was Changed:**
  - Removed the blue `FloatingActionButton` (+) from the bottom of [`CampusExpenseScreen`](file:///c:/Users/neeraj49yadav/OneDrive/Desktop/Student%20Utilitty%20Hub/lib/features/expenses/campus_expense_screen.dart).
  - Kept the top-right AppBar `+` button and 1-tap quick action chips for adding expenses.
  - *Why:* Eliminates duplicate `+` trigger buttons and avoids obscuring the bottom-most expense item or banner ad.

---

## [1.2.3] - 2026-10-05

### 📊 Interactive Weekly Study Graph Hover & Detail Inspection
- **When:** 2026-10-05 04:50 AM IST
- **What Was Changed:**
  - Upgraded [`ProgressScreen`](file:///c:/Users/neeraj49yadav/OneDrive/Desktop/Student%20Utilitty%20Hub/lib/features/progress/progress_screen.dart) from a static StatelessWidget to an interactive StatefulWidget.
  - Added structured `DayStudyData` model with exact focus hours, Pomodoro session counts, full weekday name, and day highlight tags.
  - Wrapped each bar in `MouseRegion` (`onEnter`, `onExit`) for desktop/web cursor hover and `GestureDetector` (`onTap`) for mobile/touch inspection.
  - Integrated rich floating `Tooltip` displaying day, focus hours, sessions, and session status.
  - Added live top header badge dynamically updating on hover/selection (e.g. `Thursday: 3.6h (4 sessions) ⭐ Peak Day`).
  - Added dynamic bar hover badge displaying `${data.hours}h`, animated bar scale enlargement, and glowing white gradient border highlight.
  - *Why:* Students can now inspect exact focus hours, Pomodoro session counts, and peak study days by simply hovering over or tapping any individual bar in the Weekly Study Distribution chart.

---

## [1.2.4] - 2026-10-05

### 🩹 Fix: Weekly Study Graph Bottom Overflow (3.0 Pixels)
---

## [1.3.0] - 2026-10-05

### 💎 Google Play Console Ad Policy Compliance & Humanized UI Redesign
- **When:** 2026-10-05 05:40 AM IST
- **What Was Changed / Added:**

#### 1. Google Play Console & AdMob Policy Compliant Ad Architecture
- **Added:** [`GooglePlayCompliantAdBanner`](file:///c:/Users/neeraj49yadav/OneDrive/Desktop/Student%20Utilitty%20Hub/lib/core/widgets/common_widgets.dart) supporting standard banner (320x50) and native card formats.
- **Strict Compliance Rules Enforced:**
  - **Explicit Visual Distinction:** Prominent amber `[SPONSORED]` and `[AD]` badges, distinct dark slate/neutral background containers, and clear borders ensure ads can never be confused with app content.
  - **Accidental Click Prevention:** Ads maintain safe buffer zones (14–18px vertical margins) away from primary interactive buttons, text inputs, and navigation elements.
  - **Zero Focus Disruption:** Pomodoro timer strictly suppresses all ads while active (`if (!_isRunning)`). Notes and checklists remain completely free of intrusive popups.
  - **Complete Pro Suppression:** Instantly collapses to `SizedBox.shrink()` when `isProUser == true`.
  - **Transparent Upgrades:** Direct "Remove Ads ₹49" shortcut and fallback modal dialogue.

#### 2. Humanized Campus Aesthetics & Warm Student Persona
- **Contextual Time-of-Day Affirmations:** Dynamic student wisdom banner on [`HomeScreen`](file:///c:/Users/neeraj49yadav/OneDrive/Desktop/Student%20Utilitty%20Hub/lib/features/home/home_screen.dart) adapting to Morning ☀️, Afternoon ⚡, Evening ☕, and Night Owl 🌙 study phases.
- **Interactive Digital Student ID Card 2.0:**
  - Tapping **CGPA** routes directly to the CGPA Calculator.
  - Tapping **ATTENDANCE** routes directly to the Attendance Tracker.
  - Tapping **STREAK** opens an encouraging habit breakdown modal.
  - Tapping the ID card edit button opens the official student badge editor.
- **Motivational Pulse Badges:** Integrated throughout [`StudyHubScreen`](file:///c:/Users/neeraj49yadav/OneDrive/Desktop/Student%20Utilitty%20Hub/lib/features/study_hub_screen.dart) and [`TasksHubScreen`](file:///c:/Users/neeraj49yadav/OneDrive/Desktop/Student%20Utilitty%20Hub/lib/features/tasks_hub_screen.dart).

#### 3. Interactive Structural Navigation & Tools Overhaul
- **Interactive Category Filtering in Tools Hub:** [`ToolsHubScreen`](file:///c:/Users/neeraj49yadav/OneDrive/Desktop/Student%20Utilitty%20Hub/lib/features/tools_hub_screen.dart) features instant search and category filter chips (`All`, `Favorites ⭐`, `Academics`, `Attendance`, `Converters`, `Daily`).
- **Tactile Floating Navigation Bar:** Upgraded [`main.dart`](file:///c:/Users/neeraj49yadav/OneDrive/Desktop/Student%20Utilitty%20Hub/lib/main.dart) bottom navigation bar with haptic feedback, subtle top border separation, and Material 3 indigo indicator pills.
- **Preservation Guarantee:** 100% of existing data models, offline persistence, formulas (OD waiver, bunk planning, passing solvers), and features were strictly preserved without removing any functionality.

---

## [1.3.1] - 2026-10-05

### ⏱️ Pomodoro Streamlining: Removed Breaks & Added Custom Time Option
- **When:** 2026-10-05 05:48 AM IST
- **What Was Changed:**
  - Removed "Short Break" and "Long Break" segmented buttons and automatic break transitions from [`PomodoroScreen`](file:///c:/Users/neeraj49yadav/OneDrive/Desktop/Student%20Utilitty%20Hub/lib/features/pomodoro/pomodoro_screen.dart).
  - Transformed the timer into a pure, distraction-free Study Focus Timer.
  - Added interactive **"Custom Time ⏱️"** option accessible via:
    1. Top AppBar action icon button (`Icons.edit_calendar_outlined`).
    2. Interactive duration pill badge (`Duration: X Minutes ✏️`).
    3. Direct tap on the large central timer countdown digits.
    4. "Focus Presets & Custom Time" section with a dedicated "Add / Set Custom Minutes" action.
  - Built interactive `_showCustomTimeDialog` with minute input field (1 to 360 mins) and fast incremental quick-add chips (`+5m`, `+10m`, `+15m`, `+30m`, `+45m`, `+60m`).
  - Added instant focus presets: `15m (Quick Sprint)`, `25m (Pomodoro)`, `45m (Lecture Block)`, `60m (Deep Study)`.
  - *Why:* Students requested eliminating forced break modes in favor of flexible, custom-timed study sessions tailored to their exact lecture blocks and self-study intervals.

---

## [1.3.2] - 2026-10-05

### 📅 Weekly Timetable 2D Grid Matrix & Custom Rows/Columns Engine
- **When:** 2026-10-05 05:52 AM IST
- **What Was Changed:**
  - Redesigned [`TimetableScreen`](file:///c:/Users/neeraj49yadav/OneDrive/Desktop/Student%20Utilitty%20Hub/lib/features/timetable/timetable_screen.dart) from separate day-wise selector tabs into a unified **Master 2D Scrollable Matrix Grid**.
  - **User-Decided Grid Dimensions (Rows & Columns):**
    - Added interactive `_showGridConfigDialog` allowing students to configure:
      - **Columns (Days):** 3 to 7 days (e.g. 5 Days Mon–Fri, 6 Days Mon–Sat, 7 Days Full Week).
      - **Rows (Periods):** 3 to 10 periods per day (e.g. 4, 6, 8, 10 periods).
    - Grid dimensions persist automatically in `StorageService` (`timetableRowCount`, `timetableColumnCount`).
  - **100% Editable Grid Cells:**
    - Every single cell in the grid (empty or occupied) is directly editable on tap.
    - Added `_showEditCellDialog` supporting Subject Name, Quick Subject Chips (`DBMS`, `OS`, `Java`, `DSA`, etc.), Room / Lab, Faculty / Professor, Start/End Times, 2h Practical Lab toggle, Cancelled Lecture toggle, 7 student accent colors, and a 1-tap "Clear Slot" action.
  - **Visual Realism & UX:**
    - Fixed left period header column showing Period badge (`P1`, `P2`, etc.) and timings.
    - Current day column is automatically highlighted with a bold primary badge (`TODAY`).
    - Panning & scrolling across both horizontal and vertical axes supported seamlessly.
  - *Why:* Replaces disconnected daily tab lists with a realistic, high-utility college timetable matrix where students can see their entire weekly lecture schedule at a glance and customize the exact number of periods and days.

---

## [1.4.0] - 2026-10-06

### 🎨 App-Wide Structure & Color Overhaul + Comprehensive Duplicacy Audit

- **When:** 2026-10-06 12:15 AM IST
- **What Was Changed / Added:**

#### 1. Visual Theme & Color Palette Overhaul
- **Modern High-Contrast Academic Theme:**
  - **Primary:** Electric Academic Iris (`#4F46E5`) with Vivid Indigo (`#6366F1`) and Deep Academic Violet (`#3730A3`).
  - **Secondary:** Radiant Oceanic Sky / Teal (`#0EA5E9`) and Sky Highlight (`#38BDF8`).
  - **Accent & Warm Alert:** Coral Rose (`#F43F5E`) and Amber Gold (`#F59E0B`).
  - **Dark Surfaces:** Obsidian Midnight (`#0B0F19`), Deep Navy Surface (`#131D31`), and Elevated Slate Card (`#1A263E`).
  - **Light Surfaces:** Arctic Pearl (`#F8FAFC`), Pure White (`#FFFFFF`), and Soft Ceramic Card (`#F1F5F9`).
- **Surface Elevation & Polish:**
  - Modernized `NavigationBarThemeData` with crisp pill indicators and active label typography.
  - Polished interactive `CustomCard` borders and shadows.
  - Updated Digital Student ID Card and Productivity gradients for collegiate aesthetic.
  - Aligned all tool category badges and quick-launch chip colors across Home and Tools Hub.

#### 2. Comprehensive Duplicacy Audit & Elimination
- **Eliminated Duplicate Add Triggers (`+` buttons):**
  - **Assignment Tracker ([`AssignmentsScreen`](file:///c:/Users/neeraj49yadav/OneDrive/Desktop/Student%20Utilitty%20Hub/lib/features/assignments/assignments_screen.dart)):** Removed duplicate bottom `FloatingActionButton`. Kept the clean top AppBar `+` action, eliminating dual triggers and preventing bottom ad banner obstruction.
  - **Exam Countdown ([`ExamCountdownScreen`](file:///c:/Users/neeraj49yadav/OneDrive/Desktop/Student%20Utilitty%20Hub/lib/features/exam/exam_countdown_screen.dart)):** Removed redundant bottom `FloatingActionButton`. Retained single header `+` action and upgraded bottom ad container.
  - **Quick Study Notes ([`NotesScreen`](file:///c:/Users/neeraj49yadav/OneDrive/Desktop/Student%20Utilitty%20Hub/lib/features/notes/notes_screen.dart)):** Consolidated the floating button into the standard top AppBar action (`Icons.add`), providing consistent placement across all screens and eliminating overlap over the bottom ad banner.
  - **Attendance Suite ([`AttendanceCalculatorScreen`](file:///c:/Users/neeraj49yadav/OneDrive/Desktop/Student%20Utilitty%20Hub/lib/features/calculator/attendance_calculator_screen.dart)):** Removed nested `Scaffold` and floating button inside TabBarView; promoted "Add Subject" into the main AppBar action list and provided an empty-state quick action.
- **Unified Ad Banner Architecture:**
  - Replaced legacy `AdBannerPlaceholder` references across all calculators and converters with direct [`GooglePlayCompliantAdBanner`](file:///c:/Users/neeraj49yadav/OneDrive/Desktop/Student%20Utilitty%20Hub/lib/core/widgets/common_widgets.dart) instances.
  - Maintained zero ad interruption during active Pomodoro countdowns and full suppression for Pro users.

#### 3. Complete Codebase Deprecation Migration
- **Eliminated Deprecated `withOpacity`:**
  - Replaced all 21 occurrences across the codebase with Flutter's modern `.withValues(alpha: ...)`.
  - Zero deprecations remaining across `lib/features/` and `lib/core/`.

#### 4. Verification & Invariant Adherence
- **Strict Preservation:** All existing calculators, models, offline persistence, timetable 2D grid matrix, passing marks formulas, and bunk simulators preserved with 100% functionality.
- **Quality Assurance:**
  - `flutter analyze --no-fatal-infos`: 0 errors, 0 warnings.
  - `flutter test`: 9/9 test suites passing (100% green).

---

## [1.4.1] - 2026-10-06

### 🚀 Direct Navigation: "Remove Ads" Redirects Directly to Plans Page

- **When:** 2026-10-06 12:40 AM IST
- **What Was Changed:**
  - Updated [`GooglePlayCompliantAdBanner`](file:///c:/Users/neeraj49yadav/OneDrive/Desktop/Student%20Utilitty%20Hub/lib/core/widgets/common_widgets.dart) `_handleUpgrade` action:
    - Clicking on **"Remove Ads ₹49"** button, **"Hide (₹49)"**, or tapping the ad upgrade card immediately redirects students directly to the **Plans & Upgrades Page** ([`PremiumScreen`](file:///c:/Users/neeraj49yadav/OneDrive/Desktop/Student%20Utilitty%20Hub/lib/features/premium/premium_screen.dart)).
    - Uses `StorageService.maybeInstance` / `storage` to pass active user persistence to the plans screen.
    - Updated [`PremiumScreen`](file:///c:/Users/neeraj49yadav/OneDrive/Desktop/Student%20Utilitty%20Hub/lib/features/premium/premium_screen.dart) AppBar title to `Plans & Upgrades ⭐` for immediate clarity.
    - Added one-tap selection for all three student passes: Basic Ad-Free (₹49), Pro Student (₹99), and Lifetime Ultimate (₹149).
  - *Quality Assurance:* Analyzer 0 errors, 0 warnings; 9/9 unit & widget test suites passing.

---

## [1.4.2] - 2026-10-06

### 🧘 Pomodoro Timer Minimalist Declutter: Removed Preset Buttons Card

- **When:** 2026-10-06 12:45 AM IST
- **What Was Changed:**
  - Removed the bottom **"Focus Presets & Custom Time"** card (containing `15m`, `25m`, `45m`, `60m` chips, `+ Custom Time` button, and `Add / Set Custom Minutes` button) from [`PomodoroScreen`](file:///c:/Users/neeraj49yadav/OneDrive/Desktop/Student%20Utilitty%20Hub/lib/features/pomodoro/pomodoro_screen.dart).
  - Cleaned up unused helper `_presetButton`.
  - Preserved direct timer adjustments:
    1. Top AppBar action icon (`Icons.edit_calendar_outlined`).
    2. Interactive duration pill badge (`Duration: X Minutes ✏️`).
    3. Tapping directly on the large countdown digits.
  - *Why:* Delivers a distraction-free, minimalist study timer experience without repetitive presets taking up screen real estate.
  - *Quality Assurance:* Analyzer 0 errors, 0 warnings; 9/9 unit & widget test suites passing.

---

## [1.4.3] - 2026-10-06

### 🧘 Study Focus Timer Pure Minimalist UI: Removed Duration Pill Badge & Top Edit Icon

- **When:** 2026-10-06 12:48 AM IST
- **What Was Changed:**
  - Removed the duration pill badge (`Duration: X Minutes ✏️`) from [`PomodoroScreen`](file:///c:/Users/neeraj49yadav/OneDrive/Desktop/Student%20Utilitty%20Hub/lib/features/pomodoro/pomodoro_screen.dart).
  - Removed the top AppBar calendar edit icon button (`Icons.edit_calendar_outlined`).
  - The screen now features a pure, distraction-free layout with the focus stats summary card and central countdown ring.
  - Duration adjustment remains seamlessly available by tapping directly on the countdown timer digits.
  - *Quality Assurance:* Analyzer 0 errors, 0 warnings; 9/9 unit & widget test suites passing.

---

## [1.4.4] - 2026-10-06

### 📊 Academic Progress: Clean Minimalist Weekly Chart Header

- **When:** 2026-10-06 12:53 AM IST
- **What Was Changed:**
  - Removed the subtitle text `"Hover or tap bar for details"` from the **Weekly Study Distribution** card in [`ProgressScreen`](file:///c:/Users/neeraj49yadav/OneDrive/Desktop/Student%20Utilitty%20Hub/lib/features/progress/progress_screen.dart).
  - Kept interactive functionality 100% intact:
    - Hovering or tapping any day's bar immediately displays the session & hours badge in the top right header (`{Day}: {X}h ({Y} sessions)`).
    - Floating value tooltips and bar elevation animations on mouse hover / finger tap remain completely operational.
  - *Quality Assurance:* `flutter analyze` 0 errors, 0 warnings; `flutter test` 9/9 test suites passing (100% green).

---

## [1.4.5] - 2026-10-06

### 💎 Pricing Plans Overhaul: Remove Ads (₹39), Pro Student (₹89), and Lifetime Ultimate (₹129)

- **When:** 2026-10-06 01:07 AM IST
- **What Was Changed:**
  - Updated all 3 pricing tiers in [`PremiumScreen`](file:///c:/Users/neeraj49yadav/OneDrive/Desktop/Student%20Utilitty Hub/lib/features/premium/premium_screen.dart):
    1. **Remove Ads — ₹39** (Original ₹49 struck through)
       - Subtitle: *Enjoy 100% distraction-free offline studying.*
       - Features: Zero Banner Ads, Zero Interstitial Ads, Super-fast load times.
       - Action Button: **"Get Remove Ads for ₹39"**.
    2. **Pro Student — ₹89** (Original ₹99 struck through)
       - Subtitle: *Most popular for college & exam preparation.*
       - Features: All Ad-Free Benefits, Unlimited Saved Semesters, Advanced Attendance Predictions, Custom Accent Themes, Export Academic PDF Reports.
       - Action Button: **"Get Pro Student for ₹89"**.
       - Badge: **MOST POPULAR**.
    3. **Lifetime Ultimate — ₹129** (Original ₹149 struck through)
       - Subtitle: *Unlock everything + all future V2 & V3 updates.*
       - Features: Everything in Pro Student, AI-Powered Study Assistant, Future Cloud Backup & Sync, Priority Developer Support.
       - Action Button: **"Get Lifetime Ultimate for ₹129"**.
  - Synchronized ad banner upgrade prompts in [`GooglePlayCompliantAdBanner`](file:///c:/Users/neeraj49yadav/OneDrive/Desktop/Student%20Utilitty Hub/lib/core/widgets/common_widgets.dart) and [`SettingsScreen`](file:///c:/Users/neeraj49yadav/OneDrive/Desktop/Student%20Utilitty Hub/lib/features/settings/settings_screen.dart) to reflect ₹39.
  - *Quality Assurance:* `flutter analyze` 0 errors, 0 warnings; `flutter test` 9/9 test suites passing (100% green).

---

## [1.4.6] - 2026-10-06

### 🚀 Pricing Plans: Lifetime Ultimate Marked as UPCOMING with Price ₹149

- **When:** 2026-10-06 01:13 AM IST
- **What Was Changed:**
  - Updated the 3rd tier (**Lifetime Ultimate**) in [`PremiumScreen`](file:///c:/Users/neeraj49yadav/OneDrive/Desktop/Student%20Utilitty%20Hub/lib/features/premium/premium_screen.dart):
    - Price updated from ₹129 to **₹149**.
    - Marked as **UPCOMING PLAN** with a vibrant amber/orange gradient pill badge (`UPCOMING 🚀`).
    - Added an accent border on the tier card.
    - Updated action button to **"Get Lifetime Ultimate for ₹149"** featuring a rocket icon (`Icons.rocket_launch`).
    - Tap handler passes `Lifetime Ultimate (Upcoming)` and welcomes user with instant pro preview access.
  - *Quality Assurance:* `flutter analyze` 0 errors, 0 warnings; `flutter test` 9/9 test suites passing (100% green).

---

## [1.4.7] - 2026-10-06

### 📐 Plans & Upgrades: Vertical Plans Aligned Side by Side

- **When:** 2026-10-06 01:22 AM IST
- **What Was Changed:**
  - Redesigned the plans layout in [`PremiumScreen`](file:///c:/Users/neeraj49yadav/OneDrive/Desktop/Student%20Utilitty%20Hub/lib/features/premium/premium_screen.dart) from stacked vertical banners to **vertical column cards placed side by side**:
    - **Wide Screens & Desktop (width $\ge$ 850px):** 3 equal-width columns side by side using `IntrinsicHeight` and `Row(crossAxisAlignment: CrossAxisAlignment.stretch)`.
    - **Mobile & Narrow Screens (width $<$ 850px):** Smooth horizontal carousel layout using `SingleChildScrollView(scrollDirection: Axis.horizontal)` with fixed card widths and `IntrinsicHeight` to ensure all 3 plans align side by side.
    - Updated each tier card with uniform subtitle heights, dividers, and `MainAxisAlignment.spaceBetween` so action buttons are locked to the bottom of all cards.
  - *Quality Assurance:* `flutter analyze` 0 errors, 0 warnings; `flutter test` 9/9 test suites passing (100% green).

---

## [1.4.8] - 2026-10-06

### 🛡️ App-Wide Deletion Safety: Explicit User Cross-Confirmation Dialogs

- **When:** 2026-10-06 01:29 AM IST
- **What Was Changed:**
  - Implemented reusable modal `showConfirmDeleteDialog` in [`common_widgets.dart`](file:///c:/Users/neeraj49yadav/OneDrive/Desktop/Student%20Utilitty%20Hub/lib/core/widgets/common_widgets.dart) with title, item preview, cancel option, and destructive action styling.
  - Added mandatory cross-confirmation dialogs across all deletion actions in the entire app:
    1. **Assignments:** [`assignments_screen.dart`](file:///c:/Users/neeraj49yadav/OneDrive/Desktop/Student%20Utilitty%20Hub/lib/features/assignments/assignments_screen.dart) — confirms before deleting any assignment task.
    2. **Attendance Subjects:** [`attendance_calculator_screen.dart`](file:///c:/Users/neeraj49yadav/OneDrive/Desktop/Student%20Utilitty%20Hub/lib/features/calculator/attendance_calculator_screen.dart) — confirms before deleting subject attendance logs.
    3. **Semesters (CGPA):** [`cgpa_calculator_screen.dart`](file:///c:/Users/neeraj49yadav/OneDrive/Desktop/Student%20Utilitty%20Hub/lib/features/calculator/cgpa_calculator_screen.dart) — confirms before removing a saved semester record.
    4. **Checklist Tasks:** [`checklist_screen.dart`](file:///c:/Users/neeraj49yadav/OneDrive/Desktop/Student%20Utilitty%20Hub/lib/features/checklist/checklist_screen.dart) — confirms before deleting a checklist item.
    5. **Exam Countdown:** [`exam_countdown_screen.dart`](file:///c:/Users/neeraj49yadav/OneDrive/Desktop/Student%20Utilitty%20Hub/lib/features/exam/exam_countdown_screen.dart) — confirms before deleting an exam entry.
    6. **Campus Expenses:** [`campus_expense_screen.dart`](file:///c:/Users/neeraj49yadav/OneDrive/Desktop/Student%20Utilitty%20Hub/lib/features/expenses/campus_expense_screen.dart) — confirms before deleting an expense item.
    7. **Notes:** [`notes_screen.dart`](file:///c:/Users/neeraj49yadav/OneDrive/Desktop/Student%20Utilitty%20Hub/lib/features/notes/notes_screen.dart) — confirms before deleting a note.
    8. **Timetable:** [`timetable_screen.dart`](file:///c:/Users/neeraj49yadav/OneDrive/Desktop/Student%20Utilitty%20Hub/lib/features/timetable/timetable_screen.dart) — confirms before clearing an existing timetable slot.
    9. **SGPA Rows:** [`sgpa_calculator_screen.dart`](file:///c:/Users/neeraj49yadav/OneDrive/Desktop/Student%20Utilitty%20Hub/lib/features/calculator/sgpa_calculator_screen.dart) — confirms before removing a row if data has been entered.
    10. **Data Reset:** [`settings_screen.dart`](file:///c:/Users/neeraj49yadav/OneDrive/Desktop/Student%20Utilitty%20Hub/lib/features/settings/settings_screen.dart) — confirms before clearing application starter templates.
  - *Quality Assurance:* `flutter analyze` 0 errors, 0 warnings; `flutter test` 9/9 test suites passing (100% green).

---

## [1.4.9] - 2026-10-06

### 🧹 Plans & Upgrades: Removed Redundant Header & Comparison Subtitles

- **When:** 2026-10-06 01:31 AM IST
- **What Was Changed:**
  - Removed `"Choose Your One-Time Pass"` header and `"Compare plans side by side. All passes grant lifetime offline access."` subtitle from [`PremiumScreen`](file:///c:/Users/neeraj49yadav/OneDrive/Desktop/Student%20Utilitty%20Hub/lib/features/premium/premium_screen.dart).
  - *Quality Assurance:* `flutter analyze` 0 errors, 0 warnings; `flutter test` 9/9 test suites passing (100% green).

---

## [1.4.10] - 2026-10-06

### ↩️ Plans & Upgrades: Reverted Side-by-Side Layout to Stacked Cards

- **When:** 2026-10-06 01:34 AM IST
- **What Was Changed:**
  - Reverted the side-by-side row/carousel layout in [`PremiumScreen`](file:///c:/Users/neeraj49yadav/OneDrive/Desktop/Student%20Utilitty%20Hub/lib/features/premium/premium_screen.dart).
  - Restored full-width, vertically stacked tier cards in the main screen `Column` (**Remove Ads ₹39**, **Pro Student ₹89**, and **Lifetime Ultimate ₹149 UPCOMING**).
  - Restored natural vertical padding and card flow for maximum readability on all screen sizes.
  - *Quality Assurance:* `flutter analyze` 0 errors, 0 warnings; `flutter test` 9/9 test suites passing (100% green).

---

## [1.4.11] - 2026-10-06

### 🔒 Plans & Upgrades: Disabled Purchase Button for Plan ₹149 (Lifetime Ultimate)

- **When:** 2026-10-06 01:37 AM IST
- **What Was Changed:**
  - Disabled the purchase button for the **Lifetime Ultimate (₹149)** plan card in [`PremiumScreen`](file:///c:/Users/neeraj49yadav/OneDrive/Desktop/Student%20Utilitty%20Hub/lib/features/premium/premium_screen.dart):
    - Added `isEnabled` flag with `onTap: null` and `onPressed: isEnabled ? onTap : null`.
    - Button displays in Material 3 disabled state (`Coming Soon (₹149)`).
    - Prevents accidental purchases while the plan is in upcoming preview status.
  - *Quality Assurance:* `flutter analyze` 0 errors, 0 warnings; `flutter test` 9/9 test suites passing (100% green).

---

## [1.4.12] - 2026-10-06

### 🏷️ Plans & Upgrades: Updated Plan ₹149 Badge to "COMING SOON"

- **When:** 2026-10-06 01:41 AM IST
- **What Was Changed:**
  - *Quality Assurance:* `flutter analyze` 0 errors, 0 warnings; `flutter test` 9/9 test suites passing (100% green).

---

## [1.4.13] - 2026-10-06

### 🛡️ Anti-AdBlock Shield & Resilient Ad Engine (Ad-Blocker Proof Free Tier)

- **When:** 2026-10-06 01:45 AM IST
- **What Was Changed:**
  - Implemented [`AntiAdBlockService`](file:///c:/Users/neeraj49yadav/OneDrive/Desktop/Student%20Utilitty%20Hub/lib/core/services/anti_adblock_service.dart) to detect DNS sinkholes, Private DNS blockers (AdGuard, NextDNS, Pi-hole), and VPN ad filters.
  - Built **Resilient In-App Sponsored Ad Engine**:
    - Serves verified student partner campaigns (Internshala, GeeksforGeeks, Campus Tech Deals, Pro Pass) rendered directly via Flutter's internal canvas.
    - **100% Ad-Blocker Proof:** Because the campaigns are delivered and rendered natively from application memory, no network, DNS, or VPN ad-blocker can suppress or block them in the free tier.
    - Dynamically displays an `ANTI-ADBLOCK` status shield badge when an ad blocker is detected.
    - Provides a polite info dialog explaining that free usage is supported by student sponsors and offers the one-time ₹39 upgrade.
  - Fully integrated into [`GooglePlayCompliantAdBanner`](file:///c:/Users/neeraj49yadav/OneDrive/Desktop/Student%20Utilitty%20Hub/lib/core/widgets/common_widgets.dart) across all screens.
  - Pro users (`isPro == true`) continue to have all ads completely suppressed with zero footprint.
---

## [1.5.0] - 2026-10-06

### 🚀 Production Transition: Zero-Mock Clean State & Pure User Data Engine

- **When:** 2026-10-06 01:55 AM IST
- **What Was Changed:**
  - **Removed All Mock Seed Data (`_seedDefaultStudentData`):**
    - Completely purged hardcoded demo subjects (DBMS, OS, CN), timetable lectures, assignments, exams, and expenses from [`StorageService`](file:///c:/Users/neeraj49yadav/OneDrive/Desktop/Student%20Utilitty%20Hub/lib/core/services/storage_service.dart).
    - Fresh installations now start in an authentic, pristine zero-data state where every item is 100% driven by real user input.
  - **Clean User Profile Initialized:**
    - Replaced dummy academic identity defaults with a clean fallback (`Student`, empty college/branch/semester/roll number) ready for user customization.
  - **Testing Toggles Removed:**
    - Purged testing-only `Revert to Free Tier (Testing Toggle)` debug button from [`PremiumScreen`](file:///c:/Users/neeraj49yadav/OneDrive/Desktop/Student%20Utilitty%20Hub/lib/features/premium/premium_screen.dart).
  - **Enhanced Settings Data Wipe:**
    - Updated "Reset All Data" to "Clear All User Data" in [`SettingsScreen`](file:///c:/Users/neeraj49yadav/OneDrive/Desktop/Student%20Utilitty%20Hub/lib/features/settings/settings_screen.dart), ensuring that user data wipes completely without re-injecting fake demo records.
  - **Test Suite Cleanup:**
    - Deleted the `test/` directory and test artifacts per explicit user authorization and verification.
  - *Quality Assurance:* `flutter analyze` 0 errors, 0 warnings (10 non-fatal info items).

---

## [1.5.1] - 2026-10-06

### 🔒 Tier-Based Feature Gating & Commercial Plan Locks

- **When:** 2026-10-06 02:07 AM IST
- **What Was Changed:**
  - **Plan Model & State Engine:**
    - Defined `UserPlan` enum (`free`, `removeAds`, `proStudent`, `lifetimeUltimate`) in [`StorageService`](file:///c:/Users/neeraj49yadav/OneDrive/Desktop/Student%20Utilitty%20Hub/lib/core/services/storage_service.dart).
    - Added plan-level helper predicates: `isAdFree`, `isProStudent`, `isLifetimeUltimate`.
  - **Feature Locks by Plan Tier:**
    - **Free Tier (Default):**
      - Ad-supported with Anti-AdBlock engine active.
      - Saved Semesters: capped at 2.
      - Bunk Planner & Advanced Attendance Predictions: locked behind Pro Student with preview card.
      - Custom Accent Themes: locked behind Pro Student.
      - Export Academic PDF Reports: locked behind Pro Student.
    - **Remove Ads Plan (₹39):**
      - All banner and interstitial ads completely removed.
      - Super-fast load times.
      - Advanced academic tools remain gated with upgrade path to Pro Student.
    - **Pro Student Plan (₹89):**
      - All ad-free benefits.
      - **Unlimited Saved Semesters** unlocked in SGPA & CGPA calculators.
      - **Advanced Attendance Predictions** (Bunk Planner & skip risk engine) fully unlocked.
      - **Custom Accent Themes** (6 palettes: Iris, Violet, Emerald, Cyan, Amber, Rose) dynamically applied across the entire app.
      - **Export Academic PDF Reports** unlocked for CGPA transcripts and Progress analytics reports.
    - **Lifetime Ultimate Plan (₹149 - Coming Soon):**
      - Purchase button disabled with "Coming Soon (₹149)".
      - AI Study Assistant preview in Study Hub.
      - Cloud Sync & Backup preview in Settings.
  - **Reusable Feature Lock UI:**
    - Created `showFeatureLockedDialog` in [`common_widgets.dart`](file:///c:/Users/neeraj49yadav/OneDrive/Desktop/Student%20Utilitty%20Hub/lib/core/widgets/common_widgets.dart).
  - *Quality Assurance:* `flutter analyze` 0 errors, 0 warnings.

---

## [1.5.2] - 2026-10-06

### 💡 Fair Plan Extension & Upgrade Price Difference System

- **When:** 2026-10-06 01:06 PM IST
- **What Was Changed:**
  - **Dynamic Plan Extension Calculations:**
    - If a user owns **Remove Ads (₹39)**, their ₹39 is automatically credited toward **Pro Student (₹89)**.
    - They only pay the exact difference: **+₹50** (`₹89 - ₹39 = ₹50`).
    - Lifetime Ultimate (₹149) extension is calculated similarly:
      - From Remove Ads: **+₹110** (`₹149 - ₹39 = ₹110`).
      - From Pro Student: **+₹60** (`₹149 - ₹89 = ₹60`).
  - **User Experience & Transparent Messaging:**
    - [`PremiumScreen`](file:///c:/Users/neeraj49yadav/OneDrive/Desktop/Student%20Utilitty%20Hub/lib/features/premium/premium_screen.dart): Displays green `SAVE ₹39 • EXTEND FOR ₹50` badge, strikethrough original price, extension credit explanation, and button label `"Extend to Pro Student for +₹50"`.
    - Added **Plan Extension Guarantee** card: *"Never pay twice. Your previous payments are 100% credited when extending to a higher plan."*
    - [`SettingsScreen`](file:///c:/Users/neeraj49yadav/OneDrive/Desktop/Student%20Utilitty%20Hub/lib/features/settings/settings_screen.dart): Shows `"Extend to Pro Student (+₹50)"` in the upgrade banner.
    - [`AttendanceCalculatorScreen`](file:///c:/Users/neeraj49yadav/OneDrive/Desktop/Student%20Utilitty%20Hub/lib/features/calculator/attendance_calculator_screen.dart): Locked Bunk Planner displays `₹39 Already Credited!` and button `"Extend with Pro Student (+₹50)"`.
    - [`showFeatureLockedDialog`](file:///c:/Users/neeraj49yadav/OneDrive/Desktop/Student%20Utilitty%20Hub/lib/core/widgets/common_widgets.dart): Prompts Remove Ads users with `"Extend Plan for +₹50"` and clearly notes the ₹39 credit.
  - *Quality Assurance:* `flutter analyze` 0 errors, 0 warnings.

---

## [1.5.3] - 2026-10-09

### 🍱 Timetable Slot Update: Replaced Lab Block with Lunch Break

- **When:** 2026-10-09 02:46 PM IST
- **What Was Changed:**
  - **Timetable Slot Dialog Updated:**
    - Replaced the `"🔬 2h Practical Lab Block"` toggle with `"🍱 Lunch Break"` in [`TimetableScreen`](file:///c:/Users/neeraj49yadav/OneDrive/Desktop/Student%20Utilitty%20Hub/lib/features/timetable/timetable_screen.dart).
    - When toggled on, it automatically presets the slot subject to `"Lunch Break"` without requiring manual input.
    - Added `"Lunch"` to quick-pick subject suggestions chips.
  - **Data Model Enhanced:**
    - Added `isLunch` property to [`TimetableSlot`](file:///c:/Users/neeraj49yadav/OneDrive/Desktop/Student%20Utilitty%20Hub/lib/shared/models/app_models.dart) with full serialization and backwards compatibility.
  - **UI & Badge Rendering:**
    - Timetable slot card displays a distinct `🍱 Lunch` badge with warm amber styling.
    - Updated [`HomeScreen`](file:///c:/Users/neeraj49yadav/OneDrive/Desktop/Student%20Utilitty%20Hub/lib/features/home/home_screen.dart) next-class indicator to display `LUNCH BREAK 🍱` with dining icon when the upcoming scheduled slot is lunch.
  - *Quality Assurance:* `flutter analyze` 0 errors, 0 warnings.
