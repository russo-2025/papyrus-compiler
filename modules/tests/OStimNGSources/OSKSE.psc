;/* OSKSE
* * bunch of functions supposed to be called from the SKSE plugin
* * meant for internal use and not to be called by addons
* * some of these are still save to call, however others are not
* * the ones that aren't will say so in the documentation
*/;
ScriptName OSKSE

;/* GetRmScale
* * returns the value of the RaceMenu height slider added by XPMSSE
* *
* * @param: Act, the actor the check the slider for
* * @param: IsFemale, if the actor is female
* *
* * @return: the height slider value
*/; 
float Function GetRmScale(Actor Act, bool IsFemale) Global
	If nioverride.HasNodeTransformScale(Act, False, IsFemale, "NPC", "RSMPlugin")
			Return nioverride.GetNodeTransformScale(Act, False, IsFemale, "NPC", "RSMPlugin")
		Else
			Return 1
		EndIf
EndFunction

;/* UpdateHeelOffset
* * do NOT ever call this, the .dll caches if the offset is currently removed or not
* * if you bring that out of sync shit goes sideways
*/;
Function UpdateHeelOffset(Actor Act, float Offset, bool Add, bool Remove, bool IsFemale) Global
	If Add
		nioverride.RemoveNodeTransformPosition(Act, false, IsFemale, "NPC", "OStim")
	EndIf
	If Remove
		float[] Pos = new float[3]
		Pos[0] = 0
		Pos[1] = 0
		Pos[2] = -Offset
		nioverride.AddNodeTransformPosition(Act, false, IsFemale, "NPC", "OStim", Pos)
	EndIf
	nioverride.UpdateNodeTransform(Act, false, IsFemale, "NPC")
EndFunction

;/* ApplyNodeOverrides
* * relays the ApplyNodeOverrides call through Papyrus
* * for some users the game CTDs when the .dll directly calls the NiOverride script
* * so by relaying it through this script this will hopefully end up to only be a Papyrus log entry
* *
* * @param: Act, the actor
*/;
Function ApplyNodeOverrides(Actor Act) Global
	NiOverride.ApplyNodeOverrides(Act)
EndFunction

;/* SayPostDialogue
* * makes the actor say the dialogue after a short delay
* *
* * @param: Act, the actor that should say the dialogue
* * @param: Target, the actor the dialogue should be said to
* * @param: Dialogue, the dialogue
*/;
Function SayPostDialogue(Actor Act, Actor Target, Topic Dialogue, float Delay) Global
	Utility.Wait(Delay)
	OActorUtil.SayTo(Act, Target, Dialogue)
EndFunction

;/* FadeToBlack
* * fades the game to a blackscreen
* *
* * @param: FadeDuration, the duration in seconds for the fade to reach full black
*/;
Function FadeToBlack(float FadeDuration) Global
	Game.FadeOutGame(true, true, 0.0, FadeDuration)
	Utility.Wait(fadeDuration * 0.7)
	Game.FadeOutGame(false, true, 99.0, 99.0)
	(Game.GetFormFromFile(0xECB, "OStim.esp") As GlobalVariable).value = 1
EndFunction

;/* FadeFromBlack
* * fades the game from a blackscreen back to normal
* *
* * @param: FadeDuration, the duration in seconds for the fade to reach normal
*/;
Function FadeFromBlack(float FadeDuration) Global
	GlobalVariable OStimFinishedFadeToBlack = Game.GetFormFromFile(0xECB, "OStim.esp") As GlobalVariable
	While OStimFinishedFadeToBlack.Value == 0
		Utility.Wait(0.1)
	EndWhile
	Game.FadeOutGame(false, true, 0.0, FadeDuration)
	OStimFinishedFadeToBlack.Value = 0
EndFunction

Function SendOStimEvent(int ThreadId, string Type, Actor eventActor, Actor eventTarget, Actor eventPerformer) Global
	int eventId = ModEvent.Create("ostim_event")
	ModEvent.PushInt(eventId, ThreadId)
	ModEvent.PushString(eventId, Type)
	ModEvent.PushForm(eventId, eventActor)
	ModEvent.PushForm(eventId, eventTarget)
	ModEvent.PushForm(eventId, eventPerformer)
	ModEvent.Send(eventId)
EndFunction

; TEMPORARY ONLY
; don't call any of these, we will remove them again in later versions

Function ShowBars() Global
	OUtils.GetOStim().ShowBars()
EndFunction

int Function UIExtMessageBox(string Caption, string[] Options) Global
	Debug.Notification(Caption)

	UIListMenu ListMenu = uiextensions.GetMenu("UIListMenu") As UIListMenu

	ListMenu.ResetMenu()

	int i = 0
	While i < Options.Length
		ListMenu.AddEntryItem(Options[i])
		i += 1
	EndWhile
	;ListMenu.SetPropertyStringA("appendEntries", Options)

	ListMenu.OpenMenu()
	int Index = ListMenu.GetResultInt()

	Return Index
EndFunction

string Function UIExtTextInput() Global
	UITextEntryMenu Menu = UIExtensions.GetMenu("UITextEntryMenu") As UITextEntryMenu
	Menu.OpenMenu()
	Return Menu.GetResultString()
EndFunction