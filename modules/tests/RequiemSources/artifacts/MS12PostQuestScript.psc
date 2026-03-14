Scriptname MS12PostQuestScript extends Quest  

MiscObject Property EmptyPhial auto

Potion Property Replicated auto

Potion Property HealPotion auto
Potion Property ResistMagicPotion auto
Potion Property ResistDamagePotion auto
Potion Property ImproveMagicPotion auto
Potion Property ImproveDamagePotion auto
Potion Property ImproveSneakPotion auto

Message Property MS12RefillMessage auto

ReferenceAlias Property PhialAlias auto


Function SetReward(string rewardType)
; 	Debug.Trace("MS12: Setting reward to " + rewardType)
	if     (rewardType == "heal")
		Replicated = HealPotion
	elseif (rewardType == "resist magic")		
		Replicated = ResistMagicPotion
	elseif (rewardType == "resist damage")		
		Replicated = ResistDamagePotion
	elseif (rewardType == "improve magic")		
		Replicated = ImproveMagicPotion
	elseif (rewardType == "improve damage")		
		Replicated = ImproveDamagePotion
	elseif (rewardType == "improve sneak")		
		Replicated = ImproveSneakPotion
	else
; 		Debug.Trace("MS12: Trying to align phial to unknown type.", 2)
	endif

	ObjectReference rep = Game.GetPlayer().PlaceAtMe(Replicated, 1)
	PhialAlias.ForceRefTo(rep)

	Game.GetPlayer().AddItem(rep)
EndFunction

Event OnUpdate()
	RewardCheck()
EndEvent

Event OnSleepStop(Bool abInterrupted)
	RewardCheck()
EndEvent

Function RewardCheck(bool quiet = false)
; 	Debug.Trace("MS12: White phial attempting to refill...")
	UnregisterForUpdate()
	UnregisterForSleep()
	if (Game.GetPlayer().GetItemCount(EmptyPhial) > 0)
		MS12RefillMessage.Show()
	endif
	(PhialAlias as MS12WhitePhialScript).Refill(Replicated)
EndFunction

