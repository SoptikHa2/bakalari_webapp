function update() {
    // http://youmightnotneedjquery.com/
    var request = new XMLHttpRequest();
    // Do not log access
    request.open('GET', '/student?log=0', true);

    request.onload = function () {
        if (this.status >= 200 && this.status < 400) {
            var resp = this.response;
            console.log('Updating content...');
            document.body.innerHTML = resp;
            registerSwitches();

            if(this.status == 201){ // Everything is done
                console.log('Received 201 status code from server, quiting update process.');
                clearInterval(intervalId);
            }
        } else {
            // We reached our target server, but it returned an error
            console.log('Unknown error when updating content.');
        }
    };

    request.onerror = function () {
        // There was a connection error of some sort
        console.log('Connection error when updating content.');
    };

    request.send();
}

intervalId = setInterval(update, 1000);