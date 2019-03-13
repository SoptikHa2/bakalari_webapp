import 'package:bakalari/bakalari.dart';
import 'package:stream/stream.dart';
import 'db.dart';

class ListOfSchools {
  /// Load list of cities from Bakalari, and for each city,
  /// get list of school. When it's done, save everything in
  /// database.
  static void updateListOfSchools(HttpConnect connect) async {
    var cities = await Bakalari.getListOfCities();
    var schoolsAndUrls = Map<String, String>();

    for (var city in cities) {
      try {
        var schools = await Bakalari.getListOfSchools(city);
        for(var school in schools){
          schoolsAndUrls[school.name] = school.bakawebLink;
        }
      } catch (e) {
        print('Failed to fetch schools for city $city');
      }
    }

    await DB.updateSchoolInfoDB(schoolsAndUrls);
  }
}
