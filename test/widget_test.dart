import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:todo_app/main.dart';
import 'package:todo_app/services/notification_service.dart';

void main() {
  testWidgets('Renders the initial screen', (WidgetTester tester) async {
    // Initialize services.
    await GetStorage.init();
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Detroit'));
    final notificationService = NotificationService();
    await notificationService.init();

    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(notificationService: notificationService));

    // Allow time for the BLoC to load tasks
    await tester.pump();

    // Verify that the main screen is rendered.
    expect(find.text('My Tasks'), findsOneWidget);
    expect(find.text('Pending'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);
    expect(find.text('No tasks yet.\nTap + to add one!'), findsOneWidget);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that the dialog is shown.
    expect(find.text('Add New Task'), findsOneWidget);
  });
}
