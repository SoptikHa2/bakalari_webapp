import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:bakalari/definitions.dart';
import 'package:uuid/uuid.dart';
import 'package:pointycastle/pointycastle.dart';
import 'package:encrypt/encrypt.dart';

import '../config.dart';
import '../model/complexStudent.dart';
import 'db.dart';

class Tools {
  static LinkedHashMap<String, double> gradesToSubjectAverages(
      List<Grade> grades, List<Subject> listOfSubjects) {
    // Custom groupby
    Map<String, List<double>> subjects = {};
    for (var grade in grades) {
      String subjectFullName = listOfSubjects
          .firstWhere((s) => s.subjectShort == grade.subject)
          .subjectLong;
      if (!subjects.containsKey(subjectFullName)) {
        subjects[subjectFullName] = new List<double>();
      }
      for (var i = 0; i < grade.weight; i++) {
        if (grade.numericValue != null)
          subjects[subjectFullName].add(grade.numericValue);
      }
    }
    var averages = Map<String, double>();
    for (var subject in subjects.keys) {
      averages[subject] = _average(subjects[subject]);
    }

    // Sort
    var sortedKeys = averages.keys.toList(growable: false)
      ..sort((k1, k2) => -(averages[k1].compareTo(averages[k2])));
    var sortedMap = new LinkedHashMap<String, double>.fromIterable(sortedKeys,
        key: (k) => k, value: (k) => averages[k]);
    return sortedMap;
  }

  static double _average(List<double> list) {
    double result = 0;
    for (var item in list) {
      result += item;
    }
    return result / list.length;
  }

  static String fromMapToStringyJson(Map<String, dynamic> json) {
    /*if (json == null) return 'null';
    String result = "{";
    for (var key in json.keys) {
      result += '"' + key.replaceAll('"', '\'') + '":';
      if (json[key].runtimeType == int || json[key].runtimeType == double) {
        result += json[key].toString();
      } else if (json[key].runtimeType == String) {
        result += '"' + json[key].toString().replaceAll('"', '\'') + '"';
      } else if (json[key].runtimeType == List<int>().runtimeType ||
          json[key].runtimeType == List<double>().runtimeType ||
          json[key].runtimeType == List<String>().runtimeType ||
          json[key].runtimeType == List<Map<String, dynamic>>().runtimeType) {
        result += fromListToStringyJson(json[key])
            .replaceAll('\n', '')
            .replaceAll('\r', '');
      } else {
        result += fromMapToStringyJson(json[key])
            .replaceAll('\n', '')
            .replaceAll('\r', '');
      }
      if (key != json.keys.last) {
        result += ",";
      }
    }
    return result + "}";*/
    return JsonEncoder().convert(json);
  }

  static String fromListToStringyJson(List<dynamic> json) {
    if (json == null) return 'null';
    String result = "[";
    for (var item in json) {
      if (item.runtimeType == int || item.runtimeType == double) {
        result += item.toString();
      } else if (item.runtimeType == String) {
        result += '"' + item.toString().replaceAll('"', '\'') + '"';
      } else if (item.runtimeType == List<int>().runtimeType ||
          item.runtimeType == List<double>().runtimeType ||
          item.runtimeType == List<String>().runtimeType ||
          item.runtimeType == List<Map<String, dynamic>>().runtimeType) {
        result += fromListToStringyJson(item)
            .replaceAll('\n', '')
            .replaceAll('\r', '');
      } else {
        result += fromMapToStringyJson(item)
            .replaceAll('\n', '')
            .replaceAll('\r', '');
      }

      if (item != json.last) result += ",";
    }
    return result + "]";
  }

  static Map<String, dynamic> fromStringyJsonToMap(String json) {
    return JsonDecoder().convert(json) as Map<String, dynamic>;
  }

  static T maxWhere<T>(Iterable<T> list, double score(T source)) {
    T value = null;
    double currentScore = double.negativeInfinity;
    for (var item in list) {
      double scoreOfThisItem = score(item);
      if (scoreOfThisItem >= currentScore) {
        currentScore = scoreOfThisItem;
        value = item;
      }
    }
    return value;
  }

