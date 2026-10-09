class Subject {
  final String id;
  final String name;
  final String code;
  final double credits;
  final String grade;
  final double gradePoint;

  Subject({
    required this.id,
    required this.name,
    this.code = '',
    required this.credits,
    required this.grade,
    required this.gradePoint,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'code': code,
    'credits': credits,
    'grade': grade,
    'gradePoint': gradePoint,
  };

  factory Subject.fromMap(Map<String, dynamic> map) => Subject(
    id: map['id'] ?? '',
    name: map['name'] ?? '',
    code: map['code'] ?? '',
    credits: (map['credits'] as num?)?.toDouble() ?? 3.0,
    grade: map['grade'] ?? 'A',
    gradePoint: (map['gradePoint'] as num?)?.toDouble() ?? 8.0,
  );
}

class Semester {
  final String id;
  final String name;
  final List<Subject> subjects;
  final double sgpa;
  final double totalCredits;

  Semester({
    required this.id,
    required this.name,
    required this.subjects,
    required this.sgpa,
    required this.totalCredits,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'subjects': subjects.map((s) => s.toMap()).toList(),
    'sgpa': sgpa,
    'totalCredits': totalCredits,
  };

  factory Semester.fromMap(Map<String, dynamic> map) => Semester(
    id: map['id'] ?? '',
    name: map['name'] ?? '',
    subjects: (map['subjects'] as List? ?? [])
        .map((e) => Subject.fromMap(Map<String, dynamic>.from(e)))
        .toList(),
    sgpa: (map['sgpa'] as num?)?.toDouble() ?? 0.0,
    totalCredits: (map['totalCredits'] as num?)?.toDouble() ?? 0.0,
  );
}

class AttendanceSubject {
  final String id;
  final String name;
  int attended;
  int total;
  int medicalLeaves; // Approved Duty Leaves / Medical Certificates (OD)
  double requiredPercentage;
  final String notes;

  AttendanceSubject({
    required this.id,
    required this.name,
    this.attended = 0,
    this.total = 0,
    this.medicalLeaves = 0,
    this.requiredPercentage = 75.0,
    this.notes = '',
  });

  // Regular attendance without OD
  double get percentage => total == 0 ? 100.0 : (attended / total) * 100.0;

  // Effective attendance including approved OD / Medical waivers
  double get effectivePercentage => total == 0 ? 100.0 : ((attended + medicalLeaves) / total) * 100.0;

  int get skippableClasses {
    if (total == 0) return 0;
    final reqRatio = requiredPercentage / 100.0;
    if (reqRatio <= 0 || reqRatio >= 1) return 0;
    final skippable = (((attended + medicalLeaves) - reqRatio * total) / reqRatio).floor();
    return skippable > 0 ? skippable : 0;
  }

  int get classesNeeded {
    if (total == 0) return 0;
    final reqRatio = requiredPercentage / 100.0;
    if (effectivePercentage >= requiredPercentage) return 0;
    if (reqRatio >= 1.0) return 99;
    final needed = ((reqRatio * total - (attended + medicalLeaves)) / (1 - reqRatio)).ceil();
    return needed > 0 ? needed : 0;
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'attended': attended,
    'total': total,
    'medicalLeaves': medicalLeaves,
    'requiredPercentage': requiredPercentage,
    'notes': notes,
  };

  factory AttendanceSubject.fromMap(Map<String, dynamic> map) => AttendanceSubject(
    id: map['id'] ?? '',
    name: map['name'] ?? '',
    attended: map['attended'] ?? 0,
    total: map['total'] ?? 0,
    medicalLeaves: map['medicalLeaves'] ?? 0,
    requiredPercentage: (map['requiredPercentage'] as num?)?.toDouble() ?? 75.0,
    notes: map['notes'] ?? '',
  );
}

class TimetableSlot {
  final String id;
  final String dayOfWeek; // Monday, Tuesday, ...
  final String subject;
  final String room;
  final String startTime; // '09:00'
  final String endTime; // '10:00'
  final String periodNumber; // 'Period 1', 'Period 2', 'Lab Session'
  final String professorName; // e.g. 'Prof. Sharma'
  final bool isLab; // 2-hr or 3-hr practical block
  final bool isLunch; // Lunch break slot
  bool isCancelled; // Cancelled today by professor / mass bunk
  final int colorValue;

  TimetableSlot({
    required this.id,
    required this.dayOfWeek,
    required this.subject,
    this.room = '',
    required this.startTime,
    required this.endTime,
    this.periodNumber = 'Period 1',
    this.professorName = '',
    this.isLab = false,
    this.isLunch = false,
    this.isCancelled = false,
    this.colorValue = 0xFF6366F1,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'dayOfWeek': dayOfWeek,
    'subject': subject,
    'room': room,
    'startTime': startTime,
    'endTime': endTime,
    'periodNumber': periodNumber,
    'professorName': professorName,
    'isLab': isLab,
    'isLunch': isLunch,
    'isCancelled': isCancelled,
    'colorValue': colorValue,
  };

  factory TimetableSlot.fromMap(Map<String, dynamic> map) => TimetableSlot(
    id: map['id'] ?? '',
    dayOfWeek: map['dayOfWeek'] ?? 'Monday',
    subject: map['subject'] ?? '',
    room: map['room'] ?? '',
    startTime: map['startTime'] ?? '09:00',
    endTime: map['endTime'] ?? '10:00',
    periodNumber: map['periodNumber'] ?? 'Period 1',
    professorName: map['professorName'] ?? '',
    isLab: map['isLab'] ?? false,
    isLunch: map['isLunch'] ?? (map['subject']?.toString().toLowerCase().contains('lunch') ?? false),
    isCancelled: map['isCancelled'] ?? false,
    colorValue: map['colorValue'] ?? 0xFF6366F1,
  );
}

class Assignment {
  final String id;
  final String title;
  final String subject;
  final String description;
  final DateTime dueDate;
  final String priority; // 'HIGH', 'MEDIUM', 'LOW'
  final String status; // 'Pending', 'In Progress', 'Completed'

  Assignment({
    required this.id,
    required this.title,
    required this.subject,
    this.description = '',
    required this.dueDate,
    this.priority = 'HIGH',
    this.status = 'In Progress',
  });

  bool get isCompleted => status == 'Completed';

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'subject': subject,
    'description': description,
    'dueDate': dueDate.toIso8601String(),
    'priority': priority,
    'status': status,
  };

  factory Assignment.fromMap(Map<String, dynamic> map) => Assignment(
    id: map['id'] ?? '',
    title: map['title'] ?? '',
    subject: map['subject'] ?? '',
    description: map['description'] ?? '',
    dueDate: DateTime.tryParse(map['dueDate'] ?? '') ?? DateTime.now().add(const Duration(days: 2)),
    priority: map['priority'] ?? 'HIGH',
    status: map['status'] ?? 'In Progress',
  );
}

class ExamEntry {
  final String id;
  final String subject;
  final DateTime examDate;
  final String examTime;
  final String location;
  final String notes;
  final String priority;
  final List<String> syllabusUnits; // e.g. 5 units
  final List<int> completedUnits; // completed unit indices (0 to 4)

  ExamEntry({
    required this.id,
    required this.subject,
    required this.examDate,
    this.examTime = '10:00 AM',
    this.location = '',
    this.notes = '',
    this.priority = 'HIGH',
    this.syllabusUnits = const [
      'Unit 1: Fundamentals & Basics',
      'Unit 2: Core Concepts & Models',
      'Unit 3: Implementation & Practice',
      'Unit 4: Advanced Principles',
      'Unit 5: Applications & Case Studies',
    ],
    this.completedUnits = const [0, 1],
  });

  int get daysRemaining {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(examDate.year, examDate.month, examDate.day);
    return target.difference(today).inDays;
  }

  double get preparationPercentage => syllabusUnits.isEmpty
      ? 0.0
      : (completedUnits.length / syllabusUnits.length) * 100.0;

  Map<String, dynamic> toMap() => {
    'id': id,
    'subject': subject,
    'examDate': examDate.toIso8601String(),
    'examTime': examTime,
    'location': location,
    'notes': notes,
    'priority': priority,
    'syllabusUnits': syllabusUnits,
    'completedUnits': completedUnits,
  };

  factory ExamEntry.fromMap(Map<String, dynamic> map) => ExamEntry(
    id: map['id'] ?? '',
    subject: map['subject'] ?? '',
    examDate: DateTime.tryParse(map['examDate'] ?? '') ?? DateTime.now().add(const Duration(days: 30)),
    examTime: map['examTime'] ?? '10:00 AM',
    location: map['location'] ?? '',
    notes: map['notes'] ?? '',
    priority: map['priority'] ?? 'HIGH',
    syllabusUnits: List<String>.from(map['syllabusUnits'] ?? [
      'Unit 1: Fundamentals & Basics',
      'Unit 2: Core Concepts & Models',
      'Unit 3: Implementation & Practice',
      'Unit 4: Advanced Principles',
      'Unit 5: Applications & Case Studies',
    ]),
    completedUnits: List<int>.from(map['completedUnits'] ?? [0, 1]),
  );
}

class CampusExpense {
  final String id;
  final String title;
  final double amount;
  final String category; // 'Canteen', 'Xerox & Prints', 'Travel & Metro', 'Stationery', 'Hostel & Mess'
  final DateTime timestamp;

  CampusExpense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'amount': amount,
    'category': category,
    'timestamp': timestamp.toIso8601String(),
  };

  factory CampusExpense.fromMap(Map<String, dynamic> map) => CampusExpense(
    id: map['id'] ?? '',
    title: map['title'] ?? '',
    amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
    category: map['category'] ?? 'Canteen',
    timestamp: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
  );
}

class ChecklistItem {
  final String id;
  final String title;
  final String category;
  bool isCompleted;
  final String priority;
  final DateTime? dueDate;

  ChecklistItem({
    required this.id,
    required this.title,
    this.category = 'General',
    this.isCompleted = false,
    this.priority = 'NORMAL',
    this.dueDate,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'category': category,
    'isCompleted': isCompleted,
    'priority': priority,
    'dueDate': dueDate?.toIso8601String(),
  };

  factory ChecklistItem.fromMap(Map<String, dynamic> map) => ChecklistItem(
    id: map['id'] ?? '',
    title: map['title'] ?? '',
    category: map['category'] ?? 'General',
    isCompleted: map['isCompleted'] ?? false,
    priority: map['priority'] ?? 'NORMAL',
    dueDate: map['dueDate'] != null ? DateTime.tryParse(map['dueDate']) : null,
  );
}

class NoteItem {
  final String id;
  final String title;
  final String subject;
  final String content;
  final List<String> tags;
  final bool isPinned;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;

  NoteItem({
    required this.id,
    required this.title,
    this.subject = 'General',
    required this.content,
    this.tags = const [],
    this.isPinned = false,
    this.isFavorite = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'subject': subject,
    'content': content,
    'tags': tags,
    'isPinned': isPinned,
    'isFavorite': isFavorite,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory NoteItem.fromMap(Map<String, dynamic> map) => NoteItem(
    id: map['id'] ?? '',
    title: map['title'] ?? '',
    subject: map['subject'] ?? 'General',
    content: map['content'] ?? '',
    tags: List<String>.from(map['tags'] ?? []),
    isPinned: map['isPinned'] ?? false,
    isFavorite: map['isFavorite'] ?? false,
    createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    updatedAt: DateTime.tryParse(map['updatedAt'] ?? '') ?? DateTime.now(),
  );
}

class StudySessionLog {
  final String id;
  final DateTime timestamp;
  final int durationMinutes;
  final String sessionType; // 'Pomodoro', 'Custom'
  final String subject;

  StudySessionLog({
    required this.id,
    required this.timestamp,
    required this.durationMinutes,
    this.sessionType = 'Pomodoro',
    this.subject = 'General Study',
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'timestamp': timestamp.toIso8601String(),
    'durationMinutes': durationMinutes,
    'sessionType': sessionType,
    'subject': subject,
  };

  factory StudySessionLog.fromMap(Map<String, dynamic> map) => StudySessionLog(
    id: map['id'] ?? '',
    timestamp: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
    durationMinutes: map['durationMinutes'] ?? 25,
    sessionType: map['sessionType'] ?? 'Pomodoro',
    subject: map['subject'] ?? 'General Study',
  );
}
