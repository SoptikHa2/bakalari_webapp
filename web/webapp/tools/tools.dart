import 'dart:collection';
import 'package:bakalari/src/modules/gradeModule.dart';

class Tools {
  static LinkedHashMap<String, double> gradesToSubjectAverages(
      List<Grade> grades) {
    // Custom groupby
    Map<String, List<double>> subjects = {};
    for (var grade in grades) {
      if (!subjects.containsKey(grade.subject)) {
        subjects[grade.subject] = new List<double>();
      }
      for (var i = 0; i < grade.weight; i++) {
        subjects[grade.subject].add(grade.value);
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
    if (json == null) return 'null';
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
    return result + "}";
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
}
