import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'message.g.dart';

/// Message sent from user to admin
@JsonSerializable()
class Message {
  String guid;
  String subject;
  String email;
  String text;
  String tag;
  bool isImportant;
  bool isClosed;

  Message(
      {this.guid,
      this.subject,
      this.email,
      this.text,
      this.tag,
      this.isImportant,
      this.isClosed});

  Message.create(this.subject, this.text, this.tag, this.email, this.isImportant){
    this.isClosed = false;
    this.guid = Uuid().v4();
  }

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);
  Map<String, dynamic> toJson() => _$MessageToJson(this);
}
