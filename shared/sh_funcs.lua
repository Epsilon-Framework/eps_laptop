math.randomseed(tonumber(tostring({}):sub(8), 16))

function NewResult()
    local result = nil

    local function set(val)
        result = val
    end

    local function get()
        while not result do
            Citizen.Wait(0)
        end
        return result
    end

    return set, get
end

function RandomChoice(t)
    return t[math.random(#t)]
end

function WeigtedRandom(t)
    if not t.total then
        local total = 0
        for _, class in ipairs(t) do
            total = total + class.weight
        end
        t.total = total
    end

    local rnd = math.random(t.total)

    for _, class in ipairs(t) do
        if (rnd < class.weight) then
            return class.value
        end
        rnd = rnd - class.weight
    end
end

function RandomRange(t, decimals)
    decimals = decimals or 3
    local n = t.min + math.random() * (t.max - t.min)
    if n == 1 or n == 0 then return n end
    local q, f = math.modf(n/decimals)
    return decimals * (q + (f > 0.5 and 1 or 0))
end

function RandomIntRange(t)
    return math.random(t.min, t.max)
end