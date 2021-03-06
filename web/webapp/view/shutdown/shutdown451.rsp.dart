//Auto-generated by RSP Compiler
//Source: shutdown451.rsp.html
library shutdown451_rsp;

import 'dart:async';
import 'dart:io';
import 'package:stream/stream.dart';

/** Template, shutdown451View, for rendering the view. */
Future shutdown451View(HttpConnect connect, {reason}) async {
  HttpResponse response = connect.response;
  if (!Rsp.init(connect, "text/html; charset=utf-8"))
    return null;

  await connect.include("/webapp/view/templates/head.html");

  response.write("""<div class="content">
    <h1>Unavailable For Legal Reasons</h1>
    <a href="https://en.wikipedia.org/wiki/HTTP_451"><img src="/other/fahrenheit-451-burning-books.jpg"
            title="Source: teemingbrain.com" /></a>
    <p>""");

  response.write(Rsp.nnx(reason, encode: 'none'));


  response.write("""</p>
</div>
""");

  await connect.include("/webapp/view/templates/tail.html");

  return null;
}
