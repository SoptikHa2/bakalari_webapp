import 'dart:collection';

import 'package:stream/stream.dart';

import '../../model/complexStudent.dart';
import '../../tools/tools.dart';
import '../../view/student/subjectDetails.rsp.dart';
import '../../view/student/subjectListView.rsp.dart';

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
    Map<String, double> longTextAverages = Map<String, double>();
    for (var key in averages.keys) {
      var newKey = student.subjects.singleWhere((s) => s.subjectShort == key);
      var value = averages[key];
      longTextAverages[newKey.subjectLong] = value;
    }

    return subjectListView(connect, subjects: student.subjects, grades: longTextAverages);
  }

  static Future getSubject(HttpConnect connect) async{
    String identifier = Uri.decodeComponent(connect.dataset['identifier']);
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
    if(!student.subjects.any((s) => s.subjectShort == identifier)){
      throw new Http404(connect.request.uri.toString());
    }
    var sub = student.subjects.singleWhere((s) => s.subjectShort == identifier);
    return subjectDetailsView(connect, subject: sub, grades: student.grades.where((g) => g.subject == sub.subjectShort));
  }
}
