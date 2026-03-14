Scriptname Req_DraconicKNowledgeEffect extends activemagiceffect  

Event OnEffectStart(Actor Caster, Actor Target)

	Game.GetPlayer().ModActorValue("DragonSouls", 1)

	Utility.Wait(0.1)

	Game.GetPlayer().RemovePerk(DraconicKnowledgePerk)

	Game.GetPlayer().RemoveSpell(DraconicKnowledgeProperty)


EndEvent



SPELL Property DraconicKnowledgeProperty  Auto  

Perk Property DraconicKnowledgePerk  Auto  
