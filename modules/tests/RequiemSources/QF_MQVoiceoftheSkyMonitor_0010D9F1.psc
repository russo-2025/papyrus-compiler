;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 3
Scriptname QF_MQVoiceoftheSkyMonitor_0010D9F1 Extends Quest Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0()
;BEGIN CODE
; player has killed an animal with Voice of the Sky active - remove effect
; debug.trace(self + " player has killed an animal with Voice of the Sky active - remove spell")
Game.GetPlayer().RemoveSpell(VoiceoftheSkySpell)
Stop()
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Spell Property VoiceoftheSkySpell  Auto  
