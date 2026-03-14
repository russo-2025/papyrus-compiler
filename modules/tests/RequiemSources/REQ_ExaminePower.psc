Scriptname REQ_ExaminePower extends activemagiceffect
{examine a distant target's health and check the items of the player's horse or thrall inventory or a yielding enemy's possessions}

Import Stringutil

Keyword Property SaddleKeyword Auto
Spell Property RaiseDeadBonus01 Auto
Spell Property RaiseDeadBonus02 Auto
MagicEffect Property TrueYieldFearEffect Auto
MagicEffect Property TrueYieldFearEffect02 Auto
Keyword Property ActorTypeNPC Auto
Message Property MessagePerfectHealth Auto
Message Property MessageGoodHealth Auto
Message Property MessageAverageHealth Auto
Message Property MessageBadHealth Auto
Message Property MessageTerribleHealth Auto

String Function SearchReplace(String text, String search, String replace)
	String result
	Int pos = StringUtil.Find(text, search)
	If pos == -1
		result = text
	Else
		If pos > 0
			result = Substring(text, 0, pos)
		EndIf
		result += replace
		result += Substring(text, pos + StringUtil.GetLength(search), GetLength(text))
	EndIf
	Return result
EndFunction

Event OnEffectStart(Actor akTarget, Actor akCaster)
	If akTarget.IsDead() || !akTarget.GetDisplayName()
		Return ; Don't examine corpses or hidden mechanisms (eg. invisible goat)
	EndIf
	If akCaster.GetDistance(akTarget) < 230
		If !akTarget.IsHostileToActor(Game.GetPlayer()) \
		   && ( (akTarget.WornHasKeyword(SaddleKeyword) && (akTarget.GetFactionReaction(Game.GetPlayer()) >= 2 || akTarget.GetActorOwner() == Game.GetPlayer().GetActorBase())) \
		   || akTarget.HasSpell(RaiseDeadBonus01) || akTarget.HasSpell(RaiseDeadBonus02) )
			; open a raised dead's inventory or a horse's saddlebag
			; RRO-27 "akTarget.GetFactionReaction(Game.GetPlayer()) >= 2" to prevent opening non-owned horse saddlebags
			; RRO-27 "akTarget.GetActorOwner() == Game.GetPlayer().GetActorBase()" alternative for horses that are not added to the playerhorsefaction
			akTarget.OpenInventory(true)
		ElseIf akTarget.HasKeyword(ActorTypeNPC) && (akTarget.HasMagicEffect(TrueYieldFearEffect) || akTarget.HasMagicEffect(TrueYieldFearEffect02))
			; plunder yielding foes
			akTarget.OpenInventory(true)
		EndIf
	Else
		; REQ-198 display a health report based on the target's health percentage
		
		String name = akTarget.GetDisplayName()
		
		Float healthpercent = akTarget.GetActorValuePercentage("Health")

		String healthreport

		If healthpercent >= 1.0
			healthreport = SearchReplace(MessagePerfectHealth.GetName(), "<name>", name)
		ElseIf healthpercent >= 0.8
			healthreport = SearchReplace(MessageGoodHealth.GetName(), "<name>", name)
		ElseIf healthpercent >= 0.55
			healthreport = SearchReplace(MessageAverageHealth.GetName(), "<name>", name)
		ElseIf healthpercent >= 0.25
			healthreport = SearchReplace(MessageBadHealth.GetName(), "<name>", name)
		Else
			healthreport = SearchReplace(MessageTerribleHealth.GetName(), "<name>", name)
		EndIf
		Debug.Notification(healthreport)
	EndIf
EndEvent