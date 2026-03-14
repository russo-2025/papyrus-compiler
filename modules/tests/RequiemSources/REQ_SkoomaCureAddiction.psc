ScriptName REQ_SkoomaCureAddiction Extends ActiveMagicEffect

Spell Property Addiction Auto


Event OnEffectStart(Actor akTarget, Actor akCaster)
	RegisterForSleep()
EndEvent

Event OnSleepStart(float afSleepStartTime, float afDesiredSleepEndTime)
	GetTargetActor().RemoveSpell(Addiction)
EndEvent
