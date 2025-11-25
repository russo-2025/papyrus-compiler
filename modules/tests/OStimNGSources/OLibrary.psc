;/* OLibrary
* * a collection of native functions referring to the scene library
* * 
* * bed scenes are not considered furniture scenes, those are regular scenes that happen to play on a bed
* * furniture scenes are scenes that can play animations exclusive to certain furniture objects, like sitting on a chair
* * as of right now (OStim NG 6.3) furniture scenes do not work! support will be added soon, though
* * planned furniture types are: chair, bench, shelf, craftingtable, cookingpot
* *
* * all functions taking lists of parameters have two versions:
* * the regular version takes an array (for example ["tag1", "tag2", "tag3"])
* * the CSV version takes a csv-string, CSV stands for comma separated value (for example "tag1,tag2,tag3")
* *
* * some functions need to take lists of lists and therefore only have CSV versions
* * to separate lists use semicoli (for example "tag1,tag2,tag3;tag3,tag4")
* *
* * for easier CSV-string handling use the OCSV.psc script
* *
* * since scene conditions need to be checked against individual actors those have to be passed as an array still
*/;
ScriptName OLibrary

;/* GetAllScenes
* *	returns the list of all scenes
* * this has most likely several hundred entries for most end users
* * so looping through the entire array will probably cause script lag
* *
* * @return: an array containing all scene ids
*/;
string[] Function GetAllScenes() Global Native

;/* GetScenesInRange
* * returns a list of scenes in navigation range of the given scene
* *
* * required API version: 7.3.4a (0x07030041)
* *
* * @param: Id, the id of the scene
* * @param: Actors, the actors to check scene requirements against
* * @param: Distance, the distance to search in, if 0 will use MCM setting
* *
* * @return: an array of qualifying scenes
*/;
string[] Function GetScenesInRange(string Id, Actor[] Actors, int Distance = 0) Global Native

; ██████╗  █████╗ ███╗   ██╗██████╗  ██████╗ ███╗   ███╗    ███████╗ ██████╗███████╗███╗   ██╗███████╗███████╗
; ██╔══██╗██╔══██╗████╗  ██║██╔══██╗██╔═══██╗████╗ ████║    ██╔════╝██╔════╝██╔════╝████╗  ██║██╔════╝██╔════╝
; ██████╔╝███████║██╔██╗ ██║██║  ██║██║   ██║██╔████╔██║    ███████╗██║     █████╗  ██╔██╗ ██║█████╗  ███████╗
; ██╔══██╗██╔══██║██║╚██╗██║██║  ██║██║   ██║██║╚██╔╝██║    ╚════██║██║     ██╔══╝  ██║╚██╗██║██╔══╝  ╚════██║
; ██║  ██║██║  ██║██║ ╚████║██████╔╝╚██████╔╝██║ ╚═╝ ██║    ███████║╚██████╗███████╗██║ ╚████║███████╗███████║
; ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝  ╚═════╝ ╚═╝     ╚═╝    ╚══════╝ ╚═════╝╚══════╝╚═╝  ╚═══╝╚══════╝╚══════╝

