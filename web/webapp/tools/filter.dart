import 'package:stream/stream.dart';
import '../config.dart';
import 'db.dart';

/// Every request goes here
class Filter {
  /// Process a request. Log it if needed and sometimes redirect to /shutdown.
  static Future process(
      HttpConnect connect, Future chain(HttpConnect conn)) async {
    // Remove all slashes. The point is to remove trailing slashes, but we
    // can as well remove all of them.
    var path = connect.request.uri.path.replaceAll('/', '');

    // If user tries to connect to a static file, let it through (without logging)
    if (path.endsWith('.js') ||
        path.endsWith('.css') ||
        path.endsWith('.jpg') ||
        path.endsWith('.ico') ||
        path.endsWith('.csv') ||
        path.endsWith('.txt')) {
      return chain(connect);
    }

    // Log user visit
    DB.logAccess(connect.request);

    // If user tries to reach /shutdown, let him go there
    if (path.endsWith('shutdown')) {
      return chain(connect);
    }

    // If there is defined shutdown, forward user to /shutdown
    if (Config.siteShutdownType != ShutdownTemplate.None) {
      return connect.redirect('/shutdown');
    }

    // If none of the situations above happened, continue
    return chain(connect);
  }
}
