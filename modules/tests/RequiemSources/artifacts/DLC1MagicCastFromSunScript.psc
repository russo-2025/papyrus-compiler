Scriptname DLC1MagicCastFromSunScript extends ActiveMagicEffect  
{This is just a test to find the sun.}

Import Game
Import Utility
Import Weather

Float Property fHeightFudge = 80.0 Auto
								{Fudge the height because the camera is not the same as the player.}
Float Property fSunVectorScale = 18.0 Auto
								{We need to scale the vector considerably to account for the sun actually being much closer to us then it looks.}
Float Property fBeamDurationDelay = 1.0 Auto
								{How long do we have to keep the xMarker to prevent the beams from moving to the world origin?}
Float Property fWaitDelay = 1.1 Auto
								{This is the delay for the begining to the spell, to give the arrow time to hit the sun.}
Static Property PlacedXMarker auto
								{This is the marker the spell is cast from. Use the XMarker please}
Float Property fExplosionVectorScale = 7.0 Auto
								{This scale is for the explosion ref position, to keep it in draw range.}
Spell property SpellRef auto
								{The name of the Spell the Sky will cast. (REQUIRED!)}
Activator Property ActivatorRef Auto
								{This is the art that will be used for the sun burst visual effect}
Explosion Property ExplosionRef Auto
								{This is an invisible explosion used to deliver Imod and Sound effects from the correct location.}
Float Property fActivatorDeleteDelay = 15.0 Auto
								{This delay holds the effect art in the sky so that it can animate to completion.}
Weather property WeatherForm auto
								{The name of the Weather we will seeing instantly, if we have one.}
bool Property bHoldWeatherUntilEnd = False auto
								{Check this if you want the new weather to stay active until the spell wears off}
Bool Property bUseLocalNiceWeather = False auto
								{Instead of defining a weather here, should we use a local clear weather?}
Float Property fXYBaseRandom = 1024.0 Auto
								{This is the random offset from the player that random shots will fire at.}
Float Property fRecast = 1.0 auto
								{How long before we recast the spell?  (Default = 1.0)}
Float Property fRecastRand = 0.0 auto
								{Add Some random time to the recast! (Default = 0.0)}
;globalVariable Property GameHour auto

MusicType property myMusic auto
								{this music gets played when the eclipse explosion happens}
MagicEffect Property PlayerEffect Auto
{As long as the player has this effect, continue shooting beams}
Spell Property SunAttackNPC Auto
{This is the spell that marks NPCs for shooting with beams}

float fSunYPosition = 40.0
;float fStartTime = 0.0
Bool bContinueRunning = True

Bool bFunctionRunningSunSpell
Bool bFunctionRunningExplosion

Actor Player
Actor CasterActor
Actor TargetActor
ObjectReference MyActivator = None
; int iWeatherCheck
weather CurrentWeatherForm

Event OnInit()
	Player = GetPlayer()
	fRecastRand = fRecastRand + fRecast
EndEvent


Event OnEffectStart(Actor Target, Actor Caster)
	
	; Since the y position of the sun appears to be fixed, lets only get it once instead of on update.
	fSunYPosition = GetSunPositionY()
	
	CasterActor = Caster
	TargetActor = Target
	
	Utility.Wait(fWaitDelay)

	if bContinueRunning
		if TargetActor == Player
			if bUseLocalNiceWeather
				CurrentWeatherForm = GetCurrentWeather()
				If CurrentWeatherForm.GetClassification() == 0
					WeatherForm = None
				EndIf 
			EndIf

			ReleaseOverride() ;UDGP 2.0.3 - Moved this call out here from inside the below because the Clear Skies shout sets unremovable clear weather.
			if WeatherForm
				;Debug.Trace("The Nice Weather is called: " + WeatherForm)
				Utility.Wait(0.25)
				WeatherForm.SetActive(bHoldWeatherUntilEnd,True)
			EndIf
		
			PlaceExplosionAndRotate()
		EndIf

		if SpellRef
			RegisterForSingleUpdate(RandomFloat(fRecast, fRecastRand))
		EndIf
	EndIf
EndEvent


Event OnUpdate()
	If bContinueRunning
		If TargetActor == Player
			; We're attached to the player
			SunAttackNPC.Cast(Player, Player)  ; Cast area spell to update all targets
			RegisterForSingleUpdate(RandomFloat(fRecast, fRecastRand))
			CastSpellFromSun(True)
		ElseIf Player.HasMagicEffect(PlayerEffect)
			; We're attached to an enemy and the main effect is still running
			RegisterForSingleUpdate(RandomFloat(fRecast, fRecastRand))
			CastSpellFromSun(False)
		Else
			; We're attached to an enemy and the main effect has ended
			Dispel()
		EndIf
	EndIf
EndEvent

Event OnUpdateGameTime()
;Get rid of the visual start effect if the player waits or fast travels.
	;Debug.Trace(self + " We have hit the update time")
	If MyActivator
		;Debug.Trace(self + " ..and we have an activator named: " + MyActivator)
		;Utility.Wait(fActivatorDeleteDelay)
		MyActivator.disable()
		MyActivator.delete()
		MyActivator = none
	endif
EndEvent

