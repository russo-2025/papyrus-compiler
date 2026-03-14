Scriptname DA05HircinesRingScript Extends ObjectReference  

Spell Property HircinesRingPower Auto
Quest Property CompanionsCentralQuest Auto


Event OnEquipped(Actor akActor)
	If akActor == Game.GetPlayer() && (CompanionsCentralQuest As CompanionsHousekeepingScript).PlayerHasBeastBlood
		akActor.RemoveSpell(HircinesRingPower)
		akActor.AddSpell(HircinesRingPower, False)
	EndIf
EndEvent
