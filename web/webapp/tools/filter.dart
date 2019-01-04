import 'package:stream/stream.dart';
import '../config.dart';
import 'db.dart';

class Filter {
  static Future process(HttpConnect connect, Future chain(HttpConnect conn)) async {
    var path = connect.request.uri.path.replaceAll('/', '');

    if(path.endsWith('.js') || path.endsWith('.css') || path.endsWith('.jpg')){
      return chain(connect);
    }

    if(path.endsWith('shutdown')){
      return chain(connect);
    }
    
    if(Config.siteShutdownType != ShutdownTemplate.None){
      return connect.redirect('/shutdown');
    }
    _log(connect);
    return chain(connect);
  }

  static void _log(HttpConnect connect) {
    if (!connect.request.uri.queryParameters.containsKey('log') ||
        connect.request.uri.queryParameters['log'] != 0) {
      DB.logRawAccess(connect.request, connect.browser);
    }
  }
}