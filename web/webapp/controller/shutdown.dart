import 'package:stream/stream.dart';

import '../config.dart';
import '../view/shutdown/shutdown451.rsp.dart';
import '../view/shutdown/shutdownPlain.rsp.dart';

/// In case we really have to, admin has an option
/// to redirect all trafic to shutdown page.
///
/// This change is not permanent and lasts until
/// server restarts - unless admin changes source code.
///
/// This allows admin to quickly disable whole website,
/// and later make it permanent, or quickly reenable it (by issuing one command on server).
class GeneralShutdownController {
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
