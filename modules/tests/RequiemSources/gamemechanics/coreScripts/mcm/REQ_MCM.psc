scriptname REQ_MCM extends SKI_ConfigBase

REQ_MCM_DataStorage Property data Auto

State iHoursToRespawnCell

    Event OnSliderOpenST()
        SetSliderDialogStartValue(Game.GetGameSettingint("iHoursToRespawnCell") / 24.0)
        SetSliderDialogDefaultValue(Game.GetGameSettingint("iHoursToRespawnCell") / 24.0)
        SetSliderDialogRange(10.0, 365.0)
        SetSliderDialogInterval(1.0)
    EndEvent

    Event OnSliderAcceptST(float value)
        data.iHoursToRespawnCell = (value * 24.0) as int
        Game.SetGameSettingint("iHoursToRespawnCell", data.iHoursToRespawnCell)
        SetSliderOptionValueST(Game.GetGameSettingint("iHoursToRespawnCell") / 24.0,"$REQ_iHoursToRespawnCell_slider")
    EndEvent

    Event OnDefaultST()
        data.iHoursToRespawnCell = 720.0 as int
        Game.SetGameSettingint("iHoursToRespawnCell", data.iHoursToRespawnCell)
        SetSliderOptionValueST(Game.GetGameSettingint("iHoursToRespawnCell") / 24.0,"$REQ_iHoursToRespawnCell_slider")
    EndEvent

    Event OnHighlightST()
        SetInfoText("$REQ_iHoursToRespawnCell_highlight")
    EndEvent

EndState

State iHoursToRespawnCellCleared

    Event OnSliderOpenST()
        SetSliderDialogStartValue(Game.GetGameSettingint("iHoursToRespawnCellCleared") / 24.0)
        SetSliderDialogDefaultValue(Game.GetGameSettingint("iHoursToRespawnCellCleared") / 24.0)
        SetSliderDialogRange(10.0, 365.0)
        SetSliderDialogInterval(1.0)
    EndEvent

    Event OnSliderAcceptST(float value)
        data.iHoursToRespawnCellCleared = (value * 24.0) as int
        Game.SetGameSettingint("iHoursToRespawnCellCleared", data.iHoursToRespawnCellCleared)
        SetSliderOptionValueST(Game.GetGameSettingint("iHoursToRespawnCellCleared") / 24.0,"$REQ_iHoursToRespawnCellCleared_slider")
    EndEvent

    Event OnDefaultST()
        data.iHoursToRespawnCellCleared = 7200.0 as int
        Game.SetGameSettingint("iHoursToRespawnCellCleared", data.iHoursToRespawnCellCleared)
        SetSliderOptionValueST(Game.GetGameSettingint("iHoursToRespawnCellCleared") / 24.0,"$REQ_iHoursToRespawnCellCleared_slider")
    EndEvent

    Event OnHighlightST()
        SetInfoText("$REQ_iHoursToRespawnCellCleared_highlight")
    EndEvent

EndState

State REQ_Combat_NoDeathHandling

    Event OnSelectST()
        data.REQ_Combat_NoDeathHandling.SetValueInt((!(data.REQ_Combat_NoDeathHandling.GetValueInt() as Bool)) as Int )
        SetToggleOptionValueST(data.REQ_Combat_NoDeathHandling.GetValueInt() as Bool)
        If (!data.REQ_Combat_NoDeathHandling.GetValueInt() as Bool)
            Game.SetGameSettingfloat("fPlayerDeathReloadTime", 3600)
        Else
            Game.SetGameSettingfloat("fPlayerDeathReloadTime", 5)
        EndIf
    EndEvent

    Event OnDefaultST()
        data.REQ_Combat_NoDeathHandling.SetValueInt( 0.0 as Int)
        SetToggleOptionValueST(data.REQ_Combat_NoDeathHandling.GetValueInt() as Bool)
        Game.SetGameSettingfloat("fPlayerDeathReloadTime", 3600)
    EndEvent

    Event OnHighlightST()
        SetInfoText("$REQ_REQ_Combat_NoDeathHandling_highlight")
    EndEvent

EndState

