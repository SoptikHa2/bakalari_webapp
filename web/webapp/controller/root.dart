import 'package:stream/stream.dart';
import '../view/rootView.rsp.dart';

Future root(HttpConnect connect) {
  connect.dataset['status'] = 1;
  return rootView(connect);
}