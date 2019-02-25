import 'package:stream/stream.dart';

import '../../view/general/torView.rsp.dart';

class GeneralTorController {
  static Future showTorLandingPage(HttpConnect connect) {
    return torView(connect);
  }
}
