// RAWR!

hook.Add("CheckPassword", "MyPublicId_CheckPassword", function(steamid64, ipAdd, svPassword, clPassword, name)
    if (mypublicid.TestID(steamid64) == false) then
        return false, mypublicid.config.message
    end
    
    // We won't return true ever, let other hooks have a try.
    // We only poll our system here.
end)

hook.Add("PlayerAuthed", "MyPublicId_PlayerAuthed", function(ply)
    if (mypublicid.Test(ply) == false) then
        ply:Kick(mypublicid.config.message)
    end
end)