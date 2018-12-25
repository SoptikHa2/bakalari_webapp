import 'tools/log.dart';
import 'tools/auth.dart';
import 'controller/root.dart';
import 'controller/student.dart';

class Config {
  static Map<String, dynamic> routing = {
    "/": root,
    //"/student/": student 
  };
  static dynamic filterRouting = {
    "/.*": log,
    "/student/.*": auth,
    "/admin/.*": authAdmin
  };
  static Map<String, dynamic> errorRouting = {
    "404": "/html/404.html",
    "500": "/html/500.html"
  };
}
