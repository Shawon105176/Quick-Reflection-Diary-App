import 'package:flutter_test/flutter_test.dart';
import 'package:dairy_app/services/prompt_service.dart';
import 'package:dairy_app/models/reflection_entry.dart';

void main() {
  group('Core App Tests', () {
    test('Prompt Service generates consistent prompts', () {
      final today = DateTime.now();
      final prompt1 = PromptService.getPromptForDate(today);
      final prompt2 = PromptService.getPromptForDate(today);

      expect(
        prompt1,
        equals(prompt2),
        reason: 'Same date should generate same prompt',
      );
      expect(prompt1.isNotEmpty, true, reason: 'Prompt should not be empty');
    });

    test('Reflection Entry creation works', () {
      final entry = ReflectionEntry(
        id: 'test-1',
        date: DateTime.now(),
        prompt: 'Test prompt',
        reflection: 'Test reflection',
        createdAt: DateTime.now(),
      );

      expect(entry.id, equals('test-1'));
      expect(entry.prompt, equals('Test prompt'));
      expect(entry.reflection, equals('Test reflection'));
    });

    test('Prompt Service has prompts available', () {
      final allPrompts = PromptService.getAllPrompts();
      expect(
        allPrompts.isNotEmpty,
        true,
        reason: 'Should have prompts available',
      );
      expect(
        allPrompts.length,
        greaterThan(10),
        reason: 'Should have multiple prompts',
      );
    });
  });
}
