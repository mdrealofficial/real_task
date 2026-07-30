import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

class WidgetService {
  static const String appGroupId = 'group.com.realtask.app';
  static const String iOSWidgetName = 'TaskFlowWidget';

  /// Update Mobile Home Screen Widgets with Today's Progress Stats
  static Future<void> updateHomeScreenWidget({
    required double completionPercentage,
    required int completedCount,
    required int totalCount,
  }) async {
    // home_widget plugin is designed for iOS & Android Home Screen Widgets
    if (kIsWeb || (defaultTargetPlatform != TargetPlatform.iOS && defaultTargetPlatform != TargetPlatform.android)) {
      return;
    }

    try {
      await HomeWidget.setAppGroupId(appGroupId);

      await HomeWidget.saveWidgetData<String>('percentage_text', '${completionPercentage.toStringAsFixed(0)}%');
      await HomeWidget.saveWidgetData<int>('completed_count', completedCount);
      await HomeWidget.saveWidgetData<int>('total_count', totalCount);

      await HomeWidget.updateWidget(
        name: iOSWidgetName,
        iOSName: iOSWidgetName,
      );
    } catch (e) {
      debugPrint('Widget Sync Error: $e');
    }
  }
}
