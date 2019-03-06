import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/api.dart';
import 'package:stream/stream.dart';
import 'package:uuid/uuid.dart';

import '../config.dart';
import '../model/complexStudent.dart';
import 'db.dart';

class SecurityTools {
  /* ############################################ */
  /* #                                          # */
  /* #                 L O G I N                # */
  /* #                                          # */
  /* ############################################ */

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

  /// Verify 2FA. If correct, return guid that can be used as proof that 2fa was successful.
  static String loginAsAdmin2FA(String twoFA) {
    if (Config.totp.verify(twoFA.replaceAll(' ', ''))) {
      String guid = Uuid().v4();
      Config.currentTwoFAtoken = guid;
      DateTime selectedDateTime = DateTime.now();
      selectedDateTime =
          selectedDateTime.add(Duration(minutes: Config.twoFAMinutesDuration));
      Config.currentTwoFAtokenValid = selectedDateTime;
      return guid;
    }
    return null;
  }

  /* ############################################ */
  /* #                                          # */
  /* #              E N C R Y P T               # */
  /* #                                          # */
  /* #                 H A S H                  # */
  /* #                                          # */
  /* ############################################ */

  static String encryptStudentData(String data, String key) {
    // Truncate key to 32 characters
    if (key.length < 32) {
      throw new ArgumentError(
          "Error: encryptStudentData: Key needs to be at least 32 characters long. Key was ${key.length} characters long.");
    }
    key = key.substring(0, 32);

    final encKey = Key.fromUtf8(key);
    final iv = IV.fromLength(16);

    final encrypter = Encrypter(AES(encKey, iv));

    return encrypter.encrypt(data).base64;
  }

  static String decryptStudentData(String data, String key) {
    final encKey = Key.fromUtf8(key);
    final iv = IV.fromLength(16);

    final encrypter = Encrypter(AES(encKey, iv));

    return encrypter.decrypt(Encrypted.fromBase64(data));
  }

  static String generateEncryptionKey([int length = 32]) {
    String key = "";
    var rand = Random.secure();
    for (var i = 0; i < length; i++) {
      var secureInteger = rand.nextInt(50);
      if (secureInteger < 25) {
        key += String.fromCharCode(secureInteger + 97);
      } else {
        key += String.fromCharCode((secureInteger % 25) + 65);
      }
    }
    return key;
  }

  static String obfuscateIpAddress(String ipAddress) {
    if (ipAddress == null) return '[unknown]';
    return base64.encode(_sha256
        .process(_sha256.process(utf8.encode('ipAddressIs' + ipAddress))));
  }

  /* ############################################ */
  /* #                                          # */
  /* #              HELPER METHODS              # */
  /* #                                          # */
  /* ############################################ */

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
  static String _hashPassword(String password, String username) {
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
          _hashPassword(password, username) ==
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
