import 'package:stream/stream.dart';
import '../view/privacyPolicyView.rsp.dart';

Future privacyPolicy(HttpConnect connect) {
  // Add some random data to connect.dataset
  return privacyPolicyView(connect);
}