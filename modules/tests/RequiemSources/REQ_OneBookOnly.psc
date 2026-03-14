Scriptname REQ_OneBookOnly extends ObjectReference  
; this script makes sure that the player gets only a single Guide to trainers (Sealed Journal)
; if book and the faded note are taken from a container, a global variable will be set to 100
; thereby disabling its appearance on any other containers that can be found. However, since
; unopened containers may still hold copies, we should only be distributing the book/faded note list
; to temporary containers only, such as the Imperial Battlemage at Helgen or Imperial Couriers.
; The former is cleaned up later in Helgen and the latter are created as new instances in random encounters.
; We can distribute the book in object references, outside of containers, in the world or interior cells.
; These references are based on a parent that gets disabled once the book is taken or read.
; However we don't want to immediately disable the reference because it will make the book disappear in
; front of the player's eyes! So we're setting a very low frequency loop that will stop a few minutes after
; the player moves to another cell. And then we can finally disable the parent which will remove all
; set copies from existence.

GlobalVariable Property VariableName Auto
ObjectReference Property EnableParent = None Auto

Event OnContainerChanged(ObjectReference akNewContainer, ObjectReference akOldContainer)
	VariableName.SetValue(100.0)
	if EnableParent
		EnableParent.disable()
	endif
EndEvent

Event OnRead()
	VariableName.SetValue(100.0)
	if EnableParent
		cell currentcell = Game.GetPlayer().GetParentCell()
		while currentcell == Game.GetPlayer().GetParentCell()
			Utility.Wait(600.0)
		endwhile
		EnableParent.disable()
	endif
EndEvent