;/* GetRandomScene
* * returns a random scene applicable for the actors
* *
* * @param: Actors, the actors the check scene conditions against
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomScene(Actor[] Actors) Global Native

;/* GetRandomFurnitureScene
* * returns a random furniture scene applicable for the actors
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: FurnitureType, the type of furniture for the scene
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomFurnitureScene(Actor[] Actors, string FurnitureType) Global Native


; ██████╗ ██╗   ██╗    ███████╗ ██████╗███████╗███╗   ██╗███████╗    ████████╗ █████╗  ██████╗ 
; ██╔══██╗╚██╗ ██╔╝    ██╔════╝██╔════╝██╔════╝████╗  ██║██╔════╝    ╚══██╔══╝██╔══██╗██╔════╝ 
; ██████╔╝ ╚████╔╝     ███████╗██║     █████╗  ██╔██╗ ██║█████╗         ██║   ███████║██║  ███╗
; ██╔══██╗  ╚██╔╝      ╚════██║██║     ██╔══╝  ██║╚██╗██║██╔══╝         ██║   ██╔══██║██║   ██║
; ██████╔╝   ██║       ███████║╚██████╗███████╗██║ ╚████║███████╗       ██║   ██║  ██║╚██████╔╝
; ╚═════╝    ╚═╝       ╚══════╝ ╚═════╝╚══════╝╚═╝  ╚═══╝╚══════╝       ╚═╝   ╚═╝  ╚═╝ ╚═════╝ 

;/* GetRandomSceneWithSceneTag
* * returns a random scene applicable for the actors with a scene tag
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: Tag, the scene tag
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomSceneWithSceneTag(Actor[] Actors, string Tag) Global Native

;/* GetRandomSceneWithAnySceneTag
* * returns a random scene applicable for the actors with any of a list of scene tags
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: Tags, an array scene tags
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomSceneWithAnySceneTag(Actor[] Actors, string[] Tags) Global Native

;/* GetRandomSceneWithAnySceneTagCSV
* * same as GetRandomSceneWithAnyTag, except tags are given in a csv-string
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: Tags, a csv-string of scene tags
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomSceneWithAnySceneTagCSV(Actor[] Actors, string Tags) Global Native

;/* GetRandomSceneWithAllSceneTags
* * returns a random scene applicable for the actors with all of a list of scene tags
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: Tags, an array of scene tags
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomSceneWithAllSceneTags(Actor[] Actors, string[] Tags) Global Native

;/* GetRandomSceneWithAllSceneTagsCSV
* * same as GetRandomSceneWithAllTags, except tags are given in a csv-string
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: Tags, a csv-string of scene tags
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomSceneWithAllSceneTagsCSV(Actor[] Actors, string Tags) Global Native


;/* GetRandomFurnitureSceneWithSceneTag
* * returns a random furniture scene applicable for the actors with a scene tag
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: FurnitureType, the type of furniture for the scene
* * @param: Tag, the scene tag
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomFurnitureSceneWithSceneTag(Actor[] Actors, string FurnitureType, string Tag) Global Native

;/* GetRandomFurnitureSceneWithAnySceneTag
* * returns a random furniture scene applicable for the actors with any of a list of scene tags
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: FurnitureType, the type of furniture for the scene
* * @param: Tags, an array scene tags
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomFurnitureSceneWithAnySceneTag(Actor[] Actors, string FurnitureType, string[] Tags) Global Native

;/* GetRandomFurnitureSceneWithAnySceneTagCSV
* * same as GetRandomFurnitureSceneWithAnyTag, except tags are given in a csv-string
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: FurnitureType, the type of furniture for the scene
* * @param: Tags, a csv-string of scene tags
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomFurnitureSceneWithAnySceneTagCSV(Actor[] Actors, string FurnitureType, string Tags) Global Native

;/* GetRandomFurnitureSceneWithAllSceneTags
* * returns a random furniture scene applicable for the actors with all of a list of scene tags
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: FurnitureType, the type of furniture for the scene
* * @param: Tags, an array of scene tags
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomFurnitureSceneWithAllSceneTags(Actor[] Actors, string FurnitureType, string[] Tags) Global Native

;/* GetRandomFurnitureSceneWithAllSceneTagsCSV
* * same as GetRandomFurnitureSceneWithAllTags, except tags are given in a csv-string
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: FurnitureType, the type of furniture for the scene
* * @param: Tags, a csv-list of scene tags
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomFurnitureSceneWithAllSceneTagsCSV(Actor[] Actors, string FurnitureType, string Tags) Global Native


; ██████╗ ██╗   ██╗    ███████╗██╗███╗   ██╗ ██████╗ ██╗     ███████╗     █████╗  ██████╗████████╗ ██████╗ ██████╗     ████████╗ █████╗  ██████╗ 
; ██╔══██╗╚██╗ ██╔╝    ██╔════╝██║████╗  ██║██╔════╝ ██║     ██╔════╝    ██╔══██╗██╔════╝╚══██╔══╝██╔═══██╗██╔══██╗    ╚══██╔══╝██╔══██╗██╔════╝ 
; ██████╔╝ ╚████╔╝     ███████╗██║██╔██╗ ██║██║  ███╗██║     █████╗      ███████║██║        ██║   ██║   ██║██████╔╝       ██║   ███████║██║  ███╗
; ██╔══██╗  ╚██╔╝      ╚════██║██║██║╚██╗██║██║   ██║██║     ██╔══╝      ██╔══██║██║        ██║   ██║   ██║██╔══██╗       ██║   ██╔══██║██║   ██║
; ██████╔╝   ██║       ███████║██║██║ ╚████║╚██████╔╝███████╗███████╗    ██║  ██║╚██████╗   ██║   ╚██████╔╝██║  ██║       ██║   ██║  ██║╚██████╔╝
; ╚═════╝    ╚═╝       ╚══════╝╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚══════╝╚══════╝    ╚═╝  ╚═╝ ╚═════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝       ╚═╝   ╚═╝  ╚═╝ ╚═════╝ 

;/* GetRandomSceneWithSingleActorTag
* * returns a random scene applicable for the actors with a tag for a single actor
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: Position, the index of the actor in the scene
* * @param: Tag, the actor tag
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomSceneWithSingleActorTag(Actor[] Actors, int Position, string Tag) Global Native

;/* GetRandomSceneWithAnySingleActorTag
* * returns a random scene applicable for the actors with any of a list of tags for a single actor
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: Position, the index of the actor in the scene
* * @param: Tags, an array of actor tags
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomSceneWithAnySingleActorTag(Actor[] Actors, int Position, string[] Tags) Global Native

;/* GetRandomSceneWithAnySingleActorTagCSV
* * same as GetRandomSceneWithAnySingleActorTag, except tags are given in a csv-string
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: Position, the index of the actor in the scene
* * @param: Tags, a csv-string of actor tags
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomSceneWithAnySingleActorTagCSV(Actor[] Actors, int Position, string Tags) Global Native

;/* GetRandomSceneWithAllSingleActorTags
* * returns a random scene applicable for the actors with all of a list of tags for a single actor
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: Position, the index of the actor in the scene
* * @param: Tags, an array of actor tags
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomSceneWithAllSingleActorTags(Actor[] Actors, int Position, string[] Tags) Global Native

;/* GetRandomSceneWithAllSingleActorTagsCSV
* * same as GetRandomSceneWithAllSingleActorTags, except tags are given in a csv-string
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: Position, the index of the actor in the scene
* * @param: Tags, a csv-string of actor tags
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomSceneWithAllSingleActorTagsCSV(Actor[] Actors, int Position, string Tags) Global Native


;/* GetRandomFurnitureSceneWithSingleActorTag
* * returns a random furniture scene applicable for the actors with a tag for a single actor
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: FurnitureType, the type of furniture for the scene
* * @param: Position, the index of the actor in the scene
* * @param: Tag, the actor tag
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomFurnitureSceneWithSingleActorTag(Actor[] Actors, string FurnitureType, int Position, string Tag) Global Native

;/* GetRandomFurnitureSceneWithAnySingleActorTag
* * returns a random furniture scene applicable for the actors with any of a list of tags for a single actor
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: FurnitureType, the type of furniture for the scene
* * @param: Position, the index of the actor in the scene
* * @param: Tags, an array of actor tags
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomFurnitureSceneWithAnySingleActorTag(Actor[] Actors, string FurnitureType, int Position, string[] Tags) Global Native

;/* GetRandomFurnitureSceneWithAnySingleActorTagCSV
* * same as GetRandomFurnitureSceneWithAnySingleActorTag, except tags are given in a csv-string
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: FurnitureType, the type of furniture for the scene
* * @param: Position, the index of the actor in the scene
* * @param: Tags, a csv-string of actor tags
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomFurnitureSceneWithAnySingleActorTagCSV(Actor[] Actors, string FurnitureType, int Position, string Tags) Global Native

;/* GetRandomFurnitureSceneWithAllSingleActorTags
* * returns a random furniture scene applicable for the actors with all of a list of tags for a single actor
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: FurnitureType, the type of furniture for the scene
* * @param: Position, the index of the actor in the scene
* * @param: Tags, an array of actor tags
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomFurnitureSceneWithAllSingleActorTags(Actor[] Actors, string FurnitureType, int Position, string[] Tags) Global Native

;/* GetRandomFurnitureSceneWithAllSingleActorTagsCSV
* * same as GetRandomFurnitureSceneWithAllSingleActorTags, except tags are given in a csv-string
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: FurnitureType, the type of furniture for the scene
* * @param: Position, the index of the actor in the scene
* * @param: Tags, a csv-string of actor tags
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomFurnitureSceneWithAllSingleActorTagsCSV(Actor[] Actors, string FurnitureType, int Position, string Tags) Global Native


; ██████╗ ██╗   ██╗    ███╗   ███╗██╗   ██╗██╗  ████████╗██╗     █████╗  ██████╗████████╗ ██████╗ ██████╗     ████████╗ █████╗  ██████╗ 
; ██╔══██╗╚██╗ ██╔╝    ████╗ ████║██║   ██║██║  ╚══██╔══╝██║    ██╔══██╗██╔════╝╚══██╔══╝██╔═══██╗██╔══██╗    ╚══██╔══╝██╔══██╗██╔════╝ 
; ██████╔╝ ╚████╔╝     ██╔████╔██║██║   ██║██║     ██║   ██║    ███████║██║        ██║   ██║   ██║██████╔╝       ██║   ███████║██║  ███╗
; ██╔══██╗  ╚██╔╝      ██║╚██╔╝██║██║   ██║██║     ██║   ██║    ██╔══██║██║        ██║   ██║   ██║██╔══██╗       ██║   ██╔══██║██║   ██║
; ██████╔╝   ██║       ██║ ╚═╝ ██║╚██████╔╝███████╗██║   ██║    ██║  ██║╚██████╗   ██║   ╚██████╔╝██║  ██║       ██║   ██║  ██║╚██████╔╝
; ╚═════╝    ╚═╝       ╚═╝     ╚═╝ ╚═════╝ ╚══════╝╚═╝   ╚═╝    ╚═╝  ╚═╝ ╚═════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝       ╚═╝   ╚═╝  ╚═╝ ╚═════╝ 

; every actor will be checked for the tag/tags in the tags parameter with the respective index
; so Actors[0] will be checked for Tags[0]
; Actors[1] will be checked for Tags[1], etc.

;/* GetRandomSceneWithMultiActorTagForAny
* * returns a random scene applicable for the actors with at least one actor having the respective actor tag
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: Tags, an array of actor tags
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomSceneWithMultiActorTagForAny(Actor[] Actors, string[] Tags) Global Native

;/* GetRandomSceneWithMultiActorTagForAnyCSV
* * same as GetRandomSceneWithMultiActorTagForAny, except tags are passed as a csv-string
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: Tags, a csv-string of actor tags
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomSceneWithMultiActorTagForAnyCSV(Actor[] Actors, string Tags) Global Native

;/* GetRandomSceneWithMultiActorTagForAll
* * returns a random scene applicable for the actors with all actors having the respective actor tag
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: Tags, an array of actor tags
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomSceneWithMultiActorTagForAll(Actor[] Actors, string[] Tags) Global Native

;/* GetRandomSceneWithMultiActorTagForAllCSV
* * same as GetRandomSceneWithMultiActorTagForAll, except tags are passed as a csv-string
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: Tags, a csv-string of actor tags
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomSceneWithMultiActorTagForAllCSV(Actor[] Actors, string Tags) Global Native

;/* GetRandomSceneWithAnyMultiActorTagForAnyCSV
* * returns a random scene applicable for the actors with at least one actor having at least one of the respective actor tags
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: Tags, a csv-string of lists of actor tags
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomSceneWithAnyMultiActorTagForAnyCSV(Actor[] Actors, string Tags) Global Native

;/* GetRandomSceneWithAnyMultiActorTagForAllCSV
* * returns a random scene applicable for the actors with all actors having at least one of the respective actor tags
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: Tags, a csv-string of lists of actor tags
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomSceneWithAnyMultiActorTagForAllCSV(Actor[] Actors, string Tags) Global Native

;/* GetRandomSceneWithAllMultiActorTagsForAnyCSV
* * returns a random scene applicable for the actors with at least one actor having all of the respective actor tags
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: Tags, a csv-string of lists of actor tags
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomSceneWithAllMultiActorTagsForAnyCSV(Actor[] Actors, string Tags) Global Native

;/* GetRandomSceneWithAllMultiActorTagsForAllCSV
* * returns a random scene applicable for the actors with all actors having all of the respective actor tags
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: Tags, a csv-string of lists of actor tags
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomSceneWithAllMultiActorTagsForAllCSV(Actor[] Actors, string Tags) Global Native


;/* GetRandomFurnitureSceneWithMultiActorTagForAny
* * returns a random furniture scene applicable for the actors with at least one actor having the respective actor tag
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: FurnitureType, the type of furniture for the scene
* * @param: Tags, an array of actor tags
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomFurnitureSceneWithMultiActorTagForAny(Actor[] Actors, string FurnitureType, string[] Tags) Global Native

;/* GetRandomFurnitureSceneWithMultiActorTagForAnyCSV
* * same as GetRandomFurnitureSceneWithMultiActorTagForAny, except tags are passed as a csv-string
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: FurnitureType, the type of furniture for the scene
* * @param: Tags, a csv-string of actor tags
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomFurnitureSceneWithMultiActorTagForAnyCSV(Actor[] Actors, string FurnitureType, string Tags) Global Native

;/* GetRandomFurnitureSceneWithMultiActorTagForAll
* * returns a random furniture scene applicable for the actors with all actors having the respective actor tag
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: FurnitureType, the type of furniture for the scene
* * @param: Tags, an array of actor tags
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomFurnitureSceneWithMultiActorTagForAll(Actor[] Actors, string FurnitureType, string[] Tags) Global Native

;/* GetRandomFurnitureSceneWithMultiActorTagForAlLCSV
* * same as GetRandomFurnitureSceneWithMultiActorTagForAll, except tags are passed as a csv-string
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: FurnitureType, the type of furniture for the scene
* * @param: Tags, a csv-string of actor tags
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomFurnitureSceneWithMultiActorTagForAlLCSV(Actor[] Actors, string FurnitureType, string Tags) Global Native

;/* GetRandomFurnitureSceneWithAnyMultiActorTagForAnyCSV
* * returns a random furniture scene applicable for the actors with at least one actor having at least one of the respective actor tags
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: FurnitureType, the type of furniture for the scene
* * @param: Tags, a csv-string of lists of actor tags
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomFurnitureSceneWithAnyMultiActorTagForAnyCSV(Actor[] Actors, string FurnitureType, string Tags) Global Native

;/* GetRandomFurnitureSceneWithAnyMultiActorTagForAllCSV
* * returns a random furniture scene applicable for the actors with all actors having at least one of the respective actor tags
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: FurnitureType, the type of furniture for the scene
* * @param: Tags, a csv-string of lists of actor tags
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomFurnitureSceneWithAnyMultiActorTagForAllCSV(Actor[] Actors, string FurnitureType, string Tags) Global Native

;/* GetRandomFurnitureSceneWithAllMultiActorTagsForAnyCSV
* * returns a random furniture scene applicable for the actors with at least one actor having all of the respective actor tags
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: FurnitureType, the type of furniture for the scene
* * @param: Tags, a csv-string of lists of actor tags
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomFurnitureSceneWithAllMultiActorTagsForAnyCSV(Actor[] Actors, string FurnitureType, string Tags) Global Native

;/* GetRandomFurnitureSceneWithAllMultiActorTagsForAllCSV
* * returns a random furniture scene applicable for the actors with all actors having all of the respective actor tags
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: FurnitureType, the type of furniture for the scene
* * @param: Tags, a csv-string of lists of actor tags
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomFurnitureSceneWithAllMultiActorTagsForAllCSV(Actor[] Actors, string FurnitureType, string Tags) Global Native


; ██████╗ ██╗   ██╗    ███████╗ ██████╗███████╗███╗   ██╗███████╗     █████╗ ███╗   ██╗██████╗      █████╗  ██████╗████████╗ ██████╗ ██████╗     ████████╗ █████╗  ██████╗ 
; ██╔══██╗╚██╗ ██╔╝    ██╔════╝██╔════╝██╔════╝████╗  ██║██╔════╝    ██╔══██╗████╗  ██║██╔══██╗    ██╔══██╗██╔════╝╚══██╔══╝██╔═══██╗██╔══██╗    ╚══██╔══╝██╔══██╗██╔════╝ 
; ██████╔╝ ╚████╔╝     ███████╗██║     █████╗  ██╔██╗ ██║█████╗      ███████║██╔██╗ ██║██║  ██║    ███████║██║        ██║   ██║   ██║██████╔╝       ██║   ███████║██║  ███╗
; ██╔══██╗  ╚██╔╝      ╚════██║██║     ██╔══╝  ██║╚██╗██║██╔══╝      ██╔══██║██║╚██╗██║██║  ██║    ██╔══██║██║        ██║   ██║   ██║██╔══██╗       ██║   ██╔══██║██║   ██║
; ██████╔╝   ██║       ███████║╚██████╗███████╗██║ ╚████║███████╗    ██║  ██║██║ ╚████║██████╔╝    ██║  ██║╚██████╗   ██║   ╚██████╔╝██║  ██║       ██║   ██║  ██║╚██████╔╝
; ╚═════╝    ╚═╝       ╚══════╝ ╚═════╝╚══════╝╚═╝  ╚═══╝╚══════╝    ╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝     ╚═╝  ╚═╝ ╚═════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝       ╚═╝   ╚═╝  ╚═╝ ╚═════╝ 

;/* GetRandomSceneWithAnySceneTagAndAnyMultiActorTagForAnyCSV
* * returns a random scene applicable for the actors with any of a list of scene tags and at least one actor having at least one of the respective actor tags
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: SceneTags, a csv-string of scene tags
* * @param: ActorTags, a csv-string of lists of actor tags
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomSceneWithAnySceneTagAndAnyMultiActorTagForAnyCSV(Actor[] Actors, string SceneTags, string ActorTags) Global Native

;/* GetRandomSceneWithAllSceneTagsAndAnyMultiActorTagForAnyCSV
* * returns a random scene applicable for the actors with all of a list of scene tags and at least one actor having at least one of the respective actor tags
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: SceneTags, a csv-string of scene tags
* * @param: ActorTags, a csv-string of lists of actor tags
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomSceneWithAllSceneTagsAndAnyMultiActorTagForAnyCSV(Actor[] Actors, string SceneTags, string ActorTags) Global Native

;/* GetRandomSceneWithAnySceneTagAndAnyMultiActorTagForAllCSV
* * returns a random scene applicable for the actors with any of a list of scene tags and all actors having at least one of the respective actor tags
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: SceneTags, a csv-string of scene tags
* * @param: ActorTags, a csv-string of lists of actor tags
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomSceneWithAnySceneTagAndAnyMultiActorTagForAllCSV(Actor[] Actors, string SceneTags, string ActorTags) Global Native

;/* GetRandomSceneWithAllSceneTagsAndAnyMultiActorTagForAllCSV
* * returns a random scene applicable for the actors with all of a list of scene tags and all actors having at least one of the respective actor tags
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: SceneTags, a csv-string of scene tags
* * @param: ActorTags, a csv-string of lists of actor tags
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomSceneWithAllSceneTagsAndAnyMultiActorTagForAllCSV(Actor[] Actors, string SceneTags, string ActorTags) Global Native

;/* GetRandomSceneWithAnySceneTagAndAllMultiActorTagsForAnyCSV
* * returns a random scene applicable for the actors with any of a list of scene tags and at least one actor having all of the respective actor tags
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: SceneTags, a csv-string of scene tags
* * @param: ActorTags, a csv-string of lists of actor tags
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomSceneWithAnySceneTagAndAllMultiActorTagsForAnyCSV(Actor[] Actors, string SceneTags, string ActorTags) Global Native

;/* GetRandomSceneWithAllSceneTagsAndAllMultiActorTagsForAnyCSV
* * returns a random scene applicable for the actors with all of a list of scene tags and at least one actor having all of the respective actor tags
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: SceneTags, a csv-string of scene tags
* * @param: ActorTags, a csv-string of lists of actor tags
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomSceneWithAllSceneTagsAndAllMultiActorTagsForAnyCSV(Actor[] Actors, string SceneTags, string ActorTags) Global Native

;/* GetRandomSceneWithAnySceneTagAndAllMultiActorTagsForAllCSV
* * returns a random scene applicable for the actors with any of a list of scene tags and all actors having all of the respective actor tags
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: SceneTags, a csv-string of scene tags
* * @param: ActorTags, a csv-string of lists of actor tags
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomSceneWithAnySceneTagAndAllMultiActorTagsForAllCSV(Actor[] Actors, string SceneTags, string ActorTags) Global Native

;/* GetRandomSceneWithAllSceneTagsAndAllMultiActorTagsForAllCSV
* * returns a random scene applicable for the actors with all of a list of scene tags and all actors having all of the respective actor tags
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: SceneTags, a csv-string of scene tags
* * @param: ActorTags, a csv-string of lists of actor tags
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomSceneWithAllSceneTagsAndAllMultiActorTagsForAllCSV(Actor[] Actors, string SceneTags, string ActorTags) Global Native


;/* GetRandomFurnitureSceneWithAnySceneTagAndAnyMultiActorTagForAnyCSV
* * returns a random furniture scene applicable for the actors with any of a list of scene tags and at least one actor having at least one of the respective actor tags
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: FurnitureType, the type of furniture for the scene
* * @param: SceneTags, a csv-string of scene tags
* * @param: ActorTags, a csv-string of lists of actor tags
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomFurnitureSceneWithAnySceneTagAndAnyMultiActorTagForAnyCSV(Actor[] Actors, string FurnitureType, string SceneTags, string ActorTags) Global Native

;/* GetRandomFurnitureSceneWithAllSceneTagsAndAnyMultiActorTagForAnyCSV
* * returns a random furniture scene applicable for the actors with all of a list of scene tags and at least one actor having at least one of the respective actor tags
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: FurnitureType, the type of furniture for the scene
* * @param: SceneTags, a csv-string of scene tags
* * @param: ActorTags, a csv-string of lists of actor tags
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomFurnitureSceneWithAllSceneTagsAndAnyMultiActorTagForAnyCSV(Actor[] Actors, string FurnitureType, string SceneTags, string ActorTags) Global Native

;/* GetRandomFurnitureSceneWithAnySceneTagAndAnyMultiActorTagForAllCSV
* * returns a random furniture scene applicable for the actors with any of a list of scene tags and all actors having at least one of the respective actor tags
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: FurnitureType, the type of furniture for the scene
* * @param: SceneTags, a csv-string of scene tags
* * @param: ActorTags, a csv-string of lists of actor tags
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomFurnitureSceneWithAnySceneTagAndAnyMultiActorTagForAllCSV(Actor[] Actors, string FurnitureType, string SceneTags, string ActorTags) Global Native

;/* GetRandomFurnitureSceneWithAllSceneTagsAndAnyMultiActorTagForAllCSV
* * returns a random furniture scene applicable for the actors with all of a list of scene tags and all actors having at least one of the respective actor tags
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: FurnitureType, the type of furniture for the scene
* * @param: SceneTags, a csv-string of scene tags
* * @param: ActorTags, a csv-string of lists of actor tags
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomFurnitureSceneWithAllSceneTagsAndAnyMultiActorTagForAllCSV(Actor[] Actors, string FurnitureType, string SceneTags, string ActorTags) Global Native

;/* GetRandomFurnitureSceneWithAnySceneTagAndAllMultiActorTagsForAnyCSV
* * returns a random furniture scene applicable for the actors with any of a list of scene tags and at least one actor having all of the respective actor tags
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: FurnitureType, the type of furniture for the scene
* * @param: SceneTags, a csv-string of scene tags
* * @param: ActorTags, a csv-string of lists of actor tags
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomFurnitureSceneWithAnySceneTagAndAllMultiActorTagsForAnyCSV(Actor[] Actors, string FurnitureType, string SceneTags, string ActorTags) Global Native

;/* GetRandomFurnitureSceneWithAllSceneTagsAndAllMultiActorTagsForAnyCSV
* * returns a random furniture scene applicable for the actors with all of a list of scene tags and at least one actor having all of the respective actor tags
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: FurnitureType, the type of furniture for the scene
* * @param: SceneTags, a csv-string of scene tags
* * @param: ActorTags, a csv-string of lists of actor tags
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomFurnitureSceneWithAllSceneTagsAndAllMultiActorTagsForAnyCSV(Actor[] Actors, string FurnitureType, string SceneTags, string ActorTags) Global Native

;/* GetRandomFurnitureSceneWithAnySceneTagAndAllMultiActorTagsForAllCSV
* * returns a random furniture scene applicable for the actors with any of a list of scene tags and all actors having all of the respective actor tags
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: FurnitureType, the type of furniture for the scene
* * @param: SceneTags, a csv-string of scene tags
* * @param: ActorTags, a csv-string of lists of actor tags
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomFurnitureSceneWithAnySceneTagAndAllMultiActorTagsForAllCSV(Actor[] Actors, string FurnitureType, string SceneTags, string ActorTags) Global Native

;/* GetRandomFurnitureSceneWithAllSceneTagsAndAllMultiActorTagsForAllCSV
* * returns a random furniture scene applicable for the actors with all of a list of scene tags and all actors having all of the respective actor tags
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: FurnitureType, the type of furniture for the scene
* * @param: SceneTags, a csv-string of scene tags
* * @param: ActorTags, a csv-string of lists of actor tags
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomFurnitureSceneWithAllSceneTagsAndAllMultiActorTagsForAllCSV(Actor[] Actors, string FurnitureType, string SceneTags, string ActorTags) Global Native


; ██████╗ ██╗   ██╗     █████╗  ██████╗████████╗██╗ ██████╗ ███╗   ██╗
; ██╔══██╗╚██╗ ██╔╝    ██╔══██╗██╔════╝╚══██╔══╝██║██╔═══██╗████╗  ██║
; ██████╔╝ ╚████╔╝     ███████║██║        ██║   ██║██║   ██║██╔██╗ ██║
; ██╔══██╗  ╚██╔╝      ██╔══██║██║        ██║   ██║██║   ██║██║╚██╗██║
; ██████╔╝   ██║       ██║  ██║╚██████╗   ██║   ██║╚██████╔╝██║ ╚████║
; ╚═════╝    ╚═╝       ╚═╝  ╚═╝ ╚═════╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝                                                                 

;/* GetRandomSceneWithAction
* * returns a random scene applicable for the actors with an action
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: Type, the action type
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomSceneWithAction(Actor[] Actors, string Type) Global Native

;/* GetRandomSceneWithAnyAction
* * returns a random scene applicable for the actors with any of a list of actions
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: Types, an array of action types
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomSceneWithAnyAction(Actor[] Actors, string[] Types) Global Native

;/* GetRandomSceneWithAnyActionCSV
* * same as GetRandomSceneWithAnyAction, except types are passed in a csv-string
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: Types, a csv-string of action types
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomSceneWithAnyActionCSV(Actor[] Actors, string Types) Global Native

;/* GetRandomSceneWithAllActions
* * returns a random scene applicable for the actors with all of a list of actions
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: Types, an array of action types
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomSceneWithAllActions(Actor[] Actors, string[] Types) Global Native

;/* GetRandomSceneWithAllActionsCSV
* * same as GetRandomSceneWithAllActions, except types are passed in a csv-string
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: Types, a csv-string of action types
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomSceneWithAllActionsCSV(Actor[] Actors, string Types) Global Native


;/* GetRandomFurnitureSceneWithAction
* * returns a random furniture scene applicable for the actors with an action
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: FurnitureType, the type of furniture for the scene
* * @param: Type, the action type
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomFurnitureSceneWithAction(Actor[] Actors, string FurnitureType, string Type) Global Native

;/* GetRandomFurnitureSceneWithAnyAction
* * returns a random furniture scene applicable for the actors with any of a list of actions
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: FurnitureType, the type of furniture for the scene
* * @param: Types, an array of action types
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomFurnitureSceneWithAnyAction(Actor[] Actors, string FurnitureType, string[] Types) Global Native

;/* GetRandomFurnitureSceneWithAnyActionCSV
* * same as GetRandomFurnitureSceneWithAnyAction, except types are passed in a csv-string
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: FurnitureType, the type of furniture for the scene
* * @param: Types, a csv-string of action types
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomFurnitureSceneWithAnyActionCSV(Actor[] Actors, string FurnitureType, string Types) Global Native

;/* GetRandomFurnitureSceneWithAllActions
* * returns a random furniture scene applicable for the actors with all of a list of actions
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: FurnitureType, the type of furniture for the scene
* * @param: Types, an array of action types
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomFurnitureSceneWithAllActions(Actor[] Actors, string FurnitureType, string[] Types) Global Native

;/* GetRandomFurnitureSceneWithAllActionsCSV
* * same as GetRandomFurnitureSceneWithAllActions, except types are passed in a csv-string
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: FurnitureType, the type of furniture for the scene
* * @param: Types, a csv-string of action types
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomFurnitureSceneWithAllActionsCSV(Actor[] Actors, string FurnitureType, string Types) Global Native


; ██████╗ ██╗   ██╗     █████╗  ██████╗████████╗██╗ ██████╗ ███╗   ██╗     █████╗  ██████╗████████╗ ██████╗ ██████╗ 
; ██╔══██╗╚██╗ ██╔╝    ██╔══██╗██╔════╝╚══██╔══╝██║██╔═══██╗████╗  ██║    ██╔══██╗██╔════╝╚══██╔══╝██╔═══██╗██╔══██╗
; ██████╔╝ ╚████╔╝     ███████║██║        ██║   ██║██║   ██║██╔██╗ ██║    ███████║██║        ██║   ██║   ██║██████╔╝
; ██╔══██╗  ╚██╔╝      ██╔══██║██║        ██║   ██║██║   ██║██║╚██╗██║    ██╔══██║██║        ██║   ██║   ██║██╔══██╗
; ██████╔╝   ██║       ██║  ██║╚██████╗   ██║   ██║╚██████╔╝██║ ╚████║    ██║  ██║╚██████╗   ██║   ╚██████╔╝██║  ██║
; ╚═════╝    ╚═╝       ╚═╝  ╚═╝ ╚═════╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝    ╚═╝  ╚═╝ ╚═════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝

;/* GetRandomSceneWithActionForActor
* * returns a random scene applicable for the actors with an action of an actor
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: Position, the index of the action actor in the scene
* * @param: Type, the action type
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomSceneWithActionForActor(Actor[] Actors, int Position, string Type) Global Native

;/* GetRandomSceneWithAnyActionForActor
* * returns a random scene applicable for the actors with any of a list of actions of an actor
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: Position, the index of the action actor in the scene
* * @param: Types, an array of action types
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomSceneWithAnyActionForActor(Actor[] Actors, int Position, string[] Types) Global Native

;/* GetRandomSceneWithAnyActionForActorCSV
* * same as GetRandomSceneWithAnyActionForActor, except types are passed as csv-string
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: Position, the index of the action actor in the scene
* * @param: Types, a csv-string of action types
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomSceneWithAnyActionForActorCSV(Actor[] Actors, int Position, string Types) Global Native

;/* GetRandomSceneWithAllActionsForActor
* * returns a random scene applicable for the actors with all of a list of actions of an actor
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: Position, the index of the action actor in the scene
* * @param: Types, an array of action types
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomSceneWithAllActionsForActor(Actor[] Actors, int Position, string[] Types) Global Native

;/* GetRandomSceneWithAllActionsForActorCSV
* * same as GetRandomSceneWithAllActionsForActor, except types are passed as csv-string
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: Position, the index of the action actor in the scene
* * @param: Types, a csv-string of action types
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomSceneWithAllActionsForActorCSV(Actor[] Actors, int Position, string Types) Global Native


;/* GetRandomFurnitureSceneWithActionForActor
* * returns a random furniture scene applicable for the actors with an action of an actor
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: FurnitureType, the type of furniture for the scene
* * @param: Position, the index of the action actor in the scene
* * @param: Type, the action type
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomFurnitureSceneWithActionForActor(Actor[] Actors, string FurnitureType, int Position, string Type) Global Native

;/* GetRandomFurnitureSceneWithAnyActionForActor
* * returns a random furniture scene applicable for the actors with any of a list of actions of an actor
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: FurnitureType, the type of furniture for the scene
* * @param: Position, the index of the action actor in the scene
* * @param: Types, an array of action types
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomFurnitureSceneWithAnyActionForActor(Actor[] Actors, string FurnitureType, int Position, string[] Types) Global Native

;/* GetRandomFurnitureSceneWithAnyActionForActorCSV
* * same as GetRandomFurnitureSceneWithAnyActionForActor, except types are passed as csv-string
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: FurnitureType, the type of furniture for the scene
* * @param: Position, the index of the action actor in the scene
* * @param: Types, a csv-string of action types
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomFurnitureSceneWithAnyActionForActorCSV(Actor[] Actors, string FurnitureType, int Position, string Types) Global Native

;/* GetRandomFurnitureSceneWithAllActionsForActor
* * returns a random furniture scene applicable for the actors with all of a list of actions of an actor
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: FurnitureType, the type of furniture for the scene
* * @param: Position, the index of the action actor in the scene
* * @param: Types, an array of action types
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomFurnitureSceneWithAllActionsForActor(Actor[] Actors, string FurnitureType, int Position, string[] Types) Global Native

;/* GetRandomFurnitureSceneWithAllActionsForActorCSV
* * same as GetRandomFurnitureSceneWithAllActionsForActor, except types are passed as csv-string
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: FurnitureType, the type of furniture for the scene
* * @param: Position, the index of the action actor in the scene
* * @param: Types, a csv-string of action types
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomFurnitureSceneWithAllActionsForActorCSV(Actor[] Actors, string FurnitureType, int Position, string Types) Global Native


; ██████╗ ██╗   ██╗     █████╗  ██████╗████████╗██╗ ██████╗ ███╗   ██╗    ████████╗ █████╗ ██████╗  ██████╗ ███████╗████████╗
; ██╔══██╗╚██╗ ██╔╝    ██╔══██╗██╔════╝╚══██╔══╝██║██╔═══██╗████╗  ██║    ╚══██╔══╝██╔══██╗██╔══██╗██╔════╝ ██╔════╝╚══██╔══╝
; ██████╔╝ ╚████╔╝     ███████║██║        ██║   ██║██║   ██║██╔██╗ ██║       ██║   ███████║██████╔╝██║  ███╗█████╗     ██║   
; ██╔══██╗  ╚██╔╝      ██╔══██║██║        ██║   ██║██║   ██║██║╚██╗██║       ██║   ██╔══██║██╔══██╗██║   ██║██╔══╝     ██║   
; ██████╔╝   ██║       ██║  ██║╚██████╗   ██║   ██║╚██████╔╝██║ ╚████║       ██║   ██║  ██║██║  ██║╚██████╔╝███████╗   ██║   
; ╚═════╝    ╚═╝       ╚═╝  ╚═╝ ╚═════╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝       ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝   ╚═╝   

;/* GetRandomSceneWithActionForTarget
* * returns a random scene applicable for the actors with an action of a target
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: Position, the index of the action target in the scene
* * @param: Type, the action type
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomSceneWithActionForTarget(Actor[] Actors, int Position, string Type) Global Native

;/* GetRandomSceneWithAnyActionForTarget
* * returns a random scene applicable for the actors with any of a list of actions of a target
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: Position, the index of the action target in the scene
* * @param: Types, an array of action types
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomSceneWithAnyActionForTarget(Actor[] Actors, int Position, string[] Types) Global Native

;/* GetRandomSceneWithAnyActionForTargetCSV
* * same as GetRandomSceneWithAnyActionForTarget, except types are passed as csv-string
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: Position, the index of the action target in the scene
* * @param: Types, a csv-string of action types
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomSceneWithAnyActionForTargetCSV(Actor[] Actors, int Position, string Types) Global Native

;/* GetRandomSceneWithAllActionsForTarget
* * returns a random scene applicable for the actors with all of a list of actions of a target
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: Position, the index of the action target in the scene
* * @param: Types, an array of action types
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomSceneWithAllActionsForTarget(Actor[] Actors, int Position, string[] Types) Global Native

;/* GetRandomSceneWithAllActionsForTargetCSV
* * same as GetRandomSceneWithAllActionsForTarget, except types are passed as csv-string
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: Position, the index of the action target in the scene
* * @param: Types, a csv-string of action types
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomSceneWithAllActionsForTargetCSV(Actor[] Actors, int Position, string Types) Global Native


;/* GetRandomFurnitureSceneWithActionForTarget
* * returns a random furniture scene applicable for the actors with an action of a target
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: FurnitureType, the type of furniture for the scene
* * @param: Position, the index of the action target in the scene
* * @param: Type, the action type
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomFurnitureSceneWithActionForTarget(Actor[] Actors, string FurnitureType, int Position, string Type) Global Native

;/* GetRandomFurnitureSceneWithAnyActionForTarget
* * returns a random furniture scene applicable for the actors with any of a list of actions of a target
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: FurnitureType, the type of furniture for the scene
* * @param: Position, the index of the action target in the scene
* * @param: Types, an array of action types
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomFurnitureSceneWithAnyActionForTarget(Actor[] Actors, string FurnitureType, int Position, string[] Types) Global Native

;/* GetRandomFurnitureSceneWithAnyActionForTargetCSV
* * same as GetRandomFurnitureSceneWithAnyActionForTarget, except types are passed as csv-string
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: FurnitureType, the type of furniture for the scene
* * @param: Position, the index of the action target in the scene
* * @param: Types, a csv-string of action types
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomFurnitureSceneWithAnyActionForTargetCSV(Actor[] Actors, string FurnitureType, int Position, string Types) Global Native

;/* GetRandomFurnitureSceneWithAllActionsForTarget
* * returns a random furniture scene applicable for the actors with all of a list of actions of a target
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: FurnitureType, the type of furniture for the scene
* * @param: Position, the index of the action target in the scene
* * @param: Types, an array of action types
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomFurnitureSceneWithAllActionsForTarget(Actor[] Actors, string FurnitureType, int Position, string[] Types) Global Native

;/* GetRandomFurnitureSceneWithAllActionsForTargetCSV
* * same as GetRandomFurnitureSceneWithAllActionsForTarget, except types are passed as csv-string
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: FurnitureType, the type of furniture for the scene
* * @param: Position, the index of the action target in the scene
* * @param: Types, a csv-string of action types
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomFurnitureSceneWithAllActionsForTargetCSV(Actor[] Actors, string FurnitureType, int Position, string Types) Global Native


; ██████╗ ██╗   ██╗     █████╗  ██████╗████████╗██╗ ██████╗ ███╗   ██╗     █████╗  ██████╗████████╗ ██████╗ ██████╗      █████╗ ███╗   ██╗██████╗     ████████╗ █████╗ ██████╗  ██████╗ ███████╗████████╗
; ██╔══██╗╚██╗ ██╔╝    ██╔══██╗██╔════╝╚══██╔══╝██║██╔═══██╗████╗  ██║    ██╔══██╗██╔════╝╚══██╔══╝██╔═══██╗██╔══██╗    ██╔══██╗████╗  ██║██╔══██╗    ╚══██╔══╝██╔══██╗██╔══██╗██╔════╝ ██╔════╝╚══██╔══╝
; ██████╔╝ ╚████╔╝     ███████║██║        ██║   ██║██║   ██║██╔██╗ ██║    ███████║██║        ██║   ██║   ██║██████╔╝    ███████║██╔██╗ ██║██║  ██║       ██║   ███████║██████╔╝██║  ███╗█████╗     ██║   
; ██╔══██╗  ╚██╔╝      ██╔══██║██║        ██║   ██║██║   ██║██║╚██╗██║    ██╔══██║██║        ██║   ██║   ██║██╔══██╗    ██╔══██║██║╚██╗██║██║  ██║       ██║   ██╔══██║██╔══██╗██║   ██║██╔══╝     ██║   
; ██████╔╝   ██║       ██║  ██║╚██████╗   ██║   ██║╚██████╔╝██║ ╚████║    ██║  ██║╚██████╗   ██║   ╚██████╔╝██║  ██║    ██║  ██║██║ ╚████║██████╔╝       ██║   ██║  ██║██║  ██║╚██████╔╝███████╗   ██║   
; ╚═════╝    ╚═╝       ╚═╝  ╚═╝ ╚═════╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝    ╚═╝  ╚═╝ ╚═════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝    ╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝        ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝   ╚═╝   

;/* GetRandomSceneWithActionForActorAndTarget
* * returns a random scene applicable for the actors with an action of an actor and a target
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: ActorPosition, the index of the action actor in the scene
* * @param: TargetPosition, the index of the action target in the scene
* * @param: Type, the action type
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomSceneWithActionForActorAndTarget(Actor[] Actors, int ActorPosition, int TargetPosition, string Type) Global Native

;/* GetRandomSceneWithAnyActionForActorAndTarget
* * returns a random scene applicable for the actors with any of a list of actions of an actor and a target
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: ActorPosition, the index of the action actor in the scene
* * @param: TargetPosition, the index of the action target in the scene
* * @param: Types, an array of action types
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomSceneWithAnyActionForActorAndTarget(Actor[] Actors, int ActorPosition, int TargetPosition, string[] Types) Global Native

;/* GetRandomSceneWithAnyActionForActorAndTargetCSV
* * same as GetRandomSceneWithAnyActionForActorAndTarget, except types are passed as csv-string
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: ActorPosition, the index of the action actor in the scene
* * @param: TargetPosition, the index of the action target in the scene
* * @param: Types, a csv-string of action types
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomSceneWithAnyActionForActorAndTargetCSV(Actor[] Actors, int ActorPosition, int TargetPosition, string Types) Global Native

;/* GetRandomSceneWithAllActionsForActorAndTarget
* * returns a random scene applicable for the actors with all of a list of actions of an actor and a target
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: ActorPosition, the index of the action actor in the scene
* * @param: TargetPosition, the index of the action target in the scene
* * @param: Types, an array of action types
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomSceneWithAllActionsForActorAndTarget(Actor[] Actors, int ActorPosition, int TargetPosition, string[] Types) Global Native

;/* GetRandomSceneWithAllActionsForActorAndTargetCSV
* * same as GetRandomSceneWithAllActionsForActorAndTarget, except types are passed as csv-string
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: ActorPosition, the index of the action actor in the scene
* * @param: TargetPosition, the index of the action target in the scene
* * @param: Types, a csv-string of action types
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomSceneWithAllActionsForActorAndTargetCSV(Actor[] Actors, int ActorPosition, int TargetPosition, string Types) Global Native


;/* GetRandomFurnitureSceneWithActionForActorAndTarget
* * returns a random furniture scene applicable for the actors with an action of an actor and a target
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: FurnitureType, the type of furniture for the scene
* * @param: ActorPosition, the index of the action actor in the scene
* * @param: TargetPosition, the index of the action target in the scene
* * @param: Type, the action type
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomFurnitureSceneWithActionForActorAndTarget(Actor[] Actors, string FurnitureType, int ActorPosition, int TargetPosition, string Type) Global Native

;/* GetRandomFurnitureSceneWithAnyActionForActorAndTarget
* * returns a random furniture scene applicable for the actors with any of a list of actions of an actor and a target
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: FurnitureType, the type of furniture for the scene
* * @param: ActorPosition, the index of the action actor in the scene
* * @param: TargetPosition, the index of the action target in the scene
* * @param: Types, an array of action types
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomFurnitureSceneWithAnyActionForActorAndTarget(Actor[] Actors, string FurnitureType, int ActorPosition, int TargetPosition, string[] Types) Global Native

;/* GetRandomFurnitureSceneWithAnyActionForActorAndTargetCSV
* * same as GetRandomFurnitureSceneWithAnyActionForActorAndTarget, except types are passed as csv-string
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: FurnitureType, the type of furniture for the scene
* * @param: ActorPosition, the index of the action actor in the scene
* * @param: TargetPosition, the index of the action target in the scene
* * @param: Types, a csv-string of action types
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomFurnitureSceneWithAnyActionForActorAndTargetCSV(Actor[] Actors, string FurnitureType, int ActorPosition, int TargetPosition, string Types) Global Native

;/* GetRandomFurnitureSceneWithAllActionsForActorAndTarget
* * returns a random furniture scene applicable for the actors with all of a list of actions of an actor and a target
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: FurnitureType, the type of furniture for the scene
* * @param: ActorPosition, the index of the action actor in the scene
* * @param: TargetPosition, the index of the action target in the scene
* * @param: Types, an array of action types
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomFurnitureSceneWithAllActionsForActorAndTarget(Actor[] Actors, string FurnitureType, int ActorPosition, int TargetPosition, string[] Types) Global Native

;/* GetRandomFurnitureSceneWithAllActionsForActorAndTargetCSV
* * same as GetRandomFurnitureSceneWithAllActionsForActorAndTarget, except types are passed as csv-string
* *
* * @param: Actors, the actors the check scene conditions against
* * @param: FurnitureType, the type of furniture for the scene
* * @param: ActorPosition, the index of the action actor in the scene
* * @param: TargetPosition, the index of the action target in the scene
* * @param: Types, a csv-string of action types
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomFurnitureSceneWithAllActionsForActorAndTargetCSV(Actor[] Actors, string FurnitureType, int ActorPosition, int TargetPosition, string Types) Global Native


; ██████╗ ██╗   ██╗    ███████╗██╗   ██╗██████╗ ███████╗██████╗ ██╗      ██████╗  █████╗ ██████╗ 
; ██╔══██╗╚██╗ ██╔╝    ██╔════╝██║   ██║██╔══██╗██╔════╝██╔══██╗██║     ██╔═══██╗██╔══██╗██╔══██╗
; ██████╔╝ ╚████╔╝     ███████╗██║   ██║██████╔╝█████╗  ██████╔╝██║     ██║   ██║███████║██║  ██║
; ██╔══██╗  ╚██╔╝      ╚════██║██║   ██║██╔═══╝ ██╔══╝  ██╔══██╗██║     ██║   ██║██╔══██║██║  ██║
; ██████╔╝   ██║       ███████║╚██████╔╝██║     ███████╗██║  ██║███████╗╚██████╔╝██║  ██║██████╔╝
; ╚═════╝    ╚═╝       ╚══════╝ ╚═════╝ ╚═╝     ╚══════╝╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚═════╝ 

;/* GetRandomSceneSuperloadCSV
* * returns a random scene matching the given conditions
* * parameters given as "" will be ignored for condition checks
* * 
* * I don't expect a lot of people to fully understand this just from the documentation, it is way too big and complex for that
* * so don't hesitate to join the OStim NG Discord (discord.gg/https://discord.gg/BnT5JQXynT) and ask for help in the ostim-dev channel
* *
* * @param: Actors, an array of actors to check scene conditions on
* * @param: FurnitureType, the furniture type of the scene, "" means it's a no-furniture-scene
* * @param: AnySceneTag, a csv-string of tags, the scene needs to have at least one of these
* * @param: AllSceneTags, a csv-string of tags, the scene needs to have all of these
* * @param: SceneTagWhitelist, a csv-string of tags, the scene needs to have only these
* * @param: SceneTagBlacklist, a csv-string of tags, the scene needs to have none of these
* * @param: AnyActorTagForAny, a csv-string of lists of tags, at least one actor needs to have at least one tag of their respective list
* * @param: AnyActorTagForAll, a csv-string of lists of tags, all actors need to have at least one tag of their respective list
* * @param: AllActorTagsForAny, a csv-string of lists of tags, at least one actor needs to have all tags of their respective list
* * @param: AllActorTagsForAll, a csv-string of lists of tags, all actors need to have all tags of their respective list
* * @param: ActorTagWhitelistForAny, a csv-string of lists of tags, at least one actor needs to have only tags of their respective list
* * @param: ActorTagWhitelistForAll, a csv-string of lists of tags, all actors need to have only tags of their respective list
* * @param: ActorTagBlacklistForAny, a csv-string of lists of tags, at least one actor needs to have no tag of their respective list
* * @param: ActorTagBlacklistForAll, a csv-string of lists of tags, all actors need to have no tag of their respective list
* * @param: AnyActionType, a csv-string of action types, the scene needs to have at least one of these
* * @param: AnyActionActor, a csv-string of lists of indices, the actor of AnyActionType needs to be in their respective list
* * @param: AnyActionTarget, a csv-string of lists of indices, the target of AnyActionType needs to be in their respective list
* * @param: AnyActionPerformer, a csv-string of lists of indices, the performer of AnyActionType needs to be in their respective list
* * @param: AnyActionMateAny, a csv-string of lists of indices, a mate of AnyActionType needs to be in their respective list
* * @param: AnyActionMateAll, a csv-string of lists of indices, all mates of AnyActionType need to be in their respective list
* * @param: AnyActionParticipantAny, a csv-string of lists of indices, a participant of AnyActionType needs to be in their respective list
* * @param: AnyActionParticipantAll, a csv-string of lists of indices, all participants of AnyActionType need to be in their respective list
* * @param: AllActionTypes, a csv-string of action types, the scene needs to have all of these
* * @param: AllActionActors, a csv-string of lists of indices, the actors of AllActionTypes need to be in their respective list
* * @param: AllActionTargets, a csv-string of lists of indices, the targets of AllActionTypes need to be in their respective list
* * @param: AllActionPerformers, a csv-string of lists of indices, the performers of AllActionTypes need to be in their respective list
* * @param: AllActionMatesAny, a csv-string of lists of indices, AllActionTypes need to have at least one mate in all of the respective lists
* * @param: AllActionMatesAll, a csv-string of lists of indices, AllActionTypes need to have all mates in all of the respective lists
* * @param: AllActionParticipantsAny, a csv-string of lists of indices, AllActionTypes need to have at least one participant in all of the respective lists
* * @param: AllActionParticipantsAll, a csv-string of lists of indices, AllActionTypes need to have all mates in all of the respective lists
* * @param: ActionWhitelistTypes, a csv-string of action types, the scene needs to have only these
* * @param: ActionWhitelistActors, a csv-string of lists of indices, the actors of ActionWhitelistTypes need to be in their respective list
* * @param: ActionWhitelistTargets, a csv-string of lists of indices, the targets of ActionWhitelistTypes need to be in their respective list
* * @param: ActionWhitelistPerformers, a csv-string of lists of indices, the performers of ActionWhitelistTypes need to be in their respective list
* * @param: ActionWhitelistMatesAny, a csv-string of lists of indices, ActionWhitelistTypes need to have at least one mate in their respective list
* * @param: ActionWhitelistMatesAll, a csv-string of lists of indices, ActionWhitelistTypes need to have all mates in their respective list
* * @param: ActionWhitelistParticipantsAny, a csv-string of lists of indices, ActionWhitelistTypes need to have at least one participant in their respective list
* * @param: ActionWhitelistParticipantsAll, a csv-string of lists of indices, ActionWhitelistTypes need to have all participants in their respective list
* * @param: ActionBlacklistTypes, a csv-string of action types, the scene needs to have none of these
* * @param: ActionBlacklistActors, a csv-string of lists of indices, ActionBlacklistTypes are limited to actions with actors in the respective list
* * @param: ActionBlacklistTargets, a csv-string of lists of indices, ActionBlacklistTypes are limited to actions with targets in the respective list
* * @param: ActionBlacklistPerformers, a csv-string of lists of indices, ActionBlacklistTypes are limited to actions with performers in the respective list
* * @param: ActionBlacklistMatesAny, a csv-string of lists of indices, ActionBlacklistTypes are limited to actions with at least one mate in the respective list
* * @param: ActionBlacklistMatesAll, a csv-string of lists of indices, ActionBlacklistTypes are limited to actions with all mates in the respective list
* * @param: ActionBlacklistParticipantsAny, a csv-string of lists of indices, ActionBlacklistTypes are limited to actions with at least one performer in the respective list
* * @param: ActionBlacklistParticipantsAll, a csv-string of lists of indices, ActionBlacklistTypes are limited to actions with all performers in the respective list
* *
* * @return: the id of a matching random scene, "" if no scene was found
*/;
string Function GetRandomSceneSuperloadCSV(Actor[] Actors, string FurnitureType = "", string AnySceneTag = "", string AllSceneTags = "", string SceneTagWhitelist = "", string SceneTagBlacklist = "", string AnyActorTagForAny = "", string AnyActorTagForAll = "", string AllActorTagsForAny = "", string AllActorTagsForAll = "", string ActorTagWhitelistForAny = "", string ActorTagWhitelistForAll = "", string ActorTagBlacklistForAny = "", string ActorTagBlacklistForAll = "", string AnyActionType = "", string AnyActionActor = "", string AnyActionTarget = "", string AnyActionPerformer = "", string AnyActionMatesAny = "", string AnyActionMatesAll = "", string AnyActionParticipantAny = "", string AnyActionParticipantAll = "", string AllActionTypes = "", string AllActionActors = "", string AllActionTargets = "", string AllActionPerformers = "", string AllActionMatesAny = "", string AllActionMatesAll = "", string AllActionParticipantsAny = "", string AllActionParticipantsAll = "", string ActionWhitelistTypes = "", string ActionWhitelistActors = "", string ActionWhitelistTargets = "", string ActionWhitelistPerformers = "", string ActionWhitelistMatesAny = "", string ActionWhitelistMatesAll = "", string ActionWhitelistParticipantsAny = "", string ActionWhitelistParticipantsAll = "", string ActionBlacklistTypes = "", string ActionBlacklistActors = "", string ActionBlacklistTargets = "", string ActionBlacklistPerformers = "", string ActionBlacklistMatesAny = "", string ActionBlacklistMatesAll= "", string ActionBlacklistParticipantsAny = "", string ActionBlacklistParticipantsAll = "") Global Native