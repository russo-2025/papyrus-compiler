ScriptName OAIUtils

; Common shared functions for AI (auto mode and NPC on NPC scenes)

String Function GetRandomForeplayAnimation(Actor[] Actors, string FurnitureType, int Aggressor = -1, bool isAggressorFemale, bool isLesbian, bool isGay) Global
	string typesAny = ""
	string typesBlacklist = "analsex,tribbing,vaginalsex"

	string standingTag = ""
	If FurnitureType == ""
		standingTag = OCSV.CreateCSVMatrix(Actors.Length, "standing")
	EndIf

	string actorTagBlacklist = ""
	If FurnitureType == "bed"
		actorTagBlacklist = OCSV.CreateCSVMatrix(Actors.Length, "standing")
	EndIf

	string sceneTags = ""
	if isLesbian
		sceneTags = "lesbian"
	elseif isGay
		sceneTags = "gay"
	endif

	If Aggressor != -1
		string id = ""
		string aggSceneTags = OCSV.ConcatCSVLists(sceneTags, "aggressive")
		string aggressorTag = OCSV.CreateSingleCSVMatrixEntry(Aggressor, "aggressor")
		string aggressorList = OCSV.CreateCSVList(4, Aggressor)

		OSexIntegrationMain OStim = OUtils.GetOStim()
		If isAggressorFemale
			id = OLibrary.GetRandomSceneSuperloadCSV(Actors, FurnitureType, AllSceneTags = aggSceneTags, AnyActorTagForAny = standingTag, AllActorTagsForAll = aggressorTag, ActorTagBlacklistForAll = actorTagBlacklist, AnyActionType = "cunnilingus,grindingthigh", AnyActionActor = "," + Aggressor, AnyActionTarget = Aggressor, AnyActionPerformer = AggressorList, ActionBlacklistTypes = typesBlacklist)
		Else
			id = OLibrary.GetRandomSceneSuperloadCSV(Actors, FurnitureType, AllSceneTags = aggSceneTags, AnyActorTagForAny = standingTag, AllActorTagsForAll = aggressorTag, ActorTagBlacklistForAll = actorTagBlacklist, AnyActionType = "blowjob,boobjob,buttjob,thighjob", AnyActionTarget = AggressorList, AnyActionPerformer = AggressorList, ActionBlacklistTypes = typesBlacklist)
		EndIf

		If id != ""
			Return id
		EndIf
	EndIf

	Return OLibrary.GetRandomSceneSuperloadCSV(Actors, FurnitureType, AllSceneTags = sceneTags, AnyActorTagForAny = standingTag, ActorTagBlacklistForAll = actorTagBlacklist, AnyActionType = "analfingering,blowjob,boobjob,buttjob,cunnilingus,footjob,grindingthigh,handjob,lickingnipples,lickingpenis,lickingtesticles,rimjob,rubbingclitoris,rubbingpenisagainstface,suckingnipples,thighjob,vaginalfingering", ActionBlacklistTypes = typesBlacklist)
EndFunction

String Function GetRandomSexAnimation(Actor[] Actors, string FurnitureType, int Aggressor = -1, bool isLesbian, bool isGay) Global
	string typesAny = "analsex,vaginalsex"

	string standingTag = ""
	If FurnitureType == ""
		standingTag = OCSV.CreateCSVMatrix(Actors.Length, "standing")
	EndIf

	string actorTagBlacklist = ""
	If FurnitureType == "bed"
		actorTagBlacklist = OCSV.CreateCSVMatrix(Actors.Length, "standing")
	EndIf

	string sceneTags = ""
	if isLesbian
		sceneTags = "lesbian"
		typesAny += ",tribbing"
	elseif isGay
		sceneTags = "gay"
	endif

	If Aggressor != -1
		string aggSceneTags = OCSV.ConcatCSVLists(sceneTags, "aggressive")
		string aggressorTag = OCSV.CreateSingleCSVMatrixEntry(Aggressor, "aggressor")
		string aggressorList = OCSV.CreateCSVList(3, Aggressor)

		string id = OLibrary.GetRandomSceneSuperloadCSV(Actors, FurnitureType, AllSceneTags = aggSceneTags, AnyActorTagForAny = standingTag, AllActorTagsForAll = aggressorTag, ActorTagBlacklistForAll = actorTagBlacklist, AnyActionType = typesAny, AnyActionPerformer = AggressorList)

		If id != ""
			Return id
		EndIf
	EndIf

	Return OLibrary.GetRandomSceneSuperloadCSV(Actors, FurnitureType, AllSceneTags = sceneTags, AnyActorTagForAny = standingTag, ActorTagBlacklistForAll = actorTagBlacklist, AnyActionType = typesAny)
EndFunction

String Function GetPulledOutVersion(Actor[] Actors, string FurnitureType, string SceneID, string[] positionTags) Global
	OSexIntegrationMain.Console("trying pullout")

	string[] ActorTags = PapyrusUtil.StringArray(Actors.Length)

	int i = Actors.Length
	While i
		i -= 1
		ActorTags[i] = OCSV.ToCSVList(OMetadata.GetActorTagOverlap(SceneID, i, positionTags)) ; get position tags
	EndWhile

	string ActorTagsCSV = OCSV.ToCSVMatrix(ActorTags)

	return OLibrary.GetRandomSceneSuperloadCSV(Actors, FurnitureType, AllActorTagsForAll = ActorTagsCSV, AnyActionType = "malemasturbation", AnyActionActor = "0")
EndFunction
