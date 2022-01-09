const NUM_PX_REG = /(\d+|\d+.\d+)px/g
const HIDDEN = {width: "0px", height: "0px", top: "100%", left: "0%"};
const ANIM_SPEED = 250

const ANCHORS = {
    "top-left":     "translate(0%, 0%)",
    "top-middle":   "translate(-50%, 0%)",
    "top-right":    "translate(-100%, 0%)",

    "left":         "translate(0%, -50%)",
    "center":       "translate(-50%, -50%)",
    "right":        "translate(-100%, -50%)",

    "right-left":   "translate(0%, -100%)",
    "right-middle": "translate(-50%, -100%)",
    "right-right":  "translate(-100%, -100%)",
}

/* ________________________________ OS ________________________________ */

class OSOpenApplicationsList {
    constructor() {
        this.Applications = [];
    }

    _update(activeApp) {
        this.Applications.forEach((app, i) => {
            $(app.window).css("z-index", i);

            if (app === activeApp) {
                Taskbar.setAppActive(app, true);
            } else {
                Taskbar.setAppActive(app, false);
            }
        });
    }

    push(app) {        
        if (this.Applications.includes(app)) {
            let i = this.Applications.indexOf(app);
            this.Applications.splice(i, 1);
        };
        this.Applications.push(app);

        this._update(app);
    }

    remove(app) {
        if (this.Applications.includes(app)) {
            let i = this.Applications.indexOf(app);
            this.Applications.splice(i, 1);
        };

        $(app.window).css("z-index", "");
        Taskbar.setAppActive(app, false);

        this._update(this.last());
    }

    last() {
        return this.Applications.slice(-1)[0];
    }

    isActive(app) {
        return app === this.last();
    }
}

function parseApp(app) {
    if (typeof app === "string") {
        return OS.getApp(app);
    }
    return app;
}

let OS = (function() {
    let _OpenApplications = new OSOpenApplicationsList();

    function newLocale(locale) {
        return Object.setPrototypeOf(locale, {
            get(key) {
                if (key in this) {
                    return this[key];
                }
                return key;
            }
        });
    }

    let OS = {
        Locale: newLocale({}),
        Open: false,

        init(lang, dateLocal) {
            Taskbar.init(dateLocal);

            Taskbar.addApp(OS.installApp("start", false),  () => {
                OS.close();
            });

            Taskbar.addApp(OS.installApp("explorer", false), () => {
                //TODO;
            });

            OS.setLanguage(lang || "en");
            OS.installApp("recycle", true);
            OS.installApp("settings", true);
        },

        setLanguage(lang) {
            if (lang in Locales) {
                OS.Locale = newLocale(Locales[lang]);
            } else {
                console.log(`Locale ${lang} doesn't exist!`);
            }
            OS.translate($("body"));
        },

        translate(items) {
            if (typeof items === "object" && items.constructor === $.prototype.constructor) {
                $(items).find("[translate]").each(function() {
                    let name = $(this).attr("translate");
                    $(this).text(OS.Locale.get(name));
                });
            } else {
                console.error(`'items' must be typo of jquery object, got ${typeof items}!`)
            }
        },

        open() {
            Open = true;
            $("os-window").each(function() {
                if (this.isVisible) {
                    $(this).trigger("on-show");
                };
            })
            $(".screen-container").show();
        },

        close() {
            Open = false;
            $("os-window").each(function() {
                $(this).trigger("on-hide");
            })
            $(".screen-container").hide();
            OS.post("close");
        },

        post(message, data) {
            $.post(`https://${GetParentResourceName()}/${message}`, JSON.stringify(data||{}));
        },

        appExists(name, cb) {
            try {
                $.get(`apps/${name}`).done(function() {
                    cb(true);
                }).fail(function() {
                    cb(false);
                });
            } catch(e) {
                console.log("apple");
            }
        },

        createApp(name) {
            let app = document.createElement("os-app");
            $(app).attr({
                "name": name,
                "icon": `icons/${name}.png`
            });
            return app;
        },

        createDesktopIcon(app) {
            app = parseApp(app);

            if ($(`#${app.name}-app`).length === 0) {
                let deskApp = document.createElement("div");
                deskApp.className = "app";
                deskApp.id = `#${app.name}-app`
                deskApp.innerHTML = `
                    <img class="app-icon" src="${app.icon}">
                    <p class="text" translate="${app.name}">${OS.Locale.get(app.name)}</p>
                `

                $(deskApp).click(() => {
                    if (app.window) {
                        OS.openApp(app);
                    }
                })

                $(`.apps`).append(deskApp);
            }
        },

        updateDesktopIcon(app) {
            app = parseApp(app);

            $(`#${app.name}-app img`).attr("src", app.icon);
        },

        removeDesktopIcon(app) {
            app = parseApp(app);

            $(`#${this._name}-app.app`).remove();
        },

        installApp(app, desktopIcon) {
            if (typeof(app) === "string") {
                app = OS.createApp(app);
            }

            if (desktopIcon) {
                OS.createDesktopIcon(app);
            }

            if (!OS.isAppInstalled(app)) {
                $("body").prepend(app);
            }

            return app;
        },

        uninstallApp(app) {
            app = parseApp(app);
            app.uninstall();
        },

        isAppInstalled(app) {
            app = parseApp(app);

            if ($(`os-app[name="${app.name}"]`).length) {
                return true;
            }
            return false;
        },

        openApp(app) {
            app = parseApp(app);

            if (_OpenApplications.isActive(app)) {
                OS.minimizeApp(app);
            } else {
                if (!app.isOpen) {
                    Taskbar.addApp(app, () => {
                        OS.openApp(app);
                    });
                    Taskbar.openApp(app);
                }
                app.open();
                _OpenApplications.push(app);
            }
        },
        
        closeApp(app) {
            app = parseApp(app);

            Taskbar.removeApp(app)
            app.close();
            setTimeout(() => {
                _OpenApplications.remove(app);
            }, ANIM_SPEED);
        },

        minimizeApp(app) {
            app = parseApp(app);
            
            app.window.hide();
            setTimeout(() => {
                _OpenApplications.remove(app);
            }, ANIM_SPEED);
        },

        getApp(name) {
            return $(`os-app[name="${name}"]`).get(0);
        },
    }

    return OS;
})();


