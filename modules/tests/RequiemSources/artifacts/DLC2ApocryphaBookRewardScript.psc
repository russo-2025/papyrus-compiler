Scriptname DLC2ApocryphaBookRewardScript extends DLC2ApocryphaBookScript
{Base script for the 'Reward Books' at the end of most Apocrypha dungeons. Extended by the scripts for the specific books (see RewardAScript, RewardBScript, etc.).}

;--------------------------------------------------
;ADDITIONAL APOCRYPHA MANAGEMENT PROPERTIES
;------------------------------------------

bool Property requireRewardsShownToMove = True Auto
{Default: TRUE. If TRUE, the book won't move you back to Tamriel until it's presented the Apocrypha rewards.}

bool Property showRewardsOnActivation = True Auto
{Default: TRUE. If TRUE, the next activation of the book will show the book's rewards (if they aren't visible already).}

bool Property rewardsShown = False Auto Hidden
{Default: FALSER. If TRUE, the book's rewards are already visible.}


;--------------------------------------------------
;REWARD PROPERTIES
;-----------------

Message property AbilityPrompt01 Auto Hidden
Message property AbilityPrompt02 Auto Hidden
Message property AbilityPrompt03 Auto Hidden

Message property AbilityRemoved01 Auto Hidden
Message property AbilityRemoved02 Auto Hidden
Message property AbilityRemoved03 Auto Hidden

Spell property Spell01A Auto Hidden
Spell property Spell01B Auto Hidden
Spell property Spell01C Auto Hidden
Spell property Spell02A Auto Hidden
Spell property Spell02B Auto Hidden
Spell property Spell02C Auto Hidden
Spell property Spell03A Auto Hidden
Spell property Spell03B Auto Hidden
Spell property Spell03C Auto Hidden

Perk property Perk01A Auto Hidden
Perk property Perk01B Auto Hidden
Perk property Perk01C Auto Hidden
Perk property Perk02A Auto Hidden
Perk property Perk02B Auto Hidden
Perk property Perk02C Auto Hidden
Perk property Perk03A Auto Hidden
Perk property Perk03B Auto Hidden
Perk property Perk03C Auto Hidden

ObjectReference property RewardActivator01 Auto Hidden
ObjectReference property RewardActivator02 Auto Hidden
ObjectReference property RewardActivator03 Auto Hidden

Actor property Player Auto Hidden

Keyword property LinkCustom01 Auto
Keyword property LinkCustom02 Auto
Keyword property LinkCustom03 Auto

;VFX
Spell property DLC2ApocryphaRewardSpell Auto

int lastActiveAbility = 0	;Which reward for this book is active?
bool hasOpenedBook = False	;Have we opened the book yet?
GlobalVariable property AbilityGlobal Auto Hidden


;--------------------------------------------------
;EVENTS
;-------

Event OnCellAttach()
	;See if the parent needs to do anything.
	Parent.OnCellLoad()
	
	;Assume the child object has set all of the message, spell, perk, etc. properties.
	
	;Find the Reward Activators via named linkrefs.
	RewardActivator01 = Self.GetLinkedRef(LinkCustom01)
	RewardActivator02 = Self.GetLinkedRef(LinkCustom02)
	RewardActivator03 = Self.GetLinkedRef(LinkCustom03)
		
	;Let the Reward Activators know who to call.
	(RewardActivator01 as DLC2ApocryphaBookRewardActivator).SetController(Self)
	(RewardActivator02 as DLC2ApocryphaBookRewardActivator).SetController(Self)
	(RewardActivator03 as DLC2ApocryphaBookRewardActivator).SetController(Self)
	
	;Store off the player object.
	Player = Game.GetPlayer()
EndEvent


Auto State Waiting
	Event OnActivate(ObjectReference akActivator)
		if (akActivator == Game.GetPlayer())
			GoToState("Busy")
			(DLC2BookDungeonController as DLC2BookDungeonControllerScript).ReadApocryphaBook(Self, requireQuestStageToMove, requireRewardsShownToMove, rewardsShown, showRewardsOnActivation)
			GoToState("Waiting")
		EndIf
	EndEvent
EndState

State Busy
	Event OnActivate(ObjectReference akActivator)
		;Do nothing.
	EndEvent
EndState


;--------------------------------------------------
;REQUEST HANDLING
;----------------

Function OpenBook()
	;Open the book, but don't show the rewards yet.
	if (!hasOpenedBook)
		hasOpenedBook = True
		
		;Disable the activators on the book while it opens.
		Self.DisableBothActivators()
		
		;Open the book.
		Self.PlayAnimationAndWait("Stage1", "Open")
	EndIf
EndFunction

Function ShowRewards()
	;Open the book, if necessary.
	OpenBook()
	
	;Disable the activators on the book while it displays rewards.
	Self.DisableBothActivators()
		
	;Animate the reward globes.
	Self.PlayAnimationAndWait("Stage2", "Done")
	
	;Turn on the reward activators.	
	RewardActivator01.Enable()
	RewardActivator02.Enable()
	RewardActivator03.Enable()
	
	;The rewards are now visible.
	rewardsShown = True
EndFunction

Function ShowPowerPrompt(ObjectReference rewardActivator)
	int selection = -1
; 	;Debug.Trace("Attempting: " + rewardActivator + ", " + AbilityPrompt03)
	if (rewardActivator == RewardActivator01)
		selection = AbilityPrompt01.Show()
	ElseIf (rewardActivator == RewardActivator02)
		selection = AbilityPrompt02.Show()
	ElseIf (rewardActivator == RewardActivator03)
		selection = AbilityPrompt03.Show()
	EndIf
	if (selection == -1)
; 		;Debug.Trace("No selection was made, or an invalid activator was passed. " + rewardActivator)
	ElseIf (selection == 0)
		SetPower(rewardActivator)
		
		;Display the portal activation text.
		Self.EnableToSolstheimActivator()
	EndIf
EndFunction

Function SetPower(ObjectReference rewardActivator)
	if (lastActiveAbility == 1)
; 		;Debug.Trace("Perk01A is " + Perk01A)
		;Remove ability 1.
		if (Spell01A != None)
			Player.RemoveSpell(Spell01A)
		EndIf
		if (Spell01B != None)
			Player.RemoveSpell(Spell01B)
		EndIf
		if (Spell01C != None)
			Player.RemoveSpell(Spell01C)
		EndIf
		if (Perk01A != None)
			Player.RemovePerk(Perk01A)
		EndIf
		if (Perk01B != None)
			Player.RemovePerk(Perk01B)
		EndIf
		if (Perk01C != None)
			Player.RemovePerk(Perk01C)
		EndIf
		if (AbilityRemoved01 != None)
			AbilityRemoved01.Show()
		EndIf
	ElseIf (lastActiveAbility == 2)
		;Remove ability 2.
		if (Spell02A != None)
			Player.RemoveSpell(Spell02A)
		EndIf
		if (Spell02B != None)
			Player.RemoveSpell(Spell02B)
		EndIf
		if (Spell02C != None)
			Player.RemoveSpell(Spell02C)
		EndIf
		if (Perk02A != None)
			Player.RemovePerk(Perk02A)
		EndIf
		if (Perk02B != None)
			Player.RemovePerk(Perk02B)
		EndIf
		if (Perk02C != None)
			Player.RemovePerk(Perk02C)
		EndIf
		if (AbilityRemoved02 != None)
			AbilityRemoved02.Show()
		EndIf
	ElseIf (lastActiveAbility == 3)
		;Remove ability 3.
		if (Spell03A != None)
			Player.RemoveSpell(Spell03A)
		EndIf
		if (Spell03B != None)
			Player.RemoveSpell(Spell03B)
		EndIf
		if (Spell03C != None)
			Player.RemoveSpell(Spell03C)
		EndIf
		if (Perk03A != None)
			Player.RemovePerk(Perk03A)
		EndIf
		if (Perk03B != None)
			Player.RemovePerk(Perk03B)
		EndIf
		if (Perk03C != None)
			Player.RemovePerk(Perk03C)
		EndIf
		if (AbilityRemoved03 != None)
			AbilityRemoved03.Show()
		EndIf
	EndIf
	
	if (rewardActivator == RewardActivator01)
		If lastActiveAbility == 1
			lastActiveAbility = 0
			AbilityGlobal.SetValue(0.0)
		Else
			;Add ability 1.
			if (Spell01A != None)
				Player.AddSpell(Spell01A)
			EndIf
			if (Spell01B != None)
				Player.AddSpell(Spell01B)
			EndIf
			if (Spell01C != None)
				Player.AddSpell(Spell01C)
			EndIf
			if (Perk01A != None)
				Player.AddPerk(Perk01A)
			EndIf
			if (Perk01B != None)
				Player.AddPerk(Perk01B)
			EndIf
			if (Perk01C != None)
				Player.AddPerk(Perk01C)
			EndIf
			lastActiveAbility = 1
			AbilityGlobal.SetValue(1)
			DLC2ApocryphaRewardSpell.Cast(Player)
		EndIf
	ElseIf (rewardActivator == RewardActivator02)
		If lastActiveAbility == 2
			lastActiveAbility = 0
			AbilityGlobal.SetValue(0.0)
		Else
			;Add ability 2.
			if (Spell02A != None)
				Player.AddSpell(Spell02A)
			EndIf
			if (Spell02B != None)
				Player.AddSpell(Spell02B)
			EndIf
			if (Spell02C != None)
				Player.AddSpell(Spell02C)
			EndIf
			if (Perk02A != None)
				Player.AddPerk(Perk02A)
			EndIf
			if (Perk02B != None)
				Player.AddPerk(Perk02B)
			EndIf
			if (Perk02C != None)
				Player.AddPerk(Perk02C)
			EndIf
			lastActiveAbility = 2
			AbilityGlobal.SetValue(2)
			DLC2ApocryphaRewardSpell.Cast(Player)
		EndIf
	ElseIf (rewardActivator == RewardActivator03)
		If lastActiveAbility == 3
			lastActiveAbility = 0
			AbilityGlobal.SetValue(0.0)
		Else
			;Add ability 3.
			if (Spell03A != None)
				Player.AddSpell(Spell03A)
			EndIf
			if (Spell03B != None)
				Player.AddSpell(Spell03B)
			EndIf
			if (Spell03C != None)
				Player.AddSpell(Spell03C)
			EndIf
			if (Perk03A != None)
				Player.AddPerk(Perk03A)
			EndIf
			if (Perk03B != None)
				Player.AddPerk(Perk03B)
			EndIf
			if (Perk03C != None)
				Player.AddPerk(Perk03C)
			EndIf
			lastActiveAbility = 3
			AbilityGlobal.SetValue(3)
			DLC2ApocryphaRewardSpell.Cast(Player)
		EndIf
	EndIf
EndFunction