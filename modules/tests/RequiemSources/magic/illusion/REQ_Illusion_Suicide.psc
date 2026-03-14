ScriptName REQ_Illusion_Suicide Extends ActiveMagicEffect  

MagicEffect Property Dualcast Auto
{Dualcast-Dummyeffect, if present, skip wrist cutting and die instantly}
Idle Property IdleHandCut auto
{Only a form can be used with PlayIdle and we need PlayIdle to know if they cut their wrist}
GlobalVariable Property EssentialNPCs Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
	Utility.Wait(0.5)
	If (!akTarget.HasMagicEffect(Dualcast))
		Int i = 1
		While i <= 15 && akTarget.GetAnimationVariableBool("bAnimationDriven") ; Wait until they are out of any animation
			Utility.Wait(3.0)
			i += 1
		EndWhile
		akTarget.PlayIdle(IdleHandCut)
		Utility.Wait(0.5)
		If !akTarget.PlayIdle(IdleHandCut)  ; Don't kill akTargets that can't or won't cut their wrist
			Return
		EndIf
	EndIf
	akTarget.SetUnconscious(True)
	Utility.Wait(4.0)
	If EssentialNPCs.GetValue()
		akTarget.Kill(akTarget)
	Else
		akTarget.KillEssential(akTarget)
	EndIf
	akTarget.SetUnconscious(False)
EndEvent
