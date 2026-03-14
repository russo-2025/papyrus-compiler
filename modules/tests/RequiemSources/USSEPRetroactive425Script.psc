Scriptname USSEPRetroactive425Script extends Quest  

Quest Property MQ101 Auto
USSEP_VersionTrackingScript Property USSEPTracking Auto
USSEPRetroactive426Script Property Retro426 Auto

LeveledItem Property LItemBanditWeaponArrows Auto
LeveledItem Property DLC2BaseArrowNordic75 Auto

Function Process()
	debug.trace( "USSEP 4.2.5 Retroactive Updates Complete" )
	USSEPTracking.LastVersion = 425
	Retro426.Process()
	Stop()
EndFunction
