import 'package:hive/hive.dart';

part 'prompt_category.g.dart';

@HiveType(typeId: 6)
enum PromptCategory {
  @HiveField(0)
  mentalHealth,
  @HiveField(1)
  relationships,
  @HiveField(2)
  gratitude,
  @HiveField(3)
  selfDiscovery,
  @HiveField(4)
  creativity,
  @HiveField(5)
  goals,
  @HiveField(6)
  mindfulness,
  @HiveField(7)
  random,
}

extension PromptCategoryExtension on PromptCategory {
  String get displayName {
    switch (this) {
      case PromptCategory.mentalHealth:
        return 'Mental Health';
      case PromptCategory.relationships:
        return 'Relationships';
      case PromptCategory.gratitude:
        return 'Gratitude';
      case PromptCategory.selfDiscovery:
        return 'Self-Discovery';
      case PromptCategory.creativity:
        return 'Creativity';
      case PromptCategory.goals:
        return 'Goals & Dreams';
      case PromptCategory.mindfulness:
        return 'Mindfulness';
      case PromptCategory.random:
        return 'Random/Surprise';
    }
  }

  String get icon {
    switch (this) {
      case PromptCategory.mentalHealth:
        return '🧠';
      case PromptCategory.relationships:
        return '💕';
      case PromptCategory.gratitude:
        return '🙏';
      case PromptCategory.selfDiscovery:
        return '🔍';
      case PromptCategory.creativity:
        return '🎨';
      case PromptCategory.goals:
        return '✨';
      case PromptCategory.mindfulness:
        return '🧘';
      case PromptCategory.random:
        return '🎲';
    }
  }

  String get description {
    switch (this) {
      case PromptCategory.mentalHealth:
        return 'Explore your mental wellbeing and emotional state';
      case PromptCategory.relationships:
        return 'Reflect on your connections with others';
      case PromptCategory.gratitude:
        return 'Focus on appreciation and thankfulness';
      case PromptCategory.selfDiscovery:
        return 'Learn more about who you are';
      case PromptCategory.creativity:
        return 'Unleash your creative thoughts and ideas';
      case PromptCategory.goals:
        return 'Think about your aspirations and dreams';
      case PromptCategory.mindfulness:
        return 'Practice presence and awareness';
      case PromptCategory.random:
        return 'Surprise me with something unexpected';
    }
  }

  List<String> get prompts {
    switch (this) {
      case PromptCategory.mentalHealth:
        return [
          'How are you feeling emotionally today, and what might be contributing to that feeling?',
          'What thoughts have been occupying your mind lately? Are they helpful or harmful?',
          'Describe a moment today when you felt truly present and calm.',
          'What strategies help you cope when you feel overwhelmed?',
          'How has your mental health journey evolved over the past year?',
          'What would you tell someone else who is struggling with similar challenges?',
          'What self-care activities make you feel most restored?',
        ];
      case PromptCategory.relationships:
        return [
          'Describe a meaningful conversation you had recently. What made it special?',
          'Who in your life brings out the best in you, and why?',
          'What qualities do you most value in a friendship?',
          'How do you express love and appreciation to the people you care about?',
          'What relationship boundary do you need to set or maintain?',
          'Describe a time when someone showed you unexpected kindness.',
          'How have your relationships shaped who you are today?',
        ];
      case PromptCategory.gratitude:
        return [
          'What three small things today brought you joy or comfort?',
          'Who is someone you haven\'t thanked recently but should?',
          'What ability or skill of yours are you grateful to have?',
          'Describe a place that brings you peace. What makes it special?',
          'What challenge in your past are you now grateful for?',
          'What simple pleasure do you sometimes take for granted?',
          'How has a difficult experience taught you to appreciate something more?',
        ];
      case PromptCategory.selfDiscovery:
        return [
          'What values guide your decisions? How do you know when you\'re living aligned with them?',
          'What would you do if you knew you couldn\'t fail?',
          'What patterns do you notice in your behavior or thinking?',
          'What aspect of yourself would you like to understand better?',
          'What stories do you tell yourself about who you are? Are they all true?',
          'What does success mean to you, and has that definition changed over time?',
          'What would your younger self be most surprised to learn about you now?',
        ];
      case PromptCategory.creativity:
        return [
          'If you could create anything without limitations, what would it be?',
          'What idea has been floating around in your mind lately?',
          'Describe your ideal creative space. What would it look, feel, and sound like?',
          'What creative project would you start if you had unlimited time?',
          'What inspires your creativity most? Colors, music, nature, people?',
          'How do you handle creative blocks or self-doubt?',
          'What would you create as a gift for someone you love?',
        ];
      case PromptCategory.goals:
        return [
          'What dream feels too big or impossible, but excites you anyway?',
          'What would you regret not trying if you looked back in 10 years?',
          'What skills would you love to develop, and why?',
          'Describe the person you\'re becoming. What are they like?',
          'What legacy do you want to leave behind?',
          'What would your ideal day look like five years from now?',
          'What\'s one small step you could take today toward a bigger goal?',
        ];
      case PromptCategory.mindfulness:
        return [
          'What do you notice when you really pay attention to this moment?',
          'How does your body feel right now? What is it telling you?',
          'What sounds, smells, or sensations are you aware of in this space?',
          'What thoughts are passing through your mind without judgment?',
          'How can you be more gentle with yourself today?',
          'What would change if you approached today with curiosity instead of judgment?',
          'What beauty can you find in something ordinary around you?',
        ];
      case PromptCategory.random:
        return [
          'If you could have dinner with any historical figure, who would it be and what would you ask?',
          'What superpower would you choose and how would you use it for good?',
          'Describe the most beautiful thing you\'ve ever seen.',
          'If you could solve one world problem, what would it be and why?',
          'What song perfectly captures how you feel right now?',
          'If you could time travel, would you go to the past or future? Why?',
          'What would you do if you had an entire day with no obligations?',
        ];
    }
  }
}
