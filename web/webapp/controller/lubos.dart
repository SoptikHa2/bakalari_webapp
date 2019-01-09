import 'dart:io';

import 'package:path/path.dart';
import 'package:stream/stream.dart';

import '../view/general/lubosView.rsp.dart';

class Lubos {
  static Future showLubosCites(HttpConnect connect) {
    var file = File(join(dirname(Platform.script.toFilePath()), "lubos.csv"));
    var cites = List<dynamic>();
    for (var line in file.readAsLinesSync()) {
      var columns = line.split(';');
      cites.add(columns);
    }

    return lubosView(connect, cites: cites);
  }
}
