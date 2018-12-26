import 'package:stream/stream.dart';
import '../view/privacyPolicyView.rsp.dart';

class PrivacyPolicy {
  static Future getPolicy(HttpConnect connect) {
    // Add some random data to connect.dataset
    return privacyPolicyView(connect);
  }
}
