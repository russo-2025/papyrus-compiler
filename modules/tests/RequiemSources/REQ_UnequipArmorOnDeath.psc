ScriptName REQ_UnequipArmorOnDeath Extends Actor  

Armor Property Item Auto

Event OnDying(Actor akKiller)
	UnequipItem(Item)
EndEvent
