function chatPrintFancy(msg)
    for _, ply in pairs(player.GetAll()) do
        ply:SendLua("chat.AddText(Color(255, 255, 255), \"[\", Color(30, 255, 0), \"Nextbot Chase\", Color(255, 255, 255), \"] " .. msg .. "\")")
    end
end

hook.Add("PlayerSay","chat",function(ply,text,team)
    if string.find(text,"nigger") or string.find(text,"nigga") then
        RunConsoleCommand("ulx ban " .. ply:GetName() .. " " .. 1440 .. "Being Racist, LAUGH AT THIS USER")
        return false
    end
end)