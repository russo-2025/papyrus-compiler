Scriptname Req_BendLawOfFirstsScript extends activemagiceffect  

SPELL Property BendConstant  Auto  



Event OnEffectStart(Actor akTarget, Actor akCaster)

	If akcaster.hasspell(BendConstant)
		akcaster.removespell(BendConstant)

	ElseIf akcaster.hasspell(BendConstant) == False
		akcaster.addspell(BendConstant, false)

	EndIf
EndEvent