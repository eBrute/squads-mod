kMaxSquadsMembersPerSquad = 6

kSquadType = enum {
	[0] = "Invalid",
	"Unassigned",
	"Red",
	"Green",
	"Blue",
	"Gold",
	"Purple",
	"Pink",
}

kSquadNames = {
	[0] = "Invalid",
	"Unassigned",
	"Red Squad",
	"Green Squad",
	"Blue Squad",
	"Gold Squad",
	"Purple Squad",
	"Pink Squad",
}

kSquadMenuBackgroundTextures = {
	[0] = nil, -- invalid
	"ui/squads/bg_largeempty.dds", -- unassigned
	"ui/squads/bg_cartman.dds", -- red
	"ui/squads/bg_gir.dds", -- green
	"ui/squads/bg_bender.dds", -- blue
	"ui/squads/bg_homer.dds", -- gold
	"ui/squads/bg_tentacle.dds", -- purple
	"ui/squads/bg_kitty.dds", -- pink
}


kSquadMenuBackgroundColors = {
	[0] = Color(0.25, 0.25, 0.25, 1), -- invalid
	Color(0.55, 0.55, 0.55, 1), -- unassigned
	Color(0.97, 0.14, 0.14, 1), -- red
	Color(0.12, 0.55, 0.12, 1), -- green
	Color(0.12, 0.18, 1.00, 1), -- blue
	Color(0.90, 0.84, 0.20, 1), -- gold
	Color(0.55, 0.12, 1.00, 1), -- purple
	Color(1.00, 0.12, 0.55, 1), -- pink
}

kSquadMenuPlayerColors = {
	[0] = Color(0.80, 0.80, 0.80, 1), -- invalid
	Color(0.80, 0.80, 0.80, 1), -- unassigned
	Color(0.80, 0.80, 0.80, 1), -- red
	Color(0.80, 0.80, 0.80, 1), -- green
	Color(0.80, 0.80, 0.80, 1), -- blue
	Color(0.80, 0.80, 0.80, 1), -- gold
	Color(0.80, 0.80, 0.80, 1), -- purple
	Color(0.80, 0.80, 0.80, 1), -- pink
}
