import 'package:stream/stream.dart';
import '../view/rootView.rsp.dart';
import '../tools/db.dart';

class Root {
  static Map<String, String> _errors = {
    "invalid_structure": "Ještě jednou zkontrolujte zadané údaje v formuláři, něco jste vyplnili špatně.",
    "cannot_connect": "Nepodařilo se připojit k webu školy. Zkontrolujte URl, jméno a heslo.",
  };


  static Future root(HttpConnect connect) async {
    if (false) {
      // User.loggedIn
      connect.redirect('student');
    }

    String errorMessage = null;
    if(connect.request.uri.queryParameters.containsKey('error')){
      if(_errors.containsKey(connect.request.uri.queryParameters['error']))
        errorMessage = _errors[connect.request.uri.queryParameters['error']];
    }

    return rootView(connect, urls: await DB.getSchools(), errorDescription: errorMessage);
  }
}
