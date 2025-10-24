ScriptName OStimSubthread extends ReferenceAlias
import outils 

; Subthreads
;
; These are simplified OStim threads, exclusively for running multiple scenes at the same time
; Scenes in a subthread are implied to be unimportant, as such these threads intentionally do not fire any events 
; and only allow limited api interaction with them. This is to keep OStim development simplified, since you only need to 
; worry about the main thread
;
; Because of the above, you should only use these if you are certain multiple scenes need to play.
; NPC on NPC scenes should still usually go in the main thread when possible. Player scenes should never go in a subthread.
;
; Main threads can be transformed into a subthread by calling InheritFromMain()
; Subthreads can be soft-synchronized to the main thread with linktomain(). When the main ends, if linked, the subthread will close too


;todo: beds, redressing

int property id auto
bool property LinkedToMain auto
bool inuse
 
OSexIntegrationMain ostim
ODatabaseScript ODatabase
actor playerref


actor property domactor auto
actor property subactor auto
actor property thirdactor auto
actor[] property actorlist auto
actor aggressiveActor

form[] domclothes
form[] subclothes
form[] thirdclothes

ObjectReference property currentbed Auto
int property currentOID auto
bool property aggressive Auto
string[] currScene

int property currspeed auto 
int property maxSpeed auto
float property timePerSpeed auto 

float property estimatedLength auto

bool Function StartScene(actor dom, actor sub = none, actor third = none, float time = 120.0, ObjectReference bed = none, bool isaggressive = false, actor aggressingActor = none, bool LinkToMain = false)
	if inuse
		Console("Subthread is already in use")
		return false
	endif 

	Console("Starting subthread with ID: " + id)

	inuse = true 

	domactor = dom 
	subactor = sub 
	thirdactor = third 

	actor[] actro = PapyrusUtil.ActorArray(3)
	actro[0] = dom
	actro[1] = sub 
	actro[2] = third


	aggressive = isaggressive
	aggressiveActor = aggressingActor
	currentbed = bed 

	if currentbed
		AlignToBed()
	endif


	actorlist =  PapyrusUtil.removeactor(actro, none)

	ScaleActors()
	Strip()


	string StartingAnimation = GetRandomAnimationForScene()

	CurrScene = OSA.MakeStage()
	OSA.SetActorsStim(currScene, actorlist)
	OSA.SetModule(CurrScene, "0Sex", StartingAnimation, "")
	OSA.StimStart(CurrScene)

	currSpeed = 1 
	maxSpeed = ODatabase.GetMaxSpeed(currentOID)


	

	if LinkToMain
		LinkToMain()
	else 
		timePerSpeed = (time / maxSpeed) + OSANative.RandomFloat(-2.0, 2.0)
		if timePerSpeed < 1
			timePerSpeed = 1
		endif 
	endif 

	estimatedLength = (maxSpeed * timePerSpeed) + 8
	
	Console("Subthread will use time/speed: " + timePerSpeed)
	registerforsingleupdate(timePerSpeed)

	return true

EndFunction

bool Function InheritFromMain()
	inuse = true 

	Console("Moving main thread to subthread with ID: " + id)

	domactor = ostim.GetDomActor() 
	subactor = ostim.GetSubActor()
	thirdactor = ostim.getthirdactor()

	actor[] actro = PapyrusUtil.ActorArray(3)
	actro[0] = domactor
	actro[1] = subactor
	actro[2] = thirdactor

	currentOID = ostim.GetCurrentAnimationOID()
	maxSpeed = ostim.GetCurrentAnimationMaxSpeed()
	currSpeed = ostim.GetCurrentAnimationSpeed()
	currentbed = ostim.GetBed()

	currScene = ostim.GetScene()

	GetClothesFromMain()

	timePerSpeed = (ostim.GetEstimatedTimeUntilEnd() / maxSpeed) + OSANative.RandomFloat(-2.0, 2.0)
	if timePerSpeed < 1
		timePerSpeed = 1
	endif 

	ostim.ForceStop()

	while ostim.AnimationRunning()
		Utility.Wait(0.25)
	endwhile

	estimatedLength = (maxSpeed * timePerSpeed) + 8

	Console("Subthread will use time/speed: " + timePerSpeed)
	registerforsingleupdate(timePerSpeed)

	return true
