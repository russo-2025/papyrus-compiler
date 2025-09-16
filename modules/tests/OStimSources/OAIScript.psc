ScriptName OAiScript Extends Quest

; modules & other goodies
OsexIntegrationMain OStim
ODatabaseScript ODatabase
Actor PlayerRef

; actor stuff
Actor Agent
Bool FemDom
Bool MaleDom

Bool Gay
Bool Lesbian

Int NumActors

String[] property ForeplayClasses Auto
String[] property BlowjobClasses Auto
String[] property FemaleCentricClasses Auto
String[] property MaleCentricClasses Auto
String[] property MaleMasturbationClasses Auto
String[] property FemaleMasturbationClasses Auto
String[] property MasturbationClasses Auto
String[] property MainSexClasses Auto

Event OnInit()
	;Startup()
	OStim = (Self as Quest) as OsexIntegrationMain
	ODatabase = OStim.GetODatabase()
	PlayerRef = Game.GetPlayer()

	OnGameLoad()

	ForeplayClasses = PapyrusUtil.PushString(ForeplayClasses, "VJ")
	ForeplayClasses = PapyrusUtil.PushString(ForeplayClasses, "ApHJ")
	ForeplayClasses = PapyrusUtil.PushString(ForeplayClasses, "HJ")
	ForeplayClasses = PapyrusUtil.PushString(ForeplayClasses, "Cr")
	ForeplayClasses = PapyrusUtil.PushString(ForeplayClasses, "Pf1")
	ForeplayClasses = PapyrusUtil.PushString(ForeplayClasses, "Pf2")
	ForeplayClasses = PapyrusUtil.PushString(ForeplayClasses, "BJ")
	ForeplayClasses = PapyrusUtil.PushString(ForeplayClasses, "ApPJ")
	ForeplayClasses = PapyrusUtil.PushString(ForeplayClasses, "HhPJ")
	ForeplayClasses = PapyrusUtil.PushString(ForeplayClasses, "HhBJ")
	ForeplayClasses = PapyrusUtil.PushString(ForeplayClasses, "VBJ")
	ForeplayClasses = PapyrusUtil.PushString(ForeplayClasses, "VHJ")
	ForeplayClasses = PapyrusUtil.PushString(ForeplayClasses, "BJ")
	ForeplayClasses = PapyrusUtil.PushString(ForeplayClasses, "BoJ")
	ForeplayClasses = PapyrusUtil.PushString(ForeplayClasses, "BoF")
	ForeplayClasses = PapyrusUtil.PushString(ForeplayClasses, "FJ")

	BlowjobClasses = PapyrusUtil.PushString(BlowjobClasses, "BJ")
	BlowjobClasses = PapyrusUtil.PushString(BlowjobClasses, "ApHJ")
	BlowjobClasses = PapyrusUtil.PushString(BlowjobClasses, "HJ")
	BlowjobClasses = PapyrusUtil.PushString(BlowjobClasses, "ApPJ")
	BlowjobClasses = PapyrusUtil.PushString(BlowjobClasses, "VBJ")
	BlowjobClasses = PapyrusUtil.PushString(BlowjobClasses, "HhPJ")
	BlowjobClasses = PapyrusUtil.PushString(BlowjobClasses, "HhBJ")

	FemaleCentricClasses = PapyrusUtil.PushString(FemaleCentricClasses, "VBJ")
	FemaleCentricClasses = PapyrusUtil.PushString(FemaleCentricClasses, "Cr")
	FemaleCentricClasses = PapyrusUtil.PushString(FemaleCentricClasses, "Pf1")
	FemaleCentricClasses = PapyrusUtil.PushString(FemaleCentricClasses, "Pf2")
	FemaleCentricClasses = PapyrusUtil.PushString(FemaleCentricClasses, "VHJ")
	FemaleCentricClasses = PapyrusUtil.PushString(FemaleCentricClasses, "VJ")

	MaleCentricClasses = BlowjobClasses
	MaleCentricClasses = PapyrusUtil.PushString(MaleCentricClasses, "An")

	MaleMasturbationClasses = PapyrusUtil.PushString(MaleMasturbationClasses, "Po")

	FemaleMasturbationClasses = PapyrusUtil.PushString(FemaleMasturbationClasses, "Cr")
	FemaleMasturbationClasses = PapyrusUtil.PushString(FemaleMasturbationClasses, "Pf1")
	FemaleMasturbationClasses = PapyrusUtil.PushString(FemaleMasturbationClasses, "Pf2")
	FemaleMasturbationClasses = PapyrusUtil.PushString(FemaleMasturbationClasses, "Sx") ;dildos
	
	MasturbationClasses = PapyrusUtil.PushString(MasturbationClasses, "Po")
	MasturbationClasses = PapyrusUtil.PushString(MasturbationClasses, "Cr")
	MasturbationClasses = PapyrusUtil.PushString(MasturbationClasses, "Pf1")
	MasturbationClasses = PapyrusUtil.PushString(MasturbationClasses, "Pf2")
	MasturbationClasses = PapyrusUtil.PushString(MasturbationClasses, "Sx") ;dildos

	MainSexClasses = PapyrusUtil.PushString(MainSexClasses, "Sx")
	MainSexClasses = PapyrusUtil.PushString(MainSexClasses, "An")
