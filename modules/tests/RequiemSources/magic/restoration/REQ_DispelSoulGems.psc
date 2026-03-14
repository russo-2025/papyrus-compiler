ScriptName REQ_DispelSoulGems Extends ActiveMagicEffect  
{Dispel souls from self and pre-filled soul gems}

SoulGem Property SoulGemPetty Auto
SoulGem Property SoulGemPettyFilled Auto
SoulGem Property SoulGemLesser Auto
SoulGem Property SoulGemLesserFilled Auto
SoulGem Property SoulGemCommon Auto
SoulGem Property SoulGemCommonFilled Auto
SoulGem Property SoulGemGreater Auto
SoulGem Property SoulGemGreaterFilled Auto
SoulGem Property SoulGemGrand Auto
SoulGem Property SoulGemGrandFilled Auto
SoulGem Property SoulGemBlack Auto
SoulGem Property SoulGemBlackFilled Auto
SoulGem Property SoulTomatoPetty Auto
SoulGem Property SoulTomatoPettyFilled Auto
SoulGem Property SoulTomatoLesser Auto
SoulGem Property SoulTomatoLesserFilled Auto
SoulGem Property SoulTomatoCommon Auto
SoulGem Property SoulTomatoCommonFilled Auto
SoulGem Property SoulTomatoGreater Auto
SoulGem Property SoulTomatoGreaterFilled Auto
SoulGem Property SoulTomatoGrand Auto
SoulGem Property SoulTomatoGrandFilled Auto
SoulGem Property SoulTomatoBlack Auto
SoulGem Property SoulTomatoBlackFilled Auto
SoulGem Property AzurasStar Auto
SoulGem Property BlackStar Auto


