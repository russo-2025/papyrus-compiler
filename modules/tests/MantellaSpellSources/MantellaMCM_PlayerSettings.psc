Scriptname MantellaMCM_PlayerSettings  Hidden 
{This is the menu page for setting for player character settings.}
function Render(MantellaMCM mcm, MantellaRepository Repository) global
     ;This part of the MCM MainSettings script pretty much only serves to tell papyrus what button to display.
    mcm.SetCursorFillMode(mcm.TOP_TO_BOTTOM)
    LeftColumn(mcm, Repository)
    mcm.SetCursorPosition(1)
    RightColumn(mcm, Repository)
endfunction


function LeftColumn(MantellaMCM mcm, MantellaRepository Repository) global
    ;This part of the MCM MainSettings script pretty much only serves to tell papyrus what button to display using properties from the repository
    mcm.AddHeaderOption ("Player Character")
    If (Repository.IsVR())
        mcm.AddTextOption("For VR, use Mantella Software config", true)
    else
        mcm.oid_playerCharacterDescription1 = mcm.AddTextOption("Default Player Description", repository.playerCharacterDescription1)
        mcm.oid_playerCharacterDescription2 = mcm.AddTextOption("Alternative Player Description", repository.playerCharacterDescription2)
        mcm.oid_playerCharacterUsePlayerDescription2 = mcm.AddToggleOption("Use Alternative Description", Repository.playerCharacterUsePlayerDescription2)
        mcm.oid_playerCharacterVoicePlayerInput = mcm.AddToggleOption("Voice Player Input", Repository.playerCharacterVoicePlayerInput)
        mcm.oid_playerCharacterVoiceModel = mcm.AddTextOption("Player Voice Model", Repository.playerCharacterVoiceModel)
    EndIf
    mcm.oid_worldID = mcm.AddSliderOption("World ID", Repository.worldID)
    mcm.AddHeaderOption ("Event Tracking")
    mcm.oid_playerTrackingUsePCName=mcm.AddToggleOption("Use Player Name", repository.playerTrackingUsePCName)
endfunction

function RightColumn(MantellaMCM mcm, MantellaRepository Repository) global    
endfunction

string Function GetTextInput(string existingValue) global
    ;Debug.MessageBox("After entering the value you need to close the whole MCM menu to make it responsive again.")
    UITextEntryMenu menu = uiextensions.GetMenu("UITextEntryMenu", true) as UITextEntryMenu
    menu.SetPropertyString("text", existingValue)
    menu.OpenMenu()
    return menu.GetResultString()    
EndFunction

function SliderOptionOpen(MantellaMCM mcm, int optionID, MantellaRepository Repository) global
    ; SliderOptionOpen is used to choose what to display when the user clicks on the slider
    if optionID==mcm.oid_worldID
        mcm.SetSliderDialogStartValue(repository.worldID)
        mcm.SetSliderDialogDefaultValue(1)
        mcm.SetSliderDialogRange(1, 20)
        mcm.SetSliderDialogInterval(1)    
    endif
endfunction

function SliderOptionAccept(MantellaMCM mcm, int optionID, float value, MantellaRepository Repository) global
    ;SliderOptionAccept is used to update the Repository with the user input (that input will then be used by the Mantella effect script
    If  optionId == mcm.oid_worldID
        mcm.SetSliderOptionValue(optionId, value)
        Repository.worldID = value as int
    EndIf
endfunction

function OptionUpdate(MantellaMCM mcm, int optionID, MantellaRepository Repository) global
    ;checks option per option what the toggle is and the updates the var repository MantellaRepository so the ListenerScript can access it
    if optionID==mcm.oid_playerTrackingUsePCName
        repository.playerTrackingUsePCName=!mcm.repository.playerTrackingUsePCName
        mcm.SetToggleOptionValue(mcm.oid_playerTrackingUsePCName, repository.playerTrackingUsePCName)
    ElseIf (optionID == mcm.oid_playerCharacterUsePlayerDescription2) ;Player Character options
        repository.playerCharacterUsePlayerDescription2 =!mcm.repository.playerCharacterUsePlayerDescription2
        mcm.SetToggleOptionValue(optionID, repository.playerCharacterUsePlayerDescription2)    
    ElseIf (optionID == mcm.oid_playerCharacterVoicePlayerInput) ;Player Character options
        repository.playerCharacterVoicePlayerInput =!mcm.repository.playerCharacterVoicePlayerInput
        mcm.SetToggleOptionValue(optionID, repository.playerCharacterVoicePlayerInput)
    elseIf optionID == mcm.oid_playerCharacterDescription1
        Repository.playerCharacterDescription1 = GetTextInput(Repository.playerCharacterDescription1)
    ElseIf optionID == mcm.oid_playerCharacterDescription2
        Repository.playerCharacterDescription2 = GetTextInput(Repository.playerCharacterDescription2)
    ElseIf (optionID == mcm.oid_playerCharacterVoiceModel)
        Repository.playerCharacterVoiceModel = GetTextInput(Repository.playerCharacterVoiceModel)
    endIf
endfunction
