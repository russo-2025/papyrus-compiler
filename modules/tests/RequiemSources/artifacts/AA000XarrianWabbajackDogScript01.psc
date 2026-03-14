Scriptname AA000XarrianWabbajackDogScript01 extends ActiveMagicEffect 

Explosion Property Boom  Auto  

Actor selfRef


	EVENT OnEffectStart(Actor Target, Actor Caster)	
		selfRef = caster
EndEvent


	EVENT onDying(actor myKiller)

	selfRef.placeatme(boom)
	selfRef.Disable()
	selfRef.Delete()

EndEvent


