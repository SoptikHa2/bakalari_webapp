//Auto-generated by RSP Compiler
//Source: rootView.rsp.html
library rootView_rsp;

import 'dart:async';
import 'dart:io';
import 'package:stream/stream.dart';

/** Template, rootView, for rendering the view. */
Future rootView(HttpConnect connect, {List<String> urls, String errorDescription, String presetUrl, String presetUsername}) async {
  HttpResponse response = connect.response;
  if (!Rsp.init(connect, "text/html; charset=utf-8"))
    return null;
String nbsp = "\u{00A0}";

  await connect.include("/webapp/view/templates/head.html");

  response.write("""  <div class="content">
""");

  if (errorDescription != null) {

    response.write("""    <aside class="errorBar">
      <p>
        """);

    response.write(Rsp.nnx(errorDescription));


    response.write("""

      </p>
    </aside>
""");
  } //if

  response.write("""

    <h1>
      Bakaláři
    </h1>
    <p>
      A tentokrát lépe.
    </p>

    <form class="pure-form" action="/student" method="POST">
      <fieldset>
        <legend>Přihlásit se (<a href="/privacy_policy">zpracování osobních údajů</a>)</legend>

        <input name="bakawebUrl" type="text" list="schoolUrls" placeholder="bakalari.ceskolipska.cz" """);

  response.write(Rsp.nnx(presetUrl !=null
          ? 'value="$presetUrl"' : ''));


  response.write("""" />
        <datalist id="schoolUrls">
""");

  if (urls != null) {

    for (var url in urls) {

      response.write("""          <option>""");

      response.write(Rsp.nnx(url));


      response.write("""</option>
""");
    } //for
  } //if

  response.write("""        </datalist>
        <input name="login" type="text" placeholder="Uživatelské jméno" """);

  response.write(Rsp.nnx(presetUsername !=null ?
          'value="$presetUsername"' : ''));


  response.write("""">
        <input name="password" type="password" placeholder="Heslo">

        <button type="submit" class="pure-button pure-button-primary">Přihlásit</button>
      </fieldset>
    </form>
  </div>

  <script>
    if ('serviceWorker' in navigator) {
      navigator.serviceWorker
        .register('/offlineServiceWorker.js')
        .then(function () { console.log("Service Worker Registered"); });
    }
  </script>

""");

  await connect.include("/webapp/view/templates/tail.html");

  return null;
}
