ScriptName OSexIntegrationMain Extends Quest


;		What is this? Am I in the right place? How do I use this???

; This script is the core of OStim. If you want to start OStim scenes and/or manipulate them, you are in the right place

;	Structure of this script
; At the very top here, are the Properties. They are the settings you see in the MCM. You can toggle these at will on this script and it
; will update the MCM and everything. Below that are the OStim local variables, you can safely ignore those. Below those variables,
; you will find OStim's main loop and the StartScene() function. OStim's core logic runs in there, I recommend giving it a read.
; Below that is the UTILITIES area. These functions are going to be very useful to you and will let you access data in OStim as
; well as manipulate the currently running scene. Below the utilities area are some more specific groups of functions.

; Some parts of code, including undressing, on-screen bar, and animation data lookups, are in other scripts to make this script easier to
; read. You can call functions in the below utilities area to return those script objects.

; Want a list of all Events you can register with? CTRL + F this script for "SendModEvent" and you can see them all as well as the exact point they fire
; With the exception of the sound event, OStim events do not include data with them. They only let you know when something has happened. You can access
; OStim and get all of the data you need through the normal API here

; PROTIP: ctrl + F is your best friend when it comes to seeing how and where a function/variable/property/etc is used elsewhere

;			 ██████╗ ███████╗████████╗██╗███╗   ███╗
;			██╔═══██╗██╔════╝╚══██╔══╝██║████╗ ████║
;			██║   ██║███████╗   ██║   ██║██╔████╔██║
;			██║   ██║╚════██║   ██║   ██║██║╚██╔╝██║
;			╚██████╔╝███████║   ██║   ██║██║ ╚═╝ ██║
;			 ╚═════╝ ╚══════╝   ╚═╝   ╚═╝╚═╝     ╚═╝



; -------------------------------------------------------------------------------------------------
; SETTINGS  ---------------------------------------------------------------------------------------


Bool Property EndOnDomOrgasm Auto
Bool Property EndOnSubOrgasm Auto
Bool Property RequireBothOrgasmsToFinish Auto

Bool Property EnableDomBar Auto
Bool Property EnableSubBar Auto
Bool Property EnableThirdBar Auto
Bool Property AutoHideBars Auto
Bool Property MatchBarColorToGender auto
Bool Property HideBarsInNPCScenes auto ; MCM todo

Bool Property EnableImprovedCamSupport Auto

Bool Property EnableActorSpeedControl Auto

Bool Property ResetPosAfterSceneEnd Auto ; mcm todo

Bool Property AllowUnlimitedSpanking Auto

Bool Property AutoUndressIfNeeded Auto
Int Property BedSearchDistance Auto

Int Property SubLightPos Auto
Int Property DomLightPos Auto
Int Property SubLightBrightness Auto
Int Property DomLightBrightness Auto

Bool Property LowLightLevelLightsOnly Auto
Bool Property SlowMoOnOrgasm Auto

Bool Property AlwaysUndressAtAnimStart Auto
Bool Property OnlyUndressChest Auto 		;	Removed in 4.0
Bool Property AlwaysAnimateUndress Auto     ;	Removed in 4.0
Bool Property TossClothesOntoGround Auto
Bool Property UseStrongerUnequipMethod Auto
Bool Property FullyAnimateRedress Auto

bool disableosacontrolsbool

Bool Property DisableOSAControls
	Bool Function Get()
		return disableosacontrolsbool
	EndFunction

	Function Set(Bool var)
		disableosacontrolsbool = var 
		OControl.disableControl = var
	EndFunction
EndProperty

Bool  SpeedUpNonSexAnimation
Float SpeedUpSpeed

Int Property CustomTimescale Auto

Bool Property OrgasmIncreasesRelationship Auto

Float Property SexExcitementMult Auto

Int Property KeyMap Auto

int property FreecamKey auto 

string[] scenemetadata
string[] oldscenemetadata

Int Property SpeedUpKey Auto
Int Property SpeedDownKey Auto
Int Property PullOutKey Auto
Int Property ControlToggleKey Auto

Bool Property UseBed Auto

Bool Property MisallignmentProtection Auto
Bool Property DisablePlayerHitbox Auto

Bool Property UseAIControl Auto
Bool Property OnlyGayAnimsInGayScenes auto
Bool Property PauseAI Auto

Bool Property PlayerAlwaysSubStraight auto ;mcm
Bool Property PlayerAlwaysSubGay Auto
Bool Property PlayerAlwaysDomStraight Auto 
Bool Property PlayerAlwaysDomGay auto

Bool Property UseAINPConNPC Auto
Bool Property UseAIPlayerAggressor Auto
Bool Property UseAIPlayerAggressed Auto
Bool Property UseAINonAggressive Auto
Bool Property UseAIMasturbation Auto

Bool Property MuteOSA Auto

Bool Property FixFlippedAnimations Auto

Bool Property UseFreeCam Auto

Bool Property UseRumble Auto
Bool Property UseScreenShake Auto

Bool Property UseFades Auto
Bool Property UseAutoFades Auto
bool Property SkipEndingFadein Auto

Bool Property EndAfterActorHit Auto

Bool Property GetInBedAfterBedScene Auto

Int Property FreecamFOV Auto
Int Property DefaultFOV Auto
Int Property FreecamSpeed Auto

Int Property BedReallignment Auto

Bool Property ForceFirstPersonAfter Auto

Bool Property UseNativeFunctions Auto
Bool Property BlockVRInstalls Auto

Bool Property UseAlternateBedSearch Auto

Int Property AiSwitchChance Auto

Bool Property DisableStimulationCalculation Auto

Bool property ForceCloseOStimThread auto

Bool SMPInstalled

Bool Property Installed auto

Int[] Property StrippingSlots Auto

Float Property DomScaleHeight Auto
Float Property SubScaleHeight Auto ;adjusting these then calling a rescale will let you control actors scaling heights.
Float Property ThirdScaleHeight Auto
; The default OSA scale heights are set here by default

Bool Property DisableScaling Auto

int Property InstalledVersion Auto

bool property ShowTutorials auto

; -------------------------------------------------------------------------------------------------
; SCRIPTWIDE VARIABLES ----------------------------------------------------------------------------


Actor DomActor
Actor SubActor

String diasa

Float DomExcitement
Float SubExcitement
Float ThirdExcitement

Bool SceneRunning
String CurrentAnimation
Int CurrentSpeed
String[] CurrScene
String CurrAnimClass
String CurrentSceneID

Bool AnimSpeedAtMax
Int SpankCount
Int SpankMax

_oOmni OSAOmni
_oControl OControl

Actor PlayerRef

GlobalVariable Timescale

Bool Property UndressDom Auto
Bool Property UndressSub Auto
Bool Property AnimateUndress Auto
String StartingAnimation
Actor ThirdActor



Bool StallOrgasm

Int DomTimesOrgasm
Int SubTimesOrgasm
Int ThirdTimesOrgasm

Actor MostRecentOrgasmedActor

Bool UsingBed
ObjectReference CurrentBed

Bool property EndedProper auto

Float StartTime

Float MostRecentOSexInteractionTime

Int[] OSexControlKeys

;--Thank you ODatabase
Int CurrentOID ; the OID is the JMap ID of the current animation. You can feed this in to ODatabase
Int LastHubOID
Bool CurrentAnimIsAggressive
;--

Bool property AIRunning auto

Bool AggressiveThemedSexScene
Actor AggressiveActor

OAIScript AI
OBarsScript OBars
OUndressScript OUndress
OStimUpdaterScript OUpdater

Bool IsFlipped

Float DomStimMult
Float SubStimMult
Float ThirdStimMult
; -------------------------------------------------------------------------------------------------
; OSA SPECIFIC  -----------------------------------------------------------------------------------

MagicEffect Actra
Faction OsaFactionStage

ImageSpaceModifier NutEffect


Sound OSADing
Sound OSATickSmall
Sound OSATickBig

;_oUI OSAUI
;---------


Actor ReroutedDomActor
Actor ReroutedSubActor

;--------- database
ODatabaseScript ODatabase
;---------

bool FirstAnimate

;--------- ID shortcuts
;Animation classifications
String ClassSex
String ClassEmbracing
String ClassCunn
String ClassHolding
String ClassApart
String ClassApartUndressing
String ClassApartHandjob
String ClassHandjob
String ClassClitRub
String ClassOneFingerPen
String ClassTwoFingerPen
String ClassBlowjob
String ClassPenisjob
String ClassMasturbate
String ClassRoughHolding
String ClassSelfSuck
String ClassHeadHeldBlowjob
String ClassHeadHeldPenisjob
String ClassHeadHeldMasturbate
String ClassDualHandjob
String Class69Blowjob
String Class69Handjob

String ClassAnal
String ClassBoobjob
String ClassBreastFeeding
String ClassFootjob

;Body parts
Int Penis
Int Vagina
Int Mouth
Int Hand
Int Clit
;extra parts
Int Anus
Int Feet
Int Breasts
Int Prostate

Float[] PenisStimValues
Float[] VaginaStimValues
Float[] MouthStimValues
Float[] HandStimValues
Float[] ClitStimValues

String[] SubMouthOpenClasses
String[] DomMouthOpenClasses

Float[] AnusStimValues
Float[] FeetStimValues
Float[] BreastsStimValues
Float[] ProstateStimValues


bool ReallignedDuringThisAnim

String o
Int Password

quest property subthreadquest auto 

_oUI_Lockwidget LockWidget


; -------------------------------------------------------------------------------------------------
; -------------------------------------------------------------------------------------------------


Event OnInit()
	Console("OStim initializing")
	Startup() ; OStim install script
EndEvent


; Call this function to start a new OStim scene
Bool Function StartScene(Actor Dom, Actor Sub, Bool zUndressDom = False, Bool zUndressSub = False, Bool zAnimateUndress = False, String zStartingAnimation = "", Actor zThirdActor = None, ObjectReference Bed = None, Bool Aggressive = False, Actor AggressingActor = None)
	if !installed 
		debug.Notification("OStim not ready or installation failed")
		return false
	endif 

	If (SceneRunning)
		if IsNPCScene()
			ConvertToSubthread()
		else 
			Debug.Notification("OSA scene already running")
			Return False
		endif 
	EndIf

	If IsActorActive(dom) || (sub && IsActorActive(sub))
		Debug.Notification("One of the actors is already in a OSA scene")
		Return False
	EndIf
	If !dom.Is3DLoaded()
		console("Dom actor is not loaded")
		return false
	EndIf

	; Default OSex gender order
	DomActor = Dom
	SubActor = Sub
	If (SubActor && AppearsFemale(Dom) && !AppearsFemale(Sub)) ; if the dom is female and the sub is male
		DomActor = Sub
		SubActor = Dom
	EndIf


	UndressDom = zUndressDom
	UndressSub = zUndressSub
	AnimateUndress = zAnimateUndress
	StartingAnimation = zStartingAnimation
	ThirdActor = zThirdActor
	PauseAI = False

	If zThirdActor
		If AppearsFemale(ThirdActor) && !AppearsFemale(SubActor)
			SubActor = zThirdActor
			ThirdActor = sub
		EndIf
	EndIf


	If SubActor && IsPlayerInvolved()
		;special reordering settings
		;todo: clean up all of the ordering code around here
		bool gay = (AppearsFemale(dom) == AppearsFemale(sub))
		actor playerPartner = GetSexPartner(playerref)

		if gay 
			if PlayerAlwaysDomGay
				SubActor = playerPartner
				DomActor = playerref
			elseif PlayerAlwaysSubGay
				DomActor = playerPartner
				SubActor = playerref
			endif
		else 
			if PlayerAlwaysSubStraight
				SubActor = playerref 
				DomActor = playerPartner
			elseif PlayerAlwaysDomStraight
				DomActor = playerref 
				SubActor = playerpartner  
			endif 
		endif 
	endif 


	If (Aggressive)
		If (AggressingActor)
			If ((AggressingActor != SubActor) && (AggressingActor != DomActor))
				debug.MessageBox("Programmer:  The aggressing Actor you entered is not part of the scene!")
				Return False
			Else
				AggressiveActor = AggressingActor
				AggressiveThemedSexScene = True
			EndIf
		Else
			Debug.MessageBox("Programmer: Please enter the aggressor in this aggressive animation")
			Return False
		EndIf
	Else
		AggressiveThemedSexScene = False
		AggressiveActor = None
	EndIf

	If (Bed)
		UsingBed = True
		Currentbed = Bed
	Else
		UsingBed = False
	EndIf

	ForceCloseOStimThread = false

	Console("Requesting scene start")
	RegisterForSingleUpdate(0.01) ; start main loop
	SceneRunning = True

	Return True
EndFunction

Event OnUpdate() ;OStim main logic loop
	Console("Starting scene asynchronously")

	If (UseFades && IsPlayerInvolved())
		FadeToBlack()
	EndIf


	If (SubActor)
		If (SubActor.GetParentCell() != DomActor.GetParentCell())
			If (SubActor == playerref)
				Domactor.moveto(SubActor)
			Else
				SubActor.MoveTo(DomActor)
			EndIf
		EndIf
	EndIf

	ToggleActorAI(false)

	SendModEvent("ostim_prestart") ; fires as soon as the screen goes black. be careful, some settings you normally expect may not be set yet. Use ostim_start to run code when the OSA scene begins.

	If (EnableImprovedCamSupport) && IsPlayerInvolved()
		Game.DisablePlayerControls(abCamswitch = True, abMenu = False, abFighting = False, abActivate = False, abMovement = False, aiDisablePOVType = 0)
	EndIf

 

	IsFlipped = False
	StallOrgasm = false
	CurrentSpeed = 0
	DomExcitement = 0.0
	SubExcitement = 0.0
	ThirdExcitement = 0.0
	DomStimMult = 1.0
	SubStimMult = 1.0
	ThirdStimMult = 1.0
	EndedProper = False
	StallOrgasm = False
	NavMenuHidden = false
	BlockDomFaceCommands = False
	BlocksubFaceCommands = False
	BlockthirdFaceCommands = False
	SpankCount = 0
	SubTimesOrgasm = 0
	DomTimesOrgasm = 0
	ThirdTimesOrgasm = 0
	MostRecentOrgasmedActor = None
	SpankMax = osanative.RandomInt(1, 6)
	FirstAnimate = true


	Actor[] Actro
	If (ThirdActor)
		Actro = New Actor[3]
		Actro[2] = ThirdActor
		Actro[1] = SubActor
	ElseIf SubActor
		Actro = New Actor[2]
		Actro[1] = SubActor
	Else
		Actro = new Actor[1]
	EndIf

	RegisterForModEvent("ostim_setvehicle", "OnSetVehicle")
	

	String DomFormID = _oGlobal.GetFormID_S(OSANative.GetLeveledActorBase(DomActor))
	RegisterForModEvent("0SSO" + DomFormID + "_Sound", "OnSoundDom")
	RegisterForModEvent("0SAA" + DomFormID + "_BlendMo", "OnMoDom")
	RegisterForModEvent("0SAA" + DomFormID + "_BlendPh", "OnPhDom")
	RegisterForModEvent("0SAA" + DomFormID + "_BlendEx", "OnExDom")
	If (SubActor)
		String SubFormID = _oGlobal.GetFormID_S(OSANative.GetLeveledActorBase(SubActor))
		RegisterForModEvent("0SSO" + SubFormID + "_Sound", "OnSoundSub")
		RegisterForModEvent("0SAA" + SubFormID + "_BlendMo", "OnMoSub")
		RegisterForModEvent("0SAA" + SubFormID + "_BlendPh", "OnPhSub")
		RegisterForModEvent("0SAA" + SubFormID + "_BlendEx", "OnExSub")
		If (ThirdActor)
			String ThirdFormID = _oGlobal.GetFormID_S(OSANative.GetLeveledActorBase(ThirdActor)) 
			RegisterForModEvent("0SSO" + ThirdFormID + "_Sound", "OnSoundThird")
			RegisterForModEvent("0SAA" + ThirdFormID + "_BlendMo", "OnMoThird")
			RegisterForModEvent("0SAA" + ThirdFormID + "_BlendPh", "OnPhThird")
			RegisterForModEvent("0SAA" + ThirdFormID + "_BlendEx", "OnExThird")
		EndIf
	EndIf

	

	Actro[0] = DomActor

	If (!UsingBed && UseBed)
		Currentbed = FindBed(DomActor)
		If (CurrentBed)
			UsingBed = True
		EndIf
	EndIf


	float[] domCoords
	float[] subCoords

	If ResetPosAfterSceneEnd
		domcoords = OSANative.GetCoords(DomActor)
		If SubActor
			subcoords = OSANative.GetCoords(SubActor)
		EndIf
	EndIf


	If ThirdActor && (StartingAnimation == "")
		startinganimation = "0M2F|Sy6!Sy9!Sy9|Ho|DoubleTrouble+22Enter"
	endif 

	If (UsingBed)
		AllignActorsWithCurrentBed()
		If (StartingAnimation == "")
			StartingAnimation = "0MF|KNy6!KNy6|Ho|KnLap"
		EndIf
	Else
		If (SubActor && SubActor != PlayerRef)
			SubActor.MoveTo(DomActor)
		ElseIf (SubActor == PlayerRef)
			DomActor.MoveTo(SubActor)
		EndIf
			
	EndIf

	If (StartingAnimation == "")
		StartingAnimation = "AUTO"
	EndIf

	o = "_root.WidgetContainer." + OSAOmni.Glyph + ".widget"

	;profile()

	CurrScene = OSA.MakeStage()
	OSA.SetActorsStim(currScene, Actro)
	OSA.SetModule(CurrScene, "0Sex", StartingAnimation, "")
	OSA.StimStart(CurrScene)

	;Profile("Startup time")

	; "Diasa" is basically an OSA scene thread. We need to mount it here so OStim can communicate with OSA.
	; (I didn't pick the nonsense name, it's called that in OSA)
	; Unfortunately, the method used for mounting an NPC on NPC scene is a bit involved.
	if IsNPCScene()
		diasa = GetNPCDiasa(DomActor)
		Console("Scene is a NPC on NPC scene")
		disableOSAControls = true
	Else
		diasa = o + ".viewStage"
	endif


	if !ThirdActor
		CurrentAnimation = "0Sx0MF_Ho-St6RevCud+01T180"
	elseIf SubActor
		CurrentAnimation = "0Sx0M2F_Ho-DoubleTrouble"
	Else
		CurrentAnimation = startingAnimation
	endif 
	LastHubOID = -1
	;OnAnimationChange()

	Int OldTimescale = 0

