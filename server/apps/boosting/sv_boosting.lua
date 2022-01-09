local playerCache = {}


function GetBoostingLevel(reputation)
    local lvl, nextLvl
    for _, level in ipairs(Config.Levels) do
        if level.rep <= reputation then
            lvl = level
        else
            nextLvl = level
            break
        end
    end
    return lvl, nextLvl
end


function GetBoostingData(source)
    if not playerCache[source] then

        local data = GetAppData(source, "boosting", "playerdata")
        if not data then
            return
        end

        if not next(data) then
            data = { bne=0, reputation=0, contracts={} }
        end

        local contracts = {}
        data.counter = 0
        for _, contract in ipairs(data.contracts) do
            local timeLeft = contract.timeAvailible - os.difftime(os.time(), contract.created)
            if timeLeft > 0 then
                data.counter = data.counter + 1
                contract.id = data.counter
                table.insert(contracts, contract)
            end
        end
        data.contracts = contracts

        data.level, data.nextLevel = GetBoostingLevel(data.reputation)

        playerCache[source] = data
    end
    return playerCache[source]
end


function GetBoostingContract(source, contractId)
    local data = GetBoostingData(source)

    for _, contract in ipairs(data.contracts) do
        if contract.id == contractId then
            return contract
        end
    end
end


function CreateBoostingContract(source, type)
    local data = GetBoostingData(source)

    if #data.contracts < Config.MaxContracts then
        local contractType = type or WeigtedRandom(data.level.weights)

        data.counter = data.counter + 1

        local mult = RandomRange(data.level.bneMult, 2)
        local value = RandomRange(Config.Classes[contractType].value, 2) * mult

        local contract = {}
        contract.created = os.time()
        contract.id = data.counter
        contract.timeAvailible = Config.ExpireTime.hour * 3600 + Config.ExpireTime.min * 60 + Config.ExpireTime.sec
        contract.type = contractType
        contract.vehicle = RandomChoice(Config.Vehicles[contractType])
        contract.value = value
        contract.sender = ("%s %s"):format(RandomChoice(Config.CitizenFirstNames), RandomChoice(Config.CitizenLastNames))

        table.insert(data.contracts, contract)

        SaveBoostingData(source)

        TriggerClientEvent("qb-laptop:boosting:AddContract", source, contract)
    end
end


function RemoveBoostingContract(source, contractId)
    local data = GetBoostingData(source)

    for i, contract in ipairs(data.contracts) do
        if contract.id == contractId then
            table.remove(data.contracts, i)
            break
        end
    end
end


function SaveBoostingData(source)
    local data = GetBoostingData(source)

    local contracts = {}
    for _, contract in ipairs(data.contracts) do
        local t = {}
        for k, v in pairs(contract) do
            if k ~= "id" then
                t[k] = v
            end
        end
        table.insert(contracts, t)
    end

    SaveAppData(source, "boosting", "playerdata", {
        reputation = data.reputation,
        bne = data.bne,
        contracts = contracts
    })
end


QBCore.Functions.CreateCallback("qb-laptop:boosting:GetData", function (source, cb)
    local src = source
    local data = GetBoostingData(src)
    cb(data)
end)


RegisterServerEvent("qb-laptop:boosting:CreateContract")
AddEventHandler("qb-laptop:boosting:CreateContract", function()
    local src = source
    CreateBoostingContract(src)
end)


RegisterServerEvent("qb-laptop:boosting:RemoveContract")
AddEventHandler("qb-laptop:boosting:RemoveContract", function (contractId)
    local src = source

    RemoveBoostingContract(src, contractId)
    SaveBoostingData(src)
end)


RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    local src = source
    playerCache[src] = nil
end)

RegisterNetEvent("onPlayerDrop", function ()
    local src = source
    playerCache[src] = nil
end)


QBCore.Commands.Add('boosting-blip', 'Creates a blip for current contract (Admin Only)', {}, false, function(source)
    local src = source
    TriggerClientEvent("qb-laptop:boosting:CreateBlip", src)
end, 'admin')


QBCore.Commands.Add('boosting-contract', 'Creates a contract (Admin Only)', {}, false, function(source, args)
    local src = source
    local type = Config.Classes[args[1]] and args[1] or nil

    CreateBoostingContract(src, type)
end, 'admin')