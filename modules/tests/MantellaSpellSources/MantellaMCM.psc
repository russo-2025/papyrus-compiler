Scriptname MantellaMCM extends SKI_ConfigBase 

;don't forget to set this in the CK!
MantellaRepository property repository auto

int property oid_microphoneEnabledToggle auto
int property oid_useHotkeyToStartMic auto
int property oid_responsetimeslider auto
int property oid_showReminderMessages auto

int property oid_keymapStartAddHotkey auto
int property oid_keymapPromptHotkey auto
int property oid_keymapEndHotkey auto
int property oid_keymapCustomGameEventHotkey auto
int property oid_keymapRadiantHotkey auto

int property oid_showDialogueItems auto

int property oid_radiantenabled auto
int property oid_radiantdistance auto
int property oid_radiantfrequency auto
int property oid_showRadiantDialogueMessages auto


int property oid_playerCharacterDescription1 auto
int property oid_playerCharacterDescription2 auto
int property oid_playerCharacterUsePlayerDescription2 auto
int property oid_playerCharacterVoicePlayerInput auto
int property oid_playerCharacterVoiceModel auto

int property oid_worldID auto


int property oid_playerTrackingUsePCName auto
int property oid_playerTrackingOnItemAdded auto
int property oid_playerTrackingOnItemRemoved auto
int property oid_playerTrackingOnSpellCast auto
int property oid_playerTrackingOnHit auto
int property oid_playerTrackingOnObjectEquipped auto
int property oid_playerTrackingOnObjectUnequipped auto
int property oid_playerTrackingOnPlayerBowShot auto
int property oid_playerTrackingOnSit auto
int property oid_playerTrackingOnGetUp auto
int property oid_playerTrackingAll auto
bool property playerAllToggle auto

int property oid_playerTrackingOnLocationChange auto
int property oid_playerTrackingOnTimeChange auto
int property oid_playerTrackingOnWeatherChange auto


int property oid_playerEquipmentBody auto
int property oid_playerEquipmentHead auto
int property oid_playerEquipmentHands auto
int property oid_playerEquipmentFeet auto
int property oid_playerEquipmentAmulet auto
int property oid_playerEquipmentRightHand auto
int property oid_playerEquipmentLeftHand auto
int property oid_playerEquipmentAll auto
bool property playerEquipmentAllToggle auto


int property oid_targetTrackingItemAddedToggle auto
int property oid_targetTrackingItemRemovedToggle auto
int property oid_targetTrackingOnSpellCastToggle auto
int property oid_targetTrackingOnHitToggle auto
int property oid_targetTrackingOnCombatStateChangedToggle auto
int property oid_targetTrackingOnObjectEquippedToggle auto
int property oid_targetTrackingOnObjectUnequippedToggle auto
int property oid_targetTrackingOnSitToggle auto
int property oid_targetTrackingOnGetUpToggle auto
int property oid_targetTrackingOnDyingToggle auto
int property oid_targetTrackingAngerStateToggle auto
int property oid_targetTrackingAll auto
bool property targetAllToggle auto

int property oid_targetEquipmentBody auto
int property oid_targetEquipmentHead auto
int property oid_targetEquipmentHands auto
int property oid_targetEquipmentFeet auto
int property oid_targetEquipmentAmulet auto
int property oid_targetEquipmentRightHand auto
int property oid_targetEquipmentLeftHand auto
int property oid_targetEquipmentAll auto
bool property targetEquipmentAllToggle auto


int property oid_AllowForNPCtoFollowToggle auto ;gia
int property oid_NPCAngerToggle auto ;gia
int property oid_NPCInventoryToggle auto
int property oid_NPCPackageToggle auto
int property oid_enableVanillaDialogueAwareness auto

int property oid_debugNPCSelectMode auto
int property oid_restartMantellaExe Auto
int property oid_httpPort auto

string property PAGE_GENERAL = "General" auto
string property PAGE_PLAYER = "Player" auto
string property PAGE_PLAYERTRACKING = "Player Tracking" auto
string property PAGE_TARGETTRACKING = "Target Tracking" auto
string property PAGE_EQUIPMENT = "Equipment" auto
string property PAGE_ADVANCED = "Advanced" auto



