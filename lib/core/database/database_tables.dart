class DatabaseTables {
  static const String routines = 'routines';
  static const String routineCompletions = 'routine_completions';
  static const String focusSessions = 'focus_sessions';
  static const String userPreferences = 'user_preferences';

  static const String createRoutinesTable = '''
    CREATE TABLE $routines (
      id TEXT PRIMARY KEY,
      title TEXT NOT NULL,
      subtitle TEXT,
      category TEXT NOT NULL,
      block TEXT NOT NULL,
      icon TEXT NOT NULL,
      target_minutes INTEGER NOT NULL,
      color_hex INTEGER NOT NULL,
      is_archived INTEGER DEFAULT 0,
      order_index INTEGER DEFAULT 0,
      created_at TEXT NOT NULL
    );
  ''';

  static const String createRoutineCompletionsTable = '''
    CREATE TABLE $routineCompletions (
      id TEXT PRIMARY KEY,
      routine_id TEXT NOT NULL,
      date_string TEXT NOT NULL,
      completed_at TEXT NOT NULL,
      FOREIGN KEY (routine_id) REFERENCES $routines (id) ON DELETE CASCADE
    );
  ''';

  static const String createFocusSessionsTable = '''
    CREATE TABLE $focusSessions (
      id TEXT PRIMARY KEY,
      routine_id TEXT,
      title TEXT NOT NULL,
      category TEXT NOT NULL,
      duration_seconds INTEGER NOT NULL,
      soundscape_used TEXT,
      completed_at TEXT NOT NULL,
      date_string TEXT NOT NULL
    );
  ''';

  static const String createUserPreferencesTable = '''
    CREATE TABLE $userPreferences (
      key TEXT PRIMARY KEY,
      value TEXT NOT NULL
    );
  ''';
}
