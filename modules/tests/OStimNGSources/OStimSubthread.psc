ScriptName OStimSubthread extends ReferenceAlias

import OUtils

; Subthreads
;
; These are OStim threads exclusively for NPC on NPC scenes. Player scenes should never go in a subthread.
; Subthreads have similar features to the main thread, including the sending of events, tracking of actor excitement
; and AI (they change animations dynamically as the scene progresses). They also have support for furniture animations.
;
;
; Please note that most utility functions from OSexIntegrationMain will give you information about the actors in the
; main thread, and NOT about actors in the subthreads! To get information from Subthreads, you must either work with the
; information sent in the events, or fetch the Subthread alias and work directly with the properties and functions
; provided in this script.
;
;
; The main thread has always ID -1. You access its info from the OSexIntegrationMain script.
;
; Subthreads have ID 0 thru 9. But there is only one subthread script...
; So how would you access info from a specific subthread?
; It's easy! For example, if you want to get the dom actor from the subthread with ID 2, you would do the following:
;
;		Quest subthreadQuest = Game.GetFormFromFile(0x000806, "OStim.esp") as Quest
;		OStimSubthread thread = subthreadQuest.GetNthAlias(2) as OStimSubthread
;		Actor subthreadDom
;		if thread.IsInUse() ; always check if thread is active first!
;			subthreadDom = thread.GetActor(0)
;		endif
;


int property id auto
 
OSexIntegrationMain OStim

actor PlayerRef

string[] CurrentScene

int threadID = -1

Event OnInit()
	id = GetID()
	ostim = GetOStim()
	PlayerRef = Game.GetPlayer()
EndEvent

Event OnEnd(String EventName, String StrArgs, Float EndingThreadID, Form Sender)
	If ThreadID != EndingThreadID
		Return
	EndIf

	ThreadID = -1
	; legacy event
	SendModEvent("ostim_subthread_end", "", id)

	UnregisterForModEvent("ostim_thread_end")
	UnregisterForModEvent("ostim_actor_orgasm")
EndEvent

Event OnOrgasm(String EventName, String SceneID, Float OrgasmThreadID, Form OrgasmedActor)
	If ThreadID != OrgasmThreadID
		Return
	EndIf

	OrgasmedActor.SendModEvent("ostim_subthread_orgasm", SceneID, id)
EndEvent


;
;			██╗   ██╗████████╗██╗██╗     ██╗████████╗██╗███████╗███████╗
;			██║   ██║╚══██╔══╝██║██║     ██║╚══██╔══╝██║██╔════╝██╔════╝
;			██║   ██║   ██║   ██║██║     ██║   ██║   ██║█████╗  ███████╗
;			██║   ██║   ██║   ██║██║     ██║   ██║   ██║██╔══╝  ╚════██║
;			╚██████╔╝   ██║   ██║███████╗██║   ██║   ██║███████╗███████║
;			 ╚═════╝    ╚═╝   ╚═╝╚══════╝╚═╝   ╚═╝   ╚═╝╚══════╝╚══════╝
;
; 				Utility functions for Subthread

Function StartAI()
	OThread.StartAutoMode(threadID)
EndFunction

bool Function IsInUse()
	return threadID > 0
endfunction

int Function GetScenePassword()
	return threadID
endfunction

ObjectReference Function GetFurniture()
	Return OThread.GetFurniture(threadID)
EndFunction

Bool Function AnimationRunning()
	OThread.IsRunning(threadID)
EndFunction

Actor Function GetActor(int Index)
	Return OThread.GetActor(threadID, Index)
EndFunction

Actor[] Function GetActors()
	Return OThread.GetActors(threadID)
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

float Function GetHighestExcitement()
	float Highest = 0
	Actor[] Actors = OThread.GetActors(threadID)

	int i = Actors.Length
	While i
		i -= 1
		float Excitement = OActor.GetExcitement(Actors[i])
		If Excitement > Highest
			Highest = Excitement
		EndIf
	EndWhile

	return Highest
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

Function AdjustAnimationSpeed(float amount)
	OThread.SetSpeed(threadID, OThread.GetSpeed(threadID) + (amount As int))
EndFunction

Function IncreaseAnimationSpeed()
	OThread.SetSpeed(threadID, OThread.GetSpeed(threadID) + 1)
EndFunction

Function DecreaseAnimationSpeed()
	OThread.SetSpeed(threadID, OThread.GetSpeed(threadID) - 1)
