Scriptname RaceMenuPlugin extends RaceMenuBase

bool Property HEIGHT_ENABLED = true AutoReadOnly ; Set this to false to rebuild if you don't want height
bool Property WEAPONS_ENABLED = true AutoReadOnly ; Set this to false to rebuild if you don't want weapon scales

string Property NINODE_NPC = "NPC" AutoReadOnly
string Property NINODE_HEAD = "NPC Head [Head]" AutoReadOnly
string Property NINODE_LEFT_BREAST = "NPC L Breast" AutoReadOnly
string Property NINODE_RIGHT_BREAST = "NPC R Breast" AutoReadOnly
string Property NINODE_LEFT_BUTT = "NPC L Butt" AutoReadOnly
string Property NINODE_RIGHT_BUTT = "NPC R Butt" AutoReadOnly
string Property NINODE_LEFT_BREAST_FORWARD = "NPC L Breast01" AutoReadOnly
string Property NINODE_RIGHT_BREAST_FORWARD = "NPC R Breast01" AutoReadOnly
string Property NINODE_LEFT_BICEP = "NPC L UpperarmTwist1 [LUt1]" AutoReadOnly
string Property NINODE_RIGHT_BICEP = "NPC R UpperarmTwist1 [RUt1]" AutoReadOnly
string Property NINODE_LEFT_BICEP_2 = "NPC L UpperarmTwist2 [LUt2]" AutoReadOnly
string Property NINODE_RIGHT_BICEP_2 = "NPC R UpperarmTwist2 [RUt2]" AutoReadOnly

string Property NINODE_QUIVER = "QUIVER" AutoReadOnly
string Property NINODE_BOW = "WeaponBow" AutoReadOnly
string Property NINODE_AXE = "WeaponAxe" AutoReadOnly
string Property NINODE_SWORD = "WeaponSword" AutoReadOnly
string Property NINODE_MACE = "WeaponMace" AutoReadOnly
string Property NINODE_SHIELD = "SHIELD" AutoReadOnly
string Property NINODE_WEAPON_BACK = "WeaponBack" AutoReadOnly
string Property NINODE_WEAPON = "WEAPON" AutoReadOnly

; If you are making your own scaling mod, use your own key name
string Property MOD_OVERRIDE_KEY = "RSMPlugin" AutoReadOnly

string Property CATEGORY_KEY = "rsm_body_scale" AutoReadOnly

; NiOverride version data
int Property SKEE_VERSION = 1 AutoReadOnly
int Property NIOVERRIDE_SCRIPT_VERSION = 2 AutoReadOnly

bool _versionValid = false

; Add Custom Warpaint here
Event OnWarpaintRequest()
	AddWarpaint("$Beauty Mark 01", "Actors\\Character\\Character Assets\\TintMasks\\BeautyMark_01.dds")
	AddWarpaint("$Beauty Mark 02", "Actors\\Character\\Character Assets\\TintMasks\\BeautyMark_02.dds")
	AddWarpaint("$Beauty Mark 03", "Actors\\Character\\Character Assets\\TintMasks\\BeautyMark_03.dds")
	AddWarpaint("$Dragon Tattoo 01", "Actors\\Character\\Character Assets\\TintMasks\\DragonTattoo_01.dds")
EndEvent

Event OnCategoryRequest()
	AddCategory(CATEGORY_KEY, "$BODY SCALES")
EndEvent

Event OnStartup()
	parent.OnStartup()

	int skeeVersion = SKSE.GetPluginVersion("skee")
	int nioverrideScriptVersion = NiOverride.GetScriptVersion()

	; Check NiOverride version, disable most features if this fails
	if skeeVersion >= SKEE_VERSION && nioverrideScriptVersion >= NIOVERRIDE_SCRIPT_VERSION
		_versionValid = true
	Else
		_versionValid = false
	Endif
EndEvent