State fDiffMultHPByPCL

    Event OnSliderOpenST()
        SetSliderDialogStartValue(Game.GetGameSettingfloat("fDiffMultHPByPCL") / 0.01)
        SetSliderDialogDefaultValue(Game.GetGameSettingfloat("fDiffMultHPByPCL") / 0.01)
        SetSliderDialogRange(10.0, 400.0)
        SetSliderDialogInterval(5.0)
    EndEvent

    Event OnSliderAcceptST(float value)
        data.fDiffMultHPByPCL = (value * 0.01) as float
        Game.SetGameSettingfloat("fDiffMultHPByPCL", data.fDiffMultHPByPCL)
        SetSliderOptionValueST(Game.GetGameSettingfloat("fDiffMultHPByPCL") / 0.01,"$REQ_fDiffMultHPByPCL_slider")
    Game.SetGameSettingFloat("fDiffMultHPByPCVE", Game.GetGameSettingFloat("fDiffMultHPByPCL"))
    Game.SetGameSettingFloat("fDiffMultHPByPCE", Game.GetGameSettingFloat("fDiffMultHPByPCL"))
    Game.SetGameSettingFloat("fDiffMultHPByPCN", Game.GetGameSettingFloat("fDiffMultHPByPCL"))
    Game.SetGameSettingFloat("fDiffMultHPByPCH", Game.GetGameSettingFloat("fDiffMultHPByPCL"))
    Game.SetGameSettingFloat("fDiffMultHPByPCVH", Game.GetGameSettingFloat("fDiffMultHPByPCL"))
    EndEvent

    Event OnDefaultST()
        data.fDiffMultHPByPCL = 1.0 as float
        Game.SetGameSettingfloat("fDiffMultHPByPCL", data.fDiffMultHPByPCL)
        SetSliderOptionValueST(Game.GetGameSettingfloat("fDiffMultHPByPCL") / 0.01,"$REQ_fDiffMultHPByPCL_slider")
    Game.SetGameSettingFloat("fDiffMultHPByPCVE", Game.GetGameSettingFloat("fDiffMultHPByPCL"))
    Game.SetGameSettingFloat("fDiffMultHPByPCE", Game.GetGameSettingFloat("fDiffMultHPByPCL"))
    Game.SetGameSettingFloat("fDiffMultHPByPCN", Game.GetGameSettingFloat("fDiffMultHPByPCL"))
    Game.SetGameSettingFloat("fDiffMultHPByPCH", Game.GetGameSettingFloat("fDiffMultHPByPCL"))
    Game.SetGameSettingFloat("fDiffMultHPByPCVH", Game.GetGameSettingFloat("fDiffMultHPByPCL"))
    EndEvent

    Event OnHighlightST()
        SetInfoText("$REQ_fDiffMultHPByPCL_highlight")
    EndEvent

EndState

State fDiffMultHPToPCL

    Event OnSliderOpenST()
        SetSliderDialogStartValue(Game.GetGameSettingfloat("fDiffMultHPToPCL") / 0.01)
        SetSliderDialogDefaultValue(Game.GetGameSettingfloat("fDiffMultHPToPCL") / 0.01)
        SetSliderDialogRange(10.0, 400.0)
        SetSliderDialogInterval(5.0)
    EndEvent

    Event OnSliderAcceptST(float value)
        data.fDiffMultHPToPCL = (value * 0.01) as float
        Game.SetGameSettingfloat("fDiffMultHPToPCL", data.fDiffMultHPToPCL)
        SetSliderOptionValueST(Game.GetGameSettingfloat("fDiffMultHPToPCL") / 0.01,"$REQ_fDiffMultHPToPCL_slider")
    Game.SetGameSettingFloat("fDiffMultHPToPCVE", Game.GetGameSettingFloat("fDiffMultHPToPCL"))
    Game.SetGameSettingFloat("fDiffMultHPToPCE", Game.GetGameSettingFloat("fDiffMultHPToPCL"))
    Game.SetGameSettingFloat("fDiffMultHPToPCN", Game.GetGameSettingFloat("fDiffMultHPToPCL"))
    Game.SetGameSettingFloat("fDiffMultHPToPCH", Game.GetGameSettingFloat("fDiffMultHPToPCL"))
    Game.SetGameSettingFloat("fDiffMultHPToPCVH", Game.GetGameSettingFloat("fDiffMultHPToPCL"))
    EndEvent

    Event OnDefaultST()
        data.fDiffMultHPToPCL = 1.0 as float
        Game.SetGameSettingfloat("fDiffMultHPToPCL", data.fDiffMultHPToPCL)
        SetSliderOptionValueST(Game.GetGameSettingfloat("fDiffMultHPToPCL") / 0.01,"$REQ_fDiffMultHPToPCL_slider")
    Game.SetGameSettingFloat("fDiffMultHPToPCVE", Game.GetGameSettingFloat("fDiffMultHPToPCL"))
    Game.SetGameSettingFloat("fDiffMultHPToPCE", Game.GetGameSettingFloat("fDiffMultHPToPCL"))
    Game.SetGameSettingFloat("fDiffMultHPToPCN", Game.GetGameSettingFloat("fDiffMultHPToPCL"))
    Game.SetGameSettingFloat("fDiffMultHPToPCH", Game.GetGameSettingFloat("fDiffMultHPToPCL"))
    Game.SetGameSettingFloat("fDiffMultHPToPCVH", Game.GetGameSettingFloat("fDiffMultHPToPCL"))
    EndEvent

    Event OnHighlightST()
        SetInfoText("$REQ_fDiffMultHPToPCL_highlight")
    EndEvent

