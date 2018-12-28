import 'package:bakalari/src/modules/gradeModule.dart';
import 'package:bakalari/src/modules/homeworkModule.dart';
import 'package:bakalari/src/modules/privateMessagesModule.dart';
import 'package:bakalari/src/modules/subjectListModule.dart';
import 'package:bakalari/src/modules/timetableModule.dart';
import 'package:bakalari/src/school.dart';
import 'package:bakalari/src/student.dart';

import 'package:uuid/uuid.dart';

import 'package:json_annotation/json_annotation.dart';
part 'complexStudent.g.dart';

@JsonSerializable()
class ComplexStudent {
  String guid;
  Student studentInfo;
  School schoolInfo;
  Timetable timetable;
  Timetable permTimetable;
  List<Grade> grades;
  List<Subject> subjects;
  List<Homework> homeworks;
  List<PrivateMessage> messages;
  DateTime refresh;

  ComplexStudent(
      {this.guid,
      this.timetable,
      this.permTimetable,
      this.grades,
      this.homeworks,
      this.messages,
      this.schoolInfo,
      this.studentInfo,
      this.subjects,
      this.refresh});

  ComplexStudent.create(Student studentInfo, School schoolInfo) {
    this.studentInfo = studentInfo;
    this.schoolInfo = schoolInfo;
    this.refresh = DateTime.now();
    this.guid = Uuid().v4();
  }

  /// Update self (null values ignored).
  ///
  /// This method updates the object AND returns it.
  ComplexStudent update(
      {Student studentInfo,
      School schoolInfo,
      Timetable timetable,
      Timetable permTimetable,
      List<Grade> grades,
      List<Subject> subjects,
      List<Homework> homeworks,
      List<PrivateMessage> messages,
      DateTime refresh}) {
    this.studentInfo = studentInfo ?? this.studentInfo;
    this.schoolInfo = schoolInfo ?? this.schoolInfo;
    this.timetable = timetable ?? this.timetable;
    this.permTimetable = permTimetable ?? this.permTimetable;
    this.grades = grades ?? this.grades;
    this.subjects = subjects ?? this.subjects;
    this.homeworks = homeworks ?? this.homeworks;
    this.messages = messages ?? this.messages;
    this.refresh = refresh ?? this.refresh;

    return this;
  }

  factory ComplexStudent.fromJson(Map<String, dynamic> json) =>
      _$ComplexStudentFromJson(json);
  Map<String, dynamic> toJson() => _$ComplexStudentToJson(this);
}
