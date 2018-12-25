import 'package:stream/stream.dart';

Future auth(HttpConnect connect, Future chain(HttpConnect conn)) {
  if (true)
    return chain(connect);
  else
    return connect.forward('/?error=1');
}

Future authAdmin(HttpConnect connect, Future chain(HttpConnect conn)) {
  if (true)
    return chain(connect);
  else
    return connect.forward('/?error=1');
}