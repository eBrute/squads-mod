kSquadTeams = {
	[kTeam1Index] = true,
	[kTeam2Index] = true
}

kMaxSquadsMembersPerSquad = 6

-- NOTE adding new squads requires changes in HiveVision.lua and EquipmentOutline.lua (+ associated texture files)
kSquadType = enum {
	[0] = "Invalid",
	"Unassigned",
	"Squad1",
	"Squad2",
	"Squad3",
	"Squad4",
	"Squad5",
	"Squad6",
}

kSquadPlayerDefault = kSquadType.Unassigned
kSquadBotDefault = kSquadType.Squad2

kSquadNames = {
	[0] = "Invalid",
	"Unassigned",
	"Red Squad",
	"Green Squad",
	"Blue Squad",
	"Yellow Squad",
	"Purple Squad",
	"Pink Squad",
}

kSquadMenuBackgroundTextures = { -- active, inactive, full
	[0] = nil, -- invalid
	{"ui/squads/bg_large.dds",     "ui/squads/bg_large_black.dds"}, -- unassigned
	{"ui/squads/bg_zoidberg.dds",  "ui/squads/bg_black.dds", "ui/squads/bg_full.dds"}, -- red
	{"ui/squads/bg_gir2.dds",      "ui/squads/bg_black.dds", "ui/squads/bg_full.dds"}, -- green
	{"ui/squads/bg_sonic.dds",     "ui/squads/bg_black.dds", "ui/squads/bg_full.dds"}, -- blue
	{"ui/squads/bg_spongebob.dds", "ui/squads/bg_black.dds", "ui/squads/bg_full.dds"}, -- yellow
	{"ui/squads/bg_tentacle.dds",  "ui/squads/bg_black.dds", "ui/squads/bg_full.dds"}, -- purple
	{"ui/squads/bg_pinky.dds",     "ui/squads/bg_black.dds", "ui/squads/bg_full.dds"}, -- pink
}

-- kSquadMenuSounds = {
-- 	[0] = nil, -- invalid
-- 	"sound/squads.fev/squads/homer", -- unassigned
-- 	"sound/squads.fev/squads/zoidberg", -- red
-- 	"sound/squads.fev/squads/gir", -- green
-- 	"sound/squads.fev/squads/sonic", -- blue
-- 	"sound/squads.fev/squads/spongebob", -- yellow
-- 	"sound/squads.fev/squads/tentacle", -- purple
-- 	"sound/squads.fev/squads/pinkiepie", -- pink
-- }


kSquadColors = { -- used for menu squad title and scoreboard
	[0] = nil, -- invalid (unused)
	Color(0.55, 0.55, 0.55, 1), -- unassigned
	Color(0.95, 0.34, 0.37, 1), -- red
	Color(0.58, 0.75, 0.25, 1), -- green
	Color(0.22, 0.40, 0.69, 1), -- blue
	Color(0.99, 0.84, 0.05, 1), -- yellow
	Color(0.39, 0.29, 0.62, 1), -- purple
	Color(0.96, 0.59, 0.74, 1), -- pink
}

kSquadMenuPlayerColors = {
	[0] = Color(0.80, 0.80, 0.80, 1), -- for unhovered state
	Color(0.137255, 0.149020, 0.160784, 1), -- unassigned
	Color(0.137255, 0.149020, 0.160784, 1), -- red
	Color(0.137255, 0.149020, 0.160784, 1), -- green
	Color(0.137255, 0.149020, 0.160784, 1), -- blue
	Color(0.137255, 0.149020, 0.160784, 1), -- yellow
	Color(0.137255, 0.149020, 0.160784, 1), -- purple
	Color(0.137255, 0.149020, 0.160784, 1), -- pink
}

kSquadMinimapBlipColors = { -- used for players on the minimap
	[0] = Color(0.25, 0.25, 0.25, 1), -- invalid (unused)
	Color(0.55, 0.55, 0.55, 1), -- unassigned
	Color(0.95, 0.34, 0.37, 1), -- red
	Color(0.58, 0.75, 0.25, 1), -- green
	Color(0.22, 0.40, 0.69, 1), -- blue
	Color(0.99, 0.84, 0.05, 1), -- yellow
	Color(0.39, 0.29, 0.62, 1), -- purple
	Color(0.96, 0.59, 0.74, 1), -- pink
}
