import 'dart:io';

import 'package:rikulo_commons/io.dart';
import 'package:rikulo_commons/mirrors.dart';
import 'package:stream/stream.dart';
import '../../config.dart';
import '../../model/complexStudent.dart';
import '../../tools/tools.dart';
import '../../view/student/studentView.rsp.dart';
import 'package:bakalari/bakalari.dart';
import '../../tools/db.dart';

class Student {
  // POST
  static Future login(HttpConnect connect) async {
    // Decode
    var postParameters = await HttpUtil.decodePostedParameters(connect.request);
    var post = StudentLoginPostParams();
    ObjectUtil.inject(post, postParameters);
    if (!post.validate()) {
      if (connect.request.uri.queryParameters.keys.contains('refresh') &&
          connect.request.uri.queryParameters['refresh'] == '1') {
        return connect.redirect('/refresh?error=invalid_structure');
      }
      return connect.redirect("/?error=invalid_structure");
    }

    Bakalari bakaweb = null;
    try {
      bakaweb = new Bakalari(Uri().resolve(post.bakawebUrl));
      await bakaweb.logIn(post.login, post.password);
      // refresh info, write it into DB and add access token into cookies
      var guid = await DB.saveStudentInfo(
          ComplexStudent.create(bakaweb.student, bakaweb.school));
      DB.logLogin(bakaweb.student, bakaweb.school, guid);
      DB.addSchool(post.bakawebUrl);

      bakaweb.getTimetable().then((t) => DB.updateStudentInfo(
          guid, ((student) => student.update(timetable: t))));
      bakaweb.getTimetablePermanent().then((t) => DB.updateStudentInfo(
          guid, ((student) => student.update(permTimetable: t))));
      bakaweb.getGrades().then((g) =>
          DB.updateStudentInfo(guid, ((student) => student.update(grades: g))));
      bakaweb.getSubjects().then((s) => DB.updateStudentInfo(
          guid, ((student) => student.update(subjects: s))));
      bakaweb.getHomeworks().then((h) => DB.updateStudentInfo(
          guid, ((student) => student.update(homeworks: h))));
      bakaweb.getMessages().then((m) => DB.updateStudentInfo(
          guid, ((student) => student.update(messages: m))));

      connect.response.cookies.add(Cookie("studentID", guid)
        ..expires = DateTime.now()
            .add(Duration(days: Config.daysHowLongIsSessionCookieStored)));
      connect.response.cookies.add(Cookie(
          "schoolName", Tools.encodeCookieValue(bakaweb.school.name))
        ..expires = DateTime.now().add(
            Duration(days: Config.daysHowLongIsClassIdentifierCookieStored)));
      connect.response.cookies.add(Cookie(
          "className", Tools.encodeCookieValue(bakaweb.student.schoolClass))
        ..expires = DateTime.now().add(
            Duration(days: Config.daysHowLongIsClassIdentifierCookieStored)));
    } catch (e) {
      print(e);
      if (connect.request.uri.queryParameters.keys.contains('refresh') &&
          connect.request.uri.queryParameters['refresh'] == '1') {
        return connect.redirect('/refresh?error=cannot_connect');
      }
      return connect.redirect('/?error=cannot_connect');
    }

    // Forward to itself, just GET
    return await getInfo(connect);
  }

  // GET
  static Future getInfo(HttpConnect connect) async {
    var result = await Tools.loginAsStudent(connect.request.cookies);
    var student = null;
    if (result.success) {
      student = result.result;
    } else {
      if (result.requestLogout) {
        return connect.redirect('/logout');
      } else {
        return connect.redirect('/?error=not_logged_in');
      }
    }

    var timetable = student.timetable;
    var permTimetable = student.permTimetable;

    // Refresh time
    var timeSinceLastRefresh =
        DateTime.now().difference(student.refresh ?? DateTime.now());
    String sinceLastRefresh = null;
    if (timeSinceLastRefresh.inHours >= Config.hoursUntilRefreshButtonIsShown) {
      if (timeSinceLastRefresh.inHours < 24)
        sinceLastRefresh =
            Tools.hoursToStringWithUnit(timeSinceLastRefresh.inHours);
      else
        sinceLastRefresh =
            Tools.daysToStringWithUnit(timeSinceLastRefresh.inDays);
    }

    // Averages
    Map<String, double> averages = null;
    if (student.grades != null) {
      averages = Tools.gradesToSubjectAverages(student.grades);
    }

    // Change status code to 201 (Created) if we already have all the information we need,
    // so there is no need to ask for more
    if ((student.grades != null &&
            student.homeworks != null &&
            student.messages != null &&
            student.subjects != null &&
            student.timetable != null) ||
        // If some problem happens, pretend everything is OK
        // after 2 minutes
        DateTime.now()
                .difference(student.refresh ?? DateTime.now())
                .inMinutes >=
            2) {
      connect.response.statusCode = 201;
    }

    return studentView(connect,
        timetable: timetable,
        permTimetable: permTimetable,
        lastRefresh: sinceLastRefresh,
        averages: averages);
  }

