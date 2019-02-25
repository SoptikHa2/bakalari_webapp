import 'package:stream/stream.dart';

import '../../view/general/restApi.rsp.dart';

class GeneralApiController {
  static Future showRestApiView(HttpConnect connect) {
    String studentID = null;
    if (connect.request.cookies.any((c) => c.name == "studentID")) {
      studentID =
          connect.request.cookies.where((c) => c.name == 'studentID').single.value;
    }
    return restApiView(connect, currentApiKey: studentID);
  }
}
