import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/services/storage_service.dart';

class PomodoroScreen extends StatefulWidget {
  final StorageService storage;
  const PomodoroScreen({super.key, required this.storage});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  // Timer settings (in minutes)
  int _focusDuration = 25;

  int _secondsRemaining = 25 * 60;
  bool _isRunning = false;
  Timer? _timer;
  int _completedSessions = 0;
  final String _currentSubject = 'General Study';

  @override
  void initState() {
    super.initState();
    _secondsRemaining = _focusDuration * 60;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (_isRunning) return;
    HapticFeedback.lightImpact();
    setState(() => _isRunning = true);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _timer?.cancel();
        _isRunning = false;
        _handleSessionCompleted();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    HapticFeedback.lightImpact();
    setState(() => _isRunning = false);
  }

  void _resetTimer() {
    _timer?.cancel();
    HapticFeedback.lightImpact();
    setState(() {
      _isRunning = false;
      _secondsRemaining = _focusDuration * 60;
    });
  }

  void _handleSessionCompleted() {
    HapticFeedback.vibrate();
    _completedSessions++;
    widget.storage.logStudySession(_focusDuration, _currentSubject);
    widget.storage.recordStudyActivity();

    setState(() {
      _isRunning = false;
      _secondsRemaining = _focusDuration * 60;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🎉 Focus session of ${_focusDuration}m completed! Great job!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _applyDuration(int minutes) {
    HapticFeedback.lightImpact();
    _timer?.cancel();
    setState(() {
      _focusDuration = minutes;
      _isRunning = false;
      _secondsRemaining = minutes * 60;
    });
  }

  void _showCustomTimeDialog() {
    final controller = TextEditingController(text: _focusDuration.toString());

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          int currentVal = int.tryParse(controller.text) ?? _focusDuration;

          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.timer_outlined, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text('Set Custom Focus Time ⏱️'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Enter your custom study duration in minutes:',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      labelText: 'Duration (Minutes)',
                      suffixText: 'mins',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onChanged: (val) {
                      setDialogState(() {
                        currentVal = int.tryParse(val) ?? currentVal;
                      });
                    },
                  ),
                  const SizedBox(height: 14),
                  const Text('Quick Add Buttons:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [5, 10, 15, 30, 45, 60].map((addMins) {
                      return ActionChip(
                        label: Text('+$addMins min'),
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          final newVal = (int.tryParse(controller.text) ?? 0) + addMins;
                          controller.text = newVal.toString();
                          setDialogState(() {
                            currentVal = newVal;
                          });
                        },
                      );
                    }).toList(),
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
                  final entered = int.tryParse(controller.text.trim());
                  if (entered != null && entered > 0 && entered <= 360) {
                    _applyDuration(entered);
                    Navigator.pop(ctx);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter valid minutes between 1 and 360.')),
                    );
                  }
                },
                child: const Text('Set Timer'),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatTime(int totalSeconds) {
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  double _calculateProgress() {
    final total = _focusDuration * 60;
    if (total == 0) return 0;
    return 1.0 - (_secondsRemaining / total);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalFocusToday = widget.storage.getTodayFocusMinutes();
    final todayHours = totalFocusToday ~/ 60;
    final todayMins = totalFocusToday % 60;

    final modeColor = AppColors.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Focus Timer ⏱️'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Today's Focus Summary Card
            CustomCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.bolt, color: AppColors.warning),
                      const SizedBox(width: 8),
                      Text(
                        "Today's Focus: ${todayHours}h ${todayMins}m",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ],
                  ),
                  Text(
                    '$_completedSessions sessions done',
                    style: TextStyle(fontSize: 13, color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Main Circular Countdown Display (Tap digits to set custom time)
            GestureDetector(
              onTap: _showCustomTimeDialog,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 250,
                    height: 250,
                    child: CircularProgressIndicator(
                      value: _calculateProgress(),
                      strokeWidth: 10,
                      backgroundColor: isDark ? Colors.white10 : Colors.black12,
                      valueColor: AlwaysStoppedAnimation<Color>(modeColor),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(_secondsRemaining),
                        style: const TextStyle(fontSize: 54, fontWeight: FontWeight.w900, fontFamily: 'monospace'),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'FOCUS SESSION',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                          color: modeColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Tap to edit duration',
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Controls (Play / Pause / Reset / Skip)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.filledTonal(
                  iconSize: 28,
                  onPressed: _resetTimer,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Reset',
                ),
                const SizedBox(width: 24),
                IconButton.filled(
                  iconSize: 42,
                  style: IconButton.styleFrom(
                    backgroundColor: modeColor,
                    padding: const EdgeInsets.all(16),
                  ),
                  onPressed: _isRunning ? _pauseTimer : _startTimer,
                  icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow, color: Colors.white),
                  tooltip: _isRunning ? 'Pause' : 'Start Focus',
                ),
                const SizedBox(width: 24),
                IconButton.filledTonal(
                  iconSize: 28,
                  onPressed: _handleSessionCompleted,
                  icon: const Icon(Icons.check),
                  tooltip: 'Finish & Log Session',
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Strictly Google Play Compliant: No ads during active study timer sessions!
            if (!_isRunning)
              GooglePlayCompliantAdBanner(
                isPro: widget.storage.isProUser,
                format: GooglePlayAdFormat.standardBanner,
                customTag: 'Focus Sanctuary Sponsor • Safe Placement',
              ),
          ],
        ),
      ),
    );
  }
}
