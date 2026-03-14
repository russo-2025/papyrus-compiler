Scriptname C01QuestScript extends CompanionsStoryQuest conditional

ReferenceAlias Property Observer auto

bool Property PlayerWalkedAwayFromFromOffer auto conditional

bool Property ObserverTransform auto conditional
bool Property DogsOutOfTheBag auto conditional
bool Property ObserverCloseBy auto conditional
ObjectReference Property ObserverCompensationPoint auto conditional
Scene Property ObserverGoesNuts auto
Message Property TempMessage auto
ReferenceAlias Property DebugFollower auto ; on remote quest
bool Property ObserverReadyForReveal auto conditional
Quest Property C02Kicker auto
bool Property SkjorGaveLowdown auto conditional

bool Property ObserverDismissed auto conditional
bool Property AmbushLeverPulled auto conditional

bool Property PlayerInAmbushSpace auto conditional
Idle Property IdleWerewolfTransformation auto
Race Property WerewolfRace auto
ReferenceAlias Property ObserverLycanStorage auto
Scene Property AmbushScene auto
Scene Property PostAmbush auto
Outfit Property AelaOutfit auto
Outfit Property FarkasOutfit auto
Actor Property Aela auto
Actor Property Farkas auto


ReferenceAlias Property AmbushFighter1 auto
ReferenceAlias Property AmbushFighter2 auto
ReferenceAlias Property AmbushFighter3 auto
ReferenceAlias Property AmbushFighter4 auto
ReferenceAlias Property AmbushFighter5 auto

Faction Property SilverHandFaction auto
Faction Property SilverHandFactionPacified auto
Faction Property dunPrisonerFaction auto

Weapon Property AelaBaseMeleeWeapon auto
Weapon Property AelaBaseRangedWeapon auto
Weapon Property FarkasBaseMeleeWeapon auto
Weapon Property FarkasBaseRangedWeapon auto
Keyword Property WeapTypeBow auto

Spell Property WerewolfChangeFX auto
Armor Property WolfSkinFXArmor auto

bool Property DoRealTransform = false auto
bool Property FakeFight = true auto

bool __observerWeaponWasBow = false
Race __observerOriginalRace = None ; should always be Nord, but we don't know for sure

Weapon __observerWeapon

Function Init()
	Actor selectedObserver = (CentralQuest as CompanionsHousekeepingScript).GetFavoriteQuestgiver()
	
	; it's always Farkas now
	selectedObserver = (CentralQuest as CompanionsHousekeepingScript).Farkas.GetActorReference()

	Observer.ForceRefTo(selectedObserver)
	(CentralQuest as CompanionsHousekeepingScript).TrialObserver.ForceRefTo(Observer.GetReference())
	DebugFollower.ForceRefTo(selectedObserver)

	Actor af1 = AmbushFighter1.GetActorReference()
	Actor af2 = AmbushFighter2.GetActorReference()
	Actor af3 = AmbushFighter3.GetActorReference()
	Actor af4 = AmbushFighter4.GetActorReference()
	Actor af5 = AmbushFighter5.GetActorReference()

	af1.AddToFaction(SilverHandFactionPacified)
	af2.AddToFaction(SilverHandFactionPacified)
	af3.AddToFaction(SilverHandFactionPacified)
	af4.AddToFaction(SilverHandFactionPacified)
	af5.AddToFaction(SilverHandFactionPacified)
	af1.AddToFaction(dunPrisonerFaction)
	af2.AddToFaction(dunPrisonerFaction)
	af3.AddToFaction(dunPrisonerFaction)
	af4.AddToFaction(dunPrisonerFaction)
	af5.AddToFaction(dunPrisonerFaction)

	af1.RemoveFromFaction(SilverHandFaction)
	af2.RemoveFromFaction(SilverHandFaction)
	af3.RemoveFromFaction(SilverHandFaction)
	af4.RemoveFromFaction(SilverHandFaction)
	af5.RemoveFromFaction(SilverHandFaction)
