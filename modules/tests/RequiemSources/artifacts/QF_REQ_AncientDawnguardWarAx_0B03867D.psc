;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname QF_REQ_AncientDawnguardWarAx_0B03867D Extends Quest Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0()
;BEGIN AUTOCAST TYPE REQ_AncientDawnguardWarAxe_Reset
Quest __temp = self as Quest
REQ_AncientDawnguardWarAxe kmyQuest = __temp as REQ_AncientDawnguardWarAxe
;END AUTOCAST
;BEGIN CODE
kmyquest.ResetOnDawn()
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
