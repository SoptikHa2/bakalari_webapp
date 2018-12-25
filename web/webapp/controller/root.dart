import 'package:stream/stream.dart';
import '../view/rootView.rsp.dart';

Future root(HttpConnect connect) {
  if(false) { // User.loggedIn
    connect.redirect('student');
  }
  // Add some random data to connect.dataset
  return rootView(connect);
}