;	If (CustomTimescale >= 1) && IsPlayerInvolved()
	If (CustomTimescale > 0) && IsPlayerInvolved()
		OldTimescale = GetTimeScale()
		SetTimeScale(CustomTimescale)
		Console("Using custom Timescale: " + CustomTimescale)
	EndIf

	If (LowLightLevelLightsOnly && DomActor.GetLightLevel() < 20) || (!LowLightLevelLightsOnly)
		If (DomLightPos > 0)
			LightActor(DomActor, DomLightPos, DomLightBrightness)
		EndIf
		If (SubActor && SubLightPos > 0)
			LightActor(SubActor, SubLightPos, SubLightBrightness)
		EndIf
	EndIf

	Password = DomActor.GetFactionRank(OsaFactionStage)
	string EventName = "0SAO" + Password + "_AnimateStage"
	RegisterForModEvent(eventName, "OnAnimate")
	RegisterForModEvent("0SAO" + Password + "_ActraSync", "SyncActors")

	int AEvent = ModEvent.Create(EventName)
	Modevent.PushString(AEvent, EventName)
	ModEvent.PushString(AEvent, CurrentAnimation)
	ModEvent.PushFloat(AEvent, 0.0)
	ModEvent.PushForm(AEvent, self)
	ModEvent.Send(AEvent)


	StartTime = Utility.GetCurrentRealTime()

	Bool WaitForActorsTouch = (SubActor && SubActor.GetDistance(DomActor) > 1) && (MisallignmentProtection)
	Int WaitCycles = 0
	While (WaitForActorsTouch) && (SceneRunning)
		Utility.Wait(0.1)
		WaitCycles += 1
		WaitForActorsTouch = (SubActor.GetDistance(DomActor) > 10)

		If (WaitCycles > 8)
			AlternateRealign()
		EndIf
		If (WaitCycles > 10)
			WaitForActorsTouch = False
		EndIf
	EndWhile

	ReallignedDuringThisAnim = false

	ToggleActorAI(True)

	

	Float LoopTimeTotal = 0
	Float LoopStartTime

	AIRunning = UseAIControl

	If (AIRunning)
		AI.StartAI()
	EndIf

	If (!AIRunning)
		If !SubActor && UseAIMasturbation
			Console("Masturbation scene detected. Starting AI")
			AI.StartAI()
			AIRunning = True
		ElseIf (SubActor && IsNPCScene() && UseAINPConNPC)
			Console("NPC on NPC scene detected. Starting AI")
			AI.StartAI()
			AIRunning = True
		ElseIf (SubActor && (AggressiveActor == PlayerRef) && UseAIPlayerAggressor)
			Console("Player aggressor. Starting AI")
			AI.StartAI()
			AIRunning = True
		ElseIf (SubActor && (AggressiveActor == getSexPartner(PlayerRef)) && UseAIPlayerAggressed)
			Console("Player aggressed. Starting AI")
			AI.StartAI()
			AIRunning = True
			DisableOSAControls = true
		ElseIf (SubActor && UseAINonAggressive)
			Console("Non-aggressive scene. Starting AI")
			AI.StartAI()
			AIRunning = True
		EndIf
	EndIf

	if disableplayerhitbox && IsPlayerInvolved()
		float[] stageCoords = OSANative.getcoords(GetOSAStage())
		playerref.setposition(stageCoords[0]+128, stageCoords[1], stageCoords[2])
		OSANative.SetPositionEx(playerref, stageCoords[0], stageCoords[1], stageCoords[2])
	endif 

	If (UseFreeCam) && IsPlayerInvolved()
		;Utility.Wait(1)
		ToggleFreeCam(True)
	EndIf


	SendModEvent("ostim_start")

	
	If (UseFades && IsPlayerInvolved())
		FadeFromBlack()
	EndIf

	While (IsActorActive(DomActor)) && !ForceCloseOStimThread ; Main OStim logic loop
		If (LoopTimeTotal > 1)
			;Console("Loop took: " + loopTimeTotal + " seconds")
			LoopTimeTotal = 0
		EndIf

		Utility.Wait(1.0 - LoopTimeTotal)
		LoopStartTime = Utility.GetCurrentRealTime()

		If (MisallignmentProtection && IsActorActive(DomActor)) && (!ReallignedDuringThisAnim)
			If (SubActor && SubActor.GetDistance(DomActor) > 10)
				Console("Misallignment detected")
				ReallignedDuringThisAnim = true
				AlternateRealign()
				Utility.Wait(0.1)

				Int i = 0
				While ((SubActor.GetDistance(DomActor) > 5) && IsActorActive(DomActor))&& (i < 3)
					Utility.Wait(0.25)
					Console("Still misalligned... " + SubActor.GetDistance(DomActor))
					Console("Disable Misallignment Protection if this is a frequent issue")

					If AppearsFemale(SubActor)
						DomActor.MoveTo(SubActor)
						ElseIf AppearsFemale(DomActor)
						SubActor.MoveTo(DomActor)
					EndIf

					AlternateRealign()

					i += 1
				EndWhile

				If (SubActor.GetDistance(DomActor) < 1)
					Console("Realligned")
					Else
					Console("Allignment failed")
				EndIf
			EndIf
		EndIf

		If (EnableActorSpeedControl && !AnimationIsAtMaxSpeed())
			AutoIncreaseSpeed()
		EndIf

		;Profile()
		If !DisableStimulationCalculation
			DomExcitement += GetCurrentStimulation(DomActor) * DomStimMult
			If SubActor
				SubExcitement += GetCurrentStimulation(SubActor) * SubStimMult
			EndIf
			If ThirdActor
				ThirdExcitement += GetCurrentStimulation(ThirdActor) * ThirdStimMult
			EndIf
		EndIf
		;Profile("Stim calculation")

		If (SubExcitement >= 100.0)
			MostRecentOrgasmedActor = SubActor
			SubTimesOrgasm += 1
			Orgasm(SubActor)
			If (GetCurrentAnimationClass() == ClassSex)
				DomExcitement += 5
			EndIf
			If (EndOnSubOrgasm)
				If (!RequireBothOrgasmsToFinish) || (((DomTimesOrgasm > 0) && (SubTimesOrgasm > 0)))
					If ODatabase.HasIdleSpeed(CurrentOID)
						SetCurrentAnimationSpeed(0)
					EndIf
					Utility.Wait(4)
					EndAnimation()
				EndIf
			EndIf
		EndIf

		If (ThirdExcitement >= 100.0)
			MostRecentOrgasmedActor = ThirdActor
			ThirdTimesOrgasm += 1
			Orgasm(ThirdActor)
		EndIf

		If (DomExcitement >= 100.0)
			MostRecentOrgasmedActor = DomActor
			DomTimesOrgasm += 1
			Orgasm(DomActor)
			If (EndOnDomOrgasm)
				If (!RequireBothOrgasmsToFinish) || (((DomTimesOrgasm > 0) && (SubTimesOrgasm > 0)))
					If ODatabase.HasIdleSpeed(CurrentOID)
						SetCurrentAnimationSpeed(0)
					EndIf
					Utility.Wait(4)
					EndAnimation()
				EndIf
			EndIf
		EndIf

		;Console("Dom excitement: " + DomExcitement)
		;Console("Sub excitement: " + SubExcitement)
		LoopTimeTotal = Utility.GetCurrentRealTime() - LoopStartTime
	EndWhile

	Console("Ending scene")

	SendModEvent("ostim_end", numArg = -1.0)

	If !DisableScaling && !ForceCloseOStimThread
		RestoreScales()
	EndIf

	If (EnableImprovedCamSupport) && IsPlayerInvolved()
		Game.EnablePlayerControls(abCamSwitch = True)
	EndIf

	ODatabase.Unload()

	If (FixFlippedAnimations)
		DomActor.SetDontMove(False)
		If SubActor
			SubActor.SetDontMove(False)
		EndIf
	EndIf

	If (OSANative.IsFreeCam())
		ToggleFreeCam(False)
	EndIf

	If ResetPosAfterSceneEnd && !ForceCloseOStimThread
		DomActor.SetPosition(domcoords[0], domcoords[1], domcoords[2])
		If SubActor
			SubActor.SetPosition(subcoords[0], subcoords[1], subcoords[2]) ;return
		EndIf
		If (UseFades && EndedProper && IsPlayerInvolved())
			Game.FadeOutGame(False, True, 25.0, 25.0) ; keep the screen black
		EndIf
	EndIf

	If (ForceFirstPersonAfter && IsPlayerInvolved())

		While IsInFreeCam()
			Utility.Wait(0.1)
		EndWhile

		Game.ForceFirstPerson()
	EndIf

	If (UseFades && EndedProper && IsPlayerInvolved() && !SkipEndingFadein)
		FadeFromBlack(2)
	EndIf

	UnRegisterForModEvent("0SAO" + Password + "_AnimateStage")
	UnRegisterForModEvent("0SAO" + Password + "_ActraSync")


	UnRegisterForModEvent("0SSO" + DomFormID + "_Sound")
	UnRegisterForModEvent("0SAA" + DomFormID + "_BlendMo")
	UnRegisterForModEvent("0SAA" + DomFormID + "_BlendPh")
	UnRegisterForModEvent("0SAA" + DomFormID + "_BlendEx")
	If (SubActor)
		String SubFormID = _oGlobal.GetFormID_S(OSANative.GetLeveledActorBase(SubActor))
		UnRegisterForModEvent("0SSO" + SubFormID + "_Sound")
		UnRegisterForModEvent("0SAA" + SubFormID + "_BlendMo")
		UnRegisterForModEvent("0SAA" + SubFormID + "_BlendPh")
		UnRegisterForModEvent("0SAA" + SubFormID + "_BlendEx")
		If (ThirdActor)
			String ThirdFormID = _oGlobal.GetFormID_S(OSANative.GetLeveledActorBase(ThirdActor)) 
			UnRegisterForModEvent("0SSO" + ThirdFormID + "_Sound")
			UnRegisterForModEvent("0SAA" + ThirdFormID + "_BlendMo")
			UnRegisterForModEvent("0SAA" + ThirdFormID + "_BlendPh")
			UnRegisterForModEvent("0SAA" + ThirdFormID + "_BlendEx")
		EndIf
	EndIf

	If (OldTimescale > 0)
		Console("Resetting Timescale to: " + OldTimescale)
		SetTimeScale(OldTimescale)
	EndIf

	;SendModEvent("0SA_GameLoaded") ;for safety
	Console(GetTimeSinceStart() + " seconds passed")
	DisableOSAControls = false

	ranOnce = false  

	oldscenemetadata = scenemetadata
	scenemetadata = PapyrusUtil.StringArray(0)

	SceneRunning = False

	SendModEvent("ostim_totalend")

EndEvent

Function Masturbate(Actor Masturbator, Bool zUndress = False, Bool zAnimUndress = False, ObjectReference MBed = None)

	If SoloAnimsInstalled()
		If IsFemale(Masturbator)
			console("actor is female, starting WANK|Sy9|Ap|FemaleStanding")
			StartScene(Masturbator, None, zUndressDom = zUndress, zAnimateUndress = zAnimUndress, zStartingAnimation = "WANK|Sy9|Ap|FemaleStanding", Bed = MBed)
		Else
			console("Actor is male, starting WANK|Sy9|Ap|MaleStanding")
			StartScene(Masturbator, None, zUndressDom = zUndress, zAnimateUndress = zAnimUndress, zStartingAnimation = "WANK|Sy9|Ap|MaleStanding", Bed = MBed)
		EndIf
	Else
		console("masturbation animations were not found.")
	EndIf
EndFunction


;
;			██╗   ██╗████████╗██╗██╗     ██╗████████╗██╗███████╗███████╗
;			██║   ██║╚══██╔══╝██║██║     ██║╚══██╔══╝██║██╔════╝██╔════╝
;			██║   ██║   ██║   ██║██║     ██║   ██║   ██║█████╗  ███████╗
;			██║   ██║   ██║   ██║██║     ██║   ██║   ██║██╔══╝  ╚════██║
;			╚██████╔╝   ██║   ██║███████╗██║   ██║   ██║███████╗███████║
;			 ╚═════╝    ╚═╝   ╚═╝╚══════╝╚═╝   ╚═╝   ╚═╝╚══════╝╚══════╝
;
; 				The main API functions

; Most of what you want to do in OStim is available here, i advise reading through this entire Utilities section


Bool Function IsActorActive(Actor Act)
	{Is the actor in an OSA scene at this moment?}
	Return Act.HasMagicEffect(Actra)
EndFunction

Bool Function IsActorInvolved(actor act)
	{Is or was the actor in an ostim scene}
	; Note the following distinctions with IsActorActive()
	; IsActorInvolved will return true during ostim startup and shutdown as well as during the osa scene
	; IsActorInvolved can return true even after a ostim scene has ended completely. In this sense it is basically "WasActorInvolved"  in the most recent scene
	; Generally isactoractive is preferred, since it will always return false if no ostim scene is running
	if act == none 
		return false 
	endif 
	return (act == DomActor) || (act == subactor) || (act == ThirdActor)
EndFunction

Bool Function IsPlayerInvolved()
	return IsActorInvolved(playerref)
EndFunction

Bool Function IsNPCScene()
	return !IsPlayerInvolved()
EndFunction

Bool Function IsSoloScene()
	return SubActor == None
EndFunction 

Bool Function IsThreesome()
	return ThirdActor != none
EndFunction

ODatabaseScript Function GetODatabase()

	While (!ODatabase)
		Utility.Wait(0.5)
	Endwhile
	Return ODatabase
EndFunction

OBarsScript Function GetBarScript()
	return obars
EndFunction

OUndressScript function GetUndressScript()
	return Oundress
EndFunction

Int Function GetCurrentAnimationSpeed()
	Return CurrentSpeed
EndFunction

Bool Function AnimationIsAtMaxSpeed()
	Return CurrentSpeed == GetCurrentAnimationMaxSpeed()
