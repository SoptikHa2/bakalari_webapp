import 'tools/log.dart';
import 'tools/auth.dart';
import 'controller/root.dart';
import 'controller/student.dart';
import 'controller/privacyPolicy.dart';

class Config {
  static Map<String, dynamic> routing = {
    "get:/": root,
    "get:/privacy_policy": privacyPolicy,
    "post:/student": loginStudent,
    "get:/student": getStudent
    //"/admin/": admin
  };
  static dynamic filterRouting = {
    "/.*": log,
    "post:/student/.*": auth,
    "post:/admin/.*": authAdmin
  };
  static Map<String, dynamic> errorRouting = {
    "404": "/html/404.html",
    "500": "/html/500.html"
  };
}
