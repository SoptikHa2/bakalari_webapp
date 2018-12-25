import 'package:stream/stream.dart';
import '../view/studentView.rsp.dart';

// POST
Future loginStudent(HttpConnect connect) {
  
  return studentView(connect);
}

// GET
Future getStudent(HttpConnect connect) {
  
  return studentView(connect);
}