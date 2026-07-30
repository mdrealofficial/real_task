import 'package:flutter_test/flutter_test.dart';
import 'package:real_task/main.dart';

void main() {
  testWidgets('TaskFlow app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TaskFlowApp());
    await tester.pump(const Duration(seconds: 10));

    // Verify that TaskFlow app renders without crashing
    expect(find.byType(TaskFlowApp), findsOneWidget);
  });
}
