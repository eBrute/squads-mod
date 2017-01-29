-- add squad colors, see alien_outline_lookup.dds

kHiveVisionOutlineColor = enum { [0]='Yellow', 'Green', 'KharaaOrange', 'Squad1', 'Squad2', 'Squad3', 'Squad4', 'Squad5', 'Squad6' }
kHiveVisionOutlineColorCount = #kHiveVisionOutlineColor+1

function HiveVision_GetSquadColor(squadNumber)
    return 1 + squadNumber -- squad1 is squadNumber 2
end
