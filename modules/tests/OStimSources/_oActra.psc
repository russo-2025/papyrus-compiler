ScriptName _oActra Extends ActiveMagicEffect


;  ██████╗ ███████╗ █████╗      █████╗  ██████╗████████╗██████╗  █████╗
; ██╔═══██╗██╔════╝██╔══██╗    ██╔══██╗██╔════╝╚══██╔══╝██╔══██╗██╔══██╗
; ██║   ██║███████╗███████║    ███████║██║        ██║   ██████╔╝███████║
; ██║   ██║╚════██║██╔══██║    ██╔══██║██║        ██║   ██╔══██╗██╔══██║
; ╚██████╔╝███████║██║  ██║    ██║  ██║╚██████╗   ██║   ██║  ██║██║  ██║
;  ╚═════╝ ╚══════╝╚═╝  ╚═╝    ╚═╝  ╚═╝ ╚═════╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝
; █████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗
; ╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝
; OSA empowered spell effect with all needed scene functionality.


Actor Property PlayerRef Auto

;Add the _oOmni persistent script based in quest 0SA
_oOmni Property OSO Hidden
    _oOmni Function get()
        Return Quest.GetQuest("0SA") as _oOmni
    EndFunction
EndProperty

Actor Actra
Int Glyph
Int StageID
String FormID

Formlist[] OFormSuite
EffectShader[] ShaderFX

Int ThrottleMFG = 3
Float ThrottleScale = 0.2
String[] OAE
String CodePage

ObjectReference PosObj

Bool FirstScale = True

Event OnEffectStart (Actor TarAct, Actor Spot)
	Aligned = False

	Actra = TarAct
	FormID = _oGlobal.GetFormID_S(OSANative.GetLeveledActorBase(Actra))
	Glyph = OSO.Glyph
	StageID = Actra.GetFactionRank(OSO.OFaction[1])
	RegisterEvents()
	RegisterAnimationEvents()
	CodePage = OSO.CodePage
	ShaderFX = new EffectShader[10]
	OFormSuite = new Formlist[100]
	OAE = new String[3]
	OAE[0] = FormID
	OAE[1] = StageID
	PosObj = OSO.GlobalPosition[StageID as Int]

	_oGlobal.SheathWep(Actra, PlayerRef)
	_oGlobal.ActorLock(Actra, PlayerRef)
	_oGlobal.ActraReveal(Actra, FormID, StageID)

	Actra.SetAnimationVariableBool("bHumanoidFootIKDisable", True)

	If (Actra == PlayerRef)
		UI.SetBool("HUD Menu", "_root.HUDMovieBaseInstance._visible", False)
	EndIf

	Debug.SendAnimationEvent(Actra, "sosfasterect")
EndEvent

Function RegisterAnimationEvents()
	RegisterForAnimationEvent(Actra, "0S0")
EndFunction

Function RegisterEvents()
	RegisterForModEvent("0SA" + "_GameLoaded", "OnGameLoaded")

	RegisterForModEvent("0SAA" + FormID + "_ActraEnd", "OnActraEnd")
	RegisterForModEvent("0SAA" + FormID + "_NoFuse", "OnNoFuse")
	RegisterForModEvent("0SAA" + FormID + "_ChangeStage", "OnChangeStage")
	RegisterForModEvent("0SAA" + FormID + "_CenterActro", "OnCenterActro")
	RegisterForModEvent("0SAA" + FormID + "_FormBind", "OnFormBind")

	RegisterForModEvent("0SAA" + FormID + "_Animate", "OnAnimate")
	RegisterForModEvent("0SAA" + FormID + "_AlignStage", "OnAlignStage")
	RegisterForModEvent("0SAA" + FormID + "_AllowAlignStage", "ResetAlignStage")
	
	RegisterForModEvent("0SAA" + FormID + "_BlendSc", "OnBlendSc")
	RegisterForModEvent("0SAA" + FormID + "_SnapSc", "OnSnapSc")
	;RegisterForModEvent("0SAA" + FormID + "_BodyScale", "OnBodyScale")

	
	RegisterForModEvent("0SAA" + FormID + "_OShader", "OnOShader")
	RegisterForModEvent("0SAA" + FormID + "_Lights", "OnLights")
	RegisterForModEvent("0SAA" + FormID + "_Kill", "OnKill")
	; ESG Related
	RegisterForModEvent("0SAA" + FormID + "_RequestEQSuite", "OnRequestEQSuite")
	RegisterForModEvent("0SAA" + FormID + "_EqON", "OnEqON")
	RegisterForModEvent("0SAA" + FormID + "_EqOnAutoInt", "OnEqOnAutoInt")
	RegisterForModEvent("0SAA" + FormID + "_EqOFF", "OnEqOFF")
	RegisterForModEvent("0SAA" + FormID + "_EqOffAutoInt", "OnEqOffAutoInt")
	RegisterForModEvent("0SAA" + FormID + "_WepOFF", "OnWepOFF")
	RegisterForModEvent("0SAA" + FormID + "_WepON", "OnWepON")

	osexintegrationmain ostim = outils.getostim()
	if !ostim.animationrunning() || !ostim.isactorinvolved(actra)
		; subthread events
		RegisterForModEvent("0SAA" + FormID + "_BlendMo", "OnBlendMo")
		RegisterForModEvent("0SAA" + FormID + "_BlendPh", "OnBlendPh")
		RegisterForModEvent("0SAA" + FormID + "_BlendEx", "OnBlendEx")
		RegisterForModEvent("0SSO" + FormID + "_Sound", "OnSound")
	endif 