EndEvent

;Event OStimStart(String EventName, String strArg, Float NumArg, Form Sender)
;	If (!OStim.UseAIControl)
;		Return
;	EndIf
;	StartAI()
;EndEvent

Event AI_Thread(String EventName, String strArg, Float NumArg, Form Sender)
	Console("Starting OAI")

	FemDom = False
	MaleDom = False

	Bool AggressiveScene = OStim.IsSceneAggressiveThemed()

	Actor DomActor = OStim.GetDomActor()
	Actor SubActor = OStim.GetSubActor()
	Actor AggressiveActor = OStim.GetAggressiveActor()

	If (AggressiveScene)
		If (OStim.IsFemale(AggressiveActor)) && !(OStim.IsFemale(OStim.GetSexPartner(AggressiveActor))) ; If the aggressive actor is female and their partner is not
			Console("Starting FemDom scene")
			FemDom = True
		Else
			Console("Starting MaleDom scene")
			MaleDom = True
		EndIf
	Else
		If (OStim.IsActorActive(PlayerRef))
			Agent = OStim.GetSexPartner(PlayerRef)
		Else
			Console("Player is not active")
			Agent = DomActor
		EndIf
	EndIf

	Lesbian = False
	Gay = False

	If (OStim.IsFemale(DomActor) && OStim.IsFemale(SubActor))
		Lesbian = True
	ElseIf (!OStim.IsFemale(DomActor) && !OStim.IsFemale(SubActor))
		Gay = True
	EndIf

	If (OStim.isplayerinvolved())
		Agent = OStim.GetSexPartner(PlayerRef)
	Else
		Console("Player is not active")
		Agent = DomActor
	EndIf

	NumActors = ostim.getactors().Length

	Int PulloutChance
	If (AggressiveScene)
		PulloutChance = 0
	Else
		Int Rel = Agent.GetRelationshipRank(OStim.GetSexPartner(Agent))
		If (Rel == 0)
			PulloutChance = 75
		Else
			PulloutChance = 10
		EndIf
	EndIf

	Int ForeplayChangeChance = ostim.AiSwitchChance * 2
	Float ForeplayEndThreshold
	If (AggressiveScene)
		ForeplayEndThreshold = Utility.RandomFloat(15.0, 105.0)
	Else
		Int Rel = Agent.GetRelationshipRank(OStim.GetSexPartner(Agent))
		If (Rel == 0)
			If (ChanceRoll(50))
				ForeplayEndThreshold = 125.0
			Else
				ForeplayEndThreshold = Utility.RandomFloat(10.0, 35.0)
			EndIf
		Else
			If (OStim.ChanceRoll(90))
				ForeplayEndThreshold = Utility.RandomFloat(10.0, 35.0)
			Else
				ForeplayEndThreshold = 125.0
			EndIf
		EndIf
	EndIf

	Int SexChangeChance = ostim.AiSwitchChance
	Int ForeplayChance
	If (AggressiveScene)
		ForeplayChance = 20
	Else
		ForeplayChance = 80
	EndIf

	Console("Pullout chance: " + PulloutChance)
	Console("foreplay chance: " + ForeplayChance)
	Console("foreplay change chance: " + ForeplayChangeChance)
	Console("foreplay end thresh : " + ForeplayEndThreshold)
	Console("sex change anim chance: " + SexChangeChance)

	Int Stage
	If (NumActors == 1)
		Stage = 3 ; masturbation
	ElseIf (ChanceRoll(ForeplayChance))
		Stage = 1 ; foreplay
	Else
		Stage = 2 ; main
	EndIf

	Actor CentralActor


	Bool ChangeAnimation = True
	While (OStim.isactorinvolved(DomActor) && ostim.AnimationRunning())
		If (NumActors > 1 && OStim.StringArrayContainsValue(FemaleCentricClasses, OStim.GetCurrentAnimationClass()))
			CentralActor = OStim.GetSubActor()
		Else
			CentralActor = OStim.GetDomActor()
		EndIf

		If (NumActors > 1 && OStim.GetActorExcitement(OStim.GetDomActor()) > 95)
			If (ChanceRoll(PulloutChance))
				ChangeToPulledOutVersion()
			EndIf
			Stage = 4
		EndIf

		If (Stage == 1)
			If (!ChangeAnimation)
				ChangeAnimation = OStim.ChanceRoll(ForeplayChangeChance)
			EndIf

			If (ChangeAnimation)
				ChangeAnimation = False
				Console("Changing to other foreplay animation")
				String Animation = GetRandomForeplayAnimation(MaleCentric = MaleDom, FemaleCentric = FemDom, Aggressive = OStim.IsSceneAggressiveThemed())
				If (Animation != "")
					Warp(Animation)
				EndIf
			EndIf

			If (OStim.GetActorExcitement(CentralActor) > ForeplayEndThreshold)
				ChangeAnimation = True
				Console("Changing to sex animation")
				Stage = 2
			EndIf
		ElseIf (Stage == 2)
			If (!ChangeAnimation)
				ChangeAnimation = OStim.ChanceRoll(SexChangeChance)
			EndIf

			If (ChangeAnimation)
				ChangeAnimation = False
				Console("Changing to other sex animation")
				String Animation = getRandomSexAnimation(MaleCentric = MaleDom, femaleCentric = FemDom, Aggressive = OStim.IsSceneAggressiveThemed())
				If (Animation != "")
					Warp(animation)
				EndIf
			EndIf
		ElseIf (Stage == 3)
			If (!ChangeAnimation)
				ChangeAnimation = OStim.ChanceRoll(SexChangeChance)
			EndIf

			If (ChangeAnimation)
				ChangeAnimation = False
				Console("Changing to another masturbation animation")
				String Animation = GetRandomMasturbationAnimation(OStim.IsFemale(OStim.GetDomActor()))
				If (Animation != "")
					Warp(Animation)
				EndIf
			EndIf
		EndIf

		Utility.Wait(6)

		While (OStim.PauseAI && OStim.AnimationRunning())
			Utility.Wait(1)
		EndWhile
	EndWhile
	Console("Closed AI thread")
