import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class TodoDatabase{

  static Database db;

  static Future open() async {
    db = await openDatabase(join(await getDatabasesPath(),'Todos.db'),
    version: 1,
    onCreate: (db,version) async {
      db.execute('''
      create table Todos(
        id integer primary key autoincrement,
        title text not null,
        desc text not null,
        date text not null,
        time text not null,
        isChecked text not null,
        notify text not null
      );
      ''');
    }
    );
  }

  static Future<List<Map<String,dynamic>>> getTodoList() async {
    if(db==null){
      await open();
    }
    return await db.query('Todos');
  }

  static Future insertTodo(Map<String, dynamic> todo) async {
    await db.insert('Todos', todo);
  }

  static Future updateTodo(Map<String, dynamic> todo) async {
    await db.update('Todos',
        todo,
        where: 'id = ?',
      whereArgs: [todo['id']]
    );
  }

  static Future deleteTodo(int id) async {
    await db.delete(
      'Todos',
      where: 'id = ?',
      whereArgs: [id]
    );
  }
}