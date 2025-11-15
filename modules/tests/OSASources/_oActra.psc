Scriptname _oActra extends activemagiceffect  



; ██████╗ ███████╗ █████╗      █████╗  ██████╗████████╗██████╗  █████╗                                                                                                
;██╔═══██╗██╔════╝██╔══██╗    ██╔══██╗██╔════╝╚══██╔══╝██╔══██╗██╔══██╗                                                                                               
;██║   ██║███████╗███████║    ███████║██║        ██║   ██████╔╝███████║                                                                                               
;██║   ██║╚════██║██╔══██║    ██╔══██║██║        ██║   ██╔══██╗██╔══██║                                                                                               
;╚██████╔╝███████║██║  ██║    ██║  ██║╚██████╗   ██║   ██║  ██║██║  ██║                                                                                               
; ╚═════╝ ╚══════╝╚═╝  ╚═╝    ╚═╝  ╚═╝ ╚═════╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝
;█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗                                                                                             
;╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝      
;OSA empowered spell effect with all needed scene functionality.

import _oGlobal
;OSA Global Functions

Actor Property PlayerRef Auto

_oOmni Property OSO hidden
    _oOmni function get()
        return Quest.GetQuest("0SA") as _oOmni 
    endFunction
endProperty
;Add the _oOmni persistent script based in quest 0SA


actor Actra
int glyph
int StageID
string FormID


formlist[] OFormSuite
effectShader[] shaderFX 

int ThrottleMFG = 3
float ThrottleScale = 0.2
string[] OAE
string codePage

objectReference posObj

bool firstScale = true

Event Oneffectstart (actor tarAct, actor Spot)

Actra = tarAct
FormID = GetFormID_s(Actra.GetActorBase())
glyph = OSO.glyph
stageID = Actra.getFactionRank(OSO.OFaction[1])
registerEvents()
registerAE()
codePage = oso.codePage
shaderFX = new effectShader[10]
OFormSuite = new Formlist[100]
OAE = new String[3]
OAE[0] = FormID
OAE[1] = StageID 
posObj = OSO.GlobalPosition[StageID as int]


 sheathWep(actra, PlayerRef)
 actorLock(actra, PlayerRef)



ActraReveal(Actra, FormID, StageID)


Actra.SetAnimationVariableBool("bHumanoidFootIKDisable", true)

if actra == PlayerRef
UI.SetBool("HUD Menu", "_root.HUDMovieBaseInstance._visible", false)
endif
EndEvent


Function registerAE()
RegisterForAnimationEvent(Actra, "0S0")
endFunction

Function registerEvents()
RegisterForModEvent("0SA"+"_GameLoaded", "OnGameLoaded")

RegisterForModEvent("0SAA"+FormID+"_ActraEnd", "OnActraEnd")
RegisterForModEvent("0SAA"+FormID+"_NoFuse", "OnNoFuse")
RegisterForModEvent("0SAA"+FormID+"_ChangeStage", "OnChangeStage")
RegisterForModEvent("0SAA"+FormID+"_CenterActro", "OnCenterActro")
RegisterForModEvent("0SAA"+FormID+"_FormBind", "OnFormBind")

RegisterForModEvent("0SAA"+FormID+"_Animate", "OnAnimate")
RegisterForModEvent("0SAA"+FormID+"_AlignStage", "OnAlignStage")
RegisterForModEvent("0SAA"+FormID+"_BlendMo", "OnBlendMo")
RegisterForModEvent("0SAA"+FormID+"_BlendPh", "OnBlendPh")
RegisterForModEvent("0SAA"+FormID+"_BlendEx", "OnBlendEx")
RegisterForModEvent("0SAA"+FormID+"_BlendSc", "OnBlendSc")
RegisterForModEvent("0SAA"+FormID+"_SnapSc", "OnSnapSc")
RegisterForModEvent("0SAA"+FormID+"_BodyScale", "OnBodyScale")


