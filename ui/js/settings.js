let Stored = {
    background: null,
    taskbar_color: null
};

function setTaskbarColor(clr) {
    let color = jQuery.Color(clr);
    let text = color.lightness() > 0.8 && "black" || "white";

    $(":root").css({
        "--os-taskbar-alpha-background": color.toRgbaString(),
        "--os-taskbar-background": color.toHexString(),
        "--os-color": text
    });
}

function getTaskbarColor() {
    return $(":root").css("--os-taskbar-alpha-background");
}

function setCornersRounded(rounded) {
    $(":root").css({
        "--os-rounded": rounded && "1.1vh" || "0.3vh"
    });
}

function setBackground(background) {
    $(".screen-container").css('background-image', `url(${background})`);
}

function getBackground() {
    return $(".screen-container").css("background-image").slice(5, -2);
}

//Corners
$(document).on('input', "#corners-checkbox", function() {    
    let rounded = $("#corners-checkbox").is(":checked");
    OS.post("settings:update", { rounded_corners: rounded })

    setCornersRounded(rounded);
});

//Taskbar
$(document).on('input', ".colorpicker", function() {    
    let color = $(".colorpicker").val();
    setTaskbarColor(color);
});

$(document).on("click", ".clr-clear", function() {
    let color = Stored.taskbar_color;
    if (color) {
        OS.post("settings:update", { taskbar_color: color })
        setTaskbarColor(color);
    }
})

$(document).on("mouseup", "#clr-color-area", function() {
    let color = $(".colorpicker").val();
    OS.post("settings:update", { taskbar_color: color })

    Stored.taskbar_color = getTaskbarColor();
    setTaskbarColor(color);
})

//Background
$(document).on("click", "#background-apply", function() {
    let background = $("#backgroundurl").val();
    $("#backgroundurl").val("");

    OS.post("settings:update", { background: background })

    Stored.background = getBackground();
    setBackground(background);
})

$(document).on("click", "#background-reset", function() {
    let background = Stored.background;
    if (background) {
        OS.post("settings:update", { background: background })
        setBackground(background);
    }
})

$(function() {
    $.createPortal("settings", {
        load_settings: (settings) => {
            for (let key in settings) {
                let val = settings[key];
                switch(key) {
                    case "background": 
                        setBackground(val)
                        break;
                    case "taskbar_color": 
                        setTaskbarColor(val)
                        break;
                    case "rounded_corners": 
                        setCornersRounded(val)
                        break;
                }
            }
        }
    })
})