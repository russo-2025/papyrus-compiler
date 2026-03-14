Scriptname REQ_IllusionBreak extends ActiveMagicEffect
{periodically checks, if the target breaks free from a mind-influence effect before its natural end}

;Default Settings, exposed in case specific adjustments are necessary
Float Property UpdateInterval = 2.0 Auto
{time between consecutive tests, default = 2}
Float Property Mult_Level = 30.0 Auto
{prefactor for the target's level, default=30}
Float Property Mult_Magicka = 2.0 Auto
{prefactor for the target's max magicka, default=2}
Float Property Mult_Illusion = 20.0 Auto
{prefactor for the target's illusion skill, default=20}
Float Property Mult_MagicResist = 0.01 Auto
{prefactor for the target's magic resistance, default=0.01}
Keyword Property MindFogEffect Auto
{Effect Keyword of the mind fog spell}

;Spell-specific settings
Perk[] Property Skill_ScalingPerks Auto
{each perk in this list will increase the scaling multiplicator by 1}
Float Property XPRate Auto
{the amount of illusion XP the caster gains each time the target fails to break the spell}
Float Property Skill_Offset Auto
{added to the casters illusion skill to determine effective skill}
Spell Property BaseSpell Auto
{the unique spell which owns this effect, is required to break free from all effects simultaneously}
String Property CasterSkill = "Illusion" Auto
{determines the skill to be used by the caster for the resistance check, default = Illusion}
Spell Property MindEffect Auto
{the actual mind effect, seperated to avoid possible exploits}
Bool Property InverseFunction = False Auto
{invert the script function, the spell is dispelled once it was NOT resisted}
Bool Property SingleResist = False Auto
{instead of continuous resistances allow only a single check at the beginning}
Bool Property NoAssault = False Auto
{True if the spell is not considered hostile if failed}

Float chance = 0.0
Bool grantxp = False

Event OnEffectStart(Actor akTarget, Actor akCaster)
	Float random = Utility.RandomFloat(0,100)
	Int i = 0
	Float temp = akTarget.GetLevel()
	int perks = 1
	chance = Mult_Level * temp * Math.sqrt(temp)
	temp = akTarget.GetBaseAV("Magicka")
	chance += Mult_Magicka * temp * Math.sqrt(temp)
	temp = akTarget.GetBaseAV("Illusion")
	chance += Mult_Illusion * temp * Math.sqrt(temp)
	While (i < Skill_ScalingPerks.Length)
		perks += akCaster.HasPerk(Skill_ScalingPerks[i]) as Int
		i += 1
	EndWhile
	temp = akCaster.GetAV(CasterSkill)+Skill_Offset
	chance /= (Math.sqrt(perks) * temp * Math.sqrt(temp))
	temp = akTarget.GetAV("MagicResist")
	chance += temp * Math.sqrt(Math.abs(temp)) / 100.0
	chance /= 1.0 + 0.5 * akTarget.HasMagicEffectWithKeyword(MindFogEffect) as Float
	temp = ((akTarget.GetLevel() as float)/10.0)
	XPRate *= 0.25 + temp * Math.sqrt(temp) + 0.01 * (chance/2.0) * Math.sqrt(chance/2.0)
	If ( (random < chance && !InverseFunction) || (random > chance && InverseFunction) )
		If (Basespell != None)
			akTarget.DispelSpell(BaseSpell)
		Else
			Self.Dispel()
		EndIf
		If !NoAssault
			akTarget.SendAssaultAlarm()
		EndIf
	Else
		If ( MindEffect != None )
			MindEffect.Cast(akCaster, akTarget)
		EndIf
		grantxp = ( akCaster == Game.GetPlayer() && XPRate > 0)
		If ( grantxp )
			Game.AdvanceSkill("Illusion", XPRate)
		EndIf
		If (!singleresist)
			RegisterForSingleUpdate(UpdateInterval)
		EndIf
	EndIf
EndEvent

Event OnUpdate()
	float random = Utility.RandomFloat(0,100)
	If ( GetTargetActor().IsDead() || ((random < chance && !InverseFunction) || \
	         (random > chance && InverseFunction) ))
		If (MindEffect != None)
			GetTargetActor().DispelSpell(MindEffect)
		EndIf
		If (Basespell != None)
			GetTargetActor().DispelSpell(BaseSpell)
		Else
			Self.Dispel()
		EndIf
	Else
		RegisterForSingleUpdate(UpdateInterval)
		If ( grantxp )
			Game.AdvanceSkill("Illusion", XPRate)
		EndIf
	EndIf
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
	If (MindEffect != None)
		akTarget.DispelSpell(MindEffect)
	EndIf
	If (Basespell != None)
		akTarget.DispelSpell(BaseSpell)
	EndIf
EndEvent
