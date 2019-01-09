import 'dart:io';

import 'package:stream/stream.dart';

import '../../view/admin/adminLogView.rsp.dart';

class Log {
  static Future showLogPage(HttpConnect connect) {
    return adminLogView(connect);
  }

  static Future downloadRawLog(HttpConnect connect){
    
  }
}
