import 'dart:io';

import 'package:stream/stream.dart';

import '../tools/db.dart';

class General {
  /// This accepts any URL and redirects user
  /// to URL without the last char
  static void redirectToNoLeadingSlash(HttpConnect connect) {
    connect.redirect(connect.request.uri
        .toString()
        .substring(0, connect.request.uri.toString().length - 1), status: HttpStatus.movedPermanently);
  }

  /// Purge old data about students and old raw logs.
  /// This should be called with cron about once a day.
  /// Since this is not secured, we will assign it to hard-to-guess url
  /// and return 404. Hope nobody sees this. #securitybyobscurity
  static void purgeOldData(HttpConnect connect) {
    DB.purgeSavedData();
    throw Http404.fromConnect(connect);
  }
}
