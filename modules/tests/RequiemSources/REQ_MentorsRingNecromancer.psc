ScriptName REQ_MentorsRingNecromancer Extends ReferenceAlias

Armor Property MentorsRing Auto


Event OnLoad()
	Actor Necromancer = GetActorReference()
	If Necromancer.GetItemCount(MentorsRing) >= 1
		Necromancer.EquipItem(MentorsRing)
	EndIf
EndEvent

Event OnDeath(Actor akKiller)
	Quest OwningQuest = GetOwningQuest()
	OwningQuest.CompleteQuest()
	OwningQuest.Stop()
EndEvent
