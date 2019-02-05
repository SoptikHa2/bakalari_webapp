import 'dart:io';

import 'package:stream/stream.dart';

import '../../config.dart';
import '../../tools/db.dart';
import '../../tools/tools.dart';
import '../../view/admin/adminLogView.rsp.dart';

class AdminLogController {
  static showLogPage(HttpConnect connect) {
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
    
    return adminLogView(connect);
  }

    static Future downloadRawLog(HttpConnect connect) async {
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

    String identifier = Uri.decodeComponent(connect.dataset['file']);

    String fileContent = null;
    switch(identifier){
      case 'logRaw':
        fileContent = await DB.getLogRawInJson();
      break;
      case 'logStudentLogin':
        fileContent = await DB.getStudentLoginLogsInJson();
      break;
      case 'logStudentInfo':
        fileContent = await DB.getStudentsInJson();
      break;
    }

    if(fileContent == null){
      return connect.redirect('/admin/log?error=bad_structure');
    }

    return connect.response
      ..headers.contentType = ContentType.json
      ..write(fileContent)
      ..close();
  }
}
