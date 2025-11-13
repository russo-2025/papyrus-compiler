scriptname FNIS_aaPlayerLoad extends ReferenceAlias

FNIS_aaQuest2 Property FNIS_Q2 Auto

event OnPlayerLoadGame()
	Debug.Trace("FNIS AA started (load)")
;	Debug.Notification("FNIS AA started (load)")

; Start Quest 2 after load to determine and apply necessary changes to the FNIS AA group animvariables
	FNIS_Q2.start()
	
endEvent

