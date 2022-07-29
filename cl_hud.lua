
-- Constants --
FONT_SIZE = 13
TIMER_WIDTH = 150
TIMER_HEIGHT = 50
TIMER_RADIUS = 5
TIMER_BACKGROUND_COLOR = Color(0, 0, 0, 200)
TEXT_COLOR = color_white

surface.CreateFont( "SmallText", {
	font = "CloseCaption_Bold",
	extended = false,
	size = FONT_SIZE,
	antialias = true
})

// Custom HUD

local chase_time = 0
local ply_count = 0

// update chase time
// TODO: make this a clientside countdown instead of networking the time to clients every second
net.Receive("chase_time", function()
	chase_time = net.ReadInt(16)
end)

// update alive player count, runs once a second so its a pretty low calculation
timer.Create("ALIVE_PLAYER_COUNT", 1, 0, function()
	ply_count = 0
	for _, v in ipairs(player.GetAll()) do
		if v:Alive() then
			ply_count = ply_count + 1
		end
	end
end)

// optimizations
local draw_RoundedBox = draw.RoundedBox
local surface_SetDrawColor = surface.SetDrawColor
local draw_DrawText = draw.DrawText

hook.Add("HUDPaint", "mikey_customhud", function()
	draw_RoundedBox(TIMER_RADIUS, ScrW() / 2 - TIMER_WIDTH / 2, -TIMER_RADIUS, TIMER_WIDTH, TIMER_HEIGHT, TIMER_BACKGROUND_COLOR)

	// calculate time left
	local minutes = math.floor(chase_time / 60)
	local seconds = math.floor(chase_time % 60)
	local formatted_seconds = string.format("%02d", seconds)		// formats the string so it always has 2 digits, such as 09 instead of 9

	draw_DrawText(minutes .. ":" .. formatted_seconds, "CloseCaption_Bold", ScrW() / 2, 3, TEXT_COLOR, TEXT_ALIGN_CENTER)
	draw_DrawText("Players Left: " .. ply_count, "SmallText", ScrW() / 2, ScrH() * 0.025, TEXT_COLOR, TEXT_ALIGN_CENTER)
end)