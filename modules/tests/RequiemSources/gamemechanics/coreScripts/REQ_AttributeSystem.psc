Scriptname REQ_AttributeSystem extends REQ_CoreScript
{This script controls the derived attributes, they are updated each time the skills menu is closed.
The contributions are computed as prefactor * sqrt( weighted base attribute sum - threshold). Negative 
arguments to the square root have no contribution.}

;parameters, to be defined in the esp
String[] Property derived Auto
{list of derived stats to mod}
Float[] Property prefactor Auto
{scaling prefactors for the attributes}
Float[] Property weight_health Auto
{weighting factors for base health}
Float[] Property weight_magicka Auto
{weighting factors for base magicka}
Float[] Property weight_stamina Auto
{weighting factors for base stamina}
Float[] Property threshold Auto
{minimum value the weighted attribute sum must reach to give any bonus to the specified derived stat}
String[] Property shout_derived Auto
{the individual components (game misc stats) that make up the shout cooldown reduction}
Float[] Property prefactor_shouts Auto
{the weighting prefactors for the shout cooldown bonus components}
Float[] Property shout_thresholds Auto
{the minimum value the misc stat must have to contribute at all}

;runtime variables with external access (MCM display)
Float[] Property modifiers Auto
{the current computed actorvalue modifiers}
Float[] Property mods_Shout Auto
{the current shout modifiers}

Bool doagain = False

Function shutdownScript(Int currentVersion, Int nevVersion)
	While (GetState() != "")
		Utility.Wait(0.5)
	EndWhile
	Player.ModAV("ShoutRecoveryMult", -0.5)
    UnregisterForAllMenus()

	;special update logic from version 3.3.0 -> version 3.4.0
    Player.ModAV("ShoutRecoveryMult", -mods_Shout[0])
    Int i = 0
    While i < Mods_Shout.length
        mods_Shout[i] = 0
        i += 1
    EndWhile

	Reset_Buffs()
EndFunction

Function initScript(Int currentVersion, Int nevVersion)
    modifiers = Utility.CreateFloatArray(derived.length, 0.0)
    mods_Shout = Utility.CreateFloatArray(shout_derived.length, 0.0)
	Player.ModAV("ShoutRecoveryMult", 0.5)
	Reset_Buffs()
	UpdateAttributeBonuses()
	UpdateShoutBonuses()
	RegisterForMenu("StatsMenu")
	RegisterForMenu("MagicMenu")
EndFunction

Event OnMenuClose(String Menu)
	GoToState("working")
	If Menu != "MagicMenu"
		UpdateAttributeBonuses()
	EndIf
	UpdateShoutBonuses()
	GoToState("")
	If doagain
		doagain = False
		OnMenuClose("")
	EndIf
EndEvent

State working
	Event OnMenuClose(String Menu)
		doagain = True
	EndEvent
EndState

Function Reset_Buffs()
	Int i = 0
	While i < derived.length
		Player.ModAV(derived[i], -Modifiers[i])
		Modifiers[i] = 0.0
		i += 1
	EndWhile
	i = 0
	While i < Mods_Shout.length
	    Player.ModAV("ShoutRecoveryMult", -Mods_Shout[i])
		Mods_Shout[i] = 0
		i += 1
	EndWhile
EndFunction

Function UpdateAttributeBonuses()
	Int i = 0
	Float magicka = Player.GetBaseAV("Magicka")
	Float stamina = Player.GetBaseAV("Stamina")
	Float health = Player.GetBaseAV("Health")
	Float weighted = 0.0
	While i < derived.length
		Player.ModAV(derived[i], -Modifiers[i])
		weighted = weight_health[i] * health + weight_magicka[i] * magicka + weight_stamina[i] * stamina
		If weighted > threshold[i]
			Modifiers[i] = prefactor[i] * Math.Pow(weighted - threshold[i], 0.5)
		Else
			Modifiers[i] = 0.0
		EndIf
		Player.ModAV(derived[i], Modifiers[i])
		i += 1
	EndWhile
EndFunction

Function UpdateShoutBonuses()
	Int i = 0
	While i < shout_derived.length
	    Player.ModAV("ShoutRecoveryMult", -Mods_Shout[i])
		Float statValue = Game.QueryStat(shout_derived[i]) as Float
		If statValue > Shout_Thresholds[i]
			Mods_Shout[i] = -prefactor_shouts[i] * Math.Pow(statValue - Shout_Thresholds[i], 0.5)
		Else
			Mods_Shout[i] = 0.0
		EndIf
	    Player.ModAV("ShoutRecoveryMult", Mods_Shout[i])
		i += 1
	EndWhile
EndFunction
