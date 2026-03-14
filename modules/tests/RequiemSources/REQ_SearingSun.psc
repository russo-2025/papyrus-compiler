ScriptName REQ_SearingSun Extends ActiveMagicEffect

Spell Property SearingSunDamage Auto


Event OnEffectStart(Actor akTarget, Actor akCaster)
	ApplySunDamage(akTarget)
	RegisterForUpdate(60.0)
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
	akTarget.DispelSpell(SearingSunDamage)
EndEvent

Event OnUpdate()
	ApplySunDamage(GetTargetActor())
EndEvent

Function ApplySunDamage(Actor akTarget)
	Float WeatherFactor = CalculateWeatherFactor()
	If akTarget == Game.GetPlayer()	
		Float Damage = GetMagnitude() * WeatherFactor
		SearingSunDamage.SetNthEffectMagnitude(0, Damage)
		SearingSunDamage.SetNthEffectMagnitude(1, Damage)
		SearingSunDamage.SetNthEffectMagnitude(2, Damage)
	Else
		Float HealthDamage = GetTotalDamageToNpc(akTarget, "Health", WeatherFactor)
		Float MagickaDamage = GetTotalDamageToNpc(akTarget, "Magicka", WeatherFactor)
		Float StaminaDamage = GetTotalDamageToNpc(akTarget, "Stamina", WeatherFactor)
		SearingSunDamage.SetNthEffectMagnitude(0, HealthDamage / 60.0)
		SearingSunDamage.SetNthEffectMagnitude(1, MagickaDamage / 60.0)
		SearingSunDamage.SetNthEffectMagnitude(2, StaminaDamage / 60.0)
	EndIf
	SearingSunDamage.Cast(akTarget, akTarget)
EndFunction

Float Function CalculateWeatherFactor()
	Float SunDamage = Weather.GetCurrentWeather().GetSunDamage()
	Float WeatherFactor = SunDamage

	; Reduce damage at dawn/dusk (5:00-7:30 and 17:30-19:00) because the sun
	; is weaker during those hours, but the weather parameters don't reflect that
	Float CurrentGameTime = Utility.GetCurrentGameTime()
	Float GameHour = (CurrentGameTime - Math.Floor(CurrentGameTime)) * 24
	If GameHour < 7.5 || GameHour > 17.5
		WeatherFactor *= 0.5
	EndIf

	Return WeatherFactor
EndFunction

Float Function GetTotalDamageToNpc(Actor akTarget, String asAttribute, Float afWeatherFactor)
	Float MaxValue = akTarget.GetActorValueMax(asAttribute)
	Float CurrValue = akTarget.GetActorValue(asAttribute)
	Float TargetValue = MaxValue * (1 - 0.65 * afWeatherFactor)
	Float Damage = CurrValue - TargetValue
	If Damage < 0.0
		Return 0.0
	Else
		Return Damage
	EndIf
EndFunction
