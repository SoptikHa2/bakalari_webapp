import 'package:stream/stream.dart';

import '../config.dart';
import '../tools/db.dart';
class SchoolListController {
  static void returnSchoolListInCsvByQuery(HttpConnect connect) async {
    var query = '';
    if (connect.request.uri.queryParameters.keys.contains('query')) {
      query = connect.request.uri.queryParameters['query'];
    }
    if (query.isEmpty) return;

    var schools = DB
        .getSchoolInfoFromQuery(query.split(' ').where((s) => s.isNotEmpty).toList())
        .then((f) => f.take(Config.numberOfSchoolsInListSearch));

    connect.response..writeAll(await schools, '\n');
  }
}