EndFunction

Int Function GetCurrentAnimationMaxSpeed()
	Return ODatabase.GetMaxSpeed(CurrentOID)
EndFunction

Int Function GetAPIVersion()
	Return 27
EndFunction

bool Function SoloAnimsInstalled()
	return MiscUtil.FileExists("data/meshes/0SA/mod/0Sex/scene/WANK/Boy9/Sx/AnubsMagicDildoBentOver.xml")
EndFunction

bool Function ThreesomeAnimsInstalled()
	return MiscUtil.FileExists("data/meshes/0SA/mod/0Sex/scene/0M2F/Sy6KNy2Sy9/DHJ/Parlor0BJ2HJ.xml")
EndFunction

Function IncreaseAnimationSpeed()
	If (AnimSpeedAtMax)
		Return
	EndIf
	AdjustAnimationSpeed(1)
EndFunction

Function DecreaseAnimationSpeed()
	If (CurrentSpeed < 1)
		Return
	EndIf
	AdjustAnimationSpeed(-1)
EndFunction

Function AdjustAnimationSpeed(float amount)
	{Increase or decrease the animation speed by the amount}
	If amount < 0
		int times = math.abs(amount * 2.0) as int
		While times > 0
			UI.Invokefloat("HUD Menu", diasa + ".scena.speedAdjust", -0.5)
			times -= 1
		EndWhile
	Else
		UI.Invokefloat("HUD Menu", diasa + ".scena.speedAdjust", amount)
	EndIf
EndFunction

Function SetCurrentAnimationSpeed(Int InSpeed)
	AdjustAnimationSpeed(inspeed - CurrentSpeed)
EndFunction

String Function GetCurrentAnimation()
	{Return the animation ID of the current animation}
	Return CurrentAnimation
EndFunction

String Function GetCurrentAnimationClass()
	Return CurrAnimClass
EndFunction

Int Function GetCurrentAnimationOID()
	{Return the ODatabase ID of the current scene}
	Return CurrentOID
EndFunction

string function GetCurrentAnimationSceneID() 
	{Return the scene ID of the current scene i.e. BB|Sy6!KNy9|HhPo|MoShoPo}
	return currentsceneid
endfunction

Function LightActor(Actor Act, Int Pos, Int Brightness) ; pos 1 - ass, pos 2 - face | brightness - 0 = dim
	If (Pos == 0)
		Return
	EndIf

	String Which
	If (Pos == 1) ; ass
		If (Brightness == 0)
			Which = "AssDim"
		Else
			Which = "AssBright"
		EndIf
	ElseIf (Pos == 2) ;face
		If (Brightness == 0)
			Which = "FaceDim"
		Else
			Which = "FaceBright"
		EndIf
	EndIf

	_oGlobal.ActorLight(Act, Which, OSAOmni.OLightSP, OSAOmni.OLightME)
EndFunction

Function TravelToAnimationIfPossible(String Animation) 
	{Alternative to TravelToAnimation with some safety checks}
	Int ID = ODatabase.GetAnimationsWithSceneID(ODatabase.GetDatabaseOArray(), Animation)
	ID = ODatabase.GetObjectOArray(ID, 0)
	Bool Transitory = ODatabase.IsTransitoryAnimation(ID)
	If (Transitory)
		WarpToAnimation(Animation)
	Else
		TravelToAnimation(Animation)
		If (True) ; Catch
			String Lastanimation
			String Lastlastanimation
			String Current = CurrentAnimation
			While (ODatabase.GetSceneIDByAnimID(CurrentAnimation) != Animation)
				Utility.Wait(1)
				If (Current != CurrentAnimation)
					LastLastAnimation = Lastanimation
					LastAnimation = Current
					Current = CurrentAnimation

					If (Current == LastLastAnimation)
						Console("Infinite loop during travel detected. Warping")
						WarpToAnimation(Animation)
					EndIf
				EndIf
			EndWhile
		EndIf
	EndIf
EndFunction

Function TravelToAnimation(String Animation)
	{Order OSA to path to the Scene ID provided. Often fails.}
	
	Console("Attempting travel to: " + Animation)
	RunOsexCommand("$Go," + Animation)
	;string nav = diasa + ".chore.autoNav"

	;UI.InvokeString("HUD Menu", nav + ".inputCommandAgenda", "" + animation)
	;UI.InvokeString("HUD Menu", nav + ".nextMove", "" + animation)
	;UI.Invoke("HUD Menu", nav + ".stepStandard")
EndFunction

Function WarpToAnimation(String Animation) 
	{teleport to the provided scene. Requires a SceneID like:  BB|Sy6!KNy9|HhPo|MoShoPo}
	Console("Warping to animation: " + Animation)
	;RunOsexCommand("$Warp," + Animation)
	
	;String nav = diasa + ".chore.autoNav"
	;UI.InvokeString("HUD Menu", nav + ".inputCommandAgenda", "WARP" + Animation)

	UI.InvokeString("HUD Menu", diasa + ".menuSelection", Animation)

EndFunction

Function ToggleActorAI(bool enable)
	DomActor.EnableAI(enable)
	if SubActor
		SubActor.EnableAI(enable)
		if ThirdActor 
			ThirdActor.EnableAI(enable)
		endif 
	endif 
EndFunction

Function EndAnimation(Bool SmoothEnding = True)
	If (UseFades && SmoothEnding && ((DomActor == PlayerRef) || (SubActor == PlayerRef)))
		FadeToBlack(1.5)
	EndIf
	EndedProper = SmoothEnding
	Console("Trying to end scene")	

	If (IsNPCScene() && (DomActor.GetParentCell() != playerref.GetParentCell()))
		; Attempting to end the scene when the actors are not loaded will fail
		;console("game loaded")
		SendModEvent("0SA_GameLoaded")
	else 
		UI.Invoke("HUD Menu", diasa + ".endCommand")
		;UI.InvokeInt("HUD Menu", o + ".com.endCommand", password)
		;RunOsexCommand("$endscene")
	endif 
	;todo: 0SA_Gameloaded can be used exclusively instead of diasa end command??
EndFunction

Bool Function GetCurrentAnimIsAggressive() ; if the current animation is tagged aggressive
	Return CurrentAnimIsAggressive
EndFunction

Bool Function IsSceneAggressiveThemed() ; if the entire situation should be themed aggressively
	Return AggressiveThemedSexScene
EndFunction

Actor Function GetAggressiveActor()
	Return AggressiveActor
EndFunction

bool Function IsVictim(actor act)
	return AggressiveThemedSexScene && (act != AggressiveActor)
endfunction 

Int Function GetTimesOrgasm(Actor Act) ; number of times the Actor has orgasmed
	If (Act == DomActor)
		Return DomTimesOrgasm
	ElseIf (Act == SubActor)
		Return SubTimesOrgasm
	ElseIf (Act == ThirdActor)
		return ThirdTimesOrgasm
	EndIf
EndFunction

Bool Function IsNaked(Actor NPC) ; todo caching
	Return (!(NPC.GetWornForm(0x00000004) as Bool))
EndFunction

Actor Function GetSexPartner(Actor Char)
	If (Char == SubActor)
		Return DomActor
	EndIf
	Return SubActor
EndFunction

Actor Function GetDomActor()
	Return DomActor
EndFunction

Actor Function GetSubActor()
	Return SubActor
EndFunction

Actor Function GetThirdActor()
	Return ThirdActor
EndFunction

Actor[] Function GetActors()
	Actor[] ret
	If ThirdActor
		ret = new Actor[3]
	ElseIf SubActor
		ret = new Actor[2]
	Else 
		ret = new Actor[1]
	EndIf

	ret[0] = DomActor
	If SubActor
		ret[1] = SubActor
		If ThirdActor
			ret[2] = ThirdActor
		EndIf 
	EndIf

	return ret
EndFunction

;/
Function SwapActorOrder() ; Swaps dom position in animation for sub. Only effects the animation scene. 2p scenes only
    if ThirdActor == none 
        UI.Invoke("HUD Menu", diasa + ".arrangeActra")

       ; actor temp = domactor ; experimental, please check for the side effects of this before using the function
       ; DomActor = subactor 
       ; SubActor = temp
    endif
EndFunction
/;

Actor Function GetMostRecentOrgasmedActor()
	Return MostRecentOrgasmedActor
EndFunction

Function AddSceneMetadata(string MetaTag)
	scenemetadata = PapyrusUtil.PushString(scenemetadata, MetaTag)
EndFunction

bool Function HasSceneMetadata(string MetaTag)
	string[] metadata
	if SceneRunning
		metadata = scenemetadata
	else 
		metadata = oldscenemetadata
	endif 

	return metadata.Find(metatag) != -1
EndFunction

string[] Function GetAllSceneMetadata()
	return scenemetadata
EndFunction


Function RunOsexCommand(String CMD)
	String[] Plan = new String[2]
	Plan[1] = CMD

	RunLegacyAPI(Plan)
EndFunction

;https://web.archive.org/web/20161107220749/http://ceo-os.tumblr.com/osex/book/api
Function RunLegacyAPI(String[] CMDlist)
	OSA.SetPlan(CurrScene, CMDlist)
	OSA.StimStart(CurrScene)
EndFunction

; Warps to all of the scene IDs in the array.
; Does not do any waiting on it's own. To do that, you can add in numbers into the list, 
; and the function will wait that amount of time
; i.e. [sceneID, sceneID, "3", sceneID]
Function PlayAnimationSequence(String[] list)
	String[] CMDs = new String[1]
	CMDs[0] = "$Wait,0"

	int i = 0
	int max = list.Length
	While (i < max)
		If !StringContains(list[i], "|")
			CMDs = PapyrusUtil.PushString(CMDs, "$Wait," + list[i])
		Else 
			CMDs = PapyrusUtil.PushString(CMDs, "$Warp," + list[i])
		EndIf

		i += 1
	EndWhile

	RunLegacyAPI(CMDs)
EndFunction

function FadeFromBlack(float time = 4.0)
	Game.FadeOutGame(False, True, 0.0, time) ; welcome back
EndFunction

function FadeToBlack(float time = 1.25)
		Game.FadeOutGame(True, True, 0.0, Time)
		Utility.Wait(Time * 0.70)
		Game.FadeOutGame(False, True, 25.0, 25.0) ; total blackout
EndFunction

Float Function GetTimeSinceLastPlayerInteraction()
	Return Utility.GetCurrentRealTime() - MostRecentOSexInteractionTime
EndFunction

Bool Function UsingBed()
	Return Usingbed
EndFunction

ObjectReference Function GetBed()
	Return Currentbed
EndFunction

Bool Function IsFemale(Actor Act)
	{genitalia based / has a vagina and not a penis}


	If SoSInstalled
		return !Act.IsInFaction(SoSFaction)
	else
		Return AppearsFemale(Act)
	endif

EndFunction

Bool Function AppearsFemale(Actor Act) 
	{gender based / looks like a woman but can have a penis}
	Return OSANative.GetSex(OSANative.GetLeveledActorBase(act)) == 1
EndFunction

Actor Function GetCurrentLeadingActor()
	{in a blowjob type animation, it would be the female, while in most sex animations, it will be the male}
	Int ActorNum = ODatabase.GetMainActor(CurrentOID)
	If (ActorNum == 0)
		Return DomActor
	EndIf
	Return SubActor
EndFunction

Bool Function AnimationRunning()
	Return SceneRunning
EndFunction

Bool Function IsVaginal()
	Return (GetCurrentAnimationClass() == ClassSex) && IsFemale(SubActor)
EndFunction

Bool Function IsOral()
	string animType = GetCurrentAnimationClass()
	return animType == "BJ" || animType == "HhBJ" || animType == "AgBJ" || animType == "DBJ"
EndFunction

String[] Function GetScene()
	{this is not the sceneID, this is an internal osex thing}
	Return CurrScene
EndFunction

Function Realign()
	AllowVehicleReset()
	Utility.Wait(0.1)
	SendModEvent("0SAA" + _oGlobal.GetFormID_S(OSANative.GetLeveledActorBase(DomActor)) + "_AlignStage")
	SendModEvent("0SAA" + _oGlobal.GetFormID_S(OSANative.GetLeveledActorBase(SubActor)) + "_AlignStage")
	If (ThirdActor)
		SendModEvent("0SAA" + _oGlobal.GetFormID_S(OSANative.GetLeveledActorBase(ThirdActor)) + "_AlignStage")
	EndIf
EndFunction

Function AlternateRealign() ; may work better than the above function, or worse. Try testing.
	AllowVehicleReset()
	Utility.Wait(0.1)
	OSA.StimStart(CurrScene)
EndFunction

Function AllowVehicleReset()
	Console("Allowing vehicle reset...")
	SendModEvent("0SAA" + _oGlobal.GetFormID_S(OSANative.GetLeveledActorBase(DomActor)) + "_AllowAlignStage")
	SendModEvent("0SAA" + _oGlobal.GetFormID_S(OSANative.GetLeveledActorBase(SubActor)) + "_AllowAlignStage")
	If (ThirdActor)
		SendModEvent("0SAA" + _oGlobal.GetFormID_S(OSANative.GetLeveledActorBase(ThirdActor)) + "_AllowAlignStage")
	EndIf
EndFunction

float function GetEstimatedTimeUntilEnd()
	float total = 120
	total /= SexExcitementMult

	float dom = 99999.0
	float sub = 99999.0

	if EndOnDomOrgasm
		dom = total * (1 - (DomExcitement/100.0))
	endif 
	if EndOnSubOrgasm
		sub = total * (1 - (SubExcitement/100.0))
	endif 

	if sub < dom
		return sub
	else 
		return dom
	endif

EndFunction

Function ToggleFreeCam(Bool On = True)
	outils.lock("mtx_tfc")

	If (!OSANative.IsFreeCam())
		int cstate = game.GetCameraState()
		If (cstate == 0) || ((cstate == 9))
			game.ForceThirdPerson()
			
			if EnableImprovedCamSupport
				;Console("using hack")
				; Improved cam hack
				int povkey = input.GetMappedKey("Toggle POV")

				input.HoldKey(povkey)
				Utility.Wait(0.025)
				input.ReleaseKey(povkey)

				Utility.Wait(0.05)
			endif 
		endif 
		;OSANative.EnableFreeCam()
		consoleUtil.ExecuteCommand("tfc")
		OSANative.SetFreeCamSpeed(FreecamSpeed)
		OSANative.SetFOV(FreecamFOV)
		Console("Enabling freecam")
	Else
		;OSANative.DisableFreeCam()
		consoleUtil.ExecuteCommand("tfc")
		OSANative.SetFreeCamSpeed()
		OSANative.SetFOV(DefaultFOV)
		if EnableImprovedCamSupport
			game.ForceFirstPerson()
			Utility.Wait(0.034)
			game.ForceThirdPerson()
		endif 
		Console("Disabling freecam")
	EndIf

	OSANative.Unlock("mtx_tfc")
EndFunction

bool NavMenuHidden

Function HideNavMenu()
	NavMenuHidden = true
	UI.Invoke("HUD Menu", "_root.WidgetContainer." + OSAomni.glyph + ".widget.hud.NavMenu.dim")
	UI.Invoke("HUD Menu", "_root.WidgetContainer." + OSAomni.glyph + ".widget.hud.SceneMenu.OmniDim")
EndFunction

Function ShowNavMenu()
	NavMenuHidden = false
	UI.Invoke("HUD Menu", "_root.WidgetContainer." + OSAomni.glyph + ".widget.hud.NavMenu.light")
	UI.Invoke("HUD Menu", "_root.WidgetContainer." + OSAomni.glyph + ".widget.hud.SceneMenu.OmniLight")
EndFunction

Function HideAllSkyUIWidgets() ; DEPRECIATED
	outils.SetSkyUIWidgetsVisible(false)
EndFunction

Function ShowAllSkyUIWidgets()
	outils.SetSkyUIWidgetsVisible(true)
EndFunction

bool function IsInFreeCam()
	Return OSANative.IsFreeCam()
endfunction


float Function GetStimMult(Actor Act)
	If (Act == DomActor)
		Return DomStimMult
	Elseif (Act == SubActor)
		Return SubStimMult
	Elseif (Act == ThirdActor)
		Return ThirdStimMult
	Else
		Console("Unknown actor")
	EndIf
