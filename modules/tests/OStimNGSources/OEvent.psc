;/* OEvent
* * collection of native functions related to events
* *
* * required API version: 7.3 (0x07030000)
*/;
ScriptName OEvent

;/* IsChildOf
* * checks if the event is a child of the other event
* *
* * @param: SuperType, the parent event
* * @param: SubType, the child event
* *
* * @return: true if the subtype is a child of the supertype, otherwise false
*/;
bool Function IsChildOf(string SuperType, string SubType) Global Native