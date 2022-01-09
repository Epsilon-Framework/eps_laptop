Display = false

function Post(type, action, ...)
    SendNuiMessage(json.encode({
        type=type,
        action=action,
        args={...}
    }))
end


function SendChat(msg, color)
    TriggerEvent("chat:addMessage", {
        color=color,
        multiline=true,
        args={msg}
    })
end


function HasItem(item)
    
end


function SendEmail(data)
    TriggerServerEvent("qb-phone:server:sendNewMail", data)
end


function Notify(message, type, time)
    QBCore.Functions.Notify(message, type, time)
end


Core = {}

Core.OS = { Ready = false }

function Core.OS:SaveAppData(app, key, data)
    TriggerServerEvent("qb-laptop:OS:SaveAppData", app, key, data)
end

function Core.OS:GetAppData(app, key)
    local set, get = NewResult()
    QBCore.Functions.TriggerCallback("qb-laptop:OS:GetAppData", set, app, key)
    return get()
end