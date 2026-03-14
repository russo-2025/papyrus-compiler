;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 6
Scriptname PRKF_Survival_TempleBlessing_050009EE Extends Perk Hidden

;BEGIN FRAGMENT Fragment_2
Function Fragment_2(ObjectReference akTargetRef, Actor akActor)
;BEGIN CODE
int offeringAmount = Survival_ShrineGoldOfferingAmount.GetValueInt()

int choice = Survival_ShrineGoldOfferingMessage.Show(offeringAmount)
if choice == 0
    if akActor.GetItemCount(Gold001) < offeringAmount
        Survival_ShrineNotEnoughGoldMessage.Show()
        return
    endif

    akActor.RemoveItem(Gold001, offeringAmount)
    
    TempleBlessingScript baseShrine = akTargetRef as TempleBlessingScript
    DLC2TempleShrineScript dlc2Shrine = akTargetRef as DLC2TempleShrineScript
    if baseShrine
    	baseShrine.OnActivate(akActor)
    elseif dlc2Shrine
    	dlc2Shrine.OnActivate(akActor)
    endif
endif
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

MiscObject Property Gold001  Auto  

GlobalVariable Property Survival_ShrineGoldOfferingAmount  Auto  

Message Property Survival_ShrineGoldOfferingMessage  Auto  

Message Property Survival_ShrineNotEnoughGoldMessage  Auto  