ReferenceAlias property PlayerAlias auto

string MantellaMCMcurrentPage


; Whenever a new repository value OR a new MCM setting is added, up the MCM version number returned by `ManatellaMCM.GetVersion()`
; and add the corresponding default value in 'MCMRepository.assignDefaultSettings' in a block corresponding to the version number like the examples
int Function GetVersion()
    Return 7
EndFunction

event OnVersionUpdate(int a_version)
    repository.assignDefaultSettings(CurrentVersion)
    self.OnConfigInit()
EndEvent

Event OnConfigInit()
	;this part right here name all the pages we'll need (we can add more pages at the end as long as we update the numbers) and declares some variables
    ModName = "Mantella"
	Pages = new string[6]
    Pages[0] = PAGE_GENERAL
    Pages[1] = PAGE_PLAYER
	Pages[2] = PAGE_PLAYERTRACKING
	Pages[3] = PAGE_TARGETTRACKING
    Pages[4] = PAGE_EQUIPMENT
 	Pages[5] = PAGE_ADVANCED
 
    playerAllToggle=true
    playerEquipmentAllToggle=true
	targetAllToggle=true
    targetEquipmentAllToggle = true
EndEvent

Event OnPageReset(string page)
    ;this is the event that triggers when the pages get clicked, so I link to the other MCM scripts that are basically just used for global functions
	if page==""
		loadcustomcontent("Mantella/splash.dds")
		MantellaMCMcurrentPage="Intro"
	else 
		unloadcustomcontent()
	endif
	if page==PAGE_GENERAL
		MantellaMCM_GeneralSettings.Render(self, repository)
		MantellaMCMcurrentPage=PAGE_GENERAL
    elseif page==PAGE_PLAYER
		MantellaMCM_PlayerSettings.Render(self, repository)
		MantellaMCMcurrentPage=PAGE_PLAYER
	elseif page==PAGE_PLAYERTRACKING
		MantellaMCM_PlayerTrackingSettings.Render(self, repository)
		MantellaMCMcurrentPage=PAGE_PLAYERTRACKING
	elseif page==PAGE_TARGETTRACKING
		MantellaMCM_TargetTrackingSettings.Render(self, repository)
		MantellaMCMcurrentPage=PAGE_TARGETTRACKING
    elseif page==PAGE_EQUIPMENT
		MantellaMCM_EquipmentSettings.Render(self, repository)
		MantellaMCMcurrentPage=PAGE_EQUIPMENT
	elseif page==PAGE_ADVANCED
		MantellaMCM_AdvancedSettings.Render(self, repository)
		MantellaMCMcurrentPage=PAGE_ADVANCED
 	endif		
EndEvent

;This part of the MCM below is a bunch of event listeners, they all use functions to link to the appropriate MCM scripts 
Event OnOptionSelect(int optionID)
	if MantellaMCMcurrentPage ==PAGE_GENERAL
		MantellaMCM_GeneralSettings.OptionUpdate(self,optionID, repository)	
    elseif MantellaMCMcurrentPage ==PAGE_PLAYER
		MantellaMCM_PlayerSettings.OptionUpdate(self,optionID, repository)
	elseif MantellaMCMcurrentPage ==PAGE_PLAYERTRACKING
		MantellaMCM_PlayerTrackingSettings.OptionUpdate(self,optionID, repository)	
	elseif MantellaMCMcurrentPage ==PAGE_TARGETTRACKING
		MantellaMCM_TargetTrackingSettings.OptionUpdate(self,optionID, repository)
    elseif MantellaMCMcurrentPage ==PAGE_EQUIPMENT
		MantellaMCM_EquipmentSettings.OptionUpdate(self,optionID, repository)	
	elseif MantellaMCMcurrentPage ==PAGE_ADVANCED
		MantellaMCM_AdvancedSettings.OptionUpdate(self,optionID, repository)
	endif
EndEvent 

Event OnOptionSliderOpen(Int optionId)
    If MantellaMCMcurrentPage == PAGE_GENERAL
		MantellaMCM_GeneralSettings.SliderOptionOpen(self,optionID, repository)
    elseif MantellaMCMcurrentPage == PAGE_PLAYER
        MantellaMCM_PlayerSettings.SliderOptionOpen(self,optionID, repository)
    elseif MantellaMCMcurrentPage == PAGE_ADVANCED
        MantellaMCM_AdvancedSettings.SliderOptionOpen(self,optionID, repository)
    endIf
