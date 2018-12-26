import 'package:stream/stream.dart';
import 'db.dart';

Future log(HttpConnect connect, Future chain(HttpConnect conn)){
  DB.logRawAccess(connect.request, connect.browser);
  return chain(connect);
}