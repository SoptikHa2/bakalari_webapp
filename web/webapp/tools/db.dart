import 'dart:io';

import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:bakalari/definitions.dart';

import '../config.dart';
import '../model/complexStudent.dart';
import '../model/message.dart';
import './tools.dart';

/// Class that takes care of Database
class DB {
  static Database _db;
  static Store _students;
  static Store _logStudent;
  static Store _messages;
  static Store _schools;

  static Future<void> initializeDb() async {
    _db = await databaseFactoryIo.openDatabase(Config.dbFileLocation);
    _students = _db.getStore('students'); // Students data
    _logStudent = _db.getStore('logStudent'); // Student login logs
    _messages = _db.getStore('messages'); // Messages sent to admin
    _schools = _db.getStore('schools');
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
  static Future<String> saveStudentInfo(
      ComplexStudent student, String key) async {
    String encryptedContent = Tools.encryptStudentData(
        Tools.fromMapToStringyJson(student.toJson()), key);
    return await _students.put({'student': encryptedContent}, student.guid);
  }

  static Future updateStudentInfo(String guid,
      ComplexStudent updateStudent(ComplexStudent student), String key) async {
    await _db.transaction((txn) async {
      var studentsStore = txn.getStore('students');
      var encryptedStudent =
          (await studentsStore.getRecord(guid)).value['student'];
      var decryptedStudent = Tools.decryptStudentData(encryptedStudent, key);
      var student =
          ComplexStudent.fromJson(Tools.fromStringyJsonToMap(decryptedStudent));
      student = updateStudent(student);
      String encryptedContent = Tools.encryptStudentData(
          Tools.fromMapToStringyJson(student.toJson()), key);
      await studentsStore.put({'student': encryptedContent}, guid);
    });
  }

  static Future<ComplexStudent> getStudent(String guid, String key) async {
    var record = await _students.findRecord(Finder(filter: Filter.byKey(guid)));
    var value = record.value['student'];
    var decryptedStudent = Tools.decryptStudentData(value, key);
    return ComplexStudent.fromJson(
        Tools.fromStringyJsonToMap(decryptedStudent));
  }

  static Future<void> logLogin(
      Student student, School school, String studentGuid) async {
    await _logStudent.put({
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

  static Future<Iterable<Message>> getAllMessages() async {
    var messages = (await _messages.findRecords(Finder()))
        .map((r) => Message.fromJson(r.value['message']));
    return messages;
  }

  static Future<Message> getOneMessage(String guid) async {
    return Message.fromJson(
        (await _messages.findRecord(Finder(filter: Filter.byKey(guid))))
            .value['message']);
  }

  static Future saveMessage(Message message) async {
    await _messages.put({'message': message.toJson()}, message.guid);
  }

  static Future markMessageAsDone(String guid) async {
    var message = await getOneMessage(guid);
    message.isClosed = true;
    await _messages.update({'message': message.toJson()}, guid);
  }

  static Future updateSchoolInfoDB(
      Map<String, String> schoolNamesAndUrls) async {
    await _schools.clear();
    for (var key in schoolNamesAndUrls.keys) {
      var value = schoolNamesAndUrls[key];

      await _schools.put(value, key);
    }
  }

  /// Takes list of words to match, normalizes it, and searches for schools from list
  static Future<Iterable<String>> getSchoolInfoFromQuery(
      List<String> wordsToMatch) async {
    var allRecords = _schools.findRecords(Finder());
    var filteredRecords = allRecords.then((l) => l.where((r) =>
        wordsToMatch
            .where((w) => Tools.normalizeString(r.key.toString())
                .contains(Tools.normalizeString(w)))
            .length ==
        wordsToMatch.length));
    var mappedLines = filteredRecords
        .then((l) => l.map((r) => (r.key + '``````' + r.value).toString()));
    return mappedLines;
  }
}
