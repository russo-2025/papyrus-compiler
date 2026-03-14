ScriptName REQ_Alteration_TransmuteCorpus Extends ActiveMagicEffect


Activator Property DefaultAshPileGhost Auto

EffectShader Property GhostDeathFXShader Auto

FormList Property ImmunityList Auto

GlobalVariable Property EssentialNPCs Auto

Ingredient Property Ectoplasm Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
	If IsImmune(akTarget)
		Return
	EndIf

	If EssentialNPCs.GetValue()
		akTarget.Kill(akCaster)
	Else
		akTarget.KillEssential(akCaster)
	EndIf

	If akTarget.IsDead()
		akTarget.SetCriticalStage(akTarget.CritStage_DisintegrateStart)
		GhostDeathFXShader.Play(akTarget, 0.15)
		akTarget.AttachAshPile(DefaultAshPileGhost)
		akTarget.SetCriticalStage(akTarget.CritStage_DisintegrateEnd)
		akTarget.AddItem(Ectoplasm, 3)
	EndIf
EndEvent

Bool Function IsImmune(Actor Target)
	ActorBase TargetBase = Target.GetBaseObject() As ActorBase
	Race TargetRace = TargetBase.GetRace()
	Return ImmunityList.HasForm(TargetRace) || ImmunityList.HasForm(TargetBase)
EndFunction
