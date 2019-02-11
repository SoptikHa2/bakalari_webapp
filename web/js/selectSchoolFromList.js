var inputField = document.getElementById('urlSelectField');
var targetDiv = document.getElementById('schoolList');

inputField.addEventListener('input', handleNewLetterInUrlSelectField);

var requestIsAlreadyRunning = false;
function handleNewLetterInUrlSelectField(e) {
    var inputValue = inputField.value.trim();

    if (inputValue == '' || inputValue.startsWith('http://') || inputValue.startsWith('https://'))
        return;

    if (!requestIsAlreadyRunning) {
        requestIsAlreadyRunning = true;
        var url = '/schoolList.csv?query=' + encodeURIComponent(inputValue);
        var request = new XMLHttpRequest();
        request.open('GET', url, true);
        request.onload = function () {
            if (this.status >= 200 && this.status < 400) {
                var resp = this.responseText;
                var lines = resp.split('\n');
                targetDiv.innerHTML = '';
                lines.forEach(line => {
                    var name = line.split('``````')[0];
                    var url = line.split('``````')[1];
                    targetDiv.innerHTML += '<div class="schoolListRow" url="' + url + '" onclick="handleItemClick(\'' + url + '\')">' + name + '</div>'
                });
            } else {
                console.log('Error fetching url ' + url + ' . Status code: ' + this.status);
            }
            requestIsAlreadyRunning = false;
        }
        request.send();
    }
}

function handleItemClick(url) {
    inputField.value = url;
    targetDiv.innerHTML = '';
}