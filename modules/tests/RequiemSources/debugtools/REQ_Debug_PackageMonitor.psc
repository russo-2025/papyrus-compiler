Scriptname REQ_Debug_PackageMonitor Extends Actor Hidden
{Debug script to monitor package stack evaluation on an actor, use the
AttachPapyrusScript console command to attach it to your NPC of interest}

Bool tracingonly = false

Event OnInit()
    Debug.MessageBox("Package Tracker attached to: " + Self)
EndEvent

Function TraceOnly()
    tracingonly = True
EndFunction
    
Event OnPackageStart(Package akNewPackage)
    String msg = "Package Start: " + akNewPackage + " on actor " + Self
    Debug.Trace("[REQ] Trace: " + msg)
    If (!tracingonly)
        Debug.MessageBox(msg)
    EndIf
EndEvent

Event OnPackageChange(Package akOldPackage)
    String msg = "Package Changed Away: " + akOldPackage + " on actor " + Self
    Debug.Trace("[REQ] Trace: " + msg)
    If (!tracingonly)
        Debug.MessageBox(msg)
    EndIf
EndEvent

Event OnPackageEnd(Package akOldPackage)
    String msg = "Package Finished: " + akOldPackage + " on actor " + Self
    Debug.Trace("[REQ] Trace: " + msg)
    If (!tracingonly)
        Debug.MessageBox(msg)
    EndIf
EndEvent