  static Map<String, String> _cookieValueEncoding = {
    ",": "AAAAAAACARKAAAAAAAA",
    ".": "AAAAAAATECKAAAAAAAA",
    "|": "AAAAAAAPIPAAAAAAAA",
    ":": "AAAAAAADVOJTECKAAAAAAAA",
    ";": "AAAAAAASTREDNIKAAAAAAA",
    "@": "AAAAAAAZAVINACAAAAAAA",
    "#": "AAAAAAAKRIZEKAAAAAAA",
    "%": "AAAAAAAPROCENTOAAAAAAA",
    "&": "AAAAAAAAMPERAAAAAAA",
    "*": "AAAAAAAHVEZDICKAAAAAAAA",
    "(": "AAAAAAALZAVORKAAAAAAAA",
    ")": "AAAAAAAPZAVORKAAAAAAAA",
    " ": "AAAAAAAMEZERAAAAAAAA",
    "/": "AAAAAAALOMENOAAAAAAA",
    "=": "AAAAAAAROVNASEAAAAAAA",
    "ě": "AAAAAAAE1AAAAAAA",
    "š": "AAAAAAASAAAAAAA",
    "č": "AAAAAAACAAAAAAA",
    "ř": "AAAAAAARAAAAAAA",
    "ž": "AAAAAAAZAAAAAAA",
    "ý": "AAAAAAAYAAAAAAA",
    "á": "AAAAAAAAAAAAAAA",
    "í": "AAAAAAAIAAAAAAA",
    "é": "AAAAAAAE2AAAAAAA",
    "ů": "AAAAAAAU1AAAAAAA",
    "ú": "AAAAAAAU2AAAAAAA",
    "ä": "AAAAAAAAPAAAAAAA",
    "ö": "AAAAAAAOPAAAAAAA",
    "ü": "AAAAAAAUPAAAAAAA",
    "Ě": "AAAAAAAE1VAAAAAAA",
    "Š": "AAAAAAASVAAAAAAA",
    "Č": "AAAAAAACVAAAAAAA",
    "Ř": "AAAAAAARVAAAAAAA",
    "Ž": "AAAAAAAZVAAAAAAA",
    "Ý": "AAAAAAAYVAAAAAAA",
    "Á": "AAAAAAAAVAAAAAAA",
    "Í": "AAAAAAAIVAAAAAAA",
    "É": "AAAAAAAE2VAAAAAAA",
    "Ů": "AAAAAAAU1VAAAAAAA",
    "Ú": "AAAAAAAU2VAAAAAAA",
    "Ä": "AAAAAAAAPVAAAAAAA",
    "Ö": "AAAAAAAOPVAAAAAAA",
    "Ü": "AAAAAAAUPVAAAAAAA"
  };
  static String encodeCookieValue(String value) {
    String encoded = value;
    for (var key in _cookieValueEncoding.keys) {
      var value = _cookieValueEncoding[key];

      encoded = encoded.replaceAll(key, value);
    }
    return encoded;
  }

  static String decodeCookieValue(String value) {
    String encoded = value;
    for (var key in _cookieValueEncoding.keys) {
      var value = _cookieValueEncoding[key];

      encoded = encoded.replaceAll(value, key);
    }
    return encoded;
  }

  static String hoursToStringWithUnit(int hours) {
    if (hours == 0) return "$hours hodin";
    if (hours == 1) return "$hours hodina";
    if (hours <= 4) return "$hours hodiny";

    return "$hours hodin";
  }

  static String daysToStringWithUnit(int days) {
    if (days == 0) return "$days dní";
    if (days == 1) return "$days den";
    if (days <= 4) return "$days dny";

    return "$days dní";
  }

  static Future<LoginStatus> loginAsStudent(List<Cookie> cookies) async {
    if (!cookies.any((c) => c.name == "studentID")) {
      return LoginStatus(false, false, 'not_logged_in', null);
    }
    if(!cookies.any((c) => c.name == "encryptionKey")){
      return LoginStatus(false, true, "not_logged_in", null);
    }

    try {
      String guid = cookies.singleWhere((c) => c.name == 'studentID').value;
      String key = cookies.singleWhere((c) => c.name == 'encryptionKey').value;

      ComplexStudent student = await DB.getStudent(guid, key);
      return LoginStatus(true, false, '', student);
    } catch (e) {
      print(e);
      return LoginStatus(false, true, 'unknown', null);
    }
  }

  static Day whichDayShouldIShowInOneDayTimetable(
      Timetable timetable, Timetable nextWeekTimetable) {
    Day selectedDay = null;
    var now = DateTime.now();
    // Determine which day should one show in timetable
    if (now.weekday > timetable.days.length) {
      // Next week
      selectedDay = nextWeekTimetable.days[0];
    } else {
      // Something like 10:45
      var todayLatestHourEnd = timetable
          .days[now.weekday - 1].lessons.last.first.lessonTime.endTime
          .trim()
          .split(':');
      int todayLatestHourEnd_Hour = int.parse(todayLatestHourEnd[0]);
      int todayLatestHourEnd_Minute = int.parse(todayLatestHourEnd[0]);
      if (now.hour > todayLatestHourEnd_Hour ||
          (now.hour == todayLatestHourEnd_Hour &&
              now.minute >= todayLatestHourEnd_Minute)) {
        // Tomorrow
        if (now.weekday + 1 > timetable.days.length) {
          // Next week
          selectedDay = nextWeekTimetable.days[0];
        } else {
          selectedDay = timetable.days[now.weekday];
        }
      } else {
        // Today
        selectedDay = timetable.days[now.weekday - 1];
      }
    }
    return selectedDay;
  }

