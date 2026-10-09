import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../../shared/models/app_models.dart';

enum UserPlan {
  free,
  removeAds,
  proStudent,
  lifetimeUltimate,
}

class StorageService extends ChangeNotifier {
  static late SharedPreferences _prefs;

  // State caches
  List<Semester> _semesters = [];
  List<AttendanceSubject> _attendanceSubjects = [];
  List<TimetableSlot> _timetableSlots = [];
  List<Assignment> _assignments = [];
  List<ExamEntry> _exams = [];
  List<ChecklistItem> _checklist = [];
  List<NoteItem> _notes = [];
  List<StudySessionLog> _studyLogs = [];
  List<String> _favorites = [];

  String _userName = 'Student';
  String _collegeName = '';
  String _degreeBranch = '';
  String _semesterName = '';
  String _rollNumber = '';

  String _themeMode = 'system'; // 'light', 'dark', 'system'
  String _themePresetId = 'ocean_blue';
  bool _notificationsEnabled = true;
  UserPlan _userPlan = UserPlan.free;
  int? _accentColorValue;
  bool _isProUser = false;
  double _defaultRequiredAttendance = 75.0;

  int _studyStreak = 1;
  String _lastActiveDate = '';

  List<CampusExpense> _expenses = [];

  // Getters
  List<Semester> get semesters => List.unmodifiable(_semesters);
  List<AttendanceSubject> get attendanceSubjects => List.unmodifiable(_attendanceSubjects);
  List<TimetableSlot> get timetableSlots => List.unmodifiable(_timetableSlots);
  List<Assignment> get assignments => List.unmodifiable(_assignments);
  List<ExamEntry> get exams => List.unmodifiable(_exams);
  List<ChecklistItem> get checklist => List.unmodifiable(_checklist);
  List<NoteItem> get notes => List.unmodifiable(_notes);
  List<StudySessionLog> get studyLogs => List.unmodifiable(_studyLogs);
  List<CampusExpense> get expenses => List.unmodifiable(_expenses);
  List<String> get favorites => List.unmodifiable(_favorites);

  String get userName => _userName;
  String get collegeName => _collegeName;
  String get degreeBranch => _degreeBranch;
  String get semesterName => _semesterName;
  String get rollNumber => _rollNumber;
  String get themeMode => _themeMode;
  bool get notificationsEnabled => _notificationsEnabled;
  UserPlan get currentPlan => _userPlan;
  bool get isAdFree => _userPlan != UserPlan.free;
  bool get isProStudent => _userPlan == UserPlan.proStudent || _userPlan == UserPlan.lifetimeUltimate;
  bool get isLifetimeUltimate => _userPlan == UserPlan.lifetimeUltimate;
  bool get isProUser => isAdFree;

  int get maxSavedSemesters {
    if (isProStudent) return 999;
    if (_userPlan == UserPlan.removeAds) return 4;
    return 2;
  }

  int? get customAccentColorValue => _accentColorValue;
  String get themePresetId => _themePresetId;
  double get defaultRequiredAttendance => _defaultRequiredAttendance;
  int get studyStreak => _studyStreak;

  // Initialize and load
  static StorageService? _instance;
  static StorageService get instance => _instance!;
  static StorageService? get maybeInstance => _instance;

