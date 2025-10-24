Scriptname MantellaMCM_GeneralSettings  Hidden

function Render(MantellaMCM mcm, MantellaRepository Repository) global
    mcm.SetCursorFillMode(mcm.TOP_TO_BOTTOM)
    LeftColumn(mcm, Repository)
    mcm.SetCursorPosition(1)
    RightColumn(mcm, Repository)
endfunction

function LeftColumn(MantellaMCM mcm, MantellaRepository Repository) global
    mcm.AddHeaderOption("Microphone")
    mcm.oid_microphoneEnabledToggle = mcm.AddToggleOption("Enabled", repository.microphoneEnabled)
    mcm.oid_useHotkeyToStartMic = mcm.AddToggleOption("Use Hotkey to Start Mic", repository.useHotkeyToStartMic)
    mcm.oid_responsetimeslider = mcm.AddSliderOption("Text Response Wait Time", repository.MantellaEffectResponseTimer)
    mcm.oid_showReminderMessages = mcm.AddToggleOption("Show Input Reminder Messages", repository.showReminderMessages)

    mcm.AddHeaderOption("Controls")
    mcm.oid_keymapStartAddHotkey = mcm.AddKeyMapOption("Start Conversation / Add NPC", repository.MantellaStartHotkey)
    mcm.oid_keymapPromptHotkey = mcm.AddKeyMapOption("Open Text Prompt", repository.MantellaListenerTextHotkey)
    mcm.oid_keymapEndHotkey = mcm.AddKeyMapOption("End Conversation / Remove NPC", repository.MantellaEndHotkey)
    mcm.oid_keymapCustomGameEventHotkey = mcm.AddKeyMapOption("Add Custom Game Event", repository.MantellaCustomGameEventHotkey)
    mcm.oid_keymapRadiantHotkey = mcm.AddKeyMapOption("Toggle Radiant Dialogue", repository.MantellaRadiantHotkey) 
endfunction

function RightColumn(MantellaMCM mcm, MantellaRepository Repository) global
    mcm.AddHeaderOption("Radiant Dialogue")
    mcm.oid_radiantenabled = mcm.AddToggleOption("Enabled", repository.radiantEnabled)
    mcm.oid_radiantdistance = mcm.AddSliderOption("Trigger Distance",repository.radiantDistance)
    mcm.oid_radiantfrequency = mcm.AddSliderOption("Trigger Frequency",repository.radiantFrequency)
    mcm.oid_showRadiantDialogueMessages = mcm.AddToggleOption("Show Debug Messages", repository.showRadiantDialogueMessages)

    mcm.AddHeaderOption("NPC Actions")
	mcm.oid_AllowForNPCtoFollowToggle = mcm.AddToggleOption("Allow Follow (Experimental)", Repository.AllowForNPCtoFollow)
	mcm.oid_NPCAngerToggle = mcm.AddToggleOption("Allow Aggro", Repository.NPCAnger)
    mcm.oid_NPCInventoryToggle = mcm.AddToggleOption("Allow Inventory", Repository.NPCInventory)
    mcm.oid_NPCPackageToggle = mcm.AddToggleOption("NPCs Stop to Talk", Repository.NPCPackage)
    mcm.oid_showDialogueItems = mcm.AddToggleOption("Show Dialogue Items", repository.showDialogueItems) 
    mcm.oid_enableVanillaDialogueAwareness = mcm.AddToggleOption("Enable Vanilla Dialogue Awareness", repository.enableVanillaDialogueAwareness)
endfunction

function SliderOptionOpen(MantellaMCM mcm, int optionID, MantellaRepository Repository) global
    ; SliderOptionOpen is used to choose what to display when the user clicks on the slider
    if optionID==mcm.oid_responsetimeslider
        mcm.SetSliderDialogStartValue(repository.MantellaEffectResponseTimer)
        mcm.SetSliderDialogDefaultValue(30)
        mcm.SetSliderDialogRange(0, 5000)
        mcm.SetSliderDialogInterval(1)
    elseIf optionID==mcm.oid_radiantdistance
        mcm.SetSliderDialogStartValue(repository.radiantDistance)
        mcm.SetSliderDialogDefaultValue(20)
        mcm.SetSliderDialogRange(1, 250)
        mcm.SetSliderDialogInterval(1)
    elseIf optionID==mcm.oid_radiantfrequency
        mcm.SetSliderDialogStartValue(repository.radiantFrequency)
        mcm.SetSliderDialogDefaultValue(10)
        mcm.SetSliderDialogRange(5, 300)
        mcm.SetSliderDialogInterval(1)
    endif
endfunction

