import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/services/storage_service.dart';
import '../../shared/models/app_models.dart';
import 'package:uuid/uuid.dart';

class TimetableScreen extends StatefulWidget {
  final StorageService storage;
  const TimetableScreen({super.key, required this.storage});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  static const List<String> _allDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static const List<String> _dayShortNames = [
    'MON',
    'TUE',
    'WED',
    'THU',
    'FRI',
    'SAT',
    'SUN',
  ];

  static const List<String> _defaultPeriodTimes = [
    '09:00 - 10:00',
    '10:00 - 11:00',
    '11:15 - 12:15',
    '12:15 - 01:15',
    '02:00 - 03:00',
    '03:00 - 04:00',
    '04:00 - 05:00',
    '05:00 - 06:00',
    '06:00 - 07:00',
    '07:00 - 08:00',
  ];

  late int _rowCount;
  late int _colCount;

  @override
  void initState() {
    super.initState();
    _rowCount = widget.storage.timetableRowCount;
    _colCount = widget.storage.timetableColumnCount;
    if (_rowCount < 3 || _rowCount > 10) _rowCount = 6;
    if (_colCount < 3 || _colCount > 7) _colCount = 6;
  }

  List<String> get _activeDays => _allDays.take(_colCount).toList();

  TimetableSlot? _getSlotAt(String day, String periodNumber) {
    final slots = widget.storage.timetableSlots;
    try {
      return slots.firstWhere(
        (s) => s.dayOfWeek.toLowerCase() == day.toLowerCase() && s.periodNumber == periodNumber,
      );
    } catch (_) {
      // Fallback: search by day and approximate index if periodNumber matches format
      try {
        return slots.firstWhere(
          (s) => s.dayOfWeek.toLowerCase() == day.toLowerCase() && s.periodNumber.contains(periodNumber),
        );
      } catch (_) {
        return null;
      }
    }
  }

  void _showGridConfigDialog() {
    int tempRows = _rowCount;
    int tempCols = _colCount;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.grid_on_rounded, color: AppColors.primary),
                const SizedBox(width: 10),
                const Text('Timetable Grid Size ⚙️'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Configure how many days (columns) and lecture periods (rows) you want in your master grid.',
                    style: TextStyle(fontSize: 12.5, color: Colors.grey),
                  ),
                  const SizedBox(height: 18),

