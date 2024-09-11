ScriptName dubhDisguiseMCMHelper Extends SKI_ConfigBase
{Utility to make SkyUI MCM menu syntax a little easier.}

;CAVEATS
;If a child implements MCM events, they must call Parent.eventname(args....) to pass the call up to this class.

Import Debug
Import StringUtil
Import Math

Int[] iOptionTypes
Int kToggle = 1
Int kToggleGlobal = -1
Int kSlider = 2
Int kSliderGlobal = -2
Int kText = 3
Int kMenu = 4
Int kKeyMap = 5
Int kKeyMapGlobal = -5
Int kColor = 6
Int kTextToggle = 7
Int kToggleGlobalBitmask = 8

String[] sLabels
String[] sHelpInfos
GlobalVariable[] gGlobalVars
Bool[] bBoolVals
Float[] fFloatVals
Float[] fSliderMaxs
Float[] fSliderMins
Float[] fSliderDefaults
Float[] fSliderIntervals
String[] sSliderFormats
String[] sKeyConflicts
Int[] iIntVals
String[] sStringVals
String[] sModEvents
Int[] iBitMasks

Event OnInit()
  RegisterForSingleUpdate(1.0)
  InitArrays()
  Parent.OnInit()
EndEvent

Event OnUpdate()
  RegisterForModEvent("SKICP_pageSelected", "OnPageSelect") ;mod event registration does not endure game reload
  RegisterForModEvent("SKICP_configManagerReady", "OnConfigManagerReadyMCMHelper")
  RegisterForSingleUpdate(30.0)
EndEvent

Event OnConfigManagerReadyMCMHelper(String a_eventName, String a_strArg, Float a_numArg, Form a_sender)
  ;eliminates the need to have a player ReferenceAlias with ski_playerloadgamealias to get MCM menus to show
  OnGameReload()
EndEvent

Int Function DefineMCMToggleOption(String sTextLabel, Bool bInitialState = False, Int iFlags = 0, String sHelpInfo = "", String sModEvent = "")
  ; A single line of code that sets up a menu item for toggling value of a GlobalVariable without all the event handling stuff
  ; just add to OnPageReset area
  Int iOID = AddToggleOption(sTextLabel, bInitialState, iFlags) % 128 ;- iOIDOffset

  sLabels[iOID] = sTextLabel
  sHelpInfos[iOID] = sHelpInfo
  bBoolVals[iOID] = bInitialState
  iOptionTypes[iOID] = kToggle
  sModEvents[iOID] = sModEvent
  Return iOID
EndFunction

Int Function DefineMCMToggleOptionGlobal(String sTextLabel, GlobalVariable gToggleVar, Int iFlags = 0, String sHelpInfo = "", String sModEvent = "")
  ; A single line of code that sets up a menu item for toggling value of a GlobalVariable without all the event handling stuff
  ; just add to OnPageReset area

  Int iOID = DefineMCMToggleOption(sTextLabel, gToggleVar.GetValueInt() as Bool, iFlags, sHelpInfo, sModEvent) % 128

  gGlobalVars[iOID] = gToggleVar
  iOptionTypes[iOID] = kToggle  ;Global
  Return iOID
EndFunction

Int Function DefineMCMToggleOptionGlobalBitmask(String sTextLabel, GlobalVariable gToggleVar, Int iBitmask, Int iFlags = 0, String sHelpInfo = "", String sModEvent = "")
  ; A single line of code that sets up a menu item for toggling value of a bitmask value within a GlobalVariable without all the event handling stuff
  ; just add to OnPageReset area
  ; NOTE: DUE TO FLOAT ROUNDING OF GlobalVariables, THIS FUNCTION ONLY SUPPORTS BITMASKS UP TO 0x100000 (= 21 DIFFERENT BIT VALUES)

  Bool bVal = LogicalAnd(gToggleVar.GetValue() as Int, iBitMask) as Bool
  Int iOID = DefineMCMToggleOption(sTextLabel, bVal, iFlags, sHelpInfo, sModEvent) % 128

  gGlobalVars[iOID] = gToggleVar
  bBoolVals[iOID] = bVal
  iOptionTypes[iOID] = kToggleGlobalBitmask
  iBitmasks[iOID] = iBitmask
  Return iOID
EndFunction

