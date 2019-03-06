import 'dart:io';

import 'package:stream/stream.dart';

import '../../config.dart';
import '../../tools/db.dart';
import '../../tools/securityTools.dart';
import '../../tools/tools.dart';
import '../../view/admin/adminLogView.rsp.dart';

class AdminLogController {
  static void showLogPage(HttpConnect connect) {
    /* LOGIN */
    var loginResult = SecurityTools.verifyAsAdmin(connect);

    if (loginResult == AdminLoginStatus.Ratelimit) {
      connect.response.cookies.add(Cookie('twoFAtoken', 'deleted')..maxAge = 0);
      return connect.redirect('/admin/login?error=too_many_login_attempts');
    }
    if (loginResult == AdminLoginStatus.InvalidRequest) {
      return connect.redirect('/admin/login');
    }
    if (loginResult == AdminLoginStatus.NoAuthGiven) {
      connect.response
        ..headers
            .set('WWW-Authenticate', 'Basic realm="admin", charset="UTF-8"')
        ..statusCode = 401;
        // ignore: mixed_return_types
        return;
    }
    if (loginResult == AdminLoginStatus.PasswordIncorrect) {
      connect.response
        ..headers
            .set('WWW-Authenticate', 'Basic realm="admin", charset="UTF-8"')
        ..statusCode = 401;
      // ignore: mixed_return_types
      return;
    }
    if (loginResult == AdminLoginStatus.TwoFAIncorrect) {
      return connect.redirect('/admin/login');
    }

    Config.unsuccessfulAdminLoginsInARow = 0;
    /* LOGGED IN */
    
    // ignore: return_of_invalid_type, mixed_return_types
    return adminLogView(connect);
  }

    static Future downloadRawLog(HttpConnect connect) async {
    /* LOGIN */
    var loginResult = SecurityTools.verifyAsAdmin(connect);

    if (loginResult == AdminLoginStatus.Ratelimit) {
      connect.response.cookies.add(Cookie('twoFAtoken', 'deleted')..maxAge = 0);
      return connect.redirect('/admin/login?error=too_many_login_attempts');
    }
    if (loginResult == AdminLoginStatus.InvalidRequest) {
      return connect.redirect('/admin/login');
    }
    if (loginResult == AdminLoginStatus.NoAuthGiven) {
      connect.response
        ..headers
            .set('WWW-Authenticate', 'Basic realm="admin", charset="UTF-8"')
        ..statusCode = 401;
        // ignore: mixed_return_types
        return;
    }
    if (loginResult == AdminLoginStatus.PasswordIncorrect) {
      connect.response
        ..headers
            .set('WWW-Authenticate', 'Basic realm="admin", charset="UTF-8"')
        ..statusCode = 401;
      // ignore: mixed_return_types
      return;
    }
    if (loginResult == AdminLoginStatus.TwoFAIncorrect) {
      return connect.redirect('/admin/login');
    }

    Config.unsuccessfulAdminLoginsInARow = 0;
    /* LOGGED IN */

    String identifier = Uri.decodeComponent(connect.dataset['file']);

    String fileContent = null;
    switch(identifier){
      case 'logStudentLogin':
        fileContent = await DB.getStudentLoginLogsInJson();
      break;
    }

    if(fileContent == null){
      return connect.redirect('/admin/log?error=bad_structure');
    }

    // ignore: mixed_return_types
    return connect.response
      ..headers.contentType = ContentType.json
      ..write(fileContent)
      ..close();
  }
}
