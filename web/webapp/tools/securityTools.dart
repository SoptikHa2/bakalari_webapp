import 'dart:convert';
import 'dart:io';

import 'package:pointycastle/api.dart';
import 'package:stream/stream.dart';

import '../config.dart';
import '../model/complexStudent.dart';
import 'db.dart';

class SecurityTools {
  static AdminLoginStatus verifyAsAdmin(HttpConnect connect) {
    /* LOGIN */

    // Check if there weren't five invalid logins in a row
    if (Config.unsuccessfulAdminLoginsInARow >=
        Config.unsuccessfulLoginThreshold) {
      Config.currentTwoFAtoken = null;
      Config.last2FAattempt = DateTime.now();
      Config.unsuccessfulAdminLoginsInARow = 0;
      return AdminLoginStatus.Ratelimit;
    }

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
      return AdminLoginStatus.InvalidRequest;
    }

    if (connect.request.headers.value('Authorization') == null) {
      return AdminLoginStatus.NoAuthGiven;
    }

    var nameColonPassword = connect.request.headers
        .value('Authorization')
        .replaceFirst('Basic ', '');
    var unbase64ed = utf8.decode(base64.decode(nameColonPassword));
    var username = unbase64ed.split(':')[0];
    var password = unbase64ed.split(':')[1];

    return _verifyAsAdmin(username, password, twoFAtoken);
  }

  static Future<LoginStatus> loginAsStudent(List<Cookie> cookies) async {
    if (!cookies.any((c) => c.name == "studentID")) {
      return LoginStatus(false, false, 'not_logged_in', null);
    }
    if (!cookies.any((c) => c.name == "encryptionKey")) {
      return LoginStatus(false, true, "not_logged_in", null);
    }

    try {
      String guid = cookies.singleWhere((c) => c.name == 'studentID').value;
      String key = cookies.singleWhere((c) => c.name == 'encryptionKey').value;

      ComplexStudent student = await DB.getStudent(guid, key);
      return LoginStatus(true, false, '', student);
    } catch (e) {
      print(e);
      return LoginStatus(false, true, 'unknown', null);
    }
  }

  static bool _verify2FAtoken(String twoFAguid) {
    if (Config.currentTwoFAtokenValid.isBefore(DateTime.now())) {
      Config.currentTwoFAtoken = null;
      return false;
    }
    if (Config.currentTwoFAtoken == twoFAguid) {
      return true;
    }
    return false;
  }

  static final Digest _sha256 = Digest("SHA-256");
  static String hashPassword(String password, String username) {
    return base64.encode(
        _sha256.process(utf8.encode(password + username + "dartlangislove")));
  }

  /// Verify username and password. twoFAguid has to be passed from cookie as proof that 2fa was successful.
  static AdminLoginStatus _verifyAsAdmin(
      String username, String password, String twoFAguid) {
    bool twoFACorrect = _verify2FAtoken(twoFAguid);
    if (!twoFACorrect) {
      return AdminLoginStatus.TwoFAIncorrect;
    } else {
      if (username == "Petr Šťastný" &&
          hashPassword(password, username) ==
              "wtkuDB/iOI3wkla2uvKTNJSdlal14yLZa8I6wfZB5z4=") {
        Config.unsuccessfulAdminLoginsInARow = 0;
        return AdminLoginStatus.OK;
      }
      Config.unsuccessfulAdminLoginsInARow++;
      return AdminLoginStatus.PasswordIncorrect;
    }
  }
}

class LoginStatus {
  bool success;
  bool requestLogout;
  String errorMessage;
  ComplexStudent result;

  LoginStatus(this.success, this.requestLogout, this.errorMessage, this.result);
}

enum AdminLoginStatus {
  OK,
  TwoFAIncorrect,
  PasswordIncorrect,
  Ratelimit,
  InvalidRequest,
  NoAuthGiven
}
