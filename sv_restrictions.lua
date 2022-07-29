function GM:PlayerNoClip(ply, desiredState)
	return false
end

hook.Add( "OnEntityCreated", "PropScream", function( ent )
	if ent:IsValid() and not table.HasValue(ents.FindByClass("npc_*"), ent) then
		timer.Simple(0,function()
			ent:Remove()
		end)
	end
end )

hook.Add( "PlayerCanHearPlayersVoice", "Maximum Range", function( listener, talker )
	if talker:GetObserverMode() != OBS_MODE_NONE and listener:GetObserverMode() != OBS_MODE_NONE then
		return true
	end
	if talker:GetObserverMode() == OBS_MODE_NONE and listener:GetObserverMode() == OBS_MODE_NONE then
		return true
	end
	if talker:GetObserverMode() != OBS_MODE_NONE and listener:GetObserverMode() == OBS_MODE_NONE then
		return false
	end
	if talker:GetObserverMode() == OBS_MODE_NONE and listener:GetObserverMode() != OBS_MODE_NONE then
		return false
	end
end )