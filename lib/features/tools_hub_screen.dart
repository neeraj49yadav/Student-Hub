import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/common_widgets.dart';
import '../core/services/storage_service.dart';
import 'calculator/cgpa_calculator_screen.dart';
import 'calculator/sgpa_calculator_screen.dart';
import 'calculator/attendance_calculator_screen.dart';
import 'calculator/percentage_calculator_screen.dart';
import 'calculator/age_calculator_screen.dart';
import 'calculator/exam_passing_calculator_screen.dart';
import 'converter/unit_converter_screen.dart';
import 'converter/number_system_converter_screen.dart';
import 'expenses/campus_expense_screen.dart';

class ToolItemDef {
  final String key;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String category; // 'Academics', 'Attendance', 'Converters', 'Daily'
  final Widget Function(StorageService) screenBuilder;

  ToolItemDef({
    required this.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.category,
    required this.screenBuilder,
  });
}

class ToolsHubScreen extends StatefulWidget {
  final StorageService storage;
  const ToolsHubScreen({super.key, required this.storage});

  static List<ToolItemDef> get allTools => [
    ToolItemDef(
      key: 'cgpa',
      title: 'CGPA Calculator',
      subtitle: 'Multi-semester tracking & target CGPA forecasting',
      icon: Icons.school,
      color: const Color(0xFF4F46E5),
      category: 'Academics',
      screenBuilder: (s) => CgpaCalculatorScreen(storage: s),
    ),
    ToolItemDef(
      key: 'sgpa',
      title: 'SGPA Calculator',
      subtitle: 'Weighted university course credits & grade points',
      icon: Icons.calculate,
      color: const Color(0xFF7C3AED),
      category: 'Academics',
      screenBuilder: (s) => SgpaCalculatorScreen(storage: s),
    ),
    ToolItemDef(
      key: 'attendance',
      title: 'Attendance Calculator & Bunk Planner',
      subtitle: 'Can I skip? Classes needed & Fest bunk simulator',
      icon: Icons.co_present,
      color: const Color(0xFF10B981),
      category: 'Attendance',
      screenBuilder: (s) => AttendanceCalculatorScreen(storage: s),
    ),
    ToolItemDef(
      key: 'passing',
      title: 'Passing Marks Solver',
      subtitle: 'Solve minimum externals needed to avoid backlogs',
      icon: Icons.track_changes,
      color: const Color(0xFF0EA5E9),
      category: 'Academics',
      screenBuilder: (s) => ExamPassingCalculatorScreen(isPro: s.isProUser),
    ),
    ToolItemDef(
      key: 'percentage',
      title: 'Percentage Calculator',
      subtitle: 'Subject breakdown, target marks & CGPA conversion',
      icon: Icons.percent,
      color: const Color(0xFFF59E0B),
      category: 'Academics',
      screenBuilder: (s) => PercentageCalculatorScreen(isPro: s.isProUser),
    ),
    ToolItemDef(
      key: 'expenses',
      title: 'Campus Pocket Expenses',
      subtitle: '1-tap tracking for Chai, Xerox, Metro, Canteen & Mess',
      icon: Icons.account_balance_wallet,
      color: const Color(0xFF0D9488),
      category: 'Daily',
      screenBuilder: (s) => CampusExpenseScreen(storage: s),
    ),
    ToolItemDef(
      key: 'unit',
      title: 'Multi-Unit Converter',
      subtitle: '8 academic categories: Length, Weight, Data, Speed...',
      icon: Icons.straighten,
      color: const Color(0xFF3B82F6),
      category: 'Converters',
      screenBuilder: (s) => UnitConverterScreen(isPro: s.isProUser),
    ),
    ToolItemDef(
      key: 'number',
      title: 'CS Number-System Converter',
      subtitle: 'Live sync between Binary, Octal, Decimal & Hex',
      icon: Icons.memory,
      color: const Color(0xFF4F46E5),
      category: 'Converters',
      screenBuilder: (s) => NumberSystemConverterScreen(isPro: s.isProUser),
    ),
    ToolItemDef(
      key: 'age',
      title: 'Age & Life Calculator',
      subtitle: 'Exact years, months, total days lived & birthday countdown',
      icon: Icons.cake,
      color: const Color(0xFFF43F5E),
      category: 'Daily',
      screenBuilder: (s) => AgeCalculatorScreen(isPro: s.isProUser),
    ),
  ];

  @override
  State<ToolsHubScreen> createState() => _ToolsHubScreenState();
}

class _ToolsHubScreenState extends State<ToolsHubScreen> {
  String _selectedCategory = 'All';
  String _searchFilter = '';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final favKeys = widget.storage.favorites;
    final all = ToolsHubScreen.allTools;

    final categories = ['All', 'Favorites', 'Academics', 'Attendance', 'Converters', 'Daily'];

    final filtered = all.where((t) {
      if (_selectedCategory == 'Favorites' && !favKeys.contains(t.key)) return false;
      if (_selectedCategory != 'All' && _selectedCategory != 'Favorites' && t.category != _selectedCategory) return false;
      if (_searchFilter.isNotEmpty) {
        final query = _searchFilter.toLowerCase();
        return t.title.toLowerCase().contains(query) || t.subtitle.toLowerCase().contains(query);
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Tools & Utilities 🧮'),
      ),
      body: Column(
        children: [
          // Quick Search & Filter Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search tools (e.g. attendance, cgpa, binary)...',
                prefixIcon: const Icon(Icons.search, size: 20),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                suffixIcon: _searchFilter.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => setState(() => _searchFilter = ''),
                      )
                    : null,
              ),
              onChanged: (val) => setState(() => _searchFilter = val.trim()),
            ),
          ),

          // Interactive Horizontal Category Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(
                      cat == 'Favorites' ? '⭐ $cat' : cat,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.white70 : Colors.black87),
                      ),
                    ),
                    selectedColor: AppColors.primary,
                    checkmarkColor: Colors.white,
                    backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFEEF2F6),
                    onSelected: (_) => setState(() => _selectedCategory = cat),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 6),

          // Tools List View
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                if (filtered.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(40),
                    child: Center(
                      child: Column(
                        children: [
                          const Icon(Icons.search_off, size: 48, color: Colors.grey),
                          const SizedBox(height: 12),
                          Text(
                            'No utilities match "$_searchFilter"',
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...filtered.map((t) => _buildToolCard(context, t, isDark, favKeys.contains(t.key))),

                const SizedBox(height: 16),
                // Google Play Console Compliant Ad Placement at Bottom
                GooglePlayCompliantAdBanner(
                  isPro: widget.storage.isProUser,
                  format: GooglePlayAdFormat.nativeCard,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolCard(BuildContext context, ToolItemDef tool, bool isDark, bool isFav) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: CustomCard(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => tool.screenBuilder(widget.storage)));
        },
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: tool.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(tool.icon, color: tool.color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          tool.title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: tool.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          tool.category,
                          style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: tool.color),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    tool.subtitle,
                    style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                isFav ? Icons.star_rounded : Icons.star_outline_rounded,
                color: isFav ? Colors.amber : Colors.grey,
                size: 24,
              ),
              tooltip: isFav ? 'Remove from favorites' : 'Add to favorites',
              onPressed: () => widget.storage.toggleFavorite(tool.key),
            ),
          ],
        ),
      ),
    );
  }
}
