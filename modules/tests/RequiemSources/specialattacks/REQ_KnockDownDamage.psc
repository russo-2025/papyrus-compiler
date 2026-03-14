Scriptname REQ_KnockdownDamage extends ActiveMagicEffect
{scale the knockdown damage with the enemies armor rating...}

Int Property baseDamage Auto
{base damage of the attack, is scaled by a power of the attacker's mass}
Int Property massPower Auto
{the power attacker's the mass should be scaled with}
Float Property massOffset = 0.0 Auto
{offset for the attackers mass, e.g. while riding a horse}

Event OnEffectStart(actor Target, actor Caster)
	Float mass = Caster.GetAV("mass") + massOffset
	Float damage = baseDamage * Math.pow(mass, massPower)
	Float damageReduction = Target.GetAV("DamageResist") * 0.001
	If (damageReduction > 0.8)
		Target.DamageAV("Health", damage * 0.2 )
    Else
        Target.DamageAV("Health", damage * (1 - damageReduction) )
	EndIf
EndEvent
