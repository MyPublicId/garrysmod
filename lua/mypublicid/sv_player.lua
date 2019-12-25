// RAWR!

mypublicid.players = mypublicid.players or {}
mypublicid.players.list = mypublicid.players.list or {}

local function httpRequest(method, url, params, onsuccess, onfailure, headers)
    local request = {
		url			= url,
		method		= method,
		parameters	= params,
        type        = "application/x-www-form-urlencoded",
		headers		= header or {},

		success = function( code, body, headers )

			if ( !onsuccess ) then return end

			onsuccess( body, body:len(), headers, code )

		end,

		failed = function( err )

			if ( !onfailure ) then return end

			onfailure( err )

		end
	}

	HTTP( request )
end

local function httpPost(url, params, onsuccess, onfailure, headers)
    httpRequest("post", url, params, onsuccess, onfailure, headers)
end

local function httpPut(url, params, onsuccess, onfailure, headers)
    httpRequest("put", url, params, onsuccess, onfailure, headers)
end

local function httpDelete(url, params, onsuccess, onfailure, headers)
    httpRequest("delete", url, params, onsuccess, onfailure, headers)
end

function mypublicid.Get(steamid64)
    return mypublicid.players.list[steamid64]
end

function mypublicid.Add(steamid64)
    mypublicid.Authorize(steamid64, function(err, json)
        if (!err) then
            mypublicid.players.list[steamid64] = json
            local ply = player.GetBySteamID64(steamid64)
            if (ply && mypublicid.Test(ply) == false) then
                ply:Kick(mypublicid.config.message)
            end
        end
    end)
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

// ==================================== \\
// Actual API functions
// ==================================== \\
function mypublicid.Authenticate(callback)
    local data = {}
    httpPost("https://"..mypublicid.config.endpoint.."/game/authenticate", data, function(responseText, contentLength, responseHeaders, statusCode)
        if (callback) then
            callback(nil, util.JSONToTable(responseText))
        end
    end, function(errorMessage)
        if (callback) then
            callback(errorMessage)
        else
            error(errorMessage)
        end
    end, {"x-api-key" = mypublicid.config.apikey})
end

function mypublicid.Authorize(token, callback)
    local data = {}
    data["token"] = token
    data["token_name"] = "steamid64"
    httpPost("https://"..mypublicid.config.endpoint.."/game/authorize", data, function(responseText, contentLength, responseHeaders, statusCode)
        if (callback) then
            callback(nil, util.JSONToTable(responseText))
        end
    end, function(errorMessage)
        if (callback) then
            callback(errorMessage)
        else
            error(errorMessage)
        end
    end, {"x-api-key" = mypublicid.config.apikey})
end

// Following requires special API permissions
// Will not be implemented by default, is only for the more advanced users
function mypublicid.Ban(token, callback)
    local data = {}
    data["token"] = token
    data["token_name"] = "steamid64"
    httpPut("https://"..mypublicid.config.endpoint.."/game/ban", data, function(responseText, contentLength, responseHeaders, statusCode)
        if (callback) then
            callback(nil, util.JSONToTable(responseText))
        end
    end, function(errorMessage)
        if (callback) then
            callback(errorMessage)
        else
            error(errorMessage)
        end
    end, {"x-api-key" = mypublicid.config.apikey})
end

function mypublicid.UnBan(token, callback)
    local data = {}
    data["token"] = token
    data["token_name"] = "steamid64"
    httpDelete("https://"..mypublicid.config.endpoint.."/game/ban", data, function(responseText, contentLength, responseHeaders, statusCode)
        if (callback) then
            callback(nil, util.JSONToTable(responseText))
        end
    end, function(errorMessage)
        if (callback) then
            callback(errorMessage)
        else
            error(errorMessage)
        end
    end, {"x-api-key" = mypublicid.config.apikey})
end
// Just to save someone accidentally missing the camal case
mypublicid.Unban = mypublicid.UnBan