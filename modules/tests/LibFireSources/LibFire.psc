ScriptName LibFire Hidden

{ Actor }

; Returns the index of the first keyword in `argKeywords` assigned to `akActor` - if not found, -1 is returned
Int Function ActorFindAnyKeyword(Actor akActor, Keyword[] argKeywords) Global Native

; Returns the index of the first perk in `argPerks` assigned to `akActor` - if not found, -1 is returned
Int Function ActorFindAnyPerk(Actor akActor, Perk[] argPerks) Global Native

; Returns an array of factions that track crime and of which `akActor` is a current member
Faction[] Function ActorFindCrimeFactions(Actor akActor) Global Native

; Returns whether `akActor` has any keyword in `akKeywords`
Bool Function ActorHasAnyKeyword(Actor akActor, FormList akKeywords) Global Native

; Returns whether `akActor` has `akPerk` and its rank is `aiRank` - if match not found, `False` is returned
Bool Function ActorHasPerkRank(Actor akActor, Perk akPerk, Int aiRank) Global Native

; Returns whether `akActor` is commanded by `akOtherActor`
Bool Function ActorIsCommandedBy(Actor akActor, Actor akOtherActor) Global Native

; Returns whether `akActor` is commanded by the player
Bool Function ActorIsCommandedByPlayer(Actor akActor) Global Native

; Returns whether `akActor` is a teammate or player-controlled commanded/summoned actor
Bool Function ActorIsFollower(Actor akActor) Global Native

; Returns whether `akActor` is a member of any faction in `akFactions` with a rank greater than -1
Bool Function ActorIsInAnyFaction(Actor akActor, FormList akFactions) Global Native

; Returns whether `akActor` is a member of `akFaction` with a rank greater than -1
Bool Function ActorIsInFaction(Actor akActor, Faction akFaction) Global Native

; Returns whether `akActor` is a summoned actor
Bool Function ActorIsSummoned(Actor akActor) Global Native

; Returns the current rank of `akPerk` assigned to `akActor` - if perk not assigned, -1 is returned
Int Function GetActorPerkRank(Actor akActor, Perk akPerk) Global Native

; Returns an array of perks assigned to `akActor`
Perk[] Function GetActorPerks(Actor akActor) Global Native

; Returns an array of commanded actors for `akActor` or `None`
Actor[] Function GetCommandedActors(Actor akActor) Global Native

; Returns the commanding actor for `akActor` when actor is commanded
Actor Function GetCommandingActor(Actor akActor) Global Native

; Returns the ammo currently used by `akActor`
Ammo Function GetEquippedAmmo(Actor akActor) Global Native

{ Array }

; Searches `argActors` for closest actor to `akOrigin` and returns index of member - if not found, -1 is returned
Int Function ArrayFindClosestActor(Actor[] argActors, ObjectReference akOrigin) Global Native

; Searches `argHaystack` for `afValue` and returns index of member - if not found, -1 is returned
Int Function ArrayFindGlobalValue(GlobalVariable[] argGlobals, Float afValue) Global Native

{ Faction }

; Returns flag values for `akFaction`
Bool Function GetFactionIgnoresMurder(Faction akFaction) Global Native
Bool Function GetFactionIgnoresAssault(Faction akFaction) Global Native
Bool Function GetFactionIgnoresTrespass(Faction akFaction) Global Native
Bool Function GetFactionIgnoresPickpocket(Faction akFaction) Global Native
Bool Function GetFactionIgnoresStealing(Faction akFaction) Global Native
Bool Function GetFactionIgnoresWerewolf(Faction akFaction) Global Native
Bool Function GetFactionReportsCrimesAgainstMembers(Faction akFaction) Global Native
Bool Function GetFactionTracksCrime(Faction akFaction) Global Native
Bool Function GetFactionUsesCrimeGoldDefaults(Faction akFaction) Global Native

; Returns crime value (murder, assault, etc.) for `akFaction` at `aiMember` offset
; Valid offsets:
;   - 0x0  Arrest (cast to Boolean)
;   - 0x01 Attack On Sight (cast to Boolean)
;   - 0x02 Murder (cast to Int)
;   - 0x04 Assault (cast to Int)
;   - 0x06 Trespass (cast to Int)
;   - 0x08 Pickpocket (cast to Int)
;   - 0x0C Steal Multiplier (Float)
;   - 0x10 Escape (cast to Int)
;   - 0x12 Werewolf (cast to Int)
Float Function GetFactionCrimeValue(Faction akFaction, Int aiMember) Global Native