EndFunction

Function SetCurrentAnimationSpeed(Int InSpeed)
	OThread.SetSpeed(threadID, InSpeed)
EndFunction


; ██████╗ ███████╗██████╗ ██████╗ ███████╗ ██████╗ █████╗ ████████╗███████╗██████╗ 
; ██╔══██╗██╔════╝██╔══██╗██╔══██╗██╔════╝██╔════╝██╔══██╗╚══██╔══╝██╔════╝██╔══██╗
; ██║  ██║█████╗  ██████╔╝██████╔╝█████╗  ██║     ███████║   ██║   █████╗  ██║  ██║
; ██║  ██║██╔══╝  ██╔═══╝ ██╔══██╗██╔══╝  ██║     ██╔══██║   ██║   ██╔══╝  ██║  ██║
; ██████╔╝███████╗██║     ██║  ██║███████╗╚██████╗██║  ██║   ██║   ███████╗██████╔╝
; ╚═════╝ ╚══════╝╚═╝     ╚═╝  ╚═╝╚══════╝ ╚═════╝╚═╝  ╚═╝   ╚═╝   ╚══════╝╚═════╝ 

; this is only here to not break old addons, don't use it in new addons, use whatever they're calling instead

bool Function StartScene(actor dom, actor sub = none, actor third = none, float time = 120.0, ObjectReference bed = none, bool isAggressive = false, actor aggressingActor = none, bool LinkToMain = false)
	return StartSubthreadScene(dom, sub = sub, zThirdActor = third, startingAnimation = "", furnitureObj = bed, withAI = true, isAggressive = isAggressive, aggressingActor = aggressingActor)
EndFunction

Float Function GetActorExcitement(Actor Act) ; at 100, Actor orgasms
	Return OActor.GetExcitement(Act)
EndFunction

Function SetActorExcitement(Actor Act, Float Value)
	OActor.SetExcitement(Act, Value)
EndFunction

Function AddActorExcitement(Actor Act, Float Value)
	OActor.ModifyExcitement(Act, Value)
EndFunction

Bool Function DidAnyActorDie()
	Actor[] Actors = OThread.GetActors(threadID)
	int i = Actors.Length
	While i
		i -= 1
		If Actors[i].IsDead()
			Return true
		EndIf
	EndWhile
	return false
EndFunction

Bool Function IsAnyActorInCombat()
	Actor[] Actors = OThread.GetActors(threadID)
	int i = Actors.Length
	While i
		i -= 1
		If Actors[i].GetCombatState() != 0
			Return true
		EndIf
	EndWhile
	return false
EndFunction

Function runOsexCommand(string cmd)
EndFunction

Function AutoIncreaseSpeed()
	; this is done in C++ now
EndFunction

Function Orgasm(Actor Act)
	OActor.Climax(Act)
EndFunction

Function EndAnimation()
	OThread.Stop(threadID)
EndFunction

Function WarpToAnimation(String Animation) 
	OThread.WarpTo(threadID, Animation, false)
EndFunction

; You probably want to call OThread.QuickStart, a Builder is only needed for more complex parameters
bool Function StartSubthreadScene(actor dom, actor sub = none, actor zThirdActor = none, string startingAnimation = "", ObjectReference furnitureObj = none, bool withAI = true, bool isAggressive = false, actor aggressingActor = none)
	if ThreadID > 0
		Console("Subthread is already in use")
		return false
	endif

	Console("Starting subthread with ID: " + id)

	int BuilderID = OThreadBuilder.Create(OActorUtil.ToArray(dom, sub, zThirdActor))
	OThreadBuilder.SetFurniture(BuilderID, furnitureObj)
	OThreadBuilder.SetStartingAnimation(BuilderID, startingAnimation)

	If !withAI
		OThreadBuilder.NoAutoMode(BuilderID)
	EndIf
	If aggressingActor
		Actor[] DominantActors = new Actor[1]
		DominantActors[0] = aggressingActor
		OThreadBuilder.SetDominantActors(BuilderID, DominantActors)
	EndIf

	threadID = OThreadBuilder.Start(BuilderID)

	SendModEvent("ostim_subthread_start", "", id)

	; legacy event
	RegisterForModEvent("ostim_thread_end", "OnEnd")
	RegisterForModEvent("ostim_actor_orgasm", "OnOrgasm")

	Return true
EndFunction