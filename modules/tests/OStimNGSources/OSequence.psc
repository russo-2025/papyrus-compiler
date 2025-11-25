;/* OSequence
* * collection of native functions related to sequences
* *
* * required API version: 7.1 (30)
*/;
ScriptName OSequence

; ██████╗  █████╗ ███╗   ██╗██████╗  ██████╗ ███╗   ███╗    ███████╗███████╗ ██████╗ ██╗   ██╗███████╗███╗   ██╗ ██████╗███████╗███████╗
; ██╔══██╗██╔══██╗████╗  ██║██╔══██╗██╔═══██╗████╗ ████║    ██╔════╝██╔════╝██╔═══██╗██║   ██║██╔════╝████╗  ██║██╔════╝██╔════╝██╔════╝
; ██████╔╝███████║██╔██╗ ██║██║  ██║██║   ██║██╔████╔██║    ███████╗█████╗  ██║   ██║██║   ██║█████╗  ██╔██╗ ██║██║     █████╗  ███████╗
; ██╔══██╗██╔══██║██║╚██╗██║██║  ██║██║   ██║██║╚██╔╝██║    ╚════██║██╔══╝  ██║▄▄ ██║██║   ██║██╔══╝  ██║╚██╗██║██║     ██╔══╝  ╚════██║
; ██║  ██║██║  ██║██║ ╚████║██████╔╝╚██████╔╝██║ ╚═╝ ██║    ███████║███████╗╚██████╔╝╚██████╔╝███████╗██║ ╚████║╚██████╗███████╗███████║
; ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝  ╚═════╝ ╚═╝     ╚═╝    ╚══════╝╚══════╝ ╚══▀▀═╝  ╚═════╝ ╚══════╝╚═╝  ╚═══╝ ╚═════╝╚══════╝╚══════╝

;/* GetRandomSequence
* * returns a random sequence applicable for the actors
* *
* * @param: Actors, the actors to check scene conditions against
* *
* * @return: the id of a matching random sequence, "" if no sequence was found
*/;
string Function GetRandomSequence(Actor[] Actors) Global Native

;/* GetRandomFurnitureSequence
* * returns a random furniture sequence applicable for the actors
* *
* * @param: Actors, the actors to check scene conditions against
* * @param: FurnitureType, the type of furniture for the sequence
* *
* * @return: the id of a matching random sequence, "" if no sequence was found
*/;
string Function GetRandomFurnitureSequence(Actor[] Actors, string FurnitureType) Global Native


; ██████╗ ██╗   ██╗    ███████╗███████╗ ██████╗ ██╗   ██╗███████╗███╗   ██╗ ██████╗███████╗    ████████╗ █████╗  ██████╗ 
; ██╔══██╗╚██╗ ██╔╝    ██╔════╝██╔════╝██╔═══██╗██║   ██║██╔════╝████╗  ██║██╔════╝██╔════╝    ╚══██╔══╝██╔══██╗██╔════╝ 
; ██████╔╝ ╚████╔╝     ███████╗█████╗  ██║   ██║██║   ██║█████╗  ██╔██╗ ██║██║     █████╗         ██║   ███████║██║  ███╗
; ██╔══██╗  ╚██╔╝      ╚════██║██╔══╝  ██║▄▄ ██║██║   ██║██╔══╝  ██║╚██╗██║██║     ██╔══╝         ██║   ██╔══██║██║   ██║
; ██████╔╝   ██║       ███████║███████╗╚██████╔╝╚██████╔╝███████╗██║ ╚████║╚██████╗███████╗       ██║   ██║  ██║╚██████╔╝
; ╚═════╝    ╚═╝       ╚══════╝╚══════╝ ╚══▀▀═╝  ╚═════╝ ╚══════╝╚═╝  ╚═══╝ ╚═════╝╚══════╝       ╚═╝   ╚═╝  ╚═╝ ╚═════╝

;/* GetRandomSequenceWithSequenceTag
* * returns a random sequence applicable for the actors with a sequence tag
* *
* * @param: Actors, the actors to check scene conditions against
* * @param: Tag, the sequence tag
* *
* * @return: the id of a matching random sequence, "" if no sequence was found
*/;
string Function GetRandomSequenceWithSequenceTag(Actor[] Actors, string Tag) Global Native

