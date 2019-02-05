import 'package:stream/stream.dart';

import '../../config.dart';
import '../../tools/db.dart';
import '../../tools/tools.dart';
import '../../view/admin/adminMessageListView.rsp.dart';
import '../../view/admin/adminMessageView.rsp.dart';

class AdminMessagesController {
  static Future getFullMessageList(HttpConnect connect) async {
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


    var messages = await DB.getAllMessages();
    return adminMessageListView(connect,
        countOfNew: messages.where((m) => !m.isImportant).length,
        countOfImportant: messages.where((m) => m.isImportant).length,
        messages: messages);
  }

  static Future getMessageList(HttpConnect connect) async {
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

    
    var messages = (await DB.getAllMessages()).where((m) => !m.isClosed);
    return adminMessageListView(connect,
        countOfNew: messages.where((m) => !m.isImportant).length,
        countOfImportant: messages.where((m) => m.isImportant).length,
        messages: messages);
  }

  static Future getOneMessage(HttpConnect connect) async {
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


    try {
      String identifier = Uri.decodeComponent(connect.dataset['guid']);
      var message = await DB.getOneMessage(identifier);
      return adminMessageView(connect, message: message);
    } catch (e) {
      return connect.redirect('/admin/message');
    }
  }

  static Future setAsCompleted(HttpConnect connect) async {
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


    String identifier = Uri.decodeComponent(connect.dataset['guid']);
    await DB.markMessageAsDone(identifier);
    return connect.redirect('/admin/message');
  }
}
