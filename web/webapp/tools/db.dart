import 'dart:io';
import 'dart:convert';

import 'package:path/path.dart';
import 'package:rikulo_commons/browser.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:bakalari/src/school.dart';
import 'package:bakalari/src/student.dart';
import '../config.dart';
import '../model/complexStudent.dart';
import 'tools.dart';

/// Class that takes care of Database
class DB {
  static Database _db;
  static Store _students;
  static Store _schools;
  static Store _logRaw;
  static Store _logStudent;

  static Future<void> initializeDb() async {
    _db = await databaseFactoryIo.openDatabase(Config.dbFileLocation);
    _students = _db.getStore('students'); // Students data
    _schools = _db.getStore('schools'); // List of schools [obsolete]
    _logRaw = _db.getStore('logRaw'); // Raw access logs
    _logStudent = _db.getStore('logStudent'); // Student login logs
  }

  static Future<String> getLogRawInJson() async {
    var file = File(Config.dbFileLocation);
    var lines = await file.readAsLines().then((List<String> lines) =>
        lines.where((l) => l.contains(',"store":"logRaw","value":{')));
    return jsonEncode(lines.toList(growable: false));
  }

  static Future<String> getStudentsInJson() async {
    var file = File(Config.dbFileLocation);
    var lines = await file.readAsLines().then((List<String> lines) =>
        lines.where((l) => l.contains(',"store":"students","value":{')));
    return jsonEncode(lines.toList(growable: false));
  }

  static Future<String> getStudentLoginLogsInJson() async {
    var file = File(Config.dbFileLocation);
    var lines = await file.readAsLines().then((List<String> lines) =>
        lines.where((l) => l.contains(',"store":"logStudent","value":{')));
    return jsonEncode(lines.toList(growable: false));
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
      var student = ComplexStudent.fromJson(
          (await studentsStore.getRecord(guid)).value['student']);
      student = updateStudent(student);
      await studentsStore.put({'student': student.toJson()}, guid);
    });
  }

  static Future<ComplexStudent> getStudent(String guid) async {
    var record = await _students.findRecord(Finder(filter: Filter.byKey(guid)));
    var value = record.value['student'];
    return ComplexStudent.fromJson(value);
  }

  static Future<ComplexStudent> getLatestStudent(
      String school, String studentClass) async {
    var records = (await _students.findRecords(Finder()))
        .map((r) => ComplexStudent.fromJson(r.value['student']));
    //(await _students.findRecords(Finder(filter: Filter.matchesRegExp('student', RegExp(r'^.*' + RegExp.escape(school) + r'.*' + RegExp.escape(studentClass) + r'.*$'))))).map((r) => ComplexStudent.fromJson(r.value['student']));
    return Tools.maxWhere<ComplexStudent>(
        records, (r) => r.refresh.millisecondsSinceEpoch.toDouble());
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
      Student student, School school, String studentGuid) async {
    await _logStudent.put({
      'studentName': student.name,
      'studentClass': student.schoolClass,
      'school': school.name,
      'studentGuid': studentGuid,
      'timestamp': DateTime.now().millisecondsSinceEpoch
    });
  }

  static Future<void> purgeSavedStudents(
      [int timeInDaysToKeep = Config.daysHowLongIsSessionCookieStored]) async {
    await _db.transaction((txn) async {
      var studentsStore = txn.getStore('students');
      var recordsToDelete = (await _students.findRecords(Finder()))
          .map((r) => ComplexStudent.fromJson(r.value['student']))
          .where((s) => s.refresh
              .add(Duration(days: timeInDaysToKeep))
              .isBefore(DateTime.now()));
      studentsStore.deleteAll(recordsToDelete.map((s) => s.guid));
      print('Purged ${recordsToDelete.length} students from cache');
    });
  }
}