EndEvent

 
Function StartAI()
	Console("Firing off AI thread")
	SendModEvent("ostim_start_ai")
EndFunction

String Function GetRandomForeplayAnimation(Bool MaleCentric = False, Bool FemaleCentric = False, Bool Aggressive = False)
	Int Animations = GetAllSexualAnimations()
	Animations = FilterOutAggressiveAnimations(Animations, Aggressive)

	If (Aggressive)
		If (FemDom)
			Animations = ODatabase.GetAnimationsByMainActor(Animations, 1)
		Else
			Animations = ODatabase.GetAnimationsByMainActor(Animations, 0)
		EndIf
	EndIf

	Int NumAnimations = ODatabase.GetLengthOArray(Animations)
	If (NumAnimations < 1)
		Console("No foreplay Animations with these parameters")
	EndIf


	string[] secondSet

	If (MaleCentric)
		secondSet = MaleCentricClasses
	Elseif (FemaleCentric)
		secondSet = FemaleCentricClasses
	Else
		secondSet = none
	EndIf

	string sceneID = GetAnimationThatMatchesClassArray(Animations, ForeplayClasses, secondSet)

	if sceneID != "none"
		return sceneID
	endif

	Console("No sex Animations with these parameters")
	Animations = GetAllSexualAnimations()

	sceneID = GetAnimationThatMatchesClassArray(Animations, MainSexClasses)

	if sceneID != "none"
		return sceneID
	endif

	Return ""