Int Function DefineMCMSliderOption(String sTextLabel, Float fValue, Float fDefault, Float fMin, Float fMax, Float fInterval, String sHelpInfo = "", String formatString = "{0}", Int flags = 0, String sModEvent = "")
  Int iOID = AddSliderOption(sTextLabel, fValue, formatString, flags) % 128 ; - iOIDOffset

  sLabels[iOID] = sTextLabel
  sHelpInfos[iOID] = sHelpInfo
  fFloatVals[iOID] = fValue
  fSliderMaxs[iOID] = fMax
  fSliderMins[iOID] = fMin
  fSliderDefaults[iOID] = fDefault
  fSliderIntervals[iOID] = fInterval
  iOptionTypes[iOID] = kSlider
  sSliderFormats[iOID] = formatString
  sModEvents[iOID] = sModEvent
  Return iOID
EndFunction

Int Function DefineMCMSliderOptionGlobal(String sTextLabel, GlobalVariable gSliderVar, Float fDefault, Float fMin, Float fMax, Float fInterval, String sHelpInfo = "", String formatString = "{0}", Int flags = 0, String sModEvent = "")
  Int iOID = DefineMCMSliderOption(sTextLabel, gSliderVar.GetValue(), fDefault, fMin, fMax, fInterval, sHelpInfo, formatString, flags, sModEvent) % 128

  gGlobalVars[iOID] = gSliderVar
  iOptionTypes[iOID] = kSliderGlobal
  return iOID
EndFunction

Int Function DefineMCMKeymapOption(String sTextLabel, Int iKeyCode, Int iFlags = 0, Int iDefault, String sHelpInfo = "", String sKeyConflict = "", string sModEvent = "")
  Int iOID = AddKeyMapOption(sTextLabel, iKeyCode, iFlags) % 128  ; - iOIDOffset

  iOptionTypes[iOID] = kKeyMap
  sLabels[iOID] = sTextLabel
  sHelpInfos[iOID] = sHelpInfo
  sKeyConflicts[iOID] = sKeyConflict
  iIntVals[iOID] = iKeyCode
  fSliderDefaults[iOID] = iDefault as Float
  sModEvents[iOID] = sModEvent
  Return iOID
EndFunction

Int Function DefineMCMKeymapOptionGlobal(String sTextLabel, GlobalVariable gGlobalVar, Int iFlags = 0, Int iDefault = -1, String sHelpInfo = "", String sKeyConflict = "", String sModEvent = "")
  Int iOID = DefineMCMKeymapOption(sTextLabel, gGlobalVar.GetValueInt(), iFlags, iDefault, sHelpInfo, sKeyConflict, sModEvent) % 128

  gGlobalVars[iOID] = gGlobalVar
  iOptionTypes[iOID] = kKeyMapGlobal
  Return iOID
EndFunction

Int Function DefineMCMTextOption(String sTextLabel, String sValue, Int iFlags = 0, String sHelpInfo = "", String sModEvent = "")
  Int iOID = AddTextOption(sTextLabel, sValue, iFlags) % 128  ; - iOIDOffset

  iOptionTypes[iOID] = kText
  sLabels[iOID] = sTextLabel
  sHelpInfos[iOID] = sHelpInfo
  sStringVals[iOID] = sValue
  sModEvents[iOID] = sModEvent
  Return iOID
EndFunction

Int Property OPTION_FLAG_AS_TEXTTOGGLE = 0x64 AutoReadonly ;show a menu alternatively as a toggling value text option

Int Function DefineMCMMenuOption(String sTextLabel, String sValuesCSV, Int iSelected = 0, Int iDefault = 0, Int iFlags = 0, String sHelpInfo = "", String sModEvent = "")
  Int iOID
  String[] sValues = LibFire.SplitString(sValuesCSV, ",")

  If Math.LogicalAnd(iFlags, OPTION_FLAG_AS_TEXTTOGGLE)
    iOID = AddTextOption(sTextLabel, sValues[iSelected], iFlags) % 128  ; - iOIDOffset
    iOptionTypes[iOID] = kTextToggle
  Else
    iOID = AddMenuOption(sTextLabel, sValues[iSelected], iFlags) % 128  ; - iOIDOffset
    iOptionTypes[iOID] = kMenu
    SetMenuOptionValue(iOID, sValues[iSelected])
  EndIf

  iIntVals[iOID] = iSelected
  sLabels[iOID] = sTextLabel
  sHelpInfos[iOID] = sHelpInfo
  sStringVals[iOID] = sValuesCSV
  fSliderDefaults[iOID] = iDefault as Float
  sModEvents[iOID] = sModEvent
  Return iOID
