Scriptname REQ_TemperedEquipment extends ActiveMagicEffect
{This script will temper the armor of the affected actor when it is first initialized}

Keyword[] Property Keywords Auto
{the keywords that should be tempered}
String[] Property quality Auto
{the quality tier that should be used for the keyword with the same index, as defined in datastorage}
REQ_TemperingData Property datastorage Auto
{the quest alias that contains all relevant data for tempering}
GlobalVariable Property Version_Installed Auto
{the global containing the version stamp of the esp}
GlobalVariable Property Version_Active Auto
{the global containing the version stamp of the savegame}

Event OnEffectStart(Actor akTarget, Actor akCaster)
	int timeout = 10
	While !akTarget.Is3DLoaded()
		Utility.Wait(0.5)
		timeout -= 1
		If timeout == 0
			return
		EndIf
	EndWhile
	While (Version_Active.GetValueInt() != Version_Installed.GetValueInt() )
		Utility.Wait(0.5)
	EndWhile
	ProcessItems(akTarget)
EndEvent

Function ProcessItems(Actor npc)
	int slotsChecked = 0x0
    int thisSlot = 0x01
	Armor current
    while (thisSlot < 0x80000000)
		current = npc.GetWornForm(thisSlot) as Armor
        If (Math.LogicalAnd(slotsChecked, thisSlot) != thisSlot)	
			if current != None
				TemperItem(npc, thisSlot, current)
				slotsChecked += current.GetSlotMask()
			else
				slotsChecked += thisSlot
			EndIf
		EndIf
		thisslot *= 2
	EndWhile
EndFunction

Function TemperItem(Actor npc, int slotmask, Armor item)
	Int i = 0
	Int j = -1
	Float[] sample
	While i < Keywords.length
		If item.HasKeyword(Keywords[i])
			sample = datastorage.GetRange(quality[i])
			j = Utility.RandomInt(0, sample.length - 1)
			WornObject.SetItemHealthPercent(npc, 1, slotmask , sample[j])
			i = Keywords.length
		EndIf
		i += 1
	EndWhile
EndFunction
