ScriptName REQ_TeleportVitals Extends ActiveMagicEffect


GlobalVariable Property EssentialNPCs Auto

Ingredient Property HumansHeart Auto

Keyword Property ActorTypeDaedra Auto


Event OnEffectStart(Actor akTarget, Actor akCaster)
	If EssentialNPCs.GetValue()
		akTarget.Kill(akCaster)
	Else
		akTarget.KillEssential(akCaster)
	EndIf
	Utility.Wait(0.5)
	If akTarget.IsDead() && !akTarget.HasKeyword(ActorTypeDaedra)
		akCaster.AddItem(HumansHeart)
	Endif
EndEvent
