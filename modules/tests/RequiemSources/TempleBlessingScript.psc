Scriptname TempleBlessingScript extends ObjectReference Conditional  

Spell Property TempleBlessing  Auto  

Event OnActivate(ObjectReference akActionRef)

	(akActionRef As Actor).DispelAllSpells()
	TempleBlessing.Cast(akActionRef, akActionRef)
	if akActionRef == Game.GetPlayer()
		AltarRemoveMsg.Show()
		BlessingMessage.Show()
	endif

EndEvent

Message Property BlessingMessage  Auto  

Message Property AltarRemoveMsg  Auto  
