import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';

class AgeCalculatorScreen extends StatefulWidget {
  final bool isPro;
  const AgeCalculatorScreen({super.key, required this.isPro});

  @override
  State<AgeCalculatorScreen> createState() => _AgeCalculatorScreenState();
}

class _AgeCalculatorScreenState extends State<AgeCalculatorScreen> {
  DateTime _dob = DateTime(2003, 5, 20);
  DateTime _targetDate = DateTime.now();

  String _getZodiac(int month, int day) {
    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) return 'Aries ♈';
    if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) return 'Taurus ♉';
    if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) return 'Gemini ♊';
    if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) return 'Cancer ♋';
    if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) return 'Leo ♌';
    if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) return 'Virgo ♍';
    if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) return 'Libra ♎';
    if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) return 'Scorpio ♏';
    if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) return 'Sagittarius ♐';
    if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) return 'Capricorn ♑';
    if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) return 'Aquarius ♒';
    return 'Pisces ♓';
  }

  Map<String, int> _calculateDetailedAge(DateTime birth, DateTime target) {
    int years = target.year - birth.year;
    int months = target.month - birth.month;
    int days = target.day - birth.day;

    if (days < 0) {
      final prevMonthDays = DateTime(target.year, target.month, 0).day;
      days += prevMonthDays;
      months -= 1;
    }
    if (months < 0) {
      years -= 1;
      months += 12;
    }

    return {'years': years, 'months': months, 'days': days};
  }

  int _calculateNextBirthdayDays(DateTime birth) {
    final now = DateTime.now();
    DateTime next = DateTime(now.year, birth.month, birth.day);
    if (next.isBefore(DateTime(now.year, now.month, now.day))) {
      next = DateTime(now.year + 1, birth.month, birth.day);
    }
    return next.difference(DateTime(now.year, now.month, now.day)).inDays;
  }

  @override
  Widget build(BuildContext context) {
    final age = _calculateDetailedAge(_dob, _targetDate);
    final daysToBirthday = _calculateNextBirthdayDays(_dob);
    final totalDays = _targetDate.difference(_dob).inDays;
    final zodiac = _getZodiac(_dob.month, _dob.day);

    return Scaffold(
      appBar: AppBar(title: const Text('Age Calculator 🎂')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Main Age Card
            CustomCard(
              gradient: const LinearGradient(
                colors: [Color(0xFF0EA5E9), Color(0xFF6366F1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              child: Column(
                children: [
                  const Text('YOUR AGE', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  const SizedBox(height: 8),
                  Text(
                    '${age['years']} Years',
                    style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                  Text(
                    '${age['months']} Months | ${age['days']} Days',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Zodiac: $zodiac',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Pickers
            CustomCard(
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.cake, color: AppColors.accent),
                    title: const Text('Date of Birth'),
                    subtitle: Text(DateFormat('dd MMMM yyyy').format(_dob)),
                    trailing: Icon(Icons.calendar_month, color: AppColors.primary),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _dob,
                        firstDate: DateTime(1970),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) setState(() => _dob = picked);
                    },
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.event, color: AppColors.secondary),
                    title: const Text('Age as of Date'),
                    subtitle: Text(DateFormat('dd MMMM yyyy').format(_targetDate)),
                    trailing: Icon(Icons.calendar_month, color: AppColors.primary),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _targetDate,
                        firstDate: _dob,
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) setState(() => _targetDate = picked);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Statistics Grid
            Row(
              children: [
                Expanded(
                  child: CustomCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.celebration, color: AppColors.warning, size: 24),
                        const SizedBox(height: 8),
                        const Text('Next Birthday', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 2),
                        Text('$daysToBirthday Days', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.hourglass_top, color: AppColors.primary, size: 24),
                        const SizedBox(height: 8),
                        const Text('Days Lived', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 2),
                        Text('$totalDays Days', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CustomCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.date_range, color: AppColors.success, size: 24),
                        const SizedBox(height: 8),
                        const Text('Total Weeks', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 2),
                        Text('${(totalDays / 7).floor()} Weeks', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.schedule, color: AppColors.secondary, size: 24),
                        const SizedBox(height: 8),
                        const Text('Total Hours', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 2),
                        Text('${totalDays * 24} Hours', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            GooglePlayCompliantAdBanner(isPro: widget.isPro),
          ],
        ),
      ),
    );
  }
}
