//Auto-generated by RSP Compiler
//Source: loginView.rsp.html
library loginView_rsp;

import 'dart:async';
import 'dart:io';
import 'package:stream/stream.dart';

/** Template, loginView, for rendering the view. */
Future loginView(HttpConnect connect, {String error}) async {
  HttpResponse response = connect.response;
  if (!Rsp.init(connect, "text/html; charset=utf-8"))
    return null;

  await connect.include("/webapp/view/templates/head.html");

  response.write("""<div class="content">
""");

  if (error != null) {

    response.write("""    <aside class="errorBar">
      <p>
        """);

    response.write(Rsp.nnx(error));


    response.write("""

      </p>
    </aside>
""");
  } //if

  response.write("""    <h1>Administrační sekce</h1>
    <form class="pure-form" action="/admin" method="POST">
        <fieldset>
            <legend>Zadejte dvoufaktorový kód. Heslo bude vyžadováno v příštím kroku přihlášení.</legend>

            <input name="twofa" type="text" placeholder="041 268" autocomplete="off">

            <button type="submit" class="pure-button pure-button-primary">Další</button>
        </fieldset>
    </form>
</div>
""");

  await connect.include("/webapp/view/templates/tail.html");

  return null;
}