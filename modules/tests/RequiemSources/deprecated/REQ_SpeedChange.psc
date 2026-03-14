Scriptname REQ_SpeedChange extends ActiveMagicEffect 
{triggers immediate speed change on effects that affect speedmult}

Event OnEffectStart(Actor Target, Actor Caster)
	Target.ModActorValue("InventoryWeight", 1)
	Utility.Wait(0.5)
	Target.ModActorValue("InventoryWeight", -1)
EndEvent

Event OnEffectFinish(Actor Target, Actor Caster)
	Target.ModActorValue("InventoryWeight", 1)
	Utility.Wait(0.5)
	Target.ModActorValue("InventoryWeight", -1)
EndEvent