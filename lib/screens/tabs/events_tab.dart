import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../config/app_dimensions.dart';
import '../../config/app_strings.dart';
import '../../providers/app_provider.dart';
import '../../models/event.dart';
import '../../models/event_day.dart';
import '../home_screen.dart';

/// Events management tab
class EventsTab extends StatefulWidget {
  const EventsTab({super.key});

  @override
  State<EventsTab> createState() => _EventsTabState();
}

class _EventsTabState extends State<EventsTab> {
  final TextEditingController _searchController = TextEditingController();
  List<Event> _filteredEvents = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _filterEvents();
  }

  Future<void> _filterEvents() async {
    final provider = context.read<AppProvider>();
    final query = _searchController.text;
    
    if (query.isEmpty) {
      setState(() {
        _filteredEvents = provider.allEvents;
        _isSearching = false;
      });
    } else {
      final results = await provider.searchEventsQuery(query);
      setState(() {
        _filteredEvents = results;
        _isSearching = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final events = _isSearching ? _filteredEvents : provider.allEvents;

        return Column(
          children: [
            // Header with search and sort
            _buildHeader(provider),
            
            // Events list
            Expanded(
              child: events.isEmpty
                  ? _buildEmptyState()
                  : _buildEventsList(provider, events),
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
                  Icons.event_rounded,
                  color: AppColors.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      AppStrings.allEvents,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: AppDimensions.fontXL,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${provider.allEvents.length} events',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: AppDimensions.fontS,
                      ),
                    ),
                  ],
                ),
              ),
              // Sort button
              PopupMenuButton<EventSortOption>(
                icon: const Icon(
                  Icons.sort_rounded,
                  color: AppColors.iconSecondary,
                ),
                onSelected: (option) => provider.setEventSortOption(option),
                itemBuilder: (context) => [
                  _buildSortMenuItem(
                    EventSortOption.date,
                    AppStrings.sortByDate,
                    Icons.calendar_today,
                    provider.eventSortOption,
                  ),
                  _buildSortMenuItem(
                    EventSortOption.happiness,
                    AppStrings.sortByHappiness,
                    Icons.mood,
                    provider.eventSortOption,
                  ),
                  _buildSortMenuItem(
                    EventSortOption.name,
                    AppStrings.sortByName,
                    Icons.sort_by_alpha,
                    provider.eventSortOption,
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: AppDimensions.paddingM),
          
          // Search field
          TextField(
            controller: _searchController,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: AppStrings.searchEvents,
              hintStyle: const TextStyle(color: AppColors.textTertiary),
              prefixIcon: const Icon(Icons.search, color: AppColors.iconSecondary),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: AppColors.iconSecondary),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppColors.inputBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingM,
                vertical: AppDimensions.paddingS,
              ),
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<EventSortOption> _buildSortMenuItem(
    EventSortOption option,
    String label,
    IconData icon,
    EventSortOption current,
  ) {
    final isSelected = option == current;
    return PopupMenuItem(
      value: option,
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isSelected ? AppColors.primaryColor : AppColors.iconSecondary,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.primaryColor : AppColors.textPrimary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          if (isSelected) ...[
            const Spacer(),
            const Icon(
              Icons.check,
              size: 18,
              color: AppColors.primaryColor,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.event_busy,
              size: 48,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingL),
          Text(
            _isSearching ? 'No events found' : AppStrings.noEventsYet,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: AppDimensions.fontL,
            ),
          ),
          if (!_isSearching) ...[
            const SizedBox(height: AppDimensions.paddingS),
            const Text(
              'Add events from the Calendar tab',
              style: TextStyle(
                color: AppColors.textTertiary,
                fontSize: AppDimensions.fontM,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEventsList(AppProvider provider, List<Event> events) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return _EventListItem(
          event: event,
          onTap: () => _showEventDetails(provider, event),
        );
      },
    );
  }

  void _showEventDetails(AppProvider provider, Event event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _EventDetailsSheet(
        event: event,
        onNavigateToDate: (date) {
          Navigator.pop(sheetContext);
          provider.navigateToDate(date);
          final homeState = context.findAncestorStateOfType<HomeScreenState>();
          homeState?.switchToCalendarTab();
        },
        onEdit: () {
          Navigator.pop(sheetContext);
          _showEditDialog(provider, event);
        },
        onDelete: () {
          Navigator.pop(sheetContext);
          _showDeleteDialog(provider, event);
        },
      ),
    );
  }

  void _showEditDialog(AppProvider provider, Event event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EventEditSheet(
        event: event,
        onSave: (title, startDate, endDate, colorIndex) async {
          await provider.updateEvent(event.copyWith(
            title: title,
            startDate: startDate,
            endDate: endDate,
            colorIndex: colorIndex,
          ));
        },
      ),
    );
  }

  void _showDeleteDialog(AppProvider provider, Event event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
        title: const Text(
          AppStrings.deleteEvent,
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          '${AppStrings.confirmDeleteEvent}\n\n"${event.title}"',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              provider.deleteEvent(event.id!);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }
}

/// Individual event list item
class _EventListItem extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;

  const _EventListItem({
    required this.event,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasHappinessData = event.averageHappiness != null;
    final eventColor = AppColors.getEventColor(event.colorIndex);
    final happinessColor = hasHappinessData
        ? AppColors.getHappinessColor(event.averageHappiness!)
        : AppColors.backgroundTertiary;

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingS),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(
          color: AppColors.cardBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            child: Row(
              children: [
                // Event color and happiness
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: happinessColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    border: Border.all(
                      color: eventColor,
                      width: 3,
                    ),
                  ),
                  child: Center(
                    child: hasHappinessData
                        ? Text(
                            event.averageHappiness!.toStringAsFixed(1),
                            style: TextStyle(
                              color: AppColors.getHappinessColorDark(event.averageHappiness!),
                              fontSize: AppDimensions.fontM,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: eventColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                  ),
                ),
                
                const SizedBox(width: AppDimensions.paddingM),
                
                // Event info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: AppDimensions.fontL,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.date_range,
                            size: 14,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${AppStrings.formatDate(event.startDate)} - ${AppStrings.formatDate(event.endDate)}',
                            style: const TextStyle(
                              color: AppColors.textTertiary,
                              fontSize: AppDimensions.fontS,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.backgroundTertiary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              AppStrings.formatDaysCount(event.durationInDays),
                              style: const TextStyle(
                                color: AppColors.textTertiary,
                                fontSize: AppDimensions.fontXS,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Arrow
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.iconSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Event details sheet with all days
class _EventDetailsSheet extends StatefulWidget {
  final Event event;
  final Function(DateTime) onNavigateToDate;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _EventDetailsSheet({
    required this.event,
    required this.onNavigateToDate,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_EventDetailsSheet> createState() => _EventDetailsSheetState();
}

class _EventDetailsSheetState extends State<_EventDetailsSheet> {
  List<EventDay> _eventDays = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEventDays();
  }

  Future<void> _loadEventDays() async {
    final provider = context.read<AppProvider>();
    final days = await provider.getEventDays(widget.event.id!);
    if (mounted) {
      setState(() {
        _eventDays = days;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasHappinessData = widget.event.averageHappiness != null;
    final eventColor = AppColors.getEventColor(widget.event.colorIndex);
    final happinessColor = hasHappinessData
        ? AppColors.getHappinessColor(widget.event.averageHappiness!)
        : AppColors.backgroundTertiary;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusXL),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            child: Column(
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppDimensions.paddingL),
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                // Event info card
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingM),
                  decoration: BoxDecoration(
                    color: eventColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                    border: Border.all(
                      color: eventColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Event color and happiness
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: happinessColor.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                          border: Border.all(color: eventColor, width: 3),
                        ),
                        child: Center(
                          child: hasHappinessData
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      widget.event.averageHappiness!.toStringAsFixed(1),
                                      style: TextStyle(
                                        color: AppColors.getHappinessColorDark(widget.event.averageHappiness!),
                                        fontSize: AppDimensions.fontXL,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'avg',
                                      style: TextStyle(
                                        color: AppColors.getHappinessColorDark(widget.event.averageHappiness!).withOpacity(0.7),
                                        fontSize: AppDimensions.fontXS,
                                      ),
                                    ),
                                  ],
                                )
                              : Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: eventColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                        ),
                      ),
                      
                      const SizedBox(width: AppDimensions.paddingM),
                      
                      // Event name and dates
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.event.title,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: AppDimensions.fontXL,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${AppStrings.formatDateShort(widget.event.startDate)} - ${AppStrings.formatDateShort(widget.event.endDate)}',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: AppDimensions.fontM,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Actions button
                      PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.more_vert,
                          color: AppColors.iconSecondary,
                        ),
                        onSelected: (value) {
                          switch (value) {
                            case 'edit':
                              widget.onEdit();
                              break;
                            case 'delete':
                              widget.onDelete();
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 20, color: AppColors.iconSecondary),
                                SizedBox(width: 12),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 20, color: AppColors.error),
                                SizedBox(width: 12),
                                Text('Delete', style: TextStyle(color: AppColors.error)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Section title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_month,
                  size: 18,
                  color: AppColors.iconSecondary,
                ),
                const SizedBox(width: 8),
                const Text(
                  AppStrings.daysInEvent,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: AppDimensions.fontM,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  AppStrings.formatDaysCount(widget.event.durationInDays),
                  style: const TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: AppDimensions.fontS,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppDimensions.paddingS),
          
          const Divider(height: 1, color: AppColors.divider),
          
          // Event days list
          Flexible(
            child: _isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppDimensions.paddingXL),
                      child: CircularProgressIndicator(
                        color: AppColors.primaryColor,
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(AppDimensions.paddingM),
                    itemCount: _eventDays.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final day = _eventDays[index];
                      return _EventDayItem(
                        day: day,
                        eventColor: AppColors.getEventColor(widget.event.colorIndex),
                        onTap: () => widget.onNavigateToDate(day.date),
                      );
                    },
                  ),
          ),
          
          SizedBox(height: MediaQuery.of(context).padding.bottom + AppDimensions.paddingM),
        ],
      ),
    );
  }
}

/// Individual event day item
class _EventDayItem extends StatelessWidget {
  final EventDay day;
  final Color eventColor;
  final VoidCallback onTap;

  const _EventDayItem({
    required this.day,
    required this.eventColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasHappinessData = day.hasHappinessData;
    final happinessColor = hasHappinessData && day.averageHappiness != null
        ? AppColors.getHappinessColor(day.averageHappiness!)
        : AppColors.backgroundTertiary;

    final dayName = AppStrings.weekdaysShort[day.date.weekday - 1];
    final dateStr = AppStrings.formatDateShort(day.date);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          decoration: BoxDecoration(
            color: happinessColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            border: Border.all(
              color: happinessColor.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Happiness indicator
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: happinessColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                ),
                child: Center(
                  child: hasHappinessData && day.averageHappiness != null
                      ? Text(
                          day.averageHappiness!.toStringAsFixed(1),
                          style: TextStyle(
                            color: AppColors.getHappinessColorDark(day.averageHappiness!),
                            fontSize: AppDimensions.fontL,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : const Icon(
                          Icons.remove,
                          color: AppColors.textTertiary,
                          size: 18,
                        ),
                ),
              ),
              
              const SizedBox(width: AppDimensions.paddingM),
              
              // Date info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateStr,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: AppDimensions.fontM,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dayName,
                      style: const TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: AppDimensions.fontS,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Happiness values
              if (hasHappinessData) ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _HappinessValueChip(icon: '🌅', value: day.morningValue),
                    const SizedBox(width: 4),
                    _HappinessValueChip(icon: '☀️', value: day.afternoonValue),
                    const SizedBox(width: 4),
                    _HappinessValueChip(icon: '🌙', value: day.eveningValue),
                  ],
                ),
                const SizedBox(width: AppDimensions.paddingS),
              ],
              
              // Navigate arrow
              const Icon(
                Icons.chevron_right,
                color: AppColors.iconSecondary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small happiness value chip
class _HappinessValueChip extends StatelessWidget {
  final String icon;
  final double? value;

  const _HappinessValueChip({
    required this.icon,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: hasValue 
            ? AppColors.getHappinessColor(value!).withOpacity(0.3)
            : AppColors.backgroundTertiary,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 10)),
          if (hasValue) ...[
            const SizedBox(width: 2),
            Text(
              value!.toStringAsFixed(1),
              style: TextStyle(
                color: AppColors.getHappinessColorDark(value!),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Event edit sheet
class _EventEditSheet extends StatefulWidget {
  final Event event;
  final Future<void> Function(String title, DateTime startDate, DateTime endDate, int colorIndex) onSave;

  const _EventEditSheet({
    required this.event,
    required this.onSave,
  });

  @override
  State<_EventEditSheet> createState() => _EventEditSheetState();
}

class _EventEditSheetState extends State<_EventEditSheet> {
  late TextEditingController _titleController;
  late DateTime _startDate;
  late DateTime _endDate;
  late int _selectedColorIndex;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event.title);
    _startDate = widget.event.startDate;
    _endDate = widget.event.endDate;
    _selectedColorIndex = widget.event.colorIndex;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(bool isStartDate) async {
    final initialDate = isStartDate ? _startDate : _endDate;
    final firstDate = isStartDate ? DateTime(2020) : _startDate;
    
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              surface: AppColors.cardBackground,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (date != null) {
      setState(() {
        if (isStartDate) {
          _startDate = date;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = date;
        }
      });
    }
  }

  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty) return;
    
    setState(() => _isSaving = true);
    
    await widget.onSave(
      _titleController.text.trim(),
      _startDate,
      _endDate,
      _selectedColorIndex,
    );
    
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusXL),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        AppDimensions.paddingL,
        AppDimensions.paddingL,
        AppDimensions.paddingL,
        AppDimensions.paddingL + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  AppStrings.editEvent,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: AppDimensions.fontXL,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  color: AppColors.iconSecondary,
                ),
              ],
            ),
            
            const SizedBox(height: AppDimensions.paddingL),
            
            TextField(
              controller: _titleController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: AppStrings.eventPlaceholder,
                hintStyle: const TextStyle(color: AppColors.textTertiary),
                filled: true,
                fillColor: AppColors.inputBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  borderSide: const BorderSide(color: AppColors.inputBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  borderSide: const BorderSide(color: AppColors.inputBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
                ),
              ),
            ),
            
            const SizedBox(height: AppDimensions.paddingL),
            
            Row(
              children: [
                Expanded(
                  child: _DateSelector(
                    label: AppStrings.eventStartDate,
                    date: _startDate,
                    onTap: () => _selectDate(true),
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingM),
                Expanded(
                  child: _DateSelector(
                    label: AppStrings.eventEndDate,
                    date: _endDate,
                    onTap: () => _selectDate(false),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppDimensions.paddingL),
            
            const Text(
              AppStrings.selectColor,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: AppDimensions.fontS,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingS),
            
            Wrap(
              spacing: AppDimensions.paddingS,
              runSpacing: AppDimensions.paddingS,
              children: List.generate(
                AppColors.eventColors.length,
                (index) => GestureDetector(
                  onTap: () => setState(() => _selectedColorIndex = index),
                  child: AnimatedContainer(
                    duration: AppDimensions.animationFast,
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.eventColors[index],
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _selectedColorIndex == index
                            ? AppColors.textPrimary
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: _selectedColorIndex == index
                        ? Icon(
                            Icons.check,
                            color: AppColors.needsLightText(index) 
                                ? Colors.white 
                                : AppColors.textPrimary,
                            size: 16,
                          )
                        : null,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: AppDimensions.paddingXL),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingM),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  ),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : const Text(
                        AppStrings.save,
                        style: TextStyle(
                          fontSize: AppDimensions.fontL,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            
            const SizedBox(height: AppDimensions.paddingM),
          ],
        ),
      ),
    );
  }
}

class _DateSelector extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;

  const _DateSelector({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textTertiary,
                fontSize: AppDimensions.fontXS,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: AppColors.primaryColor),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    AppStrings.formatDateShort(date),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: AppDimensions.fontM,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}