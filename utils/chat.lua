util.AddNetworkString("chase_fancy_print")

if CLIENT then
    
    net.Receive("chase_fancy_print", function()
    
        local msg = net.ReadString()
        chat.AddText(Color(30, 255, 0), "[Nextbot Chase] ", Color(255, 255, 0), msg)

    end)

else
    
end

function chatPrintFancy(msg)

    net.Start("chase_fancy_print")
    net.WriteString(msg)
    net.Broadcast()

end
