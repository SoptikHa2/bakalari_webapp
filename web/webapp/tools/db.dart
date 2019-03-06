import 'dart:io';

import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:bakalari/definitions.dart';

import '../config.dart';
import '../model/complexStudent.dart';
import '../model/message.dart';
import './tools.dart';
import 'securityTools.dart';

/// Class that takes care of Database
class DB {
  static Database _db;
  static Store _students;
  static Store _logStudent;
  static Store _messages;
  static Store _schools;
  static Store _logAccess;

  static Future<void> initializeDb() async {
    _db = await databaseFactoryIo.openDatabase(Config.dbFileLocation);
    _students = _db.getStore('students'); // Students data
    _logStudent = _db.getStore('logStudent'); // Student login logs
    _messages = _db.getStore('messages'); // Messages sent to admin
    _schools = _db.getStore('schools'); // List of school names and URLs
    _logAccess = _db.getStore('logAccess'); // Anonymised access logs
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
    String encryptedContent = SecurityTools.encryptStudentData(
        Tools.fromMapToStringyJson(student.toJson()), key);
    return await _students.put({
      'student': encryptedContent,
      'timestamp': DateTime.now().millisecondsSinceEpoch.toString()
    }, student.guid);
  }

  static Future updateStudentInfo(String guid,
      ComplexStudent updateStudent(ComplexStudent student), String key) async {
    await _db.transaction((txn) async {
      var studentsStore = txn.getStore('students');
      var encryptedStudent =
          (await studentsStore.getRecord(guid)).value['student'];
      var decryptedStudent =
          SecurityTools.decryptStudentData(encryptedStudent, key);
      var student =
          ComplexStudent.fromJson(Tools.fromStringyJsonToMap(decryptedStudent));
      student = updateStudent(student);
      String encryptedContent = SecurityTools.encryptStudentData(
          Tools.fromMapToStringyJson(student.toJson()), key);
      await studentsStore.put({'student': encryptedContent}, guid);
    });
  }

  static Future<ComplexStudent> getStudent(String guid, String key) async {
    var record = await _students.findRecord(Finder(filter: Filter.byKey(guid)));
    var value = record.value['student'];
    var decryptedStudent = SecurityTools.decryptStudentData(value, key);
    return ComplexStudent.fromJson(
        Tools.fromStringyJsonToMap(decryptedStudent));
  }

  static Future<void> logAccess(HttpRequest request) async {
    await _logAccess.put({
      'IP':
          SecurityTools.obfuscateIpAddress(request.headers.value('X-Real-IP')),
      'timestamp': DateTime.now().millisecondsSinceEpoch
    });
  }

  static Future<void> logLogin(Student student, School school) async {
    await _logStudent.put({
      'studentClass': student.schoolClass,
      'school': school.name,
      'timestamp': DateTime.now().millisecondsSinceEpoch
    });
  }

  /// Returns: timestamp and number of logins for it (Numbers are grouped to days)
  static Future<Map<int, int>> getLogins(Duration maximumAge) async {
    var records = await _logStudent.findRecords(Finder(
        filter: Filter.greaterThanOrEquals('timestamp',
            DateTime.now().subtract(maximumAge).millisecondsSinceEpoch)));
    records.sort((r1, r2) =>
        (r1.value['timestamp'] as int).compareTo(r2.value['timestamp'] as int));
    var result = Map<int, int>();
    for (var record in records) {
      var key = record.value['timestamp'] as int;
      var today = DateTime.fromMillisecondsSinceEpoch(key);
      today = DateTime(today.year, today.month, today.day);
      if (result.containsKey(today.millisecondsSinceEpoch)) {
        result[today.millisecondsSinceEpoch]++;
      } else {
        result[today.millisecondsSinceEpoch] = 1;
      }
    }

    return result;
  }

  /// Returns: timestamp for day and number of unique accesses that day. (Numbers are grouped to days.)
  static Future<Map<int, int>> getUniqueDailyAccess(Duration maximumAge) async {
    var records = await _logAccess.findRecords(Finder(
        filter: Filter.greaterThanOrEquals('timestamp',
            DateTime.now().subtract(maximumAge).millisecondsSinceEpoch)));
    records.sort((r1, r2) =>
        (r1.value['timestamp'] as int).compareTo(r2.value['timestamp'] as int));
    var result = Map<int, int>();
    var usedIpAddresses = Map<int, List<String>>();
    for (var record in records) {
      var key = record.value['timestamp'] as int;
      var today = DateTime.fromMillisecondsSinceEpoch(key);
      today = DateTime(today.year, today.month, today.day);
      // Check for validity
      bool valid = true;
      if (usedIpAddresses.containsKey(today.millisecondsSinceEpoch)) {
        valid = !usedIpAddresses[today.millisecondsSinceEpoch]
            .contains(record['IP']);
      } else {
        usedIpAddresses[today.millisecondsSinceEpoch] = List<String>();
      }
      if (valid) {
        if (result.keys.contains(today.millisecondsSinceEpoch)) {
          result[today.millisecondsSinceEpoch]++;
        } else {
          result[today.millisecondsSinceEpoch] = 1;
        }
        usedIpAddresses[today.millisecondsSinceEpoch].add(record.value['IP']);
      }
    }

    return result;
  }

  static Future<void> purgeSavedData() async {
    // Purge student data
    await _db.transaction((txn) async {
      var studentsStore = txn.getStore('students');
      var recordsToDelete = (await _students.findRecords(Finder()))
          .map((r) => r.value['timestamp'])
          .where((s) => DateTime.fromMillisecondsSinceEpoch(s)
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
