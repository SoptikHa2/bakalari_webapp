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
  static Future getList(HttpConnect connect) async {
    var result = await Tools.loginAsStudent(connect.request.cookies);
    ComplexStudent student = null;
    if (result.success) {
      student = result.result;
    } else {
      if (result.requestLogout) {
        return connect.redirect('/logout');
      } else {
        return connect.redirect('/?error=not_logged_in');
      }
    }

    Map<String, double> averages = null;
    if (student.grades != null && student.subjects != null) {
      averages =
          Tools.gradesToSubjectAverages(student.grades, student.subjects);
    }

    return subjectListView(connect,
        subjects: student.subjects, grades: averages);
  }

  static Future getSubject(HttpConnect connect) async {
    String identifier = Uri.decodeComponent(connect.dataset['identifier']);
    var result = await Tools.loginAsStudent(connect.request.cookies);
    ComplexStudent student = null;
    if (result.success) {
      student = result.result;
    } else {
      if (result.requestLogout) {
        return connect.redirect('/logout');
      } else {
        return connect.redirect('/?error=not_logged_in');
      }
    }
    if (!student.subjects.any((s) => s.subjectLong == identifier)) {
      throw new Http404(connect.request.uri.toString());
    }

    Map<String, double> averages = null;
    if (student.grades != null && student.subjects != null) {
      averages =
          Tools.gradesToSubjectAverages(student.grades, student.subjects);
    }

    var sub = student.subjects.firstWhere((s) => s.subjectLong == identifier);
    String prumer = "-";
    if (averages.containsKey(sub.subjectLong)) {
      prumer = averages[sub.subjectLong].toStringAsFixed(2);
    }
    return subjectDetailsView(connect,
        subject: sub,
        grades: student.grades.where((g) => g.subject == sub.subjectShort),
        prumer: prumer);
  }
}