EndFunction

Event OnGameLoaded(String EventName, String zAnimation, Float NumArg, Form Sender)
	LoadEnd = True
	Self.Dispel()
EndEvent

Event OnEffectFinish(Actor Target, Actor Caster)
	CompleteEnd()
EndEvent

Event OnCenterActro(String EventName, String NewStageID, Float NumArg, Form Sender)
	Actra.SetFactionRank(OSO.OFaction[1], NewStageID as Int)
	StageID = NewStageID as Int
	RegisterForModEvent("0S0" + StageID + "_StageReady", "OnStageReady")
	OSO.OSpell[1].cast(Actra, Actra)
EndEvent

Event OnHit(ObjectReference Aggressor, Form Source, Projectile Projectile, bool PowerAttack, bool SneakAttack, bool BashAttack, bool HitBlocked)
	SendModEvent("ostim_actorhit")
EndEvent

Event OnChangeStage(String EventName, String NewStageID, Float NumArg, Form Sender)
	Actra.SetFactionRank(OSO.OFaction[1], NewStageID as Int)
	StageID = NewStageID as Int
	RegisterForModEvent("0S0" + StageID + "_StageReady", "OnStageReady")
EndEvent

Event OnStageReady()
	_oGlobal.ActraReveal(Actra, FormID, StageID)
	UnRegisterForModEvent("0S0" + StageID + "_StageReady")
EndEvent

Event OnActraEnd(String EventName, String zAnimation, Float NumArg, Form Sender)
	If (Actra == PlayerRef)
		UI.SetBool("HUD Menu", "_root.HUDMovieBaseInstance._visible", True)
	EndIf
	Self.Dispel()
EndEvent

Bool LoadEnd = False
Function CompleteEnd()
	If (Actra != None) ; Shield is in place so I'm not sure how a none Actor can get by.
	;	If (Actra.Is3DLoaded()) ; NEW SHIELD START IF 3D, ISN"T LOADED DO NOTHING
	; Sairion: going to ignore the above.... skipping the below code makes actors get stuck so...
	; hopefully whatever reason was had for skipping this wasn't important!
			_oGlobal.ActorLight(Actra, "Remove", OSO.OLightSP, OSO.OLightME)
			Debug.SendAnimationEvent(Actra, "SOSFlaccid")
			_oGlobal.FactionClean(Actra, OSO.OFaction)
			MfgConsoleFunc.ResetPhonemeModifier(Actra)
			_oGlobal.PackageClean(Actra, OSO.OPackage)
			Actra.ClearExpressionOverride()
			Actra.SetAnimationVariableBool("bHumanoidFootIKDisable", False)
			If (LoadEnd)
				_oGlobal.ActorUnlock(Actra, PlayerRef)
			Else
				ObjectReference LastPoint = Actra.PlaceAtMe(OSO.OBlankStatic)
				LastPoint.MoveToNode(Actra, "NPC COM [COM ]")
				_oGlobal.ActorSmoothUnlock(Actra, PlayerRef, LastPoint.X, LastPoint.Y)
				LastPoint.Delete()
				LastPoint = None
			EndIf
	;	EndIf ; NEW SHIELD END
	EndIf ; Conclude Shield
EndFunction

Event OnLoad()
	CompleteEnd() ; When 3D does load try it again
EndEvent

;If a module doesn't want the actors stacked and rooted on a specific spot this Function unfuses them.
;Mainly used for 1 Actor scenes where positioning isn't as important or to convert a 2+ Actor scene
;into a few 1 Actor scenes and have the actors disperse themselves.

