Scriptname REQ_PersistentSpellRescaling extends ActiveMagicEffect
{remove and reapply a set of spells when the NPC is loaded. This is necessary to ensure that they
use all scaling factors from perks. Spells in the list are skipped if the NPC doesn't have them.}

FormList Property SpellsToReapply Auto
{reapply each of these persistent spells when the player closes the perk menu and has the spell}
GlobalVariable Property Version_Installed Auto
{the global containing the version stamp of the esp}
GlobalVariable Property Version_Active Auto
{the global containing the version stamp of the savegame}
Spell Property Ability Auto
{the ability that contains the effect with this script (to dispel from player immediately)}

Actor npc

Event OnEffectStart(Actor akTarget, Actor akCaster)
    npc = akTarget
    If npc == Game.GetPlayer()
        npc.removeSpell(Ability)
        return
    EndIf
    If !npc.Is3DLoaded()
        GotoState("inactive")
        return
    EndIf
    While (Version_Active.GetValueInt() != Version_Installed.GetValueInt() )
        Utility.Wait(0.5)
    EndWhile
    RefreshAbilities()
EndEvent

State inactive
    Event OnLoad()
        GoToState("")
        RefreshAbilities()
	EndEvent
EndState

Function RefreshAbilities()
    Int index = spellsToReapply.getSize()
    While ( index > 0 )
        index = index - 1
        Spell persistentSpell = spellsToReapply.getAt(index) as Spell
        If (persistentSpell != None && npc.hasSpell(persistentSpell))
            npc.removeSpell(persistentSpell)
            Utility.wait(0.001)
            npc.addSpell(persistentSpell, false)
        EndIf
    EndWhile
EndFunction
