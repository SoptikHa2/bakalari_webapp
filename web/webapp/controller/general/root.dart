import 'package:stream/stream.dart';
import '../../tools/tools.dart';
import '../../view/general/rootView.rsp.dart';

class GeneralRootController {
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

    // Add username and uri from cookies
    String uri = null;
    String username = null;
    if (connect.request.cookies.any((c) => c.name == "username")) {
      username = Tools.decodeCookieValue(connect.request.cookies
          .firstWhere((c) => c.name == "username")
          .value);
    }
    if (connect.request.cookies.any((c) => c.name == "schoolURI")) {
      uri = Tools.decodeCookieValue(connect.request.cookies
          .firstWhere((c) => c.name == "schoolURI")
          .value);
    }

    // Add username and uri if error and filled in last time
    if (connect.request.uri.queryParameters.containsKey('filledURI')) {
      uri =
          Uri.decodeComponent(connect.request.uri.queryParameters['filledURI']);
    }
    if (connect.request.uri.queryParameters.containsKey('filledUsername')) {
      username = Uri.decodeComponent(
          connect.request.uri.queryParameters['filledUsername']);
    }

    return rootView(connect,
        errorDescription: errorMessage,
        presetUrl: uri,
        presetUsername: username);
  }
}
