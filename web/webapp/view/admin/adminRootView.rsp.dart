//Auto-generated by RSP Compiler
//Source: adminRootView.rsp.html
library adminRootView_rsp;

import 'dart:async';
import 'dart:io';
import 'package:stream/stream.dart';

/** Template, adminRootView, for rendering the view. */
Future adminRootView(HttpConnect connect) async {
  HttpResponse response = connect.response;
  if (!Rsp.init(connect, "text/html; charset=utf-8"))
    return null;

  await connect.include("/webapp/view/templates/adminHead.html");

  response.write("""<div class="content">
    <h1>Administrační sekce</h1>
    <ul>
        <li><a href="/admin/log">Log</a></li>
        <li><a href="/admin/rpi">Raspberry info</a></li>
        <li><a href="/admin/upload">Upload</a></li>
        <li><a href="/admin/logout">Logout</a></li>
    </ul>
    <h2>Pozastavení stránky</h2>
    <p>
        Všechny dotazy na Bakaláře (včetně administračního panelu) budou
        přesměrovány na stránku se zadaným textem. Toto opatření
        bude trvat až do manuálního restartu serveru.
    </p>
    <p>
        Pro dlouhodobou úpravu je třeba stránku přeprogramovat.
    </p>
    <form class="pure-form" action="/admin/shutdown" method="POST">
        <fieldset>
            <legend>Zadejte dvoufaktorový kód a vyberte akci</legend>

            <input name="twofa" type="text" placeholder="041 268" autocomplete="off"><br />
            <textarea name="reason" placeholder="Reason"></textarea><br />

            <input type="radio" name="shutdownType" value="emptyTemplate"><label for="emptyTemplate">Prázdná stránka</label><br />
            <input type="radio" name="shutdownType" value="451template"><label for="451template">451</label><br />

            <button type="submit" class="pure-button button-error">Spustit</button>
        </fieldset>
    </form>
</div>
""");

  await connect.include("/webapp/view/templates/tail.html");

  return null;
}
