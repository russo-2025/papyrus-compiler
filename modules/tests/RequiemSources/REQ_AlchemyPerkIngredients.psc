Scriptname REQ_AlchemyPerkIngredients extends ActiveMagicEffect
{attached to effects that remove ingredients required for Alchemy perks}

Form[] Property Ingredients Auto
Spell Property RemoveWhenDone Auto ; remove this ability once finished (optional, used for dummy abilities)
Bool Property Silent = False Auto ; notify that items are being removed (optional)

Event OnEffectStart(Actor akTarget, Actor akCaster)
	If UI.IsMenuOpen("StatsMenu") && akTarget == Game.GetPlayer()
		Int i = 0
		While i < Ingredients.Length
			akTarget.RemoveItem(Ingredients[i], 1, Silent)
			i += 1
		EndWhile
	EndIf
	If RemoveWhenDone
		akTarget.RemoveSpell(RemoveWhenDone)
	EndIf
EndEvent