  static Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    final service = StorageService();
    await service._loadAllData();
    _instance = service;
    return service;
  }

  Future<void> _loadAllData() async {
    _userName = _prefs.getString('hub_user_name') ?? 'Student';
    _collegeName = _prefs.getString('hub_college_name') ?? '';
    _degreeBranch = _prefs.getString('hub_degree_branch') ?? '';
    _semesterName = _prefs.getString('hub_semester_name') ?? '';
    _rollNumber = _prefs.getString('hub_roll_number') ?? '';

    _themeMode = _prefs.getString('hub_theme_mode') ?? 'system';
    _notificationsEnabled = _prefs.getBool('hub_notifications') ?? true;
    final planKey = _prefs.getString('hub_user_plan');
    if (planKey != null) {
      if (planKey == 'remove_ads') {
        _userPlan = UserPlan.removeAds;
      } else if (planKey == 'pro_student') {
        _userPlan = UserPlan.proStudent;
      } else if (planKey == 'lifetime') {
        _userPlan = UserPlan.lifetimeUltimate;
      } else {
        _userPlan = UserPlan.free;
      }
    } else {
      final legacyPro = _prefs.getBool('hub_is_pro') ?? false;
      _userPlan = legacyPro ? UserPlan.proStudent : UserPlan.free;
    }
    _isProUser = isAdFree;
    _accentColorValue = _prefs.getInt('hub_accent_color');
    _themePresetId = _prefs.getString('hub_theme_preset_id') ?? 'ocean_blue';
    AppTheme.applyPreset(AppTheme.getPreset(_themePresetId));
    _defaultRequiredAttendance = _prefs.getDouble('hub_req_attendance') ?? 75.0;
    _favorites = _prefs.getStringList('hub_favorites') ?? ['cgpa', 'attendance', 'pomodoro', 'exams'];
    _studyStreak = _prefs.getInt('hub_streak') ?? 0;
    _lastActiveDate = _prefs.getString('hub_last_active') ?? '';
    _checkDailyStreak();

    // Load Semesters
    final semString = _prefs.getString('hub_semesters');
    if (semString != null) {
      final List list = jsonDecode(semString);
      _semesters = list.map((e) => Semester.fromMap(Map<String, dynamic>.from(e))).toList();
    }

    // Load Attendance
    final attString = _prefs.getString('hub_attendance');
    if (attString != null) {
      final List list = jsonDecode(attString);
      _attendanceSubjects = list.map((e) => AttendanceSubject.fromMap(Map<String, dynamic>.from(e))).toList();
    }

    // Load Timetable
    final ttString = _prefs.getString('hub_timetable');
    if (ttString != null) {
      final List list = jsonDecode(ttString);
      _timetableSlots = list.map((e) => TimetableSlot.fromMap(Map<String, dynamic>.from(e))).toList();
    }

    // Load Assignments
    final assignString = _prefs.getString('hub_assignments');
    if (assignString != null) {
      final List list = jsonDecode(assignString);
      _assignments = list.map((e) => Assignment.fromMap(Map<String, dynamic>.from(e))).toList();
    }

    // Load Exams
    final examString = _prefs.getString('hub_exams');
    if (examString != null) {
      final List list = jsonDecode(examString);
      _exams = list.map((e) => ExamEntry.fromMap(Map<String, dynamic>.from(e))).toList();
    }

    // Load Checklist
    final checkString = _prefs.getString('hub_checklist');
    if (checkString != null) {
      final List list = jsonDecode(checkString);
      _checklist = list.map((e) => ChecklistItem.fromMap(Map<String, dynamic>.from(e))).toList();
    }

    // Load Notes
    final notesString = _prefs.getString('hub_notes');
    if (notesString != null) {
      final List list = jsonDecode(notesString);
      _notes = list.map((e) => NoteItem.fromMap(Map<String, dynamic>.from(e))).toList();
    }

    // Load Study Logs
    final logsString = _prefs.getString('hub_study_logs');
    if (logsString != null) {
      final List list = jsonDecode(logsString);
      _studyLogs = list.map((e) => StudySessionLog.fromMap(Map<String, dynamic>.from(e))).toList();
    }

    // Load Campus Expenses
    final expString = _prefs.getString('hub_expenses');
    if (expString != null) {
      final List list = jsonDecode(expString);
      _expenses = list.map((e) => CampusExpense.fromMap(Map<String, dynamic>.from(e))).toList();
    }

  }

  // Attendance Operations
  Future<void> addAttendanceSubject(AttendanceSubject subject) async {
    _attendanceSubjects.add(subject);
    await _saveAttendance();
    notifyListeners();
  }

  Future<void> updateAttendance(String id, int attended, int total, {int? medicalLeaves}) async {
    final index = _attendanceSubjects.indexWhere((e) => e.id == id);
    if (index != -1) {
      _attendanceSubjects[index].attended = attended;
      _attendanceSubjects[index].total = total;
      if (medicalLeaves != null) {
        _attendanceSubjects[index].medicalLeaves = medicalLeaves;
      }
      await _saveAttendance();
      notifyListeners();
    }
  }

  Future<void> deleteAttendanceSubject(String id) async {
    _attendanceSubjects.removeWhere((e) => e.id == id);
    await _saveAttendance();
    notifyListeners();
  }

  Future<void> _saveAttendance() async {
    await _prefs.setString('hub_attendance', jsonEncode(_attendanceSubjects.map((e) => e.toMap()).toList()));
  }

  // Semester & CGPA Operations
  Future<void> saveSemester(Semester sem) async {
    final idx = _semesters.indexWhere((s) => s.id == sem.id);
    if (idx != -1) {
      _semesters[idx] = sem;
    } else {
      _semesters.add(sem);
    }
    await _prefs.setString('hub_semesters', jsonEncode(_semesters.map((e) => e.toMap()).toList()));
    notifyListeners();
  }

  Future<void> deleteSemester(String id) async {
    _semesters.removeWhere((e) => e.id == id);
    await _prefs.setString('hub_semesters', jsonEncode(_semesters.map((e) => e.toMap()).toList()));
    notifyListeners();
  }

  double calculateCumulativeCGPA() {
    if (_semesters.isEmpty) return 0.0;
    double totalPoints = 0.0;
    double totalCredits = 0.0;
    for (final sem in _semesters) {
      totalPoints += sem.sgpa * sem.totalCredits;
      totalCredits += sem.totalCredits;
    }
    return totalCredits == 0 ? 0.0 : totalPoints / totalCredits;
  }

  // Timetable Operations & Grid Dimensions
  int get timetableRowCount => _prefs.getInt('hub_tt_rows') ?? 6;
  int get timetableColumnCount => _prefs.getInt('hub_tt_cols') ?? 6;

  Future<void> updateTimetableGridDimensions(int rows, int cols) async {
    await _prefs.setInt('hub_tt_rows', rows);
    await _prefs.setInt('hub_tt_cols', cols);
    notifyListeners();
  }

  Future<void> saveOrUpdateTimetableSlot(TimetableSlot slot) async {
    final idx = _timetableSlots.indexWhere((s) => s.id == slot.id || (s.dayOfWeek == slot.dayOfWeek && s.periodNumber == slot.periodNumber));
    if (idx != -1) {
      _timetableSlots[idx] = slot;
    } else {
      _timetableSlots.add(slot);
    }
    await _saveTimetable();
    notifyListeners();
  }

  Future<void> addTimetableSlot(TimetableSlot slot) async {
    _timetableSlots.add(slot);
    await _saveTimetable();
    notifyListeners();
  }

  Future<void> toggleSlotCancelled(String id) async {
    final idx = _timetableSlots.indexWhere((s) => s.id == id);
    if (idx != -1) {
      _timetableSlots[idx].isCancelled = !_timetableSlots[idx].isCancelled;
      await _saveTimetable();
      notifyListeners();
    }
  }

  Future<void> deleteTimetableSlot(String id) async {
    _timetableSlots.removeWhere((e) => e.id == id);
    await _saveTimetable();
    notifyListeners();
  }

  Future<void> clearSlotAt(String dayOfWeek, String periodNumber) async {
    _timetableSlots.removeWhere((s) => s.dayOfWeek == dayOfWeek && s.periodNumber == periodNumber);
    await _saveTimetable();
    notifyListeners();
  }

  Future<void> _saveTimetable() async {
    await _prefs.setString('hub_timetable', jsonEncode(_timetableSlots.map((e) => e.toMap()).toList()));
  }

  // Assignment Operations
  Future<void> addAssignment(Assignment assignment) async {
    _assignments.add(assignment);
    await _saveAssignments();
    notifyListeners();
  }

  Future<void> updateAssignment(Assignment assignment) async {
    final idx = _assignments.indexWhere((e) => e.id == assignment.id);
    if (idx != -1) {
      _assignments[idx] = assignment;
      await _saveAssignments();
      notifyListeners();
    }
  }

  Future<void> deleteAssignment(String id) async {
    _assignments.removeWhere((e) => e.id == id);
    await _saveAssignments();
    notifyListeners();
  }

  Future<void> _saveAssignments() async {
    await _prefs.setString('hub_assignments', jsonEncode(_assignments.map((e) => e.toMap()).toList()));
  }

  // Exam Operations
  Future<void> addExam(ExamEntry exam) async {
    _exams.add(exam);
    await _saveExams();
    notifyListeners();
  }

  Future<void> toggleExamUnitCompleted(String examId, int unitIndex) async {
    final idx = _exams.indexWhere((e) => e.id == examId);
    if (idx != -1) {
      final old = _exams[idx];
      final List<int> updatedCompleted = List<int>.from(old.completedUnits);
      if (updatedCompleted.contains(unitIndex)) {
        updatedCompleted.remove(unitIndex);
      } else {
        updatedCompleted.add(unitIndex);
      }
      _exams[idx] = ExamEntry(
        id: old.id,
        subject: old.subject,
        examDate: old.examDate,
        examTime: old.examTime,
        location: old.location,
        notes: old.notes,
        priority: old.priority,
        syllabusUnits: old.syllabusUnits,
        completedUnits: updatedCompleted,
      );
      await _saveExams();
      notifyListeners();
    }
  }

  Future<void> deleteExam(String id) async {
    _exams.removeWhere((e) => e.id == id);
    await _saveExams();
    notifyListeners();
  }

  Future<void> _saveExams() async {
    await _prefs.setString('hub_exams', jsonEncode(_exams.map((e) => e.toMap()).toList()));
  }

  // Campus Expenses Operations
  Future<void> addExpense(CampusExpense expense) async {
    _expenses.insert(0, expense);
    await _saveExpenses();
    notifyListeners();
  }

  Future<void> deleteExpense(String id) async {
    _expenses.removeWhere((e) => e.id == id);
    await _saveExpenses();
    notifyListeners();
  }

  Future<void> _saveExpenses() async {
    await _prefs.setString('hub_expenses', jsonEncode(_expenses.map((e) => e.toMap()).toList()));
  }

  double getTodayExpenseTotal() {
    final now = DateTime.now();
    return _expenses
        .where((e) => e.timestamp.year == now.year && e.timestamp.month == now.month && e.timestamp.day == now.day)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  // Checklist Operations
  Future<void> addChecklistItem(ChecklistItem item) async {
    _checklist.add(item);
    await _saveChecklist();
    notifyListeners();
  }

  Future<void> toggleChecklistItem(String id) async {
    final idx = _checklist.indexWhere((e) => e.id == id);
    if (idx != -1) {
      _checklist[idx].isCompleted = !_checklist[idx].isCompleted;
      await _saveChecklist();
      notifyListeners();
    }
  }

  Future<void> deleteChecklistItem(String id) async {
    _checklist.removeWhere((e) => e.id == id);
    await _saveChecklist();
    notifyListeners();
  }

  Future<void> _saveChecklist() async {
    await _prefs.setString('hub_checklist', jsonEncode(_checklist.map((e) => e.toMap()).toList()));
  }

  // Note Operations
  Future<void> addNote(NoteItem note) async {
    _notes.insert(0, note);
    await _saveNotes();
    notifyListeners();
  }

  Future<void> updateNote(NoteItem note) async {
    final idx = _notes.indexWhere((e) => e.id == note.id);
    if (idx != -1) {
      _notes[idx] = note;
      await _saveNotes();
      notifyListeners();
    }
  }

  Future<void> togglePinNote(String id) async {
    final idx = _notes.indexWhere((e) => e.id == id);
    if (idx != -1) {
      final old = _notes[idx];
      _notes[idx] = NoteItem(
        id: old.id,
        title: old.title,
        subject: old.subject,
        content: old.content,
        tags: old.tags,
        isPinned: !old.isPinned,
        isFavorite: old.isFavorite,
        createdAt: old.createdAt,
        updatedAt: DateTime.now(),
      );
      await _saveNotes();
      notifyListeners();
    }
  }

  Future<void> deleteNote(String id) async {
    _notes.removeWhere((e) => e.id == id);
    await _saveNotes();
    notifyListeners();
  }

  Future<void> _saveNotes() async {
    await _prefs.setString('hub_notes', jsonEncode(_notes.map((e) => e.toMap()).toList()));
  }

  // Study Log Operations
  Future<void> logStudySession(int minutes, String subject) async {
    final log = StudySessionLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      durationMinutes: minutes,
      subject: subject,
    );
    _studyLogs.add(log);
    await _saveStudyLogs();
    notifyListeners();
  }

  Future<void> _saveStudyLogs() async {
    await _prefs.setString('hub_study_logs', jsonEncode(_studyLogs.map((e) => e.toMap()).toList()));
  }

  int getTodayFocusMinutes() {
    final now = DateTime.now();
    return _studyLogs
        .where((l) => l.timestamp.year == now.year && l.timestamp.month == now.month && l.timestamp.day == now.day)
        .fold(0, (sum, item) => sum + item.durationMinutes);
  }

  // Favorites
  Future<void> toggleFavorite(String toolKey) async {
    if (_favorites.contains(toolKey)) {
      _favorites.remove(toolKey);
    } else {
      _favorites.add(toolKey);
    }
    await _prefs.setStringList('hub_favorites', _favorites);
    notifyListeners();
  }

  // Student Profile Updates
  Future<void> updateCollegeProfile({
    String? name,
    String? college,
    String? degreeBranch,
    String? semesterName,
    String? rollNumber,
  }) async {
    if (name != null) {
      _userName = name;
      await _prefs.setString('hub_user_name', name);
    }
    if (college != null) {
      _collegeName = college;
      await _prefs.setString('hub_college_name', college);
    }
    if (degreeBranch != null) {
      _degreeBranch = degreeBranch;
      await _prefs.setString('hub_degree_branch', degreeBranch);
    }
    if (semesterName != null) {
      _semesterName = semesterName;
      await _prefs.setString('hub_semester_name', semesterName);
    }
    if (rollNumber != null) {
      _rollNumber = rollNumber;
      await _prefs.setString('hub_roll_number', rollNumber);
    }
    notifyListeners();
  }

  // Preferences
  Future<void> setUserName(String name) async {
    _userName = name;
    await _prefs.setString('hub_user_name', name);
    notifyListeners();
  }

  Future<void> setThemeMode(String mode) async {
    _themeMode = mode;
    await _prefs.setString('hub_theme_mode', mode);
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    await _prefs.setBool('hub_notifications', enabled);
    notifyListeners();
  }

  Future<void> setUserPlan(UserPlan plan) async {
    _userPlan = plan;
    _isProUser = isAdFree;
    String planKey = 'free';
    if (plan == UserPlan.removeAds) planKey = 'remove_ads';
    if (plan == UserPlan.proStudent) planKey = 'pro_student';
    if (plan == UserPlan.lifetimeUltimate) planKey = 'lifetime';
    await _prefs.setString('hub_user_plan', planKey);
    await _prefs.setBool('hub_is_pro', _isProUser);
    notifyListeners();
  }

  Future<void> setProUser(bool isPro) async {
    await setUserPlan(isPro ? UserPlan.proStudent : UserPlan.free);
  }

  Future<void> setCustomAccentColor(int? colorValue) async {
    _accentColorValue = colorValue;
    if (colorValue == null) {
      await _prefs.remove('hub_accent_color');
    } else {
      await _prefs.setInt('hub_accent_color', colorValue);
    }
    notifyListeners();
  }

  Future<void> setThemePreset(String presetId) async {
    final preset = AppTheme.getPreset(presetId);
    _themePresetId = presetId;
    AppTheme.applyPreset(preset);
    _accentColorValue = preset.primaryColor.toARGB32();
    await _prefs.setString('hub_theme_preset_id', presetId);
    await _prefs.setInt('hub_accent_color', preset.primaryColor.toARGB32());

    if (preset.preferredMode != null) {
      _themeMode = preset.preferredMode!;
      await _prefs.setString('hub_theme_mode', _themeMode);
    }

    notifyListeners();
  }

  void _checkDailyStreak() {
    final today = _formatDate(DateTime.now());
    if (_lastActiveDate.isEmpty) {
      _lastActiveDate = today;
      _prefs.setString('hub_last_active', today);
      _prefs.setInt('hub_streak', _studyStreak);
      return;
    }

    if (_lastActiveDate == today) {
      return; // Already recorded today
    }

    final last = DateTime.tryParse(_lastActiveDate);
    final now = DateTime.now();
    if (last != null) {
      final diffDays = DateTime(now.year, now.month, now.day).difference(DateTime(last.year, last.month, last.day)).inDays;
      if (diffDays == 1) {
        // Consecutive day
        _studyStreak++;
      } else if (diffDays > 1) {
        // Streak broken
        _studyStreak = 1;
      }
      _lastActiveDate = today;
      _prefs.setString('hub_last_active', today);
      _prefs.setInt('hub_streak', _studyStreak);
    }
  }

  void recordStudyActivity() {
    _checkDailyStreak();
    notifyListeners();
  }

  String _formatDate(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  // JSON Backup & Restore
  String exportDataAsJson() {
    final Map<String, dynamic> exportMap = {
      'version': '1.2.0',
      'exportedAt': DateTime.now().toIso8601String(),
      'userName': _userName,
      'collegeName': _collegeName,
      'degreeBranch': _degreeBranch,
      'semesterName': _semesterName,
      'rollNumber': _rollNumber,
      'themeMode': _themeMode,
      'isPro': _isProUser,
      'studyStreak': _studyStreak,
      'semesters': _semesters.map((s) => s.toMap()).toList(),
      'attendance': _attendanceSubjects.map((a) => a.toMap()).toList(),
      'timetable': _timetableSlots.map((t) => t.toMap()).toList(),
      'assignments': _assignments.map((a) => a.toMap()).toList(),
      'exams': _exams.map((e) => e.toMap()).toList(),
      'expenses': _expenses.map((e) => e.toMap()).toList(),
      'checklist': _checklist.map((c) => c.toMap()).toList(),
      'notes': _notes.map((n) => n.toMap()).toList(),
      'studyLogs': _studyLogs.map((l) => l.toMap()).toList(),
      'favorites': _favorites,
    };
    return const JsonEncoder.withIndent('  ').convert(exportMap);
  }

  Future<bool> importDataFromJson(String jsonString) async {
    try {
      final Map<String, dynamic> data = jsonDecode(jsonString);
      if (data.containsKey('semesters')) {
        _semesters = (data['semesters'] as List).map((e) => Semester.fromMap(Map<String, dynamic>.from(e))).toList();
        await _prefs.setString('hub_semesters', jsonEncode(_semesters.map((e) => e.toMap()).toList()));
      }
      if (data.containsKey('attendance')) {
        _attendanceSubjects = (data['attendance'] as List).map((e) => AttendanceSubject.fromMap(Map<String, dynamic>.from(e))).toList();
        await _saveAttendance();
      }
      if (data.containsKey('timetable')) {
        _timetableSlots = (data['timetable'] as List).map((e) => TimetableSlot.fromMap(Map<String, dynamic>.from(e))).toList();
        await _saveTimetable();
      }
      if (data.containsKey('assignments')) {
        _assignments = (data['assignments'] as List).map((e) => Assignment.fromMap(Map<String, dynamic>.from(e))).toList();
        await _saveAssignments();
      }
      if (data.containsKey('exams')) {
        _exams = (data['exams'] as List).map((e) => ExamEntry.fromMap(Map<String, dynamic>.from(e))).toList();
        await _saveExams();
      }
      if (data.containsKey('expenses')) {
        _expenses = (data['expenses'] as List).map((e) => CampusExpense.fromMap(Map<String, dynamic>.from(e))).toList();
        await _saveExpenses();
      }
      if (data.containsKey('checklist')) {
        _checklist = (data['checklist'] as List).map((e) => ChecklistItem.fromMap(Map<String, dynamic>.from(e))).toList();
        await _saveChecklist();
      }
      if (data.containsKey('notes')) {
        _notes = (data['notes'] as List).map((e) => NoteItem.fromMap(Map<String, dynamic>.from(e))).toList();
        await _saveNotes();
      }
      if (data.containsKey('studyLogs')) {
        _studyLogs = (data['studyLogs'] as List).map((e) => StudySessionLog.fromMap(Map<String, dynamic>.from(e))).toList();
        await _saveStudyLogs();
      }
      if (data.containsKey('userName')) {
        _userName = data['userName'] ?? 'Neeraj Yadav';
        await _prefs.setString('hub_user_name', _userName);
      }
      if (data.containsKey('collegeName')) {
        _collegeName = data['collegeName'] ?? 'Delhi Technological University';
        await _prefs.setString('hub_college_name', _collegeName);
      }
      if (data.containsKey('degreeBranch')) {
        _degreeBranch = data['degreeBranch'] ?? 'B.Tech Computer Science';
        await _prefs.setString('hub_degree_branch', _degreeBranch);
      }
      if (data.containsKey('semesterName')) {
        _semesterName = data['semesterName'] ?? 'Semester 5';
        await _prefs.setString('hub_semester_name', _semesterName);
      }
      if (data.containsKey('rollNumber')) {
        _rollNumber = data['rollNumber'] ?? '21/CS/104';
        await _prefs.setString('hub_roll_number', _rollNumber);
      }
      if (data.containsKey('studyStreak')) {
        _studyStreak = data['studyStreak'] ?? 1;
        await _prefs.setInt('hub_streak', _studyStreak);
      }
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error restoring backup: $e');
      return false;
    }
  }

  Future<void> resetAllData() async {
    await _prefs.clear();
    _semesters = [];
    _attendanceSubjects = [];
    _timetableSlots = [];
    _assignments = [];
    _exams = [];
    _expenses = [];
    _checklist = [];
    _notes = [];
    _studyLogs = [];
    _favorites = ['cgpa', 'attendance', 'pomodoro', 'exams'];
    _userName = 'Student';
    _collegeName = '';
    _degreeBranch = '';
    _semesterName = '';
    _rollNumber = '';
    _userPlan = UserPlan.free;
    _accentColorValue = null;
    _isProUser = false;
    _studyStreak = 0;
    notifyListeners();
  }
}

