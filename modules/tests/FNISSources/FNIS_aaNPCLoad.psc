scriptname FNIS_aaNPCLoad extends ReferenceAlias

FNIS_aaQuest Property FNIS_Q Auto
FNIS_aaQuest2 Property FNIS_Q2 Auto

int updateReadyCounter

event OnInit()
	; check if base data already calculated, come back if not (max 3 times)

	if ( GetRef() != none )
;		Debug.Trace("FNIS aa - NPC with AA found:" + GetRef().GetBaseObject().GetName())
		Utility.wait(0.5)
		if FNIS_Q.bConvDataReady
;			Debug.Trace("FNIS aa - NPC ready to update:" + GetRef().GetBaseObject().GetName())
			FNIS_Q2.UpdateAAvariables(GetActorReference())
		else
;			Debug.Trace("FNIS aa - NPC update delayed:" + GetRef().GetBaseObject().GetName())
			updateReadyCounter = 2
			RegisterForSingleUpdate(1.0)
		endif
	endif
endEvent

Event OnUpdate()
	if FNIS_Q.bConvDataReady
;		Debug.Trace("FNIS aa - NPC ready to update:" + GetRef().GetBaseObject().GetName())
		FNIS_Q2.UpdateAAvariables(GetActorReference())
	else
		updateReadyCounter -= 1
		if ( updateReadyCounter > 0 )
;			Debug.Trace("FNIS aa - NPC update delayed:" + GetRef().GetBaseObject().GetName())
			RegisterForSingleUpdate(1.0)
		else
;			Debug.Trace("FNIS aa - NPC CANNOT UPDATE:" + GetRef().GetBaseObject().GetName())
		endif
	endif	
endEvent
