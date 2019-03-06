import 'dart:collection';
import 'dart:convert';

import 'package:bakalari/definitions.dart';

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
}