EndFunction

Int Function DefineMCMMenuOptionGlobal(String sTextLabel, String sValuesCSV, GlobalVariable giSelected, Int iDefault = 0, Int iFlags = 0, String sHelpInfo = "", String sModEvent = "")
  Int iSelected = giSelected.GetValue() as Int
  Int iOID = DefineMCMMenuOption(sTextLabel, sValuesCSV, iSelected, iDefault, iFlags, sHelpInfo, sModEvent)
  gGlobalVars[iOID] = giSelected
  Return iOID
EndFunction

Function DefineMCMParagraph(String asText, Int aiFlags = 0x1)  ;disabled type text by default
  AddTextOption(asText, "", aiFlags)
EndFunction

Int Function DefineMCMHelpTopic(String sTopic, String sHelpInfo = "")
;simplified call to display a string of text with topic info
  Return DefineMCMTextOption(sTopic, "", 0, sHelpInfo)
EndFunction

Bool Function GetMCMValueBool(String sTextLabel)
;return the current state for a toggle by its label
  Return bBoolVals[GetMCMiOID(sTextLabel)]
EndFunction

Int Function GetMCMValueInt(String sTextLabel)
  Return iIntVals[GetMCMiOID(sTextLabel)]
EndFunction

Float Function GetMCMValueFloat(String sTextLabel)
  Return fFloatVals[GetMCMiOID(sTextLabel)]
EndFunction

String Function GetMCMValueString(String sTextLabel)
  Int iOID = GetMCMiOID(sTextLabel)
  If (iOptionTypes[iOID] == kMenu) || (iOptionTypes[iOID] == kTextToggle)
    String[] sValues = LibFire.SplitString(sStringVals[iOID], ",")
    Return sValues[iIntVals[iOID]]
  EndIf
  Return sStringVals[iOID]
EndFunction

Int Function GetMCMiOID(String sTextLabel)
  Int iOID = 0
  While iOID < 128  ;sLabels.Length
    If sLabels[iOID] == sTextLabel
      Return iOID
    EndIf
    iOID += 1
  EndWhile
  Return 0
EndFunction

;MCM EVENTS
;if child uses any of these events, they should call Parent.eventname(args,...) as part of their function or the event will be masked

Event OnOptionSelect(Int iMCMOID)
  Int iOID = iMCMOID  % 128 ;-= iOIDOffset
  If iOptionTypes[iOID] == kTextToggle
    String[] sValues = LibFire.SplitString(sStringVals[iOID], ",")
    iIntVals[iOID] = (iIntVals[iOID] + 1) % sValues.Length
    If gGlobalVars[iOID]
      gGlobalVars[iOID].SetValue(iIntVals[iOID] as Float)
    EndIf
    SetTextOptionValue(iMCMOID, sValues[iIntVals[iOID]])
  ElseIf iOptionTypes[iOID] == kToggle
    bBoolVals[iOID] = !bBoolVals[iOID]
    SetToggleOptionValue(iMCMOID, bBoolVals[iOID])
    If gGlobalVars[iOID]
      gGlobalVars[iOID].SetValue(bBoolVals[iOID] as Float)
    EndIf
  ElseIf iOptionTypes[iOID] == kToggleGlobalBitmask
    bBoolVals[iOID] = !bBoolVals[iOID]
    SetToggleOptionValue(iMCMOID, bBoolVals[iOID])
    gGlobalVars[iOID].SetValue(logicalOr(logicalAnd(gGlobalVars[iOID].GetValueInt(), logicalNot(iBitMasks[iOID])), (iBitMasks[iOID] * (bBoolVals[iOID] as int))) as float)
  EndIf
  DispatchModEvent(iOID)
EndEvent

Event OnOptionHighlight(Int iOID)
  iOID = iOID  % 128  ; -= iOIDOffset
  SetInfoText(sHelpInfos[iOID])
EndEvent

Event OnOptionSliderOpen(Int iOID)
  iOID = iOID  % 128  ; -= iOIDOffset
  SetSliderDialogStartValue(fFloatVals[iOID])
  SetSliderDialogDefaultValue(fSliderDefaults[iOID])
  SetSliderDialogRange(fSliderMins[iOID], fSliderMaxs[iOID])
  SetSliderDialogInterval(fSliderIntervals[iOID])
EndEvent

