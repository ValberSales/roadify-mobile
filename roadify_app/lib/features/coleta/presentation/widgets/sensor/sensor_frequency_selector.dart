import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../core/theme/theme_extensions.dart';

class SensorFrequencySelector extends StatefulWidget {
  final String keyPrefix;
  final int minimum;
  final int maximum;
  final String title;
  final String unit;
  final List<int> presets;
  final int? currentValue;
  final TextEditingController customController;
  final ValueChanged<int> onChanged;
  final String? Function(String?) validator;
  final String inputHint;
  final String inputHelper;
  final IconData inputIcon;

  const SensorFrequencySelector({
    super.key,
    required this.keyPrefix,
    required this.minimum,
    required this.maximum,
    required this.title,
    required this.unit,
    required this.presets,
    required this.currentValue,
    required this.customController,
    required this.onChanged,
    required this.validator,
    required this.inputHint,
    required this.inputHelper,
    required this.inputIcon,
  });

  @override
  State<SensorFrequencySelector> createState() =>
      _SensorFrequencySelectorState();
}

class _SensorFrequencySelectorState extends State<SensorFrequencySelector> {
  late bool _isCustom;

  @override
  void initState() {
    super.initState();
    _checkCustomState();
  }

  @override
  void didUpdateWidget(covariant SensorFrequencySelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentValue != oldWidget.currentValue) {
      _checkCustomState();
    }
  }

  void _checkCustomState() {
    _isCustom =
        widget.currentValue != null &&
        !widget.presets.contains(widget.currentValue);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final displayValue = widget.currentValue?.toString() ?? '?';

    return Padding(
      padding: const EdgeInsets.only(left: 32, top: AppDimensions.space8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  style: typography.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.primary,
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.space8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$displayValue ${widget.unit}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: colors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...widget.presets.map((hz) {
                final isSelected = !_isCustom && widget.currentValue == hz;
                return ChoiceChip(
                  key: ValueKey('chip-${widget.keyPrefix}-$hz'),
                  showCheckmark: false,
                  label: SizedBox(
                    width: 58,
                    child: Center(child: Text('$hz ${widget.unit}')),
                  ),
                  selected: isSelected,
                  selectedColor: colors.primary,
                  labelStyle: TextStyle(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? colors.onPrimary : colors.onSurface,
                  ),
                  onSelected: (_) {
                    setState(() => _isCustom = false);
                    widget.customController.clear();
                    widget.onChanged(hz);
                  },
                );
              }),
              ChoiceChip(
                key: ValueKey('chip-${widget.keyPrefix}-outro'),
                showCheckmark: false,
                avatar: const Icon(Icons.tune_rounded, size: 14),
                label: const Text('Outro...'),
                selected: _isCustom,
                selectedColor: colors.primary,
                labelStyle: TextStyle(
                  fontWeight: _isCustom ? FontWeight.w700 : FontWeight.w500,
                  color: _isCustom ? colors.onPrimary : colors.onSurface,
                ),
                onSelected: (_) {
                  setState(() {
                    _isCustom = true;
                    if (widget.currentValue != null &&
                        widget.customController.text.isEmpty) {
                      widget.customController.text = widget.currentValue
                          .toString();
                    }
                  });
                },
              ),
            ],
          ),
          if (_isCustom) ...[
            const SizedBox(height: AppDimensions.space12),
            TextFormField(
              key: ValueKey('input-${widget.keyPrefix}-custom'),
              controller: widget.customController,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: 'Digitar frequência customizada',
                hintText: widget.inputHint,
                suffixText: widget.unit,
                prefixIcon: Icon(widget.inputIcon, size: 20),
                helperText:
                    '${widget.inputHelper} (${widget.minimum}–${widget.maximum} ${widget.unit})',
                isDense: true,
              ),
              validator: widget.validator,
              onChanged: (val) {
                final parsed = int.tryParse(val.trim());
                if (parsed != null && parsed > 0) widget.onChanged(parsed);
              },
            ),
          ],
        ],
      ),
    );
  }
}
