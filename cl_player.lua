function GM:SetupMove(ply,mv,cmd)
    if input.WasMousePressed(MOUSE_LEFT) and #alive_people > 1 then
        net.Start("spectate_next")
        net.SendToServer()
    end
end