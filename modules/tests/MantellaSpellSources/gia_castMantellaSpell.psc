;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 2
Scriptname gia_castMantellaSpell Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
if WhatDo == "exit"
	akspeaker.SetFactionRank(giafac_follower, -2)
	getowningquest().reset()
	getowningquest().stop()
	Utility.Wait(0.5)
	getowningquest().start()
	akspeaker.EvaluatePackage()
	endif

	if WhatDo == "speakto"
	;gia_Mantellaspell.cast(game.getplayer(),akspeaker)
	game.getplayer().AddToFaction(giafac_mantella)
	endif
	
	if WhatDo == "NPCjoinfac"
	akspeaker.AddToFaction(giafac_mantella)
	endif

	if WhatDo == "NPCkickfac"
	akspeaker.removefromfaction(giafac_mantella)
	endif
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

string Property WhatDo  Auto
Spell property gia_MantellaSpell Auto
Faction property giafac_Mantella Auto
Faction Property giafac_Follower  Auto  
