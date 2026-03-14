Scriptname REQ_Debug_HitTracker Extends ObjectReference
{monitoring script to report all OnHit events triggered on a reference}

Bool traceOnly = False

Function TraceOnly()
    traceOnly = True
EndFunction

Event OnInit()
    Debug.MessageBox("Hit Tracker attached to:" + self)
EndEvent

Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, \
  bool abBashAttack, bool abHitBlocked)
    String notification = "I was hit!\nagressor:" + akAggressor + "\nsource: " \
            + akSource + "\nprojectile: " + akProjectile + "\nPower Attack: " \
            + abPowerAttack + "\nSneak Attack: " + abSneakAttack \
            + "\nBash Attack: " + abBashAttack + "\nBlocked: " + abHitBlocked
    Debug.Trace(notification)
    If (!traceOnly)
        Debug.MessageBox(notification)
    EndIf
EndEvent