import 'package:rikulo_commons/io.dart';
import 'package:rikulo_commons/mirrors.dart';
import 'package:stream/stream.dart';

import '../model/message.dart';
import '../tools/db.dart';
import '../view/general/contact.rsp.dart';

class GeneralContactController {
  static Future getContactPage(HttpConnect connect) {
    return contactView(connect, showSuccMessage: false);
  }

  static Future postContactPage(HttpConnect connect) async {
    var postParameters = await HttpUtil.decodePostedParameters(connect.request);
    var post = ContactInputMessage();
    ObjectUtil.inject(post, postParameters);
    if (!post.validate()) {
      return contactView(connect,
          showSuccMessage: false,
          errorMessage:
              'Ještě jednou zkontrolujte zadané údaje v formuláři, něco jste vyplnili špatně.',
          prefilledBody: post.messageBody,
          prefilledSubject: post.subject);
    }

    try {
      DB.saveMessage(Message.create(post.subject, post.messageBody,
          post.messageType, post.email, post.isMessageImportant));
    } catch (e) {
      return contactView(connect,
          showSuccMessage: false,
          errorMessage: 'Nepodařilo se odeslat zprávu.',
          prefilledBody: post.messageBody,
          prefilledSubject: post.subject);
    }

    return contactView(connect, showSuccMessage: true);
  }
}

class ContactInputMessage {
  String subject;
  String messageType;
  bool isMessageImportant;
  String messageBody;
  String email;

  ContactInputMessage() {
    if (isMessageImportant == null) isMessageImportant = false;
  }

  bool validate() {
    if (subject == null ||
        messageType == null ||
        messageBody == null ||
        isMessageImportant == null ||
        subject.isEmpty ||
        messageBody.isEmpty ||
        messageType.isEmpty) {
      return false;
    }

    if (isMessageImportant && (email == null || email.isEmpty)) {
      return false;
    }

    return true;
  }
}
