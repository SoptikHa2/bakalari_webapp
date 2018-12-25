import 'package:stream/stream.dart';
import '../view/rootView.rsp.dart';

Future root(HttpConnect connect) {
  return rootView(connect);
}