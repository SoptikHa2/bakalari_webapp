import 'tools/db.dart';

main(List<String> args) async {
  await DB.initializeDb();

  await DB.addSchool('abc');
  await DB.addSchool('def');
  print(await DB.getSchools());
}