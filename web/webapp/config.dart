import 'controller/refreshStudentInfo.dart';
import 'controller/shutdown.dart';
import 'tools/filter.dart';
import 'controller/root.dart';
import 'controller/student.dart';
import 'controller/logout.dart';
import 'controller/subject.dart';
import 'controller/admin.dart';
import 'view/general/privacyPolicyView.rsp.dart';
import 'view/general/restApi.rsp.dart';

import 'package:dotp/dotp.dart';

class Config {
  static final routing = {
    "get:/": Root.root,
    "get:/privacy_policy": privacyPolicyView,
    "get:/api": restApiView,
    "get:/logout": Logout.logoutUser,
    "get:/refresh": RefreshStudentInfo.refresh,

    "post:/student": Student.login,
    "get:/student": Student.getInfo,
    "get:/student/subject" : Subject.getList,
    "get:/student/subject/(identifier:[^/]*)" : Subject.getSubject,

    "post:/student/json": Student.loginJson,
    "get:/student/json": Student.getInfoJson,

    "get:/admin": Admin.adminRootPage,
    "get:/admin/login": Admin.loginForm,
    "get:/admin/logout": Logout.logoutAdmin,
    "post:/admin": Admin.verify2FA,
    "post:/admin/shutdown": Admin.shutdownWebsite,

    "get:/shutdown": Shutdown.showShutdown,
  };
  static final filterRouting = {
    "/.*": Filter.process,
  };
  static final errorRouting = {
    "404": "/html/404.html",
    "451": "/html/451.html",
    "500": "/html/500.html"
  };

  static final int hoursUntilRefreshButtonIsShown = 12;
  static final int daysHowLongIsSessionCookieStored = 7;
  static final int daysHowLongIsClassIdentifierCookieStored = 365;

  static final TOTP totp = TOTP("NEOFBAKALARIADMIN");
  static final int twoFAMinutesDuration = 10;
  static String currentTwoFAtoken = null;
  static DateTime currentTwoFAtokenValid = DateTime.now();

  static ShutdownTemplate siteShutdownType = ShutdownTemplate.None;
  static String siteShutdownReason;
}

enum ShutdownTemplate{
  None,
  TemplateEmpty,
  Template451
}