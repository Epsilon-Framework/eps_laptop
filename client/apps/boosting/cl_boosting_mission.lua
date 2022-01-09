local random = math.random


-- ______________________________________________________
BoostingBlips = {}

STAGES = {
    CANCELED = -1,
    SEARCHING_FOR_VEHICLE = 1,
    REMOVING_TRACKER = 2,
    DELIVER_VEHICLE = 3,
    EXIT_AREA = 4,
    COMPLETED = 5,
}


function BoostingBlips:add(name, blip)
    self:remove(name)
    self[name] = blip
    return blip
end


function BoostingBlips:remove(name)
    local blip = self[name]
    if DoesBlipExist(blip) then
        RemoveBlip(blip)
    end
    self[name] = nil
end


function BoostingBlips:doesExist(name)
    return DoesBlipExist(self[name])
end


function BoostingBlips:removeAll()
    for name, v in ipairs(self) do
        if type(v) ~= "function" then
            self:remove(name)
        end
    end
end



-- ______________________________________________________
BoostingMission = {
    Active = false,
}


local function RegisterStageEvent(stage, cb)
    local eventname = ("qb-laptop:boosting:stage:%s"):format(stage)
    RegisterNetEvent(eventname)
    return AddEventHandler(eventname, cb)
end


function BoostingMission:create(contractId)
    if self.Active then
        return
    end

    local contract = GetBoostingContract(contractId)
    if contract then
        self.Active = true
        self.Shared = false

        self.Owner = GetPlayerServerId(PlayerId())
        self.ContractId = contractId

        self.Data = {}
        self.Data.sender = contract.sender
        self.Data.type = contract.type

        self.Data.coords = RandomChoice(Config.VehicleCoords)
        self.Data.offset = {
            x = random(0, Config.VehicleBlip.Radius) - Config.VehicleBlip.Radius * 0.5,
            y = random(0, Config.VehicleBlip.Radius) - Config.VehicleBlip.Radius * 0.5,
            z = 0
        }
        self.Data.dropoff = RandomChoice(Config.DropOffCoords)

        self.Data.tracker = Config.Classes[contract.type].tracker

        self.VehHandle = CreateBoostingVehicle(contract.vehicle, self.Data.coords)

        self.Data.vehicleName = GetDisplayNameFromVehicleModel(contract.vehicle)
        self.Data.vehiclePlate = GetVehicleNumberPlateText(self.VehHandle)


        SendStartedContractEmail(self.Data.sender, self.Data.vehicleName, self.Data.type, self.Data.vehiclePlate)

        QBCore.Functions.TriggerCallback("qb-laptop:boosting:AddMission", function(id)
            self.MissionId = id
            self:setStage(STAGES.SEARCHING_FOR_VEHICLE, true)
        end, contractId, self.Data)
    else
        print(("ERROR contract %d doesn't exist"):format(contractId))
    end

end


function BoostingMission:join(missionId)
    QBCore.Functions.TriggerCallback("qb-laptop:boosting:JoinMission", function(missionInfo)
        local data = missionInfo.data

        if self.Active then
            return
        end

        self.Active = true
        self.Shared = true

        self.Owner = missionInfo.owner
        self.MissionId = missionInfo.id

        self.Data = data

        SendJoinedContractEmail(data.sender, data.vehicleName, data.type, data.vehiclePlate)


        if missionInfo.stage then
            self:setStage(missionInfo.stage, false)
        end
    end, missionId)
end


function BoostingMission:setStage(stage, broadcast)
    if self.Stage ~= stage then
        if broadcast then
            TriggerServerEvent("qb-laptop:boosting:SetMissionStage", self.MissionId, stage)
        end

        self.Stage = stage
        TriggerEvent(("qb-laptop:boosting:stage:%s"):format(stage))
    end
end


function BoostingMission:isActive()
    return self.Active
end


function BoostingMission:isShared()
    return self.Shared
end


function BoostingMission:cleanup()
    if self.VehHandle then
        SetEntityAsMissionEntity(self.Active, true, true)
        DeleteEntity(self.VehHandle)
    end

    for k, v in pairs(self) do
        if type(v) ~= "function" then
            self[k] = nil
        end
    end
end


RegisterCommand("join-boosting-mission", function(_, args)
    local id = tonumber(args[1])
    if not BoostingMission:isActive() then
        BoostingMission:join(id)
    end
end)


