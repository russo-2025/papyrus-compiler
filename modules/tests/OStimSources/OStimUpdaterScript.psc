ScriptName OStimUpdaterScript Extends Quest

Bool Initialized
Bool Updating

Form[] Property FormsToUpdate Auto

Event OnInit()
	Initialized = False
	Updating = False

	ResetQuestDB()

	OUtils.Console("Updater ready")
	Initialized = True
EndEvent

Function ResetQuestDB()
	FormsToUpdate = new Form[4]
	FormsToUpdate[2] = Quest.GetQuest("0SA") ; 0SA
	FormsToUpdate[1] = Game.GetFormFromFile(0x0070A4, "OSA.esm") as Quest ; 0SUI
	FormsToUpdate[0] = Quest.GetQuest("0SAControl") as Quest ; 0SAControl
	FormsToUpdate[3] = Game.GetFormFromFile(0x000801, "Ostim.esp") as Quest ; ostim
EndFunction

Function DoUpdate()
	Updating = True

	OUtils.DisplayTextBanner("Updating OStim")

	Form[] forms = FormsToUpdate

	Int i = 0
	Int l = forms.Length
	OUtils.Console("Forms to update: " + l)
	While i < l
		Form f = forms[i]
		Quest q = forms[i] as Quest

		OUtils.Console("Clearing: " + f)
		;If q
		;	q.reset()
		;	q.stop()
		;EndIf

		f.UnregisterForAllMenus()
		f.UnregisterForUpdateGameTime()
		f.UnregisterForUpdate()
		f.UnregisterForAllModEvents()
		f.UnregisterForAllKeys()

		i += 1
	EndWhile

	OUtils.Console("Preparing to fire init events...")
	ResetQuestDB()
	Utility.WaitMenuMode(2)

	i = 0
	While i < l
		Form f = forms[i]
		Quest q = forms[i] as Quest

		OUtils.Console("Starting: " + f)

		;If q
		;	q.Start()
		;EndIf

		OSANative.SendEvent(f, "OnInit")

		Utility.WaitMenuMode(0.1)

		i += 1
	EndWhile

	SendModEvent("0SA_UIBoot")

	OUtils.Console("Updated")
	Utility.Wait(4)
	OUtils.DisplayTextBanner("Update complete")
	outils.DisplayToastText("Perform a save-clean procedure if you experience issues after updating", 10.0)

	Updating = false
EndFunction

Function AddFormToDatabase(Form f)
	While Updating
		Utility.Wait(1)
	EndWhile

	FormsToUpdate = PapyrusUtil.PushForm(FormsToUpdate, f)
EndFunction
