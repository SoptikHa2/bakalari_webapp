import 'package:stream/stream.dart';
import 'db.dart';

Future log(HttpConnect connect, Future chain(HttpConnect conn)) {
  if (!connect.request.uri.queryParameters.containsKey('log') ||
      connect.request.uri.queryParameters['log'] != 0) {
    DB.logRawAccess(connect.request, connect.browser);
  }
  return chain(connect);
}