EndFunction

Function PlayerEnteredAmbushZone(bool entered)
	if (entered)
		PlayerInAmbushSpace = true
		Observer.GetActorReference().SetPlayerTeammate(false, false)
		Observer.GetActorReference().EvaluatePackage()
	else ; exited
		PlayerInAmbushSpace = false
		Observer.GetActorReference().SetPlayerTeammate(true, false)
		Observer.GetActorReference().EvaluatePackage()
	endif
EndFunction

Function AmbushPrep()
	Actor obs = Observer.GetActorReference()
	obs.ResetHealthAndLimbs()
	obs.SetGhost(true)

	Actor af1 = AmbushFighter1.GetActorReference()
	Actor af2 = AmbushFighter2.GetActorReference()
	Actor af3 = AmbushFighter3.GetActorReference()
	Actor af4 = AmbushFighter4.GetActorReference()
	Actor af5 = AmbushFighter5.GetActorReference()

	af1.Enable()
	af2.Enable()
	af3.Enable()
	af4.Enable()
	af5.Enable()

	af1.SetGhost(true)
	af2.SetGhost(true)
	af3.SetGhost(true)
	af4.SetGhost(true)
	af5.SetGhost(true)

	af1.SetLookAt(obs, true)
	af2.SetLookAt(obs, true)
	af3.SetLookAt(obs, true)
	af4.SetLookAt(obs, true)
	af5.SetLookAt(obs, true)
EndFunction

Function FightStart()
	Actor af1 = AmbushFighter1.GetActorReference()
	Actor af2 = AmbushFighter2.GetActorReference()
	Actor af3 = AmbushFighter3.GetActorReference()
	Actor af4 = AmbushFighter4.GetActorReference()
	Actor af5 = AmbushFighter5.GetActorReference()
	Actor obs = Observer.GetActorReference()

	af1.RemoveFromFaction(SilverHandFactionPacified)
	af2.RemoveFromFaction(SilverHandFactionPacified)
	af3.RemoveFromFaction(SilverHandFactionPacified)
	af4.RemoveFromFaction(SilverHandFactionPacified)
	af5.RemoveFromFaction(SilverHandFactionPacified)
	af1.RemoveFromFaction(dunPrisonerFaction)
	af2.RemoveFromFaction(dunPrisonerFaction)
	af3.RemoveFromFaction(dunPrisonerFaction)
	af4.RemoveFromFaction(dunPrisonerFaction)
	af5.RemoveFromFaction(dunPrisonerFaction)
	af1.SetGhost(false)
	af2.SetGhost(false)
	af3.SetGhost(false)
	af4.SetGhost(false)
	af5.SetGhost(false)

	af1.AddToFaction(SilverHandFaction)
	af2.AddToFaction(SilverHandFaction)
	af3.AddToFaction(SilverHandFaction)
	af4.AddToFaction(SilverHandFaction)
	af5.AddToFaction(SilverHandFaction)

	af1.StartCombat(obs)
	af2.StartCombat(obs)
	af3.StartCombat(obs)
	af4.StartCombat(obs)
	af5.StartCombat(obs)

	obs.StartCombat(af3)

	; temp
	if (FakeFight)
		Debug.MessageBox("TEMP: Werewolves are awesome; fight ends.")
		af1.ForceAV("health", 1)
		af2.ForceAV("health", 1)
		af3.ForceAV("health", 1)
		af4.ForceAV("health", 1)
		af5.ForceAV("health", 1)

		Utility.Wait(0.5)
		af1.Kill(obs)
		Utility.Wait(0.5)
		af2.Kill(obs)
		Utility.Wait(0.5)
		af3.Kill(obs)
		Utility.Wait(0.5)
		af4.Kill(obs)
		Utility.Wait(0.5)
		af5.Kill(obs)
	else
		af1.ForceAV("health", 1)
		af2.ForceAV("health", 1)
		af3.ForceAV("health", 1)
		af4.ForceAV("health", 1)
		af5.ForceAV("health", 1)
	endif

	AmbushFighter1.GetActorReference().ClearLookAt()
	AmbushFighter2.GetActorReference().ClearLookAt()
	AmbushFighter3.GetActorReference().ClearLookAt()
	AmbushFighter4.GetActorReference().ClearLookAt()
	AmbushFighter5.GetActorReference().ClearLookAt()

