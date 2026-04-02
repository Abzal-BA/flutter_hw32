import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_hw32/features/tasks/data/models/task_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../fixtures/task_fixtures.dart';

class _MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

void main() {
  group('TaskModel.fromDoc', () {
    late _MockDocumentSnapshot doc;

    setUp(() {
      doc = _MockDocumentSnapshot();
      when(() => doc.id).thenReturn('task-1');
    });

    test('maps all dto fields to domain entity', () {
      when(() => doc.data()).thenReturn(TaskFixtures.validDocData());

      final result = TaskModel.fromDoc(doc);

      expect(result.id, 'task-1');
      expect(result.uid, 'user-1');
      expect(result.title, 'Write tests');
      expect(result.description, 'Cover mapper and use case');
      expect(result.status, 'in_progress');
      expect(result.category, 'study');
      expect(result.tags, <String>['flutter', 'testing']);
      expect(result.createdAt?.toUtc(), TaskFixtures.createdAt);
      expect(result.updatedAt?.toUtc(), TaskFixtures.updatedAt);
    });

    test('uses fallback values when dto data is null', () {
      when(() => doc.data()).thenReturn(null);

      final result = TaskModel.fromDoc(doc);

      expect(result.id, 'task-1');
      expect(result.uid, '');
      expect(result.title, '');
      expect(result.description, '');
      expect(result.status, 'todo');
      expect(result.category, 'general');
      expect(result.tags, isEmpty);
      expect(result.createdAt, isNull);
      expect(result.updatedAt, isNull);
    });

    test('filters empty tags and casts values to string', () {
      when(
        () => doc.data(),
      ).thenReturn(TaskFixtures.validDocData(tags: <dynamic>['flutter', '', 7]));

      final result = TaskModel.fromDoc(doc);

      expect(result.tags, <String>['flutter', '7']);
    });

    test('ignores invalid timestamp values', () {
      when(
        () => doc.data(),
      ).thenReturn(
        TaskFixtures.validDocData(createdAt: 'bad', updatedAt: 123),
      );

      final result = TaskModel.fromDoc(doc);

      expect(result.createdAt, isNull);
      expect(result.updatedAt, isNull);
    });

    test('casts non string scalar fields to string', () {
      when(
        () => doc.data(),
      ).thenReturn(<String, dynamic>{
        'uid': 99,
        'title': 456,
        'description': true,
        'status': 1,
        'category': false,
        'tags': const <dynamic>[],
      });

      final result = TaskModel.fromDoc(doc);

      expect(result.uid, '99');
      expect(result.title, '456');
      expect(result.description, 'true');
      expect(result.status, '1');
      expect(result.category, 'false');
    });
  });
}
