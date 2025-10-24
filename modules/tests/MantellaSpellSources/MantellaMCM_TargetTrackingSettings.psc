Scriptname MantellaMCM_TargetTrackingSettings Hidden
{This is the settings page for target event tracking.}
Import StringUtil
function Render(MantellaMCM mcm, MantellaRepository Repository) global
    ;This part of the MCM MainSettings script pretty much only serves to tell papyrus what button to display.
    mcm.SetCursorFillMode(mcm.TOP_TO_BOTTOM)
    LeftColumn(mcm, Repository)
    mcm.SetCursorPosition(1)
    RightColumn(mcm)
endfunction

function LeftColumn(MantellaMCM mcm, MantellaRepository Repository) global
    ;generates the toggle buttons on the right side
    mcm.AddHeaderOption ("Tracked Events")
    mcm.oid_targetTrackingItemAddedToggle = mcm.AddToggleOption("Item Added", Repository.targetTrackingItemAdded)
    mcm.oid_targetTrackingItemRemovedToggle = mcm.AddToggleOption("Item Removed", Repository.targetTrackingItemRemoved)
    mcm.oid_targetTrackingOnSpellCastToggle = mcm.AddToggleOption("Spell Cast", Repository.targetTrackingOnSpellCast)
    mcm.oid_targetTrackingOnHitToggle = mcm.AddToggleOption("Target Hit", Repository.targetTrackingOnHit)
    mcm.oid_targetTrackingOnCombatStateChangedToggle = mcm.AddToggleOption("Combat State Changed", Repository.targetTrackingOnCombatStateChanged)
    mcm.oid_targetTrackingOnObjectEquippedToggle = mcm.AddToggleOption("Item Equipped", Repository.targetTrackingOnObjectEquipped)
    mcm.oid_targetTrackingOnObjectUnequippedToggle = mcm.AddToggleOption("Item Unequipped", Repository.targetTrackingOnObjectUnequipped)
    mcm.oid_targetTrackingOnSitToggle = mcm.AddToggleOption("Target Rests on Furniture", Repository.targetTrackingOnSit)
    mcm.oid_targetTrackingOnGetUpToggle = mcm.AddToggleOption("Target Gets Up from Furniture", Repository.targetTrackingOnGetUp)
    mcm.oid_targetTrackingAngerStateToggle = mcm.AddToggleOption("Target Anger State", Repository.targetTrackingAngerState)
    mcm.oid_targetTrackingAll = mcm.AddToggleOption("All", mcm.targetAllToggle)
endfunction

