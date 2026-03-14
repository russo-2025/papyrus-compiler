Scriptname REQ_Magic_Spellchoices Extends Quest
{generic function for spell choices after magic perk acquiring}

ReferenceAlias[] Property Toggles Auto
ReferenceAlias[] Property Names Auto

ObjectReference Property Yes Auto
ObjectReference Property No Auto
ObjectReference Property Hide Auto
MiscObject[] Property Dummies Auto
GlobalVariable Property Spellcount Auto
Message Property Menu Auto
FormList Property Empty Auto

Function Spellchoice (FormList spelllist, int max)
	Int i = 0
	Int exit = Toggles.Length
	Int chosen = 0
	Int choice = 0
	Int j = 0
	Actor player = Game.GetPlayer()
	; Game.AddperkPoints(1)
	While ( i < spelllist.GetSize() && j < exit )
		If (!player.HasSpell(spelllist.GetAt(i) as Spell))
			Dummies[j].SetName("\n"+(j+1)+") "+spelllist.GetAt(i).GetName()+": ")
			Toggles[j].ForceRefTo(No)
			Empty.AddForm(spelllist.GetAt(i))
			j += 1
		EndIf
		i += 1
	EndWhile
	While ( j < Names.Length )
		Toggles[j].ForceRefTo(Hide)
		Dummies[j].SetName("")
		j += 1
	EndWhile
	Spellcount.SetValueInt(Empty.GetSize())
	If (Empty.GetSize() == 0)
		; Self.Stop()
		Return
	EndIf
	While ( choice != exit )
		choice = Menu.Show(max as Float)
		If (choice < exit)
			If ( Toggles[choice].GetReference() == No && chosen < max)
				Toggles[choice].ForceRefTo(Yes)
				chosen += 1
			ElseIf ( Toggles[choice].GetReference() == Yes )
				Toggles[choice].ForceRefTo(No)
				chosen -= 1
			EndIf
		EndIf
	EndWhile
	i = 0
	While ( i < Empty.GetSize())
		If ( Toggles[i].GetReference() == Yes )
			player.AddSpell(Empty.GetAt(i) as Spell)
		EndIf
		i += 1
	EndWhile
	Empty.Revert()
	; Self.Stop()
EndFunction
