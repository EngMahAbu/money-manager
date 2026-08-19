import '../../data/database.dart';
import '../theme/app_colors.dart';

// Helper to get ramp color for a category based on its index among all categories
ChartColorSet getCategoryRampColor(int? categoryId, List<Category> allCategories) {
  if (categoryId == null) {
    // For transfers or transactions without a category, return a neutral color
    // Use accent color as fallback
    return const ChartColorSet(
      fill: AppColors.accent,
      container: AppColors.accentContainer,
      text: AppColors.accentText,
    );
  }
  
  // Find the index of this category in the sorted list of all categories
  final sortedCategories = List<Category>.from(allCategories)
    ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  
  final index = sortedCategories.indexWhere((c) => c.id == categoryId);
  if (index == -1) {
    // Fallback to first ramp color if category not found
    return AppColors.chartRamp[0];
  }
  
  // Cycle through the ramp colors
  return AppColors.chartRamp[index % AppColors.chartRamp.length];
}
