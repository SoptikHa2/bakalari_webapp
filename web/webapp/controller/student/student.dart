import 'dart:io';

import 'package:rikulo_commons/io.dart';
import 'package:rikulo_commons/mirrors.dart';
import 'package:stream/stream.dart';
import '../../config.dart';
import '../../model/complexStudent.dart';
import '../../tools/securityTools.dart';
import '../../tools/tools.dart';
import '../../view/student/studentView.rsp.dart';
import 'package:bakalari/bakalari.dart';
import '../../tools/db.dart';

class StudentBaseController {
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
      bakaweb = new Bakalari(post.bakawebUrl);
      await bakaweb.logIn(post.login, post.password);
      // refresh info, write it into DB and add access token into cookies
      String encryptionKey = SecurityTools.generateEncryptionKey();
      var guid = await DB.saveStudentInfo(
          ComplexStudent.create(bakaweb.student, bakaweb.school),
          encryptionKey);
      DB.logLogin(bakaweb.student, bakaweb.school);

      bakaweb.getTimetable().then((t) => DB.updateStudentInfo(
          guid, ((student) => student.update(timetable: t)), encryptionKey));
      bakaweb.getTimetablePermanent().then((t) => DB.updateStudentInfo(guid,
          ((student) => student.update(permTimetable: t)), encryptionKey));
      bakaweb.getNextWeekTimetable().then((t) => DB.updateStudentInfo(guid,
          ((student) => student.update(nextWeekTimetable: t)), encryptionKey));
      bakaweb.getGrades().then((g) => DB.updateStudentInfo(
          guid, ((student) => student.update(grades: g)), encryptionKey));
      bakaweb.getSubjects().then((s) => DB.updateStudentInfo(
          guid, ((student) => student.update(subjects: s)), encryptionKey));
      bakaweb.getHomework().then((h) => DB.updateStudentInfo(
          guid, ((student) => student.update(homework: h)), encryptionKey));
      bakaweb.getMessages().then((m) => DB.updateStudentInfo(
          guid, ((student) => student.update(messages: m)), encryptionKey));

      connect.response.cookies.add(Cookie("studentID", guid)
        ..expires = DateTime.now()
            .add(Duration(days: Config.daysHowLongIsSessionCookieStored)));
      connect.response.cookies.add(Cookie(
          "username", Tools.encodeCookieValue(post.login))
        ..expires = DateTime.now().add(
            Duration(days: Config.daysHowLongIsClassIdentifierCookieStored)));
      connect.response.cookies.add(Cookie(
          "schoolURI", Tools.encodeCookieValue(bakaweb.school.bakawebLink))
        ..expires = DateTime.now().add(
            Duration(days: Config.daysHowLongIsClassIdentifierCookieStored)));
      connect.response.cookies.add(Cookie("encryptionKey", encryptionKey)
        ..expires = DateTime.now()
            .add(Duration(days: Config.daysHowLongIsSessionCookieStored)));
    } catch (e) {
      print(e);
      if (connect.request.uri.queryParameters.keys.contains('refresh') &&
          connect.request.uri.queryParameters['refresh'] == '1') {
        return connect.redirect(
            '/refresh?error=cannot_connect&filledURI=${Uri.encodeComponent(post.bakawebUrl)}&filledUsername=${Uri.encodeComponent(post.login)}');
      }
      return connect.redirect(
          '/?error=cannot_connect&filledURI=${Uri.encodeComponent(post.bakawebUrl)}&filledUsername=${Uri.encodeComponent(post.login)}');
    }

    // Forward to itself, just GET
    return await getInfo(connect);
  }

  // GET
  static Future getInfo(HttpConnect connect) async {
    if (connect.request.uri.queryParameters.containsKey('refresh') &&
        connect.request.uri.queryParameters['refresh'] == '1') {
      // Redirect to no-refresh URL, as the refresh was successful and to cache mess things up
      // when we don't do this.
      return connect.redirect('/student');
    }

    var result = await SecurityTools.loginAsStudent(connect.request.cookies);
    ComplexStudent student = null;
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
    var nextWeekTimetable = student.nextWeekTimetable;

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
    if (student.grades != null && student.subjects != null) {
      averages =
          Tools.gradesToSubjectAverages(student.grades, student.subjects);
    }

    // Change status code to 201 (Created) if we already have all the information we need,
    // so there is no need to ask for more
    if ((student.grades != null &&
            student.homework != null &&
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

    var timetableRow = null;
    if (timetable != null && nextWeekTimetable != null) {
      timetableRow = Tools.whichDayShouldIShowInOneDayTimetable(
          timetable, nextWeekTimetable);
    }

    return studentView(connect,
        timetableRow: timetableRow,
        lastRefresh: sinceLastRefresh,
        averages: averages);
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
      if (r"\.[a-z]{2,3}$".allMatches(bakawebUrl).length > 0) {
        bakawebUrl = bakawebUrl + '/login.aspx';
      }
    }

    return loginValid && passwordValid && bakawebUrlIsValid;
  }
}
