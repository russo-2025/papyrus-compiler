Scriptname _oSpellTog extends activemagiceffect  

Spell property xToggleSpell auto

function OnEffectStart(Actor xTARG, Actor xCAST)

	if xTARG.HasSpell(xToggleSpell as form)
		xTARG.RemoveSpell(xToggleSpell)
	else
		xTARG.AddSpell(xToggleSpell, false)
	endIf
endFunction