EndFunction

Function LinkToMain()
	LinkedToMain = true


	registerForOStim()
	float time = ostim.GetEstimatedTimeUntilEnd() + 25
	timePerSpeed = (time / maxSpeed) + OSANative.RandomFloat(-2.0, 2.0)
endfunction 

bool Function IsInUse()
	return inuse
endfunction


Event OnUpdate()

	if !ostim.IsActorActive(domactor)
		Console("Subthread actor was not active. Error?")
		EndAnimation()
		return
	endif 

	if currSpeed >= maxSpeed
		if LinkedToMain && ostim.AnimationRunning()
			
		else
			Orgasm()
			Return
		endif 
		
	else 
		IncreaseAnimationSpeed()
	endif 

	RegisterForSingleUpdate(timePerSpeed)
EndEvent

Function Orgasm()
	SetAnimationSpeed(1)
	Utility.Wait(3)
	DecreaseAnimationSpeed()
	Utility.Wait(5)
	endanimation()
EndFunction

Function Strip()
	OUndressScript oundress = ostim.GetUndressScript()

	domclothes = oundress.storeequipmentforms(domactor, true)
	oundress.UnequipForms(domactor, domclothes)
	if subactor
		subclothes = oundress.storeequipmentforms(subactor, true)
		oundress.UnequipForms(subactor, subclothes)
		if thirdactor
			thirdclothes = oundress.storeequipmentforms(thirdactor, true)
			oundress.UnequipForms(thirdactor, thirdclothes)
		endif 
	endif 

EndFunction

Function Redress() 
	OUndressScript oundress = ostim.GetUndressScript()
	bool object = (domclothes[0] as ObjectReference) != none 
	Console("Subthread redress with objects: " + object)

	if object
		oundress.PickUpThings(domactor, outils.FormArrToObjRefArr(domclothes))
	else 
		oundress.EquipForms(domactor, domclothes)
	endif 
	if subactor
		if object
			oundress.PickUpThings(subactor, outils.FormArrToObjRefArr(subclothes))
		else 
			oundress.EquipForms(subactor, subclothes)
		endif 
		if thirdactor
			if object
				oundress.PickUpThings(thirdactor, outils.FormArrToObjRefArr(thirdclothes))
			else 
				oundress.EquipForms(thirdactor, thirdclothes)
			endif 
		endif 
	endif
EndFunction

Function GetClothesFromMain()
	OUndressScript oundress = ostim.GetUndressScript()

	if ostim.TossClothesOntoGround
		domclothes = outils.ObjRefArrToFormArr( oundress.getdrops(actorlist[0]) )
		subclothes = outils.ObjRefArrToFormArr( oundress.getdrops(actorlist[1]) )
		thirdclothes = outils.ObjRefArrToFormArr( oundress.getdrops(actorlist[2]) )
	else 
		domclothes = oundress.DomEquipmentForms
		subclothes = oundress.SubEquipmentForms
		thirdclothes = oundress.ThirdEquipmentForms
	endif 

EndFunction

function runOsexCommand(string cmd)
	string[] Plan = new string[2]
	Plan[1] = cmd

	osa.setPlan(currScene, Plan) 
	osa.stimstart(currScene)
EndFunction

Function ScaleActors()
	ostim.ScaleToHeight(domactor, ostim.DomScaleHeight)
	if subactor
		ostim.ScaleToHeight(subactor, ostim.SubScaleHeight)
		if thirdactor
			ostim.ScaleToHeight(thirdactor, ostim.ThirdScaleHeight)
		endif 
	endif 
EndFunction

Function SetAnimationSpeed(int to)
	{Increase or decrease the animation speed by the amount}
	string speed = to
	runOsexCommand("$Speed,0," + speed)
	
	currSpeed = to
EndFunction

Function IncreaseAnimationSpeed()
	;If (AnimSpeedAtMax)
	;	Return
	;EndIf
	Console("Increasing subthread speed")
	setanimationspeed(currspeed + 1)
EndFunction

Function DecreaseAnimationSpeed()
	;If (CurrentSpeed < 1)
	;	Return
	;EndIf
	setanimationspeed(currspeed - 1)