RegisterForModEvent("0SSO"+FormID+"_Sound", "OnSound")
RegisterForModEvent("0SAA"+FormID+"_OShader", "OnOShader")
RegisterForModEvent("0SAA"+FormID+"_Lights", "OnLights")
RegisterForModEvent("0SAA"+FormID+"_Kill", "OnKill")
;;ESG Related
RegisterForModEvent("0SAA"+FormID+"_RequestEQSuite", "OnRequestEQSuite")
RegisterForModEvent("0SAA"+FormID+"_EqON", "OnEqON")
RegisterForModEvent("0SAA"+FormID+"_EqOnAutoInt", "OnEqOnAutoInt")
RegisterForModEvent("0SAA"+FormID+"_EqOFF", "OnEqOFF")
RegisterForModEvent("0SAA"+FormID+"_EqOffAutoInt", "OnEqOffAutoInt")
RegisterForModEvent("0SAA"+FormID+"_WepOFF", "OnWepOFF")
RegisterForModEvent("0SAA"+FormID+"_WepON", "OnWepON")

EndFunction

Event OnGameLoaded(string eventName, string zAnimation, float numArg, Form sender)
loadEnd = true
Self.Dispel()
EndEvent


event OnEffectFinish(Actor akTarget, Actor akCaster)
completeEnd()
endEvent


event OnCenterActro(string eventName, string newStageID, float numArg, Form sender)
actra.SetFactionRank(OSO.OFaction[1], newStageID as int)
stageID = newStageID as int
RegisterForModEvent("0S0"+StageID+"_StageReady", "OnStageReady")
OSO.OSpell[1].cast(actra, actra)
endEvent



event OnChangeStage(string eventName, string newStageID, float numArg, Form sender)
actra.SetFactionRank(OSO.OFaction[1], newStageID as int)
stageID = newStageID as int
RegisterForModEvent("0S0"+StageID+"_StageReady", "OnStageReady")
endEvent

event OnStageReady()
ActraReveal(Actra, FormID, StageID)
UnRegisterForModEvent("0S0"+StageID+"_StageReady")
endEvent

Event OnActraEnd(string eventName, string zAnimation, float numArg, Form sender)
if actra == PlayerRef
	UI.SetBool("HUD Menu", "_root.HUDMovieBaseInstance._visible", true)
endif
Self.Dispel()
EndEvent


bool loadEnd = false

function completeEnd()
if actra != none ;<-------------------- Shield is in place so I'm not sure how a none actor can get by.
if (actra.Is3DLoaded()) ;<----------------------------------------------------------------- NEW SHIELD START IF 3D, ISN"T LOADED DO NOTHING
ActorLight(Actra, "Remove", OSO.OLightSP, OSO.OLightME)
FactionClean(Actra, OSO.OFaction)
MfgConsoleFunc.ResetPhonemeModifier(Actra)
packageClean(Actra, OSO.OPackage)
Actra.ClearExpressionOverride()
Actra.SetAnimationVariableBool("bHumanoidFootIKDisable", false)
if loadEnd
ActorUnlock(Actra, PlayerRef)
Else
objectreference lastPoint = actra.placeAtMe(OSO.OBlankStatic)
lastPoint.MoveToNode(actra, "NPC COM [COM ]")
ActorSmoothUnlock(Actra, PlayerRef, lastPoint.X, lastPoint.Y)
lastPoint.Delete()
lastPoint= none
endIf
endif ;<----------------------------------------------------------------- NEW SHIELD END
endIf ;<------------------------------------------------ Conclude Shield
endFunction
 
 
Event OnLoad()
completeEnd()              ;<---------- When 3D does load try it again
endEvent




;If a module doesn't want the actors stacked and rooted on a specific spot this function unfuses them.
;Mainly used for 1 actor scenes where positioning isn't as important or to convert a 2+ actor scene
;into a few 1 actor scenes and have the actors disperse themselves.

event OnNoFuse(string eventName, string huh, float numArg, Form sender)
actra.StopTranslation()
actra.SetVehicle(None)
endEvent


event OnAlignStage()

actra.StopTranslation()