EndFunction

Function SetStimMult(Actor Act, Float Value)
	If (Act == DomActor)
		DomStimMult = Value
	Elseif (Act == SubActor)
		SubStimMult = Value
	Elseif (Act == ThirdActor)
		ThirdStimMult = Value
	Else
		Console("Unknown actor")
	EndIf
EndFunction

Function ModifyStimMult(actor act, float by)
	{thread-safe stimulation modification. Highly recomended you use this over Set.}
	OUtils.lock("mtx_stimmult")
	SetStimMult(act, GetStimMult(act) + by)
	osanative.unlock("mtx_stimmult")
endfunction

bool Function IsBeingStimulated(Actor act)
	return (GetCurrentStimulation(act) * GetStimMult(act)) > 0.01
EndFunction

; spanking stuff
Int Function GetSpankCount() ; 
	{Number of spankings so far this scene}
	Return SpankCount
EndFunction

Int Function GetMaxSpanksAllowed()  
	{maximum number of spankings before it deals damage}
	Return SpankMax
EndFunction

Function SetSpankMax(Int Max) 
	{maximum number of spankings before it deals damage}
	SpankMax = Max
EndFunction

Function SetSpankCount(Int Count) 
	{num of spankings so far this scene}
	SpankCount = Count
EndFunction

Function ForceStop()
	ForceCloseOStimThread = true
EndFunction

Function DisableActorsCollision()
	actor[] a = GetActors()

	int i = 0
	int max = a.Length
	while i < max 
		DisableCollision(a[i])
		i += 1
	endwhile
EndFunction

Function EnableActorsCollision()
	actor[] a = GetActors()

	int i = 0
	int max = a.Length
	while i < max 
		EnableCollision(a[i])
		i += 1
	endwhile
EndFunction

Function DisableCollision(actor act)
	{Make the actor unable to moved by anything. Other actors can still touch them}
	act.TranslateTo(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.000000000, 0.000000000)
	
EndFunction

Function EnableCollision(actor act)
	act.stoptranslation()
EndFunction

OStimSubthread Function GetUnusedSubthread()
	int i = 0
	int max = subthreadquest.GetNumAliases()
	while i < max 
		OStimSubthread thread = subthreadquest.GetNthAlias(i) as OStimSubthread

		if !thread.IsInUse()
			return thread 
		endif 

		i += 1
	endwhile
EndFunction

OStimSubthread Function GetSubthread(int id)
	OStimSubthread ret = subthreadquest.GetNthAlias(id) as OStimSubthread
	if !ret 
		Console("Subthread not found")
	endif 
	return ret
EndFunction

Function ConvertToSubthread()
{Turn the current thread into a subthread and wait to return}
	if SceneRunning
		if !GetUnusedSubthread().InheritFromMain()
			Debug.Notification("OStim: Thread overload, please report this on discord")
		endif 

		while SceneRunning
			Utility.Wait(0.5)
		endwhile 
		Utility.Wait(1.0)
	else 
		Console("Nothing running...")
	endif 
EndFunction

float Function GetTimeSinceStart()
	return Utility.GetCurrentRealTime() - StartTime
EndFunction

;
;			██████╗ ███████╗██████╗ ███████╗
;			██╔══██╗██╔════╝██╔══██╗██╔════╝
;			██████╔╝█████╗  ██║  ██║███████╗
;			██╔══██╗██╔══╝  ██║  ██║╚════██║
;			██████╔╝███████╗██████╔╝███████║
;			╚═════╝ ╚══════╝╚═════╝ ╚══════╝
;
;				Code related to beds


ObjectReference Function FindBed(ObjectReference CenterRef, Float Radius = 0.0)
	If !(Radius > 0.0)
		Radius = BedSearchDistance * 64.0
	EndIf

	ObjectReference[] Beds
	If (!UseAlternateBedSearch) && (UseNativeFunctions)
		Console("Using native bed search")
		Beds = OSANative.FindBed(CenterRef, Radius, 96.0)
	Else
		Console("Using papyrus bed search")
		Beds = MiscUtil.ScanCellObjects(40, CenterRef, Radius, Keyword.GetKeyword("RaceToScale"))
	EndIf

	ObjectReference NearRef = None

	Int i = 0
	Int L = Beds.Length
	If (!UseAlternateBedSearch) && (UseNativeFunctions)
		While (i < L)
			ObjectReference Bed = Beds[i]
			If (!Bed.IsFurnitureInUse())
				NearRef = Bed
				i = L
			Else
				i += 1
			EndIf
		EndWhile
	Else
		Float Z = CenterRef.GetPositionZ()
		While (i < L)
			ObjectReference Bed = Beds[i]
			If (IsBed(Bed) && !Bed.IsFurnitureInUse() && SameFloor(Bed, Z))
				If (!NearRef)
					NearRef = Bed
				Else
					If (NearRef.GetDistance(CenterRef) > Bed.GetDistance(CenterRef))
						NearRef = Bed
					EndIf
				EndIf
			EndIf
			i += 1
		EndWhile
	EndIf

	If (NearRef)
		Console("Bed found")
		;PrintBedInfo(NearRef)
		Return NearRef
	EndIf

	Console("Bed not found")
	Return None ; Nothing found in search loop
EndFunction

Bool Function SameFloor(ObjectReference BedRef, Float Z, Float Tolerance = 128.0)
	Return (Math.Abs(Z - BedRef.GetPositionZ())) <= Tolerance
EndFunction

Bool Function CheckBed(ObjectReference BedRef, Bool IgnoreUsed = True)
	Return BedRef && BedRef.IsEnabled() && BedRef.Is3DLoaded()
EndFunction

Bool Function IsBed(ObjectReference Bed) ; trick so dirty it could only be in an adult mod
	If (OSANative.GetDisplayName(bed) == "Bed") || (Bed.Haskeyword(Keyword.GetKeyword("FurnitureBedRoll"))) || (OSANative.GetDisplayName(bed) == "Bed (Owned)")
		Return True
	EndIf
	Return False
EndFunction

Bool Function IsBedRoll(objectReference Bed)
	Return (Bed.Haskeyword(Keyword.GetKeyword("FurnitureBedRoll")))
EndFunction

Function AllignActorsWithCurrentBed()
	DomActor.SetDontMove(True)
	SubActor.SetDontMove(True)
	If ThirdActor
		ThirdActor.SetDontMove(true)
	EndIf

	Bool BedRoll = IsBedRoll(Currentbed)
	Bool Flip = !BedRoll

	Float FlipFloat = 0
	If (Flip)
		FlipFloat = 180
	EndIf

	Float DomSpeed = CurrentBed.GetDistance(DomActor) * 100
	Float BedOffsetX = 0
	Float BedOffsetY = 0
	Float BedOffsetZ = 0

	If (!BedRoll)
		Console("Current bed is not a bedroll. Moving actors backwards a bit")

		Int Offset = 31 + BedReallignment
		If (SubActor == PlayerRef)
			Console("Player is SubActor. Adding some extra bed offset")
			Offset += 36
		EndIf

		BedOffsetX = Math.Cos(OUtils.TrigAngleZ(CurrentBed.GetAngleZ())) * Offset
		BedOffsetY = Math.Sin(OUtils.TrigAngleZ(CurrentBed.GetAngleZ())) * Offset
		BedOffsetZ = 45
	Else
		Console("Bedroll. Not realigning")
	EndIf

	float[] bedCoords = OSANative.GetCoords(CurrentBed)
	bedCoords[0] = bedCoords[0] + BedOffsetX
	bedCoords[1] = bedCoords[1] + BedOffsetY
	bedCoords[2] = bedCoords[2] + BedOffsetZ
	Float BedAngleX = Currentbed.GetAngleX()
	Float BedAngleY = Currentbed.GetAngleY()
	Float BedAngleZ = Currentbed.GetAngleZ()

	DomActor.TranslateTo(bedCoords[0], bedCoords[1], bedCoords[2], BedAngleX, BedAngleY, BedAngleZ, DomSpeed, afMaxRotationSpeed = 100)
	DomActor.SetAngle(BedAngleX, BedAngleY, BedAngleZ - FlipFloat)
	If (UseFades && IsPlayerInvolved())
		Game.FadeOutGame(False, True, 25.0, 25.0) ; keep the screen black
	EndIf

	Utility.Wait(0.05)

	Float OffsetY = Math.Sin(OUtils.TrigAngleZ(DomActor.GetAngleZ())) * 30
	Float OffsetX = Math.Cos(OUtils.TrigAngleZ(DomActor.GetAngleZ())) * 30

	SubActor.MoveTo(DomActor, OffsetX, OffsetY, 0)
	SubActor.SetAngle(BedAngleX, BedAngleY, BedAngleZ - FlipFloat)

	If (UseFades && ((DomActor == PlayerRef) || (SubActor == PlayerRef)))
		Game.FadeOutGame(False, True, 10.0, 5) ; keep the screen black
	EndIf

	If ThirdActor
		Utility.Wait(0.05)

		OffsetY = Math.Sin(OUtils.TrigAngleZ(DomActor.GetAngleZ())) * 30
		OffsetX = Math.Cos(OUtils.TrigAngleZ(DomActor.GetAngleZ())) * 30

		ThirdActor.MoveTo(DomActor, OffsetX, OffsetY, 0)
		ThirdActor.SetAngle(BedAngleX, BedAngleY, BedAngleZ - FlipFloat)

		ThirdActor.SetDontMove(false)
	EndIf

	DomActor.SetDontMove(False)
	SubActor.SetDontMove(False)
EndFunction



Function Flip()
	Console("Flipping")
	IsFlipped = !IsFlipped

	ObjectReference Stage = GetOSAStage()

	Stage.SetAngle(Stage.GetAngleX(), Stage.GetAngleY(), Stage.GetAngleZ() + 180) ; flip stage

	DomActor.SetAngle(0, 0, Stage.GetAngleZ()) ; reangle
	SubActor.SetAngle(0, 0, Stage.GetAngleZ())

	DomActor.TranslateTo(Stage.x, Stage.y, Stage.z, 0, 0, Stage.GetAngleZ(), 150.0, 0) ; move into place
	SubActor.TranslateTo(Stage.x, Stage.y, Stage.z, 0, 0, Stage.GetAngleZ(), 150.0, 0)

	DomActor.SetVehicle(Stage)  ; fuse
	SubActor.SetVehicle(Stage)

	SendModEvent("ostim_setvehicle")
EndFunction

ObjectReference Function GetOSAStage() ; the stage is an invisible object that the actors are alligned on
	Int StageID = DomActor.GetFactionRank(OSAOmni.OFaction[1])
	ObjectReference stage = OSAOmni.GlobalPosition[StageID as Int]
	Return Stage
EndFunction

Function PrintBedInfo(ObjectReference Bed)
	Console("--------------------------------------------")
	Console("BED - Name: " + Bed.GetDisplayName())
	Console("BED - Enabled: " + Bed.IsEnabled())
	Console("BED - 3D loaded: " + Bed.Is3DLoaded())
	Console("BED - Bed roll: " + IsBedRoll(Bed))
	Console("--------------------------------------------")
EndFunction


;
;			███████╗██████╗ ███████╗███████╗██████╗     ██╗   ██╗████████╗██╗██╗     ██╗████████╗██╗███████╗███████╗
;			██╔════╝██╔══██╗██╔════╝██╔════╝██╔══██╗    ██║   ██║╚══██╔══╝██║██║     ██║╚══██╔══╝██║██╔════╝██╔════╝
;			███████╗██████╔╝█████╗  █████╗  ██║  ██║    ██║   ██║   ██║   ██║██║     ██║   ██║   ██║█████╗  ███████╗
;			╚════██║██╔═══╝ ██╔══╝  ██╔══╝  ██║  ██║    ██║   ██║   ██║   ██║██║     ██║   ██║   ██║██╔══╝  ╚════██║
;			███████║██║     ███████╗███████╗██████╔╝    ╚██████╔╝   ██║   ██║███████╗██║   ██║   ██║███████╗███████║
;			╚══════╝╚═╝     ╚══════╝╚══════╝╚═════╝      ╚═════╝    ╚═╝   ╚═╝╚══════╝╚═╝   ╚═╝   ╚═╝╚══════╝╚══════╝
;
;				Some code related to the speed system


Bool CurrAnimHasIdleSpeed
Function AutoIncreaseSpeed()
	If (GetTimeSinceLastPlayerInteraction() < 5.0)
		Return
	EndIf

	String CClass = GetCurrentAnimationClass()
	Float MainExcitement = GetActorExcitement(DomActor)
	If (CClass == "VJ") || (CClass == "Cr") || (CClass == "Pf1") || (CClass == "Pf2")
		MainExcitement = GetActorExcitement(SubActor)
	EndIf

	Int MaxSpeed = GetCurrentAnimationMaxSpeed()
	Int NumSpeeds = MaxSpeed

	Int AggressionBonusChance = 0
	If (IsSceneAggressiveThemed())
		AggressionBonusChance = 80
		MainExcitement += 20
	EndIf

	Int Speed = GetCurrentAnimationSpeed()
	If (!CurrAnimHasIdleSpeed)
		NumSpeeds += 1
	ElseIf (Speed == 0)
		Return
	EndIf

	If ((MainExcitement >= 85.0) && (Speed < NumSpeeds))
		If (ChanceRoll(80))
			IncreaseAnimationSpeed()
		EndIf
	ElseIf (MainExcitement >= 69.0) && (Speed <= (NumSpeeds - 1))
		If (ChanceRoll(50))
			IncreaseAnimationSpeed()
		EndIf
	ElseIf (MainExcitement >= 25.0) && (Speed <= (NumSpeeds - 2))
		If (ChanceRoll(20 + AggressionBonusChance))
			IncreaseAnimationSpeed()
		EndIf
	ElseIf (MainExcitement >= 05.0) && (Speed <= (NumSpeeds - 3))
		If (ChanceRoll(20 + AggressionBonusChance))
			IncreaseAnimationSpeed()
		EndIf
	EndIf
EndFunction




;
;			 ██████╗ ███████╗███████╗██╗  ██╗     ██████╗ ███████╗██╗      █████╗ ████████╗███████╗██████╗     ███████╗██╗   ██╗███████╗███╗   ██╗████████╗███████╗
;			██╔═══██╗██╔════╝██╔════╝╚██╗██╔╝     ██╔══██╗██╔════╝██║     ██╔══██╗╚══██╔══╝██╔════╝██╔══██╗    ██╔════╝██║   ██║██╔════╝████╗  ██║╚══██╔══╝██╔════╝
;			██║   ██║███████╗█████╗   ╚███╔╝█████╗██████╔╝█████╗  ██║     ███████║   ██║   █████╗  ██║  ██║    █████╗  ██║   ██║█████╗  ██╔██╗ ██║   ██║   ███████╗
;			██║   ██║╚════██║██╔══╝   ██╔██╗╚════╝██╔══██╗██╔══╝  ██║     ██╔══██║   ██║   ██╔══╝  ██║  ██║    ██╔══╝  ╚██╗ ██╔╝██╔══╝  ██║╚██╗██║   ██║   ╚════██║
;			╚██████╔╝███████║███████╗██╔╝ ██╗     ██║  ██║███████╗███████╗██║  ██║   ██║   ███████╗██████╔╝    ███████╗ ╚████╔╝ ███████╗██║ ╚████║   ██║   ███████║
;			 ╚═════╝ ╚══════╝╚══════╝╚═╝  ╚═╝     ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝  ╚═╝   ╚═╝   ╚══════╝╚═════╝     ╚══════╝  ╚═══╝  ╚══════╝╚═╝  ╚═══╝   ╚═╝   ╚══════╝
;
;				Event hooks that receive data from OSA


Event OnAnimate(String EventName, String zAnimation, Float NumArg, Form Sender)
	;Console("Event received")
	If (CurrentAnimation != zAnimation) || FirstAnimate
		FirstAnimate = false
		if zAnimation == "undefined"
			Console("---------------------- Warning ----------------------")
			Console("A broken animation is attempting to be played. Printing last valid animation data")
			Console(" ")
			Console(">	Last valid animation: " + CurrentAnimation)
			Console(">	Last valid speed: " + CurrentSpeed)
			Console(">	Probable broken speed: " + (CurrentSpeed + 1))
			Console(">	Last valid animation class: " + CurrAnimClass)
			Console(">	Last valid scene ID: " + GetCurrentAnimationSceneID())
			Console(" ")
			Console("Speed control will be broken until scene is changed")
			Console("Please report this information on discord")
			Console("-----------------------------------------------------")

			return
		endif 
		CurrentAnimation = zAnimation
		OnAnimationChange()

		SendModEvent("ostim_animationchanged")

	EndIf