EndEvent

Event OnOptionSliderAccept(Int optionId, Float value)
	If MantellaMCMcurrentPage == PAGE_GENERAL
		MantellaMCM_GeneralSettings.SliderOptionAccept(self,optionID, value, repository)
    elseif MantellaMCMcurrentPage == PAGE_PLAYER
        MantellaMCM_PlayerSettings.SliderOptionAccept(self,optionID, value, repository)
    elseif MantellaMCMcurrentPage == PAGE_ADVANCED
        MantellaMCM_AdvancedSettings.SliderOptionAccept(self,optionID, value, repository)
    endIf
EndEvent

Event OnOptionKeyMapChange(Int a_option, Int a_keyCode, String a_conflictControl, String a_conflictName)
    {Called when a key has been remapped}
    If 	MantellaMCMcurrentPage ==PAGE_GENERAL
		MantellaMCM_GeneralSettings.KeyMapChange(self,a_option, a_keyCode, a_conflictControl, a_conflictName, repository)
	EndIf
EndEvent

event OnOptionInputAccept(int optionID, string inputText)
	if MantellaMCMcurrentPage ==PAGE_ADVANCED
		MantellaMCM_AdvancedSettings.OptionInputUpdate(self, optionID, inputText, repository)
    ; elseif MantellaMCMcurrentPage == PAGE_PLAYER
    ;     MantellaMCM_PlayerSettings.OptionInputUpdate(self, optionID, inputText, repository)
	endif
EndEvent

