-- add squad colors, see marine_outline_lookup.dds

kEquipmentOutlineColor = enum { [0]='TSFBlue', 'Green', 'Fuchsia', 'Yellow', 'Red', 'Squad1', 'Squad2', 'Squad3', 'Squad4', 'Squad5', 'Squad6' }
kEquipmentOutlineColorCount = #kEquipmentOutlineColor+1

function EquipmentOutline_GetSquadColor(squadNumber)
    return 3 + squadNumber -- NOTE squad1 is squadNumber 2
end
