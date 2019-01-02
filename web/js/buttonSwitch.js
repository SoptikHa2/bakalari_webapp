function registerSwitches() {
    let switchButtons = document.body.getElementsByClassName('button-switch');
    for (let i = 0; i < switchButtons.length; i++) {
        const button = switchButtons[i];
        let toggleOn = button.getAttribute('toggleon');
        let toggleOff = button.getAttribute('toggleoff');
        let oppositeButton = button.getAttribute('oppButton');
        button.addEventListener("click", function(){
            document.getElementById(toggleOn).setAttribute('style', '');
            document.getElementById(toggleOff).setAttribute('style', 'display: none;');
            document.getElementById(oppositeButton).setAttribute('class', 'pure-button button-switch');
            button.setAttribute('class', 'pure-button pure-button-primary button-switch');
        });
    }
}

registerSwitches();