EndFunction

Function ObserverDropWeapon()
	Actor obs = Observer.GetActorReference()
	__observerWeapon = obs.GetEquippedWeapon()
	obs.UnequipItem(__observerWeapon)
	if (__observerWeapon.HasKeyword(WeapTypeBow))
		__observerWeaponWasBow = true
	endif
EndFunction

Function ObserverDoTransform()
; 	Debug.Trace("C01: Observer starting transform...")
	Actor obs = Observer.GetActorReference()
	__observerOriginalRace = obs.GetActorBase().GetRace()
	obs.GetActorBase().SetInvulnerable(true)

	WerewolfChangeFX.Cast(obs)

	RegisterForAnimationEvent(obs, "SetRace")
	Utility.Wait(10)
    ObserverActuallyTransform()
EndFunction

bool __transformTracked = false

Function ObserverActuallyTransform()
	if (__transformTracked)
		; transformation already happened from FX spell
		return
	endif

	__transformTracked = true
	
    ObserverTransform = False
	DogsOutOfTheBag = True
	AmbushScene.Stop() ; just to make sure
	FightStart()
EndFunction

Function ObserverTurnBack()
	if (Observer.GetActorReference().GetActorBase().GetRace() == WerewolfRace)
		Actor obs = Observer.GetActorReference()
; 		Debug.Trace("C01: Setting race " + __observerOriginalRace + " on " + obs)
		obs.SetRace(__observerOriginalRace)
		; Remove the Transformation effect armor if they have it on.
		if (obs.GetItemCount(WolfSkinFXArmor) > 0) 
			(obs.Removeitem(WolfSkinFXArmor,1,True,none))
		endif
		__observerOriginalRace = None
		ObserverLycanStorage.GetReference().RemoveAllItems(Observer.GetActorReference())
		if     (obs == Aela)
			obs.SetOutfit(AelaOutfit)
		elseif (obs == Farkas)
			obs.SetOutfit(FarkasOutfit)
		endif
		; By the grace of Todd Howard the observer appears naked unless any newly created item is added to his or her inventory
		obs.AddItem(WolfSkinFXArmor)
		obs.RemoveItem(WolfSkinFXArmor)
		obs.EquipItem(__observerWeapon)
	endif

	Observer.GetActorReference().SetPlayerTeammate(true)
EndFunction

Event OnAnimationEvent(ObjectReference akSource, string asEventName)
    if (asEventName == "SetRace" && akSource == Observer.GetReference())
        ObserverActuallyTransform()
    endif
EndEvent

Function AmbusherKilled()
	if ( \
		   AmbushFighter1.GetActorReference().IsDead() \
		&& AmbushFighter2.GetActorReference().IsDead() \
		&& AmbushFighter3.GetActorReference().IsDead() \
		&& AmbushFighter4.GetActorReference().IsDead() \
		&& AmbushFighter5.GetActorReference().IsDead() \
	)
		Observer.GetActorReference().GetActorBase().SetInvulnerable(false)
		Observer.GetActorReference().SetGhost(false)
		Observer.GetActorReference().StopCombatAlarm()
		Game.GetPlayer().StopCombatAlarm()
		PostAmbush.Start()
	endif
EndFunction

Function Teardown()
	(CentralQuest as CompanionsHousekeepingScript).DustmansCairn.Clear()
	; C02Kicker.Start()
	DebugFollower.Clear()
	parent.Teardown()
EndFunction
