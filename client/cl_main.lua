--QBCore = exports["qb-core"]:GetCoreObject()

local display = false

function SetDisplay(visible)
    display = visible

    if visible then
        CreateThread(function()
            repeat
                Wait(0)
                DisableControlAction(0, 1,   display)
                DisableControlAction(0, 2,   display)
                DisableControlAction(0, 142, display)
                DisableControlAction(0, 18,  display)
                DisableControlAction(0, 322, display)
                DisableControlAction(0, 106, display)
            until not display
        end)
    end

    SetNuiFocus(visible, visible)
    Post("ui", visible and "show" or "hide")
end


--[[
CreateThread(function()
    while true do
        if IsControlJustPressed(0, 288) then
            SetDisplay(not display)
        end
        Wait(0)
    end
end)]]


RegisterNetEvent("qb-laptop:OpenLaptop")
AddEventHandler("qb-laptop:OpenLaptop", function()
    SetDisplay(true)
end)


RegisterNUICallback("close", function()
    display = false
    SetNuiFocus(false, false)
end)

RegisterNUICallback("ready", function ()
    Post("os", "init", Config.Lang, Config.DateLocal)
    Post("os", "install_app", "boosting", true)
    Post("os", "install_app", "disabler", true)
    Core.OS.Ready = true
end)