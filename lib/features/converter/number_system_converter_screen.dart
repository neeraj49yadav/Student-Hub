import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';

class NumberSystemConverterScreen extends StatefulWidget {
  final bool isPro;
  const NumberSystemConverterScreen({super.key, required this.isPro});

  @override
  State<NumberSystemConverterScreen> createState() => _NumberSystemConverterScreenState();
}

class _NumberSystemConverterScreenState extends State<NumberSystemConverterScreen> {
  final _decController = TextEditingController(text: '255');
  final _binController = TextEditingController(text: '11111111');
  final _octController = TextEditingController(text: '377');
  final _hexController = TextEditingController(text: 'FF');

  String? _errorMsg;

  @override
  void dispose() {
    _decController.dispose();
    _binController.dispose();
    _octController.dispose();
    _hexController.dispose();
    super.dispose();
  }

  void _updateFromDecimal(String value) {
    if (value.trim().isEmpty) {
      _clearAllExcept('dec');
      return;
    }
    try {
      final num = BigInt.parse(value.trim(), radix: 10);
      _binController.text = num.toRadixString(2);
      _octController.text = num.toRadixString(8);
      _hexController.text = num.toRadixString(16).toUpperCase();
      setState(() => _errorMsg = null);
    } catch (_) {
      setState(() => _errorMsg = 'Invalid Decimal number');
    }
  }

  void _updateFromBinary(String value) {
    if (value.trim().isEmpty) {
      _clearAllExcept('bin');
      return;
    }
    try {
      final num = BigInt.parse(value.trim(), radix: 2);
      _decController.text = num.toRadixString(10);
      _octController.text = num.toRadixString(8);
      _hexController.text = num.toRadixString(16).toUpperCase();
      setState(() => _errorMsg = null);
    } catch (_) {
      setState(() => _errorMsg = 'Invalid Binary digits (only 0 and 1 allowed)');
    }
  }

  void _updateFromOctal(String value) {
    if (value.trim().isEmpty) {
      _clearAllExcept('oct');
      return;
    }
    try {
      final num = BigInt.parse(value.trim(), radix: 8);
      _decController.text = num.toRadixString(10);
      _binController.text = num.toRadixString(2);
      _hexController.text = num.toRadixString(16).toUpperCase();
      setState(() => _errorMsg = null);
    } catch (_) {
      setState(() => _errorMsg = 'Invalid Octal digits (0 to 7 allowed)');
    }
  }

  void _updateFromHex(String value) {
    if (value.trim().isEmpty) {
      _clearAllExcept('hex');
      return;
    }
    try {
      final num = BigInt.parse(value.trim(), radix: 16);
      _decController.text = num.toRadixString(10);
      _binController.text = num.toRadixString(2);
      _octController.text = num.toRadixString(8);
      setState(() => _errorMsg = null);
    } catch (_) {
      setState(() => _errorMsg = 'Invalid Hexadecimal characters (0-9, A-F)');
    }
  }

  void _clearAllExcept(String source) {
    setState(() {
      _errorMsg = null;
      if (source != 'dec') _decController.clear();
      if (source != 'bin') _binController.clear();
      if (source != 'oct') _octController.clear();
      if (source != 'hex') _hexController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Number System Converter 🔢')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_errorMsg != null)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.error),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_errorMsg!, style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold))),
                  ],
                ),
              ),

            _buildBaseCard('Decimal (Base 10)', _decController, _updateFromDecimal, Icons.pin_outlined, isDark),
            const SizedBox(height: 12),
            _buildBaseCard('Binary (Base 2)', _binController, _updateFromBinary, Icons.memory_outlined, isDark),
            const SizedBox(height: 12),
            _buildBaseCard('Octal (Base 8)', _octController, _updateFromOctal, Icons.filter_8_outlined, isDark),
            const SizedBox(height: 12),
            _buildBaseCard('Hexadecimal (Base 16)', _hexController, _updateFromHex, Icons.code_outlined, isDark),

            const SizedBox(height: 20),
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Quick Reference for CS Students', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text(
                    '• Binary (0-1): Machine instructions & logic gates.\n'
                    '• Octal (0-7): Linux file permissions (e.g., chmod 755).\n'
                    '• Decimal (0-9): Human counting standard.\n'
                    '• Hexadecimal (0-F): Memory addresses & web hex colors (#FF5733).',
                    style: TextStyle(fontSize: 12, height: 1.5, color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            GooglePlayCompliantAdBanner(isPro: widget.isPro),
          ],
        ),
      ),
    );
  }

  Widget _buildBaseCard(
    String label,
    TextEditingController controller,
    Function(String) onChanged,
    IconData icon,
    bool isDark,
  ) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: AppColors.primary, size: 18),
                  const SizedBox(width: 8),
                  Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.copy, size: 18, color: Colors.grey),
                tooltip: 'Copy',
                onPressed: () {
                  if (controller.text.isNotEmpty) {
                    Clipboard.setData(ClipboardData(text: controller.text));
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Copied ${controller.text}')));
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 16),
            decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12)),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