EndState

State WIWaitDragon

    Event OnSliderOpenST()
        SetSliderDialogStartValue(data.WIWaitDragon.GetValue() / 1.0)
        SetSliderDialogDefaultValue(data.WIWaitDragon.GetValue() / 1.0)
        SetSliderDialogRange(1.0, 28.0)
        SetSliderDialogInterval(1.0)
    EndEvent

    Event OnSliderAcceptST(float value)
        data.WIWaitDragon.SetValue( value * 1.0 )
        SetSliderOptionValueST(data.WIWaitDragon.GetValue() / 1.0,"$REQ_WIWaitDragon_slider")
    EndEvent

    Event OnDefaultST()
        data.WIWaitDragon.SetValue( 12.0)
        SetSliderOptionValueST(data.WIWaitDragon.GetValue() / 1.0, "$REQ_WIWaitDragon_slider")
    EndEvent

    Event OnHighlightST()
        SetInfoText("$REQ_WIWaitDragon_highlight")
    EndEvent

EndState

State fPlayerHealthHeartbeatSlow

    Event OnSliderOpenST()
        SetSliderDialogStartValue(Game.GetGameSettingfloat("fPlayerHealthHeartbeatSlow") / 0.01)
        SetSliderDialogDefaultValue(Game.GetGameSettingfloat("fPlayerHealthHeartbeatSlow") / 0.01)
        SetSliderDialogRange(0.0, 75.0)
        SetSliderDialogInterval(5.0)
    EndEvent

    Event OnSliderAcceptST(float value)
        data.fPlayerHealthHeartbeatSlow = (value * 0.01) as float
        Game.SetGameSettingfloat("fPlayerHealthHeartbeatSlow", data.fPlayerHealthHeartbeatSlow)
        SetSliderOptionValueST(Game.GetGameSettingfloat("fPlayerHealthHeartbeatSlow") / 0.01,"$REQ_fPlayerHealthHeartbeatSlow_slider")
    Game.SetGameSettingFloat("fPlayerHealthHeartbeatFast",Game.GetGameSettingFloat("fPlayerHealthHeartbeatSlow") / 2.0)
    EndEvent

    Event OnDefaultST()
        data.fPlayerHealthHeartbeatSlow = 0.5 as float
        Game.SetGameSettingfloat("fPlayerHealthHeartbeatSlow", data.fPlayerHealthHeartbeatSlow)
        SetSliderOptionValueST(Game.GetGameSettingfloat("fPlayerHealthHeartbeatSlow") / 0.01,"$REQ_fPlayerHealthHeartbeatSlow_slider")
    Game.SetGameSettingFloat("fPlayerHealthHeartbeatFast",Game.GetGameSettingFloat("fPlayerHealthHeartbeatSlow") / 2.0)
    EndEvent

    Event OnHighlightST()
        SetInfoText("$REQ_fPlayerHealthHeartbeatSlow_highlight")
    EndEvent

EndState

State fJumpHeightMin

    Event OnSliderOpenST()
        SetSliderDialogStartValue(Game.GetGameSettingfloat("fJumpHeightMin") / 0.76)
        SetSliderDialogDefaultValue(Game.GetGameSettingfloat("fJumpHeightMin") / 0.76)
        SetSliderDialogRange(50.0, 300.0)
        SetSliderDialogInterval(25.0)
    EndEvent

    Event OnSliderAcceptST(float value)
        data.fJumpHeightMin = (value * 0.76) as float
        Game.SetGameSettingfloat("fJumpHeightMin", data.fJumpHeightMin)
        SetSliderOptionValueST(Game.GetGameSettingfloat("fJumpHeightMin") / 0.76,"$REQ_fJumpHeightMin_slider")
    EndEvent

    Event OnDefaultST()
        data.fJumpHeightMin = 76.0 as float
        Game.SetGameSettingfloat("fJumpHeightMin", data.fJumpHeightMin)
        SetSliderOptionValueST(Game.GetGameSettingfloat("fJumpHeightMin") / 0.76,"$REQ_fJumpHeightMin_slider")
    EndEvent

    Event OnHighlightST()
        SetInfoText("$REQ_fJumpHeightMin_highlight")
    EndEvent