Event OnOptionSliderAccept(Int iMCMOID, Float value)
  Int iOID = iMCMOID  % 128 ; -= iOIDOffset
  fFloatVals[iOID] = value
  If gGlobalVars[iOID]
    gGlobalVars[iOID].SetValue(value)
  EndIf
  SetSliderOptionValue(iMCMOID, value, sSliderFormats[iOID])
  DispatchModEvent(iOID)
EndEvent

Event OnOptionDefault(Int iMCMOID)
  Int iOID = iMCMOID  % 128 ; -= iOIDOffset
  If iOptionTypes[iOID] == kSlider
    OnOptionSliderAccept(iMCMOID, fSliderDefaults[iOID])
  ElseIf iOptionTypes[iOID] == kKeyMap || iOptionTypes[iOID] == kKeyMapGlobal
    OnOptionKeyMapChange(iMCMOID, fSliderDefaults[iOID] as Int, "", "")
  EndIf
EndEvent

event OnOptionKeyMapChange(Int iMCMOID, Int KeyCode, String conflictControl, String conflictName)
  Int iOID = iMCMOID  % 128 ; -= iOIDOffset
  If (conflictControl != "") && !ShowMessage("This key is already mapped to:\n\"" + conflictControl + "\"\n(" + conflictName + ")\n\nAre you sure you want to continue?", true, "Yes", "No")
    ; If conflict avoided
  Else
    iIntVals[iOID] = KeyCode
    SetKeyMapOptionValue(iMCMOID, KeyCode)
    If gGlobalVars[iOID]
      gGlobalVars[iOID].SetValue(KeyCode)
    EndIf
    DispatchModEvent(iOID)
  EndIf
EndEvent

Event OnOptionMenuOpen(Int iOID)
  iOID = iOID  % 128  ; -= iOIDOffset
  SetMenuDialogOptions(LibFire.SplitString(sStringVals[iOID], ","))
  SetMenuDialogStartIndex(iIntVals[iOID])
  SetMenuDialogDefaultIndex(fSliderDefaults[iOID] as Int)
EndEvent

Event OnOptionMenuAccept(Int iMCMOID, Int index)
  Int iOID = iMCMOID  % 128 ; -= iOIDOffset
  String[] sValues = LibFire.SplitString(sStringVals[iOID], ",")
  iIntVals[iOID] = index
  If gGlobalVars[iOID]
    gGlobalVars[iOID].SetValue(index as Float)
  EndIf
  SetMenuOptionValue(iMCMOID, sValues[index])
EndEvent

;UTILITY INTERNAL FUNCTIONS

Bool Function DispatchModEvent(Int iOID)
;sent ModEvent calls to the child or any listener
;dispatch any ModEvents
  iOID = iOID % 128
  If sModEvents[iOID] != ""
    If iOptionTypes[iOID] == kToggle
      SendModEvent(sModEvents[iOID], sStringVals[iOID], bBoolVals[iOID] as Float)
    ElseIf iOptionTypes[iOID] == kSlider
      SendModEvent(sModEvents[iOID], sStringVals[iOID], fFloatVals[iOID])
    Else
      SendModEvent(sModEvents[iOID], sStringVals[iOID], iIntVals[iOID] as Float)
    EndIf
    Return True
  EndIf
  Return False
EndFunction

String Function GetCustomControl(Int keyCode)
;helper to notify other plugins of keymapping conflict
  Int iOID
  While iOID < iIntVals.Length
    If iIntVals[iOID] == keyCode
      Return sKeyConflicts[iOID]
    EndIf
    iOID += 1
  EndWhile
EndFunction

Event OnPageSelect(String a_eventName, String a_page, Float a_index, Form a_sender)
;listen for this ModEvent and to reinitialize the page
  InitArrays()
EndEvent

Function InitArrays()
  iOptionTypes = new Int[128]
  sHelpInfos = new String[128]
  sLabels = new String[128]
  gGlobalVars = new GlobalVariable[128]
  bBoolVals = new Bool[128]
  fFloatVals = new Float[128]
  fSliderMaxs = new Float[128]
  fSliderMins = new Float[128]
  fSliderDefaults = new Float[128]
  fSliderIntervals = new Float[128]
  sSliderFormats = new String[128]
  sKeyConflicts = new String[128]
  iIntVals = new Int[128]
  sStringVals = new String[128]
  sModEvents = new String[128]
  iBitMasks = new Int[128]
EndFunction
