Scriptname CharGen Hidden

int Function GetScriptVersion() global
	return 4
EndFunction

; Saves a character's appearances to a preset file as well as a tint mask DDS
Function SaveCharacter(string characterName) native global

bool Function LoadCharacter(Actor akDestination, Race akRace, string characterName) global
	return LoadCharacterEx(akDestination, akRace, characterName, 0)
EndFunction

; Loads a character's appearance preset file onto an Actor
bool Function LoadCharacterEx(Actor akDestination, Race akRace, string characterName, int flags = 0) native global

; Deletes the slot,dds,nif
Function DeleteCharacter(string characterName) native global

; Deletes
; Data\\Meshes\\Actors\\Character\\FaceGenData\\FaceGeom\\%s\\%08X.nif
; Data\\Textures\\Actors\\Character\\FaceGenData\\FaceTint\\%s\\%08X.dds
int Function DeleteFaceGenData(ActorBase actorBase) native global

; Unmaps the presets to their corresponding NPC
bool Function ClearPreset(ActorBase npc) native global
Function ClearPresets() native global

; External Mode
; Saves the characters slot, nif, and dds
Function SaveExternalCharacter(string characterName) native global

bool Function LoadExternalCharacter(Actor akDestination, Race akRace, string characterName) global
	return LoadExternalCharacterEx(akDestination, akRace, characterName, 0)
EndFunction

; Same as LoadCharacter, except it does not internally map the preset, meant to be paired with S.E.C
bool Function LoadExternalCharacterEx(Actor akDestination, Race akRace, string characterName, int flags = 0) native global

; Determines whether loading external heads is enabled in the ini setting
bool Function IsExternalEnabled() native global

; Exports the player's head mesh and tint mask DDS relative to Data\SKSE\Plugins\CharGen\
; Data\SKSE\Plugins\CharGen\%fileName%.dds
; Data\SKSE\Plugins\CharGen\%fileName%.nif
Function ExportHead(string fileName) native global

; Exports only the player's slot file, can be used in conjunction 
; with LoadCharacter if being applied to the player as the player
; does not require a tintmask, it is always generated
; Saves preset to SKSE\Plugins\CharGen\Exported\%characterName%.jslot
Function ExportSlot(string fileName) native global

; Loads a preset onto the player
; Loads player preset from SKSE\Plugins\CharGen\Presets\%characterName%.jslot
bool Function LoadPreset(string characterName) global
	Actor player = Game.GetPlayer()
	bool ret = LoadCharacterPreset(player, characterName, Game.GetFormFromFile(0x801, "RaceMenu.esp") as ColorForm)
	If ret
		; Signals to RaceMenu that some internals were probably modified
		; and need to be stored into RaceMenu's script representation
		player.SendModEvent("RSM_RequestTintSave")
	Endif
	return ret
EndFunction

; Saves player preset to SKSE\Plugins\CharGen\Presets\%characterName%.jslot
Function SavePreset(string characterName) global
	SaveCharacterPreset(Game.GetPlayer(), characterName)
EndFunction

; Loads a preset onto the NPC, permanently (DO NOT USE ON NPCs)
; Hair Color form that is provided is modified
; Not recommended to call this function directly
; Loads actor preset from SKSE\Plugins\CharGen\Presets\%characterName%.jslot
bool Function LoadCharacterPreset(Actor akDestination, string characterName, ColorForm hairColor) global
	return LoadCharacterPresetEx(akDestination, characterName, hairColor, 0xFFFFFFFF)
EndFunction

bool Function LoadCharacterPresetEx(Actor akDestination, string characterName, ColorForm hairColor, int flags = 0xFFFFFFFF) native global

; Saves a preset from the NPC (Only works on player currently)
; Actor parameter is reserved for future use
; Saves actor preset to SKSE\Plugins\CharGen\Presets\%characterName%.jslot
Function SaveCharacterPreset(Actor akSource, string characterName) native global