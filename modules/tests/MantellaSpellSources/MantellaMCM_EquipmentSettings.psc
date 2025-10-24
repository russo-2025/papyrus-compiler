Scriptname MantellaMCM_EquipmentSettings  Hidden 
{This is the menu page for setting for player events tracking.}
function Render(MantellaMCM mcm, MantellaRepository Repository) global
     ;This part of the MCM MainSettings script pretty much only serves to tell papyrus what button to display.
    mcm.SetCursorFillMode(mcm.TOP_TO_BOTTOM)
    LeftColumn(mcm, Repository)
    mcm.SetCursorPosition(1)
    RightColumn(mcm, Repository)
endfunction


function LeftColumn(MantellaMCM mcm, MantellaRepository Repository) global
    mcm.AddHeaderOption ("Player Equipment")
    mcm.oid_playerEquipmentBody=mcm.AddToggleOption("Body ", repository.playerEquipmentBody)
    mcm.oid_playerEquipmentHead=mcm.AddToggleOption("Head ", repository.playerEquipmentHead)
    mcm.oid_playerEquipmentHands=mcm.AddToggleOption("Hands", repository.playerEquipmentHands)
    mcm.oid_playerEquipmentFeet=mcm.AddToggleOption("Feet", repository.playerEquipmentFeet)
    mcm.oid_playerEquipmentAmulet=mcm.AddToggleOption("Amulet", repository.playerEquipmentAmulet)
    mcm.oid_playerEquipmentRightHand=mcm.AddToggleOption("Right Hand", repository.playerEquipmentRightHand)
    mcm.oid_playerEquipmentLeftHand=mcm.AddToggleOption("Left Hand", repository.playerEquipmentLeftHand)
    mcm.oid_playerEquipmentAll=mcm.AddToggleOption("All", mcm.playerAllToggle)
endfunction

function RightColumn(MantellaMCM mcm, MantellaRepository Repository) global
    mcm.AddHeaderOption ("NPC Equipment")
    mcm.oid_targetEquipmentBody=mcm.AddToggleOption("Body ", repository.targetEquipmentBody)
    mcm.oid_targetEquipmentHead=mcm.AddToggleOption("Head ", repository.targetEquipmentHead)
    mcm.oid_targetEquipmentHands=mcm.AddToggleOption("Hands", repository.targetEquipmentHands)
    mcm.oid_targetEquipmentFeet=mcm.AddToggleOption("Feet", repository.targetEquipmentFeet)
    mcm.oid_targetEquipmentAmulet=mcm.AddToggleOption("Amulet", repository.targetEquipmentAmulet)
    mcm.oid_targetEquipmentRightHand=mcm.AddToggleOption("Right Hand", repository.targetEquipmentRightHand)
    mcm.oid_targetEquipmentLeftHand=mcm.AddToggleOption("Left Hand", repository.targetEquipmentLeftHand)
    mcm.oid_targetEquipmentAll=mcm.AddToggleOption("All", mcm.targetAllToggle)
endfunction


