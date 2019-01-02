import 'package:stream/rspc.dart' show build;

main(List<String> args) {
  for(var filename in args){
    print('Building $filename');
  }
  build(args);
}