Event OnEffectFinish(Actor Target, Actor Caster)
	bContinueRunning = False

	;We need to wait until the functions finish so we can be sure to clean things up.
	while (bFunctionRunningSunSpell)
		Utility.Wait(0.1) ; Added by UDGP 1.2.2 to slightly delay things so the spell has a chance to catch up.
	endwhile
	while (bFunctionRunningExplosion)
		Utility.Wait(0.1) ; Added by UDGP 1.2.2 to slightly delay things so the spell has a chance to catch up.
	endwhile

	if WeatherForm
		if bHoldWeatherUntilEnd == True
			ReleaseOverride()
		endif
	EndIf

	If MyActivator
		MyActivator.disable()
		MyActivator.delete()
		MyActivator = none
	endif

EndEvent

;;;;

Function CastSpellFromSun(Bool bWeWantToMiss)
	bFunctionRunningSunSpell = true

	ObjectReference SpellCastXMarkerRef = CasterActor.placeAtMe(PlacedXMarker)
	ObjectReference TargetMarkerRef = CasterActor.placeAtMe(PlacedXMarker)
	
	Float PosX = TargetMarkerRef.GetPositionX() + RandomFloat(-fXYBaseRandom,fXYBaseRandom)
	Float PosY = TargetMarkerRef.GetPositionY() + RandomFloat(-fXYBaseRandom,fXYBaseRandom)
	; Float PosZ = TargetMarkerRef.GetPositionZ()
	
	float[] position = FindSunArtLocation(fSunVectorScale)
	
	SpellCastXMarkerRef.SetPosition(position[0], position[1], position[2])
	
	If SpellCastXMarkerRef.GetParentCell()
		if bWeWantToMiss
			TargetMarkerRef.SetPosition(PosX, PosY, (TargetMarkerRef.GetPositionZ()))
			SpellRef.RemoteCast(SpellCastXMarkerRef,CasterActor,TargetMarkerRef)
		Else
			SpellRef.RemoteCast(SpellCastXMarkerRef,CasterActor,TargetActor)
		EndIf
	EndIf
	
	Utility.Wait(fBeamDurationDelay)
	TargetMarkerRef.disable()
	TargetMarkerRef.delete()
	SpellCastXMarkerRef.disable()
	SpellCastXMarkerRef.delete()

	bFunctionRunningSunSpell = False
EndFunction

Function PlaceExplosionAndRotate()
	bFunctionRunningExplosion = True

; First we create an xMarker in the correct position, with use of the explosion vector scale.
	ObjectReference XMarkerRef = CasterActor.placeAtMe(PlacedXMarker)
	float[] position = FindSunArtLocation(fExplosionVectorScale)
	XMarkerRef.SetPosition(position[0], position[1], position[2])
	
; Then we rotate the xMarker to aim at the target.
	Float fSideX = GetSunPositionX()
	Float fSideY = fSunYPosition 
	Float fSideZ = GetSunPositionZ()
	
; Handle the values that are close to zero.
	If fSideZ < 0.25
		fSideZ = 0.25
	EndIf
	; If fSideX < 0.25
	; 	If fSideX > -0.25
	; 		If fSideX >= 0.0
	; 			fSideX = 0.25
	; 		else
	; 			fSideX = -0.25
	; 		EndIf
	; 	EndIf
	; EndIf
		
	Float fXRotationAngle = math.atan(fSideY/fSideZ)
	Float fYRotationAngle = math.atan(fSideX/fSideZ)
	
	;Debug.Trace("BASE X rotation angle is: " + fXRotationAngle + " and the Y is: " + fYRotationAngle)
	
	; fXRotationAngle = (-fXRotationAngle)
	fYRotationAngle = (-fYRotationAngle)

	
	; Handle the values that are negative.
	if fXRotationAngle < 0.0
		fXRotationAngle = (fXRotationAngle + 360)
	endif
	
	if fYRotationAngle < 0.0
		fYRotationAngle = (fYRotationAngle + 360)
	endif
	
	XMarkerRef.SetAngle(fXRotationAngle, fYRotationAngle, 0.0)
	XMarkerRef.placeatme(ExplosionRef)
	MyActivator = XMarkerRef.placeatme(ActivatorRef)
	MyActivator.EnableNoWait(0)
	if myMusic
		myMusic.Add() ;eclipse music added when explosion occurs
	endif
	;Debug.Trace(self + " Now Registering for gametime update.")
	RegisterForSingleUpdateGameTime(0.85)
	
	;Debug.Trace("The X rotation angle is: " + fXRotationAngle + " and the Y is: " + fYRotationAngle)

	Utility.Wait(0.25)
	XMarkerRef.disable()
	XMarkerRef.delete()

	bFunctionRunningExplosion = False
EndFunction

; we need to get a good approximation of the sun's visual position by scaling the vector through the actual position. 
float[] Function FindSunArtLocation(float fVscale = 1.0)
	float[] position = new float[3]  ; 0 = X, 1 = Y, 2 = Z
	position[0] = GetSunPositionX() * fVscale + Player.GetPositionX()
	position[1] = fSunYPosition * fVscale + Player.GetPositionY()
	position[2] = GetSunPositionZ() * fVscale + Player.GetPositionZ() + fHeightFudge
	
	Return position
EndFunction



; Int Function FindNiceWeather()
	; int iWeatherIndex = 0
	; Int iCounter = 0
	; While iCounter < 5
		; if weather.FindWeather(iCounter) == False
			; iCounter + (iCounter + 1)
		; Else
			; iWeatherIndex = iCounter
			; iCounter = 6
		; endif
	; EndWhile
	; Debug.Trace("The Nice Weather index is: " + iWeatherIndex)
	; Return iWeatherIndex
; EndFunction