function CreateBoostingVehicle(model, coords)
    local modelHash = tostring(model)
    assert(IsModelInCdimage(modelHash), ("Model %s doesn't exist in CD Image!"):format(model))

    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(10)
    end

    return CreateVehicle(modelHash, coords.x, coords.y, coords.z, coords.h, true, false)
end


RegisterNUICallback("boosting-cancel-contract", function()
    if BoostingMission:isActive() then
        if BoostingMission:isShared() then
            BoostingMission:setStage(STAGES.CANCELED, false)
        else
            BoostingMission:setStage(STAGES.CANCELED, false)
            TriggerServerEvent("qb-laptop:boosting:CancelMission", BoostingMission.MissionId)
        end
    end
end)


RegisterNUICallback("boosting-invite-mission", function(data)
    if BoostingMission:isActive() then
        TriggerServerEvent("qb-laptop:boosting:InviteMission", BoostingMission.MissionId, data.citizenid)
    end
end)


RegisterNetEvent("qb-laptop:boosting:SetMissionStage")
AddEventHandler("qb-laptop:boosting:SetMissionStage", function(stage)
    if BoostingMission:isActive() then
        BoostingMission:setStage(stage, false)
    end
end)


RegisterStageEvent(STAGES.SEARCHING_FOR_VEHICLE, function()
    local data = BoostingMission.Data

    local coordsZone = BoostingBlips:add("coords", AddBlipForRadius(
        data.coords.x + data.offset.x,
        data.coords.y + data.offset.y,
        data.coords.z + data.offset.z,
        Config.VehicleBlip.Radius
    ))
    SetBlipHighDetail(coordsZone, true)
    SetBlipColour(coordsZone, Config.VehicleBlip.Color)
    SetBlipAlpha (coordsZone, Config.VehicleBlip.Alpha)
    SetBlipRoute(coordsZone, Config.VehicleBlip.Route)
    SetBlipRouteColour(coordsZone, Config.VehicleBlip.Color)

    CreateThread(function()
        while BoostingMission.Stage == STAGES.SEARCHING_FOR_VEHICLE do
            Wait(1000)
            local veh = GetVehiclePedIsIn(GetPlayerPed(-1), false)
            if veh ~= 0 then
                if(GetVehicleNumberPlateText(veh) == data.vehiclePlate) then
                    if data.tracker then
                        BoostingMission:setStage(STAGES.REMOVING_TRACKER, true)
                    else
                        BoostingMission:setStage(STAGES.DELIVER_VEHICLE, true)
                    end
                end
            end
        end
    end)
end)


RegisterStageEvent(STAGES.REMOVING_TRACKER, function()
    local data = BoostingMission.Data

    BoostingBlips:remove("coords")
    BoostingBlips:remove("debugblip")

    if not BoostingMission:isShared() then
        CreateThread(function()
            local primary, secondary = GetVehicleColours()
            primary = COLOR_NAMES[primary]
            secondary = COLOR_NAMES[secondary]

            local streetAndZone = GetStreetandZone(GetEntityCoords(BoostingMission.VehHandle))

            TriggerServerEvent("qb-laptop:boosting:NotifyCops",
                data.vehicleName, data.vehiclePlate, {primary, secondary}, streetAndZone)

            -- Tracker Blip Update Loop
            while BoostingMission.Stage == STAGES.REMOVING_TRACKER do
                Wait(Config.Classes[data.type].trackerUpdateTime)
                local coords = GetEntityCoords(BoostingMission.VehHandle)

                TriggerServerEvent('qb-laptop:boosting:TrackerBlip', BoostingMission.MissionId, coords)
            end
        end)
    end
end)


