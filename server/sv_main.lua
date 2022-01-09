local IS_NIL = {["nil"]=true, ["null"]=true}

function GetAppData(source, app, key, cb)
    local player = QBCore.Functions.GetPlayer(source)
    local pData = player and player.PlayerData
    local cid = pData and pData.citizenid

    if cid then
        local result = SingleSync("SELECT data FROM laptop_appdata WHERE citizenid=@cid AND app=@app AND `key`=@key", {
            cid = cid,
            app = app,
            key = key
        }) or { data="{}" }
        if cb then cb(json.decode(result.data))
        else return json.decode(result.data) end
    end
end

function SaveAppData(source, app, key, data)
    local player = QBCore.Functions.GetPlayer(source)
    local pData = player and player.PlayerData
    local cid = pData and pData.citizenid

    if cid then
        local currentData = GetAppData(source, app, key)
        for k, v in pairs(data) do
            if IS_NIL[v] then currentData[k] = nil
            else currentData[k] = v end
        end

        return SingleSync("INSERT INTO laptop_appdata (citizenid, app, `key`, data) VALUES (@cid, @app, @key, @data) ON DUPLICATE KEY UPDATE data=@data", {
            cid=tostring(cid),
            app=app,
            key=key,
            data=json.encode(currentData)
        })
    end
end


RegisterServerEvent("qb-laptop:OS:SaveAppData")
AddEventHandler("qb-laptop:OS:SaveAppData", function(app, key, data)
    local src = source
    SaveAppData(src, app, key, data)
end)


QBCore.Functions.CreateCallback('qb-laptop:OS:GetAppData', function(source, cb, app, key)
    local src = source
    GetAppData(src, app, key, cb)
end)


QBCore.Functions.CreateUseableItem("qblaptop", function(source, item)
    local Player = QBCore.Functions.GetPlayer(source)

    if Player.Functions.GetItemByName(item.name) then
        TriggerClientEvent("qb-laptop:OpenLaptop", source)
    end
end)