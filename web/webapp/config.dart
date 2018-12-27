import 'tools/log.dart';
import 'controller/root.dart';
import 'controller/student.dart';
import 'controller/logout.dart';
import 'view/privacyPolicyView.rsp.dart';
import 'view/restApi.rsp.dart';

class Config {
  static Map<String, dynamic> routing = {
    "get:/": Root.root,
    "get:/privacy_policy": privacyPolicyView,
    "get:/api": restApiView,
    "get:/logout": Logout.logoutUser,

    "post:/student": Student.login,
    "get:/student": Student.getInfo,
    //"/admin/": admin

    "post:/student/json": Student.loginJson,
    "get:/student/json": Student.getInfoJson,
  };
  static dynamic filterRouting = {
    "/.*": log,
  };
  static Map<String, dynamic> errorRouting = {
    "404": "/html/404.html",
    "500": "/html/500.html"
  };
}
