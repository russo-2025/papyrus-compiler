ScriptName REQ_Illusion_MindMaelstrom extends ActiveMagicEffect
{Makes the target suffer a random effect}

Spell[] Property NormalSpells Auto
{spells to apply when the spell is casted normal}
Spell[] Property DualSpells Auto
{spells for dualcasted version}
MagicEffect Property DualCast Auto
{Magic Effect indicating Dualcast}

Event OnEffectStart(Actor akTarget, Actor akCaster)
	Int count = 0
	Spell[] list
	Int Random = 0
	If ( akTarget.HasMagicEffect(Dualcast) )
		list = DualSpells
	Else
		list = NormalSpells
	EndIf
	Random = Utility.RandomInt(0,list.Length - 1)
	list[Random].cast(akCaster, akTarget)
EndEvent
