import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../config/app_colors.dart';
import '../../config/app_dimensions.dart';
import '../../config/app_strings.dart';
import '../../providers/app_provider.dart';
import '../../models/chart_data.dart';

/// Chart period options
enum ChartPeriod { days14, days30, days90, months, years }

/// Charts tab screen
class ChartsTab extends StatefulWidget {
  const ChartsTab({super.key});

  @override
  State<ChartsTab> createState() => _ChartsTabState();
}

class _ChartsTabState extends State<ChartsTab> {
  ChartPeriod _selectedPeriod = ChartPeriod.days14;
  List<DailyChartData> _dailyData = [];
  List<MonthlyChartData> _monthlyData = [];
  List<YearlyChartData> _yearlyData = [];
  OverallStatistics? _statistics;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final provider = context.read<AppProvider>();

    try {
      _statistics = await provider.getOverallStatistics();

      switch (_selectedPeriod) {
        case ChartPeriod.days14:
          _dailyData = await provider.getDailyHappinessData(14);
          break;
        case ChartPeriod.days30:
          _dailyData = await provider.getDailyHappinessData(30);
          break;
        case ChartPeriod.days90:
          _dailyData = await provider.getDailyHappinessData(90);
          break;
        case ChartPeriod.months:
          _monthlyData = await provider.getMonthlyHappinessData(12);
          break;
        case ChartPeriod.years:
          _yearlyData = await provider.getYearlyHappinessData();
          break;
      }
    } catch (e) {
      debugPrint('Error loading chart data: $e');
    }

