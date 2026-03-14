Scriptname VampireSunISMDEffectScript extends ActiveMagicEffect  

imageSpaceModifier Property VampireSunlightISMD01  Auto
imageSpaceModifier Property VampireSunlightISMD02  Auto 
imageSpaceModifier Property VampireSunlightISMD03  Auto 
imageSpaceModifier Property VampireSunlightISMD04  Auto 
Message Property VampireSunMessage Auto

int property VampirismLevel = 1 auto

event OnEffectStart(Actor akTarget, Actor akCaster)
	if aktarget == game.getPlayer()
		if PlayerVampireQuest.VampireStatus == 1
			VampireSunlightISMD01.applyCrossFade(2.0)
		elseif PlayerVampireQuest.VampireStatus == 2
			VampireSunlightISMD02.applyCrossFade(2.0)
		elseif PlayerVampireQuest.VampireStatus == 3
			VampireSunlightISMD03.applyCrossFade(2.0)
		elseif PlayerVampireQuest.VampireStatus == 4
			VampireSunlightISMD04.applyCrossFade(2.0)
		endif
		MagVampireSunlight.Play(akTarget)
	endif
endEvent


event OnEffectFinish(Actor akTarget, Actor akCaster)
	if aktarget == game.getPlayer()
		imageSpaceModifier.removeCrossFade(2.0)
	endif
endEvent

Sound Property MagVampireSunlight  Auto  

PlayerVampireQuestScript Property PlayerVampireQuest  Auto  