function RightColumn(MantellaMCM mcm) global
     ;This part of the MCM MainSettings script pretty much only serves to tell papyrus what button to display using properties from the repository
    ;generates left column
    mcm.AddHeaderOption ("Target Info")
    MantellaConversation conversation = Quest.GetQuest("MantellaConversation") as MantellaConversation
    If (!conversation.IsRunning() || conversation.CountActorsInConversation() < 2)
        return
    EndIf
    Actor actorToDisplay = conversation.GetActorInConversationByIndex(0)
    If (actorToDisplay == Game.GetPlayer())
        actorToDisplay = conversation.GetActorInConversationByIndex(1)
    EndIf

    string currentActor = actorToDisplay.GetDisplayName()
    string currentActorID = (actorToDisplay.GetActorBase() as Form).GetFormID()
    string currentActorSex = actorToDisplay.getleveledactorbase().getsex()
    ;below translate the number for gender into string text
    if currentActorSex == 1
        currentActorSex = "Female"
    else
        currentActorSex = "Male"
    endif
    ;this part below chops down the string from the text file to get the race
    string currentActorRaceSubstring = actorToDisplay.GetRace() ;MiscUtil.ReadFromFile("_mantella_actor_race.txt") as string
    ; string currentActorRaceSubstring= Substring(currentActorRace, 7)
    ; int currentActorRaceSpacePlacement = Find(currentActorRaceSubstring, "race ")
    ; currentActorRaceSubstring= Substring(currentActorRaceSubstring, 0, currentActorRaceSpacePlacement)
    int currentActorRelationship = actorToDisplay.GetRelationshipRank(Game.GetPlayer()) ;MiscUtil.ReadFromFile("_mantella_actor_relationship.txt") as int
    ;build array for relationship status to transfert from number to string text 
    ;ToDo: Double check this relationship to relationshiprank
    string[] relationshipArray = new string[9]
    relationshipArray[0]="Archnemesis"
    relationshipArray[1]="Enemy"
    relationshipArray[2]="Foe"
    relationshipArray[3]="Rival"
    relationshipArray[4]="Acquaintance"
    relationshipArray[5]="Friend"
    relationshipArray[6]="Confidant"
    relationshipArray[7]="Ally"
    relationshipArray[8]="Lover"
    string currentActorRelationshipString=relationshipArray[currentActorRelationship+4]
    ;this part below chops down the string from the text file  get the voice
    ; string currentActorVoice = MiscUtil.ReadFromFile("_mantella_actor_voice.txt") as string
    ; string currentActorVoiceSubstring= Substring(currentActorVoice, 12)
    ; int currentActorVoiceSpacePlacement = Find(currentActorVoiceSubstring, " ")
    ; currentActorVoiceSubstring= Substring(currentActorVoiceSubstring, 0, currentActorVoiceSpacePlacement)
    string currentActorVoiceSubstring = actorToDisplay.GetVoiceType()
    string currentActorIsEnemy = actorToDisplay.getcombattarget() == game.getplayer();MiscUtil.ReadFromFile("_mantella_actor_is_enemy.txt") as string
    
    ;this part tells the MCM what to display
    mcm.AddTextOption("Name",currentActor )
    mcm.AddTextOption("ID",currentActorID )
    mcm.AddTextOption("Gender",currentActorSex )
    mcm.AddTextOption("Race",currentActorRaceSubstring )
    mcm.AddTextOption("Relationship",currentActorRelationshipString )
    mcm.AddTextOption("Voice Type",currentActorVoiceSubstring )
    mcm.AddTextOption("Enemy",currentActorIsEnemy )
    ;_keymapOID_K = mcm.AddKeyMapOption("Mantella Initiate/Text Hotkey", _myKey, 0)
endfunction

