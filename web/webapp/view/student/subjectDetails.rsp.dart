//Auto-generated by RSP Compiler
//Source: subjectDetails.rsp.html
library subjectDetails_rsp;

import 'dart:async';
import 'dart:io';
import 'package:stream/stream.dart';

/** Template, subjectDetailsView, for rendering the view. */
Future subjectDetailsView(HttpConnect connect, {dynamic subject}) async {
  HttpResponse response = connect.response;
  if (!Rsp.init(connect, "text/html; charset=utf-8"))
    return null;

  await connect.include("/webapp/view/templates/head.html");

  response.write("""

<div class="content">
  <h1>""");

  response.write(Rsp.nnx(subject.subjectLong));


  response.write("""</h1>
</div>
""");

  await connect.include("/webapp/view/templates/tail.html");

  return null;
}
