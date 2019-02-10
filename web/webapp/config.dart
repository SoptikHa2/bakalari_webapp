import 'dart:io';

import 'package:path/path.dart';

import 'controller/admin/adminMessages.dart';
import 'controller/admin/godStudent.dart';
import 'controller/admin/log.dart';
import 'controller/contact.dart';
import 'controller/general.dart';
import 'controller/lubos.dart';
import 'controller/student/refreshStudentInfo.dart';
import 'controller/shutdown.dart';
import 'controller/student/timetable.dart';
import 'controller/tor.dart';
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
    "get:/": GeneralRootController.root,
    "get:/privacy_policy": privacyPolicyView,
    "get:/api": restApiView,
    "get:/logout": GeneralLogoutController.logoutUser,
    "get:/refresh": StudentRefreshInfoController.refresh,
    "get:/lubos": GeneralLubosController.showLubosCites,
    "get:/tor": GeneralTorController.showTorLandingPage,

    "post:/student": StudentBaseController.login,
    "get:/student": StudentBaseController.getInfo,
    "get:/student/subject": StudentSubjectController.getList,
    "get:/student/subject/(identifier:[^/]*)": StudentSubjectController.getSubject,
    "post:/student/json": StudentBaseController.loginJson,
    "get:/student/json": StudentBaseController.getInfoJson,
    "get:/student/timetable": StudentTimetableController.displayTimetables,

    "get:/contact": GeneralContactController.getContactPage,
    "post:/contact" : GeneralContactController.postContactPage,

    "get:/admin": AdminBaseController.adminRootPage,
    "get:/admin/login": AdminBaseController.loginForm,
    "get:/admin/logout": GeneralLogoutController.logoutAdmin,
    "get:/admin/log": AdminLogController.showLogPage,
    "get:/admin/god": AdminGodController.displayForm,
    "get:/admin/god/student": AdminGodController.displayStudent,
    "post:/admin": AdminBaseController.verify2FA,
    "post:/admin/shutdown": AdminBaseController.shutdownWebsite,
    "get:/admin/log/raw/download/(file:[^/]*)": AdminLogController.downloadRawLog,
    "get:/admin/message" : AdminMessagesController.getMessageList,
    "get:/admin/message/all": AdminMessagesController.getFullMessageList,
    "get:/admin/message/(guid:[^/]*)": AdminMessagesController.getOneMessage,
    "post:/admin/message/markAsRead/(guid:[^/]*)": AdminMessagesController.setAsCompleted,

    "get:/shutdown": GeneralShutdownController.showShutdown,
    "/.+/": GeneralBaseController.redirectToNoLeadingSlash,
    "/admin/purgeOldData/security/in/obscurity/5432058437104547123501":
        GeneralBaseController.purgeOldData,
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