; This is the section I'd like to be able to remove and have the TranslateTo handle the rotations
; You can see when it does the hard setSangle that the camera gets unsmoothly set to the new location
; and that the game sound gets cut and restarted. Not an ideal transtion

	if Math.Abs(actra.GetAngleZ() - posObj.getAngleZ()) > 0.5   
        actra.SetAngle(0, 0, posObj.getAngleZ())
   EndIf	

;The below translateTo does not seem to rotate the player, only setting their position x,y,z
;The postObj.getAngleZ() only seems to rotate NPCs however if this could somehow effect the player it would
;make this whole thing much bette / smoother
 
actra.TranslateTo(posObj.x, posObj.y, posObj.z, 0, 0, posObj.getAngleZ(), 150.0, 0)
actra.SetVehicle(posObj) 
endEvent


Event OnTranslationComplete()

EndEvent


;Phoneme, Modifier, and Node Scale Blends

Event OnBlendMo(string eventName, string zType, float zAmount, Form sender) 
int zTy = zType as int	
blendMo(Actra, zAmount as int, MfgConsoleFunc.GetModifier(Actra, zTy), zTy, ThrottleMFG)
EndEvent
;For Softly Blending Modifiers to a new alignment

Event OnBlendPh(string eventName, string zType, float zAmount, Form sender) 
int zTy = zType as int
blendPh(Actra, zAmount as int, MfgConsoleFunc.GetPhoneme(Actra, zTy), zTy, ThrottleMFG)
EndEvent
;For Softly Blending Phonemes to a new alignment

Event OnBlendEx(string eventName, string zType, float zAmount, Form sender) 
Actra.SetExpressionOverride(zType as int, zAmount as int)
EndEvent
;For Receiving Expressions

Event OnBlendSc(string eventName, string zType, float zAmount, Form sender) 
if zAmount
	if NetImmerse.HasNode(Actra, zType, false)
	blendSc(Actra, zAmount, NetImmerse.GetNodeScale(Actra, zType, false), zType, ThrottleScale)
    endIf
endIf
EndEvent
;For Blending NodeScale softly to a new scale

Event OnSnapSc(string eventName, string zType, float zAmount, Form sender)
NetImmerse.SetNodeScale(Actra, zType, zAmount, false)
EndEvent
;For instantly setting scale back in place at times when
;dramatic effect aren't needed


Event OnBodyScale(string eventName, string zType, float zAmount, Form sender)
actra.setScale(zAmount)
;if firstScale
;firstScale = false
utility.wait(2.0)
actra.setScale(zAmount)
;endif
EndEvent


Event OnFormBind(string eventName, string zMod, float ixid, Form sender)
int Ix = StringUtil.substring(ixid, 0, 2) as int
int Fo = StringUtil.substring(ixid, 2) as int
OFormSuite[Ix] = Game.GetFormFromFile(Fo, zMod) as FormList
EndEvent


Event OnSound(string eventName, string fi, float ix, Form sender)
int S = (OFormSuite[Ix as int].GetAt(fi as int) as Sound).play(Actra)
	Sound.SetInstanceVolume(S, 1.0)
EndEvent


Event OnAnimate(string eventName, string zAnimation, float numArg, Form sender)
Debug.SendAnimationEvent(Actra, zAnimation)
Debug.SendAnimationEvent(Actra, "sosfasterect")
EndEvent



Event OnKill(string eventName, string killType, float idk, Form killer)
if killType == ""
actra.kill(killer as actor)
elseif killType == "silent"
actra.killSilent(killer as actor)
elseif killType == "essential"
actra.killEssential(killer as actor)
endIf

EndEvent

Event OnOShader(string eventName, string shaderString, float numArgggYeScurvyDogs, Form sender)
String[] stringValues = StringUtil.split(shaderString, ",")
int index = stringvalues[1] as int 
shaderFX[index].stop(actra)
shaderFX[index] = OSO.OShader.GetAt(stringvalues[0] as int) as effectshader
shaderFX[index].play(actra, stringvalues[2] as float)
EndEvent

Event OnLights(string eventName, string zLightType, float numArgggYeScurvyDogs, Form sender)
ActorLight(Actra, zLightType, OSO.OLightSP, OSO.OLightME)
EndEvent


