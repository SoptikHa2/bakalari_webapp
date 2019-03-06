import 'dart:io';

import 'package:stream/stream.dart';

import '../../config.dart';
import '../../tools/db.dart';
import '../../tools/securityTools.dart';
import '../../view/admin/adminMessageListView.rsp.dart';
import '../../view/admin/adminMessageView.rsp.dart';

class AdminMessagesController {
  static Future getFullMessageList(HttpConnect connect) async {
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
        return;
    }
    if (loginResult == AdminLoginStatus.PasswordIncorrect) {
      connect.response
        ..headers
            .set('WWW-Authenticate', 'Basic realm="admin", charset="UTF-8"')
        ..statusCode = 401;
      return;
    }
    if (loginResult == AdminLoginStatus.TwoFAIncorrect) {
      return connect.redirect('/admin/login');
    }

    Config.unsuccessfulAdminLoginsInARow = 0;
    /* LOGGED IN */


    var messages = await DB.getAllMessages();
    await adminMessageListView(connect,
        countOfNew: messages.where((m) => !m.isImportant).length,
        countOfImportant: messages.where((m) => m.isImportant).length,
        messages: messages);
  }

  static Future getMessageList(HttpConnect connect) async {
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
        return;
    }
    if (loginResult == AdminLoginStatus.PasswordIncorrect) {
      connect.response
        ..headers
            .set('WWW-Authenticate', 'Basic realm="admin", charset="UTF-8"')
        ..statusCode = 401;
      return;
    }
    if (loginResult == AdminLoginStatus.TwoFAIncorrect) {
      return connect.redirect('/admin/login');
    }

    Config.unsuccessfulAdminLoginsInARow = 0;
    /* LOGGED IN */

    
    var messages = (await DB.getAllMessages()).where((m) => !m.isClosed);
    await adminMessageListView(connect,
        countOfNew: messages.where((m) => !m.isImportant).length,
        countOfImportant: messages.where((m) => m.isImportant).length,
        messages: messages);
  }

  static Future getOneMessage(HttpConnect connect) async {
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
        return;
    }
    if (loginResult == AdminLoginStatus.PasswordIncorrect) {
      connect.response
        ..headers
            .set('WWW-Authenticate', 'Basic realm="admin", charset="UTF-8"')
        ..statusCode = 401;
      return;
    }
    if (loginResult == AdminLoginStatus.TwoFAIncorrect) {
      return connect.redirect('/admin/login');
    }

    Config.unsuccessfulAdminLoginsInARow = 0;
    /* LOGGED IN */


    try {
      String identifier = Uri.decodeComponent(connect.dataset['guid']);
      var message = await DB.getOneMessage(identifier);
      await adminMessageView(connect, message: message);
    } catch (e) {
      connect.redirect('/admin/message');
    }
  }

  static Future setAsCompleted(HttpConnect connect) async {
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
        return;
    }
    if (loginResult == AdminLoginStatus.PasswordIncorrect) {
      connect.response
        ..headers
            .set('WWW-Authenticate', 'Basic realm="admin", charset="UTF-8"')
        ..statusCode = 401;
      return;
    }
    if (loginResult == AdminLoginStatus.TwoFAIncorrect) {
      return connect.redirect('/admin/login');
    }

    Config.unsuccessfulAdminLoginsInARow = 0;
    /* LOGGED IN */


    String identifier = Uri.decodeComponent(connect.dataset['guid']);
    await DB.markMessageAsDone(identifier);
    connect.redirect('/admin/message');
  }
}