EndState

State REQ_Skills_RateFactor

    Event OnSliderOpenST()
        SetSliderDialogStartValue(data.REQ_Skills_RateFactor.GetValue() / 1.0)
        SetSliderDialogDefaultValue(data.REQ_Skills_RateFactor.GetValue() / 1.0)
        SetSliderDialogRange(50.0, 100.0)
        SetSliderDialogInterval(5.0)
    EndEvent

    Event OnSliderAcceptST(float value)
        data.REQ_Skills_RateFactor.SetValue( value * 1.0 )
        SetSliderOptionValueST(data.REQ_Skills_RateFactor.GetValue() / 1.0,"$REQ_REQ_Skills_RateFactor_slider")
    EndEvent

    Event OnDefaultST()
        data.REQ_Skills_RateFactor.SetValue( 100.0)
        SetSliderOptionValueST(data.REQ_Skills_RateFactor.GetValue() / 1.0, "$REQ_REQ_Skills_RateFactor_slider")
    EndEvent

    Event OnHighlightST()
        SetInfoText("$REQ_REQ_Skills_RateFactor_highlight")
    EndEvent

EndState

State TimeScale

    Event OnSliderOpenST()
        SetSliderDialogStartValue(data.TimeScale.GetValue() / 1.0)
        SetSliderDialogDefaultValue(data.TimeScale.GetValue() / 1.0)
        SetSliderDialogRange(5.0, 30.0)
        SetSliderDialogInterval(1.0)
    EndEvent

    Event OnSliderAcceptST(float value)
        data.TimeScale.SetValue( value * 1.0 )
        SetSliderOptionValueST(data.TimeScale.GetValue() / 1.0,"$REQ_TimeScale_slider")
    EndEvent

    Event OnDefaultST()
        data.TimeScale.SetValue( 10.0)
        SetSliderOptionValueST(data.TimeScale.GetValue() / 1.0, "$REQ_TimeScale_slider")
    EndEvent

    Event OnHighlightST()
        SetInfoText("$REQ_TimeScale_highlight")
    EndEvent

EndState

State REQ_Debug_ArmorTraining

    Event OnSelectST()
        data.REQ_Debug_ArmorTraining.SetValueInt((!(data.REQ_Debug_ArmorTraining.GetValueInt() as Bool)) as Int )
        SetToggleOptionValueST(data.REQ_Debug_ArmorTraining.GetValueInt() as Bool)
    EndEvent

    Event OnDefaultST()
        data.REQ_Debug_ArmorTraining.SetValueInt( 0.0 as Int)
        SetToggleOptionValueST(data.REQ_Debug_ArmorTraining.GetValueInt() as Bool)
    EndEvent

    Event OnHighlightST()
        SetInfoText("$REQ_REQ_Debug_ArmorTraining_highlight")
    EndEvent

EndState

State REQ_Compatibility_AttackSpeed

    Event OnSelectST()
        data.REQ_Compatibility_AttackSpeed.SetValueInt((!(data.REQ_Compatibility_AttackSpeed.GetValueInt() as Bool)) as Int )
        SetToggleOptionValueST(data.REQ_Compatibility_AttackSpeed.GetValueInt() as Bool)
    EndEvent

    Event OnDefaultST()
        data.REQ_Compatibility_AttackSpeed.SetValueInt( 0.0 as Int)
        SetToggleOptionValueST(data.REQ_Compatibility_AttackSpeed.GetValueInt() as Bool)
    EndEvent

    Event OnHighlightST()
        SetInfoText("$REQ_REQ_Compatibility_AttackSpeed_highlight")
    EndEvent

EndState