function SliderOptionAccept(MantellaMCM mcm, int optionID, float value, MantellaRepository Repository) global
    ;SliderOptionAccept is used to update the Repository with the user input (that input will then be used by the Mantella effect script
    If  optionId == mcm.oid_responsetimeslider
        mcm.SetSliderOptionValue(optionId, value)
        Repository.MantellaEffectResponseTimer=value
    elseIf optionId == mcm.oid_radiantdistance
        mcm.SetSliderOptionValue(optionId, value)
        Repository.radiantDistance=value
        debug.MessageBox("Please save and reload for this change to take effect")
    elseIf optionId == mcm.oid_radiantfrequency
        mcm.SetSliderOptionValue(optionId, value)
        Repository.radiantFrequency=value
        debug.MessageBox("Please save and reload for this change to take effect")
    EndIf
endfunction


function KeyMapChange(MantellaMCM mcm,Int option, Int keyCode, String conflictControl, String conflictName, MantellaRepository Repository) global
    ;This script is used to check if a key is already used, if it's not it will update to a new value (stored in MantellaRepository) or it will prompt the user to warn him of the conflict. The actual keybind happens in MantellaRepository
    bool isOptionHotkey = option == mcm.oid_keymapStartAddHotkey || option == mcm.oid_keymapPromptHotkey || option == mcm.oid_keymapCustomGameEventHotkey || option == mcm.oid_keymapEndHotkey || option == mcm.oid_keymapRadiantHotkey
    if (isOptionHotkey)
        Bool continue = true
        ;below checks if there's already a bound key
        if conflictControl != ""
            String ConflitMessage
            if conflictName != ""
                ConflitMessage = "Key already mapped to:\n'" + conflictControl + "'\n(" + conflictName + ")\n\nAre you sure you want to continue?"
            else
                ConflitMessage = "Key already mapped to:\n'" + conflictControl + "'\n\nAre you sure you want to continue?"
            endIf
            continue = mcm.ShowMessage(ConflitMessage, true, "$Yes", "$No")
        endIf
        if continue
            mcm.SetKeymapOptionValue(option, keyCode)
            ;selector to update the correct hotkey according to oid values
            if option == mcm.oid_keymapStartAddHotkey
                repository.BindStartAddHotkey(keyCode)
            elseIf option == mcm.oid_keymapPromptHotkey 
                repository.BindPromptHotkey(keyCode)
            elseIf option == mcm.oid_keymapEndHotkey
                repository.BindEndHotkey(keyCode)
            elseIf option == mcm.oid_keymapCustomGameEventHotkey
                repository.BindCustomGameEventHotkey(keyCode)
            elseIf option == mcm.oid_keymapRadiantHotkey
                repository.BindRadiantHotkey(keyCode)
            endif
        endIf
    endIf
endfunction

function OptionUpdate(MantellaMCM mcm, int optionID, MantellaRepository Repository) global
    ;checks option per option what the toggle is and the updates the variable/function repository MantellaRepository so the MantellaEffect and Repository Hotkey function can access it
    if optionID == mcm.oid_microphoneEnabledToggle
        Repository.microphoneEnabled =! Repository.microphoneEnabled
        mcm.SetToggleOptionValue(mcm.oid_microphoneEnabledToggle, Repository.microphoneEnabled)
    elseif optionID == mcm.oid_useHotkeyToStartMic
        Repository.useHotkeyToStartMic =! Repository.useHotkeyToStartMic
        mcm.SetToggleOptionValue(mcm.oid_useHotkeyToStartMic, Repository.useHotkeyToStartMic)
    elseIf optionID == mcm.oid_showReminderMessages
        repository.showReminderMessages =! repository.showReminderMessages
        mcm.SetToggleOptionValue(optionID, repository.showReminderMessages)
    elseIf optionID == mcm.oid_debugNPCselectMode
        Repository.NPCdebugSelectModeEnabled =! Repository.NPCdebugSelectModeEnabled
        mcm.SetToggleOptionValue(mcm.oid_debugNPCselectMode, Repository.NPCdebugSelectModeEnabled)
    elseIf optionID == mcm.oid_showDialogueItems
        repository.showDialogueItems =! repository.showDialogueItems
        mcm.SetToggleOptionValue(mcm.oid_showDialogueItems, repository.showDialogueItems)
    elseIf optionID == mcm.oid_radiantenabled
        repository.radiantEnabled =! repository.radiantEnabled
        mcm.SetToggleOptionValue(mcm.oid_radiantenabled, repository.radiantEnabled)
    elseIf optionID == mcm.oid_showRadiantDialogueMessages
        repository.showRadiantDialogueMessages =! repository.showRadiantDialogueMessages
        mcm.SetToggleOptionValue(optionID, repository.showRadiantDialogueMessages)
    elseIf optionID == mcm.oid_AllowForNPCtoFollowToggle
        Repository.AllowForNPCtoFollow =! Repository.AllowForNPCtoFollow
        mcm.SetToggleOptionValue(mcm.oid_AllowForNPCtoFollowToggle, Repository.AllowForNPCtoFollow)
        if (Repository.AllowForNPCtoFollow) == True 
            game.getplayer().addtofaction(Repository.giafac_AllowFollower)
        elseif (Repository.AllowForNPCtoFollow) == False
            game.getplayer().removefromfaction(Repository.giafac_AllowFollower)
        endif
    elseIf optionID == mcm.oid_NPCAngerToggle
        Repository.NPCAnger =! Repository.NPCAnger
        mcm.SetToggleOptionValue(mcm.oid_NPCAngerToggle, Repository.NPCAnger)
        if (Repository.NPCAnger) == True 
            game.getplayer().addtofaction(Repository.giafac_AllowAnger)
        elseif (Repository.NPCAnger) == False
            game.getplayer().removefromfaction(Repository.giafac_AllowAnger)
        endif
    elseIf optionID == mcm.oid_NPCInventoryToggle
        Repository.NPCInventory =! Repository.NPCInventory
        mcm.SetToggleOptionValue(mcm.oid_NPCInventoryToggle, Repository.NPCInventory)
        if (Repository.NPCInventory) == True 
            game.getplayer().addtofaction(Repository.fac_AllowInventory)
        elseif (Repository.NPCInventory) == False
            game.getplayer().removefromfaction(Repository.fac_AllowInventory)
        endif
    elseIf optionID == mcm.oid_NPCPackageToggle
        Repository.NPCPackage =! Repository.NPCPackage
        mcm.SetToggleOptionValue(mcm.oid_NPCPackageToggle, Repository.NPCPackage)
    elseIf optionID == mcm.oid_enableVanillaDialogueAwareness
        Repository.enableVanillaDialogueAwareness =! Repository.enableVanillaDialogueAwareness
        mcm.SetToggleOptionValue(mcm.oid_enableVanillaDialogueAwareness, Repository.enableVanillaDialogueAwareness)
    endif
endfunction