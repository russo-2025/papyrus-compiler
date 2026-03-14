Scriptname REQ_GhostlySteedScript extends Actor
{Etherealizes the player when he mounts the Ghostly Steed.
Kills the Ghostly Steed when the player dismounts him.}

Actor property PlayerREF auto
Spell property EtherealSpell auto

Bool IsMounted = false


Event OnActivate(ObjectReference akActionRef)
	if (!IsMounted && akActionRef == PlayerREF)
		Game.DisablePlayerControls(false, true, false, false, false, false, false, false) ;disallow fighting while ethereal
		PlayerREF.AddSpell(EtherealSpell, false) ;etherealize the player
		PlayerREF.SetGhost()
		RegisterForSingleUpdate(1.0)
		IsMounted = true
	endif
EndEvent


Event OnUpdate()
	if (PlayerREF.IsOnMount())
		RegisterForSingleUpdate(1.0)
	else
		Game.EnablePlayerControls()
		PlayerREF.SetGhost(false)
		PlayerREF.RemoveSpell(EtherealSpell)
		kill()
		IsMounted = false
	endif
EndEvent