EndEvent


bool ranOnce ; quick hack to get this to not run on scene start, better solution?
Event SyncActors(string eventName, string strArg, float numArg, Form sender)
	if !ranOnce
		ranOnce = true 
		Console("Skipping first actra sync event")
		return 
	endif 
	Console("Dom was " + DomActor.GetDisplayName())
	Console("Sub was " + SubActor.GetDisplayName())
	if(ThirdActor)
		Console("Third was " + ThirdActor.GetDisplayName())
	endif
	
	string[] newPositions = PapyrusUtil.StringSplit(strArg,",")

	int actorCount = (newPositions[0]) as int
	string[] originalPositions = Utility.CreateStringArray(actorCount, "")
	Actor[] originalActors = GetActors()
	float[] originalExcitementValues = Utility.CreateFloatArray(actorCount, 0.0)
	
	originalPositions[0] = _oGlobal.GetFormID_S(OSANative.GetLeveledActorBase(DomActor))
	originalExcitementValues[0] = DomExcitement
	
	if(SubActor)
		originalPositions[1] = _oGlobal.GetFormID_S(OSANative.GetLeveledActorBase(SubActor))
		originalExcitementValues[1] = SubExcitement
		if(Thirdactor)
			originalPositions[2] = _oGlobal.GetFormID_S(OSANative.GetLeveledActorBase(ThirdActor))
			originalExcitementValues[2] = ThirdExcitement
		endif
	endif

	int i = 0
	while(i < originalPositions.length)
		if(originalPositions[i] == newPositions[1])
			DomActor = originalActors[i]
			DomExcitement = originalExcitementValues[i]	
		elseif(originalPositions[i] == newPositions[2])
			SubActor = originalActors[i]
			SubExcitement = originalExcitementValues[i]			
		elseif(originalPositions[i] == newPositions[3])
			ThirdActor = originalActors[i]
			ThirdExcitement = originalExcitementValues[i]
		endif
		i = i+1
	endWhile

	Console("Dom is now " + DomActor.GetDisplayName())
	Console("Sub is now " + SubActor.GetDisplayName())
	if(ThirdActor)
		Console("Third is now " + ThirdActor.GetDisplayName())
	endif
	bool changed = false
	int j = 0
	while(j < originalPositions.length)
		if(originalPositions[j] != newPositions[j+1])
			changed = true
		endif
		j = j+1
	endwhile
	if(changed)
		SendModEvent("ostim_actorpositionschanged")
	endif
endEvent

Function OpenMouth(Actor Act)
	Console("Opening mouth...")
	String a = _oGlobal.GetFormID_S(OSANative.GetLeveledActorBase(act))

	SendModEvent("0SAA" + a + "_BlendPh", strArg = "1", numArg = 40)
	SendModEvent("0SAA" + a + "_BlendPh", strArg = "0", numArg = 100)
	SendModEvent("0SAA" + a + "_BlendPh", strArg = "5", numArg = 100)
EndFunction

Function CloseMouth(Actor Act)
	Console("Closing mouth...")
	String a = _oGlobal.GetFormID_S(OSANative.GetLeveledActorBase(act)) 

	SendModEvent("0SAA" + a + "_BlendPh", strArg = "1", numArg = 0)
	SendModEvent("0SAA" + a + "_BlendPh", strArg = "0", numArg = 0)
	SendModEvent("0SAA" + a + "_BlendPh", strArg = "5", numArg = 0)
EndFunction

Bool function MouthIsOpen(Actor Act)
	Return (MfgConsoleFunc.GetPhoneme(Act, 0) > 75)
EndFunction

Function OnAnimationChange()
	
	Console("Changing animation...")

	;Profile()
	CurrentOID = ODatabase.GetObjectOArray(ODatabase.GetAnimationWithAnimID(ODatabase.GetDatabaseOArray(), CurrentAnimation), 0)
	
	bool sceneChange = false 

	string newScene = ODatabase.GetSceneID( CurrentOID )
	if newScene != CurrentSceneID
		sceneChange = true 
	endif 
	CurrentSceneID = newScene
	;Profile("DB Lookup")

	If (ODatabase.IsHubAnimation(CurrentOID))
		LastHubOID = CurrentOID
		Console("On new hub animation")
	EndIf

	CurrentAnimIsAggressive = ODatabase.IsAggressive(CurrentOID)
	CurrAnimHasIdleSpeed = ODatabase.HasIdleSpeed(CurrentOID)

	String[] Split = PapyrusUtil.StringSplit(CurrentAnimation, "_")
	If (Split.Length > 2)
		String SpeedString = Split[2]
		CurrentSpeed = SpeedStringToInt(SpeedString)
	Else
		CurrentSpeed = 0
	EndIf

	String CClass = PapyrusUtil.StringSplit(Split[1], "-")[0]
	If (StringUtil.Find(CClass, "Ag") != -1)
		CClass = StringUtil.Substring(CClass, 2)
	EndIf

	CurrAnimClass = CClass

	If (FixFlippedAnimations)
		If (!StringArrayContainsValue(ODatabase.OriginalModules, ODatabase.GetModule(CurrentOID)))
			Console("On third party animation")
			If (!IsFlipped)
				If (StringUtil.Find(ODatabase.getFullName(CurrentOID), "noflip") == -1)
					Flip()
				EndIf
			EndIf
		Else
			If (IsFlipped)
				Console("Back on first-party animation")
				Flip()
			EndIf
		EndIf
	EndIf

	ReallignedDuringThisAnim = False 

	Int CorrectActorCount = ODatabase.GetNumActors(CurrentOID)

	If (!ThirdActor && (CorrectActorCount == 3)) ; no third actor, but there should be
		Console("Third actor has joined scene ")

		Actor[] NearbyActors = MiscUtil.ScanCellNPCs(DomActor, Radius = 64.0) ;epic hackjob time
		int max = NearbyActors.Length
		int i = 0

		While (i < max)
			Actor Act = NearbyActors[i]

			If (Act != DomActor) && (Act != SubActor) && (IsActorActive(Act))
				ThirdActor = Act
				i = max
			Endif
			i += 1
		EndWhile

		If ThirdActor
			Console("Third actor: + " + ThirdActor.GetDisplayName() + " has joined the scene")

			ActorBase thirdActorBase = OSANative.GetLeveledActorBase(ThirdActor)
			RegisterForModEvent("0SSO" + _oGlobal.GetFormID_S(thirdActorBase) + "_Sound", "OnSoundThird")
			RegisterForModEvent("0SAA" + _oGlobal.GetFormID_S(thirdActorBase) + "_BlendMo", "OnMoThird")
			RegisterForModEvent("0SAA" + _oGlobal.GetFormID_S(thirdActorBase) + "_BlendPh", "OnPhThird")
			RegisterForModEvent("0SAA" + _oGlobal.GetFormID_S(thirdActorBase) + "_BlendEx", "OnExThird")

			if !DisableScaling
				ScaleToStandardHeight(ThirdActor)
			EndIf

			SendModEvent("ostim_thirdactor_join")
		Else
			Console("Warning - Third Actor not found")
		EndIf
	ElseIf (ThirdActor && (CorrectActorCount == 2)) ; third actor, but there should not be.
		Console("Third actor has left the scene")

		ActorBase thirdActorBase = OSANative.GetLeveledActorBase(ThirdActor)
		UnRegisterForModEvent("0SSO" + _oGlobal.GetFormID_S(thirdActorBase) + "_Sound")
		UnRegisterForModEvent("0SAA" + _oGlobal.GetFormID_S(thirdActorBase) + "_BlendMo")
		UnRegisterForModEvent("0SAA" + _oGlobal.GetFormID_S(thirdActorBase) + "_BlendPh")
		UnRegisterForModEvent("0SAA" + _oGlobal.GetFormID_S(thirdActorBase) + "_BlendEx")

		if !DisableScaling
			ThirdActor.SetScale(1.0)
		EndIf

		ThirdActor = none

		SendModEvent("ostim_thirdactor_leave") ; careful, getthirdactor() won't work in this event
	EndIf


	If StringArrayContainsValue(SubMouthOpenClasses, GetCurrentAnimationClass())
		If MouthIsOpen(SubActor)
			;Console("Mouth already open")
		Else
			OpenMouth(SubActor)
		Endif
	Else
		If MouthIsOpen(subactor)
			CloseMouth(subactor)
		Endif
	Endif

	If StringArrayContainsValue(DomMouthOpenClasses, GetCurrentAnimationClass())
		If MouthIsOpen(DomActor)
			;Console("Mouth already open")
		Else
			OpenMouth(DomActor)
		Endif
	Else
		If MouthIsOpen(DomActor)
			CloseMouth(DomActor)
		EndIf
	EndIf

	if sceneChange
		SendModEvent("ostim_scenechanged")

		SendModEvent("ostim_scenechanged_" + CurrAnimClass) ;register to scenes by class
		SendModEvent("ostim_scenechanged_" + CurrentSceneID) ;register to scenes by scene
	endif 

	Console("Current animation: " + CurrentAnimation)
	Console("Current speed: " + CurrentSpeed)
	Console("Current animation class: " + CurrAnimClass)
	Console("Current scene ID: " + CurrentSceneID)

	;Profile("Animation change time")
EndFunction

Function OnSpank()
	Console("Spank event recieved")

	If (AllowUnlimitedSpanking)
		SubExcitement += 5
	Else
		If (SpankCount < SpankMax)
			SubExcitement += 5
		Else

			SubActor.DamageActorValue("health", 5.0)
		EndIf
	EndIf

	SpankCount += 1
	SendModEvent("ostim_spank")
EndFunction


Event OnActorHit(String EventName, String zAnimation, Float NumArg, Form Sender)
	If (EndAfterActorHit) && (DomActor.IsInCombat() || SubActor.IsInCombat())
		EndAnimation(False)
	EndIf
EndEvent

Float LastVehicleTime
Event OnSetVehicle(String EventName, String zAnimation, Float NumArg, Form Sender)
	If (Game.GetRealHoursPassed() - LastVehicleTime) < 0.000833 ; 3 seconds
		Utility.Wait(2)
	EndIf
	LastVehicleTime = Game.GetRealHoursPassed()

	Console("Set vehicle fired")

	If (!DisableScaling)
		ScaleAll()
	Else
		RestoreScales()
	EndIf
EndEvent

function ScaleAll()
	If (DomActor)
		ScaleToStandardHeight(DomActor)
	endif
	If (SubActor)
		ScaleToStandardHeight(SubActor)
	EndIf
	If (ThirdActor)
		ScaleToStandardHeight(ThirdActor)
	EndIf
Endfunction

Function ScaleToStandardHeight(Actor Act)
	Float GoalBodyScale
	If (Act == DomActor)
		GoalBodyScale = DomScaleHeight
	ElseIf (Act == SubActor)
		GoalBodyScale = SubScaleHeight
	Else
		GoalBodyScale = ThirdScaleHeight
	EndIf

	ScaleToHeight(Act, GoalBodyScale)
EndFunction

Function ScaleToHeight(Actor Act, Float GoalBodyScale)
	Float NativeBodyScale = outils.GetOriginalScale(act)
	Float Scale = ((GoalBodyScale - NativeBodyScale) / NativeBodyScale) + 1.0

	;Console(act.GetDisplayName())
	;Console("Native scale: " + NativeBodyScale)

	If (Scale < 1.01)  && (Scale > 0.99) ; there is some floating point imprecision with the above.
		if (math.abs(act.GetScale() - NativeBodyScale)) < 0.01 ; the actor is truly the same size as their original size
			Console("Scale not needed")
			Return ; no need to scale and update ninode
		else 
			; continue on, actor needs a scale reset
			scale = 1.0
		endif 
	EndIf

	Console("Setting scale: " + Scale)

	If Scale < 0.01
		Console("Error: an unknown mod is conflicting with OStim's scaling. OStim will now dump scaling data")
		Console("Name: " + act.GetDisplayName())
		Console("Target scale: " + GoalBodyScale)
		Console("Current scale: " + Act.GetScale())
		Console("Disabling scaling in the MCM will stop this message")
		return 
	EndIf

	Act.SetScale(Scale)
	Act.QueueNiNodeUpdate() ; This will cause actors to reqequip clothes if mid-scene
	Act.SetScale(Scale)
EndFunction

Function RestoreScales()
	If (DomActor)
		DomActor.SetScale(1.0)
	endif
	If (SubActor)
		SubActor.SetScale(1.0)
	endif
	If (ThirdActor)
		ThirdActor.SetScale(1.0)
	endif
EndFunction

;
;			███████╗████████╗██╗███╗   ███╗██╗   ██╗██╗      █████╗ ████████╗██╗ ██████╗ ███╗   ██╗    ███████╗██╗   ██╗███████╗████████╗███████╗███╗   ███╗
;			██╔════╝╚══██╔══╝██║████╗ ████║██║   ██║██║     ██╔══██╗╚══██╔══╝██║██╔═══██╗████╗  ██║    ██╔════╝╚██╗ ██╔╝██╔════╝╚══██╔══╝██╔════╝████╗ ████║
;			███████╗   ██║   ██║██╔████╔██║██║   ██║██║     ███████║   ██║   ██║██║   ██║██╔██╗ ██║    ███████╗ ╚████╔╝ ███████╗   ██║   █████╗  ██╔████╔██║
;			╚════██║   ██║   ██║██║╚██╔╝██║██║   ██║██║     ██╔══██║   ██║   ██║██║   ██║██║╚██╗██║    ╚════██║  ╚██╔╝  ╚════██║   ██║   ██╔══╝  ██║╚██╔╝██║
;			███████║   ██║   ██║██║ ╚═╝ ██║╚██████╔╝███████╗██║  ██║   ██║   ██║╚██████╔╝██║ ╚████║    ███████║   ██║   ███████║   ██║   ███████╗██║ ╚═╝ ██║
;			╚══════╝   ╚═╝   ╚═╝╚═╝     ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝    ╚══════╝   ╚═╝   ╚══════╝   ╚═╝   ╚══════╝╚═╝     ╚═╝
;
;				All code related to the stimulation simulation


