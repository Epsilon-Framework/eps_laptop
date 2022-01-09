Contracts = {}

local function load()
    while not Core.OS.Ready do Wait(0) end

    QBCore.Functions.TriggerCallback('qb-laptop:boosting:GetData', function(data)
        if data then
            Contracts = data.contracts

            local playerdata = QBCore.Functions.GetPlayerData()
            local firstname = playerdata.charinfo.firstname
            local lastname = playerdata.charinfo.lastname
            data.firstname = firstname
            data.lastname = lastname

            Post("boosting", "load_data", data)
        end
    end)
end


function GetBoostingContract(id)
    for _, contract in ipairs(Contracts) do
        if contract.id == id then
            return contract
        end
    end
end


function RemoveBoostingContract(id)
    for i, contract in ipairs(Contracts) do
        if contract.id == id then
            table.remove(Contracts, i)
            break
        end
    end
end


function GetStreetandZone(coords)
	local zone = GetLabelText(GetNameOfZone(coords.x, coords.y, coords.z))
	local streetHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
	local streetName = GetStreetNameFromHashKey(streetHash)
	return ("%s, %s"):format(streetName, zone)
end


function SpawnVehicle(model, coords)
    local modelHash = tostring(model)
    assert(IsModelInCdimage(modelHash), ("Model %s doesn't exist in CD Image!"):format(model))

    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(10)
    end

    local vehicle = CreateVehicle(modelHash, coords.x, coords.y, coords.z, coords.h, true, false)
    return vehicle, GetVehicleNumberPlateText(vehicle)
end


CreateThread(function ()
    RegisterNetEvent('QBCore:Client:OnPlayerLoaded', load)
    load()
end)

-- _______________________________________________________ EMAIL _______________________________________________________
local function hightlight(text, hex)
    return ("<span style=\"color: #%s\">%s</span>"):format(hex, text)
end


function SendStartedContractEmail(sender, vehiclename, type, plate)
    SendEmail{
        sender = sender,
        subject = Config.Emails.StartContract.subject,
        message = Config.Emails.StartContract.message:format(
            hightlight(vehiclename, "#3fbdeb"),
            hightlight(type, "#3fbdeb"),
            hightlight(plate, "#3fbdeb")
        ),
        button = {}
    }
end

function SendJoinedContractEmail(sender, vehiclename, type, plate)
    SendEmail{
        sender = sender,
        subject = Config.Emails.JoinContract.subject,
        message = Config.Emails.JoinContract.message:format(
            hightlight(vehiclename, "#3fbdeb"),
            hightlight(type, "#3fbdeb"),
            hightlight(plate, "#3fbdeb")
        ),
        button = {}
    }
end

function SendRecievedContractEmail(sender, class)
    SendEmail{
        sender = sender,
        subject = Config.Emails.RecievedContract.subject,
        message = Config.Emails.RecievedContract.message:format(hightlight(class)),
        button = {}
    }
end

function SendCompletedContractEmail(value)
    SendEmail{
        sender = Config.Emails.CompletedContract.sender,
        subject = Config.Emails.CompletedContract.subject,
        message = Config.Emails.CompletedContract.message:format(hightlight(value)),
        button = {},
    }
end
-- _______________________________________________________________________________________________________________________


RegisterNetEvent("qb-laptop:boosting:AddContract")
AddEventHandler("qb-laptop:boosting:AddContract", function(contract)
    table.insert(Contracts, contract)
    SendRecievedContractEmail(contract.sender, contract.type)
    Post("boosting", "add_contract", contract)
end)


RegisterNetEvent("qb-laptop:boosting:AddSharedMission", function (missionId, data)
    Post("boosting", "add_invite", missionId, data)
end)


RegisterNetEvent("qb-laptop:boosting:RemoveSharedMission", function (missionId)
    Post("boosting", "remove_invite", missionId)
end)


RegisterNetEvent("qb-laptop:boosting:CanceledMission", function (missionId)
    Post("boosting", "remove_invite", missionId)
end)


