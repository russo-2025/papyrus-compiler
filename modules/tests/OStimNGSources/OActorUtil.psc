;/* OActorUtil
* * collection of utility functions related to actors
* *
* * required API Version: 7.0 (29)
*/;
ScriptName OActorUtil

;  ██████╗ ██████╗ ███╗   ██╗██████╗ ██╗████████╗██╗ ██████╗ ███╗   ██╗███████╗
; ██╔════╝██╔═══██╗████╗  ██║██╔══██╗██║╚══██╔══╝██║██╔═══██╗████╗  ██║██╔════╝
; ██║     ██║   ██║██╔██╗ ██║██║  ██║██║   ██║   ██║██║   ██║██╔██╗ ██║███████╗
; ██║     ██║   ██║██║╚██╗██║██║  ██║██║   ██║   ██║██║   ██║██║╚██╗██║╚════██║
; ╚██████╗╚██████╔╝██║ ╚████║██████╔╝██║   ██║   ██║╚██████╔╝██║ ╚████║███████║
;  ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝╚═════╝ ╚═╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝

;/* HasSchlong
* * checks if the actor has a schlong
* * if SoS full is not installed or use SoS gender was disabled in the MCM this will simply check for the actors sex
* * if SoS full is installed this will check for the SOS_SchlongifiedFaction
* * additionally it will check for SOS - No Futanari Schlong and SOS Female Pubic Hair
* * (to not consider those schlongified even though they are in the faction)
* * 
* * @param: Act, the actor to check
* *
* * @return: true if the actor has a schlong, otherwise false
*/;
bool Function HasSchlong(Actor Act) Global Native

;/* FulfillsCondition
* * checks if the actor fulfills the condition functions of the perk
* * the actor does not have to have the perk for this
* *
* * required API version: 7.3 (0x07030000)
* *
* * @param: Act, the actor to check
* * @param: Condition, the perk whichs condition functions to run on the actor
* *
* * @return: true if the actor fulfills the condition functions, otherwise false
*/;
bool Function FulfillsCondition(Actor Act, Perk Condition) Global Native

;/* FulfillsAnyCondition
* * checks if the actor fulfills the condition functions of any of the perks
* * the actor does not have to have the perks for this
* *
* * required API version: 7.3 (0x07030000)
* *
* * @param: Act, the actor to check
* * @param: Conditions, the perks whichs condition functions to run on the actor
* *
* * @return: true if the actor fulfills the condition functions of at least one perk, otherwise false
*/;
bool Function FulfillsAnyCondition(Actor Act, Perk[] Conditions) Global Native

;/* FulfillsAnyCondition
* * checks if the actor fulfills the condition functions of all of the perks
* * the actor does not have to have the perks for this
* *
* * required API version: 7.3 (0x07030000)
* *
* * @param: Act, the actor to check
* * @param: Conditions, the perks whichs condition functions to run on the actor
* *
* * @return: true if the actor fulfills the condition functions of all perks, otherwise false
*/;
bool Function FulfillsAllConditions(Actor Act, Perk[] Conditions) Global Native


; ██████╗ ██╗ █████╗ ██╗      ██████╗  ██████╗ ██╗   ██╗███████╗
; ██╔══██╗██║██╔══██╗██║     ██╔═══██╗██╔════╝ ██║   ██║██╔════╝
; ██║  ██║██║███████║██║     ██║   ██║██║  ███╗██║   ██║█████╗  
; ██║  ██║██║██╔══██║██║     ██║   ██║██║   ██║██║   ██║██╔══╝  
; ██████╔╝██║██║  ██║███████╗╚██████╔╝╚██████╔╝╚██████╔╝███████╗
; ╚═════╝ ╚═╝╚═╝  ╚═╝╚══════╝ ╚═════╝  ╚═════╝  ╚═════╝ ╚══════╝

;/* SayTo
* * says the dialogue topic the the target actor
* *
* * @param: Act, the actor to say the topic
* * @param: Target, the actor to say the topic to
* * @param: Dialogue, the topic to say
*/;
Function SayTo(Actor Act, Actor Target, Topic Dialogue) Global Native

;/* SayAs
* * says the dialogue topic to the target actor
* *
* * required API version: 7.3 (0x07030000)
* *
* * @param: Act, the actor to say the topic
* * @param: Target, the actor to say the topic to
* * @param: Dialogue, the topic to say
* * @param: Voice, the voice type to say the topic with
*/;
Function SayAs(Actor Act, Actor Target, Topic Dialogue, VoiceType Voice) Global Native


;  █████╗ ██████╗ ██████╗  █████╗ ██╗   ██╗███████╗
; ██╔══██╗██╔══██╗██╔══██╗██╔══██╗╚██╗ ██╔╝██╔════╝
; ███████║██████╔╝██████╔╝███████║ ╚████╔╝ ███████╗
; ██╔══██║██╔══██╗██╔══██╗██╔══██║  ╚██╔╝  ╚════██║
; ██║  ██║██║  ██║██║  ██║██║  ██║   ██║   ███████║
; ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   ╚══════╝

;/* EmptyArray
* * returns a size zero array of type Actor
* *
* * @return: a size zero array
*/;
Actor[] Function EmptyArray() Global Native

