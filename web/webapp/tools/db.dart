import 'dart:io';

import 'package:rikulo_commons/browser.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:bakalari/definitions.dart';

import '../config.dart';
import '../model/complexStudent.dart';

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
    lines = lines.toList(growable: false);
    var result = '[';
    for (var line in lines) {
      result += line;
      if (line != lines.last) result += ',';
    }
    return result + ']';
  }

  static Future<String> getStudentsInJson() async {
    var file = File(Config.dbFileLocation);
    var lines = await file.readAsLines().then((List<String> lines) =>
        lines.where((l) => l.contains(',"store":"students","value":{')));
    lines = lines.toList(growable: false);
    var result = '[';
    for (var line in lines) {
      result += line;
      if (line != lines.last) result += ',';
    }
    return result + ']';
  }

  static Future<String> getStudentLoginLogsInJson() async {
    var file = File(Config.dbFileLocation);
    var lines = await file.readAsLines().then((List<String> lines) =>
        lines.where((l) => l.contains(',"store":"logStudent","value":{')));
    lines = lines.toList(growable: false);
    var result = '[';
    for (var line in lines) {
      result += line;
      if (line != lines.last) result += ',';
    }
    return result + ']';
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

  static Future<void> logRawAccess(HttpRequest request, Browser browser) async {
    await _logRaw.put({
      'request': request.uri.toString(),
      'browser': browser.userAgent,
      'ip': request.headers.value('X-Real-IP'),
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

  static Future<void> purgeSavedData() async {
    // Purge student data
    await _db.transaction((txn) async {
      var studentsStore = txn.getStore('students');
      var recordsToDelete = (await _students.findRecords(Finder()))
          .map((r) => ComplexStudent.fromJson(r.value['student']))
          .where((s) => s.refresh
              .add(Duration(days: Config.daysHowLongIsSessionCookieStored))
              .isBefore(DateTime.now()));
      studentsStore.deleteAll(recordsToDelete.map((s) => s.guid));
      print(
          '${DateTime.now().toIso8601String()}:Purged ${recordsToDelete.length} students from cache');
    });

    // Purge raw log
    await _db.transaction((txn) async {
      var rawLogStore = txn.getStore('logRaw');
      var recordsToDelete = (await _logRaw.findRecords(Finder()))
          .where((r) => DateTime.fromMillisecondsSinceEpoch(
                  int.parse(r.value['timestamp']))
              .isBefore(DateTime.now()
                  .add(Duration(days: Config.daysHowLongIsRawLoginLogStored))))
          .map((r) => r.key);
      rawLogStore.deleteAll(recordsToDelete);
      print(
          '${DateTime.now().toIso8601String()}:Purged ${await rawLogStore.count()} logs from cache');
    });
  }

  static Future<List<ComplexStudent>> getAllUniqueStudents() async {
    var allStudents = (await _students.findRecords(Finder()))
        .map((r) => ComplexStudent.fromJson(r.value['student']));
    var students = Map<String, ComplexStudent>();
    for (var student in allStudents) {
      String identifier = student.studentInfo.name +
          ':' +
          student.studentInfo.schoolClass +
          ':' +
          student.schoolInfo.name;
      
      if(students.containsKey(identifier)){
        var savedRecord = students[identifier];
        if(savedRecord.refresh.isBefore(student.refresh)){
          students[identifier] = student;
        }
      }else{
        students[identifier] = student;
      }
    }

    var studentsList = List<ComplexStudent>();
    for (var key in students.keys) {
      studentsList.add(students[key]);
    }

    return studentsList;
  }

  static Future<ComplexStudent> getLatestStudentBy(bool condition(ComplexStudent student)) async {
    var allStudents = (await _students.findRecords(Finder()))
        .map((r) => ComplexStudent.fromJson(r.value['student']))
        .where((s) => condition(s));
    DateTime last = null;
    ComplexStudent selectedStudent = null;
    for (var student in allStudents) {
      if(last == null || student.refresh.isAfter(last)){
        last = student.refresh;
        selectedStudent = student;
      }
    }

    return selectedStudent;
  }
}
