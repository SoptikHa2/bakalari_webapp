// Show and update subject average

function updateSubjectAverage() {
    let values = document.getElementsByName('value');
    let weights = document.getElementsByName('weight');
    let sum = 0.0;
    let count = 0;
    for (let i = 0; i < values.length; i++) {
        let value = values[i].innerText;
        let weight = weights[i].innerText;

        if (!isNaN(parseFloat(value))) {
            if (value.endsWith('-')) {
                value = parseFloat(value) + 0.5;
            } else {
                value = parseFloat(value);
            }
            weight = parseInt(weight);


            sum += value * weight;
            count += weight;
        }
    }

    let newValue = document.getElementById('new-grade').value;
    let newWeight = parseFloat(document.getElementById('new-weight').value);
    if (newValue.endsWith('-')) {
        newValue = parseFloat(newValue) + 0.5;
    } else {
        newValue = parseFloat(newValue);
    }
    if (!isNaN(newValue) && !isNaN(newWeight) && newValue >= 1 && newValue <= 5) {
        sum += newValue * newWeight;
        count += newWeight;
    }

    let average = sum / count;

    document.getElementById('average').innerHTML = "Průměr: " + average.toFixed(2);
}

updateSubjectAverage();