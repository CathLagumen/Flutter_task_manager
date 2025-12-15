// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:task_manager/main.dart';

void main() {
  testWidgets('Task Manager app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our app title is displayed
    expect(find.text('Task Manager'), findsOneWidget);

    // Verify that the empty state message is shown
    expect(find.text('No tasks yet!'), findsOneWidget);

    // Verify that the input field exists
    expect(find.byType(TextField), findsOneWidget);

    // Enter a task
    await tester.enterText(find.byType(TextField), 'Test Task');
    
    // Tap the ElevatedButton specifically (not the FloatingActionButton)
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    // Verify that the task was added
    expect(find.text('Test Task'), findsOneWidget);
    expect(find.text('No tasks yet!'), findsNothing);
  });
}