//Auto-generated by RSP Compiler
//Source: rootView.rsp.html
library rootView_rsp;

import 'dart:async';
import 'dart:io';
import 'package:stream/stream.dart';

/** Template, rootView, for rendering the view. */
Future rootView(HttpConnect connect, {String errorDescription, String presetUrl, String presetUsername}) async {
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
    <noscript>
      <aside class="errorBar">
        <p>Nemáte zapnutý JavaScript, hledání školy dle jména nebude fungovat.</p>
      </aside>
    </noscript>
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

        <label for="urlSelectField">Zadejte jméno školy nebo URL přihlašovací stránky</label>
        <input name="bakawebUrl" id="urlSelectField" type="text" placeholder="Českolipská" """);

  response.write(Rsp.nnx(presetUrl !=null
          ? 'value=$presetUrl' : ''));


  response.write(""" />
        <div id="schoolList" class="schoolList">

        </div>
        <input name="login" type="text" placeholder="Uživatelské jméno" """);

  response.write(Rsp.nnx(presetUsername !=null ?
          'value=$presetUsername' : ''));


  response.write(""">
        <input name="password" type="password" placeholder="Heslo">

        <button type="submit" class="pure-button pure-button-primary">Přihlásit</button>
      </fieldset>
    </form>

    <section>
      <h2>O projektu</h2>
      <p>
        Tento projekt byl vytvořen jako reakce na stav Bakalářů, především aplikací pro přístup
        k tomuto systému. Tato webová stránka umožňuje (nebo bude v blízké době umožňovat) přehledné
        zobrazení rozvrhu, zobrazení známek - a to i s průměry u všech předmětů, přehled zpráv a možnost
        jejich spravování, nebo třeba absence. Při troše štěstí dojde i na integraci systému Strava, který
        mnohé školy používají pro výběr jídel ve školní jídelně - stránka by tak zobrazovala, co bude dnes
        k obědu.
      </p>
      <p>
        Jednou z prioritních funkcí, která aplikace zatím postrádá, je možnost ji prohlížet kompletně offline.
        Bude tedy stačit, abyste web třeba ráno jednou načetli, a poté pokaždé když se podíváte na tuto stránku -
        a to i bez připojení k itnernetu - uvidíte rozvrh a známky, a budete moci plně interagovat s touto webovou
        aplikací.
      </p>
      <p>
        Projekt vychází z původního projektu Václava Šraiera <a href="https://bakaweb.tk" target="_blank">Bakaweb.tk</a>, který už
        dlouho před tímto projektem uměl zobrazovat průměry u všech předmětů. Díky jeho knihovně <a href="https://github.com/vakabus/pybakalib/" target="_blank">pybakalib</a>
        bylo možné tohoto dosáhnout. Pokud máte zájem o podrobnější informace o tom, jak protokol Bakalářů funguje, v
        repozitáři <a href="">bakalari-api</a>
        je komunikace s webovou službou podrobně popsána.
      </p>
      <p>
        V případě jakýchkoli žádostí, otázek, nebo návrhů, mě neváhejte <a href="/contact">kontaktovat</a> (<a href="https://github.com/soptikha2/" target="_blank">GitHub</a>).
      </p>
      <p>
        Petr Šťastný
      </p>
    </section>
  </div>

  <script>
    if ('serviceWorker' in navigator) {
      navigator.serviceWorker
        .register('/offlineServiceWorker.js')
        .then(function () { console.log("Service Worker Registered"); });
    }
  </script>
  <script src="/js/selectSchoolFromList.js"></script>

""");

  await connect.include("/webapp/view/templates/tail.html");

  return null;
}
