import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_colors.dart';
import '../config/app_dimensions.dart';
import '../config/app_strings.dart';
import '../config/app_config.dart';
import '../providers/app_provider.dart';

/// Widget containing all three happiness sliders
class HappinessSliders extends StatelessWidget {
  const HappinessSliders({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final entry = provider.selectedDayEntry;
        
        return Container(
          padding: const EdgeInsets.all(AppDimensions.sliderCardPadding),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            border: Border.all(
              color: AppColors.cardBorder,
              width: AppDimensions.cardBorderWidth,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.mood,
                      color: AppColors.primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    AppStrings.happinessLevel,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: AppDimensions.fontL,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppDimensions.paddingL),
              
              // Morning slider
              _HappinessSliderItem(
                icon: AppStrings.sliderMorningIcon,
                label: AppStrings.morningHappiness,
                value: entry?.morningValue,
                onChanged: (value) {
                  provider.updateHappinessValue(
                    morning: value,
                    afternoon: entry?.afternoonValue,
                    evening: entry?.eveningValue,
                  );
                },
              ),
              
              const SizedBox(height: AppDimensions.sliderSpacing),
              
              // Afternoon slider
              _HappinessSliderItem(
                icon: AppStrings.sliderAfternoonIcon,
                label: AppStrings.afternoonHappiness,
                value: entry?.afternoonValue,
                onChanged: (value) {
                  provider.updateHappinessValue(
                    morning: entry?.morningValue,
                    afternoon: value,
                    evening: entry?.eveningValue,
                  );
                },
              ),
              
              const SizedBox(height: AppDimensions.sliderSpacing),
              
              // Evening slider
              _HappinessSliderItem(
                icon: AppStrings.sliderEveningIcon,
                label: AppStrings.eveningHappiness,
                value: entry?.eveningValue,
                onChanged: (value) {
                  provider.updateHappinessValue(
                    morning: entry?.morningValue,
                    afternoon: entry?.afternoonValue,
                    evening: value,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Individual happiness slider with label and value display
class _HappinessSliderItem extends StatefulWidget {
  final String icon;
  final String label;
  final double? value;
  final ValueChanged<double> onChanged;

  const _HappinessSliderItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  State<_HappinessSliderItem> createState() => _HappinessSliderItemState();
}

class _HappinessSliderItemState extends State<_HappinessSliderItem> {
  late double _currentValue;
  bool _hasInteracted = false;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value ?? AppConfig.happinessDefaultValue;
    _hasInteracted = widget.value != null;
  }

  @override
  void didUpdateWidget(_HappinessSliderItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _currentValue = widget.value ?? AppConfig.happinessDefaultValue;
      _hasInteracted = widget.value != null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final happinessColor = AppColors.getHappinessColor(_currentValue);
    final happinessColorDark = AppColors.getHappinessColorDark(_currentValue);
    
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: _hasInteracted 
            ? happinessColor.withOpacity(0.15) 
            : AppColors.backgroundTertiary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(
          color: _hasInteracted 
              ? happinessColor.withOpacity(0.3) 
              : AppColors.inputBorder,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label row with icon and value
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    widget.icon,
                    style: const TextStyle(
                      fontSize: AppDimensions.sliderIconSize,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.paddingS),
                  Text(
                    widget.label,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: AppDimensions.sliderLabelFontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              AnimatedContainer(
                duration: AppDimensions.animationFast,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingM,
                  vertical: AppDimensions.paddingXS,
                ),
                decoration: BoxDecoration(
                  color: _hasInteracted 
                      ? happinessColor 
                      : AppColors.backgroundTertiary,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  border: Border.all(
                    color: _hasInteracted 
                        ? happinessColor 
                        : AppColors.inputBorder,
                    width: 1,
                  ),
                ),
                child: Text(
                  _hasInteracted 
                      ? AppStrings.formatHappinessValue(_currentValue)
                      : '-',
                  style: TextStyle(
                    color: _hasInteracted ? happinessColorDark : AppColors.textTertiary,
                    fontSize: AppDimensions.sliderValueFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppDimensions.paddingM),
          
          // Slider
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: happinessColor,
              inactiveTrackColor: AppColors.sliderInactiveTrack,
              thumbColor: AppColors.sliderThumb,
              overlayColor: happinessColor.withOpacity(0.2),
              trackHeight: AppDimensions.sliderTrackHeight,
              thumbShape: _CustomThumbShape(
                thumbRadius: AppDimensions.sliderThumbRadius,
                borderColor: happinessColor,
              ),
              overlayShape: const RoundSliderOverlayShape(
                overlayRadius: AppDimensions.sliderOverlayRadius,
              ),
            ),
            child: Slider(
              value: _currentValue,
              min: AppConfig.happinessMinValue,
              max: AppConfig.happinessMaxValue,
              divisions: AppConfig.sliderDivisions,
              onChanged: (value) {
                setState(() {
                  _currentValue = value;
                  _hasInteracted = true;
                });
              },
              onChangeEnd: (value) {
                widget.onChanged(value);
              },
            ),
          ),
          
          // Min/Max labels with BIGGER emojis
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingS,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text(
                      '😢',
                      style: TextStyle(
                        fontSize: AppDimensions.sliderEmojiFontSize,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      AppConfig.happinessMinValue.toInt().toString(),
                      style: const TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: AppDimensions.fontS,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      AppConfig.happinessMaxValue.toInt().toString(),
                      style: const TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: AppDimensions.fontS,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      '😊',
                      style: TextStyle(
                        fontSize: AppDimensions.sliderEmojiFontSize,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom thumb shape with border
class _CustomThumbShape extends SliderComponentShape {
  final double thumbRadius;
  final Color borderColor;

  const _CustomThumbShape({
    required this.thumbRadius,
    required this.borderColor,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    // Draw shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(center + const Offset(0, 2), thumbRadius, shadowPaint);

    // Draw white fill
    final fillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, thumbRadius, fillPaint);

    // Draw colored border
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, thumbRadius - 1.5, borderPaint);
  }
}