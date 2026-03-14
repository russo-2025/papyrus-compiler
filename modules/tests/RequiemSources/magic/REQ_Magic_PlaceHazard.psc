Scriptname REQ_Magic_PlaceHazard extends ActiveMagicEffect
{places a hazard object at the caster's or target's position, enabling hazards to affect the player}

ObjectReference HazardRef
Hazard Property HazardType Auto
{type of hazard to create}
Bool Property PlaceAtCaster = True Auto
{place the hazard at the caster's position? If not, uses target's position.}
Float Property zoffset = 0.0 Auto
{z-offset for the hazard effect}

Event OnEffectStart(Actor Target, Actor Caster)
	If ( PlaceAtCaster )
		HazardRef = Caster.placeatme(HazardType)
	Else
		HazardRef = Target.placeatme(HazardType)
	EndIf
	HazardRef.SetPosition(HazardRef.x, HazardRef.y, HazardRef.z+zoffset)
EndEvent

Event OnEffectFinish(Actor Target, Actor Caster)
	HazardRef.Disable()
	HazardRef.Delete()
EndEvent

Event OnUnload()
	HazardRef.Disable()
	HazardRef.Delete()
EndEvent