Float Function GetCurrentStimulation(Actor Act) ; how much an Actor is being stimulated in the current animation
	Float Ret = 0.0
	String CClass = GetCurrentAnimationClass()
	;Bool Aggressive = GetCurrentAnimIsAggressive()
	Bool Sub = Act == SubActor || (!SubActor && IsFemale(Act))
	If ThirdActor == Act
		sub = AppearsFemale(ThirdActor)
	EndIf
	Float Excitement = GetActorExcitement(Act)

	If (CClass == ClassSex)
		If (Sub)
			Ret = GetInteractionStim(Penis, Vagina)
			If (Excitement > 75.0) ; extra lubrication increases enjoyment
				Ret += 0.2
			Elseif (Excitement < 25.0)
				Ret -= 0.2
			EndIf
		Else
			Ret = GetInteractionStim(Vagina, Penis)
		EndIf
	ElseIf ((CClass == ClassHolding) || (CClass == ClassApartUndressing) || (CClass == ClassRoughHolding)) ; Lightly exciting
		If (Excitement > 50.0)
			Ret = -1.0
		EndIf
	ElseIf (CClass == ClassEmbracing) ; more lightly exciting
		If (Excitement > 75.0)
			Ret = -1.0
		EndIf
	ElseIf (CClass == ClassApart)
		If (Excitement > 25.0)
			Ret = -1.0
		EndIf
	ElseIf ((CClass == ClassMasturbate) || (CClass == ClassHeadHeldMasturbate))
		If (Sub)
			Ret = 0.0
		Else
			Ret = GetInteractionStim(Hand, Penis)
		EndIf
	ElseIf (CClass == ClassCunn)
		If (Sub)
			If (ChanceRoll(50))
				Ret = GetInteractionStim(Mouth, Clit)
			Else
				Ret = GetInteractionStim(Mouth, Vagina)
			EndIf
		Else
			Ret = 0.0
		EndIf
	ElseIf ((CClass == ClassPenisjob) || (CClass == ClassHeadHeldPenisjob))
		If (Sub)
			Ret = 0.0
		Else
			If (ChanceRoll(10))
				Ret = GetInteractionStim(Hand, Penis) + (GetInteractionStim(Mouth, Penis) - 1.0)
			Else
				Ret = GetInteractionStim(Mouth, Penis)
			EndIf
		EndIf
	ElseIf (CClass == ClassHandjob) || (CClass == ClassApartHandjob) || (CClass == ClassDualHandjob)
		If (Sub)
			Ret = 0.0
		Else
			Ret = GetInteractionStim(Hand, Penis)
		EndIf
	ElseIf (CClass == ClassBlowjob) || (CClass == ClassHeadHeldBlowjob)
		If (Sub)
			Ret = 0.0
		Else
			Ret = GetInteractionStim(Mouth, Penis)
		EndIf
	ElseIf (CClass == Class69Handjob)
		If (Sub)
			If GetCurrentAnimationSpeed() == 1
				If chanceRoll(30)
					Ret = GetInteractionStim(Mouth, Clit)
				Else
					Ret = GetInteractionStim(Mouth, Vagina)
				EndIf
			Else
				Ret = 0.0 ;this animation is broken
			EndIf
		Else
			Ret = GetInteractionStim(Hand, Penis)
		EndIf
	ElseIf (CClass == Class69Blowjob)
		If (Sub)
			If (GetCurrentAnimationSpeed() == 1)
				If (ChanceRoll(30))
					Ret = GetInteractionStim(Mouth, Clit)
				Else
					Ret = GetInteractionStim(Mouth, Vagina)
				EndIf
			Else
				Ret = 0.0 ;this animation is broken
			EndIf
		Else
			Ret = GetInteractionStim(Mouth, Penis)
		EndIf
	ElseIf (CClass == ClassClitRub)
		If (Sub)
			Ret = GetInteractionStim(Hand, Clit)
		Else
			Ret = 0.0
		EndIf
	ElseIf (CClass == ClassOneFingerPen)
		If (Sub)
			Ret = GetInteractionStim(Hand, Vagina)
		Else
			Ret = 0.0
		EndIf
	ElseIf (CClass == ClassTwoFingerPen)
		If (Sub)
			Ret = GetInteractionStim(Hand, Vagina) * 1.5
		Else
			Ret = 0.0
		EndIf
	ElseIf (CClass == ClassSelfSuck)
		If (Sub)
			Ret = 0.0
		Else
			Ret = GetInteractionStim(Mouth, Penis)
		EndIf
	ElseIf (CClass == ClassAnal)
		If (Sub)
			If (IsFemale(GetSubActor()))
				Ret = (GetInteractionStim(Penis, Anus))
			Else
				Ret = (GetInteractionStim(Penis, Prostate)) + (GetInteractionStim(Penis, Anus))
			EndIf
		Else
			Ret = GetInteractionStim(Anus, Penis)
		EndIf
	ElseIf (CClass == ClassFootjob)
		If (Sub)
			Ret = GetInteractionStim(Penis, Feet)
		Else
			Ret = GetInteractionStim(Feet, Penis)
		EndIf
	ElseIf (CClass == ClassBoobjob)
		If (Sub)
			Ret = GetInteractionStim(Penis, Breasts)
		Else
			Ret = GetInteractionStim(Breasts, Penis)
		EndIf
	ElseIf (CClass == ClassBreastFeeding)
		If (Sub)
			Ret = GetInteractionStim(Mouth, Breasts)
		Else
			Ret = GetInteractionStim(Breasts, Mouth)
		EndIf
	Else
		If (GetCurrentAnimation() == "undefined") ;osex broke!
			Console("Osex state broken. Returning to default animation")
			WarpToAnimation("0MF|Cy6!DOy6|Ho|DoggyLi")
		Else
			Console("Unknown animation class: " + CClass + ". Please report this to the dev!")
		EndIf
	EndIf

	If (Ret > 0.0)
		Int Speed = GetCurrentAnimationSpeed()
		Int NumSpeeds = GetCurrentAnimationMaxSpeed()

		If (!CurrAnimHasIdleSpeed)
			NumSpeeds += 1
		EndIf

		If (SubActor && !IsNaked(GetSexPartner(Act)))
			Ret -= 0.1
		EndIf


		Int HalfwaySpeed = Math.Ceiling((NumSpeeds as Float) / 2.0) ; 5 -> 3 | 3 -> 2 etc
		If (Speed == (HalfwaySpeed - 2))
			Ret -= 0.4
		ElseIf (Speed == (HalfwaySpeed - 1))
			Ret -= 0.2
		ElseIf (Speed == (HalfwaySpeed))
			;do nothing
		ElseIf (Speed == (HalfwaySpeed + 1))
			Ret += 0.2
		ElseIf (Speed == (HalfwaySpeed + 2))
			Ret += 0.4
		EndIf

		If ((Speed == 0) && CurrAnimHasIdleSpeed)
			Ret = 0.0
		EndIf
	EndIf

	If (Ret > 0.0)
		Ret *= SexExcitementMult
	EndIf

	Return Ret
EndFunction

Float Function GetInteractionStim(Int Stimulator, Int Stimulated) ; holds interaction between body parts
	Float[] StimulatorValues

	If (Stimulator == Penis)
		StimulatorValues = PenisStimValues
	ElseIf (Stimulator == Vagina)
		StimulatorValues = VaginaStimValues
	ElseIf (Stimulator == Mouth)
		StimulatorValues = MouthStimValues
	ElseIf (Stimulator == Hand)
		StimulatorValues = HandStimValues
	ElseIf (Stimulator == Clit)
		StimulatorValues = ClitStimValues
	ElseIf (Stimulator == Anus)
		StimulatorValues = AnusStimValues
	ElseIf (Stimulator == Feet)
		StimulatorValues = FeetStimValues
	ElseIf (Stimulator == Breasts)
		StimulatorValues = BreastsStimValues
	ElseIf (Stimulator == Prostate)
		StimulatorValues = ProstateStimValues
	Else
		Console("Unknown Stimulator")
	EndIf

	Return StimulatorValues[Stimulated]
EndFunction

Float Function GetActorExcitement(Actor Act) ; at 100, Actor orgasms
	If (Act == DomActor)
		Return DomExcitement
	ElseIf (Act == SubActor)
		Return SubExcitement
	ElseIf (Act == ThirdActor)
		return ThirdExcitement
	Else
		Debug.Notification("Unknown Actor")
	EndIf
EndFunction

Function SetActorExcitement(Actor Act, Float Value)
	If (Act == DomActor)
		DomExcitement = Value
	ElseIf Act == SubActor
		SubExcitement = Value
	ElseIf (Act == ThirdActor)
		ThirdExcitement = Value
	Else
		Console("Unknown Actor")
	EndIf
EndFunction

Function Orgasm(Actor Act)
	SetActorExcitement(Act, -3.0)
	SendModEvent("ostim_orgasm")
	If (Act == PlayerRef)
		NutEffect.Apply()
		If (SlowMoOnOrgasm)
			SetGameSpeed("0.3")
			Utility.Wait(2.5)
			SetGameSpeed("1")
		EndIf

		If ((DomActor == PlayerRef) || (SubActor == PlayerRef))
			ShakeCamera(1.00, 2.0)
		EndIf

		ShakeController(0.5, 0.7)
	EndIf

	If (Act == DomActor)
		SetCurrentAnimationSpeed(1)
	EndIf

	While StallOrgasm
		Utility.Wait(0.3)
	EndWhile

	If (OrgasmIncreasesRelationship)
		Actor Partner = GetSexPartner(Act)
		Int Rank = Act.GetRelationshipRank(Partner)
		If (Rank == 0)
			Act.SetRelationshipRank(Partner, 1)
		EndIf
	EndIf


	Act.DamageActorValue("stamina", 250.0)
EndFunction

Function SetOrgasmStall(Bool Set)
	StallOrgasm = Set
EndFunction

Bool Function GetOrgasmStall()
	Return StallOrgasm
EndFunction

; Faces

Bool BlockDomFaceCommands
Bool BlockSubFaceCommands
Bool BlockThirdFaceCommands

Function MuteFaceData(Actor Act)
	If (Act == DomActor)
		BlockDomFaceCommands = True
	Elseif (Act == SubActor)
		BlocksubFaceCommands = True
	Elseif (Act == ThirdActor)
		BlockthirdFaceCommands = True
	EndIf
EndFunction

Function UnMuteFaceData(Actor Act)
	If (Act == DomActor)
		BlockDomFaceCommands = False
	Elseif (Act == SubActor)
		BlocksubFaceCommands = False
	Elseif (Act == ThirdActor)
		BlockthirdFaceCommands = False
	EndIf
EndFunction

Bool Function FaceDataIsMuted(Actor Act)
	If (Act == DomActor)
		Return BlockDomFaceCommands
	Elseif (Act == SubActor)
		Return BlocksubFaceCommands
	Elseif (Act == ThirdActor)
		Return BlockthirdFaceCommands
	EndIf
EndFunction

Event OnMoDom(String EventName, String zType, Float zAmount, Form Sender)
	If BlockDomFaceCommands
		Return
	EndIf
	OnMo(DomActor, zType as Int, zAmount as Int)
EndEvent

Event OnMoSub(String EventName, String zType, Float zAmount, Form Sender)
	If BlockSubFaceCommands
		Return
	EndIf
	OnMo(SubActor, zType as Int, zAmount as Int)
EndEvent

Event OnMoThird(String EventName, String zType, Float zAmount, Form Sender)
	If BlockthirdFaceCommands
		Return
	EndIf
	OnMo(ThirdActor, zType as Int, zAmount as Int)
EndEvent

Function OnMo(Actor Act, Int zType, Int zAmount) ; eye related face blending
	;Console("Eye event: " + "Type: " + type + " Amount: " + amount)
	_oGlobal.BlendMo(Act, zAmount, MfgConsoleFunc.GetModifier(Act, zType), zType, 3)
EndFunction

Event OnPhDom(String EventName, String zType, Float zAmount, Form Sender)
	If BlockDomFaceCommands
		Return
	EndIf
	OnPh(DomActor, zType as Int, zAmount as Int)
EndEvent

Event OnPhSub(String EventName, String zType, Float zAmount, Form Sender)
	If BlockSubFaceCommands
		Return
	EndIf
	OnPh(SubActor, zType as Int, zAmount as Int)
EndEvent

Event OnPhThird(String EventName, String zType, Float zAmount, Form Sender)
	If BlockThirdFaceCommands
		Return
	EndIf
	OnPh(ThirdActor, zType as Int, zAmount as Int)
EndEvent

Function OnPh(Actor Act, Int zType, Int zAmount) ;mouth related face blending
	;Console("Mouth event: " + "Type: " + type + " Amount: " + amount)
	_oGlobal.BlendPh(Act, zAmount, MfgConsoleFunc.GetPhoneme(Act, zType), zType, 3)
EndFunction

Event OnExDom(String EventName, String zType, Float zAmount, Form Sender)
	if blockDomFaceCommands
		return
	endif
	OnEx(DomActor, zType as Int, zAmount as Int)
EndEvent

Event OnExSub(String EventName, String zType, Float zAmount, Form Sender)
	if blockSubFaceCommands
		return
	endif
	OnEx(SubActor, zType as Int, zAmount as Int)
EndEvent

Event OnExThird(String EventName, String zType, Float zAmount, Form Sender)
	If BlockthirdFaceCommands
		Return
	EndIf
	OnEx(ThirdActor, zType as Int, zAmount as Int)
EndEvent

Function OnEx(Actor Act, Int zType, Int zAmount) ;expression related face blending
	;Console("Expression event: " + "Type: " + type + " Amount: " + amount)
	Act.SetExpressionOverride(zType, zAmount)
EndFunction


;			███████╗ ██████╗ ██╗   ██╗███╗   ██╗██████╗
;			██╔════╝██╔═══██╗██║   ██║████╗  ██║██╔══██╗
;			███████╗██║   ██║██║   ██║██╔██╗ ██║██║  ██║
;			╚════██║██║   ██║██║   ██║██║╚██╗██║██║  ██║
;			███████║╚██████╔╝╚██████╔╝██║ ╚████║██████╔╝
;			╚══════╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝╚═════╝
;
;				Code related to Sound

Function PlayDing()
	OSADing.Play(PlayerRef)
EndFunction

Function PlayTickSmall()
	OSATickSmall.Play(PlayerRef)
EndFunction

Function PlayTickBig()
	OSATickBig.Play(PlayerRef)
EndFunction

Event OnSoundDom(String EventName, String Fi, Float Ix, Form Sender)
	OnSound(DomActor, (Fi as Int), Ix as Int)
EndEvent

Event OnSoundSub(String EventName, String Fi, Float Ix, Form Sender)
	OnSound(SubActor, (Fi as Int), Ix as Int)
EndEvent

Event OnSoundThird(String EventName, String Fi, Float Ix, Form Sender)
	OnSound(ThirdActor, (Fi as Int), Ix as Int)
EndEvent

; Below is an event you can easily copy paste into your code to receive sound data
;/
RegisterForModEvent("ostim_osasound", "OnOSASound")
Event OnOSASound(String EventName, String Args, Float Nothing, Form Sender)
	String[] Argz = new String[3]
	Argz = StringUtil.Split(Args, ",")

	Actor Char
	If (Argz[0] == "dom")
		Char = OStim.GetDomActor()
	ElseIf (Argz[0] == "sub")
		Char = OStim.Getsubactor()
	ElseIf (Argz[0] == "third")
		Char = OStim.GetThirdActor()
	EndIf
	Int FormID = Argz[1] as Int
	Int SoundID = Argz[2] as Int

	OsexIntegrationMain.Console("Actor: " + Char.GetDisplayName() + " FormID: " + formID + " SoundID: " + Argz[2])
EndEvent
/;

int[] property SoundFormNumberWhitelist auto 
; Sounds that match a Formnumber found in the above whitelist will always be played if osa is muted
; this is useful if you only want to mute voices, for example 

Function OnSound(Actor Act, Int SoundID, Int FormNumber)
	Int FormID = FormNumber
	If (AppearsFemale(Act))
		If ((FormNumber == 50) || (FormNumber == 60))
			FormID = FormNumber
		Else
			FormID = FormNumber + 5
		EndIf
	EndIf

	If (!MuteOSA) || IntArrayContainsValue(SoundFormNumberWhitelist, FormID)
		PlayOSASound(Act, Formid, Soundid)
	EndIf

	If (FormNumber == 60)
		OnSpank()
		ShakeController(0.3)
		If (UseScreenShake && ((DomActor == PlayerRef) || (SubActor == PlayerRef)))
			ShakeCamera(0.5)
		EndIf
	EndIf

	If (FormNumber == 50)
		ShakeController(0.1)
		If (UseScreenShake && ((DomActor == PlayerRef) || (SubActor == PlayerRef)))
			ShakeCamera(0.5)
		EndIf
	EndIf

	String Arg = "third"
	If (Act == DomActor)
		Arg = "dom"
	ElseIf (Act == SubActor)
		Arg = "sub"
	EndIf

	Arg += "," + FormId
	Arg += "," + SoundId
	SendModEvent("ostim_osasound", StrArg = Arg)

	;Console("Sound: " + arg)
EndFunction

Event OnFormBind(String EventName, String zMod, Float IxID, Form Sender)
	Int Ix = StringUtil.Substring(IxID, 0, 2) as Int
	Int Fo = StringUtil.Substring(IxID, 2) as Int
	;OFormSuite[Ix] = Game.GetFormFromFile(Fo, zMod) as FormList
	Console("System requesting form: " + Fo + " be placed in to slot " + Ix)
	If (zMod != "OSA.esm")
		Console(zMod)
	EndIf

	Console(Game.GetFormFromFile(fo, "OSA.esm").GetName())
EndEvent

Function PlayOSASound(Actor Act, Int FormlistID, Int SoundID)
	PlaySound(Act, SoundFormlists[FormlistID].GetAt(SoundID) as Sound)
	;Console("Playing sound " + soundid + " in form " + formlistID)
