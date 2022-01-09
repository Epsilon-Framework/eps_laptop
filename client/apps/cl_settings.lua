RegisterNUICallback("settings:update", function (data)
    Core.OS:SaveAppData("SYSTEM", "settings", data)
end)


local function load()
    while not Core.OS.Ready do Wait(0) end

    local data = Core.OS:GetAppData("SYSTEM", "settings")
    Post("settings", "load_settings", data or {})
end

CreateThread(function ()
    RegisterNetEvent('QBCore:Client:OnPlayerLoaded', load)
    load()
end)