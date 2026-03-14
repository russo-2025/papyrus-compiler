Scriptname REQ_TemperingData extends REQ_CoreScript
{this alias is a centralized datastorage for armor tempering scripts on NPCs}

Float[] Property tier1_H_fall Auto
{tempering health distribution for quality tier 1 for small items with lower probability for good values}
Float[] Property tier1_N_fall Auto
{tempering health distribution for quality tier 1 for normal items with lower probability for good values}
Float[] Property tier1_D_fall Auto
{tempering health distribution for quality tier 1 for large items with lower probability for good values}

Float[] Property tier1_H_const Auto
{tempering health distribution for quality tier 1 for small items with equal probability}
Float[] Property tier1_N_const Auto
{tempering health distribution for quality tier 1 for normal items with equal probability}
Float[] Property tier1_D_const Auto
{tempering health distribution for quality tier 1 for large items with equal probability}

Float[] Property tier1_H_rise Auto
{tempering health distribution for quality tier 1 for small items with higher probability for good values}
Float[] Property tier1_N_rise Auto
{tempering health distribution for quality tier 1 for normal items with higher probability for good values}
Float[] Property tier1_D_rise Auto
{tempering health distribution for quality tier 1 for large items with higher probability for good values}

Float[] Property tier2_H_fall Auto
{tempering health distribution for quality tier 2 for small items with lower probability for good values}
Float[] Property tier2_N_fall Auto
{tempering health distribution for quality tier 2 for normal items with lower probability for good values}
Float[] Property tier2_D_fall Auto
{tempering health distribution for quality tier 2 for large items with lower probability for good values}

Float[] Property tier2_H_const Auto
{tempering health distribution for quality tier 2 for small items with equal probability}
Float[] Property tier2_N_const Auto
{tempering health distribution for quality tier 2 for normal items with equal probability}
Float[] Property tier2_D_const Auto
{tempering health distribution for quality tier 2 for large items with equal probability}

Float[] Property tier2_H_rise Auto
{tempering health distribution for quality tier 2 for small items with higher probability for good values}
Float[] Property tier2_N_rise Auto
{tempering health distribution for quality tier 2 for normal items with higher probability for good values}
Float[] Property tier2_D_rise Auto
{tempering health distribution for quality tier 2 for large items with higher probability for good values}

Function initScript(Int currentVersion, Int nevVersion)
EndFunction

Function shutdownScript(Int currentVersion, Int nevVersion)
EndFunction

Float[] Function GetRange(String tiername)
	If tiername == "tier1_N_fall"
		return tier1_N_fall
	ElseIf tiername == "tier1_N_const"
		return tier1_N_const
	ElseIf tiername == "tier1_N_rise"
		return tier1_N_rise
	ElseIf tiername == "tier2_N_fall"
		return tier2_N_fall
	ElseIf tiername == "tier2_N_const"
		return tier2_N_const
	ElseIf tiername == "tier2_N_rise"
		return tier2_N_rise
	Else
		Debug.Trace("[REQ] ERROR: Undefined Tempering Data '" + tiername + "'requested!")
		return None
	EndIf
EndFunction
