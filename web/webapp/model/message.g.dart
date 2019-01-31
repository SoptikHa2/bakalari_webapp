part of 'message.dart';

Message _$MessageFromJson(Map<String, dynamic> json) {
  return Message(
    guid: json['guid'] as String,
    email: json['email'] as String,
    isClosed: json['isClosed'] as bool,
    isImportant: json['isImportant'] as bool,
    subject: json['subject'] as String,
    tag: json['tag'] as String,
    text: json['text'] as String,
    sent: json['sent'] == null
        ? null
        : DateTime.parse(json['sent'] as String),
  );
}

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
      'email': instance.email,
      'isClosed': instance.isClosed,
      'isImportant': instance.isImportant,
      'subject': instance.subject,
      'tag': instance.tag,
      'text': instance.text,
      'guid': instance.guid,
      'sent': instance.sent?.toIso8601String()
    };
