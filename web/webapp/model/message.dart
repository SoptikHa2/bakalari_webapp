import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:markdown/markdown.dart';

part 'message.g.dart';

/// Message sent from user to admin
@JsonSerializable()
class Message {
  String guid;
  String subject;
  String email;
  String text;
  String tag;
  DateTime sent;
  bool isImportant;
  bool isClosed;

  String getMarkdownInHtml() => markdownToHtml(text);

  Message(
      {this.guid,
      this.subject,
      this.email,
      this.text,
      this.tag,
      this.isImportant,
      this.isClosed,
      this.sent});

  Message.create(this.subject, this.text, this.tag, this.email, this.isImportant){
    this.isClosed = false;
    this.isImportant = isImportant ?? false;
    this.guid = Uuid().v4();
    this.sent = DateTime.now();
  }

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);
  Map<String, dynamic> toJson() => _$MessageToJson(this);
}
