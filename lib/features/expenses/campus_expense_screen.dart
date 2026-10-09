import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/services/storage_service.dart';
import '../../shared/models/app_models.dart';
import 'package:uuid/uuid.dart';

class CampusExpenseScreen extends StatefulWidget {
  final StorageService storage;
  const CampusExpenseScreen({super.key, required this.storage});

  @override
  State<CampusExpenseScreen> createState() => _CampusExpenseScreenState();
}

class _CampusExpenseScreenState extends State<CampusExpenseScreen> {
  final List<String> _categories = [
    'All',
    'Canteen',
    'Xerox & Prints',
    'Travel & Metro',
    'Stationery',
    'Hostel & Mess',
  ];

  String _selectedCategory = 'All';

  IconData _getCategoryIcon(String cat) {
    switch (cat) {
      case 'Canteen':
        return Icons.fastfood_outlined;
      case 'Xerox & Prints':
        return Icons.print_outlined;
      case 'Travel & Metro':
        return Icons.directions_subway_outlined;
      case 'Stationery':
        return Icons.edit_outlined;
      case 'Hostel & Mess':
        return Icons.hotel_outlined;
      default:
        return Icons.account_balance_wallet_outlined;
    }
  }

  Color _getCategoryColor(String cat) {
    switch (cat) {
      case 'Canteen':
        return Colors.orange;
      case 'Xerox & Prints':
        return Colors.blue;
      case 'Travel & Metro':
        return Colors.green;
      case 'Stationery':
        return Colors.purple;
      case 'Hostel & Mess':
        return Colors.teal;
      default:
        return AppColors.primary;
    }
  }

  void _quickAddExpense(String title, double amount, String category) {
    HapticFeedback.lightImpact();
    final expense = CampusExpense(
      id: const Uuid().v4(),
      title: title,
      amount: amount,
      category: category,
      timestamp: DateTime.now(),
    );
    widget.storage.addExpense(expense);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ₹${amount.toInt()} for $title'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allExpenses = widget.storage.expenses;
    final todayTotal = widget.storage.getTodayExpenseTotal();
    final totalSpent = allExpenses.fold(0.0, (sum, e) => sum + e.amount);

    final filtered = _selectedCategory == 'All'
        ? allExpenses
        : allExpenses.where((e) => e.category == _selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Pocket Expense 💸'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Custom Expense',
            onPressed: () => _showAddExpenseDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Spending Summary Banner
          Padding(
            padding: const EdgeInsets.all(16),
            child: CustomCard(
              gradient: const LinearGradient(
                colors: [Color(0xFF0D9488), Color(0xFF14B8A6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "TODAY'S CAMPUS SPEND",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₹${todayTotal.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            "TOTAL LOGGED",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₹${totalSpent.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white24, height: 24),
                  Row(
                    children: [
                      const Icon(Icons.bolt, color: Colors.amberAccent, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        '${allExpenses.length} campus expenses tracked offline',
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Quick 1-Tap Add Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'QUICK 1-TAP LOG',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.1),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ActionChip(
                        avatar: const Icon(Icons.local_cafe, size: 16, color: Colors.orange),
                        label: const Text('☕ Chai ₹15'),
                        onPressed: () => _quickAddExpense('Canteen Chai', 15.0, 'Canteen'),
                      ),
                      const SizedBox(width: 8),
                      ActionChip(
                        avatar: const Icon(Icons.fastfood, size: 16, color: Colors.orange),
                        label: const Text('🥟 Samosa ₹20'),
                        onPressed: () => _quickAddExpense('Canteen Samosa', 20.0, 'Canteen'),
                      ),
                      const SizedBox(width: 8),
                      ActionChip(
                        avatar: const Icon(Icons.print, size: 16, color: Colors.blue),
                        label: const Text('📄 Xerox ₹20'),
                        onPressed: () => _quickAddExpense('Lab Notes Xerox', 20.0, 'Xerox & Prints'),
                      ),
                      const SizedBox(width: 8),
                      ActionChip(
                        avatar: const Icon(Icons.subway, size: 16, color: Colors.green),
                        label: const Text('🚇 Metro ₹40'),
                        onPressed: () => _quickAddExpense('College Metro Fare', 40.0, 'Travel & Metro'),
                      ),
                      const SizedBox(width: 8),
                      ActionChip(
                        avatar: const Icon(Icons.edit, size: 16, color: Colors.purple),
                        label: const Text('✏️ Pen/Notebook ₹30'),
                        onPressed: () => _quickAddExpense('Class Stationery', 30.0, 'Stationery'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Category Chips Filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(cat),
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : (isDark ? AppColors.darkText : AppColors.lightText),
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _selectedCategory = cat);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 16),

          // Expense List
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey),
                        SizedBox(height: 12),
                        Text('No expenses in this category.', style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('Tap 1-Tap chips above or + to add an expense.', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filtered.length,
                    itemBuilder: (context, idx) {
                      final exp = filtered[idx];
                      final catColor = _getCategoryColor(exp.category);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: CustomCard(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: catColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(_getCategoryIcon(exp.category), color: catColor, size: 22),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      exp.title,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: catColor.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            exp.category,
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: catColor,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          DateFormat('dd MMM, hh:mm a').format(exp.timestamp),
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '₹${exp.amount.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.teal,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 18),
                                onPressed: () async {
                                  HapticFeedback.lightImpact();
                                  final confirmed = await showConfirmDeleteDialog(
                                    context,
                                    title: 'Delete Expense?',
                                    message: 'Are you sure you want to delete "${exp.title}" (₹${exp.amount.toStringAsFixed(0)})? This cannot be undone.',
                                  );
                                  if (confirmed) {
                                    widget.storage.deleteExpense(exp.id);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GooglePlayCompliantAdBanner(
              isPro: widget.storage.isProUser,
              format: GooglePlayAdFormat.standardBanner,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddExpenseDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final amtCtrl = TextEditingController();
    String category = 'Canteen';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Campus Expense'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Expense Description (e.g. Canteen Lunch, Xerox)',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amtCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Amount (₹)',
                    prefixText: '₹ ',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: [
                    'Canteen',
                    'Xerox & Prints',
                    'Travel & Metro',
                    'Stationery',
                    'Hostel & Mess',
                  ].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => category = val);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final amt = double.tryParse(amtCtrl.text.trim()) ?? 0.0;
                if (titleCtrl.text.trim().isNotEmpty && amt > 0) {
                  final newExp = CampusExpense(
                    id: const Uuid().v4(),
                    title: titleCtrl.text.trim(),
                    amount: amt,
                    category: category,
                    timestamp: DateTime.now(),
                  );
                  widget.storage.addExpense(newExp);
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Save Expense'),
            ),
          ],
        ),
      ),
    );
  }
}
