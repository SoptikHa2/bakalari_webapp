import 'package:stream/stream.dart';

Future log(HttpConnect connect, Future chain(HttpConnect conn)){
  // TODO: log
  return chain(connect);
}