    setState(() => _isLoading = false);
  }

  void _changePeriod(ChartPeriod period) {
    if (_selectedPeriod != period) {
      setState(() => _selectedPeriod = period);
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            // Header with title and period selector
            _buildHeader(provider),

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(AppDimensions.paddingM),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildChart(),
                            const SizedBox(height: 24),
                            _buildStatistics(),
                            const SizedBox(height: 24),
                            _buildDataManagement(),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(AppProvider provider) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Title row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.insert_chart_rounded,
                  color: AppColors.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.chartsTitle,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: AppDimensions.fontXL,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      AppStrings.happinessTrend,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: AppDimensions.fontS,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.paddingM),

          // Period selector
          _buildPeriodSelector(),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _buildPeriodButton(ChartPeriod.days14, '14 Days'),
          _buildPeriodButton(ChartPeriod.days30, '30 Days'),
          _buildPeriodButton(ChartPeriod.days90, '90 Days'),
          _buildPeriodButton(ChartPeriod.months, 'Months'),
          _buildPeriodButton(ChartPeriod.years, 'Years'),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(ChartPeriod period, String label) {
    final isSelected = _selectedPeriod == period;

    return Expanded(
      child: GestureDetector(
        onTap: () => _changePeriod(period),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: AppDimensions.fontS,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChart() {
    final hasData = _hasChartData();

    return Container(
      height: 340,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.paddingM,
        AppDimensions.paddingXL,
        AppDimensions.paddingL,
        AppDimensions.paddingM,
      ),
      child: hasData ? _buildLineChart() : _buildNoDataMessage(),
    );
  }

  bool _hasChartData() {
    switch (_selectedPeriod) {
      case ChartPeriod.days14:
      case ChartPeriod.days30:
      case ChartPeriod.days90:
        return _dailyData.any((d) => d.avgHappiness != null);
      case ChartPeriod.months:
        return _monthlyData.any((d) => d.avgHappiness != null);
      case ChartPeriod.years:
        return _yearlyData.any((d) => d.avgHappiness != null);
    }
  }

  Widget _buildNoDataMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.insert_chart_outlined,
            size: 64,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.noChartData,
            style: TextStyle(
              fontSize: AppDimensions.fontL,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.startTracking,
            style: TextStyle(
              fontSize: AppDimensions.fontM,
              color: AppColors.textSecondary.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart() {
    final spots = _getChartSpots();
    final labels = _getChartLabels();

    if (spots.isEmpty) return _buildNoDataMessage();

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 10,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 2,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.textSecondary.withOpacity(0.1),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 35,
              interval: 2,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    value.toInt().toString(),
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: AppDimensions.fontS,
                    ),
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: _getBottomInterval(),
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < labels.length) {
                  // For 90 days, only show if it's a Monday (label is not empty)
                  if (_selectedPeriod == ChartPeriod.days90 &&
                      labels[index].isEmpty) {
                    return const SizedBox();
                  }

                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      labels[index],
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: AppDimensions.fontXS,
                        height: 1.1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.3,
            color: AppColors.primaryColor,
            barWidth: _selectedPeriod == ChartPeriod.days90 ? 2 : 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: _selectedPeriod == ChartPeriod.days90 ? 3 : 4,
                  color: Colors.white,
                  strokeWidth: 2,
                  strokeColor: AppColors.primaryColor,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primaryColor.withOpacity(0.3),
                  AppColors.primaryColor.withOpacity(0.0),
                ],
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (LineBarSpot touchedSpot) =>
                AppColors.cardBackground,
            tooltipBorderRadius: BorderRadius.circular(8),
            tooltipBorder: BorderSide(color: AppColors.cardBorder),
            tooltipPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              return touchedSpots.map((LineBarSpot touchedSpot) {
                final index = touchedSpot.x.toInt();
                String dateLabel = '';

                // Get proper date label for tooltip
                if (_selectedPeriod == ChartPeriod.days90 &&
                    index >= 0 &&
                    index < _dailyData.length) {
                  final d = _dailyData[index].date;
                  dateLabel =
                      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}\n';
                } else if (index >= 0 && index < _getChartLabels().length) {
                  final labels = _getChartLabels();
                  if (labels[index].isNotEmpty) {
                    dateLabel = '${labels[index]}\n';
                  }
                }

                return LineTooltipItem(
                  '$dateLabel${touchedSpot.y.toStringAsFixed(1)}',
                  TextStyle(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  List<FlSpot> _getChartSpots() {
    switch (_selectedPeriod) {
      case ChartPeriod.days14:
      case ChartPeriod.days30:
      case ChartPeriod.days90:
        return _dailyData
            .asMap()
            .entries
            .where((e) => e.value.avgHappiness != null)
            .map((e) => FlSpot(e.key.toDouble(), e.value.avgHappiness!))
            .toList();
      case ChartPeriod.months:
        return _monthlyData
            .asMap()
            .entries
            .where((e) => e.value.avgHappiness != null)
            .map((e) => FlSpot(e.key.toDouble(), e.value.avgHappiness!))
            .toList();
      case ChartPeriod.years:
        return _yearlyData
            .asMap()
            .entries
            .where((e) => e.value.avgHappiness != null)
            .map((e) => FlSpot(e.key.toDouble(), e.value.avgHappiness!))
            .toList();
    }
  }

  List<String> _getChartLabels() {
    switch (_selectedPeriod) {
      case ChartPeriod.days14:
      case ChartPeriod.days30:
        // Format: dd.mm
        return _dailyData
            .map(
              (d) =>
                  '${d.date.day.toString().padLeft(2, '0')}.${d.date.month.toString().padLeft(2, '0')}',
            )
            .toList();
      case ChartPeriod.days90:
        // Show date every 7 days
        return _dailyData.asMap().entries.map((entry) {
          final index = entry.key;
          final d = entry.value.date;
          if (index % 7 == 0) {
            return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}';
          }
          return ''; // Empty for other days
        }).toList();
      case ChartPeriod.months:
        return _monthlyData
            .map((d) => AppStrings.monthsShort[d.month - 1])
            .toList();
      case ChartPeriod.years:
        return _yearlyData.map((d) => d.year.toString()).toList();
    }
  }

  double _getBottomInterval() {
    switch (_selectedPeriod) {
      case ChartPeriod.days14:
        return 2;
      case ChartPeriod.days30:
        return 5;
      case ChartPeriod.days90:
        return 7; // Show every 7 days (weekly)
      case ChartPeriod.months:
        return 2;
      case ChartPeriod.years:
        return 1;
    }
  }

  Widget _buildStatistics() {
    if (_statistics == null) return const SizedBox();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.statistics,
            style: TextStyle(
              fontSize: AppDimensions.fontXL,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.sentiment_satisfied_alt,
                  label: AppStrings.overallAverage,
                  value: _statistics!.overallAvg?.toStringAsFixed(1) ?? '-',
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.calendar_today,
                  label: AppStrings.totalEntries,
                  value: _statistics!.totalEntries.toString(),
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.local_offer,
                  label: AppStrings.tagsTitle,
                  value: _statistics!.tagCount.toString(),
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.event,
                  label: AppStrings.eventsTitle,
                  value: _statistics!.eventCount.toString(),
                  color: AppColors.primaryLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: AppDimensions.fontXXL,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: AppDimensions.fontS,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDataManagement() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.dataManagement,
            style: TextStyle(
              fontSize: AppDimensions.fontXL,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.file_upload_outlined,
                  label: AppStrings.exportData,
                  onTap: _exportData,
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.file_download_outlined,
                  label: AppStrings.importData,
                  onTap: _importData,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: AppDimensions.fontM,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _exportData() async {
    final provider = context.read<AppProvider>();
    final success = await provider.exportData(context);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? AppStrings.exportSuccess : AppStrings.exportError,
          ),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  Future<void> _importData() async {
    final provider = context.read<AppProvider>();
    final result = await provider.importData();

    if (mounted) {
      if (result != null) {
        final message =
            '${AppStrings.importSuccess}\n'
            '${result['happiness_entries']} entries, '
            '${result['tags']} tags, '
            '${result['events']} events';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 3),
          ),
        );

        // Reload chart data
        _loadData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.importError),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