EndFunction

Function PlaySound(Actor Act, Sound Snd)
	Int S = (Snd).Play(Act)
	Sound.SetInstanceVolume(S, 1.0)
EndFunction

;  0Guy_vo - 20
; 0Gal_vo - 20 - s 25
; 0Guy_ivo - 10
; 0Gal_ivo - 10 - s 15
;  0Gal_ivos - 11 - s 16
; 0Gal_ivo - 11
; FEvenTone_wvo - 80 - s 85
;0guy_wvo - 80
; 0bod_ibo - 50
; 0bod_ibo - 50
;0spank_spank - 60
;0spank_spank - 60

FormList[] SoundFormLists
Function BuildSoundFormLists()
	SoundFormLists = new FormList[100]
	String Plugin = "OSA.esm"

	SoundFormLists[10] = Game.GetFormFromFile(10483, Plugin) as FormList ;0Guy_ivo
	SoundFormLists[15] = Game.GetFormFromFile(8986, Plugin) as FormList ;0Gal_ivo

	SoundFormLists[11] = Game.GetFormFromFile(8986, Plugin) as FormList ;0Gal_ivo | wtf? female voice on male?
	SoundFormLists[16] = Game.GetFormFromFile(8987, Plugin) as FormList ;0Gal_ivos

	SoundFormLists[20] = Game.GetFormFromFile(17595, Plugin) as FormList ;0Guy_vo
	SoundFormLists[25] = Game.GetFormFromFile(17570, Plugin) as FormList ;0Gal_vo

	SoundFormLists[80] = Game.GetFormFromFile(13409, Plugin) as FormList ;0guy_wvo
	SoundFormLists[85] = Game.GetFormFromFile(13400, Plugin) as FormList ;FEvenTone_wvo

	SoundFormLists[50] = Game.GetFormFromFile(11972, Plugin) as FormList ;0bod_ibo

	SoundFormLists[60] = Game.GetFormFromFile(9037, Plugin) as FormList ;0spank_spank
EndFunction

FormList[] Function GetSoundFormLists()
	Return SoundFormLists
EndFunction




;			 ██████╗ ████████╗██╗  ██╗███████╗██████╗
;			██╔═══██╗╚══██╔══╝██║  ██║██╔════╝██╔══██╗
;			██║   ██║   ██║   ███████║█████╗  ██████╔╝
;			██║   ██║   ██║   ██╔══██║██╔══╝  ██╔══██╗
;			╚██████╔╝   ██║   ██║  ██║███████╗██║  ██║
;			 ╚═════╝    ╚═╝   ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝
;
;				Misc stuff
;				https://textkool.com/en/ascii-art-generator?hl=default&vl=default&font=ANSI%20Shadow&text=Other


Function Console(String In) Global
	MiscUtil.PrintConsole("OStim: " + In)
EndFunction

Function SetGameSpeed(String In)
	ConsoleUtil.ExecuteCommand("sgtm " + In)
EndFunction

Bool Function ChanceRoll(Int Chance) ; input 60: 60% of returning true ;DEPRECIATED - moving to outils in future ver


	return OUtils.ChanceRoll(chance)

EndFunction

Int Function SpeedStringToInt(String In) ; casting does not work so...

	return (StringUtil.AsOrd(StringUtil.GetNthChar(In, 1)) - 48)

EndFunction

Function ShakeCamera(Float Power, Float Duration = 0.1)
	if !OSANative.IsFreeCam()
		Game.ShakeCamera(PlayerRef, Power, Duration)
	endif
EndFunction

Function ShakeController(Float Power, Float Duration = 0.1)
	If (UseRumble && ((DomActor == PlayerRef) || (SubActor == PlayerRef)))
		Game.ShakeController(Power, Power, Duration)
	EndIf
EndFunction

Bool Function IntArrayContainsValue(Int[] Arr, Int Val) ;DEPRECIATED - moving to outils in future ver
	return outils.IntArrayContainsValue(arr, val)
EndFunction

Bool Function StringArrayContainsValue(String[] Arr, String Val) ;DEPRECIATED - moving to outils in future ver
	return outils.StringArrayContainsValue(arr, val)
EndFunction

bool Function StringContains(string str, string contains) ;DEPRECIATED - moving to outils in future ver
	return outils.StringContains(str, contains)
EndFunction

bool Function IsModLoaded(string ESPFile) ;DEPRECIATED - moving to outils in future ver
	return outils.IsModLoaded(ESPFile)
Endfunction

bool Function IsChild(actor act) ;DEPRECIATED - moving to outils in future ver
	return OUtils.IsChild(Act)
EndFunction

Int Function GetTimeScale()
	Return Timescale.GetValue() as Int
EndFunction

Function SetTimeScale(Int Time)
	Timescale.SetValue(Time as Float)
EndFunction

Function DisplayToastAsync(string txt, float lengthOftime)

	RegisterForModEvent("ostim_toast", "DisplayToastEvent")

	int handle = ModEvent.Create("ostim_toast")
	ModEvent.PushString(handle, txt)
	ModEvent.Pushfloat(handle, lengthOftime)

	ModEvent.send(handle)
endfunction

Event DisplayToastEvent(string txt, float time)
	outils.DisplayToastText(txt, time)
EndEvent

Function SetSystemVars()
	; vanilla OSex class library
	ClassSex = "Sx"
	ClassCunn = "VJ" ;Cunnilingus
	ClassApartHandjob = "ApHJ"
	ClassHandjob = "HJ"
	ClassClitRub = "Cr"
	ClassOneFingerPen = "Pf1"
	ClassTwoFingerPen = "Pf2"
	ClassBlowjob = "BJ"
	ClassPenisjob = "ApPJ" ;Blowjob with jerking at the same time
	ClassMasturbate = "Po" ; masturbation
	ClassHolding = "Ho" ;
	ClassApart = "Ap" ;standing apart
	ClassApartUndressing = "ApU"
	ClassEmbracing = "Em"
	ClassRoughHolding = "Ro"
	ClassSelfSuck = "SJ"
	ClassHeadHeldPenisjob = "HhPJ"
	ClassHeadHeldBlowjob = "HhBJ"
	ClassHeadHeldMasturbate = "HhPo"
	ClassDualHandjob = "DHJ"
	Class69Blowjob = "VBJ"
	Class69Handjob = "VHJ"

	; OStim extended library
	ClassAnal = "An"
	ClassBoobjob = "BoJ"
	ClassBreastFeeding = "BoF"
	ClassFootjob = "FJ"

	Penis = 0
	Vagina = 1
	Mouth = 2
	Hand = 3
	Clit = 4
	;extra
	Anus = 5
	Feet = 6
	Breasts = 7
	Prostate = 8

	PenisStimValues = new Float[9]
	VaginaStimValues = new Float[9]
	MouthStimValues = new Float[9]
	HandStimValues = new Float[9]
	ClitStimValues = new Float[9]

	AnusStimValues = new Float[9]
	FeetStimValues = new Float[9]
	BreastsStimValues = new Float[9]
	ProstateStimValues = new Float[9]

	PenisStimValues[Penis] = 0.4
	PenisStimValues[Vagina] = 0.8
	PenisStimValues[Mouth] = 0.0
	PenisStimValues[Hand] = 0.0
	PenisStimValues[Clit] = 0.85
	PenisStimValues[Anus] = 0.2
	PenisStimValues[Feet] = 0.0
	PenisStimValues[Breasts] = 0
	PenisStimValues[Prostate] = 0.6

	VaginaStimValues[Penis] = 1.0
	VaginaStimValues[Vagina] = 0.6
	VaginaStimValues[Mouth] = 0.0
	VaginaStimValues[Hand] = 0.0
	VaginaStimValues[Clit] = 1.0
	VaginaStimValues[Anus] = 0.0
	VaginaStimValues[Feet] = 0.0
	VaginaStimValues[Breasts] = 0.0
	VaginaStimValues[Prostate] = 0.0

	MouthStimValues[Penis] = 1.4
	MouthStimValues[Vagina] = 1.0
	MouthStimValues[Mouth] = 0.1
	MouthStimValues[Hand] = 0.0
	MouthStimValues[Clit] = 2.0
	MouthStimValues[Anus] = 0.1
	MouthStimValues[Feet] = 0.0
	MouthStimValues[Breasts] = 0.1
	MouthStimValues[Prostate] = 0.0

	HandStimValues[Penis] = 0.9
	HandStimValues[Vagina] = 0.6
	HandStimValues[Mouth] = 0.0
	HandStimValues[Hand] = 0.0
	HandStimValues[Clit] = 1.3
	HandStimValues[Anus] = 0.1
	HandStimValues[Feet] = 0.0
	HandStimValues[Breasts] = 0.0
	HandStimValues[Prostate] = 0.5

	ClitStimValues[Penis] = 0.2
	ClitStimValues[Vagina] = 0.1
	ClitStimValues[Mouth] = 0.0
	ClitStimValues[Hand] = 0.0
	ClitStimValues[Clit] = 1.1
	ClitStimValues[Anus] = 0.0
	ClitStimValues[Feet] = 0.0
	ClitStimValues[Breasts] = 0.0
	ClitStimValues[Prostate] = 0.0

	AnusStimValues[Penis] = 1.2
	AnusStimValues[Vagina] = 0.2
	AnusStimValues[Mouth] = 0.0
	AnusStimValues[Hand] = 0.0
	AnusStimValues[Clit] = 0.5
	AnusStimValues[Anus] = 0.0
	AnusStimValues[Feet] = 0.0
	AnusStimValues[Breasts] = 0.0
	AnusStimValues[Prostate] = 0.0

	FeetStimValues[Penis] = 0.7
	FeetStimValues[Vagina] = 0.6
	FeetStimValues[Mouth] = 0.0
	FeetStimValues[Hand] = 0.0
	FeetStimValues[Clit] = 0.8
	FeetStimValues[Anus] = 0.1
	FeetStimValues[Feet] = 0.0
	FeetStimValues[Breasts] = 0.0
	FeetStimValues[Prostate] = 0.3

	BreastsStimValues[Penis] = 0.8
	BreastsStimValues[Vagina] = 0.3
	BreastsStimValues[Mouth] = 0.0
	BreastsStimValues[Hand] = 0.0
	BreastsStimValues[Clit] = 1.0
	BreastsStimValues[Anus] = 0.0
	BreastsStimValues[Feet] = 0.0
	BreastsStimValues[Breasts] = 0.1
	BreastsStimValues[Prostate] = 0.0

	ProstateStimValues[Penis] = 1.2
	ProstateStimValues[Vagina] = 0.2
	ProstateStimValues[Mouth] = 0.0
	ProstateStimValues[Hand] = 0.0
	ProstateStimValues[Clit] = 0.5
	ProstateStimValues[Anus] = 0.0
	ProstateStimValues[Feet] = 0.0
	ProstateStimValues[Breasts] = 0.0
	ProstateStimValues[Prostate] = 0.0


	SubMouthOpenClasses = new String[5]
	SubMouthOpenClasses[0] = "BJ"
	SubMouthOpenClasses[1] = "ApPJ"
	SubMouthOpenClasses[2] = "VBJ"
	SubMouthOpenClasses[3] = "HhBJ"
	SubMouthOpenClasses[4] = "HhPJ"

	DomMouthOpenClasses = new String[5]
	DomMouthOpenClasses[0] = "VJ"
	DomMouthOpenClasses[1] = "VBJ"
	DomMouthOpenClasses[2] = "VHJ"
	DomMouthOpenClasses[3] = "BoF"
	DomMouthOpenClasses[4] = "SJ"
EndFunction

Function SetDefaultSettings()
	EndOnDomOrgasm = True
	EndOnSubOrgasm = False 
	RequireBothOrgasmsToFinish = False
	EnableSubBar = True
	EnableDomBar = True
	EnableThirdBar = True
	HideBarsInNPCScenes = True
	EnableActorSpeedControl = True
	AllowUnlimitedSpanking = False
	AutoUndressIfNeeded = false
	ResetPosAfterSceneEnd = true 

	PlayerAlwaysSubStraight = false
	PlayerAlwaysSubGay = false
	PlayerAlwaysDomStraight = false
	PlayerAlwaysDomGay = false

	EndAfterActorHit = True


	ForceCloseOStimThread = false

	DomLightBrightness = 0
	SubLightBrightness = 1
	SubLightPos = 0
	DomLightPos = 0

	CustomTimescale = 0
	AlwaysUndressAtAnimStart = true
	FullyAnimateRedress = true
	TossClothesOntoGround = true
	UseStrongerUnequipMethod = false

	LowLightLevelLightsOnly = False

	SexExcitementMult = 1.0

	SoundFormNumberWhitelist = new int[1]
	SoundFormNumberWhitelist[0] = 9999 ;initializing to avoid array-related bugs

	EnableImprovedCamSupport = (SKSE.GetPluginVersion("ImprovedCamera") != -1)

	SpeedUpNonSexAnimation = False ;game pauses if anim finished early
	SpeedUpSpeed = 1.5

	DomScaleHeight = 1.03 ; male height
	SubScaleHeight = 1.00 ; female height
	ThirdScaleHeight = 1.03

	disablescaling = false

	Usebed = True
	BedSearchDistance = 15
	MisallignmentProtection = false

	DisablePlayerHitbox = false 

	DisableStimulationCalculation = false

	FixFlippedAnimations = False
	OrgasmIncreasesRelationship = False
	SlowMoOnOrgasm = True

	UseAIControl = False
	OnlyGayAnimsInGayScenes = False
	PauseAI = False
	AutoHideBars = False
	MatchBarColorToGender = false

	AISwitchChance = 6

	GetInBedAfterBedScene = False
	UseAINPConNPC = True
	UseAIPlayerAggressor = True
	UseAIPlayerAggressed = True
	UseAINonAggressive = False


	disableOSAControls = false




	UseFreeCam = !(SKSE.GetPluginVersion("ImprovedCamera") != -1)

	Forcefirstpersonafter = !UseFreeCam

	BedReallignment = 0

	UseRumble = Game.UsingGamepad()
	UseScreenShake = False

	UseFades = True
	UseAutoFades = True
	SkipEndingFadein = false
	BlockVRInstalls = True

	KeyMap = 200
	FreecamKey = 181  
	SpeedUpKey = 78
	SpeedDownKey = 74
	PullOutKey = 79
	ControlToggleKey = 82

	MuteOSA = False

	FreecamFOV = 45
	DefaultFOV = 85
	FreecamSpeed = 3

	Int[] Slots = new Int[1]
	Slots[0] = 32
	Slots = PapyrusUtil.PushInt(Slots, 33)
	Slots = PapyrusUtil.PushInt(Slots, 31)
	Slots = PapyrusUtil.PushInt(Slots, 37)
	StrippingSlots = Slots

	UseNativeFunctions = (SKSE.GetPluginVersion("OSA") != -1)
	If (!UseNativeFunctions)
		Console("Native function DLL failed to load. Falling back to papyrus implementations")
	EndIf
	UseAlternateBedSearch = !UseNativeFunctions
	;UseAlternateBedSearch = True

	ShowTutorials = true 
	
	UseBrokenCosaveWorkaround = True
	RemapStartKey(Keymap)
	RegisterForKey(FreecamKey)
	RemapSpeedDownKey(SpeedDownKey)
	RemapSpeedUpKey(SpeedUpKey)
	RemapPullOutKey(PullOutKey)
	RemapControlToggleKey(ControlToggleKey)
EndFunction

Function RegisterOSexControlKey(Int zKey)
	OSexControlKeys = PapyrusUtil.PushInt(OSexControlKeys, zKey)
	RegisterForKey(zKey)
EndFunction

Function LoadOSexControlKeys()
	OSexControlKeys = new Int[1]
	OSexControlKeys = PapyrusUtil.PushInt(OSexControlKeys, SpeedUpKey)
	OSexControlKeys = PapyrusUtil.PushInt(OSexControlKeys, SpeedDownKey)
	OSexControlKeys = PapyrusUtil.PushInt(OSexControlKeys, PullOutKey)
	OSexControlKeys = PapyrusUtil.PushInt(OSexControlKeys, ControlToggleKey)
	OSexControlKeys = PapyrusUtil.PushInt(OSexControlKeys, KeyMap)
	OSexControlKeys = PapyrusUtil.PushInt(OSexControlKeys, FreecamKey)

	RegisterOSexControlKey(83)
	RegisterOSexControlKey(156)
	RegisterOSexControlKey(72)
	RegisterOSexControlKey(76)
	RegisterOSexControlKey(75)
	RegisterOSexControlKey(77)
	RegisterOSexControlKey(73)
	RegisterOSexControlKey(71)
	RegisterOSexControlKey(79)
	RegisterOSexControlKey(209)
