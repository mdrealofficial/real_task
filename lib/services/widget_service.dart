import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

class WidgetService {
  static const String appGroupId = 'group.com.realtask.app';
  static const String iOSWidgetName = 'TaskFlowWidget';
  static const String macOSWidgetName = 'TaskFlowMacWidget';

  /// Update macOS and Mobile Home Screen Widgets with Today's Progress Stats
  static Future<void> updateHomeScreenWidget({
    required double completionPercentage,
    required int completedCount,
    required int totalCount,
  }) async {
    try {
      await HomeWidget.setAppGroupId(appGroupId);

      await HomeWidget.saveWidgetData<String>('percentage_text', '${completionPercentage.toStringAsFixed(0)}%');
      await HomeWidget.saveWidgetData<int>('completed_count', completedCount);
      await HomeWidget.saveWidgetData<int>('total_count', totalCount);

      // Trigger Widget updates for Mobile (iOS/Android) and macOS
      await HomeWidget.updateWidget(
        name: iOSWidgetName,
        iOSName: iOSWidgetName,
      );
    } catch (e) {
      debugPrint('Widget Sync Error: $e');
    }
  }
}
