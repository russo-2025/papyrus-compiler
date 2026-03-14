Scriptname DA15WabbajackEffectSCRIPT extends ActiveMagicEffect  

ActorBase Property Dog Auto
ActorBase Property Goat Auto

Spell Property FearSpell Auto
Spell Property IceForm Auto

Potion Property CheeseSlice Auto
Potion Property CheeseWheel Auto
Potion Property CheeseWedge Auto


; the gold
MISCOBJECT PROPERTY gold AUTO

; the sweet roll
POTION PROPERTY sweetRoll AUTO
MISCOBJECT PROPERTY plate AUTO

; the heal spell
SPELL PROPERTY healSpell AUTO

; invisibilty spell
SPELL PROPERTY invis AUTO

; the fire/frost/storm spell
EXPLOSION PROPERTY fireSpell AUTO
EXPLOSION PROPERTY frostSpell AUTO
EXPLOSION PROPERTY stormSpell AUTO

; a skeever
ACTORBASE PROPERTY skeever AUTO
ACTORBASE PROPERTY wolf AUTO
ACTORBASE PROPERTY bandit AUTO
ACTORBASE PROPERTY draugr AUTO
ACTORBASE PROPERTY falmer AUTO
ACTORBASE PROPERTY dragonPriest AUTO
ACTORBASE PROPERTY atronach AUTO

; ally
FACTION PROPERTY playerFaction AUTO

; //THE STUFF FOR THE EXPLOSION
EXPLOSION PROPERTY forceExplosion AUTO
EXPLOSION PROPERTY visualExplosion AUTO

OBJECTREFERENCE PROPERTY explosionMarker AUTO
EFFECTSHADER PROPERTY wabbaHitEffect AUTO

SPELL PROPERTY ghostSpell AUTO

INT randEffect=0
ACTORBASE ghostNPC
OBJECTREFERENCE npcChanged
OBJECTREFERENCE newCreature

KEYWORD PROPERTY keyWabbajackExcluded Auto
KEYWORD PROPERTY keyGiant AUTO
KEYWORD PROPERTY keyDragon AUTO

; //TRANSMOGRIFY VARIABLES
OBJECTREFERENCE objStore
OBJECTREFERENCE newRefStore
ACTORBASE PROPERTY chicken AUTO
ACTORBASE PROPERTY mudcrab AUTO
ACTORBASE PROPERTY rabbit AUTO
ACTORBASE PROPERTY dremora AUTO
dunTransmogrifyAnimal mainScript

; //WE madwoman
ACTORBASE PROPERTY madWoman AUTO

; //////////
; //ASH PILE VARIABLES
; //////////
float property fDelay = 0.75 auto
{time to wait before Spawning Ash Pile}
float property fDelayEnd = 1.65 auto
{time to wait before Removing Base Actor}
float property ShaderDuration = 0.00 auto
{Duration of Effect Shader.}
Activator property pDefaultAshPileGhost auto
{The object we use as a pile.}
Bool property bSetAlphaZero = True auto
{The Effect Shader we want.}
FormList Property pDisintegrationMainImmunityList auto
{If the target is in this list, they will not be disintegrated.}
EFFECTSHADER PROPERTY pGhostDeathFXShader AUTO
{the shader to play while dying}

race VictimRace
ACTOR victim
bool TargetIsImmune = True