State REQ_Combat_NoDragonFear

    Event OnSelectST()
        data.REQ_Combat_NoDragonFear.SetValueInt((!(data.REQ_Combat_NoDragonFear.GetValueInt() as Bool)) as Int )
        SetToggleOptionValueST(data.REQ_Combat_NoDragonFear.GetValueInt() as Bool)
    EndEvent

    Event OnDefaultST()
        data.REQ_Combat_NoDragonFear.SetValueInt( 0.0 as Int)
        SetToggleOptionValueST(data.REQ_Combat_NoDragonFear.GetValueInt() as Bool)
    EndEvent

    Event OnHighlightST()
        SetInfoText("$REQ_REQ_Combat_NoDragonFear_highlight")
    EndEvent

EndState

State REQ_Combat_EssentialAgain

    Event OnSelectST()
        data.REQ_Combat_EssentialAgain.SetValueInt((!(data.REQ_Combat_EssentialAgain.GetValueInt() as Bool)) as Int )
        SetToggleOptionValueST(data.REQ_Combat_EssentialAgain.GetValueInt() as Bool)
    EndEvent

    Event OnDefaultST()
        data.REQ_Combat_EssentialAgain.SetValueInt( 0.0 as Int)
        SetToggleOptionValueST(data.REQ_Combat_EssentialAgain.GetValueInt() as Bool)
    EndEvent

    Event OnHighlightST()
        SetInfoText("$REQ_REQ_Combat_EssentialAgain_highlight")
    EndEvent

EndState

State REQ_Combat_NoOnHitDisarm

    Event OnSelectST()
        data.REQ_Combat_NoOnHitDisarm.SetValueInt((!(data.REQ_Combat_NoOnHitDisarm.GetValueInt() as Bool)) as Int )
        SetToggleOptionValueST(data.REQ_Combat_NoOnHitDisarm.GetValueInt() as Bool)
    EndEvent

    Event OnDefaultST()
        data.REQ_Combat_NoOnHitDisarm.SetValueInt( 0.0 as Int)
        SetToggleOptionValueST(data.REQ_Combat_NoOnHitDisarm.GetValueInt() as Bool)
    EndEvent

    Event OnHighlightST()
        SetInfoText("$REQ_REQ_Combat_NoOnHitDisarm_highlight")
    EndEvent

EndState

State REQ_Atmosphere_AllowFastTravel

    Event OnSelectST()
        data.REQ_Atmosphere_AllowFastTravel.SetValueInt((!(data.REQ_Atmosphere_AllowFastTravel.GetValueInt() as Bool)) as Int )
        SetToggleOptionValueST(data.REQ_Atmosphere_AllowFastTravel.GetValueInt() as Bool)
    Game.EnableFastTravel(data.REQ_Atmosphere_AllowFastTravel.GetValueInt() as Bool)
    EndEvent

    Event OnDefaultST()
        data.REQ_Atmosphere_AllowFastTravel.SetValueInt( 0.0 as Int)
        SetToggleOptionValueST(data.REQ_Atmosphere_AllowFastTravel.GetValueInt() as Bool)
    Game.EnableFastTravel(data.REQ_Atmosphere_AllowFastTravel.GetValueInt() as Bool)
    EndEvent

    Event OnHighlightST()
        SetInfoText("$REQ_REQ_Atmosphere_AllowFastTravel_highlight")
    EndEvent

EndState

State REQ_Combat_NoFearAndYield

    Event OnSelectST()
        data.REQ_Combat_NoFearAndYield.SetValueInt((!(data.REQ_Combat_NoFearAndYield.GetValueInt() as Bool)) as Int )
        SetToggleOptionValueST(data.REQ_Combat_NoFearAndYield.GetValueInt() as Bool)
    EndEvent

    Event OnDefaultST()
        data.REQ_Combat_NoFearAndYield.SetValueInt( 0.0 as Int)
        SetToggleOptionValueST(data.REQ_Combat_NoFearAndYield.GetValueInt() as Bool)
    EndEvent

    Event OnHighlightST()
        SetInfoText("$REQ_REQ_Combat_NoFearAndYield_highlight")
    EndEvent

EndState

State REQ_Debug_OnHit

    Event OnSelectST()
        data.REQ_Debug_OnHit.SetValueInt((!(data.REQ_Debug_OnHit.GetValueInt() as Bool)) as Int )
        SetToggleOptionValueST(data.REQ_Debug_OnHit.GetValueInt() as Bool)
    EndEvent

    Event OnDefaultST()
        data.REQ_Debug_OnHit.SetValueInt( 0.0 as Int)
        SetToggleOptionValueST(data.REQ_Debug_OnHit.GetValueInt() as Bool)
    EndEvent

    Event OnHighlightST()
        SetInfoText("$REQ_REQ_Debug_OnHit_highlight")
    EndEvent

EndState

