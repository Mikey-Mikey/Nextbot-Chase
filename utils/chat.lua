function chatPrintFancy(msg)
    for _, ply in pairs(player.GetAll()) do
        ply:SendLua("chat.AddText(Color(255, 255, 255), \"[\", Color(30, 255, 0), \"Nextbot Chase\", Color(255, 255, 255), \"] " .. msg .. "\")")
    end
end