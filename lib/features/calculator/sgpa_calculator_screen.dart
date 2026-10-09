import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/services/storage_service.dart';
import '../../shared/models/app_models.dart';
import 'package:uuid/uuid.dart';

class SgpaCalculatorScreen extends StatefulWidget {
  final StorageService storage;
  const SgpaCalculatorScreen({super.key, required this.storage});

  @override
  State<SgpaCalculatorScreen> createState() => _SgpaCalculatorScreenState();
}

class SubjectInputRow {
  final TextEditingController nameController;
  final TextEditingController creditController;
  String grade;
  double gradePoint;

  SubjectInputRow({
    required String name,
    required double credits,
    this.grade = 'A',
    this.gradePoint = 8.0,
  })  : nameController = TextEditingController(text: name),
        creditController = TextEditingController(text: credits.toString());

  void dispose() {
    nameController.dispose();
    creditController.dispose();
  }
}

class _SgpaCalculatorScreenState extends State<SgpaCalculatorScreen> {
  final List<SubjectInputRow> _rows = [];
  final _semesterNameController = TextEditingController(text: 'Semester 1');
  String _gradingScale = '10-Point (UGC/AICTE)';

  final Map<String, double> _scale10Map = {
    'O (10)': 10.0,
    'A+ (9)': 9.0,
    'A (8)': 8.0,
    'B+ (7)': 7.0,
    'B (6)': 6.0,
    'C (5)': 5.0,
    'P (4)': 4.0,
    'F (0)': 0.0,
  };

  final Map<String, double> _scaleAnnaUniv = {
    'O (10)': 10.0,
    'A+ (9)': 9.0,
    'A (8)': 8.0,
    'B+ (7)': 7.0,
    'B (6)': 6.0,
    'C (5)': 5.0,
    'RA (0)': 0.0,
  };

  final Map<String, double> _scaleMumbaiUniv = {
    'O (10)': 10.0,
    'A (9)': 9.0,
    'B (8)': 8.0,
    'C (7)': 7.0,
    'D (6)': 6.0,
    'E (5)': 5.0,
    'P (4)': 4.0,
    'F (0)': 0.0,
  };

  final Map<String, double> _scale4Map = {
    'A (4.0)': 4.0,
    'A- (3.7)': 3.7,
    'B+ (3.3)': 3.3,
    'B (3.0)': 3.0,
    'B- (2.7)': 2.7,
    'C+ (2.3)': 2.3,
    'C (2.0)': 2.0,
    'F (0.0)': 0.0,
  };

  @override
  void initState() {
    super.initState();
    _rows.add(SubjectInputRow(name: 'DBMS', credits: 4, grade: 'A (8)', gradePoint: 8.0));
    _rows.add(SubjectInputRow(name: 'Java', credits: 3, grade: 'A+ (9)', gradePoint: 9.0));
    _rows.add(SubjectInputRow(name: 'Operating Systems', credits: 4, grade: 'B+ (7)', gradePoint: 7.0));
    _rows.add(SubjectInputRow(name: 'Mathematics', credits: 3, grade: 'A (8)', gradePoint: 8.0));
  }

  @override
  void dispose() {
    for (var r in _rows) {
      r.dispose();
    }
    _semesterNameController.dispose();
    super.dispose();
  }

  double _calculateSgpa() {
    double totalWeighted = 0;
    double totalCredits = 0;
    for (var r in _rows) {
      final cred = double.tryParse(r.creditController.text) ?? 0;
      totalWeighted += cred * r.gradePoint;
      totalCredits += cred;
    }
    return totalCredits == 0 ? 0.0 : totalWeighted / totalCredits;
  }