  /// Verify 2FA. If correct, return guid that can be used as proof that 2fa was successful.
  static String loginAsAdmin2FA(String twoFA) {
    if (Config.totp.verify(twoFA.replaceAll(' ', ''))) {
      String guid = Uuid().v4();
      Config.currentTwoFAtoken = guid;
      DateTime selectedDateTime = DateTime.now();
      selectedDateTime =
          selectedDateTime.add(Duration(minutes: Config.twoFAMinutesDuration));
      Config.currentTwoFAtokenValid = selectedDateTime;
      return guid;
    }
    return null;
  }

  static bool _verify2FAtoken(String twoFAguid) {
    if (Config.currentTwoFAtokenValid.isBefore(DateTime.now())) {
      Config.currentTwoFAtoken = null;
      return false;
    }
    if (Config.currentTwoFAtoken == twoFAguid) {
      return true;
    }
    return false;
  }

  static final Digest _sha256 = Digest("SHA-256");
  static String hashPassword(String password, String username) {
    return base64.encode(
        _sha256.process(utf8.encode(password + username + "dartlangislove")));
  }

  /// Verify username and password. twoFAguid has to be passed from cookie as proof that 2fa was successful.
  static AdminLoginStatus _verifyAsAdmin(
      String username, String password, String twoFAguid) {
    bool twoFACorrect = _verify2FAtoken(twoFAguid);
    if (!twoFACorrect) {
      return AdminLoginStatus.TwoFAIncorrect;
    } else {
      if (username == "Petr Šťastný" &&
          hashPassword(password, username) ==
              "wtkuDB/iOI3wkla2uvKTNJSdlal14yLZa8I6wfZB5z4=") {
        return AdminLoginStatus.OK;
      }
      return AdminLoginStatus.PasswordIncorrect;
    }
  }

  static AdminLoginStatus verifyAsAdmin(
      String authHeaderValue, String twoFAguid) {
    var nameColonPassword = authHeaderValue.replaceFirst('Basic ', '');
    var unbase64ed = utf8.decode(base64.decode(nameColonPassword));
    var username = unbase64ed.split(':')[0];
    var password = unbase64ed.split(':')[1];

    return _verifyAsAdmin(username, password, twoFAguid);
  }

  /// Take string, remove diacritics, set to uppercase and return
  static String normalizeString(String str) {
    str = str.toLowerCase();
    String diacritics = 'ěščřžýáíéůúóöäëü';
    String normalChars = 'escrzyaieuuooaeu';
    str = str.trim();
    for (var i = 0; i < diacritics.length; i++) {
      str = str.replaceAll(diacritics[i], normalChars[i]);
    }
    return str;
  }

  static String encryptStudentData(String data, String key) {
    // Truncate key to 32 characters
    if (key.length < 32) {
      throw new ArgumentError(
          "Error: encryptStudentData: Key needs to be at least 32 characters long. Key was ${key.length} characters long.");
    }
    key = key.substring(0, 32);

    final encKey = Key.fromUtf8(key);
    final iv = IV.fromLength(16);

    final encrypter = Encrypter(AES(encKey, iv));

    return encrypter.encrypt(data).base64;
  }

  static String decryptStudentData(String data, String key) {
    final encKey = Key.fromUtf8(key);
    final iv = IV.fromLength(16);

    final encrypter = Encrypter(AES(encKey, iv));

    return encrypter.decrypt(Encrypted.fromBase64(data));
  }

  static String generateEncryptionKey([int length = 32]) {
    String key = "";
    var rand = Random.secure();
    for (var i = 0; i < length; i++) {
      var secureInteger = rand.nextInt(50);
      if (secureInteger < 25) {
        key += String.fromCharCode(secureInteger + 97);
      } else {
        key += String.fromCharCode((secureInteger % 25) + 65);
      }
    }
    return key;
  }
}

class LoginStatus {
  bool success;
  bool requestLogout;
  String errorMessage;
  ComplexStudent result;

  LoginStatus(this.success, this.requestLogout, this.errorMessage, this.result);
}

enum AdminLoginStatus { OK, TwoFAIncorrect, PasswordIncorrect }
