import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_colors.dart';
import '../config/app_dimensions.dart';
import '../config/app_strings.dart';
import '../config/app_config.dart';
import '../providers/app_provider.dart';
import '../models/tag.dart';

/// Widget for displaying and managing tags for a selected day
class TagsSection extends StatefulWidget {
  const TagsSection({super.key});

  @override
  State<TagsSection> createState() => _TagsSectionState();
}

class _TagsSectionState extends State<TagsSection> {
  final TextEditingController _tagController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _showAllTags = false;
  bool _isCreating = false;

  @override
  void dispose() {
    _tagController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _createAndAddTag(AppProvider provider) async {
    final tagName = _tagController.text.trim();
    if (tagName.isEmpty || _isCreating) return;

    setState(() => _isCreating = true);

    try {
      debugPrint('Creating tag: $tagName');
      
      // Create or get existing tag
      final tag = await provider.createTag(tagName);
      debugPrint('Tag created/found: ${tag?.id} - ${tag?.name}');
      
      if (tag != null) {
        // Check if not already added to this day
        if (!provider.isTagAddedToSelectedDay(tag)) {
          debugPrint('Adding tag to day: ${tag.id}');
          await provider.addTagToSelectedDay(tag);
          debugPrint('Tag added successfully');
        } else {
          debugPrint('Tag already added to this day');
        }
      }
      
      // Clear input
      _tagController.clear();
      _focusNode.unfocus();
      
      // Show success feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tag "${tag?.name}" added'),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error creating/adding tag: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final selectedTags = provider.selectedDayTags;
        final allTags = provider.allTags;
        
        // Filter out already selected tags
        final availableTags = allTags
            .where((tag) => !provider.isTagAddedToSelectedDay(tag))
            .toList();

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
              // Title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.label_rounded,
                      color: AppColors.primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    AppStrings.tagsTitle,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: AppDimensions.fontL,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppDimensions.paddingM),
              
              // Tag input field
              _buildTagInput(provider),
              
              const SizedBox(height: AppDimensions.paddingM),
              
              // Selected tags
              if (selectedTags.isNotEmpty) ...[
                const Text(
                  'Added to this day:',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: AppDimensions.fontS,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingS),
                _buildSelectedTags(provider, selectedTags),
                const SizedBox(height: AppDimensions.paddingM),
              ],
              
              // Available tags toggle
              if (availableTags.isNotEmpty) ...[
                _buildAvailableTagsSection(provider, availableTags),
              ],
            ],
          ),
        );
      },
    );
  }

  /// Build tag input field
  Widget _buildTagInput(AppProvider provider) {
    return Container(
      height: AppDimensions.tagInputHeight,
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(
          color: _isCreating ? AppColors.primaryColor : AppColors.inputBorder,
          width: _isCreating ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _tagController,
              focusNode: _focusNode,
              maxLength: AppConfig.maxTagLength,
              enabled: !_isCreating,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: AppDimensions.fontM,
              ),
              decoration: const InputDecoration(
                hintText: AppStrings.tagPlaceholder,
                hintStyle: TextStyle(
                  color: AppColors.textTertiary,
                ),
                border: InputBorder.none,
                counterText: '',
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingM,
                ),
              ),
              onSubmitted: _isCreating ? null : (_) => _createAndAddTag(provider),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _isCreating ? null : () => _createAndAddTag(provider),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(AppDimensions.radiusM),
                bottomRight: Radius.circular(AppDimensions.radiusM),
              ),
              child: Container(
                width: AppDimensions.tagInputHeight,
                height: AppDimensions.tagInputHeight,
                decoration: BoxDecoration(
                  color: _isCreating 
                      ? AppColors.primaryColor.withOpacity(0.5)
                      : AppColors.primaryColor,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(AppDimensions.radiusM - 1),
                    bottomRight: Radius.circular(AppDimensions.radiusM - 1),
                  ),
                ),
                child: _isCreating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build selected tags chips
  Widget _buildSelectedTags(AppProvider provider, List<Tag> tags) {
    return Wrap(
      spacing: AppDimensions.tagSpacing,
      runSpacing: AppDimensions.tagSpacing,
      children: tags.map((tag) {
        return _TagChip(
          tag: tag,
          isSelected: true,
          onTap: () async {
            await provider.removeTagFromSelectedDay(tag);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Tag "${tag.name}" removed'),
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
        );
      }).toList(),
    );
  }

  /// Build available tags section
  Widget _buildAvailableTagsSection(AppProvider provider, List<Tag> availableTags) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Toggle button
        GestureDetector(
          onTap: () {
            setState(() {
              _showAllTags = !_showAllTags;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingM,
              vertical: AppDimensions.paddingS,
            ),
            decoration: BoxDecoration(
              color: AppColors.backgroundTertiary,
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${AppStrings.allTags} (${availableTags.length})',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: AppDimensions.fontS,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingXS),
                Icon(
                  _showAllTags 
                      ? Icons.keyboard_arrow_up 
                      : Icons.keyboard_arrow_down,
                  color: AppColors.textSecondary,
                  size: AppDimensions.iconS,
                ),
              ],
            ),
          ),
        ),
        
        // Available tags list
        if (_showAllTags) ...[
          const SizedBox(height: AppDimensions.paddingM),
          Wrap(
            spacing: AppDimensions.tagSpacing,
            runSpacing: AppDimensions.tagSpacing,
            children: availableTags.map((tag) {
              return _TagChip(
                tag: tag,
                isSelected: false,
                onTap: () async {
                  await provider.addTagToSelectedDay(tag);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Tag "${tag.name}" added'),
                        duration: const Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                },
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}

/// Individual tag chip widget
class _TagChip extends StatelessWidget {
  final Tag tag;
  final bool isSelected;
  final VoidCallback onTap;

  const _TagChip({
    required this.tag,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDimensions.animationFast,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.tagPaddingH,
          vertical: AppDimensions.tagPaddingV,
        ),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.tagSelectedBackground 
              : AppColors.tagBackground,
          borderRadius: BorderRadius.circular(AppDimensions.radiusCircle),
          border: Border.all(
            color: isSelected 
                ? AppColors.tagSelectedBackground 
                : AppColors.tagBorder,
            width: AppDimensions.tagBorderWidth,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              tag.name,
              style: TextStyle(
                color: isSelected 
                    ? AppColors.tagSelectedText 
                    : AppColors.tagText,
                fontSize: AppDimensions.tagFontSize,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: AppDimensions.paddingXS),
              Icon(
                Icons.close,
                color: AppColors.tagSelectedText,
                size: AppDimensions.iconS,
              ),
            ] else ...[
              const SizedBox(width: AppDimensions.paddingXS),
              Icon(
                Icons.add,
                color: AppColors.tagText,
                size: AppDimensions.iconS,
              ),
            ],
          ],
        ),
      ),
    );
  }
}