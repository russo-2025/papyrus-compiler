ScriptName REQ_Debug_HealthMonitor Extends Actor
{Keeps track of an actor's health}

Bool Property Restore Auto
{Whether to restore attributes after message is displayed}
GlobalVariable Property UpdateInterval Auto
{How often the message is displayed in seconds}
GlobalVariable Property EnableAI Auto
{How often the message is displayed in seconds}
GlobalVariable Property EnableMovement Auto
{How often the message is displayed in seconds}

Float Health


Event OnInit()
	If (!UpdateInterval)
		; Necessary for aps because it doesn't allow properties
		UpdateInterval = Game.GetFormFromFile(0x01211D, "Requiem - Debug.esp") as GlobalVariable
	EndIf
EndEvent


Event OnLoad()
	ResetDummy()
EndEvent


Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, Bool abPowerAttack, Bool abSneakAttack, Bool abBashAttack, Bool abHitBlocked)
	GoToState("Processing")
	Utility.Wait(UpdateInterval.GetValue())
	If (Restore)
		Float DamageTaken = GetBaseActorValue("Health") - GetActorValue("Health")
		Debug.MessageBox(DamageTaken + " taken")
		RestoreActorValue("Health", 99999)
		RestoreActorValue("Stamina", 99999)
		RestoreActorValue("Magicka", 99999)
	Else
		Float DamageTaken = Health - GetActorValue("Health")
		If (DamageTaken > 0)
			Debug.MessageBox(DamageTaken + " taken")
		EndIf
		Health = GetActorValue("Health")
	EndIf
	GoToState("")
EndEvent


State Processing
	Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, Bool abPowerAttack, Bool abSneakAttack, Bool abBashAttack, Bool abHitBlocked)
		; Do nothing
	EndEvent
EndState


Function ResetDummy()
	MoveToMyEditorLocation()
	SetDontMove(!EnableMovement.GetValue())
	EnableAI(EnableAI.GetValue())
	Health = GetActorValue("Health")
EndFunction
