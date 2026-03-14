Scriptname REQ_OutfitUpdater_MQ101 extends Actor
{this script is used to update Ralofs and Hadvar's equipment once the stormcloak soldier in
the tower is killed by Alduin.}

Actor Property Hadvar Auto
Actor Property Ralof Auto

Outfit Property Outfit_Ralof Auto
Outfit Property Outfit_Hadvar Auto

Armor Property PrisonerClothes Auto
Armor Property PrisonerBoots Auto
Armor Property PlayerRobe Auto
Armor Property PlayerBoots Auto

Event OnDeath(Actor akKiller)
	Actor Player = Game.GetPlayer()
	Player.RemoveItem(PrisonerClothes, 1, True)
	Player.RemoveItem(PrisonerBoots, 1, True)
	Player.EquipItem(PlayerRobe, False, True)
	Player.EquipItem(PlayerBoots, False, True)
	Hadvar.SetOutfit(Outfit_Hadvar)
	Utility.Wait(30.0)
	Ralof.SetOutfit(Outfit_Ralof)
EndEvent
