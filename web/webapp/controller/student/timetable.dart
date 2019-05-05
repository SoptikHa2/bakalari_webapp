import 'package:stream/stream.dart';

import '../../model/complexStudent.dart';
import '../../tools/securityTools.dart';
import '../../view/student/timetableView.rsp.dart';

class StudentTimetableController {
  static Future displayTimetables(HttpConnect connect) async {
    var result = await SecurityTools.loginAsStudent(connect.request.cookies);
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

    var timetable = student.timetable;
    var nextWeekTimetable = student.nextWeekTimetable;
    var permanentTimetable = student.permTimetable;

    return timetableView(connect,
        nextWeekTimetable: nextWeekTimetable,
        permanentTimetable: permanentTimetable,
        timetable: timetable);
  }
}
