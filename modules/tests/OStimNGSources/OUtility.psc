;/* OUtility
* * collection of general utility functions
* *
* * required API version: 7.3.5
*/;
ScriptName OUtility

; ███████╗████████╗██████╗ ██╗███╗   ██╗ ██████╗ ███████╗
; ██╔════╝╚══██╔══╝██╔══██╗██║████╗  ██║██╔════╝ ██╔════╝
; ███████╗   ██║   ██████╔╝██║██╔██╗ ██║██║  ███╗███████╗
; ╚════██║   ██║   ██╔══██╗██║██║╚██╗██║██║   ██║╚════██║
; ███████║   ██║   ██║  ██║██║██║ ╚████║╚██████╔╝███████║
; ╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚══════╝

;/* Translate
* * loads a translation from the translation files in the Interface folder
* *
* * @param: Text, the id of the translation to load
* *
* * @return: the translation if one was found, otherwise the text itself
*/;
string Function Translate(string Text) Global Native


;  █████╗ ██████╗ ██████╗  █████╗ ██╗   ██╗███████╗
; ██╔══██╗██╔══██╗██╔══██╗██╔══██╗╚██╗ ██╔╝██╔════╝
; ███████║██████╔╝██████╔╝███████║ ╚████╔╝ ███████╗
; ██╔══██║██╔══██╗██╔══██╗██╔══██║  ╚██╔╝  ╚════██║
; ██║  ██║██║  ██║██║  ██║██║  ██║   ██║   ███████║
; ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   ╚══════╝

;/* ShuffleFormArray
* * shuffles an array of forms, randomizing the order
* *
* * @param: Array, the array to shuffle
* *
* * @return: the shuffled array
*/;
Form[] Function ShuffleFormArray(Form[] Array) Global Native


;  ██████╗ ██╗   ██╗███████╗███████╗████████╗███████╗
; ██╔═══██╗██║   ██║██╔════╝██╔════╝╚══██╔══╝██╔════╝
; ██║   ██║██║   ██║█████╗  ███████╗   ██║   ███████╗
; ██║▄▄ ██║██║   ██║██╔══╝  ╚════██║   ██║   ╚════██║
; ╚██████╔╝╚██████╔╝███████╗███████║   ██║   ███████║
;  ╚══▀▀═╝  ╚═════╝ ╚══════╝╚══════╝   ╚═╝   ╚══════╝

;/* GetQuestsWithGlobal
* * returns a list of all quests that have the given global in their text display globals
* * this allows you to "flag" quests with a global for quick access
* *
* * @param: Tag, the global to look for on the quests
* *
* * @return: a list of all quests with the given global
*/;
Quest[] Function GetQuestsWithGlobal(GlobalVariable Tag) Global Native