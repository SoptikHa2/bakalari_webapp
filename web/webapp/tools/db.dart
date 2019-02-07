import 'dart:io';

import 'package:rikulo_commons/browser.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:bakalari/definitions.dart';

import '../config.dart';
import '../model/complexStudent.dart';
import '../model/message.dart';

/// Class that takes care of Database
class DB {
  static Database _db;
  static Store _students;
  static Store _logStudent;
  static Store _messages;

  static Future<void> initializeDb() async {
    _db = await databaseFactoryIo.openDatabase(Config.dbFileLocation);
    _students = _db.getStore('students'); // Students data
    _logStudent = _db.getStore('logStudent'); // Student login logs
    _messages = _db.getStore('messages'); // Messages sent to admin
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

  static Future<String> getMessagesInJson() async {
    var file = File(Config.dbFileLocation);
    var lines = await file.readAsLines().then((List<String> lines) =>
        lines.where((l) => l.contains(',"store":"messages","value":{')));
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

      if (students.containsKey(identifier)) {
        var savedRecord = students[identifier];
        if (savedRecord.refresh.isBefore(student.refresh)) {
          students[identifier] = student;
        }
      } else {
        students[identifier] = student;
      }
    }

    var studentsList = List<ComplexStudent>();
    for (var key in students.keys) {
      studentsList.add(students[key]);
    }

    return studentsList;
  }

  static Future<ComplexStudent> getLatestStudentBy(
      bool condition(ComplexStudent student)) async {
    var allStudents = (await _students.findRecords(Finder()))
        .map((r) => ComplexStudent.fromJson(r.value['student']))
        .where((s) => condition(s));
    DateTime last = null;
    ComplexStudent selectedStudent = null;
    for (var student in allStudents) {
      if (last == null || student.refresh.isAfter(last)) {
        last = student.refresh;
        selectedStudent = student;
      }
    }

    return selectedStudent;
  }

  static Future<Iterable<Message>> getAllMessages() async {
    var messages = (await _messages.findRecords(Finder()))
        .map((r) => Message.fromJson(r.value['message']));
    return messages;
  }

  static Future<Message> getOneMessage(String guid) async {
    return Message.fromJson(
        (await _messages.findRecord(Finder(filter: Filter.byKey(guid)))).value['message']);
  }

  static Future saveMessage(Message message) async {
    await _messages.put({'message': message.toJson()}, message.guid);
  }

  static Future markMessageAsDone(String guid) async {
    var message = await getOneMessage(guid);
    message.isClosed = true;
    await _messages.update({'message': message.toJson()}, guid);
  }
}
