import 'dart:io';

import 'package:path/path.dart';
import 'package:rikulo_commons/browser.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import '../model/complexStudent.dart';

/// Class that takes care of Database
class DB {
  static Database _db;
  static Store _students;
  static Store _schools;
  static Store _logRaw;
  static Store _logStudent;

  static Future<void> initializeDb() async {
    _db = await databaseFactoryIo.openDatabase(join("..", "..", dirname(Platform.script.toFilePath()), "main.db"));
    _students = _db.getStore('students');
    _schools = _db.getStore('schools');
    _logRaw = _db.getStore('logRaw');
    _logStudent = _db.getStore('logStudent');
  }

  static Future<List<String>> getSchools() async {
    return await _schools.records
        .map(
            (Record school) => school.value[school.value.keys.first].toString())
        .toList();
  }

  static Future<void> addSchool(String url) async {
    if ((await getSchools()).any((u) => u == url)) return;
    await _schools.put({'url': url});
  }

  /// Save student info into DB.
  /// Return access GUID.
  ///
  /// Once you retrieve more info, run this again.
  /// If the object `student` has the same `student.guid`,
  /// it's value in database will be updated.
  static Future<String> saveStudentInfo(ComplexStudent student) async {
    return await _students.put({'student': student.toJson()}, student.guid);
  }

  static Future updateStudentInfo(
      String guid, ComplexStudent updateStudent(ComplexStudent student)) async {
    await _db.transaction((txn) async {
      var studentsStore = txn.getStore('students');
      var student =
          ComplexStudent.fromJson((await studentsStore.getRecord(guid)).value['student']);
      student = updateStudent(student);
      await studentsStore.put({'student': student.toJson()}, guid);
    });
  }

  static Future<ComplexStudent> getStudent(String guid) async {
    var record = await _students
        .findRecord(Finder(filter: Filter.byKey(guid)));
    var value = record.value['student'];
    return ComplexStudent.fromJson(value);
  }

  static Future<void> logRawAccess(HttpRequest request, Browser browser) async {
    await _logRaw.put({
      'request': request.uri.toString(),
      'browser': browser.userAgent,
      'ip': request.connectionInfo.remoteAddress.toString(),
      'timestamp': DateTime.now().millisecondsSinceEpoch
    });
  }

  static Future<void> logLogin(
      Map<String, String> requestData, String studentGuid) async {
    await _logStudent.put({
      'data': requestData,
      'student': studentGuid,
      'timestamp': DateTime.now().millisecondsSinceEpoch
    });
  }
}
