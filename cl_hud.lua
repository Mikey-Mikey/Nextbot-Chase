-- micro optimizations
local getAllPlayers = player.GetAll
local ipairs = ipairs
local Color = Color
local draw_RoundedBox = draw.RoundedBox
local surface_SetDrawColor = surface.SetDrawColor
local draw_DrawText = draw.DrawText
local floor = math.floor
local format = string.format
local ScrW = ScrW
local timeLeft = timer.TimeLeft
local inTable = table.HasValue
-- Hud Config
local FONT_SIZE = floor(math.min(ScrW(), ScrH()) / 60)
local TIMER_WIDTH = 0.08
local TIMER_HEIGHT = 0.07
local TIMER_RADIUS = 8
local TIMER_BACKGROUND_COLOR = Color(0, 0, 0, 200)
local TEXT_COLOR = color_white
GM.players = {}
-- create a font so we can have smaller text
surface.CreateFont( "SmallText", {
	font = "CloseCaption_Bold",
	extended = false,
	size = FONT_SIZE,
	antialias = true
})

surface.CreateFont( "BigText", {
	font = "CloseCaption_Bold",
	extended = false,
	size = floor(FONT_SIZE * 2),
	antialias = true
})

-- Internal values for the hud
local chase_time = 0
local ply_count = 0

-- create a timer on the client when the round starts
hook.Add("RoundStart", "hud", function(round, roundTime)
	timer.Create("chase_time", roundTime, 0, function()
		
	end)
end)
-- update alive player count, runs once a second so its a pretty low calculation
timer.Create("ALIVE_PLAYER_COUNT", 1, 0, function()
	ply_count = 0
	GAMEMODE.players = {}
	for _, v in ipairs(getAllPlayers()) do
		if v:IsValid() then
			if v:GetObserverMode() == OBS_MODE_NONE then
				if not inTable(GAMEMODE.players, v) then
					GAMEMODE.players[#GAMEMODE.players + 1] = v
				end
				ply_count = ply_count + 1
			end
		end
	end
end)
hook.Add("RoundEnd", "hud", function()
	if CLIENT then
		-- say in chat the players that won
		if #GAMEMODE.players > 0 then
			timer.Simple(0.01,function()
				if #GAMEMODE.players > 0 then
					for _, ply in ipairs(GAMEMODE.players) do
						if ply:IsValid() and ply:Alive() and ply:GetObserverMode() == OBS_MODE_NONE then
							chat.AddText(Color(255, 255, 255), "[", Color(30, 255, 0), "Nextbot Chase", Color(255, 255, 255), "] ", Color(236, 150, 19), ply:Nick(), Color(255, 255, 255), " won this round!")
						end
					end
				end
			end)
		else
			chat.AddText(Color(255, 255, 255), "[", Color(30, 255, 0), "Nextbot Chase", Color(255, 255, 255), "] ", Color(255, 255, 255), "Everybody lost this round!")
		end
	end
	GAMEMODE.players = getAllPlayers()
end)
-- Actually draw the hud
hook.Add("HUDPaint", "hud", function()
	draw_RoundedBox(TIMER_RADIUS, ScrW() / 2 - ScrW() * TIMER_WIDTH / 2, -TIMER_RADIUS, ScrW() * TIMER_WIDTH, ScrH() * TIMER_HEIGHT, TIMER_BACKGROUND_COLOR)

	-- calculate time left
	local timer = timeLeft("chase_time") or 0
	local minutes = floor(timer / 60)
	local seconds = floor(timer % 60)
	local formatted_seconds = format("%02d", seconds)		-- formats the string so it always has 2 digits, such as 09 instead of 9

	draw_DrawText(minutes .. ":" .. formatted_seconds, "BigText", ScrW() / 2, 3, TEXT_COLOR, TEXT_ALIGN_CENTER)
	draw_DrawText("Players Left: " .. ply_count, "SmallText", ScrW() / 2, FONT_SIZE + 17, TEXT_COLOR, TEXT_ALIGN_CENTER)
end)