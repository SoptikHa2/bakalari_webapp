import 'dart:collection';

import 'package:stream/stream.dart';

import '../model/complexStudent.dart';
import '../tools/tools.dart';
import '../view/student/subjectListView.rsp.dart';

/// This controllers handles both
/// one subject details lookup
/// and subject list
/// 
/// /student/subject -> display subject list
/// /student/subject/XX -> display subject XX
class Subject {
  static Future getList(HttpConnect connect) async{
    var result = await Tools.loginAsStudent(connect.request.cookies);
    ComplexStudent student = null;
    if (result.success) {
      student = result.result;
    }else{
      if(result.requestLogout){
        return connect.redirect('/logout');
      }else{
        return connect.redirect('/?error=not_logged_in');
      }
    }

    Map<String, double> averages = null;
    if (student.grades != null) {
      averages = Tools.gradesToSubjectAverages(student.grades);
    }
    var sortedKeys = averages.keys.toList(growable: false)
      ..sort((k1, k2) => student.subjects.indexWhere((s) => s.subjectShort == k1).compareTo(student.subjects.indexWhere((s) => s.subjectShort == k2)));
    var sortedAverages = new LinkedHashMap<String, double>.fromIterable(sortedKeys,
        key: (k) => k, value: (k) => averages[k]);

    return subjectListView(connect, subjects: student.subjects, grades: sortedAverages.values.toList());
  }

  static void getSubject(HttpConnect connect){
    String identifier = connect.dataset['identifier'];

  }
}