EndFunction

String Function GetRandomMasturbationAnimation(Bool FemaleCentric)
	Int Animations = GetAllSexualAnimations()

	Int NumAnimations = ODatabase.GetLengthOArray(Animations)
	If (NumAnimations < 1)
		Console("No masturbation animations with these parameters")
	EndIf

	string[] secondSet

	If (FemaleCentric)
		secondSet = FemaleMasturbationClasses
	Else
		secondSet = MaleMasturbationClasses
	EndIf

	string sceneID = GetAnimationThatMatchesClassArray(Animations, MasturbationClasses, secondSet)

	if sceneID != "none"
		return sceneID
	endif
	Console("No masturbation scenes were found.")
	return ""
EndFunction

String Function GetRandomSexAnimation(Bool MaleCentric = False, Bool FemaleCentric = False, Bool Aggressive = False)
	Int Animations = GetAllSexualAnimations()
	Animations = FilterOutAggressiveAnimations(Animations, Aggressive)

	If (Aggressive)
		If (FemDom)
			Animations = ODatabase.GetAnimationsByMainActor(Animations, 1)

			Int CowgirlAnims = GetAllSexualAnimations()
			CowgirlAnims = ODatabase.GetAnimationsWithName(CowgirlAnims, "cow",  AllowPartialResult = True)

			Int[] Merge = new Int[2]
			Merge[0] = Animations
			Merge[1] = CowgirlAnims

			Animations = ODatabase.MergeOArrays(Merge)
		Else
			Animations = ODatabase.GetAnimationsByMainActor(Animations, 0)
		EndIf
	EndIf

	Int NumAnimations = ODatabase.GetLengthOArray(Animations)
	If (NumAnimations < 1)
		Console("No sex Animations with these parameters")
		Animations = GetAllSexualAnimations()
	EndIf

	string sceneID = GetAnimationThatMatchesClassArray(Animations, MainSexClasses)

	if sceneID != "none"
		return sceneID
	endif

	Console("No sex Animations with these parameters")
	Animations = GetAllSexualAnimations()

	sceneID = GetAnimationThatMatchesClassArray(Animations, MainSexClasses)

	if sceneID != "none"
		return sceneID
	endif

	Return ""
EndFunction

Function ChangeToPulledOutVersion()
	Console("trying pullout")
	String Pos = ODatabase.GetPositionData(OStim.GetCurrentAnimationOID())

	Int Animations = ODatabase.GetAnimationsWithPositionData(getAllSexualAnimations(), Pos)
	Animations = ODatabase.GetAnimationsWithAnimationClass(Animations, "Po")

	If (ODatabase.getLengthOArray(Animations) > 0)
		Int Animation = ODatabase.getObjectOArray(Animations, 0)
		OStim.WarpToAnimation(ODatabase.GetSceneID(animation))
		OStim.SetCurrentAnimationSpeed(ODatabase.GetMaxSpeed(Animation))
	EndIf
EndFunction

