//Auto-generated by RSP Compiler
//Source: logView.rsp.html
library logView_rsp;

import 'dart:async';
import 'dart:io';
import 'package:stream/stream.dart';

/** Template, logView, for rendering the view. */
Future logView(HttpConnect connect, {dynamic loginsPerDay, dynamic accessesPerDay}) async {
  HttpResponse response = connect.response;
  if (!Rsp.init(connect, "text/html; charset=utf-8"))
    return null;

  await connect.include("/webapp/view/templates/adminHead.html");

  response.write("""<div class="content">
    <h1>Vizualizace</h1>
    <p>
        <canvas id="hitsPerDay" width="400" height="200"></canvas>
    </p>
    <p>
        <canvas id="loginsPerDay" width="400" height="200"></canvas>
    </p>
    <p>
        <canvas id="schoolsPerDay" width="400" height="200"></canvas>
    </p>
    <h1>Ke stažení</h1>
    <p>Vše bude ve formátu JSON.</p>
    <h2>Log přihlášení studentů</h2>
    <form class="pure-form" action="/admin/log/raw/download/logStudentLogin" method="GET">
        <fieldset>
            <button type="submit" class="pure-button pure-button-primary">Stáhnout</button>
        </fieldset>
    </form>
</div>

<!-- Load chart.js library -->
<script src="/js/Chart.bundle.min.js"></script>
""");

  if (loginsPerDay != null) {

    response.write("""<script>
/* LOGINS PER DAY VISUALISATION */
var ctx = document.getElementById("loginsPerDay");
var myChart = new Chart(ctx, {
    type: 'line',
    data: {
        labels: [ """);

    response.write(Rsp.nnx(loginsPerDay.keys.map((key) => '"$key"').toList().join(', '), encode: 'none'));


    response.write(""" ],
        datasets: [{
            label: "Logins per day",
            data: [ """);

    response.write(Rsp.nnx(loginsPerDay.keys.map((key) => loginsPerDay[key]).toList().join(', '), encode: 'none'));


    response.write("""],
        }]
    }
});
</script>
""");
  } //if

  if (accessesPerDay != null) {

    response.write("""<script>
/* HITS PER DAY VISUALISATION */
var ctx = document.getElementById("hitsPerDay");
var myChart = new Chart(ctx, {
    type: 'line',
    data: {
        labels: [ """);

    response.write(Rsp.nnx(accessesPerDay.keys.map((key) => '"$key"').toList().join(', '), encode: 'none'));


    response.write(""" ],
        datasets: [{
            label: "Unique hits per day",
            data: [ """);

    response.write(Rsp.nnx(accessesPerDay.keys.map((key) => accessesPerDay[key]).toList().join(', '), encode: 'none'));


    response.write("""],
        }]
    }
});
</script>
""");
  } //if

  response.write("""

""");

  await connect.include("/webapp/view/templates/tail.html");

  return null;
}