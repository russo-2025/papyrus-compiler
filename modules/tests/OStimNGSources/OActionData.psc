;/* OActionMetadata
* * collection of native functions relating to action metadata
* *
* * there are sadly a few things with similar names here because I didn't think properly about it when I first created it :c (sorry)
* * so when it comes to the term "actor" there are two things it can mean depending on context
* * 1) a Skyrim actor (as in the reference to the PC or an NPC), this is not used in this script at all
* * 2) an action actor, this refers to the actor property of a record of the "actions" list in the scene file (which is just an int)
* * I tried to always use either the term "Skyrim actor" or "action actor" to make it clear which one a specific function is referring to
* *
* * requred API version: 7.3.5
*/;
ScriptName OActionData

;  ██████╗ ██████╗ ███╗   ██╗██████╗ ██╗████████╗██╗ ██████╗ ███╗   ██╗███████╗
; ██╔════╝██╔═══██╗████╗  ██║██╔══██╗██║╚══██╔══╝██║██╔═══██╗████╗  ██║██╔════╝
; ██║     ██║   ██║██╔██╗ ██║██║  ██║██║   ██║   ██║██║   ██║██╔██╗ ██║███████╗
; ██║     ██║   ██║██║╚██╗██║██║  ██║██║   ██║   ██║██║   ██║██║╚██╗██║╚════██║
; ╚██████╗╚██████╔╝██║ ╚████║██████╔╝██║   ██║   ██║╚██████╔╝██║ ╚████║███████║
;  ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝╚═════╝ ╚═╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝

;/* FulfillsActorConditions
* * checks if a Skyrim actor fulfills the conditions of the action actor
* *
* * @param: ActionType, the action to check conditions on
* * @param: Act, the Skyrim actor to check conditions for
* *
* * @return: true if the Skyrim actor fulfills the conditions, otherwise false
*/;
bool Function FulfillsActorConditions(string ActionType, Actor Act) Global Native

;/* FulfillsTargetConditions
* * checks if a Skyrim actor fulfills the conditions of the action target
* *
* * @param: ActionType, the action to check conditions on
* * @param: Act, the Skyrim actor to check conditions for
* *
* * @return: true if the Skyrim actor fulfills the conditions, otherwise false
*/;
bool Function FulfillsTargetConditions(string ActionType, Actor Act) Global Native

;/* FulfillsPerformerConditions
* * checks if a Skyrim actor fulfills the conditions of the action performer
* *
* * @param: ActionType, the action to check conditions on
* * @param: Act, the Skyrim actor to check conditions for
* *
* * @return: true if the Skyrim actor fulfills the conditions, otherwise false
*/;
bool Function FulfillsPerformerConditions(string ActionType, Actor Act) Global Native