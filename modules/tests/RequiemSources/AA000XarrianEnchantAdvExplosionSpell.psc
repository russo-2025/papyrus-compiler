Scriptname AA000XarrianEnchantAdvExplosionSpell extends ActiveMagicEffect  

SPELL Property NewProperty  Auto  


	Event OnEffectStart(Actor Target, Actor Caster)

		NewProperty.cast(target, target)

EndEvent