;███████╗███████╗ ██████╗                                                                                                                                             
;██╔════╝██╔════╝██╔════╝                                                                                                                                             
;█████╗  ███████╗██║  ███╗                                                                                                                                            
;██╔══╝  ╚════██║██║   ██║                                                                                                                                            
;███████╗███████║╚██████╔╝                                                                                                                                            
;╚══════╝╚══════╝ ╚═════╝                                                                                                                                             
;███████╗ ██████╗ ██╗   ██╗██╗██████╗     ███████╗██╗      ██████╗ ████████╗     ██████╗ ██████╗  ██████╗ ██╗   ██╗██████╗ ███████╗                                   
;██╔════╝██╔═══██╗██║   ██║██║██╔══██╗    ██╔════╝██║     ██╔═══██╗╚══██╔══╝    ██╔════╝ ██╔══██╗██╔═══██╗██║   ██║██╔══██╗██╔════╝                                   
;█████╗  ██║   ██║██║   ██║██║██████╔╝    ███████╗██║     ██║   ██║   ██║       ██║  ███╗██████╔╝██║   ██║██║   ██║██████╔╝███████╗                                   
;██╔══╝  ██║▄▄ ██║██║   ██║██║██╔═══╝     ╚════██║██║     ██║   ██║   ██║       ██║   ██║██╔══██╗██║   ██║██║   ██║██╔═══╝ ╚════██║                                   
;███████╗╚██████╔╝╚██████╔╝██║██║         ███████║███████╗╚██████╔╝   ██║       ╚██████╔╝██║  ██║╚██████╔╝╚██████╔╝██║     ███████║                                   
;╚══════╝ ╚══▀▀═╝  ╚═════╝ ╚═╝╚═╝         ╚══════╝╚══════╝ ╚═════╝    ╚═╝        ╚═════╝ ╚═╝  ╚═╝ ╚═════╝  ╚═════╝ ╚═╝     ╚══════╝  

;Managing Papyrus stuff for processing actors equipment, dressing and undressing.



;Gets the name and Form of slots 30-60 and then sends them to the UI.
Event OnRequestEQSuite(string eventName, string zNothin, float numArgggYeLanLubers, Form sender)	
SendEQSuite(actra, formID, glyph, codePage)
EndEvent





Event OnWepOFF(string eventName, string zTrueHand, float ArrggYeBeWalkingThaPlank, Form sender)
int zHand
int zExHand
If zTrueHand == 0
zHand = 1
zExHand = 1
Else
zHand = 0
zExHand = 2
EndIf

Form zWep = Actra.GetEquippedObject(zHand)

If !zWep

ElseIf (zWep as Weapon)
	Actra.UnequipItemEx(zWep as Weapon, zExHand, false)	
ElseIf (zWep as Spell)
	Actra.UnequipSpell(zWep as Spell, zHand)	
Else

EndIf
EndEvent

Event OnWepON(string eventName, string zWeaponFormID, float zTrueHand, Form sender)
int zHand
int zExHand
If zTrueHand == 0
zHand = 1
zExHand = 1
Else
zHand = 0
zExHand = 2
EndIf

Form zWep = Game.GetFormEx(zWeaponFormID as int)

If !zWep

ElseIf (zWep as Weapon)
			Actra.EquipItemEx(zWep as weapon, zExHand, false)

ElseIf (zWep as Spell)
			Actra.EquipSpell(ZWep as spell, zHand)
Else

EndIf


EndEvent

;The player might manually equip or unequip items which the UI would be blind to
;To adjust for this the spell uses it's extending Actor ability to register for the
;actor OnObject(Un)Equipped events. These relay information to the UI when it occurs.


Event OnObjectUnequipped(Form Item, ObjectReference ShitIdontNeed)
;oi.os(".OAA"+FormID+".equip.RegEqOFF", (Item as armor).GetSlotMask())
endEvent

