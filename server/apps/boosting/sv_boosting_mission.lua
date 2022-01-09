local MissionCounter = 0
Missions = {}


function GetBoostingMission(missionId)
    for _, mission in ipairs(Missions) do
        if mission.id == missionId then
            return mission
        end
    end
end


function RemoveBoostingMission(missionId)
    for i, mission in ipairs(Missions) do
        if mission.id == missionId then
            table.remove(Missions, i)
            break
        end
    end
end


function AddBoostingMission(source, contractId, data)
    MissionCounter = MissionCounter + 1

    local contract = GetBoostingContract(source, contractId)
    if contract then
        local mission = {
            id = MissionCounter,
            data = data,
            owner = source,
            contractId = contractId,
            players = {}
        }
        table.insert(Missions, mission)

        return mission.id
    else
        print(("ERROR contract %d doesn't exist"):format(contractId))
    end
end


RegisterCommand("boosting-mission-id", function(source)
    local src = source
    for i, mission in ipairs(Missions) do
        if mission.owner == src then
            print("Mission Id: ", i)
            return
        end
    end
    print("Not in a mission")
end)


function GiveContractRewards(source, missionId)
    local data = GetBoostingData(source)
    local mission = GetBoostingMission(missionId)
    local contract = GetBoostingContract(mission.owner, mission.contractId)

    if not mission then
        return print(("ERROR Mission %d doesn't exist!"):format(missionId or -1))
    end

    if not contract then
        return print(("ERROR Contract %d for player %d doesn't exist!"):format(mission.contractId or -1, mission.owner))
    end

    local share = mission.owner == source and {
        bne = 1,
        reputation = 1
    } or Config.ContractShare

    local repMult = RandomRange(Config.Classes[contract.type].reputationMult, 2)
    local reputation = RandomRange(data.level.reputationGain, 2) * repMult * share.reputation

    if data.nextLevel then

        data.reputation = data.reputation + reputation

        if data.reputation >= data.nextLevel.rep then
            data.level, data.nextLevel = GetBoostingLevel(data.reputation)
        end
    end

    data.bne = contract.value * share.bne

    TriggerClientEvent("qb-laptop:boosting:Paycheck", source, contract.value * share.bne)
    TriggerClientEvent("qb-laptop:boosting:UpdateData", source, {
        level = data.level,
        nextLevel = data.nextLevel,
        reputation = data.reputation,
        bne = data.bne
    })
end


QBCore.Functions.CreateCallback("qb-laptop:boosting:AddMission", function(source, cb, contractId, data)
    local src = source
    local id = AddBoostingMission(src, contractId, data)
    cb(id)
end)


RegisterServerEvent("qb-laptop:boosting:MissionCompleted")
AddEventHandler("qb-laptop:boosting:MissionCompleted", function(missionId)
    local src = source
    local mission = GetBoostingMission(missionId)

    if not mission then
        return print(("ERROR Mission %d doesn't exist!"):format(missionId or -1))
    end

    if not (mission.owner == src or mission.players[src]) then
        return print(("ERROR Player %d is not the owner of mission %d!"):format(src, missionId))
    end

    for player in ipairs(mission.players) do
        GiveContractRewards(player, missionId)
        SaveBoostingData(player)
    end

    GiveContractRewards(mission.owner, missionId)
    RemoveBoostingContract(source, mission.contractId)
    SaveBoostingData(mission.owner)
end)


RegisterServerEvent("qb-laptop:boosting:SetMissionStage")
AddEventHandler("qb-laptop:boosting:SetMissionStage", function(missionId, stage)
    local src = source
    local mission = GetBoostingMission(missionId)

    if not mission then
        return print(("ERROR Mission %d doesn't exist!"):format(missionId or -1))
    end

    if not (mission.owner == src or mission.players[src]) then
        return print(("ERROR Player %d is not part of mission %d!"):format(src, missionId))
    end

    mission.stage = stage

    for player in pairs(mission.players) do
        TriggerClientEvent("qb-laptop:boosting:SetMissionStage", player, stage)
    end

   TriggerClientEvent("qb-laptop:boosting:SetMissionStage", mission.owner, stage)
end)

RegisterServerEvent("qb-laptop:boosting:NotifyArrived")
AddEventHandler("qb-laptop:boosting:NotifyArrived", function(missionId)
    local src = source
    local mission = GetBoostingMission(missionId)

    if not mission then
        return print(("ERROR Mission %d doesn't exist!"):format(missionId or -1))
    end

    if not (mission.owner == src or mission.players[src]) then
        return print(("ERROR Player %d is not part of mission %d!"):format(src, missionId))
    end

    for player in ipairs(mission.players) do
        Notify(player, Config.Notifications.DropOffMsg, "success", 3500)
    end
    Notify(mission.owner, Config.Notifications.DropOffMsg, "success", 3500)
end)


RegisterServerEvent("qb-laptop:boosting:CancelMission")
AddEventHandler("qb-laptop:boosting:CancelMission", function(missionId)
    local src = source
    local mission = GetBoostingMission(missionId)

    if not mission then
        return print(("ERROR Mission %d doesn't exist!"):format(missionId or -1))
    end

    if not (mission.owner == src or mission.players[src]) then
        return print(("ERROR Player %d is not the owner of mission %d!"):format(src, missionId))
    end

    for player in ipairs(mission.players) do
        TriggerClientEvent("qb-laptop:boosting:CanceledMission", player)
    end
end)


QBCore.Functions.CreateCallback("qb-laptop:boosting:JoinMission", function(source, cb, missionId)
    local src = source
    local mission = GetBoostingMission(missionId)

    if not mission then
        return print(("ERROR Mission %d doesn't exist!"):format(missionId or -1))
    end

    mission.players[src] = true
    cb(mission)
end)


RegisterServerEvent("qb-laptop:boosting:TrackerBlip")
AddEventHandler("qb-laptop:boosting:TrackerBlip", function(missionId, coords)
    local mission = GetBoostingMission(missionId)

    if not mission then
        return print(("ERROR Mission %d doesn't exist!"):format(missionId or -1))
    end

    for _, src in pairs(QBCore.Functions.GetPlayers()) do
        local player = QBCore.Functions.GetPlayer(src)
        local job = player and player.PlayerData.job.name
        if mission.owner == src
            or mission.players[src]
            or job == Config.PoliceJobName
        then
            TriggerClientEvent('qb-laptop:boosting:TrackerBlip', src, coords)
        end
    end
end)