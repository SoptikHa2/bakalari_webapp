import 'dart:io';

import 'package:rikulo_commons/io.dart';
import 'package:rikulo_commons/mirrors.dart';
import 'package:stream/stream.dart';

import '../../config.dart';
import '../../tools/db.dart';
import '../../tools/securityTools.dart';
import '../../view/admin/adminLoginView.rsp.dart';
import '../../view/admin/adminRootView.rsp.dart';

class AdminBaseController {
  static Map<String, String> _errors = {
    "invalid_structure":
        "Ještě jednou zkontrolujte zadané údaje v formuláři, něco jste vyplnili špatně.",
    "2fa_error":
        "Dvoufaktorový kód je nesprávný nebo vypršela jeho platnost ještě před úspěšným přihlášením. Počkejte než bude vygenerován další a zkuste to znovu.",
    "ratelimit_error":
        "Zkoušíte to moc rychle. Dvoufaktorový kód lze zadat pouze jednou za 30 vteřin.",
    "too_many_login_attempts":
        "Zkusili jste se několikrát neúspěšně přihlásit. Počkejte než bude vygenerován nový kód a zkuste to znovu."
  };

  /// Show login form (with error, as described in [_errors])
  static Future loginForm(HttpConnect connect) async {
    String errorMessage = null;
    if (connect.request.uri.queryParameters.containsKey('error')) {
      if (_errors.containsKey(connect.request.uri.queryParameters['error']))
        errorMessage = _errors[connect.request.uri.queryParameters['error']];
    }

    return adminLoginView(connect, error: errorMessage);
  }

  /// User POSTed 2fa code. Verify it, and either rate-limit user, or
  /// mark that user passed 2fa test and send him to /admin, where he will
  /// be asked for password.
  static Future verify2FA(HttpConnect connect) async {
    // Check ratelimit
    var now = DateTime.now();
    if (Config.last2FAattempt != null) {
      if (now.second >= 30 && Config.last2FAattempt.second < 30 ||
          now.minute > Config.last2FAattempt.minute) {
      } // It's ok
      else {
        // Rate limit
        return connect.redirect("/admin/login?error=ratelimit_error");
      }
    }

    // Decode
    var postParameters = await HttpUtil.decodePostedParameters(connect.request);
    var post = AdminLoginPostParams();
    ObjectUtil.inject(post, postParameters);
    if (!post.validate()) {
      return connect.redirect("/admin/login?error=invalid_structure");
    }

    String twoFAToken = SecurityTools.loginAsAdmin2FA(post.twofa);

    if (twoFAToken == null) {
      Config.last2FAattempt = now;
      return connect.redirect('/admin/login?error=2fa_error');
    }

    connect.response.cookies.add(Cookie("twoFAtoken", twoFAToken)
      ..expires =
          DateTime.now().add(Duration(minutes: Config.twoFAMinutesDuration)));

    return await adminRootPage(connect);
  }

  /// Show main admin page. If user is not logged in,
  /// show him login form.
  static Future adminRootPage(HttpConnect connect) async {
    /* LOGIN */
    var loginResult = SecurityTools.verifyAsAdmin(connect);

    if (loginResult == AdminLoginStatus.Ratelimit) {
      connect.response.cookies.add(Cookie('twoFAtoken', 'deleted')..maxAge = 0);
      connect.redirect('/admin/login?error=too_many_login_attempts');
      return;
    }
    if (loginResult == AdminLoginStatus.InvalidRequest) {
      connect.redirect('/admin/login');
      return;
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
    int countOfNormalMessages = messages.where((m) => !m.isImportant).length;
    int countOfImprotantMessages = messages.length - countOfNormalMessages;
    await adminRootView(connect,
        numberOfNormalMessages: countOfNormalMessages,
        numberOfImprotantMessages: countOfImprotantMessages);
  }

  // Verify 2fa and shutdown website, if user succeeds.
  static Future shutdownWebsite(HttpConnect connect) async {
    // Decode
    var postParameters = await HttpUtil.decodePostedParameters(connect.request);
    var post = ShutdownPostParams();
    ObjectUtil.inject(post, postParameters);
    if (!post.validate()) {
      return connect.redirect("/admin?error=invalid_structure");
    }

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

    if (!SecurityTools.verifyAdmin2FA(post.twofa)) {
      return connect.redirect('/admin?error=2fa_error');
    }

    switch (post.shutdownType) {
      case "emptyTemplate":
        Config.siteShutdownType = ShutdownTemplate.TemplateEmpty;
        break;
      case "451template":
        Config.siteShutdownType = ShutdownTemplate.Template451;
        break;
    }

    Config.siteShutdownReason = post.reason;

    connect.redirect('/admin?shutdown=true');
  }
}

class AdminLoginPostParams {
  String twofa;

  bool validate() {
    return twofa != null && twofa.replaceAll(' ', '').length == 6;
  }
}

class ShutdownPostParams {
  String twofa;
  String shutdownType;
  String reason;

  bool validate() {
    return twofa != null &&
        reason != null &&
        reason != "" &&
        (shutdownType == "emptyTemplate" || shutdownType == "451template");
  }
}