  double _calculateTotalCredits() {
    double totalCredits = 0;
    for (var r in _rows) {
      totalCredits += double.tryParse(r.creditController.text) ?? 0;
    }
    return totalCredits;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sgpa = _calculateSgpa();
    final totalCredits = _calculateTotalCredits();
    Map<String, double> activeMap;
    if (_gradingScale.contains('Anna')) {
      activeMap = _scaleAnnaUniv;
    } else if (_gradingScale.contains('Mumbai')) {
      activeMap = _scaleMumbaiUniv;
    } else if (_gradingScale.contains('4-Point')) {
      activeMap = _scale4Map;
    } else {
      activeMap = _scale10Map;
    }
    final gradeOptions = activeMap.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('SGPA Calculator 🧮'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset',
            onPressed: () {
              setState(() {
                _rows.clear();
                _rows.add(SubjectInputRow(name: 'Subject 1', credits: 3));
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Result
            CustomCard(
              color: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.1),
              border: Border.all(color: AppColors.primary, width: 1.5),
              child: Column(
                children: [
                  const Text('CALCULATED SGPA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.2)),
                  const SizedBox(height: 4),
                  Text(
                    sgpa.toStringAsFixed(2),
                    style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: AppColors.primary),
                  ),
                  Text(
                    'Total Credits: ${totalCredits.toStringAsFixed(1)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Grading System Selector
            CustomCard(
              child: Row(
                children: [
                  Icon(Icons.tune, color: AppColors.primary),
                  const SizedBox(width: 12),
                  const Text('Grading Scale:', style: TextStyle(fontWeight: FontWeight.w600)),
                  const Spacer(),
                  DropdownButton<String>(
                    value: _gradingScale,
                    underline: const SizedBox.shrink(),
                    items: [
                      '10-Point (UGC/AICTE)',
                      'Anna Univ (10-Point)',
                      'Mumbai Univ (10-Point)',
                      '4-Point (US Standard)',
                    ].map((e) {
                      return DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13)));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _gradingScale = val;
                          Map<String, double> map;
                          if (val.contains('Anna')) {
                            map = _scaleAnnaUniv;
                          } else if (val.contains('Mumbai')) {
                            map = _scaleMumbaiUniv;
                          } else if (val.contains('4-Point')) {
                            map = _scale4Map;
                          } else {
                            map = _scale10Map;
                          }
                          for (var r in _rows) {
                            r.grade = map.keys.first;
                            r.gradePoint = map.values.first;
                          }
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Subject Rows
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subjects & Credits', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      final defaultGrade = gradeOptions.first;
                      final defaultGp = activeMap[defaultGrade]!;
                      _rows.add(SubjectInputRow(
                        name: 'Subject ${_rows.length + 1}',
                        credits: 3,
                        grade: defaultGrade,
                        gradePoint: defaultGp,
                      ));
                    });
                  },
                  icon: const Icon(Icons.add_circle_outline, size: 18),
                  label: const Text('Add Subject'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            ..._rows.asMap().entries.map((entry) {
              final idx = entry.key;
              final row = entry.value;

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: CustomCard(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: row.nameController,
                          decoration: const InputDecoration(
                            isDense: true,
                            hintText: 'Subject',
                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: row.creditController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            isDense: true,
                            hintText: 'Credits',
                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 3,
                        child: DropdownButtonFormField<String>(
                          initialValue: gradeOptions.contains(row.grade) ? row.grade : gradeOptions.first,
                          isDense: true,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          ),
                          items: gradeOptions.map((g) {
                            return DropdownMenuItem(value: g, child: Text(g, style: const TextStyle(fontSize: 12)));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                row.grade = val;
                                row.gradePoint = activeMap[val]!;
                              });
                            }
                          },
                        ),
                      ),
                      if (_rows.length > 1)
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: AppColors.error, size: 20),
                          onPressed: () async {
                            final hasData = row.nameController.text.trim().isNotEmpty || row.creditController.text.trim().isNotEmpty;
                            if (hasData) {
                              final confirmed = await showConfirmDeleteDialog(
                                context,
                                title: 'Remove Subject Row?',
                                message: 'Are you sure you want to remove "${row.nameController.text.trim().isEmpty ? 'this row' : row.nameController.text.trim()}"?',
                                deleteLabel: 'Remove',
                              );
                              if (!confirmed) return;
                            }
                            setState(() {
                              row.dispose();
                              _rows.removeAt(idx);
                            });
                          },
                        ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _saveSemesterDialog(context, sgpa, totalCredits),
              icon: const Icon(Icons.bookmark_border),
              label: const Text('Save to Semester History'),
            ),

            const SizedBox(height: 16),
            GooglePlayCompliantAdBanner(isPro: widget.storage.isProUser),
          ],
        ),
      ),
    );
  }

  void _saveSemesterDialog(BuildContext context, double sgpa, double totalCredits) {
    if (!widget.storage.isProStudent && widget.storage.semesters.length >= widget.storage.maxSavedSemesters) {
      final isRemoveAds = widget.storage.currentPlan == UserPlan.removeAds;
      showFeatureLockedDialog(
        context,
        featureTitle: 'Unlimited Saved Semesters 📚',
        requiredPlanTitle: 'GOLD PLAN (₹89)',
        description: isRemoveAds
            ? 'You have reached the 4 saved semesters cap on your Silver Plan (₹39).\n\nUpgrade to Gold Plan (+₹50) to unlock unlimited semesters and multi-year CGPA tracking!'
            : 'You have reached the 2 saved semesters limit on the Free tier.\n\nUpgrade to Gold Plan (₹89) or Silver Plan (₹39 - capped at 4 semesters) to save more semesters!',
        storage: widget.storage,
        planPrice: '₹89',
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Save Semester Record'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _semesterNameController,
              decoration: const InputDecoration(labelText: 'Semester Name (e.g., Semester 1)'),
            ),
            const SizedBox(height: 12),
            Text('Calculated SGPA: ${sgpa.toStringAsFixed(2)} | Credits: ${totalCredits.toStringAsFixed(1)}'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final subjects = _rows.map((r) {
                return Subject(
                  id: const Uuid().v4(),
                  name: r.nameController.text.trim().isEmpty ? 'Subject' : r.nameController.text.trim(),
                  credits: double.tryParse(r.creditController.text) ?? 3.0,
                  grade: r.grade,
                  gradePoint: r.gradePoint,
                );
              }).toList();

              final semester = Semester(
                id: const Uuid().v4(),
                name: _semesterNameController.text.trim(),
                subjects: subjects,
                sgpa: sgpa,
                totalCredits: totalCredits,
              );

              widget.storage.saveSemester(semester);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Saved "${semester.name}" with SGPA ${sgpa.toStringAsFixed(2)}!')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
