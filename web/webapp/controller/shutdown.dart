import 'dart:io';

import 'package:stream/stream.dart';

import '../config.dart';
import '../view/shutdown/shutdown451.rsp.dart';
import '../view/shutdown/shutdownPlain.rsp.dart';

class Shutdown {
  static Future showShutdown(HttpConnect connect) async {
    switch (Config.siteShutdownType) {
      case ShutdownTemplate.None:
        return connect.redirect('/');
      case ShutdownTemplate.Template451:
        return shutdown451View(connect, reason: Config.siteShutdownReason);
      case ShutdownTemplate.TemplateEmpty:
        return shutdownPlainView(connect, reason: Config.siteShutdownReason);
    }
    return connect.redirect('/');
  }
}