                  // Column count (Days)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Columns (Days):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$tempCols Days (${_allDays[0].substring(0, 3)} - ${_allDays[tempCols - 1].substring(0, 3)})',
                          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: tempCols.toDouble(),
                    min: 3,
                    max: 7,
                    divisions: 4,
                    label: '$tempCols Days',
                    onChanged: (val) {
                      setDialogState(() => tempCols = val.toInt());
                    },
                  ),
                  const SizedBox(height: 12),

                  // Row count (Periods)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Rows (Periods / Day):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$tempRows Periods / Day',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary),
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: tempRows.toDouble(),
                    min: 3,
                    max: 10,
                    divisions: 7,
                    label: '$tempRows Periods',
                    onChanged: (val) {
                      setDialogState(() => tempRows = val.toInt());
                    },
                  ),
                  const SizedBox(height: 10),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.amber, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Grid will display $tempRows Periods × $tempCols Days (${tempRows * tempCols} editable lecture slots).',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _rowCount = tempRows;
                    _colCount = tempCols;
                  });
                  widget.storage.updateTimetableGridDimensions(_rowCount, _colCount);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Timetable updated to $_rowCount Rows × $_colCount Columns! 📅'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                child: const Text('Apply Grid Size'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditCellDialog(String day, int periodIndex, TimetableSlot? existingSlot) {
    HapticFeedback.lightImpact();
    final periodName = 'Period ${periodIndex + 1}';
    final defaultTimes = periodIndex < _defaultPeriodTimes.length
        ? _defaultPeriodTimes[periodIndex].split(' - ')
        : ['09:00', '10:00'];

    final subjectCtrl = TextEditingController(text: existingSlot?.subject ?? '');
    final roomCtrl = TextEditingController(text: existingSlot?.room ?? '');
    final profCtrl = TextEditingController(text: existingSlot?.professorName ?? '');
    final startCtrl = TextEditingController(text: existingSlot?.startTime ?? defaultTimes[0]);
    final endCtrl = TextEditingController(text: existingSlot?.endTime ?? defaultTimes[1]);

    bool isLunch = existingSlot?.isLunch ?? false;
    bool isCancelled = existingSlot?.isCancelled ?? false;
    int selectedColor = existingSlot?.colorValue ?? 0xFF6366F1;

    final colorOptions = [
      0xFF6366F1, // Indigo
      0xFF06B6D4, // Cyan
      0xFF10B981, // Emerald
      0xFFF59E0B, // Amber
      0xFFEC4899, // Pink
      0xFF8B5CF6, // Purple
      0xFF0D9488, // Teal
    ];

    final quickSubjects = ['DBMS', 'OS', 'Java', 'DSA', 'Lunch', 'Web Tech', 'Networks', 'Maths'];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    existingSlot == null ? 'Add Class: $day ($periodName)' : 'Edit Class: $day ($periodName)',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    day.substring(0, 3).toUpperCase(),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.primary),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: subjectCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Subject Name *',
                      hintText: 'e.g. Database Systems',
                      prefixIcon: Icon(Icons.menu_book),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Quick Subject chips
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: quickSubjects.map((sub) {
                      return ActionChip(
                        label: Text(sub, style: const TextStyle(fontSize: 11)),
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          setDialogState(() {
                            subjectCtrl.text = sub;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: roomCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Room / Lab',
                            hintText: 'e.g. Lab 4 / R201',
                            prefixIcon: Icon(Icons.room),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: profCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Faculty / Prof.',
                            hintText: 'e.g. Prof. Kumar',
                            prefixIcon: Icon(Icons.person),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: startCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Start Time',
                            hintText: '09:00',
                            prefixIcon: Icon(Icons.access_time),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: endCtrl,
                          decoration: const InputDecoration(
                            labelText: 'End Time',
                            hintText: '10:00',
                            prefixIcon: Icon(Icons.access_time_filled),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Toggles
                  SwitchListTile(
                    title: const Text('🍱 Lunch Break', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    value: isLunch,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    onChanged: (val) => setDialogState(() {
                      isLunch = val;
                      if (val && (subjectCtrl.text.trim().isEmpty || subjectCtrl.text.trim() == 'Subject')) {
                        subjectCtrl.text = 'Lunch Break';
                      }
                    }),
                  ),
                  SwitchListTile(
                    title: const Text('🚫 Cancelled Today (Mass Bunk / Leave)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    value: isCancelled,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    onChanged: (val) => setDialogState(() => isCancelled = val),
                  ),
                  const SizedBox(height: 10),

                  // Color Picker
                  const Text('Slot Accent Color:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: colorOptions.map((c) {
                      final isSelected = selectedColor == c;
                      return GestureDetector(
                        onTap: () => setDialogState(() => selectedColor = c),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Color(c),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? Colors.white : Colors.transparent,
                              width: 2.5,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: Color(c).withValues(alpha: 0.6),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                : null,
                          ),
                          child: isSelected ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            actions: [
              if (existingSlot != null)
                TextButton(
                  style: TextButton.styleFrom(foregroundColor: AppColors.error),
                  onPressed: () async {
                    final confirmed = await showConfirmDeleteDialog(
                      context,
                      title: 'Clear Timetable Slot?',
                      message: 'Are you sure you want to clear ${existingSlot.subject} ($day, $periodName)? This cannot be undone.',
                      deleteLabel: 'Clear Slot',
                    );
                    if (confirmed) {
                      widget.storage.clearSlotAt(day, periodName);
                      if (context.mounted) {
                        Navigator.pop(ctx);
                      }
                    }
                  },
                  child: const Text('Clear Slot'),
                ),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  String subText = subjectCtrl.text.trim();
                  if (subText.isEmpty) {
                    if (isLunch) {
                      subText = 'Lunch Break';
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter a subject name')),
                      );
                      return;
                    }
                  }

                  final newSlot = TimetableSlot(
                    id: existingSlot?.id ?? const Uuid().v4(),
                    dayOfWeek: day,
                    periodNumber: periodName,
                    subject: subText,
                    room: roomCtrl.text.trim(),
                    professorName: profCtrl.text.trim(),
                    startTime: startCtrl.text.trim().isNotEmpty ? startCtrl.text.trim() : defaultTimes[0],
                    endTime: endCtrl.text.trim().isNotEmpty ? endCtrl.text.trim() : defaultTimes[1],
                    isLunch: isLunch,
                    isCancelled: isCancelled,
                    colorValue: isLunch && selectedColor == 0xFF6366F1 ? 0xFFF59E0B : selectedColor,
                  );

                  widget.storage.saveOrUpdateTimetableSlot(newSlot);
                  Navigator.pop(ctx);
                },
                child: const Text('Save Slot'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final todayWeekday = DateFormat('EEEE').format(DateTime.now());

    const double periodColWidth = 84.0;
    const double dayColWidth = 120.0;
    const double rowHeight = 92.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Timetable Grid 📅'),
        actions: [
          IconButton(
            icon: const Icon(Icons.grid_view_rounded),
            tooltip: 'Configure Grid Size (Rows & Columns)',
            onPressed: _showGridConfigDialog,
          ),
        ],
      ),
      body: Column(
        children: [

          // Master 2D Scrollable Timetable Grid
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row: [Period / Time] + Days of Week
                    Row(
                      children: [
                        // Corner Box
                        Container(
                          width: periodColWidth,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'PERIOD',
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.8),
                          ),
                        ),
                        const SizedBox(width: 6),

                        // Day Columns Headers
                        ...List.generate(_colCount, (colIdx) {
                          final day = _activeDays[colIdx];
                          final isToday = day.toLowerCase() == todayWeekday.toLowerCase();

                          return Container(
                            width: dayColWidth,
                            height: 44,
                            margin: const EdgeInsets.only(right: 6),
                            decoration: BoxDecoration(
                              color: isToday
                                  ? AppColors.primary
                                  : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isToday
                                    ? Colors.white
                                    : (isDark ? Colors.white12 : Colors.black12),
                                width: isToday ? 1.5 : 1.0,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _dayShortNames[colIdx],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 13,
                                    color: isToday ? Colors.white : (isDark ? Colors.white : Colors.black87),
                                  ),
                                ),
                                if (isToday)
                                  const Text(
                                    'TODAY',
                                    style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white70),
                                  ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Grid Body: Rows (Periods) × Columns (Days)
                    ...List.generate(_rowCount, (rowIdx) {
                      final periodNumber = 'Period ${rowIdx + 1}';
                      final defaultTime = rowIdx < _defaultPeriodTimes.length
                          ? _defaultPeriodTimes[rowIdx]
                          : 'Slot ${rowIdx + 1}';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            // Left Period Label Column
                            Container(
                              width: periodColWidth,
                              height: rowHeight,
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF131D31) : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'P${rowIdx + 1}',
                                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.primary),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    defaultTime.split(' - ').first,
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    defaultTime.split(' - ').length > 1 ? defaultTime.split(' - ').last : '',
                                    style: TextStyle(fontSize: 9.5, color: isDark ? Colors.white54 : Colors.black54),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),

                            // Cells across Days
                            ...List.generate(_colCount, (colIdx) {
                              final day = _activeDays[colIdx];
                              final slot = _getSlotAt(day, periodNumber);

                              return _buildGridCell(
                                context,
                                day: day,
                                periodIndex: rowIdx,
                                slot: slot,
                                width: dayColWidth,
                                height: rowHeight,
                                isDark: isDark,
                              );
                            }),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),

          // Google Play Compliant Ad Placement at Bottom
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: GooglePlayCompliantAdBanner(
              isPro: widget.storage.isProUser,
              format: GooglePlayAdFormat.standardBanner,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridCell(
    BuildContext context, {
    required String day,
    required int periodIndex,
    required TimetableSlot? slot,
    required double width,
    required double height,
    required bool isDark,
  }) {
    if (slot == null) {
      // Empty / Free slot cell
      return GestureDetector(
        onTap: () => _showEditCellDialog(day, periodIndex, null),
        child: Container(
          width: width,
          height: height,
          margin: const EdgeInsets.only(right: 6),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.black12,
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_rounded,
                size: 20,
                color: isDark ? Colors.white24 : Colors.black26,
              ),
              const SizedBox(height: 2),
              Text(
                'Free Slot',
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? Colors.white38 : Colors.black38,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final color = Color(slot.colorValue);

    return GestureDetector(
      onTap: () => _showEditCellDialog(day, periodIndex, slot),
      child: Container(
        width: width,
        height: height,
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: slot.isCancelled
              ? (isDark ? Colors.grey.shade900 : Colors.grey.shade200)
              : color.withValues(alpha: isDark ? 0.22 : 0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: slot.isCancelled ? Colors.grey : color.withValues(alpha: 0.6),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (slot.isLunch)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('🍱 Lunch', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: Colors.amber)),
                  )
                else if (slot.isLab)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.cyan.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('🔬 Lab', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: Colors.cyan)),
                  )
                else
                  Text(
                    slot.startTime,
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black87),
                  ),
                if (slot.isCancelled)
                  const Text('🚫', style: TextStyle(fontSize: 10))
                else
                  Icon(Icons.edit_outlined, size: 12, color: color),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  slot.subject,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12.5,
                    decoration: slot.isCancelled ? TextDecoration.lineThrough : null,
                    color: slot.isCancelled ? Colors.grey : (isDark ? Colors.white : Colors.black),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (slot.room.isNotEmpty)
                  Text(
                    slot.room,
                    style: TextStyle(fontSize: 10, color: isDark ? Colors.white60 : Colors.black54),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
            if (slot.professorName.isNotEmpty)
              Text(
                slot.professorName,
                style: TextStyle(fontSize: 9, color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            else
              const SizedBox(height: 2),
          ],
        ),
      ),
    );
  }
}