RegisterNUICallback("boosting-start-contract", function(data)
    if data.isShared then
        QBCore.Functions.TriggerCallback("qb-laptop:boosting:JoinContract", function(missionData)
            BoostingMission:join(missionData)
        end, data.missionId)
    else
        BoostingMission:create(data.id)
    end
end)


RegisterNUICallback("boosting-remove-contract", function(data)
    RemoveBoostingContract(data.id)
    TriggerServerEvent("qb-laptop:boosting:RemoveContract", data.id)
end)


RegisterNetEvent("qb-laptop:boosting:UpdateData")
AddEventHandler("qb-laptop:boosting:UpdateData", function(data)
    Post("boosting", "load_data", data)
end)


RegisterNetEvent("qb-laptop:boosting:Paycheck")
AddEventHandler("qb-laptop:boosting:Paycheck", function(value)
    SendCompletedContractEmail(value)
end)


-- _______________________________________________________ DEBUG _____________________________________________________

--if GetConvarInt("debug", 0) == 1 then
    local ratingCache = {}
    local vehicleClassCache = {}

    local function getField(field , vehicle)
        return GetVehicleHandlingFloat(vehicle, 'CHandlingData', field)
    end

    local function GetVehiclePerformanceRating(model)
        if not ratingCache[model] then
            local modelHash = tostring(model)

            if not IsModelInCdimage(modelHash) then
                return -1
            elseif IsThisModelABike(modelHash) then
                return 0
            end

            local vehicle = CreateVehicle(modelHash, 0, 0, 0, 0.0, false, false)

            local fInitialDriveMaxFlatVel = getField("fInitialDriveMaxFlatVel" , vehicle)
            local fInitialDragCoeff = getField("fInitialDragCoeff", vehicle)
            local fTractionCurveMax = getField("fTractionCurveMax", vehicle)
            local fTractionCurveMin = getField("fTractionCurveMin", vehicle)
            local fBrakeForce = getField("fBrakeForce" , vehicle)
            local force = getField("fInitialDriveForce" , vehicle)
            local handling = (fTractionCurveMax + getField("fSuspensionReboundDamp", vehicle)) * fTractionCurveMin
            local braking = ((fTractionCurveMin / fInitialDragCoeff) * fBrakeForce) * 7
            local accel = (fInitialDriveMaxFlatVel * force) / 10
            local speed = ((fInitialDriveMaxFlatVel / fInitialDragCoeff) * (fTractionCurveMax + fTractionCurveMin)) / 40

            local pr = ((accel * 5) + speed + handling + braking) * 15
            ratingCache[model] = pr

            SetEntityAsMissionEntity(vehicle, true, true)
            DeleteVehicle(vehicle)
        end
        return ratingCache[model]
    end

    local function GetVehicleClassFromPerformenceRating(pr)
        if pr == -1 then
            return "N/A"
        elseif pr == 0 then
            return "M"
        elseif pr > 750 then
            return "X"
        elseif pr > 650 then
            return "S"
        elseif pr > 550 then
            return "A"
        elseif pr > 400 then
            return "B"
        elseif pr > 325 then
            return "C"
        end
        return "D"
    end

    local function GetVehicleClassFromModel(model)
        if not vehicleClassCache[model] then
            local pr = GetVehiclePerformanceRating(model)
            vehicleClassCache[model] = GetVehicleClassFromPerformenceRating(pr)
        end
        return vehicleClassCache[model]
    end

    RegisterCommand("pr", function (source, args)
        local name = args[1]
        if not name then
            local ped = GetPlayerPed()
            local veh = GetVehiclePedIsIn(ped, false)

            local hash = GetEntityModel(veh)
            name = GetDisplayNameFromVehicleModel(hash)
        end

        local pr = GetVehiclePerformanceRating(name)
        local class = GetVehicleClassFromPerformenceRating(pr)

        print("________________________________________")
        print("CAR         : ", name)
        print("PERF_RATING : ", pr)
        print("CLASS       : ", class)
        print("________________________________________")
    end)
--end