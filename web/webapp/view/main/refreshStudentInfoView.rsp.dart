//Auto-generated by RSP Compiler
//Source: refreshStudentInfoView.rsp.html
library refreshStudentInfoView_rsp;

import 'dart:async';
import 'dart:io';
import 'package:stream/stream.dart';

/** Template, refreshStudentInfoView, for rendering the view. */
Future refreshStudentInfoView(HttpConnect connect, {List<String> urls, String errorDescription}) async {
  HttpResponse response = connect.response;
  if (!Rsp.init(connect, "text/html; charset=utf-8"))
    return null;

  await connect.include("/webapp/view/templates/head.html");

  response.write("""    <div class="content">
""");

  if (errorDescription != null) {

    response.write("""        <aside class="errorBar">
            <p>
                """);

    response.write(Rsp.nnx(errorDescription));


    response.write("""

            </p>
        </aside>
""");
  } //if

  response.write("""

        <form class="pure-form" action="/student?refresh=1" method="POST">
            <fieldset>
                <legend>Obnovení údajů o studentovi (<a href="/privacy_policy">zpracování osobních údajů</a>)</legend>

                <input name="bakawebUrl" type="text" list="schoolUrls" placeholder="bakalari.ceskolipska.cz" />
                <datalist id="schoolUrls">
""");

  if (urls != null) {

    for (var url in urls) {

      response.write("""                    <option>""");

      response.write(Rsp.nnx(url));


      response.write("""</option>
""");
    } //for
  } //if

  response.write("""                </datalist>
                <input name="login" type="text" placeholder="Uživatelské jméno">
                <input name="password" type="password" placeholder="Heslo">

                <button type="submit" class="pure-button pure-button-primary">Přihlásit</button>
            </fieldset>
        </form>
    </div>
""");

  await connect.include("/webapp/view/templates/tail.html");

  return null;
}
