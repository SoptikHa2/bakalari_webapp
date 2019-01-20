import 'dart:io';

import 'package:rikulo_commons/io.dart';
import 'package:rikulo_commons/mirrors.dart';
import 'package:stream/stream.dart';

import '../../config.dart';
import '../../tools/tools.dart';
import '../../view/admin/adminLoginView.rsp.dart';
import '../../view/admin/adminRootView.rsp.dart';

class Admin {
  static Map<String, String> _errors = {
    "invalid_structure":
        "Ještě jednou zkontrolujte zadané údaje v formuláři, něco jste vyplnili špatně.",
    "2fa_error":
        "Dvoufaktorový kód je nesprávný. Počkejte než bude vygenerován další a zkuste to znovu.",
    "ratelimit_error":
        "Zkoušíte to moc rychle. Dvoufaktorový kód lze zadat pouze jednou za 30 vteřin."
  };

  static Future loginForm(HttpConnect connect) async {
    String errorMessage = null;
    if (connect.request.uri.queryParameters.containsKey('error')) {
      if (_errors.containsKey(connect.request.uri.queryParameters['error']))
        errorMessage = _errors[connect.request.uri.queryParameters['error']];
    }

    return adminLoginView(connect, error: errorMessage);
  }

  // Post
  static Future verify2FA(HttpConnect connect) async {
    // Check ratelimit
    var now = DateTime.now();
    if (Config.last2FAattempt != null) {
      if (now.second >= 30 && Config.last2FAattempt.second < 30 ||
          now.minute > Config.last2FAattempt.minute) {} // It's ok
      else{
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

    String twoFAToken = Tools.loginAsAdmin2FA(post.twofa);

    if (twoFAToken == null) {
      Config.last2FAattempt = now;
      return connect.redirect('/admin/login?error=2fa_error');
    }

    connect.response.cookies.add(Cookie("twoFAtoken", twoFAToken)
      ..expires =
          DateTime.now().add(Duration(minutes: Config.twoFAMinutesDuration)));

    return await adminRootPage(connect);
  }

  static Future adminRootPage(HttpConnect connect) async {
    /* LOGIN */
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

    if (connect.request.headers.value('Authorization') == null) {
      connect.response
        ..headers
            .set('WWW-Authenticate', 'Basic realm="admin", charset="UTF-8"')
        ..statusCode = 401;
      // ignore: mixed_return_types
      return;
    }

    var authResult = Tools.verifyAsAdmin(
        connect.request.headers.value('Authorization'), twoFAtoken);

    if (authResult == AdminLoginStatus.PasswordIncorrect) {
      connect.response
        ..headers
            .set('WWW-Authenticate', 'Basic realm="admin", charset="UTF-8"')
        ..statusCode = 401;
      // ignore: mixed_return_types
      return;
    }
    if (authResult == AdminLoginStatus.TwoFAIncorrect) {
      return connect.redirect('/admin/login');
    }

    /* LOGGED IN */
    // ignore: mixed_return_types
    return adminRootView(connect);
  }

  // Post
  static Future shutdownWebsite(HttpConnect connect) async {
    // Decode
    var postParameters = await HttpUtil.decodePostedParameters(connect.request);
    var post = ShutdownPostParams();
    ObjectUtil.inject(post, postParameters);
    if (!post.validate()) {
      return connect.redirect("/admin");
    }

    String twoFAtoken = null;
    try {
      if (connect.request.cookies.any((c) => c.name == "twoFAtoken")) {
        twoFAtoken = connect.request.cookies
            .singleWhere((c) => c.name == "twoFAtoken")
            .value;
      }
    } catch (e) {}

    if (twoFAtoken == null) {
      return connect.redirect('/admin/login');
    }

    if (connect.request.headers.value('Authorization') == null) {
      connect.response
        ..headers
            .set('WWW-Authenticate', 'Basic realm="admin", charset="UTF-8"')
        ..statusCode = 401;
      return;
    }

    var authResult = Tools.verifyAsAdmin(
        connect.request.headers.value('Authorization'), twoFAtoken);

    if (authResult == AdminLoginStatus.PasswordIncorrect) {
      connect.response
        ..headers
            .set('WWW-Authenticate', 'Basic realm="admin", charset="UTF-8"')
        ..statusCode = 401;
      return;
    }
    if (authResult == AdminLoginStatus.TwoFAIncorrect) {
      return connect.redirect('/admin/login?error=2fa');
    }

    if (!Config.totp.verify(post.twofa.replaceAll(' ', ''))) {
      return connect.redirect('/admin?error=2fa');
    }

    /* LOGGED IN */
    switch (post.shutdownType) {
      case "emptyTemplate":
        Config.siteShutdownType = ShutdownTemplate.TemplateEmpty;
        break;
      case "451template":
        Config.siteShutdownType = ShutdownTemplate.Template451;
        break;
    }

    Config.siteShutdownReason = post.reason;

    return connect.redirect('/admin?shutdown=true');
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
        (shutdownType == "emptyTemplate" || shutdownType == "451template");
  }
}
