import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:bakalari/src/modules/gradeModule.dart';
import 'package:bakalari/src/modules/homeworkModule.dart';
import 'package:bakalari/src/modules/privateMessagesModule.dart';
import 'package:bakalari/src/modules/subjectListModule.dart';
import 'package:bakalari/src/modules/timetableModule.dart';
import 'package:bakalari/src/school.dart';
import 'package:bakalari/src/student.dart';

/// Class that takes care of Database
class DB {
  static Database _db;
  static Store _userData;
  static Store _schools;

  static Future<void> initializeDb() async {
    _db = await databaseFactoryIo.openDatabase('main.db');
    _userData = _db.getStore('userData');
    _schools = _db.getStore('schools');
  }

  static Future<List<String>> getSchools() async {
    return await _schools.records
        .map(
            (Record school) => school.value[school.value.keys.first].toString())
        .toList();
  }

  static Future<void> addSchool(String url) async {
    await _db.putRecord(Record(_schools, {'url': url}));
  }

  /// Save student info into DB.
  /// Return access GUID.
  static Future<String> addStudent(
      Timetable timetable,
      List<Grade> grades,
      List<Subject> subjects,
      List<Homework> homeworks,
      List<PrivateMessage> messages,
      Student studentInfo,
      School schoolInfo) {
        
      }
}
