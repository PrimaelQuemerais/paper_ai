import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'ai_paper.db');
    return await openDatabase(
      path,
      version: 2, // Increment the version number
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE conversations (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            timestamp TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE messages (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            conversation_id INTEGER,
            sender TEXT,
            message TEXT,
            FOREIGN KEY (conversation_id) REFERENCES conversations (id)
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE conversations ADD COLUMN timestamp TEXT');
        }
      },
    );
  }

  Future<int> createConversation(String title) async {
    final db = await database;
    final timestamp = DateTime.now().toIso8601String();
    return await db.insert('conversations', {'title': title, 'timestamp': timestamp});
  }

  Future<void> insertMessage(int conversationId, String sender, String message) async {
    final db = await database;
    await db.insert('messages', {
      'conversation_id': conversationId,
      'sender': sender,
      'message': message,
    });
  }

  Future<List<Map<String, dynamic>>> getConversations() async {
    final db = await database;
    return await db.query('conversations');
  }

  Future<List<Map<String, dynamic>>> getMessages(int conversationId) async {
    final db = await database;
    return await db.query('messages', where: 'conversation_id = ?', whereArgs: [conversationId]);
  }

  Future<void> deleteConversation(int conversationId) async {
    final db = await database;
    await db.delete('messages', where: 'conversation_id = ?', whereArgs: [conversationId]);
    await db.delete('conversations', where: 'id = ?', whereArgs: [conversationId]);
  }
}