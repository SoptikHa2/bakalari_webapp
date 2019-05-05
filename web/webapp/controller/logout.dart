import 'dart:io';

import 'package:stream/stream.dart';

class GeneralLogoutController {
  static void logoutUser(HttpConnect connect) {
    connect.response.cookies.add(Cookie('studentID', 'deleted')..maxAge = 0);
    connect.response.cookies.add(Cookie('encryptionKey', 'deleted')..maxAge = 0);
    connect.response.cookies.add(Cookie('twoFAtoken', 'deleted')..maxAge = 0);
    connect.redirect('/');
  }
}
