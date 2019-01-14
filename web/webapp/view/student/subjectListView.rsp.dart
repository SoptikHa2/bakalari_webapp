//Auto-generated by RSP Compiler
//Source: subjectListView.rsp.html
library subjectListView_rsp;

import 'dart:async';
import 'dart:io';
import 'package:stream/stream.dart';

/** Template, subjectListView, for rendering the view. */
Future subjectListView(HttpConnect connect, {List<dynamic> subjects, Map<String, double> grades, List<dynamic> absences}) async {
  HttpResponse response = connect.response;
  if (!Rsp.init(connect, "text/html; charset=utf-8"))
    return null;

  await connect.include("/webapp/view/templates/head.html");

  response.write("""<div class="content">
    <h1 class="content-subhead">Předměty</h1>
""");

  for (var subject in subjects) {
var grade = null;
    if(grades != null)
        grade = grades[subject.subjectLong];

    response.write("""

    <div class="listDiv">
        <h2><a href="/student/subject/""");

    response.write(Rsp.nnx(subject.subjectLong));


    response.write("""">""");

    response.write(Rsp.nnx(subject.subjectLong));


    response.write("""</a></h2>
        <p>
            """);

    response.write(Rsp.nnx(subject.teacherName));


    response.write(""" (""");

    response.write(Rsp.nnx(subject.teacherEmail));


    response.write(""")
        </p>
        <br />
        <p>
            <strong>
""");

    if (grade != null) {

      response.write("""            """);

      response.write(Rsp.nnx(grade.toStringAsFixed(2)));


      response.write("""

""");
    } //if

    response.write("""            </strong>
        </p>
        <p>
        </p>
    </div>
""");
  } //for

  response.write("""</div>
""");

  await connect.include("/webapp/view/templates/tail.html");

  return null;
}
