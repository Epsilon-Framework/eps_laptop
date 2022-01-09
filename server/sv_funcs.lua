local random = math.random


--[[_______________ Database _______________]]
local ghmattimysql = exports.ghmattimysql

local function newValuePromise()
    local val

    local function get()
        while not val do
            Citizen.Wait(0)
        end
        return val
    end

    local function set(v)
        val = v
    end

    return set, get
end

local function exec(type, query, parameters, cb)
    local set, get = newValuePromise()

    ghmattimysql[type](ghmattimysql, query, parameters, cb or set)

    if not cb then
        return get()
    end
end

function Execute(query, parameters)
    return exec("execute", query, parameters)
end

function SingleSync(query, parameters, cb)
    local set, get = newValuePromise()

    exec("execute", query, parameters, set)

    local result = get()
    result = result and result[1] or nil

    if cb then
        cb(result)
    else
        return result
    end
end

function InsertSync(query, parameters, cb)
    return exec("insertSync", query, parameters, cb)
end

--[[_______________ Main _______________]]

function Notify(source, message, type, time)
    TriggerClientEvent("QBCore:Notify", source, message, type, time)
end