EVENT onEffectStart(Actor akTarget, Actor akCaster)

	victim = akTarget

	IF(akCaster == game.getPlayer())
	
		randEffect = utility.randomInt(0, 99)
		explosionMarker.moveTo(akTarget)
		
		IF(akTarget.hasKeyword(keyWabbajackExcluded))
			randEffect = 1
		ELSEIF(akTarget.hasKeyword(keyDragon))
			randEffect = 1
		ELSEIF(akTarget.isCommandedActor())
			randEffect = 1
		ELSEIF(akTarget.getBaseObject() == madwoman)
			randEffect = 60
		ENDIF

		; /////////////
		; //CHOOSE WHAT WE'RE RANDOMLY DOING
		IF(randEffect < 30)
			elementalEffect(akTarget)

		ELSEIF(randEffect < 35)
			hsmTransfer(akTarget)

		ELSEIF(randEffect < 40)
			akTarget.placeAtMe(fireSpell)
			akTarget.placeAtMe(Dog, 3)

		ELSEIF(randEffect < 45)
			akTarget.placeAtMe(fireSpell)
			akTarget.placeAtMe(Goat, 5)
		ELSEIF(randEffect < 50)
			randomCreatureChicken(akTarget)

		ELSEIF(randEffect < 55)
			randomCreatureDremora(akTarget)

		ELSEIF(randEffect < 60)
			randomCreatureMudcrab(akTarget)

		ELSEIF(randEffect < 65)
			randomCreatureRabbit(akTarget)

		ELSEIF(randEffect < 70)
			akTarget.UnequipAll()
			FearSpell.Cast(akTarget, akTarget)
			
		ELSEIF(randEffect < 75)
			invis.cast(akTarget, akTarget)

		ELSEIF(randEffect < 80)
			healSpell.cast(akTarget, akTarget)

		ELSEIF(randEffect < 85)
			IceForm.Cast(akCaster, akTarget)

		ELSEIF(randEffect < 90)
			spawnGold(akTarget)

		ELSEIF(randEffect < 95)
			spawnSweetRoll(akTarget)

		ELSE
			spawnCheese(akTarget)
		ENDIF
		
		
	ENDIF

ENDEVENT

FUNCTION basicDamage(ACTOR targ)

ENDFUNCTION

FUNCTION randomCreatureChicken(ACTOR targ)

	targ.disable()
			
	newRefStore = targ.placeAtMe(chicken)
	
	; //setting the master script to be the one with the stored vars
	mainScript = newRefstore AS dunTransmogrifyAnimal
	mainScript.storedActor = targ
	
	targ.stopCombat()
	
ENDFUNCTION

FUNCTION randomCreatureMudcrab(ACTOR targ)

	targ.disable()
			
	newRefStore = targ.placeAtMe(mudcrab)
	
	; //setting the master script to be the one with the stored vars
	mainScript = newRefstore AS dunTransmogrifyAnimal
	mainScript.storedActor = targ
	
	targ.stopCombat()
	
ENDFUNCTION

FUNCTION randomCreatureRabbit(ACTOR targ)

	targ.disable()
			
	newRefStore = targ.placeAtMe(rabbit)
	
	; //setting the master script to be the one with the stored vars
	mainScript = newRefstore AS dunTransmogrifyAnimal
	mainScript.storedActor = targ
	
	targ.stopCombat()
	
ENDFUNCTION

FUNCTION randomCreatureDremora(ACTOR targ)

	targ.disable()
			
	newRefStore = targ.placeAtMe(dremora)
	
	; //setting the master script to be the one with the stored vars
	mainScript = newRefstore AS dunTransmogrifyAnimal
	mainScript.storedActor = targ
	
	targ.stopCombat()
	
ENDFUNCTION

FUNCTION spawnGhostFriend(ACTOR targ)
	
	targ.placeAtMe(visualExplosion)
	
	ACTOR tempNPC = (targ.placeAtMe(targ.getBaseObject()) as ACTOR)
	tempNPC.addSpell(ghostSpell)
	tempNPC.removeFromAllFactions()
	tempNPC.setFactionRank(playerFaction, 5)
	tempNPC.setGhost(TRUE)
			
	utility.wait(10)
	
	explosionMarker.setPosition(tempNPC.x, tempNPC.y, (tempNPC.z + 75))
	tempNPC.placeAtMe(visualExplosion)
	
	utility.wait(0.5)
	
	tempNPC.disable()

ENDFUNCTION

FUNCTION elementalEffect(ACTOR targ)
	
	int rand = utility.randomInt(1,3)
	explosionMarker.setPosition(targ.x, targ.y, (targ.z + 75))
		
	IF(rand == 1)
		targ.placeAtMe(fireSpell)
		targ.damageAV("Health", 60)
	
	ELSEIF(rand == 2)
		targ.placeAtMe(frostSpell)
		targ.damageAV("Health", 60)
	
	ELSEIF(rand == 3)
		targ.placeAtMe(stormSpell)
		targ.damageAV("Health", 60)
	
	ENDIF

ENDFUNCTION

