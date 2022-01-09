function SetDisplay(visible){
    if (visible) {
        OS.open();
    } else {
        OS.close();
    }
}

$(function() {
    SetDisplay(false);
    /*OS.init("nl", "GB-en");
    OS.installApp("disabler", true);
    OS.installApp("boosting", true);
    OS.openApp("disabler");highlight(cursorPos, "disabler-selected");*/

    $.createPortal("ui", {
        "show": () => {
            SetDisplay(true);
        },
        "hide": () => {
            SetDisplay(false);
        }
    })
})


/** ________________________ Coloris ________________________ **/
Coloris({
    wrap: true,
    theme: 'default',
    themeMode: 'dark',
    margin: -5,
    format: 'mixed',
    formatToggle: false,
    alpha: true,
    focusInput: false,
    clearButton: {
        show: true,
        label: OS.Locale.get("clear")
    },
});