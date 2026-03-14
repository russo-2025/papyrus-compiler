;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 2
Scriptname DLC1_QF_Patch1_6_UpdateQuest_0100097F Extends Quest Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0()
;BEGIN CODE
; FOR PATCH 1.6
; debug.trace("PATCH 1.6 QUEST HAS STARTED")

; 81462 -- making sure player can't use Hircine's Ring if he's not a werewolf
if (Game.GetPlayer().HasSpell(HircinesRingPower) && !C00.PlayerHasBeastBlood)
   Game.GetPlayer().RemoveSpell(HircinesRingPower)
endif

IsNewGame = True  ; Added by Requiem

;KILL THE PATCH QUEST
Stop()
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

CompanionsHousekeepingScript Property C00 Auto
Spell Property HircinesRingPower auto

Bool Property IsNewGame Auto  ; Added by Requiem
