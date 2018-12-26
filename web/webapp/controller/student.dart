import 'dart:io';

import 'package:rikulo_commons/io.dart';
import 'package:rikulo_commons/mirrors.dart';
import 'package:stream/stream.dart';
import '../model/complexStudent.dart';
import '../view/studentView.rsp.dart';
import 'package:bakalari/bakalari.dart';
import '../tools/db.dart';

class Student {
  // POST
  static Future login(HttpConnect connect) async {
    // Decode
    var postParameters = await HttpUtil.decodePostedParameters(connect.request);
    var post = StudentLoginPostParams();
    ObjectUtil.inject(post, postParameters);
    if (!post.validate()) {
      return connect.redirect("/?error=invalid_structure");
    }

    Bakalari bakaweb = null;
    try {
      bakaweb = new Bakalari(Uri().resolve(post.bakawebUrl));
      await bakaweb.logIn(post.login, post.password);
      // refresh info, write it into DB and add access token into cookies
      var guid = await DB.saveStudentInfo(
          ComplexStudent.create(bakaweb.student, bakaweb.school));
      DB.logLogin(postParameters, guid);
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
      connect.response.cookies.add(Cookie("studentID", guid));
    } catch (e) {
      print(e);
      return connect.redirect('/?error=cannot_connect');
    }

    // Forward to itself, just GET
    return await getInfo(connect);
  }

  // GET
  static Future getInfo(HttpConnect connect) async {
    if (!connect.request.cookies.any((c) => c.name == "studentID")) {
      return connect.redirect('/?error=not_logged_in');
    }

    try {
      String guid = connect.request.cookies
          .singleWhere((c) => c.name == 'studentID')
          .value;

      ComplexStudent student = await DB.getStudent(guid);
      var timetable = student.timetable;
      var timeSinceLastRefresh = DateTime.now().difference(student.refresh ?? DateTime.now());
      String sinceLastRefresh = null;
      if(timeSinceLastRefresh.inHours > 0){
        if(timeSinceLastRefresh.inHours < 24)
          sinceLastRefresh = "${timeSinceLastRefresh.inHours} hodin";
        else
          sinceLastRefresh = "${timeSinceLastRefresh.inDays} dní";
      }

      // Change status code to 201 (Created) if we already have all the information we need,
      // so there is no need to ask for more
      // TODO: What if some school doesn't support one of the modules I'm checking here?
      if(student.grades != null && student.homeworks != null && student.messages != null &&
        student.subjects != null && student.timetable != null){
          connect.response.statusCode = 201;
        }

      return studentView(connect, timetable: timetable, lastRefresh: sinceLastRefresh);
    } catch (e) {
      print(e);
      connect.response.cookies.clear();
      return connect.redirect('/?error=unknown');
    }
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
    }

    return loginValid && passwordValid && bakawebUrlIsValid;
  }
}