Event OnNoFuse(String EventName, String Huh, Float NumArg, Form Sender)
	Actra.StopTranslation()
	Actra.SetVehicle(None)
EndEvent

Bool Property Aligned Auto

Event AllowAlignStage()
	Aligned = False
EndEvent

Event OnAlignStage()
	If (Aligned)
		Return
	EndIf

	Actra.StopTranslation()

	; This is the section I'd like to be able to remove and have the TranslateTo handle the rotations
	; You can see when it does the hard setSangle that the camera gets unsmoothly set to the new location
	; and that the game sound gets cut and restarted. Not an ideal transtion

	If (Math.Abs(Actra.GetAngleZ() - PosObj.getAngleZ()) > 0.5)
		Actra.SetAngle(0, 0, PosObj.getAngleZ())
	EndIf

	;The below translateTo does not seem to rotate the player, only setting their position x,y,z
	;The postObj.getAngleZ() only seems to rotate NPCs however If this could somehow effect the player it would
	;make this whole thing much bette / smoother

	Actra.TranslateTo(PosObj.x, PosObj.y, PosObj.z, 0, 0, PosObj.getAngleZ(), 150.0, 0)
	Actra.SetVehicle(PosObj)
	SendModEvent("ostim_setvehicle")
	Aligned = True
EndEvent

Event OnTranslationComplete()
EndEvent

;Phoneme, Modifier, and Node Scale Blends

;For Softly Blending Modifiers to a new alignment
Event OnBlendMo(String EventName, String zType, Float zAmount, Form Sender)
	Int zTy = zType as Int
	_oGlobal.BlendMo(Actra, zAmount as Int, MfgConsoleFunc.GetModifier(Actra, zTy), zTy, ThrottleMFG)
EndEvent

;For Softly Blending Phonemes to a new alignment
Event OnBlendPh(String EventName, String zType, Float zAmount, Form Sender)
	Int zTy = zType as Int
	_oGlobal.BlendPh(Actra, zAmount as Int, MfgConsoleFunc.GetPhoneme(Actra, zTy), zTy, ThrottleMFG)

	;osexintegrationmain ostim = game.GetFormFromFile(0x000801, "Ostim.esp") as OsexIntegrationMain
	;osexintegrationmain.console("Type: " + zType + " Amount: " + zAmount + " Anim: " + ostim.getcurrentanimation())
EndEvent

;For Receiving Expressions
Event OnBlendEx(String EventName, String zType, Float zAmount, Form Sender)
	Actra.SetExpressionOverride(zType as Int, zAmount as Int)
EndEvent

;For Blending NodeScale softly to a new scale
Event OnBlendSc(String EventName, String zType, Float zAmount, Form Sender)
	If (zAmount)
		outils.console("Node: " + zType + " Amount: " + zAmount)
		If (NetImmerse.HasNode(Actra, zType, False))
			_oGlobal.BlendSc(Actra, zAmount, NetImmerse.GetNodeScale(Actra, zType, False), zType, ThrottleScale)
		EndIf
	EndIf
EndEvent

;For instantly setting scale back in place at times when
;dramatic effect aren't needed
Event OnSnapSc(String EventName, String zType, Float zAmount, Form Sender)
	outils.console("Node: " + zType + " Amount: " + zAmount)
	NetImmerse.SetNodeScale(Actra, zType, zAmount, False)
EndEvent

Event OnBodyScale(String EventName, String zType, Float zAmount, Form Sender)
	Actra.setScale(zAmount)
	;If (FirstScale)
		;FirstScale = False
		Utility.Wait(2.0)
		Actra.SetScale(zAmount)
	;EndIf
EndEvent

Event OnFormBind(String EventName, String zMod, Float IxID, Form Sender)
	Int Ix = StringUtil.Substring(IxID, 0, 2) as Int
	Int Fo = StringUtil.Substring(IxID, 2) as Int
	OFormSuite[Ix] = Game.GetFormFromFile(Fo, zMod) as FormList
EndEvent

Event OnSound(String EventName, String Fi, Float Ix, Form Sender)
	Int S = (OFormSuite[Ix as Int].GetAt(Fi as Int) as Sound).Play(Actra)
	Sound.SetInstanceVolume(S, 1.0)
EndEvent

Event OnAnimate(String EventName, String zAnimation, Float NumArg, Form Sender)
	Debug.SendAnimationEvent(Actra, zAnimation)
	;Debug.SendAnimationEvent(Actra, "sosfasterect")

	;OsexIntegrationMain.console("Animation for " + actra.getdisplayname() + ": " + zAnimation + " (stage id " + StageID + ")")

EndEvent

