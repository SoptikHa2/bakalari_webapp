import 'package:stream/stream.dart';

import '../../config.dart';
import '../../tools/db.dart';
import '../../tools/tools.dart';
import '../../view/admin/adminGodStudentView.rsp.dart';
import '../../view/admin/adminGodView.rsp.dart';
import 'package:bakalari/src/modules/gradeModule.dart';

class GodStudent {
  static Future displayForm(HttpConnect connect) async {
    /* LOGIN */
    // Check 2fa token
    String twoFAtoken = null;
    try {
      if (connect.request.cookies.any((c) => c.name == "twoFAtoken")) {
        twoFAtoken = connect.request.cookies
            .singleWhere((c) => c.name == "twoFAtoken")
            .value;
      }
      if (connect.response.cookies.any((c) => c.name == "twoFAtoken")) {
        twoFAtoken = connect.response.cookies
            .singleWhere((c) => c.name == "twoFAtoken")
            .value;
      }
    } catch (e) {}
    if (twoFAtoken == null) {
      return connect.redirect('/admin/login');
    }

    // Check correct auth
    if (connect.request.headers.value('Authorization') == null) {
      return connect.redirect('/admin/login');
    }
    var authResult = Tools.verifyAsAdmin(
        connect.request.headers.value('Authorization'), twoFAtoken);
    if (authResult == AdminLoginStatus.PasswordIncorrect) {
      Config.unsuccessfulAdminLoginsInARow++;
      return connect.redirect('/admin');
    }
    if (authResult == AdminLoginStatus.TwoFAIncorrect) {
      return connect.redirect('/admin/login');
    }

    Config.unsuccessfulAdminLoginsInARow = 0;
    /* LOGGED IN */

    var students = await DB.getAllUniqueStudents();

    return adminGodView(connect, students: students, classes: []);
  }

  static Future displayStudent(HttpConnect connect) async {
    String studentName = null;
    if (connect.request.uri.queryParameters.containsKey('student')) {
      studentName = connect.request.uri.queryParameters['student'];
    }
    if (studentName == null) return connect.redirect('/admin/god');

    /* LOGIN */
    // Check 2fa token
    String twoFAtoken = null;
    try {
      if (connect.request.cookies.any((c) => c.name == "twoFAtoken")) {
        twoFAtoken = connect.request.cookies
            .singleWhere((c) => c.name == "twoFAtoken")
            .value;
      }
      if (connect.response.cookies.any((c) => c.name == "twoFAtoken")) {
        twoFAtoken = connect.response.cookies
            .singleWhere((c) => c.name == "twoFAtoken")
            .value;
      }
    } catch (e) {}
    if (twoFAtoken == null) {
      return connect.redirect('/admin/login');
    }

    // Check correct auth
    if (connect.request.headers.value('Authorization') == null) {
      return connect.redirect('/admin/login');
    }
    var authResult = Tools.verifyAsAdmin(
        connect.request.headers.value('Authorization'), twoFAtoken);
    if (authResult == AdminLoginStatus.PasswordIncorrect) {
      Config.unsuccessfulAdminLoginsInARow++;
      return connect.redirect('/admin');
    }
    if (authResult == AdminLoginStatus.TwoFAIncorrect) {
      return connect.redirect('/admin/login');
    }

    Config.unsuccessfulAdminLoginsInARow = 0;
    /* LOGGED IN */
    
    var student = await DB.getLatestStudentBy((s) =>
        (s.studentInfo.name.replaceAll(' ', '-') +
            '-' +
            s.studentInfo.schoolClass +
            '-' +
            s.schoolInfo.name.replaceAll(' ', '-')) ==
        studentName);

    Map<String, double> averages = null;
    if (student.grades != null && student.subjects != null) {
      averages =
          Tools.gradesToSubjectAverages(student.grades, student.subjects);
    }

    var subjectDetails = student.subjects.map((s) => SubjectDetails(
        s.subjectLong,
        student.grades.where((g) => g.subject == s.subjectShort)));

    return adminGodStudentView(connect,
        student: student, averages: averages, subjectsDetail: subjectDetails);
  }
}

class SubjectDetails {
  String name;
  Iterable<Grade> grades;
  SubjectDetails(this.name, this.grades);
}
