import 'package:flutter_test/flutter_test.dart';
import 'package:todo/models/item.dart';

void main() {
  group('Item Model Unit Tests', () {
    test('creates Item instance with given values', () {
      const item = Item(id: '1', title: 'Buy milk', done: false);
      expect(item.id, '1');
      expect(item.title, 'Buy milk');
      expect(item.done, isFalse);
    });

    test('Item.fromJson parses valid map correctly', () {
      final jsonMap = {
        'id': 'item_100',
        'title': ' Clean house ',
        'done': true,
      };

      final item = Item.fromJson(jsonMap);
      expect(item.id, 'item_100');
      expect(item.title, 'Clean house'); // checks trim
      expect(item.done, isTrue);
    });

    test('Item.fromJson handles missing or invalid fields gracefully', () {
      final invalidJson = <String, dynamic>{
        'id': null,
        'title': null,
        'done': 'not_a_bool',
      };

      final item = Item.fromJson(invalidJson);
      expect(item.id, isNotEmpty);
      expect(item.title, '');
      expect(item.done, isFalse);
    });

    test('toJson serializes Item correctly', () {
      const item = Item(id: 'abc', title: 'Read book', done: true);
      final json = item.toJson();

      expect(json, {
        'id': 'abc',
        'title': 'Read book',
        'done': true,
      });
    });

    test('copyWith updates fields while retaining unchanged values', () {
      const item = Item(id: '1', title: 'Task 1', done: false);
      final updated = item.copyWith(done: true);

      expect(updated.id, '1');
      expect(updated.title, 'Task 1');
      expect(updated.done, isTrue);
    });

    test('equality operator and hashCode work correctly', () {
      const item1 = Item(id: '1', title: 'Task 1', done: false);
      const item2 = Item(id: '1', title: 'Task 1', done: false);
      const item3 = Item(id: '2', title: 'Task 1', done: false);

      expect(item1, equals(item2));
      expect(item1 == item3, isFalse);
      expect(item1.hashCode, equals(item2.hashCode));
    });
  });
}