Int Function GetAllSexualAnimations()
	Int Animations = ODatabase.GetAnimationsWithActorCount(ODatabase.GetDatabaseOArray(), NumActors)
	Animations = ODatabase.GetHubAnimations(Animations, False)
	Animations = ODatabase.GetTransitoryAnimations(Animations, False)

	If (OStim.UsingBed())
		Animations = removeStandingAnimations(Animations)
	EndIf

	If (!Gay)
		Animations = ODatabase.GetAnimationsWithName(Animations, "Gay",  AllowPartialResult = True, Negative = True)
	Elseif (Gay) && (OStim.OnlyGayAnimsInGayScenes)
		Int PossibleAnims = ODatabase.GetAnimationsWithName(Animations, "Gay",  AllowPartialResult = True, Negative = False)
		If ODatabase.getLengthOArray(PossibleAnims) > 1
			Animations = PossibleAnims
		EndIf 
	EndIf

	If (!Lesbian)
		Animations = ODatabase.GetAnimationsWithName(Animations, "Lesbian",  AllowPartialResult = True, Negative = True)
	Elseif (Lesbian) && (OStim.OnlyGayAnimsInGayScenes)
		Int PossibleAnims = ODatabase.GetAnimationsWithName(Animations, "Lesbian",  AllowPartialResult = True, Negative = False)
		If ODatabase.getLengthOArray(PossibleAnims) > 1
			Animations = PossibleAnims
		EndIf 
	EndIf

	
	Return Animations
EndFunction

Int Function FilterOutAggressiveAnimations(Int Animations, Bool Allow = False)
	Return ODatabase.GetAnimationsByAggression(Animations, Allow)
EndFunction

Int Function RemoveStandingAnimations(Int Animations)
	Console("Filtering standing Animations")
	Int Ret = ODatabase.NewOArray()

	Int i = 0
	Int max = ODatabase.GetLengthOArray(Animations)
	While (i < max)
		String Pos = ODatabase.getPositionData(ODatabase.GetObjectOArray(Animations, i))

		If (StringUtil.Find(Pos, "S") == -1)
			ODatabase.appendObjectOArray(ret, ODatabase.GetObjectOArray(Animations, i))
		EndIf

		i += 1
	EndWhile

	Return Ret
EndFunction

String Function GetAnimationThatMatchesClassArray(int Animations, string[] classes, string[] secondClassSet = none)
	Animations = ODatabase.ShuffleOArray(Animations)

	int i = 0 
	int max = ODatabase.GetLengthOArray(Animations)

	While i < max 
		Int Animation = ODatabase.GetObjectOArray(Animations, ostim.RandomInt(0, max))
		String AnimationClass = ODatabase.GetAnimationClass(Animation)

		If (OStim.StringArrayContainsValue(classes, AnimationClass))
			If secondClassSet != none 
				If (OStim.StringArrayContainsValue(secondClassSet, AnimationClass))
					return ODatabase.GetSceneID(Animation)
				EndIf
			else 
				return ODatabase.GetSceneID(Animation)
		    EndIf
		EndIf

		i += 1
	EndWhile

	return "none"
EndFunction

Function Warp(String aScene)
	If (OStim.UseAutoFades && OStim.IsActorActive(PlayerRef))
		ostim.FadeToBlack(1)
	EndIf

	OStim.WarpToAnimation(aScene)

	If (OStim.UseAutoFades && OStim.IsActorActive(PlayerRef))
		Utility.Wait(0.55)
		ostim.FadeFromBlack(1)
	EndIf
EndFunction

Function Console(String In)
	OsexIntegrationMain.Console(In)
EndFunction

Bool Function ChanceRoll(Int Chance)
	Return OStim.ChanceRoll(Chance)
EndFunction

Function OnGameLoad()
	;Console("Fixing AI thread")
	;RegisterForModEvent("ostim_start", "Ostimstart")
	RegisterForModEvent("ostim_start_ai", "AI_Thread")
EndFunction
