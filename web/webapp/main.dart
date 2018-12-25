import 'package:stream/stream.dart';
import 'config.dart';

main(List<String> args) {
  var server = StreamServer(
    uriMapping: Config.routing,
    filterMapping: Config.filterRouting,
    errorMapping: Config.errorRouting
  );
  server.start();
}

void currentTime(HttpConnect connect){
  connect.response
    .write("<html><body>It's ${new DateTime.now()}</body></html>");
}