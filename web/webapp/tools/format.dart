import 'package:bakalari/src/modules/gradeModule.dart';

/// This class takes various
/// formats and converts them.
class Format {
  static Map<String, double> gradesToSubjectAverages(List<Grade> grades) {
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
    return averages;
  }

  static double _average(List<double> list){
    double result = 0;
    for (var item in list) {
      result += item;
    }
    return result / list.length;
  }
}