State REQ_Combat_NoHorseTrample

    Event OnSelectST()
        data.REQ_Combat_NoHorseTrample.SetValueInt((!(data.REQ_Combat_NoHorseTrample.GetValueInt() as Bool)) as Int )
        SetToggleOptionValueST(data.REQ_Combat_NoHorseTrample.GetValueInt() as Bool)
    EndEvent

    Event OnDefaultST()
        data.REQ_Combat_NoHorseTrample.SetValueInt( 0.0 as Int)
        SetToggleOptionValueST(data.REQ_Combat_NoHorseTrample.GetValueInt() as Bool)
    EndEvent

    Event OnHighlightST()
        SetInfoText("$REQ_REQ_Combat_NoHorseTrample_highlight")
    EndEvent

EndState

State REQ_Atmosphere_NoPoisonISM

    Event OnSelectST()
        data.REQ_Atmosphere_NoPoisonISM.SetValueInt((!(data.REQ_Atmosphere_NoPoisonISM.GetValueInt() as Bool)) as Int )
        SetToggleOptionValueST(data.REQ_Atmosphere_NoPoisonISM.GetValueInt() as Bool)
    EndEvent

    Event OnDefaultST()
        data.REQ_Atmosphere_NoPoisonISM.SetValueInt( 0.0 as Int)
        SetToggleOptionValueST(data.REQ_Atmosphere_NoPoisonISM.GetValueInt() as Bool)
    EndEvent

    Event OnHighlightST()
        SetInfoText("$REQ_REQ_Atmosphere_NoPoisonISM_highlight")
    EndEvent

EndState

State REQ_Skills_HideClutterRecipes

    Event OnSelectST()
        data.REQ_Skills_HideClutterRecipes.SetValueInt((!(data.REQ_Skills_HideClutterRecipes.GetValueInt() as Bool)) as Int )
        SetToggleOptionValueST(data.REQ_Skills_HideClutterRecipes.GetValueInt() as Bool)
    EndEvent

    Event OnDefaultST()
        data.REQ_Skills_HideClutterRecipes.SetValueInt( 0.0 as Int)
        SetToggleOptionValueST(data.REQ_Skills_HideClutterRecipes.GetValueInt() as Bool)
    EndEvent

    Event OnHighlightST()
        SetInfoText("$REQ_REQ_Skills_HideClutterRecipes_highlight")
    EndEvent

EndState

State REQ_Atmosphere_SlowerHorses

    Event OnSelectST()
        data.REQ_Atmosphere_SlowerHorses.SetValueInt((!(data.REQ_Atmosphere_SlowerHorses.GetValueInt() as Bool)) as Int )
        SetToggleOptionValueST(data.REQ_Atmosphere_SlowerHorses.GetValueInt() as Bool)
    EndEvent

    Event OnDefaultST()
        data.REQ_Atmosphere_SlowerHorses.SetValueInt( 0.0 as Int)
        SetToggleOptionValueST(data.REQ_Atmosphere_SlowerHorses.GetValueInt() as Bool)
    EndEvent

    Event OnHighlightST()
        SetInfoText("$REQ_REQ_Atmosphere_SlowerHorses_highlight")
    EndEvent

EndState

State REQ_Skills_NoSmithingBooks

    Event OnSelectST()
        data.REQ_Skills_NoSmithingBooks.SetValueInt((!(data.REQ_Skills_NoSmithingBooks.GetValueInt() as Bool)) as Int )
        SetToggleOptionValueST(data.REQ_Skills_NoSmithingBooks.GetValueInt() as Bool)
    EndEvent

    Event OnDefaultST()
        data.REQ_Skills_NoSmithingBooks.SetValueInt( 0.0 as Int)
        SetToggleOptionValueST(data.REQ_Skills_NoSmithingBooks.GetValueInt() as Bool)
    EndEvent

    Event OnHighlightST()
        SetInfoText("$REQ_REQ_Skills_NoSmithingBooks_highlight")
    EndEvent

EndState

State REQ_Atmosphere_VampireRandomCarnage

    Event OnSelectST()
        data.REQ_Atmosphere_VampireRandomCarnage.SetValueInt((!(data.REQ_Atmosphere_VampireRandomCarnage.GetValueInt() as Bool)) as Int )
        SetToggleOptionValueST(data.REQ_Atmosphere_VampireRandomCarnage.GetValueInt() as Bool)
    EndEvent

    Event OnDefaultST()
        data.REQ_Atmosphere_VampireRandomCarnage.SetValueInt( 0.0 as Int)
        SetToggleOptionValueST(data.REQ_Atmosphere_VampireRandomCarnage.GetValueInt() as Bool)
    EndEvent

    Event OnHighlightST()
        SetInfoText("$REQ_REQ_Atmosphere_VampireRandomCarnage_highlight")
    EndEvent

