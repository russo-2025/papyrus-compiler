Scriptname REQ_ShieldEffectUnequipFix extends activemagiceffect  
{attach this script to Shield effects that change DamageResist to fix REQ-550}

Event OnEffectFinish(Actor akTarget, Actor akCaster)
	akTarget.DamageActorValue("DamageResist",1)
	akTarget.RestoreActorValue("DamageResist",1)
EndEvent