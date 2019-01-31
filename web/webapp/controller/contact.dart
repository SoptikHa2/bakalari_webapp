
import 'package:stream/stream.dart';

import '../view/general/contact.rsp.dart';

class Contact{
  static Future getContactPage(HttpConnect connect){
    return contactView(connect, showSuccMessage: false);
  }
}