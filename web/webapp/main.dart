import 'package:stream/stream.dart';
import 'config.dart';
import 'tools/db.dart';

main(List<String> args) async {
  var server = StreamServer(
    uriMapping: Config.routing,
    filterMapping: Config.filterRouting,
    errorMapping: Config.errorRouting
  );
  DB.initializeDb().whenComplete(() => server.start());
}

void currentTime(HttpConnect connect){
  connect.response
    .write("<html><body>It's ${new DateTime.now()}</body></html>");
}