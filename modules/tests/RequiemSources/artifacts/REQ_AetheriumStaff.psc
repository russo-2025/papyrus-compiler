ScriptName REQ_AetheriumStaff Extends ObjectReference

Faction Property DLC1LD_AetherialStaffBusyFaction Auto

Spell Property SummonSphereSpell Auto


Event OnInit()
	Actor Player = Game.GetPlayer()
	If !Player.IsInFaction(DLC1LD_AetherialStaffBusyFaction)
		Player.AddToFaction(DLC1LD_AetherialStaffBusyFaction)
		SummonSphereSpell.Cast(Player, Self)
	EndIf
	Disable()
	Delete()
EndEvent
