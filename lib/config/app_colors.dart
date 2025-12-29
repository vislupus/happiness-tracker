import 'package:flutter/material.dart';

/// All application colors - Light Pastel Theme
/// Modify this file to change the entire app's color scheme
class AppColors {
  // Primary Theme Colors - Soft lavender/purple
  static const Color primaryColor = Color(0xFF7C6AEF);
  static const Color primaryLight = Color(0xFFA99BFF);
  static const Color primaryDark = Color(0xFF5B4BC9);
  
  // Background Colors - Soft creamy whites
  static const Color backgroundPrimary = Color(0xFFF8F7FC);
  static const Color backgroundSecondary = Color(0xFFFFFFFF);
  static const Color backgroundTertiary = Color(0xFFF0EEF6);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF2D2D3A);
  static const Color textSecondary = Color(0xFF6B6B80);
  static const Color textTertiary = Color(0xFF9999AD);
  static const Color textDisabled = Color(0xFFBDBDCF);
  
  // Calendar Colors
  static const Color calendarBackground = Color(0xFFFFFFFF);
  static const Color calendarHeaderBackground = Color(0xFFF5F3FF);
  static const Color calendarTodayBorder = Color(0xFF7C6AEF);
  static const Color calendarTodayBackground = Color(0xFFEDE9FF);
  static const Color calendarSelectedBackground = Color(0xFF7C6AEF);
  static const Color calendarSelectedText = Color(0xFFFFFFFF);
  static const Color calendarWeekdayText = Color(0xFF8888A0);
  static const Color calendarDayText = Color(0xFF2D2D3A);
  static const Color calendarOtherMonthText = Color(0xFFCCCCDD);
  
  // Happiness Level Colors (gradient from sad to happy) - Pastel version
  static const List<Color> happinessGradient = [
    Color(0xFFFFB5B5), // 1 - Very sad (soft red/pink)
    Color(0xFFFFCAAA), // 2 - (soft orange)
    Color(0xFFFFDFA6), // 3 - (soft amber)
    Color(0xFFFFEEA8), // 4 - (soft yellow-orange)
    Color(0xFFFFF9B0), // 5 - Neutral (soft yellow)
    Color(0xFFE8F5AA), // 6 - (soft lime)
    Color(0xFFCCEFB5), // 7 - (soft light green)
    Color(0xFFB5E8C0), // 8 - (soft green)
    Color(0xFFA3E4C1), // 9 - (soft mint)
    Color(0xFF8EDFC2), // 10 - Very happy (soft teal)
  ];
  
  // Event Colors - Light pastel + Darker pastel (all in one group)
  static const List<Color> eventColors = [
    // Row 1 - Light pastels
    Color(0xFFFFB3B3), // 0 - Light Coral
    Color(0xFFFFCC99), // 1 - Light Peach
    Color(0xFFFFE699), // 2 - Light Yellow
    Color(0xFFCCFF99), // 3 - Light Lime
    Color(0xFF99FFCC), // 4 - Light Mint
    Color(0xFF99FFFF), // 5 - Light Cyan
    Color(0xFF99CCFF), // 6 - Light Sky Blue
    Color(0xFFCC99FF), // 7 - Light Purple
    Color(0xFFFF99FF), // 8 - Light Magenta
    Color(0xFFFF99CC), // 9 - Light Pink
    
    // Row 2 - Medium pastels
    Color(0xFFFF8A8A), // 10 - Coral
    Color(0xFFFFB366), // 11 - Orange
    Color(0xFFFFD966), // 12 - Yellow
    Color(0xFFB8E986), // 13 - Lime
    Color(0xFF7ED3B2), // 14 - Mint
    Color(0xFF7EC8E3), // 15 - Sky Blue
    Color(0xFF8B9DC3), // 16 - Steel Blue
    Color(0xFFA388EE), // 17 - Purple
    Color(0xFFD88CEE), // 18 - Magenta
    Color(0xFFFF8EB8), // 19 - Pink
    
    // Row 3 - Darker pastels (still soft but more saturated)
    Color(0xFFE57373), // 20 - Dark Coral
    Color(0xFFFF8A65), // 21 - Dark Peach
    Color(0xFFFFD54F), // 22 - Dark Yellow
    Color(0xFF9CCC65), // 23 - Dark Lime
    Color(0xFF4DB6AC), // 24 - Dark Mint/Teal
    Color(0xFF4DD0E1), // 25 - Dark Cyan
    Color(0xFF64B5F6), // 26 - Dark Sky Blue
    Color(0xFF9575CD), // 27 - Dark Purple
    Color(0xFFBA68C8), // 28 - Dark Magenta
    Color(0xFFF06292), // 29 - Dark Pink
    
    // Row 4 - Deep pastels (rich but still pastel-like)
    Color(0xFFD32F2F), // 30 - Deep Red
    Color(0xFFE64A19), // 31 - Deep Orange
    Color(0xFFFBC02D), // 32 - Deep Yellow
    Color(0xFF689F38), // 33 - Deep Green
    Color(0xFF00897B), // 34 - Deep Teal
    Color(0xFF0097A7), // 35 - Deep Cyan
    Color(0xFF1976D2), // 36 - Deep Blue
    Color(0xFF7B1FA2), // 37 - Deep Purple
    Color(0xFFC2185B), // 38 - Deep Magenta
    Color(0xFF8D6E63), // 39 - Brown
  ];
  
  // Slider Colors
  static const Color sliderActiveTrack = Color(0xFF7C6AEF);
  static const Color sliderInactiveTrack = Color(0xFFE8E6F0);
  static const Color sliderThumb = Color(0xFFFFFFFF);
  static const Color sliderThumbBorder = Color(0xFF7C6AEF);
  static const Color sliderOverlay = Color(0x297C6AEF);
  
  // Tag Colors
  static const Color tagBackground = Color(0xFFF0EEF6);
  static const Color tagSelectedBackground = Color(0xFF7C6AEF);
  static const Color tagText = Color(0xFF4A4A5A);
  static const Color tagSelectedText = Color(0xFFFFFFFF);
  static const Color tagBorder = Color(0xFFDDDBE8);
  
  // Bottom Navigation
  static const Color navBarBackground = Color(0xFFFFFFFF);
  static const Color navBarSelectedItem = Color(0xFF7C6AEF);
  static const Color navBarUnselectedItem = Color(0xFFAAAAAA);
  static const Color navBarBorder = Color(0xFFEEEEF5);
  
  // Card Colors
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFEEECF5);
  
  // Divider
  static const Color divider = Color(0xFFEEECF5);
  
  // Icons
  static const Color iconPrimary = Color(0xFF4A4A5A);
  static const Color iconSecondary = Color(0xFF8888A0);
  
  // Shadows
  static const Color shadowColor = Color(0x0A000000);
  
  // Input fields
  static const Color inputBackground = Color(0xFFF5F4FA);
  static const Color inputBorder = Color(0xFFE0DEE8);
  static const Color inputFocusBorder = Color(0xFF7C6AEF);
  
  // Success, Warning, Error
  static const Color success = Color(0xFF6BCB8B);
  static const Color warning = Color(0xFFFFBE5C);
  static const Color error = Color(0xFFFF8A8A);

  /// Get happiness color based on value (1-10)
  static Color getHappinessColor(double value) {
    if (value <= 1) return happinessGradient[0];
    if (value >= 10) return happinessGradient[9];
    
    int index = ((value - 1) / 1).floor();
    double fraction = (value - 1) % 1;
    
    if (index >= 9) return happinessGradient[9];
    
    return Color.lerp(
      happinessGradient[index],
      happinessGradient[index + 1],
      fraction,
    )!;
  }
  
  /// Get darker version of happiness color for text/borders
  static Color getHappinessColorDark(double value) {
    final baseColor = getHappinessColor(value);
    return HSLColor.fromColor(baseColor)
        .withLightness(0.35)
        .withSaturation(0.6)
        .toColor();
  }
  
  /// Get event color by index
  static Color getEventColor(int index) {
    return eventColors[index % eventColors.length];
  }
  
  /// Check if event color needs light text (for darker colors)
  static bool needsLightText(int index) {
    // Deep pastels (row 4) need light text
    return index >= 30;
  }
}