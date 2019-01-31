//Auto-generated by RSP Compiler
//Source: subjectDetails.rsp.html
library subjectDetails_rsp;

import 'dart:async';
import 'dart:io';
import 'package:stream/stream.dart';

/** Template, subjectDetailsView, for rendering the view. */
Future subjectDetailsView(HttpConnect connect, {dynamic subject, dynamic grades, String prumer}) async {
  HttpResponse response = connect.response;
  if (!Rsp.init(connect, "text/html; charset=utf-8"))
    return null;

  await connect.include("/webapp/view/templates/head.html");

  response.write("""

<div class="content">
  <noscript>
    <p>
      Zapněte JavaScript pro
      kalkulaci průměru
    </p>
  </noscript>
  <h1>""");

  response.write(Rsp.nnx(subject.subjectLong));


  response.write("""</h1>
  <a href="/student">Zpět</a>
  <p>""");

  response.write(Rsp.nnx(subject.teacherName));


  response.write(""" (""");

  response.write(Rsp.nnx(subject.teacherEmail));


  response.write(""")</p>
""");

  if (grades != null) {

    response.write("""  <h2>Průměr: """);

    response.write(Rsp.nnx(prumer));


    response.write("""</h2>
  <table class="grades-table">
    <tr>
      <th>Datum</th>
      <th>Titulek</th>
      <th>Známka</th>
      <th>Váha</th>
    </tr>
""");

    for (var grade in grades) {

      response.write("""  <tr class="grades">
    <td>""");

      response.write(Rsp.nnx(grade.date.day));


      response.write(""". """);

      response.write(Rsp.nnx(grade.date.month));


      response.write("""</td>
    <td>""");

      response.write(Rsp.nnx(grade.caption));


      response.write("""</td>
    <td name="value">""");

      response.write(Rsp.nnx(grade.numericValue == null ? grade.value : (grade.numericValue.round() == grade.numericValue ? grade.numericValue.toInt() : grade.numericValue.floor().toString() + '-')));


      response.write("""</td>
    <td name="weight">""");

      response.write(Rsp.nnx(grade.weight));


      response.write("""</td>
  </tr>
""");
    } //for

    response.write("""  </table>
  <form class="pure-form">
    <fieldset>
      <label for="new-grade">Známka</label>
      <input name="new-grade" id="new-grade" type="text" placeholder="2-" autocomplete="off" onkeyup="updateSubjectAverage();">
      <label for="new-weight">Váha</label>
      <input name="new-weight" id="new-weight" type="number" value="4" autocomplete="off" min="1" max="12" onchange="updateSubjectAverage();">
    </fieldset>
  </form>
  <p id="average"></p>
""");
  } //if

  response.write("""</div>

<script src="/js/subjectDetails.js"></script>
""");

  await connect.include("/webapp/view/templates/tail.html");

  return null;
}
