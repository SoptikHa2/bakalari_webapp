//Auto-generated by RSP Compiler
//Source: studentView.rsp.html
library studentView_rsp;

import 'dart:async';
import 'dart:io';
import 'package:stream/stream.dart';

/** Template, studentView, for rendering the view. */
Future studentView(HttpConnect connect, {String errorDescription, dynamic timetable, dynamic permTimetable, dynamic averages,
String lastRefresh,
String lastMailInfo, String urgentAbsence, String urgentHomeworks}) async {
  HttpResponse response = connect.response;
  if (!Rsp.init(connect, "text/html; charset=utf-8"))
    return null;

  await connect.include("/webapp/view/templates/head.html");
String nbsp = "\u{00A0}";

  response.write("""

<div class="content">
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

  response.write("""    <noscript>
        <aside class="errorBar">
            <p>
                Nemáte zapnutý JavaScript, stránka tedy sama nenačítá
                přijaté informace. Můžete je načíst manuálně obnovením
                stránky (<span style="background-color: lightgray">F5</span>)
            </p>
        </aside>
    </noscript>
    <div class="pure-g" id="main">
        <div class="pure-u-1 pure-u-md-1-4" id="znamky">
            <h1 class="content-subhead">Průměry</h1>
""");

  if (averages == null) {

    response.write("""            <p>
                Načítám známky, za chvíli to bude...
            </p>
""");

  } else {

    response.write("""            <table class="pure-table">
                <tbody>
""");

    for (var subject in averages.keys) {

      response.write("""                    <tr>
                        <td>
                            <a href="/student/subject/""");

      response.write(Rsp.nnx(subject));


      response.write("""">""");

      response.write(Rsp.nnx(subject));


      response.write("""</a>
                        </td>
                        <td>
                            """);

      response.write(Rsp.nnx(averages[subject].toStringAsPrecision(3)));


      response.write("""

                        </td>
                    </tr>
""");
    } //for

    response.write("""                </tbody>
            </table>
""");
  } //if

  response.write("""        </div>
        <div class="pure-u-1 pure-u-md-2-3" id="rozvrh">
            <h1 class="content-subhead">Rozvrh</h1>
""");

  if (timetable == null) {

    response.write("""            <p>
                Načítám rozvrh, za chvíli tady bude...
            </p>
""");

  } else {

    if (timetable != null && permTimetable != null) {

      response.write("""            <button id="butSwitchTimetableToToday" class="pure-button pure-button-primary button-switch" toggleon="tabletoday" toggleoff="tableperm" oppButton="butSwitchTimetableToPerm">Dnešní</button>
            <button id="butSwitchTimetableToPerm" class="pure-button button-switch" toggleon="tableperm" toggleoff="tabletoday" oppButton="butSwitchTimetableToToday">Stálý</button>
""");
    } //if

    response.write("""            <table class="pure-table" id="tabletoday">
                <thead>
                    <tr></tr>
                    <tr>
                        <th></th>
""");

    for (var hour in timetable.times) {

      response.write("""                        <th title=\"""");

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

    response.write("""                    </tr>
                </thead>
                <tbody>
""");

    for (var day in timetable.days) {

      response.write("""                    <tr>
                        <th>""");

      response.write(Rsp.nnx(day.shortName));


      response.write("""</th>
""");

      for (var lessons in day.lessons) {

        response.write("""                        <td class="table-cell-small">
""");

        for (var lesson in lessons) {

          response.write("""                            <div class="table-cell-standalone """);

          response.write(Rsp.nnx((lesson.change != null && lesson.change != '') ? 'lesson-change' : ''));


          response.write("""">
                                <div class="table-cell-main">""");

          response.write(Rsp.nnx(lesson.subjectShort));


          response.write("""</div>
                                <span class="table-cell-secondary">""");

          response.write(Rsp.nnx(lesson.teacherShort));


          response.write(Rsp.nnx((lesson.teacherShort ==
                                    null
                                    || lesson.teacherShort == "" || lesson.classroom == null || lesson.classroom == "")
                                    ?
                                    '' : '$nbsp|$nbsp'));


          response.write(Rsp.nnx(lesson.classroom));


          response.write("""</span>
                            </div>
""");
        } //for

        response.write("""                        </td>
""");
      } //for

      response.write("""                    </tr>
""");
    } //for

    response.write("""                </tbody>
            </table>
""");

    if (permTimetable != null) {

      response.write("""            <table class="pure-table" id="tableperm" style="display: none;">
                <thead>
                    <tr></tr>
                    <tr>
                        <th></th>
""");

      for (var hour in permTimetable.times) {

        response.write("""                        <th title=\"""");

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

      response.write("""                    </tr>
                </thead>
                <tbody>
""");

      for (var day in permTimetable.days) {

        response.write("""                    <tr>
                        <th>""");

        response.write(Rsp.nnx(day.shortName));


        response.write("""</th>
""");

        for (var lessons in day.lessons) {

          response.write("""                        <td class="table-cell-small">
""");

          for (var lesson in lessons) {

            response.write("""                            <div class="table-cell-standalone """);

            response.write(Rsp.nnx((lesson.change != null && lesson.change != '') ? 'lesson-change' : ''));


            response.write("""">
                                <div class="table-cell-main">""");

            response.write(Rsp.nnx(lesson.subjectShort));


            response.write("""</div>
                                <span class="table-cell-secondary">""");

            response.write(Rsp.nnx(lesson.teacherShort));


            response.write(Rsp.nnx((lesson.teacherShort ==
                                    null
                                    || lesson.teacherShort == "" || lesson.classroom == null || lesson.classroom == "")
                                    ?
                                    '' : '$nbsp|$nbsp'));


            response.write(Rsp.nnx(lesson.classroom));


            response.write("""</span>
                            </div>
""");
          } //for

          response.write("""                        </td>
""");
        } //for

        response.write("""                    </tr>
""");
      } //for

      response.write("""                </tbody>
            </table>
""");
    } //if
  } //if

  response.write("""            <div class="pure-u-1 pure-u-md-1-2" id="otherModules">
                <h1 class="content-subhead">Ostatní moduly</h1>
                <ul>
                    <li>
                        <a href="/student/grade">Přehled všech známek</a>
                    </li>
                    <li>
                        <a href="/student/message">Přehled zpráv</a>
                        """);

  response.write(Rsp.nnx(lastMailInfo == null ? '' : '(poslední zpráva $lastMailInfo)'));


  response.write("""

                    </li>
                    <li>
                        <a href="/student/absention">Přehled absencí</a>
                        """);

  response.write(Rsp.nnx(urgentAbsence == null ? '' : urgentAbsence));


  response.write("""

                    </li>
                    <li>
                        <a href="/student/homework">Přehled domácích úkolů</a>
                        """);

  response.write(Rsp.nnx(urgentHomeworks == null ? '' : urgentHomeworks));


  response.write("""

                    </li>
                    <li>
                        <a href="/student/subject">Přehled předmětů</a>
                    </li>
                </ul>
            </div>
        </div>
    </div>
</div>
""");

  if (lastRefresh != null) {

    response.write("""<p style="text-align: center">
    To co vidíte na této stránce je """);

    response.write(Rsp.nnx(lastRefresh));


    response.write(""" staré.
    <a href="/refresh"><button class="pure-button">Obnovit</button></a>
</p>
""");
  } //if

  response.write("""

<script src="../../js/buttonSwitch.js"></script>
<script src="../../js/studentRefresh.js"></script>
""");

  await connect.include("/webapp/view/templates/tail.html");

  return null;
}
