import 'dart:io';

import 'package:path/path.dart';
import 'package:intl/intl.dart';
import 'package:dotp/dotp.dart';

import 'controller/admin/adminMessages.dart';
import 'controller/admin/adminLog.dart';
import 'controller/contact.dart';
import 'controller/general.dart';
import 'controller/schoolList.dart';
import 'controller/student/message.dart';
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
import 'tools/listOfSchools.dart';
import 'view/general/privacyPolicyView.rsp.dart';
import 'view/general/restApi.rsp.dart';
import 'secret.dart';

class Config {
  static final routing = {
    "get:/": GeneralRootController.root,
    "get:/privacy_policy": privacyPolicyView,
    "get:/api": restApiView,
    "get:/logout": GeneralLogoutController.logoutUser,
    "get:/tor": GeneralTorController.showTorLandingPage,
    "post:/student": StudentBaseController.login,
    "get:/student": StudentBaseController.getInfo,
    "get:/student/subject": StudentSubjectController.getList,
    "get:/student/subject/(identifier:[^/]*)":
        StudentSubjectController.getSubject,
    "get:/student/message": StudentMessageController.getList,
    "get:/student/message/(identifier:[^/]*)":
        StudentMessageController.getMessage,
    "get:/student/timetable": StudentTimetableController.displayTimetables,
    "get:/student/refresh": StudentRefreshInfoController.refresh,
    "get:/schoolList.csv": SchoolListController.returnSchoolListInCsvByQuery,
    "get:/contact": GeneralContactController.getContactPage,
    "post:/contact": GeneralContactController.postContactPage,
    "get:/admin": AdminBaseController.adminRootPage,
    "get:/admin/login": AdminBaseController.loginForm,
    "get:/admin/log": AdminLogController.showLogPage,
    "post:/admin": AdminBaseController.verify2FA,
    "post:/admin/shutdown": AdminBaseController.shutdownWebsite,
    "get:/admin/log/raw/download/(file:[^/]*)":
        AdminLogController.downloadRawLog,
    "get:/admin/message": AdminMessagesController.getMessageList,
    "get:/admin/message/all": AdminMessagesController.getFullMessageList,
    "get:/admin/message/(guid:[^/]*)": AdminMessagesController.getOneMessage,
    "post:/admin/message/markAsRead/(guid:[^/]*)":
        AdminMessagesController.setAsCompleted,
    "get:/shutdown": GeneralShutdownController.showShutdown,
    "/.+/": GeneralBaseController.redirectToNoLeadingSlash,
    Secret.purgeConfigUrl: GeneralBaseController.purgeOldData,
    Secret.updateSchoolUrl: ListOfSchools.updateListOfSchools,
  };
  static final filterRouting = {
    "/.*": Filter.process,
  };
  static final errorRouting = {
    "404": "/html/404.html",
    "451": "/html/451.html",
    "500": "/html/500.html"
  };

  static final dateFormat = DateFormat('dd.MM.yyyy HH:mm');

  /// When user starts typing school name, some schools with
  /// simmilar name will be displayed to user. This controls
  /// how many of them will be displayed.
  static const int numberOfSchoolsInListSearch = 5;

  /// How long wait until refresh button on main page is shown.
  /// If user was last logged in more than X hours, there will
  /// be big annoying button telling him to refresh.
  /// TOOD: Automate this, we might save password hash in localstorage
  static const int hoursUntilRefreshButtonIsShown = 8;

  /// User will be logged out after X days
  static const int daysHowLongIsSessionCookieStored = 7;

  /// How long will be username stored after last login, so user
  /// doesn't have to input it again and again
  static const int daysHowLongIsClassIdentifierCookieStored = 365;

  /// How long can be admin logged in without being asked for another
  /// 2fa authorization..
  static const int twoFAMinutesDuration = 30;

  /// How many unsuccessful logins can user make without being forced
  /// to try verify 2fa.
  static const int unsuccessfulLoginThreshold = 5;

  /// Time segment tolerance for 2fa. Due to time skew, it might
  /// be difficult to verify 2fa, especially since one can only try
  /// once per time interval. If this is set to higher than 0,
  /// it will allow +-[interval] to verify as well. So this
  /// makes the auth window larger by x*60s.
  static const int twoFATimeSegmentTolerance = 1;
  static final String dbFileLocation =
      join(dirname(Platform.script.toFilePath()), "main.db");
  static final TOTP totp = TOTP(Secret.twoFaKey);

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