;/* CreateActorArray
* * returns an actor array of the desired size
* *
* * @param: Size, the size of the array
* * @param: Filler, a default element to fill the array with
* *
* * @return: an actor array
*/;
Actor[] Function CreateArray(int Size, Actor Filler = None) Global Native

;/* ToArray
* * creates an array out of the given actors, sorts out none entires
* *
* * @param: X, the actors for the array
* *
* * @return: an array of actors
*/;
Actor[] Function ToArray(Actor One = None, Actor Two = None, Actor Three = None, Actor Four = None, Actor Five = None, Actor Six = None, Actor Seven = None, Actor Eight = None, Actor Nine = None, Actor Ten = None) Global Native

;/* SortActors
* * sorts all dominant actors to the front of the array and all non dominant actors to the back
* * within those groups sorts all actors with schlongs to the front and all actors without to the back
* * obeys the MCM settings for two actor scenes if no player index is passed
* * other than this the order is not altered (i.e. the sorting algorithm is stable)
* *
* * @param: Actors, the array of actors to sort
* * @param: DominantActors, an array of dominant actors
* * @param: PlayerIndex, if given the player will be sorted to this index, independent of them having a schlong or not
* *
* * @return: the sorted array 
*/;
Actor[] Function Sort(Actor[] Actors, Actor[] DominantActors, int PlayerIndex = -1) Global Native

;/* SelectIndexAndSortActors
* * pops up the index selection for the player depending on the MCM settings and then sorts the actors according to the selected value
* *
* * @param: Actors, the array of actors to sort
* * @param: DominantActors, a list of dominant actors
* *
* * @return: the sorted array
*/;
Actor[] Function SelectIndexAndSort(Actor[] Actors, Actor[] DominantActors) Global
	OSexIntegrationMain OStim = OUtils.GetOStim()
	
	bool SelectRole = false
	If Actors.Length >= 3
		SelectRole = OStim.PlayerSelectRoleThreesome
	ElseIf Actors.Length == 2
		If OStim.AppearsFemale(Actors[0]) == OStim.AppearsFemale(Actors[1])
			SelectRole = OStim.PlayerSelectRoleGay
		Else
			SelectRole = OStim.PlayerSelectRoleStraight
		EndIf
	EndIf
	If SelectRole
		OStim.OStimRoleSelectionCount.value = Actors.Length
		int PlayerIndex = OStim.OStimRoleSelectionMessage.Show()
		Return OActor.SortActors(Actors, PlayerIndex)
	Else
		Return Sort(Actors, DominantActors)
	EndIf
EndFunction

;/* GetActorsInRange
* * gets all actors in range around the center
* *
* * required API version: 7.3.4 (0x07030040)
* *
* * @param: Center, the center to base the search on
* * @param: Range, the range of the search in Skyrim units (100 units are approx. 1 meter)
* * @param: IncludeCenter, if false the center will not be included in the list
* * @param: IncludePlayer, if false the player will not be included in the list
* * @param: OStimActorsOnly, if true only actors that qualify for OStim scenes will be included in the list
* * @param: Condition, if set only actors who fulfill the condition functions of the perk will be included
* * 	actors do not have to have the perk for this, just fulfill it's condition functions
* *
* * @return: an array of all actors in range (and fulfilling the condition, if one is given)
*/;
Actor[] Function GetActorsInRangeV2(ObjectReference Center, float Range, bool IncludeCenter = false, bool IncludePlayer = true, bool OStimActorsOnly = false, Perk Condition = None) Global Native

;/* ActorsToNames
* * converts an array of actors to an array of their names
* *
* * required API version: 7.3 (0x07030000)
* *
* * @param: Actors, the array of actors
* *
* * @return: a string array containing all the actor names
*/;
string[] Function ActorsToNames(Actor[] Actors) Global Native


; ██████╗ ███████╗██████╗ ██████╗ ███████╗ ██████╗ █████╗ ████████╗███████╗██████╗ 
; ██╔══██╗██╔════╝██╔══██╗██╔══██╗██╔════╝██╔════╝██╔══██╗╚══██╔══╝██╔════╝██╔══██╗
; ██║  ██║█████╗  ██████╔╝██████╔╝█████╗  ██║     ███████║   ██║   █████╗  ██║  ██║
; ██║  ██║██╔══╝  ██╔═══╝ ██╔══██╗██╔══╝  ██║     ██╔══██║   ██║   ██╔══╝  ██║  ██║
; ██████╔╝███████╗██║     ██║  ██║███████╗╚██████╗██║  ██║   ██║   ███████╗██████╔╝
; ╚═════╝ ╚══════╝╚═╝     ╚═╝  ╚═╝╚══════╝ ╚═════╝╚═╝  ╚═╝   ╚═╝   ╚══════╝╚═════╝

; required API version: 7.3.0 (0x07030000)
Actor[] Function GetActorsInRange(ObjectReference Center, float Range, bool IncludeCenter = false, bool IncludePlayer = true, Perk Condition = None) Global
	Return GetActorsInRangeV2(Center, Range, IncludeCenter, IncludePlayer, false, Condition)
EndFunction