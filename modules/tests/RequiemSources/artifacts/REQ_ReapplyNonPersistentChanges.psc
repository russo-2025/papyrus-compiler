ScriptName REQ_ReapplyNonPersistentChanges Extends ReferenceAlias

REQ_AncientDawnguardWarAxe Property AncientDawnguardWarAxeScript Auto
REQ_Dawnbreaker Property DawnbreakerScript Auto
REQ_EbonyBlade Property EbonyBladeScript Auto
REQ_GlassBowOfTheStagPrince Property GlassBowOfTheStagPrinceScript Auto
REQ_MaceOfMolagBal Property MaceOfMolagBalScript Auto
REQ_Volendrung Property VolendrungScript Auto


Event OnPlayerLoadGame()
	If AncientDawnguardWarAxeScript != None
		AncientDawnguardWarAxeScript.ReapplyNonPersistentChanges()
	EndIf
	If DawnbreakerScript != None
		DawnbreakerScript.ReapplyNonPersistentChanges()
	EndIf
	If EbonyBladeScript != None
		EbonyBladeScript.ReapplyNonPersistentChanges()
	EndIf
	If GlassBowOfTheStagPrinceScript != None
		GlassBowOfTheStagPrinceScript.ReapplyNonPersistentChanges()
	EndIf
	If MaceOfMolagBalScript != None
		MaceOfMolagBalScript.ReapplyNonPersistentChanges()
	EndIf
	If VolendrungScript != None
		VolendrungScript.ReapplyNonPersistentChanges()
	EndIf
EndEvent
