ScriptName REQ_Conjuration_Teleport Extends Actor

ImageSpaceModifier Property Fadeout Auto

Event OnLoad()
	Fadeout.Apply()
	Game.DisablePlayerControls()
	Utility.Wait(0.5)
	Game.GetPlayer().MoveTo(Self)	
	Disable()
	Delete()
	Utility.Wait(0.5)
	Fadeout.Remove()
	Game.EnablePlayerControls()
EndEvent
