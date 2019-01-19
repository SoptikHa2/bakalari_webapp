import 'package:stream/stream.dart';
import '../view/main/rootView.rsp.dart';
import '../tools/db.dart';

class Root {
  static Map<String, String> _errors = {
    "invalid_structure":
        "Ještě jednou zkontrolujte zadané údaje v formuláři, něco jste vyplnili špatně.",
    "cannot_connect":
        "Nepodařilo se připojit k webu školy. Zkontrolujte URl, jméno a heslo.",
  };

  static Future root(HttpConnect connect) async {
    if (connect.request.cookies.any((c) => c.name == "studentID")) {
      return connect.redirect('student');
    }

    String errorMessage = null;
    if (connect.request.uri.queryParameters.containsKey('error')) {
      if (_errors.containsKey(connect.request.uri.queryParameters['error']))
        errorMessage = _errors[connect.request.uri.queryParameters['error']];
    }

    // Add username and uri if error and filled in last time
    String uri = null;
    if (connect.request.uri.queryParameters.containsKey('filledURI')) {
        uri = Uri.decodeComponent(connect.request.uri.queryParameters['filledURI']);
    }
    String username = null;
    if (connect.request.uri.queryParameters.containsKey('filledUsername')) {
        username = Uri.decodeComponent(connect.request.uri.queryParameters['filledUsername']);
    }

    return rootView(connect,
        urls: await DB.getSchools(), errorDescription: errorMessage, presetUrl: uri, presetUsername: username);
  }
}