RegisterStageEvent(STAGES.DELIVER_VEHICLE, function()
    local data = BoostingMission.Data

    BoostingBlips:remove("coords")
    BoostingBlips:remove("debugblip")

    -- Create Drop off Blip
    local blip = BoostingBlips:add("dropoff", AddBlipForCoord(data.dropoff.x, data.dropoff.y, data.dropoff.z))
    SetBlipColour(blip, Config.DropOffBlip.Color)
    SetBlipRoute(blip, Config.DropOffBlip.Route)
    SetBlipRouteColour(blip, Config.DropOffBlip.Color)
    SetBlipSprite(blip, Config.DropOffBlip.Sprite)
    SetBlipScale(blip, Config.DropOffBlip.Scale)
    SetBlipAsShortRange(blip, false)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.DropOffBlip.Label)
    EndTextCommandSetBlipName(blip)

    if not BoostingMission:isShared() then
        while BoostingMission.Stage == STAGES.DELIVER_VEHICLE do
            Wait(1000)
            local coords = GetEntityCoords(BoostingMission.VehHandle)
            local dist = GetDistanceBetweenCoords(
                data.dropoff.x, data.dropoff.y, data.dropoff.z,
                coords.x, coords.y, coords.z
            )
            if dist < 10.0 then
                BoostingMission:setStage(STAGES.EXIT_AREA, true)
            end
        end
    end
end)


RegisterStageEvent(STAGES.EXIT_AREA, function()
    local data = BoostingMission.Data

    TriggerServerEvent("qb-laptop:boosting:NotifyArrived", BoostingMission.MissionId)

    SetVehicleDoorsLockedForAllPlayers(BoostingMission.VehHandle, true)
    SetVehicleEngineOn(BoostingMission.VehHandle, false, true, true)
    SetVehicleFuelLevel(BoostingMission.VehHandle, 0)

    BoostingBlips:remove("dropoff")

    if not BoostingMission:isShared() then
        while BoostingMission.Stage == STAGES.EXIT_AREA do
            Wait(1000)
            local coords = GetEntityCoords(GetPlayerPed(-1))
            local dist = GetDistanceBetweenCoords(
                data.dropoff.x, data.dropoff.y, data.dropoff.z,
                coords.x, coords.y, coords.z
            )
            if dist > 60.0 then
                BoostingMission:setStage(STAGES.COMPLETED, true)
            end
        end
    end
end)


RegisterStageEvent(STAGES.COMPLETED, function()
    if not BoostingMission:isShared() then
        RemoveBoostingContract(BoostingMission.ContractId)
        Post("boosting", "remove_contract", BoostingMission.ContractId)

        SetEntityAsMissionEntity(BoostingMission.VehHandle, true, true)
        SetEntityAsNoLongerNeeded(BoostingMission.VehHandle)
        UnregisterRawNuiCallback("boosting-contract-cancel")

        TriggerServerEvent("qb-laptop:boosting:MissionCompleted", BoostingMission.MissionId)
    end

    BoostingMission:cleanup()
    BoostingBlips:removeAll()
end)


RegisterStageEvent(STAGES.CANCELED, function()
    BoostingMission:cleanup()
    BoostingBlips:removeAll()
end)


RegisterNetEvent("qb-laptop:boosting:TrackerBlip")
AddEventHandler("qb-laptop:boosting:TrackerBlip", function(coords)
    local blip = BoostingBlips:add("tracker", AddBlipForCoord(coords.x, coords.y, coords.z))
    SetBlipSprite(blip , Config.TrackerBlip.Sprite)
    SetBlipScale(blip , Config.TrackerBlip.Scale)
    SetBlipColour(blip, Config.TrackerBlip.Color)
    PulseBlip(blip)
end)


RegisterNetEvent("qb-laptop:boosting:RemoveTrackerBlip")
AddEventHandler("qb-laptop:boosting:RemoveTrackerBlip", function(coords)
    BoostingBlips:remove("tracker")
end)


RegisterNetEvent("qb-laptop:boosting:CreateBlip")
AddEventHandler("qb-laptop:boosting:CreateBlip", function()
    if BoostingMission.Stage == STAGES.SEARCHING_FOR_VEHICLE then
        local coords = BoostingMission.Data.coords

        local blip
        if BoostingMission:isShared() then
            blip = BoostingBlips:add("debugblip", AddBlipForCoord(coords.x, coords.y, coords.z))
        else
            blip = BoostingBlips:add("debugblip", AddBlipForEntity(BoostingMission.VehHandle))
        end

        SetBlipDisplay(blip, 6)
        SetBlipSprite(blip, 225)
        SetBlipColour(blip, 83)
        SetBlipRoute(blip, true)
        SetBlipRouteColour(blip, 83)
        SetBlipAsMissionCreatorBlip(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(BoostingMission.Data.vehicleName)
        EndTextCommandSetBlipName(blip)

        Notify("Created a Contract Blip!")
    else
        Notify("No contracts are active at the momment!", error)
    end
end)