FUNCTION castInvis(ACTOR targ)

	float baseMagicka = targ.getAV("magicka")
	float baseIllusion = targ.getAV("Illusion")
	
	targ.setAV("magicka", 200)
	targ.setAV("Illusion", 200)
	invis.cast(targ, targ)
	
	utility.wait(0.5)
	
	targ.setAV("magicka", baseMagicka)
	targ.setAV("Illusion", baseIllusion)
		
ENDFUNCTION

FUNCTION hsmTransfer(ACTOR targ)
	
	wabbaHitEffect.play(game.getPlayer())
	
	targ.damageAV("health", (targ.getBaseAV("health") * 0.5))
	game.getPlayer().restoreAV("health", (game.getPlayer().getBaseAV("health") * 0.5))

	targ.damageAV("stamina", (targ.getBaseAV("stamina") * 0.5))
	game.getPlayer().restoreAV("stamina", (game.getPlayer().getBaseAV("stamina") * 0.5))

	targ.damageAV("magicka", (targ.getBaseAV("magicka") * 0.5))
	game.getPlayer().restoreAV("magicka", (game.getPlayer().getBaseAV("magicka") * 0.5))
	
	utility.wait(1.5)
	
	wabbaHitEffect.stop(game.getPlayer())

ENDFUNCTION

FUNCTION spawnCheese(ACTOR targ)
	targ.placeAtMe(visualExplosion)
	explosionMarker.setPosition(targ.x, targ.y, (targ.z + 100))
	explosionMarker.placeAtMe(CheeseWheel, Utility.RandomInt(1, 2))
	explosionMarker.placeAtMe(CheeseWedge, Utility.RandomInt(2, 4))
	explosionMarker.placeAtMe(CheeseSlice, Utility.RandomInt(4, 8))
	explosionMarker.placeAtMe(forceExplosion)
ENDFUNCTION

FUNCTION spawnGold(ACTOR targ)
	If targ.GetActorValue("Health") > 300
		Game.GetPlayer().PushActorAway(targ, 20)
	Else
		createAshPile()
		Utility.Wait(0.1)
		explosionMarker.setPosition(targ.x, targ.y, (targ.z + 100))
		explosionMarker.placeAtMe(gold, 150)
		explosionMarker.placeAtMe(forceExplosion)
	EndIf
ENDFUNCTION

FUNCTION spawnSweetRoll(ACTOR targ)
	If targ.GetActorValue("Health") > 300
		Game.GetPlayer().PushActorAway(targ, 20)
	Else
		createAshPile()
		Utility.Wait(0.1)
		explosionMarker.setPosition(targ.x, targ.y, (targ.z + 10))
		explosionMarker.placeAtMe(sweetRoll)
	EndIf
ENDFUNCTION

FUNCTION createAshPile()

	; //check to see if the target is in the immunity list
	IF(pDisintegrationMainImmunityList == none)
		TargetIsImmune = False
	ELSE
		ActorBase VictimBase = victim.GetBaseObject() as ActorBase
		VictimRace = VictimBase.GetRace()
		
		IF(pDisintegrationMainImmunityList.hasform(VictimRace) || pDisintegrationMainImmunityList.hasform(VictimBase))
			TargetIsImmune = True
		ELSE
			TargetIsImmune = False
		ENDIF
	ENDIF

	; //if the target is not immune, disintegrate them
	IF(TargetIsImmune == False)
; 		debug.trace("victim just died")

		
		victim.kill(game.getPlayer())
		victim.SetCriticalStage(victim.CritStage_DisintegrateStart)

		IF(pGhostDeathFXShader != none)
			pGhostDeathFXShader.play(victim,ShaderDuration)
		ENDIF
		
		victim.SetAlpha (0.0,True)
		
		; //attach the ash pile
		victim.AttachAshPile(pDefaultAshPileGhost)
		
		utility.wait(fDelayEnd)
		IF(pGhostDeathFXShader != none)
			pGhostDeathFXShader.stop(victim)
		ENDIF
		IF(bSetAlphaZero == True)
			victim.SetAlpha (0.0,True)
		ENDIF
		victim.SetCriticalStage(victim.CritStage_DisintegrateEnd)
	ENDIF
	
endFUNCTION