; Don't use this event to reset things, loading a preset also triggers this
; Event OnResetMenu(Actor target, ActorBase targetBase)
; 	bool isFemale = targetBase.GetSex() as bool
; 	If _versionValid ; Delete all the previous scales
; 		RemoveNodeTransforms(target, isFemale, NINODE_NPC)
; 		RemoveNodeTransforms(target, isFemale, NINODE_HEAD)
; 		RemoveNodeTransforms(target, isFemale, NINODE_LEFT_BREAST)
; 		RemoveNodeTransforms(target, isFemale, NINODE_RIGHT_BREAST)
; 		RemoveNodeTransforms(target, isFemale, NINODE_LEFT_BREAST_FORWARD)
; 		RemoveNodeTransforms(target, isFemale, NINODE_RIGHT_BREAST_FORWARD)
; 		RemoveNodeTransforms(target, isFemale, NINODE_LEFT_BUTT)
; 		RemoveNodeTransforms(target, isFemale, NINODE_RIGHT_BUTT)
; 		RemoveNodeTransforms(target, isFemale, NINODE_LEFT_BICEP)
; 		RemoveNodeTransforms(target, isFemale, NINODE_RIGHT_BICEP)
; 		RemoveNodeTransforms(target, isFemale, NINODE_LEFT_BICEP_2)
; 		RemoveNodeTransforms(target, isFemale, NINODE_RIGHT_BICEP_2)
; 		RemoveNodeTransforms(target, isFemale, NINODE_QUIVER)
; 		RemoveNodeTransforms(target, isFemale, NINODE_BOW)
; 		RemoveNodeTransforms(target, isFemale, NINODE_AXE)
; 		RemoveNodeTransforms(target, isFemale, NINODE_SWORD)
; 		RemoveNodeTransforms(target, isFemale, NINODE_MACE)
; 		RemoveNodeTransforms(target, isFemale, NINODE_SHIELD)
; 		RemoveNodeTransforms(target, isFemale, NINODE_WEAPON_BACK)
; 		RemoveNodeTransforms(target, isFemale, NINODE_WEAPON)
; 	Endif
; EndEvent

