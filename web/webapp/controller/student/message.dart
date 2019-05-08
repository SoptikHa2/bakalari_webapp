import 'package:stream/stream.dart';

import '../../config.dart';
import '../../model/complexStudent.dart';
import '../../tools/securityTools.dart';
import '../../view/student/messageDetailsView.rsp.dart';
import '../../view/student/messageListView.rsp.dart';

/// This controllers handles both
/// one message details lookup
/// and message list
///
/// /student/message -> display message list
/// /student/message/XX -> display message XX
class StudentMessageController {
  static Future getList(HttpConnect connect) async {
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

    return messageListView(connect,
        messages: student.messages,
        strippedMessagesContent: student.messages
            .map(
                (m) => m.content.replaceAll(RegExp(r'(<[^>]*>)|(&nbsp;)'), ' '))
            .map((s) => s.length > 140 ? s.substring(0, 140) + '...' : s)
            .toList(),
        datetimesFormatted: student.messages
            .map((m) => Config.dateFormat.format(m.dateTime))
            .toList(),
            sendMessageLink: student.schoolInfo.bakawebLink.replaceFirst("login.aspx", "next/komens_zprava.aspx"));
  }

  static Future getMessage(HttpConnect connect) async {
    String identifier = Uri.decodeComponent(connect.dataset['identifier']);
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
    if (!student.messages.any((s) => s.id == identifier)) {
      throw new Http404();
    }
    var selectedMessage =
        student.messages.firstWhere((message) => message.id == identifier);

    return messageDetailsView(connect,
        datetimeFormatted: Config.dateFormat.format(selectedMessage.dateTime),
        message: selectedMessage);
  }
}
