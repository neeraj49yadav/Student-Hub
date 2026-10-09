import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';

class UnitConverterScreen extends StatefulWidget {
  final bool isPro;
  const UnitConverterScreen({super.key, required this.isPro});

  @override
  State<UnitConverterScreen> createState() => _UnitConverterScreenState();
}

class _UnitConverterScreenState extends State<UnitConverterScreen> {
  String _selectedCategory = 'Length';
  final _inputController = TextEditingController(text: '1');
  late String _fromUnit;
  late String _toUnit;

  // Category definitions & standard conversion multipliers (base unit)
  final Map<String, Map<String, double>> _conversionRates = {
    'Length': {
      'Millimeter (mm)': 0.001,
      'Centimeter (cm)': 0.01,
      'Meter (m)': 1.0, // Base
      'Kilometer (km)': 1000.0,
      'Inch (in)': 0.0254,
      'Foot (ft)': 0.3048,
      'Yard (yd)': 0.9144,
      'Mile (mi)': 1609.34,
    },
    'Weight': {
      'Milligram (mg)': 0.000001,
      'Gram (g)': 0.001,
      'Kilogram (kg)': 1.0, // Base
      'Pound (lb)': 0.453592,
      'Ounce (oz)': 0.0283495,
    },
    'Area': {
      'Square Meter (m²)': 1.0, // Base
      'Square Kilometer (km²)': 1000000.0,
      'Square Foot (ft²)': 0.092903,
      'Acre': 4046.86,
      'Hectare': 10000.0,
    },
    'Volume': {
      'Milliliter (ml)': 0.001,
      'Liter (L)': 1.0, // Base
      'Gallon (US)': 3.78541,
      'Cubic Meter (m³)': 1000.0,
    },
    'Time': {
      'Second (s)': 1.0, // Base
      'Minute (min)': 60.0,
      'Hour (hr)': 3600.0,
      'Day': 86400.0,
      'Week': 604800.0,
    },
    'Data': {
      'Bit (b)': 0.125,
      'Byte (B)': 1.0, // Base
      'Kilobyte (KB)': 1024.0,
      'Megabyte (MB)': 1048576.0,
      'Gigabyte (GB)': 1073741824.0,
      'Terabyte (TB)': 1099511627776.0,
    },
    'Speed': {
      'Meter/second (m/s)': 1.0, // Base
      'Kilometer/hour (km/h)': 0.277778,
      'Miles/hour (mph)': 0.44704,
    },
  };

  @override
  void initState() {
    super.initState();
    _resetUnitsForCategory('Length');
  }

  void _resetUnitsForCategory(String cat) {
    _selectedCategory = cat;
    if (cat == 'Temperature') {
      _fromUnit = 'Celsius (°C)';
      _toUnit = 'Fahrenheit (°F)';
    } else {
      final units = _conversionRates[cat]!.keys.toList();
      _fromUnit = units[0];
      _toUnit = units[1];
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  double _convert() {
    final val = double.tryParse(_inputController.text) ?? 0.0;

    if (_selectedCategory == 'Temperature') {
      if (_fromUnit == _toUnit) return val;
      // Convert to Celsius first
      double cVal;
      if (_fromUnit.startsWith('Celsius')) {
        cVal = val;
      } else if (_fromUnit.startsWith('Fahrenheit')) {
        cVal = (val - 32) * 5 / 9;
      } else {
        cVal = val - 273.15;
      }

      // Convert Celsius to target
      if (_toUnit.startsWith('Celsius')) return cVal;
      if (_toUnit.startsWith('Fahrenheit')) return (cVal * 9 / 5) + 32;
      return cVal + 273.15;
    }

    final rates = _conversionRates[_selectedCategory]!;
    final fromRate = rates[_fromUnit] ?? 1.0;
    final toRate = rates[_toUnit] ?? 1.0;

    // Convert from -> Base -> to
    final inBase = val * fromRate;
    return inBase / toRate;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final result = _convert();
    final categories = ['Length', 'Weight', 'Temperature', 'Area', 'Volume', 'Time', 'Data', 'Speed'];
    final unitList = _selectedCategory == 'Temperature'
        ? ['Celsius (°C)', 'Fahrenheit (°F)', 'Kelvin (K)']
        : _conversionRates[_selectedCategory]!.keys.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Unit Converter 📐')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Category Chips Carousel
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : (isDark ? AppColors.darkText : AppColors.lightText),
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (val) {
                        if (val) {
                          setState(() => _resetUnitsForCategory(cat));
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Conversion Output Display Card
            CustomCard(
              gradient: const LinearGradient(
                colors: [Color(0xFF06B6D4), Color(0xFF3B82F6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              child: Column(
                children: [
                  Text(
                    '${_inputController.text.isEmpty ? "0" : _inputController.text} $_fromUnit =',
                    style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    result.abs() < 0.0001 && result != 0
                        ? result.toStringAsExponential(4)
                        : (result % 1 == 0 ? result.toInt().toString() : result.toStringAsFixed(4)),
                    style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w900, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  Text(_toUnit, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Input Value
            CustomCard(
              child: TextField(
                controller: _inputController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Enter Value',
                  prefixIcon: Icon(Icons.numbers),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(height: 16),

            // Unit Selection with Swap Button
            Row(
              children: [
                Expanded(
                  child: CustomCard(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('From', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                        DropdownButton<String>(
                          value: unitList.contains(_fromUnit) ? _fromUnit : unitList.first,
                          isExpanded: true,
                          underline: const SizedBox.shrink(),
                          items: unitList.map((u) => DropdownMenuItem(value: u, child: Text(u, style: const TextStyle(fontSize: 13)))).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _fromUnit = val);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: IconButton.filled(
                    style: IconButton.styleFrom(backgroundColor: AppColors.primary),
                    icon: const Icon(Icons.swap_horiz, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        final temp = _fromUnit;
                        _fromUnit = _toUnit;
                        _toUnit = temp;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: CustomCard(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('To', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                        DropdownButton<String>(
                          value: unitList.contains(_toUnit) ? _toUnit : unitList.last,
                          isExpanded: true,
                          underline: const SizedBox.shrink(),
                          items: unitList.map((u) => DropdownMenuItem(value: u, child: Text(u, style: const TextStyle(fontSize: 13)))).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _toUnit = val);
                          },
                        ),
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
