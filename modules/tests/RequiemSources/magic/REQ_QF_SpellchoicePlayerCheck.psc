;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 29
Scriptname REQ_QF_SpellchoicePlayerCheck Extends Quest Hidden

;BEGIN FRAGMENT Fragment_12
Function Fragment_12()
;BEGIN CODE
If ( Game.GetPlayer().HasPerk(Perklist[10]) )
    Spellchoices.SetStage(300)
EndIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_20
Function Fragment_20()
;BEGIN CODE
If ( Game.GetPlayer().HasPerk(Perklist[18]) )
    Spellchoices.SetStage(460)
EndIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_28
Function Fragment_28()
;BEGIN CODE
If ( Game.GetPlayer().HasPerk(Perklist[0]) && REQ_VersionInstalled.GetValue() >= 160 )
    Spellchoices.SetStage(100)
EndIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_11
Function Fragment_11()
;BEGIN CODE
If ( Game.GetPlayer().HasPerk(Perklist[9]) )
    Spellchoices.SetStage(280)
EndIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_22
Function Fragment_22()
;BEGIN CODE
If ( Game.GetPlayer().HasPerk(Perklist[20]) )
    Spellchoices.SetStage(500)
EndIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_17
Function Fragment_17()
;BEGIN CODE
If ( Game.GetPlayer().HasPerk(Perklist[15]) )
    Spellchoices.SetStage(400)
EndIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_24
Function Fragment_24()
;BEGIN CODE
If ( Game.GetPlayer().HasPerk(Perklist[22]) )
    Spellchoices.SetStage(540)
EndIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_10
Function Fragment_10()
;BEGIN CODE
If ( Game.GetPlayer().HasPerk(Perklist[8]) )
    Spellchoices.SetStage(260)
EndIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_25
Function Fragment_25()
;BEGIN CODE
If ( Game.GetPlayer().HasPerk(Perklist[23]) )
    Spellchoices.SetStage(560)
EndIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_13
Function Fragment_13()
;BEGIN CODE
If ( Game.GetPlayer().HasPerk(Perklist[11]) )
    Spellchoices.SetStage(320)
EndIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_14
Function Fragment_14()
;BEGIN CODE
If ( Game.GetPlayer().HasPerk(Perklist[12]) )
    Spellchoices.SetStage(340)
EndIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_5
Function Fragment_5()
;BEGIN CODE
If ( Game.GetPlayer().HasPerk(Perklist[3]) && REQ_VersionInstalled.GetValue() >= 160 )
    Spellchoices.SetStage(160)
EndIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_7
Function Fragment_7()
;BEGIN CODE
If ( Game.GetPlayer().HasPerk(Perklist[5]) )
    Spellchoices.SetStage(200)
EndIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_19
Function Fragment_19()
;BEGIN CODE
If ( Game.GetPlayer().HasPerk(Perklist[17]) )
    Spellchoices.SetStage(440)
EndIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_18
Function Fragment_18()
;BEGIN CODE
If ( Game.GetPlayer().HasPerk(Perklist[16]) )
    Spellchoices.SetStage(420)
EndIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_15
Function Fragment_15()
;BEGIN CODE
If ( Game.GetPlayer().HasPerk(Perklist[13]) )
    Spellchoices.SetStage(360)
EndIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_23
Function Fragment_23()
;BEGIN CODE
If ( Game.GetPlayer().HasPerk(Perklist[21]) )
    Spellchoices.SetStage(520)
EndIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_3
Function Fragment_3()
;BEGIN CODE
If ( Game.GetPlayer().HasPerk(Perklist[1]) && REQ_VersionInstalled.GetValue() >= 160 )
    Spellchoices.SetStage(120)
EndIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_16
Function Fragment_16()
;BEGIN CODE
If ( Game.GetPlayer().HasPerk(Perklist[14]) )
    Spellchoices.SetStage(380)
EndIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_4
Function Fragment_4()
;BEGIN CODE
If ( Game.GetPlayer().HasPerk(Perklist[2]) && REQ_VersionInstalled.GetValue() >= 160 )
    Spellchoices.SetStage(140)
EndIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_21
Function Fragment_21()
;BEGIN CODE
If ( Game.GetPlayer().HasPerk(Perklist[19]) )
    Spellchoices.SetStage(480)
EndIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_6
Function Fragment_6()
;BEGIN CODE
If ( Game.GetPlayer().HasPerk(Perklist[4]) && REQ_VersionInstalled.GetValue() >= 160 )
    Spellchoices.SetStage(180)
EndIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_26
Function Fragment_26()
;BEGIN CODE
If ( Game.GetPlayer().HasPerk(Perklist[24]) )
    Spellchoices.SetStage(580)
EndIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_9
Function Fragment_9()
;BEGIN CODE
If ( Game.GetPlayer().HasPerk(Perklist[7]) )
    Spellchoices.SetStage(240)
EndIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_8
Function Fragment_8()
;BEGIN CODE
If ( Game.GetPlayer().HasPerk(Perklist[6]) )
    Spellchoices.SetStage(220)
EndIf
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Quest Property Spellchoices  Auto  
{the real spell-choice script}

Perk[] Property PerkList  Auto  

GlobalVariable Property REQ_VersionInstalled Auto
{version control to determine if message should be suppressed while updating to 1.6}