Event OnKill(String EventName, String KillType, Float IDK, Form Killer)
	If (KillType == "")
		Actra.Kill(Killer as Actor)
	elseif (KillType == "silent")
		Actra.KillSilent(Killer as Actor)
	elseif (KillType == "essential")
		Actra.KillEssential(Killer as Actor)
	EndIf
EndEvent

Event OnOShader(String EventName, String ShaderString, Float NumArgggYeScurvyDogs, Form Sender)
	String[] StringValues = StringUtil.Split(ShaderString, ",")
	Int i = StringValues[1] as Int
	ShaderFX[i].Stop(Actra)
	ShaderFX[i] = OSO.OShader.GetAt(StringValues[0] as Int) as EffectShader
	ShaderFX[i].Play(Actra, StringValues[2] as Float)
EndEvent

Event OnLights(String EventName, String zLightType, Float NumArgggYeScurvyDogs, Form Sender)
	_oGlobal.ActorLight(Actra, zLightType, OSO.OLightSP, OSO.OLightME)
EndEvent


; ███████╗███████╗ ██████╗
; ██╔════╝██╔════╝██╔════╝
; █████╗  ███████╗██║  ███╗
; ██╔══╝  ╚════██║██║   ██║
; ███████╗███████║╚██████╔╝
; ╚══════╝╚══════╝ ╚═════╝
; ███████╗ ██████╗ ██╗   ██╗██╗██████╗     ███████╗██╗      ██████╗ ████████╗     ██████╗ ██████╗  ██████╗ ██╗   ██╗██████╗ ███████╗
; ██╔════╝██╔═══██╗██║   ██║██║██╔══██╗    ██╔════╝██║     ██╔═══██╗╚══██╔══╝    ██╔════╝ ██╔══██╗██╔═══██╗██║   ██║██╔══██╗██╔════╝
; █████╗  ██║   ██║██║   ██║██║██████╔╝    ███████╗██║     ██║   ██║   ██║       ██║  ███╗██████╔╝██║   ██║██║   ██║██████╔╝███████╗
; ██╔══╝  ██║▄▄ ██║██║   ██║██║██╔═══╝     ╚════██║██║     ██║   ██║   ██║       ██║   ██║██╔══██╗██║   ██║██║   ██║██╔═══╝ ╚════██║
; ███████╗╚██████╔╝╚██████╔╝██║██║         ███████║███████╗╚██████╔╝   ██║       ╚██████╔╝██║  ██║╚██████╔╝╚██████╔╝██║     ███████║
; ╚══════╝ ╚══▀▀═╝  ╚═════╝ ╚═╝╚═╝         ╚══════╝╚══════╝ ╚═════╝    ╚═╝        ╚═════╝ ╚═╝  ╚═╝ ╚═════╝  ╚═════╝ ╚═╝     ╚══════╝
; Managing Papyrus stuff for processing actors equipment, dressing and undressing.


;Gets the name and Form of slots 30-60 and then sends them to the UI.
Event OnRequestEQSuite(String EventName, String zNothin, Float NumArgggYeLanLubers, Form Sender)
	_oGlobal.SendEQSuite(Actra, FormID, Glyph, CodePage)
EndEvent

Event OnWepOFF(String EventName, String zTrueHand, Float ArrggYeBeWalkingThaPlank, Form Sender)
	Int zHand = 0
	Int zExHand = 2
	If (zTrueHand == 0)
		zHand = 1
		zExHand = 1
	EndIf

	Form zWep = Actra.GetEquippedObject(zHand)
	If (zWep)
		If (zWep as Weapon)
			Actra.UnequipItemEx(zWep as Weapon, zExHand, False)
		ElseIf (zWep as Spell)
			Actra.UnequipSpell(zWep as Spell, zHand)
		EndIf
	EndIf
EndEvent

Event OnWepON(String EventName, String zWeaponFormID, Float zTrueHand, Form Sender)
	Int zHand = 0
	Int zExHand = 2
	If (zTrueHand == 0)
		zHand = 1
		zExHand = 1
	EndIf

	Form zWep = Game.GetFormEx(zWeaponFormID as Int)
	If (zWep)
		If (zWep as Weapon)
			Actra.EquipItemEx(zWep as weapon, zExHand, False)
		ElseIf (zWep as Spell)
			Actra.EquipSpell(ZWep as spell, zHand)
		EndIf
	EndIf
EndEvent

;The player might manually equip or unequip items which the UI would be blind to
;To adjust for this the spell uses it's extending Actor ability to register for the
;Actor OnObject(Un)Equipped events. These relay information to the UI when it occurs.