Event OnOptionHighlight (Int optionID)
	if optionID == oid_microphoneEnabledToggle	
		SetInfoText("Toggles microphone / text input.")
	elseIf optionID == oid_useHotkeyToStartMic
		SetInfoText("If this is unchecked recording from the mic will start automatically when it is the player's turn to speak. If this is checked recording will only start once the 'Open Text Prompt' hotkey is pressed.")
    elseIf optionID == oid_responsetimeslider
		SetInfoText("Time (in seconds) to enter a text response or start the microphone recording using the 'Open Text Prompt' hotkey if the options above are set accordingly. \nDefault: 180")
	elseIf optionID == oid_showReminderMessages
		SetInfoText("Periodically reminds the player it is their turn to speak / input text.")
    
    elseIf optionID == oid_keymapStartAddHotkey
		SetInfoText("Either starts a conversation or adds an NPC to a conversation.")
	elseIf optionID == oid_keymapPromptHotkey
		SetInfoText("Opens the text prompt or starts the mic recording depending on the context and the microphone options above. \nDefault: H")
	elseIf optionID == oid_keymapEndHotkey
		SetInfoText("Ends all Mantella conversations.")
	elseIf optionID == oid_keymapCustomGameEventHotkey	
		SetInfoText("Opens a text prompt to enter a custom game event (eg 'The house is on fire').")
	elseIf optionID == oid_keymapRadiantHotkey	
		SetInfoText("Toggle radiant conversations.")

    elseIf optionID == oid_showDialogueItems	
		SetInfoText("Show the dialogue tree entries to start a conversation or add and remove NPCs from it.")

	elseIf optionID == oid_radiantenabled
		SetInfoText("Starts a Mantella conversation between the nearest two NPCs to the player at a given frequency. \nNPCs must both be stationary when a radiant dialogue attempt is made.")
	elseIf optionID == oid_radiantdistance
		SetInfoText("How far from the player (in meters) radiant dialogues can begin. \nDefault: 20")
	elseIf optionID == oid_radiantfrequency
		SetInfoText("How frequently (in seconds) radiant dialogues should attempt to begin. \nDefault: 10")
    elseIf optionID == oid_showRadiantDialogueMessages
		SetInfoText("Enable radiant dialogue debuggging messages.")

    elseIf optionID == oid_playerCharacterDescription1	
		SetInfoText("The description of the player used in the prompt for the LLM. This is not a bio of the player. \nTry to only put things here that are obvious about your character when the NPC meets them. e.g.'A tall and broad Nord man with long red hair''")
    elseIf optionID == oid_playerCharacterDescription2	
		SetInfoText("Alternative description of the player. Used in the same way as the first description. Can potentially be used if a player can change their appearance.")
    elseIf optionID == oid_playerCharacterUsePlayerDescription2
		SetInfoText("If checked the alternative player description will be used, otherwise the default one is selected.")
    elseIf optionID == oid_playerCharacterVoicePlayerInput
		SetInfoText("If checked the input of the player will be spoken aloud.")
	elseIf optionID == oid_playerCharacterDescription1	
		SetInfoText("The TTS voice model to use when the player speaks.")
    elseIf optionID == oid_playerTrackingUsePCName	
		SetInfoText("Use the name of the player character when tracking events. Uses 'Player' otherwise.")
    elseIf optionID == oid_worldID	
		SetInfoText("Used to uniquely identify a world/save game/player-through. The unique world id is the name of the player character followed by this number.\nIf you are using the same player character name for different playthroughs you can change this number to differentiate them.")

    elseIf optionID == oid_playerTrackingOnItemAdded	
		SetInfoText("Tracks items picked up / acquired while a Mantella conversation is active.")
	elseIf optionID == oid_playerTrackingOnItemRemoved	
		SetInfoText("Tracks items dropped / removed while a Mantella conversation is active.")
	elseIf optionID == oid_playerTrackingOnSpellCast	
		SetInfoText("Tracks spells / shouts / effects casted while a Mantella conversation is active.")
	elseIf optionID == oid_playerTrackingOnHit	
		SetInfoText("Tracks damage taken (and the source of the damage) while a Mantella conversation is active.")
	elseIf optionID == oid_playerTrackingOnObjectEquipped	
		SetInfoText("Tracks items / spells / shouts equipped while a Mantella conversation is active.")
	elseIf optionID == oid_playerTrackingOnObjectEquipped	
		SetInfoText("Tracks items / spells / shouts unequipped while a Mantella conversation is active.")
	elseIf optionID == oid_playerTrackingOnPlayerBowShot	
		SetInfoText("Tracks if player shoots an arrow while a Mantella conversation is active.")
	elseIf optionID == oid_playerTrackingOnSit
		SetInfoText("Tracks furniture rested on while a Mantella conversation is active.")
	elseIf optionID == oid_playerTrackingOnGetUp
		SetInfoText("Tracks furniture stood up from while a Mantella conversation is active.")
	elseIf optionID == oid_playerTrackingAll	
		SetInfoText("Enable / disable all tracking options for the player.")

    elseIf optionID == oid_playerTrackingOnLocationChange	
		SetInfoText("Tracks location changes while a Mantella conversation is active.")
    elseIf optionID == oid_playerTrackingOnTimeChange	
		SetInfoText("Tracks time changes while a Mantella conversation is active.")
    elseIf optionID == oid_playerTrackingOnWeatherChange	
		SetInfoText("Tracks weather changes while a Mantella conversation is active.")

    elseIf optionID == oid_playerEquipmentBody	
		SetInfoText("Describe item in the body slot (32) of the player to the LLM.")
	elseIf optionID == oid_playerEquipmentHead	
		SetInfoText("Describe item in the helmet/hair slot (31) of the player to the LLM.")
	elseIf optionID == oid_playerEquipmentHands	
		SetInfoText("Describe item in the hands slot (33) of the player to the LLM.")
	elseIf optionID == oid_playerEquipmentFeet	
		SetInfoText("Describe item in the feet slot (37) of the player to the LLM.")
	elseIf optionID == oid_playerEquipmentAmulet
		SetInfoText("Describe item in the amulet slot (35) of the player to the LLM.")
	elseIf optionID == oid_playerEquipmentRightHand
		SetInfoText("Describe item in the right hand of the player to the LLM.")
	elseIf optionID == oid_playerEquipmentLeftHand
		SetInfoText("Describe item in the left hand of the player to the LLM.")
	elseIf optionID == oid_playerEquipmentAll
		SetInfoText("Enable / disable all description options for the player.")

	
	elseIf optionID == oid_targetTrackingItemAddedToggle	
		SetInfoText("Tracks items picked up / acquired while a Mantella conversation is active.")
	elseIf optionID == oid_targetTrackingItemRemovedToggle	
		SetInfoText("Tracks items dropped / removed while a Mantella conversation is active.")
	elseIf optionID == oid_targetTrackingOnSpellCastToggle	
		SetInfoText("Tracks spells / shouts / effects casted while a Mantella conversation is active.")
	elseIf optionID == oid_targetTrackingOnHitToggle	
		SetInfoText("Tracks damage taken (and the source of the damage) while a Mantella conversation is active.")
	elseIf optionID == oid_targetTrackingOnCombatStateChangedToggle	
		SetInfoText("Tracks combat state changes while a Mantella conversation is active.")
	elseIf optionID == oid_targetTrackingOnObjectEquippedToggle	
		SetInfoText("Tracks items / spells / shouts equipped while a Mantella conversation is active.")
	elseIf optionID == oid_targetTrackingOnObjectUnequippedToggle	
		SetInfoText("Tracks items / spells / shouts unequipped while a Mantella conversation is active.")
	elseIf optionID == oid_targetTrackingOnSitToggle	
		SetInfoText("Tracks furniture rested on while a Mantella conversation is active.")
	elseIf optionID == oid_targetTrackingOnGetUpToggle	
		SetInfoText("Tracks furniture stood up from while a Mantella conversation is active.")
	elseIf optionID == oid_targetTrackingOnGetUpToggle	
		SetInfoText("Enable / disable all tracking options for the target.")
	elseIf optionID == oid_targetTrackingAngerStateToggle	
		SetInfoText("Tracks anger state of target (used to apply anger emotions to xVASynth output). Causes minor response delays.")

    elseIf optionID == oid_targetEquipmentBody	
		SetInfoText("Describe item in the body slot (32) of the target to the LLM.")
	elseIf optionID == oid_targetEquipmentHead	
		SetInfoText("Describe item in the helmet/hair slot (31) of the target to the LLM.")
	elseIf optionID == oid_targetEquipmentHands	
		SetInfoText("Describe item in the hands slot (33) of the target to the LLM.")
	elseIf optionID == oid_targetEquipmentFeet	
		SetInfoText("Describe item in the feet slot (37) of the target to the LLM.")
	elseIf optionID == oid_targetEquipmentAmulet
		SetInfoText("Describe item in the amulet slot (35) of the target to the LLM.")
	elseIf optionID == oid_targetEquipmentRightHand
		SetInfoText("Describe item in the right hand of the target to the LLM.")
	elseIf optionID == oid_targetEquipmentLeftHand
		SetInfoText("Describe item in the left hand of the target to the LLM.")
	elseIf optionID == oid_targetEquipmentAll
		SetInfoText("Enable / disable all description options for the target.")


	elseIf optionID == oid_AllowForNPCtoFollowToggle ;gia
		SetInfoText("NPCs can be convinced to follow (not tested over long playthroughs).")
	elseIf optionID == oid_NPCAngerToggle ;gia
		SetInfoText("NPCs can attack the player if provoked.")
	elseIf optionID == oid_NPCInventoryToggle
		SetInfoText("NPCs can open their inventory to share items.")
	elseIf optionID == oid_NPCPackageToggle
		SetInfoText("NPCs will stop to talk to you and will not engage in non-Mantella conversations.")
	elseIf optionID == oid_enableVanillaDialogueAwareness
		SetInfoText("NPCs will know about any dialogue spoken in the vanilla dialogue system.")

	elseIf optionID == oid_debugNPCSelectMode
		SetInfoText("Allows the player to speak to any NPC by initiating a conversation then entering the actor RefID and actor name that the player wishes to speak to")
	elseif optionID == oid_httpPort
		SetInfoText("HTTP port for Mantella to call. If you need to change the default port, change it here and the port for MantellaSoftware's server in its config.ini. Default: 4999")
	EndIf
endEvent

bool Function IsNotProperlyInitialised()
    if(!PlayerAlias);Checks if the PlayerAlias is not asssigned. Should only happen when updating from an old version of Mantella where the Quest is still running        
        return true
    Else
        return false
    endif
EndFunction