; Add Custom sliders here
Event OnSliderRequest(Actor target, ActorBase targetBase, Race actorRace, bool isFemale)
	If HEIGHT_ENABLED
		AddSliderEx("$Height", CATEGORY_KEY, "ChangeHeight", 0.25, 2.00, 0.01, GetNodeScale(target, isFemale, NINODE_NPC))
	Endif

	If NetImmerse.HasNode(target, NINODE_HEAD, false)
		AddSliderEx("$Head", CATEGORY_KEY, "ChangeHeadSize", 0.01, 3.00, 0.01, GetNodeScale(target, isFemale, NINODE_HEAD))
	Endif

	If isFemale == true		
		If NetImmerse.HasNode(target, NINODE_LEFT_BREAST, false)
			AddSliderEx("$Left Breast", CATEGORY_KEY, "ChangeLeftBreast", 0.1, 3.00, 0.01, GetNodeScale(target, isFemale, NINODE_LEFT_BREAST))
		Endif
		If NetImmerse.HasNode(target, NINODE_RIGHT_BREAST, false)
			AddSliderEx("$Right Breast", CATEGORY_KEY, "ChangeRightBreast", 0.1, 3.00, 0.01, GetNodeScale(target, isFemale, NINODE_RIGHT_BREAST))
		Endif
		If NetImmerse.HasNode(target, NINODE_LEFT_BREAST_FORWARD, false)
			AddSliderEx("$Left Breast Curve", CATEGORY_KEY, "ChangeLeftBreastCurve", 0.1, 3.00, 0.01, GetNodeScale(target, isFemale, NINODE_LEFT_BREAST_FORWARD))
		Endif
		If NetImmerse.HasNode(target, NINODE_RIGHT_BREAST_FORWARD, false)
			AddSliderEx("$Right Breast Curve", CATEGORY_KEY, "ChangeRightBreastCurve", 0.1, 3.00, 0.01, GetNodeScale(target, isFemale, NINODE_RIGHT_BREAST_FORWARD))
		Endif
		If NetImmerse.HasNode(target, NINODE_LEFT_BUTT, false)
			AddSliderEx("$Left Glute", CATEGORY_KEY, "ChangeLeftButt", 0.1, 3.00, 0.01, GetNodeScale(target, isFemale, NINODE_LEFT_BUTT))
		Endif
		If NetImmerse.HasNode(target, NINODE_RIGHT_BUTT, false)
			AddSliderEx("$Right Glute", CATEGORY_KEY, "ChangeRightButt", 0.1, 3.00, 0.01, GetNodeScale(target, isFemale, NINODE_RIGHT_BUTT))
		Endif
	Endif

	AddSliderEx("$Left Biceps", CATEGORY_KEY, "ChangeLeftBiceps", 0.1, 2.00, 0.01, GetNodeScale(target, isFemale, NINODE_LEFT_BICEP))
	AddSliderEx("$Right Biceps", CATEGORY_KEY, "ChangeRightBiceps", 0.1, 2.00, 0.01, GetNodeScale(target, isFemale, NINODE_RIGHT_BICEP))

	AddSliderEx("$Left Biceps 2", CATEGORY_KEY, "ChangeLeftBiceps2", 0.1, 2.00, 0.01, GetNodeScale(target, isFemale, NINODE_LEFT_BICEP_2))
	AddSliderEx("$Right Biceps 2", CATEGORY_KEY, "ChangeRightBiceps2", 0.1, 2.00, 0.01, GetNodeScale(target, isFemale, NINODE_RIGHT_BICEP_2))

	If WEAPONS_ENABLED
		If NetImmerse.HasNode(target, NINODE_QUIVER, false)
			AddSliderEx("$Quiver Scale", CATEGORY_KEY, "ChangeQuiverScale", 0.1, 3.00, 0.01, GetNodeScale(target, isFemale, NINODE_QUIVER))
		Endif
		If NetImmerse.HasNode(target, NINODE_BOW, false)
			AddSliderEx("$Bow Scale", CATEGORY_KEY, "ChangeBowScale", 0.1, 3.00, 0.01, GetNodeScale(target, isFemale, NINODE_BOW))
		Endif
		If NetImmerse.HasNode(target, NINODE_AXE, false)
			AddSliderEx("$Axe Scale", CATEGORY_KEY, "ChangeAxeScale", 0.1, 3.00, 0.01, GetNodeScale(target, isFemale, NINODE_AXE))
		Endif
		If NetImmerse.HasNode(target, NINODE_SWORD, false)
			AddSliderEx("$Sword Scale", CATEGORY_KEY, "ChangeSwordScale", 0.1, 3.00, 0.01, GetNodeScale(target, isFemale, NINODE_SWORD))
		Endif
		If NetImmerse.HasNode(target, NINODE_MACE, false)
			AddSliderEx("$Mace Scale", CATEGORY_KEY, "ChangeMaceScale", 0.1, 3.00, 0.01, GetNodeScale(target, isFemale, NINODE_MACE))
		Endif
		If NetImmerse.HasNode(target, NINODE_SHIELD, false)
			AddSliderEx("$Shield Scale", CATEGORY_KEY, "ChangeShieldScale", 0.1, 3.00, 0.01, GetNodeScale(target, isFemale, NINODE_SHIELD))
		Endif
		If NetImmerse.HasNode(target, NINODE_WEAPON_BACK, false)
			AddSliderEx("$Weapon Back Scale", CATEGORY_KEY, "ChangeWeaponBackScale", 0.1, 3.00, 0.01, GetNodeScale(target, isFemale, NINODE_WEAPON_BACK))
		Endif
		If NetImmerse.HasNode(target, NINODE_WEAPON, false)
			AddSliderEx("$Weapon Scale", CATEGORY_KEY, "ChangeWeaponScale", 0.1, 3.00, 0.01, GetNodeScale(target, isFemale, NINODE_WEAPON))
		Endif
	Endif
EndEvent

