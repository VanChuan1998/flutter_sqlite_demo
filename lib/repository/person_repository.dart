import 'package:flutter/material.dart';
import 'package:flutter_sqlite_demo/app_config/text_config.dart';
import 'package:flutter_sqlite_demo/main.dart';
import 'package:flutter_sqlite_demo/model/student/person_entity.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class PersonRepository {
  static Future<String> createDatabase({required String databaseName}) async {
    // Get a location using getDatabasesPath
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, databaseName);
    return path;
  }

  static Future<Database> open(
      {required String path, required int version}) async {
    return await openDatabase(path, version: version,
        onCreate: (Database db, int version) async {
      await db.execute('''
create table ${TextConfig.personTable} ( 
  ${TextConfig.personColumnId} integer primary key autoincrement, 
  ${TextConfig.personColumnName} text not null,
  ${TextConfig.personColumnAge} integer not null)
''');
    },
        onUpgrade: (db, oldVersion, newVersion) async {
      if (navigatorKey.currentContext != null && oldVersion < version) {
        showDialog<void>(
          context: navigatorKey.currentContext!,
          barrierDismissible: false,
          // false = user must tap button, true = tap outside dialog
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: const Text('Thông báo'),
              content: const Text(
                  'Phiên bản hiện tại đã quá lỗi thời. Vui lòng cập nhật lên phiên bản mới nhất'),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(dialogContext).pop(); // Dismiss alert dialog
                  },
                ),
              ],
            );
          },
        );
      }
    });
  }

  ///ALTER TABLE $tableName ADD COLUMN $columnName INTEGER
  static Future<void> queryDatabase({
    required Database db,
    required String sqlQuery,
  }) async {
    return await db.execute(sqlQuery);
  }

  static Future<int> insert({
    required Person person,
    required Database db,
  }) async {
    return await db.insert(TextConfig.personTable, person.personToJson(person));
  }

  static Future<Person?> getPerson(
      {required int id, required Database db}) async {
    List<Map<String, dynamic>> maps = await db.query(TextConfig.personTable,
        columns: [
          TextConfig.personColumnId,
          TextConfig.personColumnName,
          TextConfig.personColumnAge
        ],
        where: '${TextConfig.personColumnId} = ?',
        whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Person().personFromJson(maps.first);
    }
    return null;
  }

  static Future<List<Person>?> getAllPerson({required Database db}) async {
    List<Map<String, dynamic>> maps = await db.query(TextConfig.personTable);
    if (maps.isNotEmpty) {
      List<Person> person = [];
      for (var value in maps) {
        person.add(Person().personFromJson(value));
      }
      return person;
    }
    return null;
  }

  static Future<int> delete({required int id, required Database db}) async {
    return await db.delete(TextConfig.personTable,
        where: '${TextConfig.personColumnId} = ?', whereArgs: [id]);
  }

  static Future<int> update(
      {required Person person, required Database db}) async {
    return await db.update(TextConfig.personTable, person.personToJson(person),
        where: '${TextConfig.personColumnId} = ?', whereArgs: [person.id]);
  }

  static Future<int> getVersion({required Database db}) async {
    return await db.getVersion();
  }

  static Future close({required Database db}) async => db.close();
}
