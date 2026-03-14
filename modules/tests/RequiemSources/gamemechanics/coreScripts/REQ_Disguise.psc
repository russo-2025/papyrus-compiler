Scriptname REQ_Disguise extends REQ_CoreScript

KeyWord[] Property FactionKeyword Auto
{Faction Keywords for suitable cuirasses}
ReferenceAlias[] Property FactionAlias Auto
{alias with corresponding factions}
Formlist[] Property RequiredRace Auto
{formlist with allowed races for faction, if any (else none)}
Message[] Property DisguiseStart Auto
{message shown when disguise starts}
Message[] Property DisguiseBlown Auto
{message shown when disguise is blown}
Float Property UpdateInterval Auto
{update interval for observer tests}

Perk Property BaseDisguise Auto
{perk required for disguise with regular checks}
Perk Property MasterDisguise Auto
{perk required for disguise without regular checks}
Quest Property LOSTracker Auto
{Line of Sight tracking quest}
ReferenceAlias[] Property Closest Auto
{aliases for actors allowed to blow the player's disguise}

Int disguise = -1

Function initScript(Int currentVersion, Int nevVersion)
EndFunction

Function shutdownScript(Int currentVersion, Int nevVersion)
EndFunction

Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
	Int i = 0
	Bool notfound = True
	If ( !Player.IsInCombat() && Player.HasPerk(BaseDisguise) )
		While (i < FactionKeyword.Length && disguise < 0 && Notfound)
			disguise = -1 + akBaseObject.HasKeyword(FactionKeyword[i]) as Int * (i+1)
			notfound = !(disguise >= 0)
			If (RequiredRace[i] != None && !RequiredRace[i].HasForm(Player.GetRace()) )
				disguise = -1
				notfound = True
			EndIf
			i += 1
		EndWhile
		If (disguise >= 0 && !notfound)
			If (!Player.HasPerk(MasterDisguise))
				RegisterForSingleUpdate(UpdateInterval)
			EndIf
			FactionAlias[disguise].ForceRefTo(Player)
			GoToState("Disguised")
			DisguiseStart[disguise].Show()
		EndIf
	EndIf
EndEvent

Event OnObjectUnEquipped(Form akBaseObject, ObjectReference akReference)
	If ( Player.HasPerk(BaseDisguise) )
		If (disguise >= 0 && akBaseObject.HasKeyword(FactionKeyword[disguise]))
			FactionAlias[disguise].Clear()
			UnregisterForUpdate()
			GoToState("")
			disguise = -1 
		EndIf
	EndIf
EndEvent

Bool Function BlowDisguise()
	Int i = 0
	Float Chance = 0
	Float random = Utility.RandomFloat(0.0,100.0)
	LOSTracker.Stop()
	LOSTracker.Start()
	While (i < Closest.Length)
		If (Closest[i].GetActorReference() != None)
			chance = -1.67+905/Player.GetActorValue("Speechcraft")
			chance *= Player.GetLightLevel()/300
			chance *= 1400.0/(Closest[i].GetActorReference().GetDistance(Player)+1400.0)
			If ( Player.IsSneaking() )
				chance *= 3.0
			ElseIf ( Player.IsSprinting() )
				chance *= 2.0
			EndIf
			If ( random < chance )
				Return True
			EndIf
		EndIf
		i += 1
	EndWhile
	return false
Endfunction

State Disguised

	Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
		If ((akAggressor as Actor).GetFactionReaction(Player) >= 2)
			FactionAlias[disguise].Clear()
			GoToState("")
			UnregisterForUpdate()
			DisguiseBlown[disguise].Show()
			disguise = -1
		EndIf
	EndEvent
	
	Event OnUpdate()
		If ( BlowDisguise() )
			FactionAlias[disguise].Clear()
			GoToState("")
			UnregisterForUpdate()
			DisguiseBlown[disguise].Show()
			disguise = -1
		Else
			RegisterForSingleUpdate(UpdateInterval)
		EndIf
	EndEvent
	
EndState
