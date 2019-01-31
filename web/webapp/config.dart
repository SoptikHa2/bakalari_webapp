import 'dart:io';

import 'package:path/path.dart';

import 'controller/admin/godStudent.dart';
import 'controller/admin/log.dart';
import 'controller/contact.dart';
import 'controller/general.dart';
import 'controller/lubos.dart';
import 'controller/student/refreshStudentInfo.dart';
import 'controller/shutdown.dart';
import 'tools/filter.dart';
import 'controller/root.dart';
import 'controller/student/student.dart';
import 'controller/logout.dart';
import 'controller/student/subject.dart';
import 'controller/admin/admin.dart';
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
    "get:/lubos": Lubos.showLubosCites,

    "post:/student": Student.login,
    "get:/student": Student.getInfo,
    "get:/student/subject": Subject.getList,
    "get:/student/subject/(identifier:[^/]*)": Subject.getSubject,
    "post:/student/json": Student.loginJson,
    "get:/student/json": Student.getInfoJson,

    "get:/contact": Contact.getContactPage,

    "get:/admin": Admin.adminRootPage,
    "get:/admin/login": Admin.loginForm,
    "get:/admin/logout": Logout.logoutAdmin,
    "get:/admin/log": Log.showLogPage,
    "get:/admin/god": GodStudent.displayForm,
    "get:/admin/god/student": GodStudent.displayStudent,
    "post:/admin": Admin.verify2FA,
    "post:/admin/shutdown": Admin.shutdownWebsite,
    "get:/admin/log/raw/download/(file:[^/]*)": Log.downloadRawLog,

    "get:/shutdown": Shutdown.showShutdown,
    "/.+/": General.redirectToNoLeadingSlash,
    "/admin/purgeOldData/security/in/obscurity/5432058437104547123501":
        General.purgeOldData,
  };
  static final filterRouting = {
    "/.*": Filter.process,
  };
  static final errorRouting = {
    "404": "/html/404.html",
    "451": "/html/451.html",
    "500": "/html/500.html"
  };

  static const int hoursUntilRefreshButtonIsShown = 8;
  static const int daysHowLongIsSessionCookieStored = 7;
  static const int daysHowLongIsRawLoginLogStored = 3;
  static const int daysHowLongIsClassIdentifierCookieStored = 365;
  static const int twoFAMinutesDuration = 10;
  static const int unsuccessfulLoginThreshold = 5;
  static final String dbFileLocation = join(dirname(Platform.script.toFilePath()), "main.db");
  static final TOTP totp = TOTP("NEOFBAKALARIADMIN");

  static String currentTwoFAtoken = null;
  static DateTime currentTwoFAtokenValid = DateTime.now();
  // When unsuccessful 2fa occurs, lock down admin account until next 2FA
  // code is generated (which is every 30 seconds)
  static DateTime last2FAattempt = null;
  // When $unsuccessfulLoginThreshold admin logins in a row failed,
  // request new 2FA auth. This is more than enough to stop
  // bruteforcing, as 2FA login can be attempted just once
  // every 30 seconds.
  static int unsuccessfulAdminLoginsInARow = 0;

  static ShutdownTemplate siteShutdownType = ShutdownTemplate.None;
  static String siteShutdownReason;
}

enum ShutdownTemplate { None, TemplateEmpty, Template451 }
