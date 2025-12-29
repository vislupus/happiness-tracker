import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_colors.dart';
import '../config/app_dimensions.dart';
import '../config/app_strings.dart';
import '../providers/app_provider.dart';
import '../models/event.dart';

/// Widget for displaying and managing events for a selected day
class EventsSection extends StatefulWidget {
  const EventsSection({super.key});

  @override
  State<EventsSection> createState() => _EventsSectionState();
}

class _EventsSectionState extends State<EventsSection> {
  // Track which event has actions shown
  int? _expandedEventId;
  DateTime? _lastSelectedDate;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkDateChange();
  }

  void _checkDateChange() {
    final provider = context.read<AppProvider>();
    if (_lastSelectedDate != provider.selectedDate) {
      _lastSelectedDate = provider.selectedDate;
      if (_expandedEventId != null) {
        setState(() {
          _expandedEventId = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        // Check for date change
        if (_lastSelectedDate != provider.selectedDate) {
          _lastSelectedDate = provider.selectedDate;
          _expandedEventId = null;
        }

        final events = provider.selectedDayEvents;
        final isExpanded = provider.eventsExpanded;

        return Container(
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
            children: [
              // Header (always visible)
              _buildHeader(provider, events.length, isExpanded),
              
              // Content (collapsible)
              AnimatedCrossFade(
                duration: AppDimensions.animationNormal,
                crossFadeState: isExpanded 
                    ? CrossFadeState.showSecond 
                    : CrossFadeState.showFirst,
                firstChild: const SizedBox.shrink(),
                secondChild: _buildContent(provider, events),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(AppProvider provider, int eventCount, bool isExpanded) {
    return InkWell(
      onTap: () => provider.toggleEventsExpanded(),
      borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.sliderCardPadding),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.event_rounded,
                color: AppColors.primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Row(
                children: [
                  const Text(
                    AppStrings.eventsTitle,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: AppDimensions.fontL,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (eventCount > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$eventCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            AnimatedRotation(
              turns: isExpanded ? 0.5 : 0,
              duration: AppDimensions.animationNormal,
              child: const Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.iconSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(AppProvider provider, List<Event> events) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.sliderCardPadding,
        0,
        AppDimensions.sliderCardPadding,
        AppDimensions.sliderCardPadding,
      ),
      child: Column(
        children: [
          // Event list
          if (events.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingM),
              child: Text(
                AppStrings.noEvents,
                style: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: AppDimensions.fontM,
                ),
              ),
            )
          else
            ...events.map((event) => _EventItem(
              key: ValueKey(event.id),
              event: event,
              isExpanded: _expandedEventId == event.id,
              onTap: () {
                setState(() {
                  if (_expandedEventId == event.id) {
                    _expandedEventId = null;
                  } else {
                    _expandedEventId = event.id;
                  }
                });
              },
              onEdit: () => _showEventDialog(context, provider, event: event),
              onDelete: () => _confirmDeleteEvent(context, provider, event),
            )),
          
          // Add button
          const SizedBox(height: AppDimensions.paddingS),
          _AddEventButton(
            onTap: () => _showEventDialog(context, provider),
          ),
        ],
      ),
    );
  }

  void _showEventDialog(
    BuildContext context, 
    AppProvider provider, {
    Event? event,
  }) {
    // Close any expanded event
    setState(() {
      _expandedEventId = null;
    });
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EventFormSheet(
        event: event,
        selectedDate: provider.selectedDate,
        onSave: (title, startDate, endDate, colorIndex) async {
          if (event != null) {
            await provider.updateEvent(event.copyWith(
              title: title,
              startDate: startDate,
              endDate: endDate,
              colorIndex: colorIndex,
            ));
          } else {
            await provider.createEvent(
              title: title,
              startDate: startDate,
              endDate: endDate,
              colorIndex: colorIndex,
            );
          }
        },
      ),
    );
  }

  void _confirmDeleteEvent(
    BuildContext context, 
    AppProvider provider, 
    Event event,
  ) {
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
          'Are you sure you want to delete "${event.title}"?',
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
              setState(() {
                _expandedEventId = null;
              });
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

/// Individual event item
class _EventItem extends StatelessWidget {
  final Event event;
  final bool isExpanded;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _EventItem({
    super.key,
    required this.event,
    required this.isExpanded,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.getEventColor(event.colorIndex);
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDimensions.animationFast,
        margin: const EdgeInsets.only(bottom: AppDimensions.paddingS),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingM,
          vertical: AppDimensions.paddingS,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Color dot
            Container(
              width: AppDimensions.eventColorDotSize,
              height: AppDimensions.eventColorDotSize,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppDimensions.paddingM),
            
            // Title
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: AppDimensions.eventFontSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (event.durationInDays > 1)
                    Text(
                      '${AppStrings.formatDate(event.startDate)} - ${AppStrings.formatDate(event.endDate)}',
                      style: const TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: AppDimensions.fontXS,
                      ),
                    ),
                ],
              ),
            ),
            
            // Actions (only when expanded)
            AnimatedSize(
              duration: AppDimensions.animationFast,
              child: isExpanded
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, size: AppDimensions.eventIconSize),
                          color: AppColors.iconSecondary,
                          onPressed: onEdit,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, size: AppDimensions.eventIconSize),
                          color: AppColors.error,
                          onPressed: onDelete,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Add event button
class _AddEventButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddEventButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.paddingM,
        ),
        decoration: BoxDecoration(
          color: AppColors.backgroundTertiary,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          border: Border.all(
            color: AppColors.inputBorder,
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add,
              color: AppColors.primaryColor,
              size: AppDimensions.iconM,
            ),
            SizedBox(width: AppDimensions.paddingS),
            Text(
              AppStrings.addEvent,
              style: TextStyle(
                color: AppColors.primaryColor,
                fontSize: AppDimensions.fontM,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Event form bottom sheet
class _EventFormSheet extends StatefulWidget {
  final Event? event;
  final DateTime selectedDate;
  final Future<void> Function(String title, DateTime startDate, DateTime endDate, int colorIndex) onSave;

  const _EventFormSheet({
    this.event,
    required this.selectedDate,
    required this.onSave,
  });

  @override
  State<_EventFormSheet> createState() => _EventFormSheetState();
}

class _EventFormSheetState extends State<_EventFormSheet> {
  late TextEditingController _titleController;
  late DateTime _startDate;
  late DateTime _endDate;
  late int _selectedColorIndex;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event?.title ?? '');
    _startDate = widget.event?.startDate ?? widget.selectedDate;
    _endDate = widget.event?.endDate ?? widget.selectedDate;
    _selectedColorIndex = widget.event?.colorIndex ?? 0;
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
            // Handle bar
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
            
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.event != null ? AppStrings.editEvent : AppStrings.addEvent,
                  style: const TextStyle(
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
            
            // Title input
            TextField(
              controller: _titleController,
              autofocus: widget.event == null,
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
            
            // Date selection
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
            
            // Color selection
            const Text(
              AppStrings.selectColor,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: AppDimensions.fontS,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingS),
            _ColorSelector(
              selectedIndex: _selectedColorIndex,
              onSelect: (index) {
                setState(() => _selectedColorIndex = index);
              },
            ),
            
            const SizedBox(height: AppDimensions.paddingXL),
            
            // Save button
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

/// Date selector widget - using short date format
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
                const Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: AppColors.primaryColor,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    AppStrings.formatDateShort(date), // Using short format
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

/// Color selector widget - all colors in one grid
class _ColorSelector extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const _ColorSelector({
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppDimensions.paddingS,
      runSpacing: AppDimensions.paddingS,
      children: List.generate(
        AppColors.eventColors.length,
        (index) => _ColorDot(
          index: index,
          isSelected: selectedIndex == index,
          onTap: () => onSelect(index),
        ),
      ),
    );
  }
}

/// Individual color dot
class _ColorDot extends StatelessWidget {
  final int index;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorDot({
    required this.index,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.eventColors[index];
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDimensions.animationFast,
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? AppColors.textPrimary : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.5),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: isSelected
            ? Icon(
                Icons.check,
                color: AppColors.needsLightText(index) ? Colors.white : AppColors.textPrimary,
                size: 16,
              )
            : null,
      ),
    );
  }
}