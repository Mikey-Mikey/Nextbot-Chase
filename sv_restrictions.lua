function GM:PlayerNoClip(ply, desiredState)
	return false
end

hook.Add( "PlayerCanHearPlayersVoice", "Maximum Range", function( listener, talker )
	if talker:GetObserverMode() == OBS_MODE_NONE and listener:GetObserverMode() != OBS_MODE_NONE then
		return true
	end
	if talker:GetObserverMode() != OBS_MODE_NONE and listener:GetObserverMode() != OBS_MODE_NONE then
		return true
	end
	if talker:GetObserverMode() == OBS_MODE_NONE and listener:GetObserverMode() == OBS_MODE_NONE then
		return true
	end
	if talker:GetObserverMode() != OBS_MODE_NONE and listener:GetObserverMode() == OBS_MODE_NONE then
		return false
	end
end )