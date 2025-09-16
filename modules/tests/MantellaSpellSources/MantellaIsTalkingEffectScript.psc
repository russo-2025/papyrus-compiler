Scriptname MantellaIsTalkingEffectScript extends ActiveMagicEffect  

Quest Property MantellaConversationQuest Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
    (MantellaConversationQuest as MantellaConversation).SetIsTalking(true)
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
    (MantellaConversationQuest as MantellaConversation).SetIsTalking(false)
EndEvent