Event OnObjectUnequipped(Form Item, ObjectReference ShitIdontNeed)
	;OI.OS(".OAA" + FormID + ".equip.RegEqOFF", (Item as armor).GetSlotMask())
EndEvent

Event OnObjectEquipped(Form Item, ObjectReference ShitIdontNeed)
	;String[] EqOn = New String[4]
	;Armor zItem = Item as Armor
	;EqOn[0]  = FormID
	;EqOn[1]  = zItem.GetFormID()
	;EqOn[2]  = zItem.GetName()
	;EqOn[3]  = (zItem as Armor).GetSlotMask()
	;OI.OSS(".OAA" + FormID + ".equip.RegEqON", EqOn)

	;Int zSlot = 0
	;Int FoundSlot
	;While (!foundSlot || zSlot <= 32)
		;If (Item == Actra.GetWornForm(GetOSlot(zSlot)))
			;foundSlot = zSlot
			;zSlot += 99
		;EndIf
		;zSlot += 1
	;EndWhile

	;If (FoundSlot)
		;Debug.MessageBox(FoundSlot)
	;Else
		;Debug.MessageBox("nothinfound" + zSlot)
	;EndIf
EndEvent

Event OnEqOFF(String EventName, String EqSlot, Float ArrggYeBeWalkingThaPlank, Form Sender)
	Actra.UnequipItemSlot(EqSlot as Int)
EndEvent

Event OnEqOffAutoInt(String EventName, String AutoIntCMD, Float ArrggYeBeWalkingThaPlank, Form Sender)
	String[] Data = StringUtil.Split(AutoIntCMD, ",")
	Actra.UnequipItemSlot(Data[0] as Int)
	ConsoleUtil.SetSelectedReference(Actra)
	Data[1] = _oGlobal.IntToHex(Game.GetModByName(Data[1]))
	ConsoleUtil.ExecuteCommand("equipitem " + Data[1] + Data[2] + " 1")
EndEvent

Event OnEqOnAutoInt(String EventName, String AutoIntCMD, Float ArrggYeBeWalkingThaPlank, Form Sender)
	String[] Data = StringUtil.Split(AutoIntCMD, ",")
	consoleUtil.SetSelectedReference(Actra)
	Data[1] = _oGlobal.IntToHex(Game.GetModByName(Data[1]))
	ConsoleUtil.ExecuteCommand("unequipitem " + Data[1] + Data[2] + " 1")
	Actra.EquipItemEx(Game.GetFormEx(data[0] as Int) as Armor, 0, False, False)
EndEvent

Event OnEqON(String EventName, String EquipForm, Float ArrrrggMatey, Form Sender)
	Actra.EquipItemEx(Game.GetFormEx(EquipForm as Int) as Armor, 0, False, False)
EndEvent


;  █████╗ ███╗   ██╗██╗███╗   ███╗ █████╗ ████████╗██╗ ██████╗ ███╗   ██╗    ███████╗██╗   ██╗███████╗███╗   ██╗████████╗
; ██╔══██╗████╗  ██║██║████╗ ████║██╔══██╗╚══██╔══╝██║██╔═══██╗████╗  ██║    ██╔════╝██║   ██║██╔════╝████╗  ██║╚══██╔══╝
; ███████║██╔██╗ ██║██║██╔████╔██║███████║   ██║   ██║██║   ██║██╔██╗ ██║    █████╗  ██║   ██║█████╗  ██╔██╗ ██║   ██║
; ██╔══██║██║╚██╗██║██║██║╚██╔╝██║██╔══██║   ██║   ██║██║   ██║██║╚██╗██║    ██╔══╝  ╚██╗ ██╔╝██╔══╝  ██║╚██╗██║   ██║
; ██║  ██║██║ ╚████║██║██║ ╚═╝ ██║██║  ██║   ██║   ██║╚██████╔╝██║ ╚████║    ███████╗ ╚████╔╝ ███████╗██║ ╚████║   ██║
; ╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝    ╚══════╝  ╚═══╝  ╚══════╝╚═╝  ╚═══╝   ╚═╝
; Timed events registered in FNIS for things that need super precision like impact sounds
; The scripts state is used here as I don't want to clog the animation Event up with a lot of IF checks
; for the case when Animnation Events are occuring at a rapid pace.


; Phys is for the basic impact sound + facial expression reaction on sex impacts
Event OnAnimationEvent(ObjectReference Source, String zAE)
	OAE[2] = zAE
	UI.InvokeStringA("HUD Menu", "_root.WidgetContainer." + Glyph + ".widget.com.skyActraAE", OAE)
EndEvent
