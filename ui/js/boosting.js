const TIME_MULT_TABLE = [ 1, 60, 3600, 86_400 ];


function ParseToSeconds(timeStr) {
    let sec = 0;
    timeStr.split(":").reverse().forEach((s, i) => {
        sec += parseInt(s) * TIME_MULT_TABLE[i];
    });
    return sec
}

function DateFormat(date) {
    let sections = []
    let hours = date.getHours() - 1;
    let minutes = date.getMinutes();

    if (hours > 0) {
        sections.push(`${hours} ${hours > 1 && 
            OS.Locale.get("hours") || OS.Locale.get("hour")}`);
    }
    
    if (minutes > 0) {
        sections.push(`${minutes} ${minutes > 1 && 
            OS.Locale.get("minutes") || OS.Locale.get("minute")}`);
    }

    if (hours < 1) {
        let seconds = date.getSeconds();
        sections.push(`${seconds} ${seconds > 1 && 
            OS.Locale.get("seconds") || OS.Locale.get("second")}`);
    }

    return sections.join(", ");
}

function DiffTime(date0, date1) {
    return new Date(Math.max(date0.getTime() - date1.getTime(), 0));
}


class Contract extends HTMLDivElement {
    constructor() {
        super();

        this.vehicle = $(this).attr("vehicle")
        this.type = $(this).attr("type").toUpperCase();
        this.buyin = $(this).attr("buy-in")
        this.index = parseInt($(this).attr("index"));

        this.start = new Date(parseInt($(this).attr("time-start") * 1e3));
        this.timeAvailible = new Date(parseInt($(this).attr("time-availible") * 1e3));
        //ParseToSeconds($(this).attr("time-availible") || "06:00:00")
    }

    connectedCallback() {
        this.innerHTML = `
            <div class="boosting-contract-details">
                <div class="left">
                    <p class="boosting-contract-text">
                        <span class="key" translate="vehicle">Vehicle</span>
                        <span class="boosting-contract-vehicle">${this.vehicle}</span>
                    </p>
                    <p class="boosting-contract-text">
                        <span class="key" translate="contract_type">Contract Type</span>
                        <span class="boosting-contract-type ${this.type}">${this.type}</span>
                    </p>
                </div>
                <div class="right">
                    <p class="boosting-contract-text">
                        <span class="key" translate="expires_in">Expires In</span>
                        <span class="boosting-contract-expire-time"></span>
                    </p>
                    <p class="boosting-contract-text">
                        <span class="key" translate="buy_in">Buy In</span>
                        <span class="boosting-contract-buy-in boosting-currency">${this.buyin}</span>
                    </p>
                </div>
            </div>
            <div class="boosting-contract-buttons">
                <button class="boosting-contract-start-btn" translate="start">Start</button>
                <button class="boosting-contract-transfer-btn" translate="transfer">Transfer</button>
                <button class="boosting-contract-decline-btn" translate="decline">Decline</button>
            </div>
        `;

        this.className = `${this.className} boosting-contract`;
        this.updateExpiretime();

        $(this).on("update", () => {
            this.updateExpiretime();
        });

        OS.translate($(this));
    }

    updateExpiretime() {
        let timePassed = DiffTime(new Date(), this.start);
        let timeLeft = DiffTime(this.timeAvailible, timePassed);

        if (timeLeft.getTime() <= 0) {
            $(this).hide();
            OS.post("boosting-remove-contract", {
                id: this.index
            });
        }

        $(this).find(".boosting-contract-expire-time").text(DateFormat(timeLeft));
    }
}

let handle;
$("#boosting-window").on("on-show", () => {
    function update() {
        $("div[is=\"boosting-contract\"]").trigger("update");
    }
    update();
    handle = setInterval(update, 1000);
});

$("#boosting-window").on("on-hide", () => {
    if (handle) {
        clearInterval(handle);
    }
});


/* Contract Buttons */
$(document).on("click", ".boosting-contract-start-btn", function() {
    let contract = $(this).closest('div[is="boosting-contract"]').get(0);
    OS.post("boosting-start-contract", {
        id: contract.index
    });
    OS.close();
});

$(document).on("click", ".boosting-contract-transfer-btn", function() {

});

$(document).on("click", ".boosting-contract-decline-btn", function() {

});


customElements.define("boosting-contract", Contract, { extends: 'div' });

/* _____________________________________________________________________________ */

let contracts = {}

function AddContract(contract) {
    $(".boosting-contracts").append(`
        <div is="boosting-contract" index="${contract.id}" vehicle="${contract.vehicle}" type="${contract.type}"\
        time-availible="${contract.timeAvailible}", time-start="${contract.created}" buy-in="${contract.value}"></div>
    `);
}

function AddContracts(contracts) {
    contracts.forEach((contract) => {
        AddContract(contract);
    });
}

function RemoveContract(id) {
    $(`div[is="boosting-contract"][index="${id}"]`).remove();
}

function SetContractState(id, started) {
    if (started) {
        $(`div[is="boosting-contract"][index="${id}"]`).addClass("started")
    } else {
        $(`div[is="boosting-contract"][index="${id}"]`).removeClass("started")
    }
}

function SetLevel(rep, level, nextLevel) {
    let a = rep - level.rep
    let b = typeof nextLevel !== "undefined"
        && nextLevel.rep - level.rep
        || a

    $("#boosting-progress-left-label").text(level.label);
    $("#boosting-progress-right-label").text(nextLevel.label);
    $(".boosting-progressbar-fill").css("width", `${Math.min((a / b) * 100, 100)}%`);
}

function SetBNE(bne) {
    $("#boosting-balance").text(bne);
}

function SetName(firstname, lastname) {
    $("#boosting-name").text(`${firstname} ${lastname}`);
}

function SetPicture(pic) {
    /*let url = `https://nui-img/{pic}`;
    $(".profile-picture").attr("src", url);*/
}

function LoadData(data) {
    if (typeof data.bne !== "undefined") {
        SetBNE(data.bne)
    };

    if (typeof data.reputation !== "undefined" && typeof data.level !== "undefined") {
        SetLevel(data.reputation, data.level, data.nextLevel)
    };

    if (typeof data.contracts !== "undefined") {
        AddContracts(data.contracts)
    };

    if (typeof data.firstname !== "undefined" && typeof data.lastname !== "undefined") {
        SetName(data.firstname, data.lastname)
    };
}

$.createPortal("boosting", {
    //update_contracts: UpdateContracts,
    add_contract: AddContract,
    set_contract_state: SetContractState,
    remove_contract: RemoveContract,
    set_name: SetName,
    set_picture: SetPicture,
    set_bne: SetBNE,
    set_level: SetLevel,
    load_data: LoadData,
})