;/* GetRandomSequenceWithAnySequenceTag
* * returns a random sequence applicable for the actors with any of a list of sequence tags
* *
* * @param: Actors, the actors to check scene conditions against
* * @param: Tags, an array of sequence tags
* *
* * @return: the id of a matching random sequence, "" if no sequence was found
*/;
string Function GetRandomSequenceWithAnySequenceTag(Actor[] Actors, string[] Tags) Global Native

;/* GetRandomSequenceWithAnySequenceTagCSV
* * same as GetRandomSequenceWithAnySequenceTag, except tags are given in a csv-string
* *
* * @param: Actors, the actors to check scene conditions against
* * @param: Tags, a csv-string of sequence tags
* *
* * @return: the id of a matching random sequence, "" if no sequence was found
*/;
string Function GetRandomSequenceWithAnySequenceTagCSV(Actor[] Actors, string Tags) Global Native

;/* GetRandomSequenceWithAllSequenceTags
* * returns a random sequence applicable for the actors with all of a list of sequence tags
* *
* * @param: Actors, the actors to check scene conditions against
* * @param: Tags, an array of sequence tags
* *
* * @return: the id of a matching random sequence, "" if no sequence was found
*/;
string Function GetRandomSequenceWithAllSequenceTags(Actor[] Actors, string[] Tags) Global Native

;/* GetRandomSequenceWithAllSequenceTagsCSV
* * same as GetRandomSequenceWithAllSequenceTags, except tags are given in a csv-string
* *
* * @param: Actors, the actors to check scene conditions against
* * @param: Tags, a csv-string of sequence tags
* *
* * @return: the id of a matching random sequence, "" if no sequence was found
*/;
string Function GetRandomSequenceWithAllSequenceTagsCSV(Actor[] Actors, string Tags) Global Native


;/* GetRandomFurnitureSequenceWithSequenceTag
* * returns a random furniture sequence applicable for the actors with a sequence tag
* *
* * @param: Actors, the actors to check scene conditions against
* * @param: FurnitureType, the type of furniture for the sequence
* * @param: Tag, the sequence tag
* *
* * @return: the id of a matching random sequence, "" if no sequence was found
*/;
string Function GetRandomFurnitureSequenceWithSequenceTag(Actor[] Actors, string FurnitureType, string Tag) Global Native

;/* GetRandomFurnitureSequenceWithAnySequenceTag
* * returns a random furniture sequence applicable for the actors with any of a list of sequence tags
* *
* * @param: Actors, the actors to check scene conditions against
* * @param: FurnitureType, the type of furniture for the sequence
* * @param: Tags, an array of sequence tags
* *
* * @return: the id of a matching random sequence, "" if no sequence was found
*/;
string Function GetRandomFurnitureSequenceWithAnySequenceTag(Actor[] Actors, string FurnitureType, string[] Tags) Global Native

;/* GetRandomSequenceWithAnySequenceTagCSV
* * same as GetRandomFurnitureSequenceWithAnySequenceTag, except tags are given in a csv-string
* *
* * @param: Actors, the actors to check scene conditions against
* * @param: FurnitureType, the type of furniture for the sequence
* * @param: Tags, a csv-string of sequence tags
* *
* * @return: the id of a matching random sequence, "" if no sequence was found
*/;
string Function GetRandomFurnitureSequenceWithAnySequenceTagCSV(Actor[] Actors, string FurnitureType, string Tags) Global Native

;/* GetRandomFurnitureSequenceWithAllSequenceTags
* * returns a random furniture sequence applicable for the actors with all of a list of sequence tags
* *
* * @param: Actors, the actors to check scene conditions against
* * @param: FurnitureType, the type of furniture for the sequence
* * @param: Tags, an array of sequence tags
* *
* * @return: the id of a matching random sequence, "" if no sequence was found
*/;
string Function GetRandomFurnitureSequenceWithAllSequenceTags(Actor[] Actors, string FurnitureType, string[] Tags) Global Native

;/* GetRandomFurnitureSequenceWithAllSequenceTagsCSV
* * same as GetRandomFurnitureSequenceWithAllSequenceTags, except tags are given in a csv-string
* *
* * @param: Actors, the actors to check scene conditions against
* * @param: FurnitureType, the type of furniture for the sequence
* * @param: Tags, a csv-string of sequence tags
* *
* * @return: the id of a matching random sequence, "" if no sequence was found
*/;
string Function GetRandomFurnitureSequenceWithAllSequenceTagsCSV(Actor[] Actors, string FurnitureType, string Tags) Global Native