EndState

State REQ_Atmosphere_KillmoveHealthThreshold

    Event OnSliderOpenST()
        SetSliderDialogStartValue(data.REQ_Atmosphere_KillmoveHealthThreshold.GetValue() / 0.01)
        SetSliderDialogDefaultValue(25.0)
        SetSliderDialogRange(0.0, 100.0)
        SetSliderDialogInterval(1.0)
    EndEvent

    Event OnSliderAcceptST(float value)
        data.REQ_Atmosphere_KillmoveHealthThreshold.SetValue( value * 0.01 )
        SetSliderOptionValueST(data.REQ_Atmosphere_KillmoveHealthThreshold.GetValue() / 0.01 ,"$REQ_Atmosphere_KillmoveHealthThreshold_slider")
    EndEvent

    Event OnDefaultST()
        data.REQ_Atmosphere_KillmoveHealthThreshold.SetValue(0.25)
        SetSliderOptionValueST(data.REQ_Atmosphere_KillmoveHealthThreshold.GetValue() / 0.01 , "$REQ_Atmosphere_KillmoveHealthThreshold_slider")
    EndEvent

    Event OnHighlightST()
        SetInfoText("$REQ_Atmosphere_KillmoveHealthThreshold_highlight")
    EndEvent

EndState

State REQ_Atmosphere_FasterOutOfCombatRegen

    Event OnSelectST()
        data.REQ_Atmosphere_FasterOutOfCombatRegen.SetValueInt((!(data.REQ_Atmosphere_FasterOutOfCombatRegen.GetValueInt() as Bool)) as Int )
        SetToggleOptionValueST(data.REQ_Atmosphere_FasterOutOfCombatRegen.GetValueInt() as Bool)
    EndEvent

    Event OnDefaultST()
        data.REQ_Atmosphere_FasterOutOfCombatRegen.SetValueInt( 0.0 as Int)
        SetToggleOptionValueST(data.REQ_Atmosphere_FasterOutOfCombatRegen.GetValueInt() as Bool)
    EndEvent

    Event OnHighlightST()
        SetInfoText("$REQ_Atmosphere_FasterOutOfCombatRegen_highlight")
    EndEvent

EndState

