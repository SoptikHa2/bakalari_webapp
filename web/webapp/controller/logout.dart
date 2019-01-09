import 'dart:io';

import 'package:stream/stream.dart';

class Logout {
  static void logoutUser(HttpConnect connect) {
    connect.response.cookies.add(Cookie('studentID', 'deleted')..maxAge = 0);
    connect.redirect('/');
  }

  /// TODO: This doesn't work
  static void logoutAdmin(HttpConnect connect){
    connect.response.cookies.add(Cookie('twoFAtoken', 'deleted')..maxAge = 0);
    connect.redirect('/');
  }
}
