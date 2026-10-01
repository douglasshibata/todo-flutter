import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HomePage Widget & Integration Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('Renders empty task state when no tasks exist', (WidgetTester tester) async {
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();

      expect(find.text('Nenhuma tarefa cadastrada.'), findsOneWidget);
    });

    testWidgets('Loads stored tasks from SharedPreferences correctly', (WidgetTester tester) async {
      final initialData = jsonEncode([
        {'id': '1', 'title': 'Task from storage', 'done': false},
        {'id': '2', 'title': 'Completed storage task', 'done': true},
      ]);
      SharedPreferences.setMockInitialValues({'data': initialData});

      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();

      expect(find.text('Task from storage'), findsOneWidget);
      expect(find.text('Completed storage task'), findsOneWidget);
    });

    testWidgets('Adds a new task when valid text is submitted', (WidgetTester tester) async {
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();

      final inputFinder = find.byType(TextFormField);
      expect(inputFinder, findsOneWidget);

      await tester.enterText(inputFinder, 'New Test Task');
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('New Test Task'), findsOneWidget);

      // Verify task was persisted to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString('data');
      expect(storedData, contains('New Test Task'));
    });

    testWidgets('Does not add empty or whitespace-only tasks', (WidgetTester tester) async {
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();

      final inputFinder = find.byType(TextFormField);
      await tester.enterText(inputFinder, '   ');
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('Nenhuma tarefa cadastrada.'), findsOneWidget);
    });

    testWidgets('Toggles task completion status when checkbox is tapped', (WidgetTester tester) async {
      final initialData = jsonEncode([
        {'id': '1', 'title': 'Toggleable task', 'done': false},
      ]);
      SharedPreferences.setMockInitialValues({'data': initialData});

      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();

      final checkboxFinder = find.byType(Checkbox);
      expect(checkboxFinder, findsOneWidget);

      Checkbox checkbox = tester.widget(checkboxFinder);
      expect(checkbox.value, isFalse);

      await tester.tap(checkboxFinder);
      await tester.pumpAndSettle();

      checkbox = tester.widget(checkboxFinder);
      expect(checkbox.value, isTrue);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('data'), contains('"done":true'));
    });

    testWidgets('Removes task when dismissed via swipe', (WidgetTester tester) async {
      final initialData = jsonEncode([
        {'id': 'swipe_1', 'title': 'Dismissible Task', 'done': false},
      ]);
      SharedPreferences.setMockInitialValues({'data': initialData});

      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();

      expect(find.text('Dismissible Task'), findsOneWidget);

      await tester.drag(find.text('Dismissible Task'), const Offset(500, 0));
      await tester.pumpAndSettle();

      expect(find.text('Dismissible Task'), findsNothing);
      expect(find.text('Nenhuma tarefa cadastrada.'), findsOneWidget);
    });
  });
}
