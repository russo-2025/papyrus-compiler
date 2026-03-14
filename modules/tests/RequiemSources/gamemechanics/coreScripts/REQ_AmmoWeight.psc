Scriptname REQ_AmmoWeight extends REQ_CoreScript

Keyword[] Property ammoWeightIdentifiers Auto
{keyword identifier for a weight class, maps to ammoWeightDummies with the same array index}
Weapon[] Property ammoWeightDummies Auto
{hidden weight dummy item for a weight class, maps to ammoWeightIdentifiers with the same array index}

Keyword Property weightlessAmmo Auto
{keyword identifier for ammunition that is treated as weightless}
Int Property defaultWeightIndex Auto
{index from ammoWeightDummies which is used for any ammunition without a known weight keyword}

MiscObject Property displayQuiver Auto
{a quest item added to the player's inventory to display the total ammunition weight}
ObjectReference Property hideQuiverPlace Auto
{container where the quiver can be hidden when the player has no ammunition in their inventory}

Event OnItemAdded(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
    Int index = getWeightIndexForObject(akBaseItem)
    If (index != -1)
        addAmmoWeight(ammoWeightDummies[index], aiItemCount)
    EndIf
EndEvent

Event OnItemRemoved(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akDestContainer)
    Int index = getWeightIndexForObject(akBaseItem)
    If (index != -1)
        removeAmmoWeight(ammoWeightDummies[index], aiItemCount)
    ElseIf (akBaseItem == displayQuiver && akDestContainer != hideQuiverPlace)
        akDestContainer.removeItem(displayQuiver, 1, true, hideQuiverPlace)
    EndIf
EndEvent

Event OnPlayerLoadGame()
    parent.OnPlayerLoadGame()
    updateAmmoWeightDisplay()
EndEvent

Function initScript(Int currentVersion, Int nevVersion)
    Int i = 0
    While (i < ammoWeightDummies.length)
        player.removeItem(ammoWeightDummies[i], Player.GetItemCount(ammoWeightDummies[i]), true)
        i += 1
    EndWhile

    Int[] ammoCounts = Utility.createIntArray(ammoWeightIdentifiers.length, 0)

    i = player.getNumItems()
    While (i > 0)
        i -= 1
        Form object = player.getNthForm(i)
        Int ammoType = getWeightIndexForObject(object)
        If (ammoType >= 0)
            ammoCounts[ammoType] = ammoCounts[ammoType] + Player.GetItemCount(object)
        EndIf
    EndWhile

    i = 0
    While (i < ammoWeightDummies.length)
        player.addItem(ammoWeightDummies[i], ammoCounts[i], true)
        i += 1
    EndWhile
    updateAmmoWeightDisplay()
EndFunction

Function shutdownScript(Int currentVersion, Int nevVersion)
    ; a new one will be spawned by restarting the parent quest
    player.removeItem(displayQuiver, player.getItemCount(displayQuiver), true)
    hideQuiverPlace.removeItem(displayQuiver, hideQuiverPlace.getItemCount(displayQuiver), true)
    Int i = 0
    While (i < ammoWeightDummies.length)
        player.removeItem(ammoWeightDummies[i], Player.GetItemCount(ammoWeightDummies[i]), true)
        i += 1
    EndWhile
EndFunction

Int Function getWeightIndexForObject(Form object)
    Ammo ammunition = object as Ammo
    If (ammunition != None)
        Int i = 0
        While (i < ammoWeightIdentifiers.length)
            If ammunition.hasKeyword(ammoWeightIdentifiers[i])
                return i
            EndIf
            i += 1
        EndWhile
        If (ammunition.hasKeyword(weightlessAmmo))
            return -1
        Else
            return defaultWeightIndex
        EndIf
    EndIf
    return -1
EndFunction

Function addAmmoWeight(Weapon type, Int count)
    If (count > 0)
        player.addItem(type, count, true)
        updateAmmoWeightDisplay()
    EndIf
EndFunction

Function removeAmmoWeight(Weapon type, Int count)
    If (count > 0)
        player.removeItem(type, count, true)
        updateAmmoWeightDisplay()
    EndIf
EndFunction

Function updateAmmoWeightDisplay()
    Float weight = 0
    Int i = 0
    While (i < ammoWeightIdentifiers.length)
        weight += player.getItemCount(ammoWeightDummies[i]) * ammoWeightDummies[i].getWeight()
        i += 1
    EndWhile
    displayQuiver.setWeight(weight)
    If (weight == 0 && player.getItemCount(displayQuiver) > 0)
        player.removeItem(displayQuiver, 1, true, hideQuiverPlace)
    ElseIf (weight > 0 && player.getItemCount(displayQuiver) == 0)
        hideQuiverPlace.removeItem(displayQuiver, 1, true, player)
    EndIf
EndFunction