; Sets `akFaction` as ally or friend to each faction in `akFactions`
Function SetAllies(Faction akFaction, FormList akFactions, Bool abSelfIsFriendToOther = False, Bool abOtherIsFriendToSelf = False) Global Native

; Sets `akFaction` as enemy or neutral to each faction in `akFactions`
Function SetEnemies(Faction akFaction, FormList akFactions, Bool abSelfIsNeutralToOther = False, Bool abOtherIsNeutralToSelf = False) Global Native

; Copies violent and nonviolent crime gold from `akFaction` to `akOtherFaction`. If `abModify` is True,
;   adds crime gold values to existing values instead.
Function CopyFactionCrimeGold(Faction akFaction, Faction akOtherFaction, Bool abModify) Global Native

; Zeroes out violent and nonviolent crime gold on `akFaction`
Function ResetFactionCrimeGold(Faction akFaction) Global Native

; Clears cached faction fight reactions (sometimes required to update faction actors)
;   Note: SetAllies and SetEnemies already clears the faction reactions cache.
Bool Function ClearFactionReactionsCache() Global Native

{ FormList }

; Returns whether `akHaystack` contains each form in `argNeedles`
Bool[] Function SearchListForForms(FormList akHaystack, Form[] argNeedles) Global Native

; Returns whether each formlist in `akHaystack` contains `akNeedle`
Bool[] Function SearchListsForForm(FormList akHaystack, Form akNeedle) Global Native

{ ObjectReference }

; Returns closest actor within `afRadius` of and line of sight to `akOrigin`
Actor Function FindClosestActorByLOS(ObjectReference akOrigin, Float afRadius) Global Native

; Returns closest actor who is a member of `akFaction` within `afRadius` of `akOrigin`
Actor Function FindClosestActorInFaction(ObjectReference akOrigin, Faction akFaction, Float afRadius) Global Native

; Returns closest actor who is a member of `akFaction` within `afRadius` of and line of sight to `akOrigin`
Actor Function FindClosestActorInFactionByLOS(ObjectReference akOrigin, Faction akFaction, Float afRadius) Global Native

; Returns actors in loaded cells within `afRadius` of `akOrigin`
Actor[] Function FindNearbyActors(ObjectReference akOrigin, Float afRadius) Global Native

; Returns actors who are members of `akFaction` in loaded cells within `afRadius` of `akOrigin`
Actor[] Function FindNearbyActorsInFaction(ObjectReference akOrigin, Faction akFaction, Float afRadius) Global Native

; Returns actors who are members of `akFaction` in loaded cells within `afRadius` of and line of sight to `akOrigin`
Actor[] Function FindNearbyActorsInFactionByLOS(ObjectReference akOrigin, Faction akFaction, Float afRadius) Global Native

; Returns books in loaded cells within `afRadius` of `akOrigin`
ObjectReference[] Function FindNearbyBooks(ObjectReference akOrigin, Float afRadius) Global Native

; Returns commanded actors in loaded cells within `afRadius` of `akOrigin` who are controlled by `akOrigin`
Actor[] Function FindNearbyCommandedActors(ObjectReference akOrigin, Float afRadius) Global Native

; Returns teammates and player-controlled commanded/summoned actors in loaded cells within `afRadius` of player
Actor[] Function FindNearbyFollowers(Float afRadius) Global Native

; Returns summoned actors in loaded cells within `afRadius` of `akOrigin`
Actor[] Function FindNearbySummons(ObjectReference akOrigin, Float afRadius) Global Native

; Returns teammates in loaded cells within `afRadius` of player
Actor[] Function FindNearbyTeammates(Float afRadius) Global Native

; Returns the permanent value of `asActorValue` for `akActor`
Float Function GetPermanentActorValue(ObjectReference akActor, String asActorValue) Global Native

{ Player Character }

; Returns an array of factions with which the player is infamous
Faction[] Function FindPlayerInfamousWithFactions() Global Native

