numberOfRequests = 0
requestThreshold = 20;

function update() {
    // http://youmightnotneedjquery.com/
    var request = new XMLHttpRequest();
    // Do not log access
    request.open('GET', '/student?log=0', true);

    request.onload = function () {
        if (this.status >= 200 && this.status < 400) {
            var resp = this.response;
            console.log('[LOGIN-AUTO-REFRESH] Pulled content update...');
            registerSwitches();
            numberOfRequests++;

            if (this.status == 201) { // Everything is done
                console.log('[LOGIN-AUTO-REFRESH] Received 201 status code from server, updating content and quiting update process.');
                document.body.innerHTML = resp;
                clearInterval(intervalId);
            } else if (numberOfRequests > requestThreshold) {
                console.log('[LOGIN-AUTO-REFRESH] Failed to receive 201 status code from server in last ' + requestThreshold + ' requests. Aborting.');
                // Display error box
                document.getElementById('failed-to-fetch-update').setAttribute('style', '');
            }
        } else {
            // We reached our target server, but it returned an error
            console.log('[LOGIN-AUTO-REFRESH] Unknown error when updating content.');
            // Display error box
            document.getElementById('failed-to-fetch-update').setAttribute('style', '');
        }
    };

    request.onerror = function () {
        // There was a connection error of some sort
        console.log('[LOGIN-AUTO-REFRESH] Connection error when updating content.');
        // Display error box
        document.getElementById('failed-to-fetch-update').setAttribute('style', '');
    };

    request.send();
}

intervalId = setInterval(update, 1000);