Event OnSliderChanged(string callback, float value)
	bool isFemale = _targetActorBase.GetSex() as bool
	If _versionValid
		If callback == "ChangeHeight"
			SetNodeScale(_targetActor, isFemale, NINODE_NPC, value)
		ElseIf callback == "ChangeHeadSize"
			SetNodeScale(_targetActor, isFemale, NINODE_HEAD, value)
		Elseif callback == "ChangeLeftBreast"
			SetNodeScale(_targetActor, isFemale, NINODE_LEFT_BREAST, value)
		Elseif callback == "ChangeRightBreast"
			SetNodeScale(_targetActor, isFemale, NINODE_RIGHT_BREAST, value)
		Elseif callback == "ChangeLeftBreastCurve"
			SetNodeScale(_targetActor, isFemale, NINODE_LEFT_BREAST_FORWARD, value)
		Elseif callback == "ChangeRightBreastCurve"
			SetNodeScale(_targetActor, isFemale, NINODE_RIGHT_BREAST_FORWARD, value)
		Elseif callback == "ChangeLeftButt"
			SetNodeScale(_targetActor, isFemale, NINODE_LEFT_BUTT, value)
		Elseif callback == "ChangeRightButt"
			SetNodeScale(_targetActor, isFemale, NINODE_RIGHT_BUTT, value)
		Elseif callback == "ChangeLeftBiceps"
			SetNodeScale(_targetActor, isFemale, NINODE_LEFT_BICEP, value)
		Elseif callback == "ChangeRightBiceps"
			SetNodeScale(_targetActor, isFemale, NINODE_RIGHT_BICEP, value)
		Elseif callback == "ChangeLeftBiceps2"
			SetNodeScale(_targetActor, isFemale, NINODE_LEFT_BICEP_2, value)
		Elseif callback == "ChangeRightBiceps2"
			SetNodeScale(_targetActor, isFemale, NINODE_RIGHT_BICEP_2, value)
		Elseif callback == "ChangeQuiverScale"
			SetNodeScale(_targetActor, isFemale, NINODE_QUIVER, value)
		Elseif callback == "ChangeBowScale"
			SetNodeScale(_targetActor, isFemale, NINODE_BOW, value)
		Elseif callback == "ChangeAxeScale"
			SetNodeScale(_targetActor, isFemale, NINODE_AXE, value)
		Elseif callback == "ChangeSwordScale"
			SetNodeScale(_targetActor, isFemale, NINODE_SWORD, value)
		Elseif callback == "ChangeMaceScale"
			SetNodeScale(_targetActor, isFemale, NINODE_MACE, value)
		Elseif callback == "ChangeShieldScale"
			SetNodeScale(_targetActor, isFemale, NINODE_SHIELD, value)
		Elseif callback == "ChangeWeaponBackScale"
			SetNodeScale(_targetActor, isFemale, NINODE_WEAPON_BACK, value)
		Elseif callback == "ChangeWeaponScale"
			SetNodeScale(_targetActor, isFemale, NINODE_WEAPON, value)
		Endif
	Endif
EndEvent

Function RemoveNodeTransforms(Actor akActor, bool isFemale, string nodeName)
	NiOverride.RemoveNodeTransformScale(akActor, false, isFemale, nodeName, MOD_OVERRIDE_KEY)
	NiOverride.RemoveNodeTransformScale(akActor, true, isFemale, nodeName, MOD_OVERRIDE_KEY)
	NiOverride.UpdateNodeTransform(akActor, false, isFemale, nodeName)
	NiOverride.UpdateNodeTransform(akActor, true, isFemale, nodeName)
EndFunction

Function SetNodeScale(Actor akActor, bool isFemale, string nodeName, float value)
	If value != 1.0
		NiOverride.AddNodeTransformScale(akActor, false, isFemale, nodeName, MOD_OVERRIDE_KEY, value)
		NiOverride.AddNodeTransformScale(akActor, true, isFemale, nodeName, MOD_OVERRIDE_KEY, value)
	Else
		NiOverride.RemoveNodeTransformScale(akActor, false, isFemale, nodeName, MOD_OVERRIDE_KEY)
		NiOverride.RemoveNodeTransformScale(akActor, true, isFemale, nodeName, MOD_OVERRIDE_KEY)
	Endif
	NiOverride.UpdateNodeTransform(akActor, false, isFemale, nodeName)
	NiOverride.UpdateNodeTransform(akActor, true, isFemale, nodeName)
EndFunction

float Function GetNodeScale(Actor akActor, bool isFemale, string nodeName)
	return NiOverride.GetNodeTransformScale(akActor, false, isFemale, nodeName, MOD_OVERRIDE_KEY)
EndFunction