; Returns an array of factions to which the player owes crime gold
Faction[] Function FindPlayerWantedByFactions() Global Native

; Returns whether the player is infamous with any faction
Bool Function IsPlayerInfamous() Global Native

; Returns whether the player is wanted by any faction
Bool Function IsPlayerWanted() Global Native

{ Race }

; Returns the skill boost value of `asActorValue` for `akRace`
Int Function GetRaceSkillBonus(Race akRace, String asActorValue) Global Native

; Returns names of boosted actor values for `akRace`
String[] Function GetRaceSkills(Race akRace) Global Native

; Returns the base male height for `akRace`
Float Function GetRaceMaleHeight(Race akRace) Global Native

; Returns the base female height for `akRace`
Float Function GetRaceFemaleHeight(Race akRace) Global Native

; Returns the base male weight for `akRace`
Float Function GetRaceMaleWeight(Race akRace) Global Native

; Returns the base female weight for `akRace`
Float Function GetRaceFemaleWeight(Race akRace) Global Native

; Returns the starting health for `akRace`
Float Function GetRaceStartingHealth(Race akRace) Global Native

; Returns the starting magicka for `akRace`
Float Function GetRaceStartingMagicka(Race akRace) Global Native

; Returns the starting stamina for `akRace`
Float Function GetRaceStartingStamina(Race akRace) Global Native

; Returns the base carry weight for `akRace`
Float Function GetRaceCarryWeight(Race akRace) Global Native

; Returns the base mass for `akRace`
Float Function GetRaceMass(Race akRace) Global Native

; Returns the base health regen for `akRace`
Float Function GetRaceHealthRegen(Race akRace) Global Native

; Returns the base magicka regen for `akRace`
Float Function GetRaceMagickaRegen(Race akRace) Global Native

; Returns the base stamina regen for `akRace`
Float Function GetRaceStaminaRegen(Race akRace) Global Native

; Returns the base unarmed damage for `akRace`
Float Function GetRaceUnarmedDamage(Race akRace) Global Native

; Returns the base unarmed reach for `akRace`
Float Function GetRaceUnarmedReach(Race akRace) Global Native

{ String }

; Returns whether `asText` contains `asSubText` (all Papyrus string comparisons are case-insensitive)
Bool Function ContainsText(String asText, String asSubText) Global Native

; Replaces `{}` tokens in `asFormat` with `argValues` (supports up to 9 values)
;   Note: Arrays exceeding the maximum number of values will be truncated.
;   Syntax: https://fmt.dev/latest/syntax.html
String Function FormatFloat(String asFormat, Float[] argValues) Global Native

; Replaces `{}` tokens in `asFormat` with `argValues` (supports up to 9 values)
;   Note: Arrays exceeding the maximum number of values will be truncated.
;   Syntax: https://fmt.dev/latest/syntax.html
String Function FormatInt(String asFormat, Int[] argValues) Global Native

; Replaces `{}` tokens in `asFormat` with `argValues` (supports up to 9 values)
;   Note: Arrays exceeding the maximum number of values will be truncated.
;   Syntax: https://fmt.dev/latest/syntax.html
String Function FormatString(String asFormat, String[] argValues) Global Native

; Returns the hexadecimal string representation of `aiSource`
String Function IntToHex(Int aiSource) Global Native

; Returns `asSource` as array of String split by `asDelimiter`
String[] Function SplitString(String asSource, String asDelimiter) Global Native

; Returns `asSource` as array of Float split by `asDelimiter`
Float[] Function StrToFloatArray(String asSource, String asDelimiter) Global Native

; Returns `asSource` as array of Int split by `asDelimiter`
Int[] Function StrToIntArray(String asSource, String asDelimiter) Global Native

; Returns `asSource` wrapped to column `aiMaxLength` with lines delimited by newline character
String Function WrapString(String asSource, Int aiMaxLength) Global Native

{ Spell }

; Returns highest minimum skill level for `akSpell` (does not account for conditions)
Int Function GetHighestMinSkillLevelForSpell(Spell akSpell) Global Native

{ Time }

; Returns hours passed since current day began
Float Function GetCurrentHourOfDay() Global Native
