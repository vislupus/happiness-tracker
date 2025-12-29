import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../config/app_dimensions.dart';
import '../../config/app_strings.dart';
import '../../providers/app_provider.dart';
import '../../models/tag.dart';
import '../../models/tag_usage.dart';
import '../home_screen.dart';

/// Tags management tab
class TagsTab extends StatefulWidget {
  const TagsTab({super.key});

  @override
  State<TagsTab> createState() => _TagsTabState();
}

class _TagsTabState extends State<TagsTab> {
  final TextEditingController _searchController = TextEditingController();
  List<Tag> _filteredTags = [];
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
    _filterTags();
  }

  Future<void> _filterTags() async {
    final provider = context.read<AppProvider>();
    final query = _searchController.text;
    
    if (query.isEmpty) {
      setState(() {
        _filteredTags = provider.allTags;
        _isSearching = false;
      });
    } else {
      final results = await provider.searchTags(query);
      setState(() {
        _filteredTags = results;
        _isSearching = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final tags = _isSearching ? _filteredTags : provider.allTags;

        return Column(
          children: [
            // Header with search and sort
            _buildHeader(provider),
            
            // Tags list
            Expanded(
              child: tags.isEmpty
                  ? _buildEmptyState()
                  : _buildTagsList(provider, tags),
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
                  Icons.label_rounded,
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
                      AppStrings.tagsTitle,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: AppDimensions.fontXL,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${provider.allTags.length} tags',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: AppDimensions.fontS,
                      ),
                    ),
                  ],
                ),
              ),
              // Sort button
              PopupMenuButton<TagSortOption>(
                icon: const Icon(
                  Icons.sort_rounded,
                  color: AppColors.iconSecondary,
                ),
                onSelected: (option) => provider.setTagSortOption(option),
                itemBuilder: (context) => [
                  _buildSortMenuItem(
                    TagSortOption.happiness,
                    AppStrings.sortByHappiness,
                    Icons.mood,
                    provider.tagSortOption,
                  ),
                  _buildSortMenuItem(
                    TagSortOption.usage,
                    AppStrings.sortByUsage,
                    Icons.trending_up,
                    provider.tagSortOption,
                  ),
                  _buildSortMenuItem(
                    TagSortOption.name,
                    AppStrings.sortByName,
                    Icons.sort_by_alpha,
                    provider.tagSortOption,
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
              hintText: AppStrings.searchTags,
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

  PopupMenuItem<TagSortOption> _buildSortMenuItem(
    TagSortOption option,
    String label,
    IconData icon,
    TagSortOption current,
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
              Icons.label_off_rounded,
              size: 48,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingL),
          Text(
            _isSearching ? 'No tags found' : AppStrings.noTags,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: AppDimensions.fontL,
            ),
          ),
          if (!_isSearching) ...[
            const SizedBox(height: AppDimensions.paddingS),
            const Text(
              'Add tags from the Calendar tab',
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

  Widget _buildTagsList(AppProvider provider, List<Tag> tags) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      itemCount: tags.length,
      itemBuilder: (context, index) {
        final tag = tags[index];
        return _TagListItem(
          tag: tag,
          onTap: () => _showTagDetails(provider, tag),
        );
      },
    );
  }

  void _showTagDetails(AppProvider provider, Tag tag) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _TagDetailsSheet(
        tag: tag,
        onNavigateToDate: (date) {
          Navigator.pop(sheetContext);
          // Switch to calendar tab and navigate to date
          provider.navigateToDate(date);
          // Find the home screen and switch tab
          final homeState = context.findAncestorStateOfType<HomeScreenState>();
          homeState?.switchToCalendarTab();
        },
        onEdit: () {
          Navigator.pop(sheetContext);
          _showEditDialog(provider, tag);
        },
        onDelete: () {
          Navigator.pop(sheetContext);
          _showDeleteDialog(provider, tag);
        },
        onMerge: () {
          Navigator.pop(sheetContext);
          _showMergeDialog(provider, tag);
        },
      ),
    );
  }

  void _showEditDialog(AppProvider provider, Tag tag) {
    final controller = TextEditingController(text: tag.name);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
        title: const Text(
          AppStrings.editTag,
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: AppStrings.tagPlaceholder,
            hintStyle: const TextStyle(color: AppColors.textTertiary),
            filled: true,
            fillColor: AppColors.inputBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              borderSide: const BorderSide(color: AppColors.inputBorder),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                provider.updateTag(tag.id!, controller.text.trim());
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text(AppStrings.save),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(AppProvider provider, Tag tag) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
        title: const Text(
          AppStrings.deleteTag,
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          AppStrings.confirmDeleteTag,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              provider.deleteTag(tag.id!);
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

  void _showMergeDialog(AppProvider provider, Tag sourceTag) {
    final otherTags = provider.allTags.where((t) => t.id != sourceTag.id).toList();
    
    if (otherTags.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No other tags to merge with'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _MergeTagSheet(
        sourceTag: sourceTag,
        otherTags: otherTags,
        onMerge: (targetTag) {
          provider.mergeTags(sourceTag.id!, targetTag.id!);
          Navigator.pop(context);
        },
      ),
    );
  }
}

/// Individual tag list item
class _TagListItem extends StatelessWidget {
  final Tag tag;
  final VoidCallback onTap;

  const _TagListItem({
    required this.tag,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasHappinessData = tag.averageHappiness != null;
    final happinessColor = hasHappinessData
        ? AppColors.getHappinessColor(tag.averageHappiness!)
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
                // Happiness indicator
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: happinessColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    border: Border.all(
                      color: happinessColor.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: hasHappinessData
                        ? Text(
                            tag.averageHappiness!.toStringAsFixed(1),
                            style: TextStyle(
                              color: AppColors.getHappinessColorDark(tag.averageHappiness!),
                              fontSize: AppDimensions.fontL,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : const Icon(
                            Icons.remove,
                            color: AppColors.textTertiary,
                            size: 20,
                          ),
                  ),
                ),
                
                const SizedBox(width: AppDimensions.paddingM),
                
                // Tag info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tag.name,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: AppDimensions.fontL,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppStrings.formatUsageCount(tag.usageCount),
                        style: const TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: AppDimensions.fontS,
                        ),
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

/// Tag details sheet with usage days
class _TagDetailsSheet extends StatefulWidget {
  final Tag tag;
  final Function(DateTime) onNavigateToDate;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onMerge;

  const _TagDetailsSheet({
    required this.tag,
    required this.onNavigateToDate,
    required this.onEdit,
    required this.onDelete,
    required this.onMerge,
  });

  @override
  State<_TagDetailsSheet> createState() => _TagDetailsSheetState();
}

class _TagDetailsSheetState extends State<_TagDetailsSheet> {
  List<TagUsageDay> _usageDays = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsageDays();
  }

  Future<void> _loadUsageDays() async {
    final provider = context.read<AppProvider>();
    final days = await provider.getTagUsageDays(widget.tag.id!);
    if (mounted) {
      setState(() {
        _usageDays = days;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasHappinessData = widget.tag.averageHappiness != null;
    final happinessColor = hasHappinessData
        ? AppColors.getHappinessColor(widget.tag.averageHappiness!)
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
                
                // Tag info card
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingM),
                  decoration: BoxDecoration(
                    color: happinessColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                    border: Border.all(
                      color: happinessColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Happiness indicator
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: happinessColor.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                        ),
                        child: Center(
                          child: hasHappinessData
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      widget.tag.averageHappiness!.toStringAsFixed(1),
                                      style: TextStyle(
                                        color: AppColors.getHappinessColorDark(widget.tag.averageHappiness!),
                                        fontSize: AppDimensions.fontXL,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'avg',
                                      style: TextStyle(
                                        color: AppColors.getHappinessColorDark(widget.tag.averageHappiness!).withOpacity(0.7),
                                        fontSize: AppDimensions.fontXS,
                                      ),
                                    ),
                                  ],
                                )
                              : const Icon(
                                  Icons.remove,
                                  color: AppColors.textTertiary,
                                  size: 24,
                                ),
                        ),
                      ),
                      
                      const SizedBox(width: AppDimensions.paddingM),
                      
                      // Tag name and usage
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.tag.name,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: AppDimensions.fontXL,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppStrings.formatUsageCount(widget.tag.usageCount),
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
                            case 'merge':
                              widget.onMerge();
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
                            value: 'merge',
                            child: Row(
                              children: [
                                Icon(Icons.merge, size: 20, color: AppColors.iconSecondary),
                                SizedBox(width: 12),
                                Text('Merge'),
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
                  'Days with this tag',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: AppDimensions.fontM,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_usageDays.length} days',
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
          
          // Usage days list
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
                : _usageDays.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(AppDimensions.paddingXL),
                        child: Column(
                          children: [
                            Icon(
                              Icons.event_busy,
                              size: 48,
                              color: AppColors.textTertiary.withOpacity(0.5),
                            ),
                            const SizedBox(height: AppDimensions.paddingM),
                            const Text(
                              'No days recorded yet',
                              style: TextStyle(
                                color: AppColors.textTertiary,
                                fontSize: AppDimensions.fontM,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(AppDimensions.paddingM),
                        itemCount: _usageDays.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final day = _usageDays[index];
                          return _UsageDayItem(
                            day: day,
                            onTap: () => widget.onNavigateToDate(day.date),
                          );
                        },
                      ),
          ),
          
          // Bottom padding
          SizedBox(height: MediaQuery.of(context).padding.bottom + AppDimensions.paddingM),
        ],
      ),
    );
  }
}

/// Individual usage day item
class _UsageDayItem extends StatelessWidget {
  final TagUsageDay day;
  final VoidCallback onTap;

  const _UsageDayItem({
    required this.day,
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

/// Merge tag selection sheet
class _MergeTagSheet extends StatelessWidget {
  final Tag sourceTag;
  final List<Tag> otherTags;
  final Function(Tag) onMerge;

  const _MergeTagSheet({
    required this.sourceTag,
    required this.otherTags,
    required this.onMerge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
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
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            AppStrings.mergeTags,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: AppDimensions.fontXL,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Merge "${sourceTag.name}" into:',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: AppDimensions.fontM,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      color: AppColors.iconSecondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              itemCount: otherTags.length,
              itemBuilder: (context, index) {
                final tag = otherTags[index];
                return _MergeTagItem(
                  tag: tag,
                  onTap: () => _confirmMerge(context, tag),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _confirmMerge(BuildContext context, Tag targetTag) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
        title: const Text('Confirm Merge', style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'Merge "${sourceTag.name}" into "${targetTag.name}"?\n\nAll usages will be transferred. This cannot be undone.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              onMerge(targetTag);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text(AppStrings.merge),
          ),
        ],
      ),
    );
  }
}

class _MergeTagItem extends StatelessWidget {
  final Tag tag;
  final VoidCallback onTap;

  const _MergeTagItem({required this.tag, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.label_rounded, color: AppColors.primaryColor, size: 20),
              ),
              const SizedBox(width: AppDimensions.paddingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tag.name, style: const TextStyle(color: AppColors.textPrimary, fontSize: AppDimensions.fontM, fontWeight: FontWeight.w500)),
                    Text(AppStrings.formatUsageCount(tag.usageCount), style: const TextStyle(color: AppColors.textTertiary, fontSize: AppDimensions.fontS)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward, color: AppColors.iconSecondary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}