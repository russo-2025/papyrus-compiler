;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 2
Scriptname PRKF_RFTI_Player_Cannibalism_0C000802 Extends Perk Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akTargetRef, Actor akActor)
;BEGIN CODE
    akActor.StartCannibal(akTargetRef As Actor)
    CorpsesEaten.Mod(1.0)
    If FollowsGreenpact.GetValue() != 0.0
        GreenPactBlessing.Cast(akActor)
    EndIf
    If akActor.IsEquipped(RingOfNamira)
        NamirasBlessing1.Cast(akActor)
        NamirasBlessing2.Cast(akActor)
    EndIf
    NextCorpseEating.SetValue(GameDaysPassed.GetValue() + HoursBetweenCorpseEating / 24.0)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Armor Property RingOfNamira  Auto  

GlobalVariable Property CorpsesEaten  Auto  
GlobalVariable Property FollowsGreenpact  Auto  
GlobalVariable Property GameDaysPassed  Auto  
GlobalVariable Property NextCorpseEating  Auto  

Float Property HoursBetweenCorpseEating  Auto  

Spell Property NamirasBlessing1  Auto  
Spell Property NamirasBlessing2  Auto  
Spell Property GreenPactBlessing  Auto  
