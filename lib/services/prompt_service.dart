import 'dart:math';

class PromptService {
  static final List<String> _prompts = [
    "What made you smile today?",
    "What challenge did you overcome today?",
    "If you could change one thing about today, what would it be?",
    "What are three things you're grateful for right now?",
    "How did you grow as a person today?",
    "What moment today brought you the most joy?",
    "What did you learn about yourself today?",
    "How did you show kindness to yourself or others today?",
    "What would you tell your younger self about today?",
    "What emotion dominated your day and why?",
    "What's one thing you want to remember about today?",
    "How did you step out of your comfort zone today?",
    "What patterns in your thoughts did you notice today?",
    "What are you most proud of accomplishing today?",
    "How did you handle stress or difficult situations today?",
    "What connections with others meant the most to you today?",
    "What did you discover about your values today?",
    "How did you practice self-care today?",
    "What mistake taught you something valuable today?",
    "What hopes do you have for tomorrow?",
    "How did you honor your authentic self today?",
    "What beauty did you notice in the world today?",
    "How did you contribute to someone else's wellbeing today?",
    "What old habit did you choose not to follow today?",
    "What new perspective did you gain today?",
    "How did you celebrate small victories today?",
    "What fear did you face today?",
    "How did you practice mindfulness today?",
    "What story are you telling yourself about today?",
    "How did today align with your deeper purpose?",
  ];

  static String getPromptForDate(DateTime date) {
    // Use date as seed to ensure same prompt for same date
    final seed = date.year * 10000 + date.month * 100 + date.day;
    final random = Random(seed);
    return _prompts[random.nextInt(_prompts.length)];
  }

  static String getTodayPrompt() {
    return getPromptForDate(DateTime.now());
  }

  static List<String> getAllPrompts() {
    return List.unmodifiable(_prompts);
  }
}
