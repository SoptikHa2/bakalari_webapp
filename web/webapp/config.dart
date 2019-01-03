import 'controller/refreshStudentInfo.dart';
import 'tools/log.dart';
import 'controller/root.dart';
import 'controller/student.dart';
import 'controller/logout.dart';
import 'controller/subject.dart';
import 'view/general/privacyPolicyView.rsp.dart';
import 'view/general/restApi.rsp.dart';

class Config {
  static Map<String, dynamic> routing = {
    "get:/": Root.root,
    "get:/privacy_policy": privacyPolicyView,
    "get:/api": restApiView,
    "get:/logout": Logout.logoutUser,
    "get:/refresh": RefreshStudentInfo.refresh,

    "post:/student": Student.login,
    "get:/student": Student.getInfo,
    "get:/student/subject" : Subject.getList,
    "get:/student/subject/(identifier:[^/]*)" : Subject.getSubject,
    //"/admin/": admin

    "post:/student/json": Student.loginJson,
    "get:/student/json": Student.getInfoJson,
  };
  static dynamic filterRouting = {
    "/.*": log,
  };
  static Map<String, dynamic> errorRouting = {
    "404": "/html/404.html",
    "451": "/html/451.html",
    "500": "/html/500.html"
  };

  static int hoursUntilRefreshButtonIsShown = 12;
  static int daysHowLongIsSessionCookieStored = 7;
  static int daysHowLongIsClassIdentifierCookieStored = 365;
}
