import 'dart:io';

import 'package:path/path.dart';
import 'package:stream/stream.dart';

import '../config.dart';
import '../tools/db.dart';
import '../view/general/lubosView.rsp.dart';

class SchoolListController {
  static void returnSchoolListInCsvByQuery(HttpConnect connect) async {
    var query = '';
    if (connect.request.uri.queryParameters.keys.contains('query')) {
      query = connect.request.uri.queryParameters['query'];
    }
    if (query.isEmpty) return;

    var schools = DB
        .getSchoolInfoFromQuery(query.split(' ').where((s) => s.isNotEmpty))
        .then((f) => f.take(Config.numberOfSchoolsInListSearch));

    connect.response..writeAll(await schools, '\n');
  }

  static void generateNewSchoolList(HttpConnect connect) async {
    
  }
}