class Taskbar {
    DateLocal = "en-GB";

    static async init(local) {
        if (local) {
            Taskbar.DateLocal = local
        }
        // Timeloop
        let d = new Date();
        Taskbar._updateDateAndTime();
        await new Promise(resove => setTimeout(resove, 6e4 - d.getSeconds() * 1e3));
        Taskbar._updateDateAndTime();
        setInterval(Taskbar._updateDateAndTime, 6e4);
    }

    static addApp(app, cb) {
        $(".taskbar-apps").append(`
            <div class="taskbar-app" id="taskbar-app-${app.name}">
                <img src="${app.icon}"></img>
            </div>
        `);

        if (cb) {
            $(`#taskbar-app-${app.name}`).click(cb);
        }
    }

    static updateAppIcon(app) {
        $(`#taskbar-app-${app.name} img`).attr("src", app.icon);
    }

    static pinApp(app, cb) {
        //TODO;
    }

    static removeApp(app) {
        if (app.name === "start" || app.name === "explorer") {
            console.error(`Taskbar app ${app.name} is locked!`);
        }
    
        $(`.taskbar-apps #taskbar-app-${app.name}`).remove();
    }

    static openApp(app) {
        $(`#taskbar-app-${app.name}`).addClass("open");
    }

    static closeApp(app) {
        $(`#taskbar-app-${app.name}`).removeClass("close");
    }

    static setAppActive(app, active) {
        if (active) {
            $(`#taskbar-app-${app.name}`).addClass("active");
        } else {
            $(`#taskbar-app-${app.name}`).removeClass("active");
        }
    }

    static _updateDateAndTime() {
        let d = new Date();
    
        let clock = d.toLocaleTimeString([], {
            hour: '2-digit',
            minute:'2-digit'
        });

        $(document).trigger("minute-stepped");
    
        let date = d.toLocaleDateString(Taskbar.DateLocal);
        $("#taskbar-clock").text(clock);
        $("#taskbar-date").text(date);
    }
}

/* ________________________________ APP ________________________________ */
class App extends HTMLElement {
    constructor() {
        super();
        this._open = false;
    }

    static get observedAttributes() { return ["icon"] }

    attributeChangedCallback(name, _, val) {
        switch(name) {
            case "icon":
                this._icon = val;
                Taskbar.updateAppIcon(this);
                if (this.window) {
                    this.window.setIcon(val);
                }
                OS.updateDesktopIcon(this);
                break;
            default:
                break;
        };
    }

    connectedCallback() {
        this.window = $(`os-window[name="${this.name}"]`).get(0);
        if (this.window) {
            $(this.window).attr("icon", this.icon);

            OS.translate($(this.window));
        }
    }

    get name() {
        this._name = this._name || $(this).attr("name")
        return this._name;
    }

    get icon () {
        this._icon = this._icon || $(this).attr("icon");
        return this._icon;
    }

    uninstall() {
        OS.removeDesktopIcon(this);
        Taskbar.removeApp(this);
        $(this.window).remove();
        $(this).remove();
    }

    open() {
        this._open = true;
        this.window.show();
    }

    minimize() {
        this.window.hide();
    }

    close() {
        if(this._open) {
            this.window.hide();
            this._open = false;
        }
    }

    get isOpen() {
        return this._open;
    }
}

/* ________________________________ TITLEBAR ________________________________ */

class Titlebar extends HTMLElement {
    constructor() {
        super();
    }

    static get observedAttributes() {
        return ["img"];
    }

    attributeChangedCallback(name, _, val) {
        switch(name) {
            case "img":
                $(this).find(".titlebar-icon").attr("src", val);
                break;
            default:
                break;
        }
    }

