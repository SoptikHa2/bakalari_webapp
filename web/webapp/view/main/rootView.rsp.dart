//Auto-generated by RSP Compiler
//Source: rootView.rsp.html
library rootView_rsp;

import 'dart:async';
import 'dart:io';
import 'package:stream/stream.dart';

/** Template, rootView, for rendering the view. */
Future rootView(HttpConnect connect, {List<String> urls, dynamic timetable, String errorDescription, String timetableOld}) async {
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

        <input name="bakawebUrl" type="text" list="schoolUrls" placeholder="bakalari.ceskolipska.cz" />
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
        <input name="login" type="text" placeholder="Uživatelské jméno">
        <input name="password" type="password" placeholder="Heslo">

        <button type="submit" class="pure-button pure-button-primary">Přihlásit</button>
      </fieldset>
    </form>
  </div>
  <div class="content">
    <h1 class="content-subhead">Funkce</h1>
    <p>
      Cílem projektu <i>Bakaláři: a tentokrát lépe</i>
      je vytvořit webovou aplikaci, která by dokázala kompletně nahradit
      původní aplikaci Bakalářů, která je pomalá a na telefonech často
      téměř nepoužitelná.
    </p>
    <p>
      Aplikace už teď podporuje zobrazování rozvrhu, známek (včetně průměrů), úkolů,
      a přijatých zpráv. Další moduly budeme ještě přidávat.
    </p>
    <p>
      Všechny data cachujeme, takže vše vidíte přehledně na jednom místě - a rychle.
      I když zrovna nejste přihlášení, tak zde můžeme zobrazit rozvrh pro vaši třídu.
    </p>
    <h1 class="content-subhead">Rozvrh</h1>
""");

  if (timetable == null) {

    response.write("""    <p>
      Jakmile se v tomto prohlížeči alespoň jednou přihlásíte,
      uvidíte zde aktuální rozvrh pro vaši třídu -
      i pokud zrovna nebudete přihlášeni.
    </p>
""");

  } else {

    if (timetableOld != '') {

      response.write("""    <p>
      """);

      response.write(Rsp.nnx(timetableOld));


      response.write("""

    </p>
""");
    } //if

    response.write("""    <table class="pure-table">
      <thead>
        <tr></tr>
        <tr>
          <th></th>
""");

    for (var hour in timetable.times) {

      response.write("""          <th title=\"""");

      response.write(Rsp.nnx(hour.beginTime));


      response.write(""" - """);

      response.write(Rsp.nnx(hour.endTime));


      response.write("""">
            """);

      response.write(Rsp.nnx(hour.caption));


      response.write("""

          </th>
""");
    } //for

    response.write("""        </tr>
      </thead>
      <tbody>
""");

    for (var day in timetable.days) {

      response.write("""        <tr>
          <th>""");

      response.write(Rsp.nnx(day.shortName));


      response.write("""</th>
""");

      for (var lessons in day.lessons) {

        response.write("""          <td class="table-cell-small">
""");

        for (var lesson in lessons) {

          response.write("""            <div class="table-cell-standalone """);

          response.write(Rsp.nnx((lesson.change != null && lesson.change != '') ? 'lesson-change' : ''));


          response.write("""">
              <div class="table-cell-main">""");

          response.write(Rsp.nnx(lesson.subjectShort));


          response.write("""</div>
              <span class="table-cell-secondary">""");

          response.write(Rsp.nnx(lesson.teacherShort));


          response.write(Rsp.nnx((lesson.teacherShort == null
                || lesson.teacherShort == "" || lesson.classroom == null || lesson.classroom == "") ?
                '' : '$nbsp|$nbsp'));


          response.write(Rsp.nnx(lesson.classroom));


          response.write("""</span>
            </div>
""");
        } //for

        response.write("""          </td>
""");
      } //for

      response.write("""        </tr>
""");
    } //for

    response.write("""      </tbody>
    </table>
""");
  } //if

  response.write("""  </div>

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
