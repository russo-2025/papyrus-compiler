ScriptName LibTurtleClub Hidden

{ Actor }

; Returns whether `akActor` is a member of each faction in `akFactions` (does not evaluate faction rank)
Bool[] Function GetFactionStates(Actor akActor, FormList akFactions) Global Native

; Returns armor items equipped in each slot and each weapon equipped in either hand when `abLeftWeapon` or
; `abRightWeapon` are True (Note: Return values are in array order and can be None)
Form[] Function GetWornEquipment(Actor akActor, Bool abWeaponL, Bool abWeaponR) Global Native

{ Misc }

; Returns whether disguise can activate based on map of mutually exclusive faction indices
Bool Function CanDisguiseActivate(Int aiFactionIndex, Bool[] akFactionStates) Global Native

; Returns index to `akPlayerRace` in `argRaces` after checking if `akPlayerRace` is mapped to `aiFactionIndex`
Int Function LookupRaceWeightIndex(Int aiFactionIndex, Race akPlayerRace, Race[] argRaces) Global Native
