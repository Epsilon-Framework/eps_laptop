
//Elements
const
    $timer = $(".disabler-timer"),
    $sequence = $("#disabler-sequence"),
    $grid = $(".disabler-grid"),

//Configs
    SEQUENCE_SIZE = 4,
    GRID_X = 12,
    GRID_Y = 9,
    GRID_SIZE = GRID_X * GRID_Y;

    //LETTERS = "ᚡᚢᚣᚤᚥᚧᚫᚬᚱᚳᚵᚶᚷᚸᚹᚻᚼᚾᚿᛁᛂᛃᛄᛅᛇᛈᛉᛊᛋᛒᛕᛖᛗᛘᛜᛝᛞᛟᛠᛣᛤᛥᛦᛪ";
    LETTERS = "0123456789";

//handles
let
    timerHandle,
    shiftHandle,

//vars
    running = false,
    sequence = [],
    rndCombination = [],
    startCombination,
    cursorPos = 25,

    cheat = true;
    

$grid.css({
    "grid-template-columns": `repeat(${GRID_X}, 2vh)`,
    "grid-template-rows": `repeat(${GRID_Y}, 2vh)`
});


function randNum(min, max) {
    return min + Math.random() * (max - min);
}

function randInt(min, max) {
    return Math.floor(randNum(min, max) + 0.5);
}


function randString(len) {
    let s = '';
    let charLen = LETTERS.length;
    for (let i=0; i < len; i++) {
        s += LETTERS.charAt(Math.floor(Math.random() * charLen));
    }
    return s;
}


function timeFormat(time) {
    let m = Math.floor(time / 60);
    let ms = (time % 1);
    let s = Math.floor(time % 60 - ms);

    m = m.toString().padStart(2, "0");
    s = s.toString().padStart(2, "0");
    ms = Math.floor(ms * 1000).toString().padEnd(3, "0");

    return (`${m}:${s}.${ms}`)
}


function startTimer(time) {
    let timeRemaining = time || 15.0;
    let a = Date.now();

    timerHandle = setInterval(() => {
        timeRemaining -= (Date.now() - a) / 1000;
        a = Date.now();
    
        if(timeRemaining <= 0) {
            timeRemaining = 0
            stop(false);
        }
    
        $("#disabler-timer").text(timeFormat(timeRemaining));
    }, 0)
}


function highlight(pos, tag) {
    for (let i=0; i < GRID_SIZE; i++) {
        let $span = $(`span[id=disabler-span-${i}]`);
        let j = i - pos;
        
        if (0 <= j && j < SEQUENCE_SIZE) {
            $span.addClass(tag);
        } else {
            $span.removeClass(tag);
        }
    }
}


function startShift(interval) {
    shiftHandle = setInterval(() => {
        startCombination -= 1
        startCombination = startCombination < 0 && GRID_SIZE -1 || startCombination;

        rndCombination.push(rndCombination.shift());
        for (let i=0; i < GRID_SIZE; i++) {
            $(`span[id=disabler-span-${i}]`).text(rndCombination[i])
        }

        if (cheat) {
            highlight(startCombination, "disabler-cheat");
        }

    }, interval || 1250)
}


function initGrid() {
    startCombination = randInt(0, GRID_SIZE - SEQUENCE_SIZE);

    for (let i=0; i < SEQUENCE_SIZE; i++) {
        sequence.push(randString(2));
    }

    $sequence.text(sequence.join("."));

    for (let i=0; i < GRID_SIZE; i++) {
        let val;
        let j = i - startCombination;
        if (0 <= j && j < SEQUENCE_SIZE) {
            val = sequence[j];
        } else {
            val = randString(2);
        }
        rndCombination.push(val);
        $grid.append(`<span id="disabler-span-${i}">${val}</span>`);
    }
}


function stop(succes) {
    clearInterval(timerHandle);
    clearInterval(shiftHandle);

    sequence = [];
    rndCombination = [];

    running = false;

    OS.post("disabler-response", {
        succes: succes
    });
}


function start(time, interval) {
    running = true;
    initGrid();

    startTimer(time);
    startShift(interval);

    if (cheat) {
        highlight(startCombination, "disabler-cheat");
    }

    highlight(cursorPos, "disabler-selected");
}


start(90.0);

$(document).on("keydown", (e) => {
    if(running) { // Did the tablet start up? If no ignore the input...
        if(e.key === "ArrowUp" || e.key === "KeyW") {
            if(cursorPos >= GRID_X) {
                cursorPos -= GRID_X;
            }
        }
        else if(e.key === "ArrowDown" || e.key === "KeyS") {
            if(cursorPos < GRID_SIZE - GRID_X) {
                cursorPos += GRID_X;
            }
        }
        else if(e.key === "ArrowLeft" || e.key === "KeyA") {
            if(cursorPos != 0) {
                cursorPos -= 1;
            }
        }
        else if(e.key === "ArrowRight" || e.key === "KeyD") {
            if(cursorPos != GRID_SIZE - SEQUENCE_SIZE) {
                cursorPos += 1;
            }
        }
        else if(e.key === "Enter" || e.key === "NumpadEnter") {
            stop(cursorPos == startCombination ? true : false);
        }
        highlight(cursorPos, "disabler-selected");
    }
})