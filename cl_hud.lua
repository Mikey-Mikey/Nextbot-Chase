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

-- Hud Config
local FONT_SIZE = 13
local TIMER_WIDTH = 150
local TIMER_HEIGHT = 50
local TIMER_RADIUS = 5
local TIMER_BACKGROUND_COLOR = Color(0, 0, 0, 200)
local TEXT_COLOR = color_white

-- create a font so we can have smaller text
surface.CreateFont( "SmallText", {
	font = "CloseCaption_Bold",
	extended = false,
	size = FONT_SIZE,
	antialias = true
})

-- Internal values for the hud
local chase_time = 0
local ply_count = 0

-- create a timer on the client when the round starts
hook.Add("RoundStart", "hud", function(round, roundTime)
	timer.Create("chase_time", roundTime, 0)
end)

-- update alive player count, runs once a second so its a pretty low calculation
timer.Create("ALIVE_PLAYER_COUNT", 1, 0, function()
	ply_count = 0
	for _, v in ipairs(getAllPlayers()) do
		if v:GetObserverMode() == OBS_MODE_NONE then
			ply_count = ply_count + 1
		end
	end
end)

-- Actually draw the hud
hook.Add("HUDPaint", "hud", function()
	draw_RoundedBox(TIMER_RADIUS, ScrW() / 2 - TIMER_WIDTH / 2, -TIMER_RADIUS, TIMER_WIDTH, TIMER_HEIGHT, TIMER_BACKGROUND_COLOR)

	-- calculate time left
	local timer = timeLeft("chase_time") or 0
	local minutes = floor(timer / 60)
	local seconds = floor(timer % 60)
	local formatted_seconds = format("%02d", seconds)		-- formats the string so it always has 2 digits, such as 09 instead of 9

	draw_DrawText(minutes .. ":" .. formatted_seconds, "CloseCaption_Bold", ScrW() / 2, 3, TEXT_COLOR, TEXT_ALIGN_CENTER)
	draw_DrawText("Players Left: " .. ply_count, "SmallText", ScrW() / 2, ScrH() * 0.025, TEXT_COLOR, TEXT_ALIGN_CENTER)
end)