Event OnObjectEquipped(Form Item, ObjectReference ShitIdontNeed)
;string[] EqOn = New String[4]
;;armor zItme = Item as Armor 
;EqOn[0]  = formID
;EqOn[1]  = zItem.getFormID()
;EqOn[2]  = zItem.getName()
;EqOn[3]  = (zItem as armor).GetSlotMask()
;oi.oSS(".OAA"+FormID+".equip.RegEqON", EqOn)

;int zSlot = 0
;int foundSlot
;While !foundSlot || zSlot <= 32
;if Item == Actra.GetWornForm(getOSlot(zSlot)) 
;foundSlot = zSlot
;zSlot+=99
;endIf
;zSlot+=1
;EndWhile

;if foundSlot
;debug.messageBox(foundSlot)
;Else
;	debug.messagebox("nothinfound"+zSlot)
;endIf

endEvent

Event OnEqOFF(string eventName, string EqSlot, float ArrggYeBeWalkingThaPlank, Form sender)
actra.UnequipItemSlot(EqSlot as int) 
EndEvent

Event OnEqOffAutoInt(string eventName, string AutoIntCMD, float ArrggYeBeWalkingThaPlank, Form sender)
String[] data = StringUtil.split(AutoIntCMD, ",")


actra.UnequipItemSlot(data[0] as int)
consoleUtil.SetSelectedReference(actra)
data[1] = _oGlobal.IntToHex(Game.GetModByName(data[1]))
consoleUtil.ExecuteCommand("equipitem "+Data[1]+Data[2]+" 1")
EndEvent

Event OnEqOnAutoInt(string eventName, string AutoIntCMD, float ArrggYeBeWalkingThaPlank, Form sender)
String[] data = StringUtil.split(AutoIntCMD, ",")
consoleUtil.SetSelectedReference(actra)
data[1] = _oGlobal.IntToHex(Game.GetModByName(data[1]))
consoleUtil.ExecuteCommand("unequipitem "+Data[1]+Data[2]+" 1")
actra.EquipItemEx(Game.GetFormEx(data[0] as int) as armor, 0, false, false)
EndEvent


Event OnEqON(string eventName, string EquipForm, float ArrrrggMatey, Form sender)	
actra.EquipItemEx(Game.GetFormEx(EquipForm as int) as armor, 0, false, false)
EndEvent




; █████╗ ███╗   ██╗██╗███╗   ███╗ █████╗ ████████╗██╗ ██████╗ ███╗   ██╗    ███████╗██╗   ██╗███████╗███╗   ██╗████████╗                                              
;██╔══██╗████╗  ██║██║████╗ ████║██╔══██╗╚══██╔══╝██║██╔═══██╗████╗  ██║    ██╔════╝██║   ██║██╔════╝████╗  ██║╚══██╔══╝                                              
;███████║██╔██╗ ██║██║██╔████╔██║███████║   ██║   ██║██║   ██║██╔██╗ ██║    █████╗  ██║   ██║█████╗  ██╔██╗ ██║   ██║                                                 
;██╔══██║██║╚██╗██║██║██║╚██╔╝██║██╔══██║   ██║   ██║██║   ██║██║╚██╗██║    ██╔══╝  ╚██╗ ██╔╝██╔══╝  ██║╚██╗██║   ██║                                                 
;██║  ██║██║ ╚████║██║██║ ╚═╝ ██║██║  ██║   ██║   ██║╚██████╔╝██║ ╚████║    ███████╗ ╚████╔╝ ███████╗██║ ╚████║   ██║                                                 
;╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝    ╚══════╝  ╚═══╝  ╚══════╝╚═╝  ╚═══╝   ╚═╝     
;Timed events registered in FNIS for things that need super precision like impact sounds
;The scripts state is used here as I don't want to clog the animation event up with a lot of IF checks
;for the case when Animnation Events are occuring at a rapid pace.



;Phys is for the basic impact sound + facial expression reaction on sex impacts
Event OnAnimationEvent(ObjectReference akSource, string zAE)

		OAE[2] = zAE
		UI.InvokeStringA("HUD Menu", "_root.WidgetContainer."+glyph+".widget.com.skyActraAE", OAE)
							
EndEvent



