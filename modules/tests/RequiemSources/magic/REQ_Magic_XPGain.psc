ScriptName REQ_Magic_XPGain extends ActiveMagicEffect
{grant continously XP for actively maintained effects}

Float Property XPGain = 0.5 Auto
{XPs earned per Interval} 
Float Property Interval = 1.0 Auto
{update interval in seconds}
String Property Skill Auto
{the skill which should be increased}

Event OnEffectStart(Actor akTarget, Actor akCaster)
	If (akCaster == Game.GetPlayer() && XPGain > 0.0 )
		If Interval > 0.0
			RegisterForSingleUpdate(Interval)
		Else
			Game.AdvanceSkill(Skill, XPGain)
		EndIf
	EndIf
EndEvent

Event OnUpdate()
	Game.AdvanceSkill(Skill, XPGain)
	RegisterForSingleUpdate(Interval)
EndEvent
