import 'package:stream/stream.dart';
import '../view/refreshStudentInfoView.rsp.dart';
import '../tools/db.dart';

class RefreshStudentInfo {
  static Map<String, String> _errors = {
    "invalid_structure":
        "Ještě jednou zkontrolujte zadané údaje v formuláři, něco jste vyplnili špatně.",
    "cannot_connect":
        "Nepodařilo se připojit k webu školy. Zkontrolujte URl, jméno a heslo.",
  };

  static Future refresh(HttpConnect connect) async {
    String errorMessage = null;
    if (connect.request.uri.queryParameters.containsKey('error')) {
      if (_errors.containsKey(connect.request.uri.queryParameters['error']))
        errorMessage = _errors[connect.request.uri.queryParameters['error']];
    }

    return refreshStudentInfoView(connect,
        urls: await DB.getSchools(),
        errorDescription: errorMessage);
  }
}
