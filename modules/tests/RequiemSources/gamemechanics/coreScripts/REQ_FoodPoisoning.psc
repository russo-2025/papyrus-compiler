ScriptName REQ_FoodPoisoning Extends REQ_CoreScript

Keyword Property ContaminatedFood Auto

Spell Property FoodPoisoning Auto

Message Property MessageFoodPoisoning Auto

Function initScript(Int currentVersion, Int nevVersion)
EndFunction

Function shutdownScript(Int currentVersion, Int nevVersion)
EndFunction

Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
    If akBaseObject As Potion
        If akBaseObject.HasKeyword(ContaminatedFood)
            Float DiseaseResist = Player.GetActorValue("DiseaseResist")
            If DiseaseResist < Utility.RandomFloat(0.0, 100.0)
                Player.AddSpell(FoodPoisoning, False)
                MessageFoodPoisoning.Show()
            EndIf
        EndIf
    EndIf
EndEvent
