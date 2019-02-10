import 'dart:html';

void main() {
  var targetDiv = querySelector('#schoolList');
  var inputField = querySelector('#urlSelectField');

  inputField.onInput.listen(handleNewLetterInUrlSelectField);
}

bool requestIsAlreadyRunning = false;
void handleNewLetterInUrlSelectField(Event ev) {
  var newValue = ev.matchingTarget.nodeValue.trim();

  if (newValue.startsWith(RegExp('http(s)?://'))) {
    return;
  }

  // Ask server for school list
  if (!requestIsAlreadyRunning) {
    requestIsAlreadyRunning = true;
    // Yeah, we could see two requests at once because async, but who cares
    var request = HttpRequest.request('/schoolList.csv?query=' + Uri.encodeQueryComponent(newValue))
        .then((req) => updateSchoolList(req));
  }
}

void updateSchoolList(HttpRequest req) {
  var targetDiv = querySelector('#schoolList');

  var lines = req.responseText.split('\n').map((l) => l.split(':'));
  for (var line in lines) {
    var name = line[0];
    var url = line[1];
    var newElement = Element.div();
    newElement.appendText(name);
    newElement.className = "schoolListRow";
    newElement.setAttribute('url', url);
  }
}

void handleClickOnSchoolInSchoolList(Event ev) {}