function OptionUpdate(MantellaMCM mcm, int optionID, MantellaRepository Repository) global
    ;checks option per option what the toggle is and the updates the var repository MantellaRepository
    ;left column
    If optionID==mcm.oid_playerEquipmentBody
        repository.playerEquipmentBody=!repository.playerEquipmentBody
        mcm.SetToggleOptionValue(optionID, repository.playerEquipmentBody)
    ElseIf optionID==mcm.oid_playerEquipmentHands
        repository.playerEquipmentHands=!repository.playerEquipmentHands
        mcm.SetToggleOptionValue( optionID, repository.playerEquipmentHands)
    ElseIf optionID==mcm.oid_playerEquipmentHands
        mcm.repository.playerEquipmentHands=!mcm.repository.playerEquipmentHands
        mcm.SetToggleOptionValue( optionID, mcm.repository.playerEquipmentHands)
     ElseIf optionID==mcm.oid_playerEquipmentFeet
        repository.playerEquipmentFeet=!repository.playerEquipmentFeet
        mcm.SetToggleOptionValue( optionID, repository.playerEquipmentFeet)
    ElseIf optionID==mcm.oid_playerEquipmentAmulet
        repository.playerEquipmentAmulet=!repository.playerEquipmentAmulet
        mcm.SetToggleOptionValue( optionID, repository.playerEquipmentAmulet)
    ElseIf optionID==mcm.oid_playerEquipmentRightHand
        repository.playerEquipmentRightHand=!repository.playerEquipmentRightHand
        mcm.SetToggleOptionValue( optionID, repository.playerEquipmentRightHand)
    ElseIf optionID==mcm.oid_playerEquipmentLeftHand
        repository.playerEquipmentLeftHand=!repository.playerEquipmentLeftHand
        mcm.SetToggleOptionValue( optionID, repository.playerEquipmentLeftHand)
    ElseIf optionID==mcm.oid_playerEquipmentAll
        ;This part of the function OptionUpdate flips a bunch of variables in the repository at once :
        mcm.playerEquipmentAllToggle=!mcm.playerEquipmentAllToggle
        mcm.SetToggleOptionValue( mcm.oid_playerEquipmentBody, mcm.playerEquipmentAllToggle)
        mcm.SetToggleOptionValue( mcm.oid_playerEquipmentHead, mcm.playerEquipmentAllToggle)
        mcm.SetToggleOptionValue( mcm.oid_playerEquipmentHands, mcm.playerEquipmentAllToggle)
        mcm.SetToggleOptionValue( mcm.oid_playerEquipmentFeet, mcm.playerEquipmentAllToggle)
        mcm.SetToggleOptionValue( mcm.oid_playerEquipmentAmulet, mcm.playerEquipmentAllToggle)
        mcm.SetToggleOptionValue( mcm.oid_playerEquipmentRightHand, mcm.playerEquipmentAllToggle)
        mcm.SetToggleOptionValue( mcm.oid_playerEquipmentLeftHand, mcm.playerEquipmentAllToggle)
        mcm.SetToggleOptionValue( mcm.oid_playerEquipmentAll, mcm.playerEquipmentAllToggle)
        Repository.playerEquipmentBody=mcm.playerEquipmentAllToggle
        Repository.playerEquipmentHead=mcm.playerEquipmentAllToggle
        Repository.playerEquipmentHands=mcm.playerEquipmentAllToggle
        Repository.playerEquipmentFeet=mcm.playerEquipmentAllToggle
        Repository.playerEquipmentAmulet=mcm.playerEquipmentAllToggle
        Repository.playerEquipmentRightHand=mcm.playerEquipmentAllToggle
        Repository.playerEquipmentLeftHand=mcm.playerEquipmentAllToggle
    
    ;right column
    ElseIf optionID==mcm.oid_targetEquipmentBody
        repository.targetEquipmentBody=!repository.targetEquipmentBody
        mcm.SetToggleOptionValue(optionID, repository.targetEquipmentBody)
    ElseIf optionID==mcm.oid_targetEquipmentHands
        repository.targetEquipmentHands=!repository.targetEquipmentHands
        mcm.SetToggleOptionValue( optionID, repository.targetEquipmentHands)
    ElseIf optionID==mcm.oid_targetEquipmentHands
        mcm.repository.targetEquipmentHands=!mcm.repository.targetEquipmentHands
        mcm.SetToggleOptionValue( optionID, mcm.repository.targetEquipmentHands)
     ElseIf optionID==mcm.oid_targetEquipmentFeet
        repository.targetEquipmentFeet=!repository.targetEquipmentFeet
        mcm.SetToggleOptionValue( optionID, repository.targetEquipmentFeet)
    ElseIf optionID==mcm.oid_targetEquipmentAmulet
        repository.targetEquipmentAmulet=!repository.targetEquipmentAmulet
        mcm.SetToggleOptionValue( optionID, repository.targetEquipmentAmulet)
    ElseIf optionID==mcm.oid_targetEquipmentRightHand
        repository.targetEquipmentRightHand=!repository.targetEquipmentRightHand
        mcm.SetToggleOptionValue( optionID, repository.targetEquipmentRightHand)
    ElseIf optionID==mcm.oid_targetEquipmentLeftHand
        repository.targetEquipmentLeftHand=!repository.targetEquipmentLeftHand
        mcm.SetToggleOptionValue( optionID, repository.targetEquipmentLeftHand)
    ElseIf optionID==mcm.oid_targetEquipmentAll
        ;This part of the function OptionUpdate flips a bunch of variables in the repository at once :
        mcm.targetEquipmentAllToggle=!mcm.targetEquipmentAllToggle
        mcm.SetToggleOptionValue( mcm.oid_targetEquipmentBody, mcm.targetEquipmentAllToggle)
        mcm.SetToggleOptionValue( mcm.oid_targetEquipmentHead, mcm.targetEquipmentAllToggle)
        mcm.SetToggleOptionValue( mcm.oid_targetEquipmentHands, mcm.targetEquipmentAllToggle)
        mcm.SetToggleOptionValue( mcm.oid_targetEquipmentFeet, mcm.targetEquipmentAllToggle)
        mcm.SetToggleOptionValue( mcm.oid_targetEquipmentAmulet, mcm.targetEquipmentAllToggle)
        mcm.SetToggleOptionValue( mcm.oid_targetEquipmentRightHand, mcm.targetEquipmentAllToggle)
        mcm.SetToggleOptionValue( mcm.oid_targetEquipmentLeftHand, mcm.targetEquipmentAllToggle)
        mcm.SetToggleOptionValue( mcm.oid_targetEquipmentAll, mcm.targetEquipmentAllToggle)
        Repository.targetEquipmentBody=mcm.targetEquipmentAllToggle
        Repository.targetEquipmentHead=mcm.targetEquipmentAllToggle
        Repository.targetEquipmentHands=mcm.targetEquipmentAllToggle
        Repository.targetEquipmentFeet=mcm.targetEquipmentAllToggle
        Repository.targetEquipmentAmulet=mcm.targetEquipmentAllToggle
        Repository.targetEquipmentRightHand=mcm.targetEquipmentAllToggle
        Repository.targetEquipmentLeftHand=mcm.targetEquipmentAllToggle
    endif
endfunction 