EndFunction

Bool Function GetGameIsVR()
	Return (PapyrusUtil.GetScriptVersion() == 36) ;obviously this no guarantee but it's the best we've got for now
EndFunction

Function AcceptReroutingActors(Actor Act1, Actor Act2) ;compatibility thing, never call this one directly
	ReroutedDomActor = Act1
	ReroutedSubActor = Act2
	Console("Recieved rerouted actors")
EndFunction

Function StartReroutedScene()
	Console("Rerouting scene")
	StartScene(ReroutedDomActor,  ReroutedSubActor)
EndFunction

Function ResetState()
	Console("Resetting thread state")
	SceneRunning = False
	DisableOSAControls = false

	int i = 0 
	Actor[] a = GetActors()
	while i < a.Length
		a[i].dispelallspells()
		i += 1
	endwhile
	o = "_root.WidgetContainer." + OSAOmni.Glyph + ".widget"
    
	UI.InvokeInt("HUD Menu", o + ".com.endCommand", 51)
	UI.InvokeInt("HUD Menu", o + ".com.endCommand", 52)
	UI.InvokeInt("HUD Menu", o + ".com.endCommand", 53)
	UI.InvokeInt("HUD Menu", o + ".com.endCommand", 54)
	UI.InvokeInt("HUD Menu", o + ".com.endCommand", 55)
	UI.InvokeInt("HUD Menu", o + ".com.endCommand", 56)
EndFunction

Function RemapStartKey(Int zKey)
	UnregisterForKey(KeyMap)
	RegisterForKey(zKey)
	KeyMap = zKey
EndFunction

Function RemapFreecamKey(Int zKey)
	UnregisterForKey(FreecamKey)
	RegisterForKey(zKey)
	FreecamKey = zKey
EndFunction

Function RemapControlToggleKey(Int zKey)
	UnregisterForKey(ControlToggleKey)
	RegisterForKey(zKey)
	ControlToggleKey = zKey
	LoadOSexControlKeys()
EndFunction

Function RemapSpeedUpKey(Int zKey)
	UnregisterForKey(SpeedUpKey)
	RegisterForKey(zKey)
	speedUpKey = zKey
	LoadOSexControlKeys()
EndFunction

Function RemapSpeedDownKey(Int zKey)
	UnregisterForKey(SpeedDownKey)
	RegisterForKey(zKey)
	speedDownKey = zKey
	LoadOSexControlKeys()
EndFunction

Function RemapPullOutKey(Int zKey)
	UnregisterForKey(PullOutKey)
	RegisterForKey(zKey)
	PullOutKey = zKey
	LoadOSexControlKeys()
EndFunction

Float ProfileTime 
Function Profile(String Name = "")
	{Call Profile() to start. Call Profile("any string") to pring out the time since profiler started in console. Most accurate at 60fps}
	If (Name == "")
		ProfileTime = Game.GetRealHoursPassed() * 60 * 60
	Else
		float seconds = ((Game.GetRealHoursPassed() * 60 * 60) - ProfileTime - 0.016)
		float ms = seconds * 1000
		If seconds < 0.0
			Console(Name + ": Too fast to measure")
			Debug.Trace("Ostim: "+Name+" : Too fast to measure")
		else 
			Console(Name + ": " + seconds + " seconds (" + ms + " milliseconds)")
			Debug.Trace("Ostim: "+Name+": " + seconds + " seconds (" + ms + " milliseconds)")
		endif 
	EndIf
EndFunction

string Function GetNPCDiasa(actor act)
	; The player thread is easily accessible through OSA. However, NPC scenes are not.
	; Normally, we would go through OSA's thread manager and fetch it.
	; However, SKSE's flash interface doesn't handle flash arrays, so this is not possible.
	; Instead, running an OSA inspect on an npc mounts their data, and within that data is a link to the scene thread they are in
	; Closing the inspect menu would break the link, so we need to leave it open.
	
	o = "_root.WidgetContainer." + OSAOmni.Glyph + ".widget" ; save the path to the main script

	String DomID = _oGlobal.GetFormID_S(OSANative.GetLeveledActorBase(act)) ; get actor 0's id

	String InspectMenu = o + ".hud.InspectMenu" ; get the path to the inspect menu

	UI.InvokeString("HUD Menu", o + ".ctr.INSPECT", domID) ; open the inspect menu on actor 0

	string actraD = InspectMenu + ".actra" ; from that, get actor 0's actra


	string ret = actraD + ".stageStatus" ; get the diasa from that actra



	UI.Invoke("HUD Menu", InspectMenu + ".OmniDim") ; hide the inspect menu real quick

	return ret


EndFunction


Event OnKeyDown(Int KeyPress)

	If outils.MenuOpen()
		Return
	EndIf


	If (KeyPress == KeyMap)
		Actor Target = Game.GetCurrentCrosshairRef() as Actor
		If (Target)
			If (Target.IsInDialogueWithPlayer())
				Return
			EndIf
			If (!Target.IsDead())
				AddSceneMetadata("ostim_manual_start")
				StartScene(PlayerRef,  Target)
				return 
			EndIf
		Else
			Utility.Wait(2)
			if Input.IsKeyPressed(keymap)
				AddSceneMetadata("ostim_manual_start")
				Masturbate(PlayerRef)
			endif 
			return
		EndIf
	elseif (KeyPress == freecamkey)
		if animationrunning() && IsPlayerInvolved()
			ToggleFreeCam()
			return
		endif 
	EndIf

	If (DisableOSAControls)
		Console("OStim controls disabled by property")
		
		if AnimationRunning()
			LockWidget.FlashVisibililty()
		endif 

		Return
	EndIf


	If (AnimationRunning())
		If (IntArrayContainsValue(OSexControlKeys, KeyPress))
			MostRecentOSexInteractionTime = Utility.GetCurrentRealTime()
			If (AutoHideBars)
				If (!OBars.IsBarVisible(OBars.DomBar))
					OBars.SetBarVisible(OBars.DomBar, True)
				EndIf
				If (!OBars.IsBarVisible(OBars.SubBar))
					OBars.SetBarVisible(OBars.SubBar, True)
				EndIf
				If (!OBars.IsBarVisible(OBars.ThirdBar))
					OBars.SetBarVisible(OBars.ThirdBar, True)
				EndIf
			EndIf

			if !IsActorActive(PlayerRef) && navMenuHidden
				ShowNavMenu()
			EndIf
		EndIf

		If (KeyPress == SpeedUpKey)
			IncreaseAnimationSpeed()
			PlayTickSmall()
		ElseIf (KeyPress == SpeedDownKey)
			DecreaseAnimationSpeed()
			PlayTickSmall()
		ElseIf ((KeyPress == PullOutKey) && !AIRunning)
			If (ODatabase.IsSexAnimation(CurrentOID))
				If (LastHubOID != -1)
					TravelToAnimationIfPossible(ODatabase.GetSceneID(LastHubOID))
				EndIf
			EndIf
		EndIf
	EndIf

	If (KeyPress == ControlToggleKey)
		If (AnimationRunning())
			If (AIRunning)
				AIRunning = False
				PauseAI = True
				Debug.Notification("Switched to manual control mode")
				Console("Switched to manual control mode")
			Else
				If (PauseAI)
					PauseAI = False
				Else
					AI.StartAI()
				EndIf
				AIRunning = True
				Debug.Notification("Switched to automatic control mode")
				Console("Switched to automatic control mode")
			EndIf
		Else
			If (UseAIControl)
				UseAIControl = False
				Debug.Notification("Switched to manual control mode")
				Console("Switched to manual control mode")
			Else
				UseAIControl = True
				Debug.Notification("Switched to automatic control mode")
				Console("Switched to automatic control mode")
			EndIf
		EndIf
		PlayTickBig()
	EndIf

	

EndEvent

Bool SoSInstalled
Faction SoSFaction

Function ResetOSA() ; do not use, breaks osa
	Quest OSAQuest = Quest.GetQuest("0SA")
	Quest UIQuest = Quest.GetQuest("0SUI")
	Quest CtrlQuest = Quest.GetQuest("0SAControl")

	OSAQuest.Reset()
	OSAQuest.Stop()
	UIQuest.Reset()
	UIQuest.Stop()
	CtrlQuest.Reset()
	CtrlQuest.Stop()

	Utility.Wait(2.0)

	CtrlQuest.Start()
	OSAQuest.Start()
	UIQuest.Start()

	Utility.Wait(1.0)
Endfunction

int rnd_s1
int rnd_s2
int rnd_s3


int Function RandomInt(int min = 0, int max = 100) ;DEPRECIATED - moving to osanative in future ver
	return OSANative.RandomInt(min, max)
EndFunction 

; Set initial seed values for the RNG. 
Function ResetRandom()
	return
EndFunction

Function Startup()
	installed = false
	Debug.Notification("Installing OStim. Please wait...")


	LoadRegistrations = PapyrusUtil.FormArray(0, none)

	InstalledVersion = GetAPIVersion()

	SceneRunning = False
	Actra = Game.GetFormFromFile(0x000D63, "OSA.ESM") as MagicEffect
	OsaFactionStage = Game.GetFormFromFile(0x00182F, "OSA.ESM") as Faction
	OSAOmni = (Quest.GetQuest("0SA") as _oOmni)
;	OSAUI = (Quest.GetQuest("0SA") as _oui)
	PlayerRef = Game.GetPlayer()
	NutEffect = Game.GetFormFromFile(0x000805, "Ostim.esp") as ImageSpaceModifier
	LockWidget = (Self as Quest) as _oUI_Lockwidget

	subthreadquest = Game.GetFormFromFile(0x000806, "Ostim.esp") as quest

	OUpdater = Game.GetFormFromFile(0x000D67, "Ostim.esp") as OStimUpdaterScript
	OSADing = Game.GetFormFromFile(0x000D6D, "Ostim.esp") as Sound
	OSATickSmall = Game.GetFormFromFile(0x000D6E, "Ostim.esp") as Sound
	OSATickBig = Game.GetFormFromFile(0x000D6F, "Ostim.esp") as Sound

	Timescale = (Game.GetFormFromFile(0x00003A, "Skyrim.esm")) as GlobalVariable

	OControl = Quest.GetQuest("0SAControl") as _oControl

	AI = ((Self as Quest) as OAiScript)
	OBars = ((Self as Quest) as OBarsScript)
	OUndress = ((Self as Quest) as OUndressScript)
	;RegisterForModEvent("ostim_actorhit", "OnActorHit")
	SetSystemVars()
	SetDefaultSettings()
	BuildSoundFormlists()
	scenemetadata = PapyrusUtil.StringArray(0)

	If (BlockVRInstalls && GetGameIsVR())
		Debug.MessageBox("OStim: You appear to be using Skyrim VR. VR is not yet supported by OStim. See the OStim description for more details. If you are not using Skyrim VR by chance, update your papyrus Utilities.")
		Return
	EndIf

	If (SKSE.GetPluginVersion("JContainers64") == -1)
		Debug.MessageBox("OStim: JContainers is not installed, please exit the game and install it to allow Ostim to function.")
		Return
	EndIf

	If (!JContainers.FileExistsAtPath(".\\Data\\Scripts\\OSex.pex"))
		Debug.MessageBox("OStim: OSex is not installed, please exit the game and install it to allow Ostim to function.")
		Return
	endif

	SMPInstalled = (SKSE.GetPluginVersion("hdtSSEPhysics") != -1)
	Console("SMP installed: " + SMPInstalled)

	ODatabase = (Self as Quest) as ODatabaseScript
	ODatabase.InitDatabase()

	If (OSAFactionStage)
		Console("Loaded")
	Else
		Debug.MessageBox("OSex and OSA do not appear to be installed, please do not continue using this save file.")
		Return
	EndIf

	If (ODatabase.GetLengthOArray(ODatabase.GetDatabaseOArray()) < 1)
		Debug.Notification("OStim install failed.")
		Return
	Else
		ODatabase.Unload()
	EndIf

	;If (ArousedFaction)
	;	Console("Sexlab Aroused loaded")
	;EndIf

	If (SKSE.GetPluginVersion("ConsoleUtilSSE") == -1)
		Debug.Notification("OStim: ConsoleUtil is not installed, a few features may not work")
	EndIf

	SoSInstalled = false
	If (Game.GetModByName("Schlongs of Skyrim.esp") != 255)
		SoSFaction = (Game.GetFormFromFile(0x0000AFF8, "Schlongs of Skyrim.esp")) as Faction
		If (SoSFaction)
			Console("Schlongs of Skyrim loaded")
			SoSInstalled = true

		Endif

	EndIf

	

	If (OSA.StimInstalledProper())
		Console("OSA is installed correctly")
	Else
		Debug.MessageBox("OStim is not loaded after OSA in your mod files, please allow OStim to overwrite OSA's files and restart. Alternatively SkyUI is not loaded.")
		Return
	EndIf

	OControl.ResetControls()
	OControl.UpdateControls() ; uneeded?

	If (SKSE.GetPluginVersion("ImprovedCamera") == -1)
		Debug.Notification("OStim: Improved Camera is not installed. First person scenes unavailable.")
		Debug.Notification("OStim: However, freecam will have extra features.")
	EndIf

	If (!_oGlobal.OStimGlobalLoaded())
		Debug.MessageBox("It appears you have the OSex facial expression fix installed. Please exit and remove that mod, as it is now included in OStim, and having it installed will break some things now!")
		return
	EndIf

	OnLoadGame()

	installed = true 

	OUtils.DisplayTextBanner("OStim installed.")
EndFunction

Bool Property UseBrokenCosaveWorkaround Auto

Form[] LoadRegistrations 

Function RegisterForGameLoadEvent(form f)
	{Make a "Event OnGameLoad()" in the scripts attatched to the form you send and the event is called on game load}
	; Note the database is reset when ostim is updated so you should only use this if you also use OUpdater in your mod so you reregister
	while !installed
		Utility.Wait(1)
		Console("Load registrations not ready")
	endWhile

	OUtils.lock("mtx_os_registerload")

	LoadRegistrations = PapyrusUtil.PushForm(LoadRegistrations, f)
	Console("Registered for load event: " + f.getname())

	OSANative.unlock("mtx_os_registerload")
EndFunction 

Function SendLoadGameEvent()
	;Console(LoadRegistrations as string)
	int l = LoadRegistrations.Length

	if l > 0
		int i = 0 

		while i < l 
			;Console("Loading: " + LoadRegistrations[i].getname())
			LoadRegistrations[i].RegisterForModEvent("ostim_gameload", "OnGameLoad")
			ModEvent.Send(ModEvent.Create("ostim_gameload"))
			LoadRegistrations[i].UnregisterForModEvent("ostim_gameload")



			Utility.Wait(0.5)
			i += 1
		endWhile

	endif

EndFunction

Function OnLoadGame()
	If (UseBrokenCosaveWorkaround)
		Console("Using cosave fix")

		RegisterForModEvent("ostim_actorhit", "OnActorHit")
		LoadOSexControlKeys()
		RegisterForKey(SpeedUpKey)
		RegisterForKey(SpeedDownKey)
		RegisterForKey(PullOutKey)
		RegisterForKey(ControlToggleKey)
		RegisterForKey(KeyMap)

		AI.OnGameLoad()
		OBars.OnGameLoad()
		OUndress.OnGameLoad()

		SendLoadGameEvent()

	EndIf

	;may annoy ihud users?
	UI.SetBool("HUD Menu", "_root.HUDMovieBaseInstance._visible", true)

		; Fix for rapid animation swap bug after reload
	o = "_root.WidgetContainer." + OSAOmni.Glyph + ".widget"
	UI.InvokeInt("HUD Menu", o + ".com.endCommand", 51) ;todo test

	if GetAPIVersion() != InstalledVersion
		OUtils.ForceOUpdate()
	endif 

EndFunction