EndFunction

Function EndAnimation() ;todo - isloaded check, see osexintegrationmain endanimation()
	Console("Subthread " + id + " ending..." )

	If DomActor.GetParentCell() != playerref.GetParentCell()
		; Attempting to end the scene when the actors are not loaded will fail
		SendModEvent("0SA_GameLoaded")
	else 
		runOsexCommand("$endscene")
	endif 

	UnregisterForUpdate()
	UnregisterForAllModEvents()
	if !ostim.AnimationRunning()
		ODatabase.Unload()
	endif 

	Redress()

	SendModEvent("ostim_end", numArg = id)

	inuse = false

EndFunction

Function AlignToBed() ;todo, merge this logic with main?
	Float DomSpeed = CurrentBed.GetDistance(DomActor) * 100
	Float BedOffsetX = 0
	Float BedOffsetY = 0
	Float BedOffsetZ = 0

	Int Offset = 31

	float[] bedCoords = OSANative.GetCoords(CurrentBed)
	bedCoords[0] = bedCoords[0] + BedOffsetX
	bedCoords[1] = bedCoords[1] + BedOffsetY
	bedCoords[2] = bedCoords[2] + BedOffsetZ
	Float BedAngleX = Currentbed.GetAngleX()
	Float BedAngleY = Currentbed.GetAngleY()
	Float BedAngleZ = Currentbed.GetAngleZ()

	DomActor.TranslateTo(bedCoords[0], bedCoords[1], bedCoords[2], BedAngleX, BedAngleY, BedAngleZ, DomSpeed, afMaxRotationSpeed = 100)
	DomActor.SetAngle(BedAngleX, BedAngleY, BedAngleZ)
	Utility.Wait(0.05)

	Float OffsetY = Math.Sin(OUtils.TrigAngleZ(DomActor.GetAngleZ())) * 30
	Float OffsetX = Math.Cos(OUtils.TrigAngleZ(DomActor.GetAngleZ())) * 30

	SubActor.MoveTo(DomActor, OffsetX, OffsetY, 0)
	SubActor.SetAngle(BedAngleX, BedAngleY, BedAngleZ)
EndFunction

string Function GetRandomAnimationForScene() ; todo aggressive stuff
	Int Animations = ODatabase.GetAnimationsWithActorCount(ODatabase.GetDatabaseOArray(), actorlist.Length)
	Animations = ODatabase.GetHubAnimations(Animations, False)
	Animations = ODatabase.GetTransitoryAnimations(Animations, False)

	if currentbed
		int bedanims 

		Int i = 0
		Int max = ODatabase.GetLengthOArray(Animations)
		While (i < max)
			String Pos = ODatabase.getPositionData(ODatabase.GetObjectOArray(Animations, i))

			If (outils.stringcontains(pos, "S"))
				ODatabase.appendObjectOArray(bedanims, ODatabase.GetObjectOArray(Animations, i))
			EndIf

		i += 1
		EndWhile

		Animations = bedanims

	endif 

	currentoid = ODatabase.GetObjectOArray(animations, OSANative.RandomInt(0, ODatabase.GetLengthOArray(Animations) - 1))

	string ret = ODatabase.GetSceneID( currentoid )
	Console("Subthread using scene: " + ret)
	return ret
endfunction



Function registerForOStim()
	RegisterForModEvent("ostim_end", "OstimEnd")
	RegisterForModEvent("ostim_orgasm", "OstimOrgasm")
endfunction


Event OstimEnd(string eventName, string strArg, float numArg, Form sender)
	EndAnimation()
EndEvent

Event OstimOrgasm(string eventName, string strArg, float numArg, Form sender)
	actor orgasmer = ostim.GetMostRecentOrgasmedActor()

	if ostim.EndOnDomOrgasm
		if orgasmer == ostim.getdomactor()
			Orgasm()
		endif
	endif 

	if ostim.EndOnSubOrgasm
		if orgasmer == ostim.getsubactor()
			Orgasm()
		endif
	endif 
endevent





Event OnInit()
	id = GetID()
	ostim = OUtils.GetOStim()
	odatabase = ostim.GetODatabase()
	playerref = game.GetPlayer()
	inuse = false
EndEvent