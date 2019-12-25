// RAWR!

mypublicid.players = mypublicid.players or {}
mypublicid.players.list = mypublicid.players.list or {}

function mypublicid.Get(steamid)
    return mypublicid.players.list[steamid64]
end

function mypublicid.Add(steamid)
    local data = {}
    data["token"] = steamid64
    data["token_name"] = "steamid64"
    http.Post("https://"..mypublicid.config.endpoint.."/game/authorize", data, function(responseText, contentLength, responseHeaders, statusCode)
        local json = util.JSONToTable(responseText)
        mypublicid.players.list[steamid64] = json
        local ply = player.GetBySteamID64(steamid64)
        if (ply && mypublicid.Test(ply) == false) then
            ply:Kick(mypublicid.config.message)
        end
    end, function(errorMessage)
        // Oh no! It has all gone horribly wrong!
        error(errorMessage)
    end, {"x-api-key" = mypublicid.config.apikey, "Content-Type" = "application/x-www-form-urlencoded"})
end

function mypublicid.Test(ply)
    if (!IsValid(ply) || !ply.IsPlayer || !ply:IsPlayer()) then
        return true
    end

    return mypublicid.TestID(ply:SteamID64())
end

// Uniform decision of whether players are allowed
function mypublicid.TestID(steamid64)
    local data = mypublicid.players.Get(steamid64)
    if (data) then
        if (data.active && !data.banned) then
            if (mypublicid.config.region > 0 && mypublicid.config.region != data.region) then
                return false
            end
            return true
        end
        return false
    end
    // Pull from the API
    mypublicid.Add(steamid64)
    return nil
end