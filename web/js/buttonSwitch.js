function registerSwitches() {
    let switchButtons = document.body.getElementsByClassName('button-switch');
    for (let i = 0; i < switchButtons.length; i++) {
        const button = switchButtons[i];
        let toggleOn = button.getAttribute('toggleon');
        let toggleOff = button.getAttribute('toggleoff');
        button.addEventListener("click", function(){
            document.getElementById('toggleOn').setAttribute('style', '');
            document.getElementById('toggleOff').setAttribute('style', 'display: none;');
        });
    }
}

registerSwitches();