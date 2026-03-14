ScriptName REQ_AncientDawnguardWarAxe_KillCounter Extends ActiveMagicEffect

GlobalVariable Property UndeadKilled Auto

REQ_ReapplyNonPersistentChanges Property ReapplyNonPersistentChanges Auto

Quest Property ResetQuest Auto


Event OnDying(Actor akKiller)
	UndeadKilled.Mod(1.0)
	ResetQuest.Start()
	ReapplyNonPersistentChanges.AncientDawnguardWarAxeScript.RescaleEnchantment()
EndEvent