Event OnEffectStart(Actor akTarget, Actor akCaster)
	Int CountPetty = akCaster.GetItemCount(SoulgemPetty)
	Int CountPettyFilled = akCaster.GetItemCount(SoulgemPettyFilled)
	Int CountLesser = akCaster.GetItemCount(SoulgemLesser)
	Int CountLesserFilled = akCaster.GetItemCount(SoulgemLesserFilled)
	Int CountCommon = akCaster.GetItemCount(SoulgemCommon)
	Int CountCommonFilled = akCaster.GetItemCount(SoulgemCommonFilled)
	Int CountGreater = akCaster.GetItemCount(SoulgemGreater)
	Int CountGreaterFilled = akCaster.GetItemCount(SoulgemGreaterFilled)
	Int CountGrand = akCaster.GetItemCount(SoulgemGrand)
	Int CountGrandFilled = akCaster.GetItemCount(SoulgemGrandFilled)
	Int CountBlack = akCaster.GetItemCount(SoulgemBlack)
	Int CountBlackFilled = akCaster.GetItemCount(SoulgemBlackFilled)
	Int CountTomatoPetty = akCaster.GetItemCount(SoulTomatoPetty)
	Int CountTomatoPettyFilled = akCaster.GetItemCount(SoulTomatoPettyFilled)
	Int CountTomatoLesser = akCaster.GetItemCount(SoulTomatoLesser)
	Int CountTomatoLesserFilled = akCaster.GetItemCount(SoulTomatoLesserFilled)
	Int CountTomatoCommon = akCaster.GetItemCount(SoulTomatoCommon)
	Int CountTomatoCommonFilled = akCaster.GetItemCount(SoulTomatoCommonFilled)
	Int CountTomatoGreater = akCaster.GetItemCount(SoulTomatoGreater)
	Int CountTomatoGreaterFilled = akCaster.GetItemCount(SoulTomatoGreaterFilled)
	Int CountTomatoGrand = akCaster.GetItemCount(SoulTomatoGrand)
	Int CountTomatoGrandFilled = akCaster.GetItemCount(SoulTomatoGrandFilled)
	Int CountTomatoBlack = akCaster.GetItemCount(SoulTomatoBlack)
	Int CountTomatoBlackFilled = akCaster.GetItemCount(SoulTomatoBlackFilled)
	Int CountAzurasStar = akCaster.GetItemCount(AzurasStar)
	Int CountBlackStar = akCaster.GetItemCount(BlackStar)

	akCaster.RemoveItem(SoulGemPetty, CountPetty, True)
	akCaster.RemoveItem(SoulGemPettyFilled, CountPettyFilled, True)
	akCaster.RemoveItem(SoulGemLesser, CountLesser, True)
	akCaster.RemoveItem(SoulGemLesserFilled, CountLesserFilled, True)
	akCaster.RemoveItem(SoulGemCommon, CountCommon, True)
	akCaster.RemoveItem(SoulGemCommonFilled, CountCommonFilled, True)
	akCaster.RemoveItem(SoulGemGreater, CountGreater, True)
	akCaster.RemoveItem(SoulGemGreaterFilled, CountGreaterFilled, True)
	akCaster.RemoveItem(SoulGemGrand, CountGrand, True)
	akCaster.RemoveItem(SoulGemGrandFilled, CountGrandFilled, True)
	akCaster.RemoveItem(SoulGemBlack, CountBlack, True)
	akCaster.RemoveItem(SoulGemBlackFilled, CountBlackFilled, True)
	akCaster.RemoveItem(SoulTomatoPetty, CountTomatoPetty, True)
	akCaster.RemoveItem(SoulTomatoPettyFilled, CountTomatoPettyFilled, True)
	akCaster.RemoveItem(SoulTomatoLesser, CountTomatoLesser, True)
	akCaster.RemoveItem(SoulTomatoLesserFilled, CountTomatoLesserFilled, True)
	akCaster.RemoveItem(SoulTomatoCommon, CountTomatoCommon, True)
	akCaster.RemoveItem(SoulTomatoCommonFilled, CountTomatoCommonFilled, True)
	akCaster.RemoveItem(SoulTomatoGreater, CountTomatoGreater, True)
	akCaster.RemoveItem(SoulTomatoGreaterFilled, CountTomatoGreaterFilled, True)
	akCaster.RemoveItem(SoulTomatoGrand, CountTomatoGrand, True)
	akCaster.RemoveItem(SoulTomatoGrandFilled, CountTomatoGrandFilled, True)
	akCaster.RemoveItem(SoulTomatoBlack, CountTomatoBlack, True)
	akCaster.RemoveItem(SoulTomatoBlackFilled, CountTomatoBlackFilled, True)
	akCaster.RemoveItem(AzurasStar, CountAzurasStar, True)
	akCaster.RemoveItem(BlackStar, CountBlackStar, True)

	akCaster.AddItem(SoulgemPetty, CountPetty + CountPettyFilled, True)
	akCaster.AddItem(SoulgemLesser, CountLesser + CountLesserFilled, True)
	akCaster.AddItem(SoulgemCommon, CountCommon + CountCommonFilled, True)
	akCaster.AddItem(SoulgemGreater, CountGreater + CountGreaterFilled, True)
	akCaster.AddItem(SoulgemGrand, CountGrand + CountGrandFilled, True)
	akCaster.AddItem(SoulgemBlack, CountBlack + CountBlackFilled, True)
	akCaster.AddItem(SoulTomatoPetty, CountTomatoPetty + CountTomatoPettyFilled, True)
	akCaster.AddItem(SoulTomatoLesser, CountTomatoLesser + CountTomatoLesserFilled, True)
	akCaster.AddItem(SoulTomatoCommon, CountTomatoCommon + CountTomatoCommonFilled, True)
	akCaster.AddItem(SoulTomatoGreater, CountTomatoGreater + CountTomatoGreaterFilled, True)
	akCaster.AddItem(SoulTomatoGrand, CountTomatoGrand + CountTomatoGrandFilled, True)
	akCaster.AddItem(SoulTomatoBlack, CountTomatoBlack + CountTomatoBlackFilled, True)
	akCaster.AddItem(AzurasStar, CountAzurasStar, True)
	akCaster.AddItem(BlackStar, CountBlackStar, True)

	Int SoulSizeSum = 0
	SoulSizeSum += (CountPettyFilled + CountTomatoPettyFilled) * 250
	SoulSizeSum += (CountLesserFilled + CountTomatoLesserFilled) * 500
	SoulSizeSum += (CountCommonFilled + CountTomatoCommonFilled) * 1000
	SoulSizeSum += (CountGreaterFilled + CountTomatoGreaterFilled) * 2000
	SoulSizeSum += (CountGrandFilled + CountTomatoGrandFilled) * 3000
	Game.AdvanceSkill("Restoration", SoulSizeSum * 0.2)
EndEvent
