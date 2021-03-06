// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'complexStudent.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ComplexStudent _$ComplexStudentFromJson(Map<String, dynamic> json) {
  return ComplexStudent(
      guid: json['guid'] as String,
      timetable: json['timetable'] == null
          ? null
          : Timetable.fromJson(json['timetable'] as Map<String, dynamic>),
      permTimetable: json['permTimetable'] == null
          ? null
          : Timetable.fromJson(json['permTimetable'] as Map<String, dynamic>),
      nextWeekTimetable: json['nextWeekTimetable'] == null
          ? null
          : Timetable.fromJson(
              json['nextWeekTimetable'] as Map<String, dynamic>),
      grades: (json['grades'] as List)
          ?.map((e) =>
              e == null ? null : Grade.fromJson(e as Map<String, dynamic>))
          ?.toList(),
      homework: (json['homework'] as List)
          ?.map((e) =>
              e == null ? null : Homework.fromJson(e as Map<String, dynamic>))
          ?.toList(),
      messages: (json['messages'] as List)
          ?.map((e) => e == null
              ? null
              : PrivateMessage.fromJson(e as Map<String, dynamic>))
          ?.toList(),
      schoolInfo: json['schoolInfo'] == null
          ? null
          : School.fromJson(json['schoolInfo'] as Map<String, dynamic>),
      refresh: json['refresh'] == null
          ? null
          : DateTime.parse(json['refresh'] as String),
      studentInfo: json['studentInfo'] == null
          ? null
          : Student.fromJson(json['studentInfo'] as Map<String, dynamic>),
      subjects: (json['subjects'] as List)
          ?.map((e) =>
              e == null ? null : Subject.fromJson(e as Map<String, dynamic>))
          ?.toList());
}

Map<String, dynamic> _$ComplexStudentToJson(ComplexStudent instance) =>
    <String, dynamic>{
      'guid': instance.guid,
      'studentInfo': instance.studentInfo?.toJson(),
      'schoolInfo': instance.schoolInfo?.toJson(),
      'timetable': instance.timetable?.toJson(),
      'permTimetable': instance.permTimetable?.toJson(),
      'nextWeekTimetable': instance.nextWeekTimetable?.toJson(),
      'grades': instance.grades?.map((m) => m.toJson())?.toList(),
      'subjects': instance.subjects?.map((s) => s.toJson())?.toList(),
      'homework': instance.homework?.map((h) => h.toJson())?.toList(),
      'messages': instance.messages?.map((m) => m.toJson())?.toList(),
      'refresh': instance.refresh?.toIso8601String()
    };