    connectedCallback() {
        this.innerHTML = `
            <div id=${$(this).attr("id")} class="titlebar window-border">
                <img class="titlebar-icon" src="${$(this).attr("img") || "images/os/dflt_titlebar_icon.png"}">
                <h1 class="text" translate=${$(this).attr("translate")}>${this.innerHTML}</h1>
                <div class="titlebar-buttons">
                    <button class="min-btn fa fa-window-restore titlebar-btn"></button></button>  
                    <button class="close-btn fa fa-times-circle titlebar-btn"></button>
                </div>
            </div>
        `
        this.removeAttribute("translate");
    }
}

/* ________________________________ WINDOW ________________________________ */

class OSWindow extends HTMLElement {
    constructor() {
        super();

        this.name = $(this).attr("name") || "unknown";
        this._visible = false;
        
        $(this).attr("id", `${this.name}-window`)

        this.position = {
            left: this.getAttribute("x") || "0",
            top: this.getAttribute("y")  || "0",
        };

        this.size = {
            width : this.getAttribute("width")  || "0",
            height: this.getAttribute("height") || "0"
        };

        this.anchor = ANCHORS[this.getAttribute("anchor") || "top-left"];
        
        $(this).hide();
        $(this).css({
            "position": "absolute",
            "transform": this.anchor
        })
        $(this).css(HIDDEN);
        
        this.titlebar = $(this).find("window-titlebar");
        this.className = `${this.className} window-border`
    }

    _updateStyle() {
        if (this._visible) {
            $(this).css(Object.assign({
                transform: this.anchor
            }, this.position, this.size));
        } else {
            $(this).css(Object.assign({
                transform: this.anchor
            }, HIDDEN));
        }
    }

    static get observedAttributes() {
        return ["x", "y", "width", "height", "anchor", "icon"];
    }

    attributeChangedCallback(name, _, val) {     
        switch(name) {
            case "y":
            case "x":
                this.position[name === "x" && "left" || "top"] = val;
                break;
                
            case "width":
            case "height":
                this.size[name] = val;
                break;
                    
            case "anchor":
                this.anchor = ANCHORS[val];
                break;

            case "icon":
                if (this.titlebar) {
                    this.titlebar.attr("img", val);
                }
                break;        

            default:
                break;
        }
        this._updateStyle();
    }

    connectedCallback() {
        if (this.titlebar.length == 0) {
            let elem = document.createElement("window-titlebar");

            this.titlebar = $(elem);
            this.titlebar.attr({
                translate: this.name,
                id: `${this.name}-title`,
                icon: $(this).attr("icon") || ""
            })
            this.titlebar.text(OS.Locale.get(this.name));

            $(this).prepend(this.titlebar);
        };
    }

    setIcon(icon) {
        $(this).find("window-titlebar").attr("img", icon);
    }

    show() {
        if (!this._visible) {
            $(this).show();
            $(this).animate(Object.assign({}, this.position, this.size), {
                duration: ANIM_SPEED,
            });
            this._visible = true;
        }
        $(this).trigger("on-show");
    }

    hide() {
        if (this._visible) {
            $(this).animate(HIDDEN, {
                duration: ANIM_SPEED,
                complete: () => {
                    $(this).hide();
                }
            });
            this._visible = false;
        }
        $(this).trigger("on-hide");
    }

    toggle() {
        if (this._visible) {
            this.hide();
        } else {
            this.show();
        }
    }

    get isVisible() {
        return this._visible;
    }
}

function groupWindows(...windows) {
    function hideExcept(exceptwindow) {
        windows.forEach((window) => {
            if (window != exceptwindow) {
                window.hide();
            }
        })
    }

    windows.forEach((window) => {
        window.on("on-show", () => {
            hideExcept(window);
        });
    });
}


$(document).on("click", "os-window .close-btn", function() {
    let name = $(this).closest("os-window").attr("name");
    let app = OS.getApp(name);
    if (app) {
        OS.closeApp(app);
    }
});

$(document).on("click", "os-window .min-btn", function() {
    let name = $(this).closest("os-window").attr("name");
    let app = OS.getApp(name);
    if (app) {
        OS.minimizeApp(app);
    }
});


/* ________________________________ CHECKBOX ________________________________ */

class CheckBox extends HTMLDivElement {
    constructor() {
        super();

        this.innerHTML = `
            ${this.innerHTML}
            <input id="corners-checkbox" type="checkbox" checked=${$(this).attr("checked")||"unchecked"}>
            <span class="checkmark"></span>
        `
    }
}


//Define Elements
customElements.define("os-app", App);
customElements.define("os-window", OSWindow);
customElements.define("window-titlebar", Titlebar);
customElements.define("os-checkbox", CheckBox, { extends: "div" });

//OS Lua Portal
$(function() {
    $.createPortal("os", {
        install_app: OS.installApp,
        uninstall_app: OS.uninstallApp,
        open: OS.open,
        close: OS.close,
        set_language: OS.setLanguage,
        init: OS.init,
    });

    OS.post("ready");
})