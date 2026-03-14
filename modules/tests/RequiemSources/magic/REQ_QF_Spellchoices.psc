;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 27
Scriptname REQ_QF_Spellchoices Extends Quest Hidden

;BEGIN ALIAS PROPERTY Toggle4
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Toggle4 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Toggle9
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Toggle9 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Toggle5
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Toggle5 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Toggle2
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Toggle2 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Name5
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Name5 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Toggle3
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Toggle3 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Name9
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Name9 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Name2
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Name2 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Toggle8
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Toggle8 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Name3
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Name3 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Toggle7
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Toggle7 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Name7
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Name7 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Name6
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Name6 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Name4
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Name4 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Name8
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Name8 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Toggle6
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Toggle6 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Toggle1
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Toggle1 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Name1
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Name1 Auto
;END ALIAS PROPERTY

;BEGIN FRAGMENT Fragment_9
Function Fragment_9()
;BEGIN AUTOCAST TYPE REQ_Magic_Spellchoices
Quest __temp = self as Quest
REQ_Magic_Spellchoices kmyQuest = __temp as REQ_Magic_Spellchoices
;END AUTOCAST
;BEGIN CODE
If (REQ_VersionInstalled.GetValue() >= 160)
    kmyQuest.Spellchoice(spelllist_conjuration[2], 2)
EndIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_14
Function Fragment_14()
;BEGIN AUTOCAST TYPE REQ_Magic_Spellchoices
Quest __temp = self as Quest
REQ_Magic_Spellchoices kmyQuest = __temp as REQ_Magic_Spellchoices
;END AUTOCAST
;BEGIN CODE
If (REQ_VersionInstalled.GetValue() >= 160)
    kmyQuest.Spellchoice(spelllist_destruction[2], 2)
EndIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_0
Function Fragment_0()
;BEGIN AUTOCAST TYPE REQ_Magic_Spellchoices
Quest __temp = self as Quest
REQ_Magic_Spellchoices kmyQuest = __temp as REQ_Magic_Spellchoices
;END AUTOCAST
;BEGIN CODE
If (REQ_VersionInstalled.GetValue() >= 160)
    kmyQuest.Spellchoice(spelllist_illusion[0], 2)
EndIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_10
Function Fragment_10()
;BEGIN AUTOCAST TYPE REQ_Magic_Spellchoices
Quest __temp = self as Quest
REQ_Magic_Spellchoices kmyQuest = __temp as REQ_Magic_Spellchoices
;END AUTOCAST
;BEGIN CODE
If (REQ_VersionInstalled.GetValue() >= 160)
    kmyQuest.Spellchoice(spelllist_conjuration[3], 2)
EndIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_26
Function Fragment_26()
;BEGIN AUTOCAST TYPE REQ_Magic_Spellchoices
Quest __temp = self as Quest
REQ_Magic_Spellchoices kmyQuest = __temp as REQ_Magic_Spellchoices
;END AUTOCAST
;BEGIN CODE
If (REQ_VersionInstalled.GetValue() >= 160)
    kmyQuest.Spellchoice(spelllist_alteration[4], 1)
EndIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_13
Function Fragment_13()
;BEGIN AUTOCAST TYPE REQ_Magic_Spellchoices
Quest __temp = self as Quest
REQ_Magic_Spellchoices kmyQuest = __temp as REQ_Magic_Spellchoices
;END AUTOCAST
;BEGIN CODE
If (REQ_VersionInstalled.GetValue() >= 160)
    kmyQuest.Spellchoice(spelllist_destruction[1], 2)
EndIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_7
Function Fragment_7()
;BEGIN AUTOCAST TYPE REQ_Magic_Spellchoices
Quest __temp = self as Quest
REQ_Magic_Spellchoices kmyQuest = __temp as REQ_Magic_Spellchoices
;END AUTOCAST
;BEGIN CODE
If (REQ_VersionInstalled.GetValue() >= 160)
    kmyQuest.Spellchoice(spelllist_conjuration[0], 2)
EndIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_25
Function Fragment_25()
;BEGIN AUTOCAST TYPE REQ_Magic_Spellchoices
Quest __temp = self as Quest
REQ_Magic_Spellchoices kmyQuest = __temp as REQ_Magic_Spellchoices
;END AUTOCAST
;BEGIN CODE
If (REQ_VersionInstalled.GetValue() >= 160)
    kmyQuest.Spellchoice(spelllist_alteration[3], 2)
EndIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_11
Function Fragment_11()
;BEGIN AUTOCAST TYPE REQ_Magic_Spellchoices
Quest __temp = self as Quest
REQ_Magic_Spellchoices kmyQuest = __temp as REQ_Magic_Spellchoices
;END AUTOCAST
;BEGIN CODE
If (REQ_VersionInstalled.GetValue() >= 160)
    kmyQuest.Spellchoice(spelllist_conjuration[4], 1)
EndIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_23
Function Fragment_23()
;BEGIN AUTOCAST TYPE REQ_Magic_Spellchoices
Quest __temp = self as Quest
REQ_Magic_Spellchoices kmyQuest = __temp as REQ_Magic_Spellchoices
;END AUTOCAST
;BEGIN CODE
If (REQ_VersionInstalled.GetValue() >= 160)
    kmyQuest.Spellchoice(spelllist_alteration[1], 2)
EndIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_22
Function Fragment_22()
;BEGIN AUTOCAST TYPE REQ_Magic_Spellchoices
Quest __temp = self as Quest
REQ_Magic_Spellchoices kmyQuest = __temp as REQ_Magic_Spellchoices
;END AUTOCAST
;BEGIN CODE
If (REQ_VersionInstalled.GetValue() >= 160)
    kmyQuest.Spellchoice(spelllist_alteration[0], 2)
EndIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_15
Function Fragment_15()
;BEGIN AUTOCAST TYPE REQ_Magic_Spellchoices
Quest __temp = self as Quest
REQ_Magic_Spellchoices kmyQuest = __temp as REQ_Magic_Spellchoices
;END AUTOCAST
;BEGIN CODE
If (REQ_VersionInstalled.GetValue() >= 160)
    kmyQuest.Spellchoice(spelllist_destruction[3], 2)
EndIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_20
Function Fragment_20()
;BEGIN AUTOCAST TYPE REQ_Magic_Spellchoices
Quest __temp = self as Quest
REQ_Magic_Spellchoices kmyQuest = __temp as REQ_Magic_Spellchoices
;END AUTOCAST
;BEGIN CODE
If (REQ_VersionInstalled.GetValue() >= 160)
    kmyQuest.Spellchoice(spelllist_restoration[3], 2)
EndIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_6
Function Fragment_6()
;BEGIN AUTOCAST TYPE REQ_Magic_Spellchoices
Quest __temp = self as Quest
REQ_Magic_Spellchoices kmyQuest = __temp as REQ_Magic_Spellchoices
;END AUTOCAST
;BEGIN CODE
If (REQ_VersionInstalled.GetValue() >= 160)
    kmyQuest.Spellchoice(spelllist_illusion[4], 1)
EndIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_18
Function Fragment_18()
;BEGIN AUTOCAST TYPE REQ_Magic_Spellchoices
Quest __temp = self as Quest
REQ_Magic_Spellchoices kmyQuest = __temp as REQ_Magic_Spellchoices
;END AUTOCAST
;BEGIN CODE
If (REQ_VersionInstalled.GetValue() >= 160)
    kmyQuest.Spellchoice(spelllist_restoration[1], 2)
EndIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_4
Function Fragment_4()
;BEGIN AUTOCAST TYPE REQ_Magic_Spellchoices
Quest __temp = self as Quest
REQ_Magic_Spellchoices kmyQuest = __temp as REQ_Magic_Spellchoices
;END AUTOCAST
;BEGIN CODE
If (REQ_VersionInstalled.GetValue() >= 160)
    kmyQuest.Spellchoice(spelllist_illusion[2], 2)
EndIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_3
Function Fragment_3()
;BEGIN AUTOCAST TYPE REQ_Magic_Spellchoices
Quest __temp = self as Quest
REQ_Magic_Spellchoices kmyQuest = __temp as REQ_Magic_Spellchoices
;END AUTOCAST
;BEGIN CODE
If (REQ_VersionInstalled.GetValue() >= 160)
    kmyQuest.Spellchoice(spelllist_illusion[1], 2)
EndIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_24
Function Fragment_24()
;BEGIN AUTOCAST TYPE REQ_Magic_Spellchoices
Quest __temp = self as Quest
REQ_Magic_Spellchoices kmyQuest = __temp as REQ_Magic_Spellchoices
;END AUTOCAST
;BEGIN CODE
If (REQ_VersionInstalled.GetValue() >= 160)
    kmyQuest.Spellchoice(spelllist_alteration[2], 2)
EndIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_21
Function Fragment_21()
;BEGIN AUTOCAST TYPE REQ_Magic_Spellchoices
Quest __temp = self as Quest
REQ_Magic_Spellchoices kmyQuest = __temp as REQ_Magic_Spellchoices
;END AUTOCAST
;BEGIN CODE
If (REQ_VersionInstalled.GetValue() >= 160)
    kmyQuest.Spellchoice(spelllist_restoration[4], 1)
EndIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_12
Function Fragment_12()
;BEGIN AUTOCAST TYPE REQ_Magic_Spellchoices
Quest __temp = self as Quest
REQ_Magic_Spellchoices kmyQuest = __temp as REQ_Magic_Spellchoices
;END AUTOCAST
;BEGIN CODE
If (REQ_VersionInstalled.GetValue() >= 160)
    kmyQuest.Spellchoice(spelllist_destruction[0], 2)
EndIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_16
Function Fragment_16()
;BEGIN AUTOCAST TYPE REQ_Magic_Spellchoices
Quest __temp = self as Quest
REQ_Magic_Spellchoices kmyQuest = __temp as REQ_Magic_Spellchoices
;END AUTOCAST
;BEGIN CODE
If (REQ_VersionInstalled.GetValue() >= 160)
    kmyQuest.Spellchoice(spelllist_destruction[4], 1)
EndIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_17
Function Fragment_17()
;BEGIN AUTOCAST TYPE REQ_Magic_Spellchoices
Quest __temp = self as Quest
REQ_Magic_Spellchoices kmyQuest = __temp as REQ_Magic_Spellchoices
;END AUTOCAST
;BEGIN CODE
If (REQ_VersionInstalled.GetValue() >= 160)
    kmyQuest.Spellchoice(spelllist_restoration[0], 2)
EndIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_8
Function Fragment_8()
;BEGIN AUTOCAST TYPE REQ_Magic_Spellchoices
Quest __temp = self as Quest
REQ_Magic_Spellchoices kmyQuest = __temp as REQ_Magic_Spellchoices
;END AUTOCAST
;BEGIN CODE
If (REQ_VersionInstalled.GetValue() >= 160)
    kmyQuest.Spellchoice(spelllist_conjuration[1], 2)
EndIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_5
Function Fragment_5()
;BEGIN AUTOCAST TYPE REQ_Magic_Spellchoices
Quest __temp = self as Quest
REQ_Magic_Spellchoices kmyQuest = __temp as REQ_Magic_Spellchoices
;END AUTOCAST
;BEGIN CODE
If (REQ_VersionInstalled.GetValue() >= 160)
    kmyQuest.Spellchoice(spelllist_illusion[3], 2)
EndIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_19
Function Fragment_19()
;BEGIN AUTOCAST TYPE REQ_Magic_Spellchoices
Quest __temp = self as Quest
REQ_Magic_Spellchoices kmyQuest = __temp as REQ_Magic_Spellchoices
;END AUTOCAST
;BEGIN CODE
If (REQ_VersionInstalled.GetValue() >= 160)
    kmyQuest.Spellchoice(spelllist_restoration[2], 2)
EndIf
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
FormList[] Property spelllist_illusion Auto
FormList[] Property spelllist_conjuration Auto  
FormList[] Property spelllist_destruction Auto
FormList[] Property spelllist_restoration Auto  
FormList[] Property spelllist_alteration Auto

GlobalVariable Property REQ_VersionInstalled Auto
{version control to determine if message should be suppressed while updating to 1.6}