  // POST
  static void loginJson(HttpConnect connect) async {
    var postParameters = await HttpUtil.decodePostedParameters(connect.request);
    var post = StudentLoginPostParams();
    ObjectUtil.inject(post, postParameters);
    if (!post.validate()) {
      connect.response
        ..headers.contentType = ContentType.json
        ..statusCode = 400
        ..write(
            '{"error":{"type": "invalidStructure", "description": "String bakawebUrl, String login, String password"}}');
      return;
    }

    try {
      var bakaweb = new Bakalari(Uri().resolve(post.bakawebUrl));
      await bakaweb.logIn(post.login, post.password);
      // refresh info, write it into DB and add access token into cookies
      var guid = await DB.saveStudentInfo(
          ComplexStudent.create(bakaweb.student, bakaweb.school));
      DB.logLogin(bakaweb.student, bakaweb.school, guid);
      DB.addSchool(post.bakawebUrl);

      bakaweb.getTimetable().then((t) => DB.updateStudentInfo(
          guid, ((student) => student.update(timetable: t))));
      bakaweb.getGrades().then((g) =>
          DB.updateStudentInfo(guid, ((student) => student.update(grades: g))));
      bakaweb.getSubjects().then((s) => DB.updateStudentInfo(
          guid, ((student) => student.update(subjects: s))));
      bakaweb.getHomeworks().then((h) => DB.updateStudentInfo(
          guid, ((student) => student.update(homeworks: h))));
      bakaweb.getMessages().then((m) => DB.updateStudentInfo(
          guid, ((student) => student.update(messages: m))));
      connect.response
        ..headers.contentType = ContentType.json
        ..write('{"result":{"guid": "$guid"}}');
    } catch (e) {
      print(e);
      connect.response
        ..headers.contentType = ContentType.json
        ..statusCode = 500
        ..write(
            '{"error":{"type": "unknown", "description":"An error occured while getting content, check bakaweb url"}}');
    }
  }

  // GET
  static void getInfoJson(HttpConnect connect) async {
    if (!connect.request.uri.queryParameters.containsKey('studentID')) {
      connect.response
        ..headers.contentType = ContentType.json
        ..statusCode = 400
        ..write(
            '{"error": {"type": "invalidStructure", "description": "Pass studentID query parameter or send POST request to log in"}}');
      return;
    }

    var result = await Tools.loginAsStudent(connect.request.cookies);
    var student = null;
    if (result.success) {
      student = result.result;
    } else {
      connect.response
        ..headers.contentType = ContentType.json
        ..statusCode = 500
        ..write(
            '{"error":{"type": "unknown", "description":"An error occured while getting content, check if you passed corrent studentID. You can get new one by sending POST request"}}');
      return;
    }

    // Change status code to 201 (Created) if we already have all the information we need,
    // so there is no need to ask for more
    if ((student.grades != null &&
            student.homeworks != null &&
            student.messages != null &&
            student.subjects != null &&
            student.timetable != null) ||
        // If some problem happens, pretend everything is OK
        // after 2 minutes
        DateTime.now()
                .difference(student.refresh ?? DateTime.now())
                .inMinutes >=
            2) {
      connect.response.statusCode = 201;
    }

    connect.response
      ..headers.contentType = ContentType.json
      ..write(Tools.fromMapToStringyJson(student.toJson()));
  }
}

class StudentLoginPostParams {
  String bakawebUrl;
  String login;
  String password;

  bool validate() {
    var bakawebUrlRegex =
        RegExp("(http(s)?:\\/\\/|www\.)?(\\w+\\.)+cz(\\/\\w+(\\.\\w+)?)?\\/?");

    bool loginValid = login != null && login.isNotEmpty;
    bool passwordValid = password != null && password.isNotEmpty;
    bool bakawebUrlIsValid =
        bakawebUrl != null && bakawebUrlRegex.hasMatch(bakawebUrl);

    // Refine bakawebUrl
    if (bakawebUrlIsValid) {
      // Remove trailing /
      int firstTrailingSlash = -1;
      for (var i = bakawebUrl.length - 1; i >= 0; i--) {
        if (bakawebUrl[i] == '/')
          firstTrailingSlash = i;
        else
          break;
      }
      if (firstTrailingSlash != -1)
        bakawebUrl = bakawebUrl.substring(0, firstTrailingSlash);

      bakawebUrl = bakawebUrl.replaceFirst('www.', '');

      // If it doesn't start with http or https, we have to
      // add it there. Let's assume https
      if (!bakawebUrl.startsWith(new RegExp('http(s)?:\\/\\/'))) {
        bakawebUrl = "https://" + bakawebUrl;
      }
      // Add /login.aspx if it ends with domain
      if(r"\.[a-z]{2,3}$".allMatches(bakawebUrl).length > 0){
        bakawebUrl = bakawebUrl + '/login.aspx';
      }
    }

    return loginValid && passwordValid && bakawebUrlIsValid;
  }
}