function OptionUpdate(MantellaMCM mcm, int optionID, MantellaRepository Repository) global
    ;checks option per option what the toggle is and the updates the var repository MantellaRepository so the targetListenerScript can access it
    if optionID==mcm.oid_targetTrackingItemAddedToggle
        Repository.targetTrackingItemAdded=!Repository.targetTrackingItemAdded
        mcm.SetToggleOptionValue(mcm.oid_targetTrackingItemAddedToggle, Repository.targetTrackingItemAdded)
    ElseIf optionID==mcm.oid_targetTrackingItemRemovedToggle
        Repository.targetTrackingItemRemoved=!Repository.targetTrackingItemRemoved
        mcm.SetToggleOptionValue( mcm.oid_targetTrackingItemRemovedToggle, Repository.targetTrackingItemRemoved)
    ElseIf optionID==mcm.oid_targetTrackingOnSpellCastToggle
        Repository.targetTrackingOnSpellCast=! Repository.targetTrackingOnSpellCast
        mcm.SetToggleOptionValue( mcm.oid_targetTrackingOnSpellCastToggle,  Repository.targetTrackingOnSpellCast)
    ElseIf optionID==mcm.oid_targetTrackingOnHitToggle
        Repository.targetTrackingOnHit=!Repository.targetTrackingOnHit
        mcm.SetToggleOptionValue( mcm.oid_targetTrackingOnHitToggle, Repository.targetTrackingOnHit)
    ElseIf optionID==mcm.oid_targetTrackingOnCombatStateChangedToggle
        Repository.targetTrackingOnCombatStateChanged=!Repository.targetTrackingOnCombatStateChanged
        mcm.SetToggleOptionValue( mcm.oid_targetTrackingOnCombatStateChangedToggle, Repository.targetTrackingOnCombatStateChanged)
    ElseIf optionID==mcm.oid_targetTrackingOnObjectEquippedToggle
        Repository.targetTrackingOnObjectEquipped=!Repository.targetTrackingOnObjectEquipped
        mcm.SetToggleOptionValue( mcm.oid_targetTrackingOnObjectEquippedToggle, Repository.targetTrackingOnObjectEquipped)
    ElseIf optionID==mcm.oid_targetTrackingOnObjectUnequippedToggle
        Repository.targetTrackingOnObjectUnequipped=!Repository.targetTrackingOnObjectUnequipped
        mcm.SetToggleOptionValue( mcm.oid_targetTrackingOnObjectUnequippedToggle, Repository.targetTrackingOnObjectUnequipped)
    ElseIf optionID==mcm.oid_targetTrackingOnSitToggle
        Repository.targetTrackingOnSit=!Repository.targetTrackingOnSit
        mcm.SetToggleOptionValue( mcm.oid_targetTrackingOnSitToggle, Repository.targetTrackingOnSit)
    ElseIf optionID==mcm.oid_targetTrackingOnGetUpToggle
        Repository.targetTrackingOnGetUp=!Repository.targetTrackingOnGetUp
        mcm.SetToggleOptionValue( mcm.oid_targetTrackingOnGetUpToggle, Repository.targetTrackingOnGetUp)
    ElseIf optionID==mcm.oid_targetTrackingAngerStateToggle
        Repository.targetTrackingAngerState=!Repository.targetTrackingAngerState
        mcm.SetToggleOptionValue( mcm.oid_targetTrackingAngerStateToggle, Repository.targetTrackingAngerState)
    ElseIf optionID==mcm.oid_targetTrackingAll
        ;This part of the function OptionUpdate flips a bunch of variables in the repository at once :
        mcm.targetAllToggle=!mcm.targetAllToggle
        mcm.SetToggleOptionValue( mcm.oid_targetTrackingAll, mcm.targetAllToggle)
        mcm.SetToggleOptionValue( mcm.oid_targetTrackingItemAddedToggle, mcm.targetAllToggle)
        mcm.SetToggleOptionValue( mcm.oid_targetTrackingItemRemovedToggle, mcm.targetAllToggle)
        mcm.SetToggleOptionValue( mcm.oid_targetTrackingOnSpellCastToggle, mcm.targetAllToggle)
        mcm.SetToggleOptionValue( mcm.oid_targetTrackingOnHitToggle, mcm.targetAllToggle)
        mcm.SetToggleOptionValue( mcm.oid_targetTrackingOnCombatStateChangedToggle, mcm.targetAllToggle)
        mcm.SetToggleOptionValue( mcm.oid_targetTrackingOnObjectEquippedToggle, mcm.targetAllToggle)
        mcm.SetToggleOptionValue( mcm.oid_targetTrackingOnObjectUnequippedToggle, mcm.targetAllToggle)
        mcm.SetToggleOptionValue( mcm.oid_targetTrackingOnSitToggle, mcm.targetAllToggle)
        mcm.SetToggleOptionValue( mcm.oid_targetTrackingOnGetUpToggle, mcm.targetAllToggle)
        mcm.SetToggleOptionValue( mcm.oid_targetTrackingAngerStateToggle, mcm.targetAllToggle)
        
        Repository.targetTrackingItemAdded=mcm.targetAllToggle
        Repository.targetTrackingItemRemoved=mcm.targetAllToggle
        Repository.targetTrackingOnSpellCast=mcm.targetAllToggle
        Repository.targetTrackingOnHit=mcm.targetAllToggle
        Repository.targetTrackingOnCombatStateChanged=mcm.targetAllToggle
        Repository.targetTrackingOnObjectEquipped=mcm.targetAllToggle
        Repository.targetTrackingOnObjectUnequipped=mcm.targetAllToggle
        Repository.targetTrackingOnSit=mcm.targetAllToggle
        Repository.targetTrackingOnGetUp=mcm.targetAllToggle
        Repository.targetTrackingAngerState=mcm.targetAllToggle
        ;not using dying toggle cause this one is to end conversations on NPC death
        ;Repository.targetTrackingOnDying=mcm.targetAllToggle
        
    endif
endfunction 
