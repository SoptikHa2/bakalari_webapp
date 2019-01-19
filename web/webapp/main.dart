import 'dart:io';

import 'package:path/path.dart';
import 'package:stream/stream.dart';
import 'config.dart';
import 'tools/db.dart';

main(List<String> args) async {
  var server = StreamServer(
    uriMapping: Config.routing,
    filterMapping: Config.filterRouting,
    errorMapping: Config.errorRouting
  );
  print('Database will be loaded from ' + join(dirname(Platform.script.toFilePath()), "main.db"));
  DB.initializeDb().whenComplete(() => server.start());
}