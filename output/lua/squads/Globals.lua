kSquadTeams = {
	[kTeam1Index] = true,
	[kTeam2Index] = true
}

kMaxSquadsMembersPerSquad = 6

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

kSquadMenuBackgroundTextures = {
	[0] = nil, -- invalid
	{"ui/squads/bg_large.dds",     "ui/squads/bg_large_black.dds"}, -- unassigned
	{"ui/squads/bg_zoidberg.dds",  "ui/squads/bg_black.dds"}, -- red
	{"ui/squads/bg_gir2.dds",      "ui/squads/bg_black.dds"}, -- green
	{"ui/squads/bg_sonic.dds",     "ui/squads/bg_black.dds"}, -- blue
	{"ui/squads/bg_spongebob.dds", "ui/squads/bg_black.dds"}, -- yellow
	{"ui/squads/bg_tentacle.dds",  "ui/squads/bg_black.dds"}, -- purple
	{"ui/squads/bg_pinky.dds",     "ui/squads/bg_black.dds"}, -- pink
}


kSquadColors = { -- used for menu squad title and scoreboard
	[0] = Color(0.25, 0.25, 0.25, 1), -- invalid
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