Event OnPageReset(String page)
    UnloadCustomContent()
    If page == ""
        If pages.length > 0
            LoadCustomContent("Requiem\\MCM_background.dds", 56, 23)
        Else
            LoadCustomContent("Requiem\\MCM_background_warning.dds", 56, 23)
        Endif
    ElseIf page == "$REQ_cat_0"
        AddToggleOptionST("REQ_Combat_NoDeathHandling","$REQ_REQ_Combat_NoDeathHandling",data.REQ_Combat_NoDeathHandling.GetValueInt() as Bool)
        AddSliderOptionST("fDiffMultHPByPCL",  "$REQ_fDiffMultHPByPCL", Game.GetGameSettingfloat("fDiffMultHPByPCL") / 0.01, "$REQ_fDiffMultHPByPCL_slider")
        AddSliderOptionST("fDiffMultHPToPCL",  "$REQ_fDiffMultHPToPCL", Game.GetGameSettingfloat("fDiffMultHPToPCL") / 0.01, "$REQ_fDiffMultHPToPCL_slider")
        AddToggleOptionST("REQ_Combat_NoDragonFear","$REQ_REQ_Combat_NoDragonFear",data.REQ_Combat_NoDragonFear.GetValueInt() as Bool)
        AddToggleOptionST("REQ_Combat_EssentialAgain","$REQ_REQ_Combat_EssentialAgain",data.REQ_Combat_EssentialAgain.GetValueInt() as Bool)
        AddToggleOptionST("REQ_Combat_NoOnHitDisarm","$REQ_REQ_Combat_NoOnHitDisarm",data.REQ_Combat_NoOnHitDisarm.GetValueInt() as Bool)
        AddToggleOptionST("REQ_Combat_NoFearAndYield","$REQ_REQ_Combat_NoFearAndYield",data.REQ_Combat_NoFearAndYield.GetValueInt() as Bool)
        AddToggleOptionST("REQ_Combat_NoHorseTrample","$REQ_REQ_Combat_NoHorseTrample",data.REQ_Combat_NoHorseTrample.GetValueInt() as Bool)
    ElseIf page == "$REQ_cat_1"
        AddSliderOptionST("fJumpHeightMin",  "$REQ_fJumpHeightMin", Game.GetGameSettingfloat("fJumpHeightMin") / 0.76, "$REQ_fJumpHeightMin_slider")
        AddSliderOptionST("REQ_Skills_RateFactor",  "$REQ_REQ_Skills_RateFactor", data.REQ_Skills_RateFactor.GetValue() / 1.0, "$REQ_REQ_Skills_RateFactor_slider")
        AddToggleOptionST("REQ_Skills_HideClutterRecipes","$REQ_REQ_Skills_HideClutterRecipes",data.REQ_Skills_HideClutterRecipes.GetValueInt() as Bool)
        AddToggleOptionST("REQ_Skills_NoSmithingBooks","$REQ_REQ_Skills_NoSmithingBooks",data.REQ_Skills_NoSmithingBooks.GetValueInt() as Bool)
    ElseIf page == "$REQ_cat_2"
        AddSliderOptionST("iHoursToRespawnCell",  "$REQ_iHoursToRespawnCell", Game.GetGameSettingint("iHoursToRespawnCell") / 24.0, "$REQ_iHoursToRespawnCell_slider")
        AddSliderOptionST("iHoursToRespawnCellCleared",  "$REQ_iHoursToRespawnCellCleared", Game.GetGameSettingint("iHoursToRespawnCellCleared") / 24.0, "$REQ_iHoursToRespawnCellCleared_slider")
        AddSliderOptionST("WIWaitDragon",  "$REQ_WIWaitDragon", data.WIWaitDragon.GetValue() / 1.0, "$REQ_WIWaitDragon_slider")
        AddSliderOptionST("fPlayerHealthHeartbeatSlow",  "$REQ_fPlayerHealthHeartbeatSlow", Game.GetGameSettingfloat("fPlayerHealthHeartbeatSlow") / 0.01, "$REQ_fPlayerHealthHeartbeatSlow_slider")
        AddSliderOptionST("TimeScale",  "$REQ_TimeScale", data.TimeScale.GetValue() / 1.0, "$REQ_TimeScale_slider")
		AddSliderOptionST("REQ_Atmosphere_KillmoveHealthThreshold","$REQ_Atmosphere_KillmoveHealthThreshold",data.REQ_Atmosphere_KillmoveHealthThreshold.GetValue() / 0.01, "$REQ_Atmosphere_KillmoveHealthThreshold_slider")
        AddToggleOptionST("REQ_Atmosphere_AllowFastTravel","$REQ_REQ_Atmosphere_AllowFastTravel",data.REQ_Atmosphere_AllowFastTravel.GetValueInt() as Bool)
        AddToggleOptionST("REQ_Atmosphere_NoPoisonISM","$REQ_REQ_Atmosphere_NoPoisonISM",data.REQ_Atmosphere_NoPoisonISM.GetValueInt() as Bool)
        AddToggleOptionST("REQ_Atmosphere_SlowerHorses","$REQ_REQ_Atmosphere_SlowerHorses",data.REQ_Atmosphere_SlowerHorses.GetValueInt() as Bool)
        AddToggleOptionST("REQ_Atmosphere_VampireRandomCarnage","$REQ_REQ_Atmosphere_VampireRandomCarnage",data.REQ_Atmosphere_VampireRandomCarnage.GetValueInt() as Bool)
        AddToggleOptionST("REQ_Atmosphere_FasterOutOfCombatRegen","$REQ_Atmosphere_FasterOutOfCombatRegen",data.REQ_Atmosphere_FasterOutOfCombatRegen.GetValueInt() as Bool)
    ElseIf page == "$REQ_cat_3"
        AddToggleOptionST("REQ_Debug_ArmorTraining","$REQ_REQ_Debug_ArmorTraining",data.REQ_Debug_ArmorTraining.GetValueInt() as Bool)
        AddToggleOptionST("REQ_Compatibility_AttackSpeed","$REQ_REQ_Compatibility_AttackSpeed",data.REQ_Compatibility_AttackSpeed.GetValueInt() as Bool)
        AddToggleOptionST("REQ_Debug_OnHit","$REQ_REQ_Debug_OnHit",data.REQ_Debug_OnHit.GetValueInt() as Bool)
    EndIf
EndEvent
