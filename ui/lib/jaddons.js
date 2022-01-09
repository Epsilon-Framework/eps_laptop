$.waitFor = function(selector, callback, timeoutInMs) {
    let checkFrequencyInMs = 250;
    timeoutInMs = timeoutInMs || 5000;

    var startTimeInMs = Date.now();
    let val = null;
    function loopSearch() {
        if (timeoutInMs && Date.now() - startTimeInMs > timeoutInMs)
            return;

        if (document.querySelector(selector) != null) {
            val = $(selector);
            if (callback !== undefined) {
                callback(val);
            }
        } else {
            setTimeout(loopSearch, checkFrequencyInMs);
        }
    }
    loopSearch();
};

$.createPortal = function(type, portal) {
    $(window).on("message", function(e) {
        let data = e.originalEvent.data;

        if (data.type === type) {
            if (data.action in portal) {
                portal[data.action](...(data.args || []));
            } else {
                console.error(`Action ${data.action} doesn't exist in ${data.type}`);
            }
        }
    });
};

String.prototype.Format = String.prototype.Format || function () {
    "use strict";
    var str = this.toString();
    if (arguments.length) {
        var dict = {};
        if (typeof(Array.prototype.slice.call(arguments, -1)[0]) === "object") {
            for (let [k, v] of Object.entries(Array.prototype.pop.call(arguments))) {
                dict[k] = v;
            }
        }

        Array.prototype.forEach.call(arguments, function(v, i) {
            dict[i] = v;
        })

        for (let key in dict) {
            str = str.replace(new RegExp(`\\{${key}\\}`, "gi"), dict[key]);
        }
    }

    return str;
};