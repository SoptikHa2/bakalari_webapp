import 'package:bakalari/bakalari.dart';
import 'package:stream/stream.dart';
import 'db.dart';

class ListOfSchools {
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
