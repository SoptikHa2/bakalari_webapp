switchTimetableDisplay_idsToHide = [ "tabletoday", "tabletomorrow", "tablepermanent" ]

function switchtimetableDisplay(allowID){
    switchTimetableDisplay_idsToHide.forEach(id => {
        document.getElementById(id).setAttribute('style', 'display: none');
    });
    document.getElementById(allowID).setAttribute('style', '');
}