;/* OMetadata
* * collection of native functions refering to scene metadata
* *
* * there are sadly a few things with similar names here because I didn't think properly about it when I first created it :c (sorry)
* * so when it comes to the term "actor" there are three things it can mean depending on context
* * 1) a Skyrim actor (as in the reference to the PC or an NPC), this is not used in this script at all
* * 2) a scene actor, this refers to a record of the "actors" list in the scene file
* * 3) an action actor, this refers to the actor property of a record of the "actions" list in the scene file (which is just an int)
* * I tried to always use either the term "scene actor" or "action actor" to make it clear which one a specific function is referring to
* *
* * all functions taking lists of parameters have two versions:
* * the regular version takes an array (for example ["tag1", "tag2", "tag3"])
* * the CSV version takes a csv-string, CSV stands for comma separated value (for example "tag1,tag2,tag3")
* *
* * some functions need to return lists of lists and therefore only have CSV versions
* * to separate lists semicoli are used (for example "tag1,tag2,tag3;tag3,tag4")
* *
* * for easier CSV-string handling use the OCSV.psc script
*/;
ScriptName OMetadata

;  ██████╗ ███████╗███╗   ██╗███████╗██████╗  █████╗ ██╗     
; ██╔════╝ ██╔════╝████╗  ██║██╔════╝██╔══██╗██╔══██╗██║     
; ██║  ███╗█████╗  ██╔██╗ ██║█████╗  ██████╔╝███████║██║     
; ██║   ██║██╔══╝  ██║╚██╗██║██╔══╝  ██╔══██╗██╔══██║██║     
; ╚██████╔╝███████╗██║ ╚████║███████╗██║  ██║██║  ██║███████╗
;  ╚═════╝ ╚══════╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝

;/* GetName
* * gets the name of the scene
* *
* * required API version: 7.3.4a (0x07030041)
* *
* * @param: Id, the id of the scene
* *
* * @return: the name of the scene
*/;
string Function GetName(string Id) Global Native

;/* ScenesToNames
* * turns a list of scene ids into a list of their display names
* *
* * required API version: 7.3.4a (0x07030041)
* *
* * @param: Ids, the ids of the scenes
* *
* * @return: the names of the scenes
*/;
string[] Function ScenesToNames(string[] Ids) Global Native

;/* IsTransition
* * checks if the scene is a transition
* *
* * @param: Id, the id of the scene
* *
* * @return: true if the scene is a transition, otherwise false
*/;
bool Function IsTransition(string Id) Global Native

;/* GetDefaultSpeed
* * returns the index of the default speed of the scene
* * this is usually 1 if the scene has an idle speed and 0 if it doesn't
* *
* * @param: Id, the id if the scene
* *
* * @return: the index of the default speed
*/;
int Function GetDefaultSpeed(string Id) Global Native

;/* GetMaxSpeed
* * returns the index of the fastest speed of the scene
* *
* * @param: Id, the id of the scene
* *
* * @return: the index of the fastest speed
*/;
int Function GetMaxSpeed(string Id) Global Native

;/* GetActorCount
* * returns the actor count of the scene
* *
* * @param: Id, the id of the scene
* *
* * @return: the actor count
*/;
int Function GetActorCount(string Id) Global Native

;/* GetAnimationId
* * returns the id of the animation of a speed
* * note: this is the generic id, you still have to add _0, _1, etc. to get the actual animation events to send
* *
* * @param: Id, the id of the scene
* * @param: Index, the index of the speed
* *
* * @return: the animation id
*/;
string Function GetAnimationId(string Id, int Index) Global Native

;/* HasRequirement
* * checks if the scene actor requires the requirement
* *
* * required API version: 7.3 (0x07030000)
* *
* * @param: Id, the id of the scene
* * @param: Position, the index of the actor in the scene
* * @param: Requirement, the requirement to check for
* *
* * @return: true if the scene actor requires the requirement, otherwise false
*/;
bool Function HasRequirement(string Id, int Position, string Requirement) Global Native

;/* HasAnyRequirement
* * checks if the scene actor requires at least one of the requirements
* *
* * required API version: 7.3 (0x07030000)
* *
* * @param: Id, the id of the scene
* * @param: Position, the index of the actor in the scene
* * @param: Requirements, an array of requirements to check for
* *
* * @return: true if the scene actor requires at least one of the requirements, otherwise false
*/;
bool Function HasAnyRequirement(string Id, int Position, string[] Requirements) Global Native

;/* HasAnyRequirementCSV
* * same as HasAnyRequirement, except requirements are passed as a csv-string
* *
* * required API version: 7.3 (0x07030000)
* *
* * @param: Id, the id of the scene
* * @param: Position, the index of the actor in the scene
* * @param: Requirements, a csv-string of requirements to check for
* *
* * @return: true if the scene actor requires at least one of the requirements, otherwise false
*/;
bool Function HasAnyRequirementCSV(string Id, int Position, string Requirements) Global Native

;/* HasAllRequirements
* * checks if the scene actor requires all of the requirements
* *
* * required API version: 7.3 (0x07030000)
* *
* * @param: Id, the id of the scene
* * @param: Position, the index of the actor in the scene
* * @param: Requirements, an array of requirements to check for
* *
* * @return: true if the scene actor requires all of the requirements, otherwise false
*/;
bool Function HasAllRequirements(string Id, int Position, string[] Requirements) Global Native

;/* HasAllRequirementsCSV
* * same as HasAllRequirements, except requirements are passed as a csv-string
* *
* * required API version: 7.3 (0x07030000)
* *
* * @param: Id, the id of the scene
* * @param: Position, the index of the actor in the scene
* * @param: Requirements, an array of requirements to check for
* *
* * @return: true if the scene actor requires all of the requirements, otherwise false
*/;
bool Function HasAllRequirementsCSV(string Id, int Position, string Requirements) Global Native


; ███╗   ██╗ █████╗ ██╗   ██╗██╗ ██████╗  █████╗ ████████╗██╗ ██████╗ ███╗   ██╗
; ████╗  ██║██╔══██╗██║   ██║██║██╔════╝ ██╔══██╗╚══██╔══╝██║██╔═══██╗████╗  ██║
; ██╔██╗ ██║███████║██║   ██║██║██║  ███╗███████║   ██║   ██║██║   ██║██╔██╗ ██║
; ██║╚██╗██║██╔══██║╚██╗ ██╔╝██║██║   ██║██╔══██║   ██║   ██║██║   ██║██║╚██╗██║
; ██║ ╚████║██║  ██║ ╚████╔╝ ██║╚██████╔╝██║  ██║   ██║   ██║╚██████╔╝██║ ╚████║
; ╚═╝  ╚═══╝╚═╝  ╚═╝  ╚═══╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝

;/* GetAutoTransitionForActor
* * returns the auto transition of the respective type for the scene actor
* *
* * @param: Id, the id of the scene
* * @param: Position, the index of the actor in the scene
* * @param: Type, the type of the transition
* *
* * @return: the scene id of the transition destination, or "" if it does not have one
*/;
string Function GetAutoTransitionForActor(string Id, int Position, string Type) Global Native


; ████████╗ █████╗  ██████╗ ███████╗
; ╚══██╔══╝██╔══██╗██╔════╝ ██╔════╝
;    ██║   ███████║██║  ███╗███████╗
;    ██║   ██╔══██║██║   ██║╚════██║
;    ██║   ██║  ██║╚██████╔╝███████║
;    ╚═╝   ╚═╝  ╚═╝ ╚═════╝ ╚══════╝

;/* GetSceneTags
* * returns all tags for a scene
* *
* * @param: Id, the id of the scene
* *
* * @return: an array containing all the tags of the scene
*/;
string[] Function GetSceneTags(string Id) Global Native

;/* HasSceneTag
* * checks if a scene has a tag
* *
* * @param: Id, the id of the scene
* * @param: Tag, the tag
* *
* * @return: true if the scene has the tag, otherwise false
*/;
bool Function HasSceneTag(string Id, string Tag) Global Native

;/* HasAnySceneTag
* * checks if a scene has at least one of a list of tags
* *
* * @param: Id, the id of the scene
* * @param: Tags, an array of tags
* *
* * @return: true if the scene has at least one of the tags, otherwise false
*/;
bool Function HasAnySceneTag(string Id, string[] Tags) Global Native

;/* HasAnySceneTagCSV
* * same as HasAnySceneTag, except tags are passed as a csv-string
* *
* * @param: Id, the id of the scene
* * @param: Tags, a csv-string of tags
* *
* * @return: true if the scene has at least one of the tags, otherwise false
*/;
bool Function HasAnySceneTagCSV(string Id, string Tags) Global Native

;/* HasAllSceneTags
* * checks if a scene has all of a list of tags
* *
* * @param: Id, the id of the scene
* * @param: Tags, an array with all the tags to check for
* *
* * @return: true if the scene has all the tags, otherwise false
*/;
bool Function HasAllSceneTags(string Id, string[] Tags) Global Native

;/* HasAllSceneTagsCSV
* * same as HasAllSceneTags, except tags are passed as a csv-string
* *
* * @param: Id, the id of the scene
* * @param: Tags, a csv-string of tags
* *
* * @return: true if the scene has all the tags, otherwise false
*/;
bool Function HasAllSceneTagsCSV(string Id, string Tags) Global Native

;/* GetSceneTagOverlap
* * returns all scene tags that overlap with the list
* *
* * @param: Id, the id of the scene
* * @param: Tags, an array with all the tags to check for
* *
* * @return: an array of tags that appear in the scene tags and the given list
*/;
string[] Function GetSceneTagOverlap(string Id, string[] Tags) Global Native

;/* GetSceneTagOverlapCSV
* * same as GetSceneTagOverlap, except tags are passed as a csv-string
* *
* * @param: Id, the id of the scene
* * @param: Tags, a csv-string of tags
* *
* * @return: an array of tags that appear in the scene tags and the given list
*/;
string[] Function GetSceneTagOverlapCSV(string Id, string Tags) Global Native


;/* GetActorTags
* * returns all tags for a scene actor
* *
* * @param: Id, the id of the scene
* * @param: Position, the index of the actor in the scene
* *
* * @return: an array containing all the tags for the actor
*/;
string[] Function GetActorTags(string Id, int Position) Global Native

;/* HasActorTag
* * checks if a scene actor has a tag
* *
* * @param: Id, the id of the scene
* * @param: Position, the index of the actor in the scene
* * @param: Tag, the tag
* *
* * @return: true if the actor has the tag, otherwise false
*/;
bool Function HasActorTag(string Id, int Position, string Tag) Global Native

;/* HasAnyActorTag
* * checks if an scene actor has at least one of a list of tags
* *
* * @param: Id, the id of the scene
* * @param: Position, the index of the actor in the scene
* * @param: Tags, an array of tags
* *
* * @return: true if the actor has at least one of the tags, otherwise false
*/;
bool Function HasAnyActorTag(string Id, int Position, string[] Tags) Global Native

;/* HasAnyActorTagCSV
* * same as HasAnyActorTags, except tags are passed as a csv-string
* *
* * @param: Id, the id of the scene
* * @param: Position, the index of the actor in the scene
* * @param: Tags, a csv-string of tags
* *
* * @return: true if the actor has at least one of the tags, otherwise false
*/;
bool Function HasAnyActorTagCSV(string Id, int Position, string Tags) Global Native

;/* HasAllActorTags
* * checks if a scene actor has all of a list of tags
* *
* * @param: Id, the id of the scene
* * @param: Position, the index of the actor in the scene
* * @param: Tags, an array of tags
* *
* * @return: true if the actor has all the tags, otherwise false
*/;
bool Function HasAllActorTags(string Id, int Position, string[] Tags) Global Native

;/* HasAllActorTagsCSV
* * same as HasAllActorTags, except tags are passed as a csv-string
* *
* * @param: Id, the id of the scene
* * @param: Position, the index of the actor in the scene
* * @param: Tags, a csv-string of tags
* *
* * @return: true if the actor has all the tags, otherwise false
*/;
bool Function HasAllActorTagsCSV(string Id, int Position, string Tags) Global Native

;/* GetActorTagOverlap
* * returns all scene actor tags that overlap with the list
* *
* * @param: Id, the id of the scene
* * @param: Position, the index of the actor in the scene
* * @param: Tags, an array with all the tags to check for
* *
* * @return: an array of tags that appear in the actor tags and the given list
*/;
string[] Function GetActorTagOverlap(string Id, int Position, string[] Tags) Global Native

;/* GetActorTagOverlapCSV
* * same as GetActorTagOverlap, except tags are passed as a csv-string
* *
* * @param: Id, the id of the scene
* * @param: Position, the index of the actor in the scene
* * @param: Tags, a csv-string of tags
* *
* * @return: an array of tags that appear in the actor tags and the given list
*/;
string[] Function GetActorTagOverlapCSV(string Id, int Position, string Tags) Global Native


;  █████╗  ██████╗████████╗██╗ ██████╗ ███╗   ██╗███████╗
; ██╔══██╗██╔════╝╚══██╔══╝██║██╔═══██╗████╗  ██║██╔════╝
; ███████║██║        ██║   ██║██║   ██║██╔██╗ ██║███████╗
; ██╔══██║██║        ██║   ██║██║   ██║██║╚██╗██║╚════██║
; ██║  ██║╚██████╗   ██║   ██║╚██████╔╝██║ ╚████║███████║
; ╚═╝  ╚═╝ ╚═════╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝

;/* HasActions
* * checks if the scene has at least one action
* *
* * @param: Id, the id of the scene
* *
* * @return: true if the scene contains action, otherwise false
*/;
bool Function HasActions(string Id) Global Native

;/* FindAction
* * returns the first occurance of an action in a scene
* *
* * @param: Id, the id of the scene
* * @param: Type, the action type
* *
* * @return: the index of the first occurance of the action type if it occurs, otherwise -1
*/;
int Function FindAction(string Id, string Type) Global Native

;/* FindAnyAction
* * returns the first occurance of any of a list of actions in a scene
* *
* * @param: Id, the id of the scene
* * @param: Types, an array of action types
* *
* * @return: the index of the first occurance of any of the action types if one occurs, otherwise -1
*/;
int Function FindAnyAction(string Id, string[] Types) Global Native

;/* FindAnyActionCSV
* * same as FindAnyAction, excepts types are passed as a csv-string
* *
* * @param: Id, the id of the scene
* * @param: Types, a csv-string of action types
* *
* * @return: the index of the first occurance of any of the action types if one occurs, otherwise -1
*/;
int Function FindAnyActionCSV(string Id, string Types) Global Native

;/* FindActions
* * returns all occurances of an action in a scene
* *
* * @param: Id, the id of the scene
* * @param: Type, the action type
* * 
* * @return: an array of the indices of all occurances of the action type
*/;
int[] Function FindActions(string Id, string Type) Global Native

;/* FindAllActions
* * returns all occurances of any of a list of actions in a scene
* *
* * @param: Id, the id of the scene
* * @param: Types, an array of action types
* *
* * @return: an array of the indices of all occurances of any of the action types
*/;
int[] Function FindAllActions(string Id, string[] Types) Global Native

;/* FindAllActionsCSV
* * same as FindAllActions, except types are passed as a csv-string
* *
* * @param: Id, the id of the scene
* * @param: Types, a csv-string of action types
* *
* * @return: an array of the indices of all occurances of any of the action types
*/;
int[] Function FindAllActionsCSV(string Id, string Types) Global Native


;  █████╗  ██████╗████████╗██╗ ██████╗ ███╗   ██╗███████╗    ██████╗ ██╗   ██╗     █████╗  ██████╗████████╗ ██████╗ ██████╗ 
; ██╔══██╗██╔════╝╚══██╔══╝██║██╔═══██╗████╗  ██║██╔════╝    ██╔══██╗╚██╗ ██╔╝    ██╔══██╗██╔════╝╚══██╔══╝██╔═══██╗██╔══██╗
; ███████║██║        ██║   ██║██║   ██║██╔██╗ ██║███████╗    ██████╔╝ ╚████╔╝     ███████║██║        ██║   ██║   ██║██████╔╝
; ██╔══██║██║        ██║   ██║██║   ██║██║╚██╗██║╚════██║    ██╔══██╗  ╚██╔╝      ██╔══██║██║        ██║   ██║   ██║██╔══██╗
; ██║  ██║╚██████╗   ██║   ██║╚██████╔╝██║ ╚████║███████║    ██████╔╝   ██║       ██║  ██║╚██████╗   ██║   ╚██████╔╝██║  ██║
; ╚═╝  ╚═╝ ╚═════╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝    ╚═════╝    ╚═╝       ╚═╝  ╚═╝ ╚═════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝

;/* FindActionForActor
* * returns the first occurance of an action from an action actor
* * 
* * @param: Id, the id of the scene
* * @param: Position, the index of the actor in the scene
* * @param: Type, the action type
* *
* * @return: the index of the first occurance of the action type if it occurs, otherwise -1
*/;
int Function FindActionForActor(string Id, int Position, string Type) Global Native

;/* FindAnyActionForActor
* * returns the first occurance of any of a list of actions from an action actor
* *
* * @param: Id, the id of the scene
* * @param: Position, the index of the actor in the scene
* * @param: Types, an array of action types
* * 
* * @return: the index of the first occurance of any of the action types if one occurs, otherwise -1
*/;
int Function FindAnyActionForActor(string Id, int Position, string[] Types) Global Native

;/* FindAnyActionForActorCSV
* * same es FindAnyActionForActor, except types are passed as a csv-string
* *
* * @param: Id, the id of the scene
* * @param: Position, the index of the actor in the scene
* * @param: Types, a csv-string of action types
* * 
* * @return: the index of the first occurance of any of the action types if one occurs, otherwise -1
*/;
int Function FindAnyActionForActorCSV(string Id, int Position, string Types) Global Native

;/* FindActionsForActor
* * returns all occurances of an action from an action actor
* * 
* * @param: Id, the id of the scene
* * @param: Position, the index of the actor in the scene
* * @param: Type, the action type
* *
* * @return: an array of the indices of all occurances of the action type
*/;
int[] Function FindActionsForActor(string Id, int Position, string Type) Global Native

;/* FindAllActionsForActor
* * returns all occurances of any of a list of actions from an action actor
* *
* * @param: Id, the id of the scene
* * @param: Position, the index of the actor in the scene
* * @param: Types, an array of action types
* * 
* * @return: an array of the indices of all occurances of any of the action types
*/;
int[] Function FindAllActionsForActor(string Id, int Position, string[] Types) Global Native

;/* FindAllActionsForActorCSV
* * same es FindAllActionsForActor, except types are passed as a csv-string
* *
* * @param: Id, the id of the scene
* * @param: Position, the index of the actor in the scene
* * @param: Types, a csv-string of action types
* * 
* * @return: an array of the indices of all occurances of any of the action types
*/;
int[] Function FindAllActionsForActorCSV(string Id, int Position, string Types) Global Native


;/* FindActionForActors
* * returns the first occurance of an action from a list of action actors
* * 
* * @param: Id, the id of the scene
* * @param: Positions, an array of indices of the actors in the scene
* * @param: Type, the action type
* *
* * @return: the index of the first occurance of the action type if it occurs, otherwise -1
*/;
int Function FindActionForActors(string Id, int[] Positions, string Type) Global Native

;/* FindActionForActorsCSV
* * same es FindActionForActors, except positions are passed as a csv-string
* * 
* * @param: Id, the id of the scene
* * @param: Positions, a csv-string of indices of the actors in the scene
* * @param: Type, the action type
* *
* * @return: the index of the first occurance of the action type if it occurs, otherwise -1
*/;
int Function FindActionForActorsCSV(string Id, string Positions, string Type) Global Native

;/* FindAnyActionForActors
* * returns the first occurance of any of a list of actions from a list of action actors
* *
* * @param: Id, the id of the scene
* * @param: Positions, an array of indices of the actors in the scene
* * @param: Types, an array of action types
* * 
* * @return: the index of the first occurance of any of the action types if one occurs, otherwise -1
*/;
int Function FindAnyActionForActors(string Id, int[] Positions, string[] Types) Global Native

;/* FindAnyActionForActorsCSV
* * same es FindAnyActionForActors, except positions and types are passed as a csv-string
* * 
* * @param: Id, the id of the scene
* * @param: Positions, a csv-string of indices of the actors in the scene
* * @param: Types, a csv-string of action types
* *
* * @return: the index of the first occurance of the action type if it occurs, otherwise -1
*/;
int Function FindAnyActionForActorsCSV(string Id, string Positions, string Types) Global Native

;/* FindActionsForActors
* * returns all occurances of an action from a list of action actors
* * 
* * @param: Id, the id of the scene
* * @param: Positions, an array of indices of the actors in the scene
* * @param: Type, the action type
* *
* * @return: an array of the indices of all occurances of the action type
*/;
int[] Function FindActionsForActors(string Id, int[] Positions, string Type) Global Native

;/* FindActionsForActorsCSV
* * same es FindActionsForActors, except positions are passed as a csv-string
* * 
* * @param: Id, the id of the scene
* * @param: Positions, a csv-string of indices of the actors in the scene
* * @param: Type, the action type
* *
* * @return: an array of the indices of all occurances of the action type
*/;
int[] Function FindActionsForActorsCSV(string Id, string Positions, string Type) Global Native

;/* FindAllActionsForActors
* * returns all occurances of any of a list of actions from a list of action actors
* *
* * @param: Id, the id of the scene
* * @param: Positions, an array of indices of the actors in the scene
* * @param: Types, an array of action types
* * 
* * @return: an array of the indices of all occurances of any of the action types
*/;
int[] Function FindAllActionsForActors(string Id, int[] Positions, string[] Types) Global Native

;/* FindAllActionsForActorsCSV
* * same es FindAllActionsForActors, except positions and types are passed as a csv-string
* * 
* * @param: Id, the id of the scene
* * @param: Positions, a csv-string of indices of the actors in the scene
* * @param: Types, a csv-string of action types
* *
* * @return: an array of the indices of all occurances of any of the action types
*/;
int[] Function FindAllActionsForActorsCSV(string Id, string Positions, string Types) Global Native


;  █████╗  ██████╗████████╗██╗ ██████╗ ███╗   ██╗███████╗    ██████╗ ██╗   ██╗    ████████╗ █████╗ ██████╗  ██████╗ ███████╗████████╗
; ██╔══██╗██╔════╝╚══██╔══╝██║██╔═══██╗████╗  ██║██╔════╝    ██╔══██╗╚██╗ ██╔╝    ╚══██╔══╝██╔══██╗██╔══██╗██╔════╝ ██╔════╝╚══██╔══╝
; ███████║██║        ██║   ██║██║   ██║██╔██╗ ██║███████╗    ██████╔╝ ╚████╔╝        ██║   ███████║██████╔╝██║  ███╗█████╗     ██║   
; ██╔══██║██║        ██║   ██║██║   ██║██║╚██╗██║╚════██║    ██╔══██╗  ╚██╔╝         ██║   ██╔══██║██╔══██╗██║   ██║██╔══╝     ██║   
; ██║  ██║╚██████╗   ██║   ██║╚██████╔╝██║ ╚████║███████║    ██████╔╝   ██║          ██║   ██║  ██║██║  ██║╚██████╔╝███████╗   ██║   
; ╚═╝  ╚═╝ ╚═════╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝    ╚═════╝    ╚═╝          ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝   ╚═╝                                                                                                                                 

;/* FindActionForTarget
* * returns the first occurance of an action from an action target
* * 
* * @param: Id, the id of the scene
* * @param: Position, the index of the target in the scene
* * @param: Type, the action type
* *
* * @return: the index of the first occurance of the action type if it occurs, otherwise -1
*/;
int Function FindActionForTarget(string Id, int Position, string Type) Global Native

;/* FindAnyActionForTarget
* * returns the first occurance of any of a list of actions from an action target
* *
* * @param: Id, the id of the scene
* * @param: Position, the index of the target in the scene
* * @param: Types, an array of action types
* * 
* * @return: the index of the first occurance of any of the action types if one occurs, otherwise -1
*/;
int Function FindAnyActionForTarget(string Id, int Position, string[] Types) Global Native

;/* FindAnyActionForTargetCSV
* * same as FindAnyActionForTarget, except types are passed as a csv-string
* *
* * @param: Id, the id of the scene
* * @param: Position, the index of the target in the scene
* * @param: Types, a csv-string of action types
* * 
* * @return: the index of the first occurance of any of the action types if one occurs, otherwise -1
*/;
int Function FindAnyActionForTargetCSV(string Id, int Position, string Types) Global Native

;/* FindActionsForTarget
* * returns all occurances of an action from an action target
* * 
* * @param: Id, the id of the scene
* * @param: Position, the index of the target in the scene
* * @param: Type, the action type
* *
* * @return: an array of the indices of all occurances of the action type
*/;
int[] Function FindActionsForTarget(string Id, int Position, string Type) Global Native

;/* FindAllActionsForTarget
* * returns all occurances of any of a list of actions from an action target
* *
* * @param: Id, the id of the scene
* * @param: Position, the index of the target in the scene
* * @param: Types, an array of action types
* * 
* * @return: an array of the indices of all occurances of any of the action types
*/;
int[] Function FindAllActionsForTarget(string Id, int Position, string[] Types) Global Native

;/* FindAllActionsForTargetCSV
* * same as FindAllActionsForTarget, except types are passed as a csv-string
* *
* * @param: Id, the id of the scene
* * @param: Position, the index of the target in the scene
* * @param: Types, a csv-string of action types
* * 
* * @return: an array of the indices of all occurances of any of the action types
*/;
int[] Function FindAllActionsForTargetCSV(string Id, int Position, string Types) Global Native


;/* FindActionForTargets
* * returns the first occurance of an action from a list of action targets
* * 
* * @param: Id, the id of the scene
* * @param: Positions, an array of indices of the targets in the scene
* * @param: Type, the action type
* *
* * @return: the index of the first occurance of the action type if it occurs, otherwise -1
*/;
int Function FindActionForTargets(string Id, int[] Positions, string Type) Global Native

;/* FindActionForTargetsCSV
* * same as FindActionForTargets, except positions are passed as a csv-string
* * 
* * @param: Id, the id of the scene
* * @param: Positions, a csv-string of indices of the targets in the scene
* * @param: Type, the action type
* *
* * @return: the index of the first occurance of the action type if it occurs, otherwise -1
*/;
int Function FindActionForTargetsCSV(string Id, string Positions, string Type) Global Native

;/* FindAnyActionForTargets
* * returns the first occurance of any of a list of actions from a list of action targets
* *
* * @param: Id, the id of the scene
* * @param: Positions, an array of indices of the targets in the scene
* * @param: Types, an array of action types
* * 
* * @return: the index of the first occurance of any of the action types if one occurs, otherwise -1
*/;
int Function FindAnyActionForTargets(string Id, int[] Positions, string[] Types) Global Native

;/* FindAnyActionForTargetsCSV
* * same as FindAnyActionForTargets, except positions and types are passed as a csv-string
* *
* * @param: Id, the id of the scene
* * @param: Positions, a csv-string of indices of the targets in the scene
* * @param: Types, a csv-string of action types
* * 
* * @return: the index of the first occurance of any of the action types if one occurs, otherwise -1
*/;
int Function FindAnyActionForTargetsCSV(string Id, string Positions, string Types) Global Native

;/* FindActionsForTargets
* * returns all occurances of an action from a list of action targets
* * 
* * @param: Id, the id of the scene
* * @param: Positions, an array of indices of the targets in the scene
* * @param: Type, the action type
* *
* * @return: an array of the indices of all occurances of the action type
*/;
int[] Function FindActionsForTargets(string Id, int[] Positions, string Type) Global Native

;/* FindActionsForTargetsCSV
* * same as FindActionsForTargets, exvcept positions are passed as a csv-string
* * 
* * @param: Id, the id of the scene
* * @param: Positions, a csv-string of indices of the targets in the scene
* * @param: Type, the action type
* *
* * @return: an array of the indices of all occurances of the action type
*/;
int[] Function FindActionsForTargetsCSV(string Id, string Positions, string Type) Global Native

;/* FindAllActionsForTargets
* * returns all occurances of any of a list of actions from a list of action targets
* *
* * @param: Id, the id of the scene
* * @param: Positions, an array of indices of the targets in the scene
* * @param: Types, an array of action types
* * 
* * @return: an array of the indices of all occurances of any of the action types
*/;
int[] Function FindAllActionsForTargets(string Id, int[] Positions, string[] Types) Global Native

;/* FindAllActionsForTargetsCSV
* * same as FindAllActionsForTargets, except positions and types are passed as a csv-string
* *
* * @param: Id, the id of the scene
* * @param: Positions, a csv-string of indices of the targets in the scene
* * @param: Types, a csv-string of action types
* * 
* * @return: an array of the indices of all occurances of any of the action types
*/;
int[] Function FindAllActionsForTargetsCSV(string Id, string Positions, string Types) Global Native


;  █████╗  ██████╗████████╗██╗ ██████╗ ███╗   ██╗███████╗    ██████╗ ██╗   ██╗    ██████╗ ███████╗██████╗ ███████╗ ██████╗ ██████╗ ███╗   ███╗███████╗██████╗ 
; ██╔══██╗██╔════╝╚══██╔══╝██║██╔═══██╗████╗  ██║██╔════╝    ██╔══██╗╚██╗ ██╔╝    ██╔══██╗██╔════╝██╔══██╗██╔════╝██╔═══██╗██╔══██╗████╗ ████║██╔════╝██╔══██╗
; ███████║██║        ██║   ██║██║   ██║██╔██╗ ██║███████╗    ██████╔╝ ╚████╔╝     ██████╔╝█████╗  ██████╔╝█████╗  ██║   ██║██████╔╝██╔████╔██║█████╗  ██████╔╝
; ██╔══██║██║        ██║   ██║██║   ██║██║╚██╗██║╚════██║    ██╔══██╗  ╚██╔╝      ██╔═══╝ ██╔══╝  ██╔══██╗██╔══╝  ██║   ██║██╔══██╗██║╚██╔╝██║██╔══╝  ██╔══██╗
; ██║  ██║╚██████╗   ██║   ██║╚██████╔╝██║ ╚████║███████║    ██████╔╝   ██║       ██║     ███████╗██║  ██║██║     ╚██████╔╝██║  ██║██║ ╚═╝ ██║███████╗██║  ██║
; ╚═╝  ╚═╝ ╚═════╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝    ╚═════╝    ╚═╝       ╚═╝     ╚══════╝╚═╝  ╚═╝╚═╝      ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝

;/* FindActionForPerformer
* * returns the first occurance of an action from an action performer
* * 
* * @param: Id, the id of the scene
* * @param: Position, the index of the performer in the scene
* * @param: Type, the action type
* *
* * @return: the index of the first occurance of the action type if it occurs, otherwise -1
*/;
int Function FindActionForPerformer(string Id, int Position, string Type) Global Native

;/* FindAnyActionForPerformer
* * returns the first occurance of any of a list of actions from an action performer
* *
* * @param: Id, the id of the scene
* * @param: Position, the index of the performer in the scene
* * @param: Types, an array of action types
* * 
* * @return: the index of the first occurance of any of the action types if one occurs, otherwise -1
*/;
int Function FindAnyActionForPerformer(string Id, int Position, string[] Types) Global Native

;/* FindAnyActionForPerformerCSV
* * same as FindAnyActionForPerformer, except types are passed as a csv-string
* *
* * @param: Id, the id of the scene
* * @param: Position, the index of the performer in the scene
* * @param: Types, a csv-string of action types
* * 
* * @return: the index of the first occurance of any of the action types if one occurs, otherwise -1
*/;
int Function FindAnyActionForPerformerCSV(string Id, int Position, string Types) Global Native

;/* FindActionsForPerformer
* * returns all occurances of an action from an action performer
* * 
* * @param: Id, the id of the scene
* * @param: Position, the index of the performer in the scene
* * @param: Type, the action type
* *
* * @return: an array of the indices of all occurances of the action type
*/;
int[] Function FindActionsForPerformer(string Id, int Position, string Type) Global Native

;/* FindAllActionsForPerformer
* * returns all occurances of any of a list of actions from an action performer
* *
* * @param: Id, the id of the scene
* * @param: Position, the index of the performer in the scene
* * @param: Types, an array of action types
* * 
* * @return: an array of the indices of all occurances of any of the action types
*/;
int[] Function FindAllActionsForPerformer(string Id, int Position, string[] Types) Global Native

;/* FindAllActionsForPerformerCSV
* * same as FindAllActionsForPerformer, except types are passed as a csv-string
* *
* * @param: Id, the id of the scene
* * @param: Position, the index of the performer in the scene
* * @param: Types, a csv-string of action types
* * 
* * @return: an array of the indices of all occurances of any of the action types
*/;
int[] Function FindAllActionsForPerformerCSV(string Id, int Position, string Types) Global Native


;/* FindActionForPerformers
* * returns the first occurance of an action from a list of action performers
* * 
* * @param: Id, the id of the scene
* * @param: Positions, an array of indices of the performers in the scene
* * @param: Type, the action type
* *
* * @return: the index of the first occurance of the action type if it occurs, otherwise -1
*/;
int Function FindActionForPerformers(string Id, int[] Positions, string Type) Global Native

;/* FindActionForPerformersCSV
* * same as FindActionForPerformers, except positions are passed as a csv-string
* * 
* * @param: Id, the id of the scene
* * @param: Positions, a csv-string of indices of the performers in the scene
* * @param: Type, the action type
* *
* * @return: the index of the first occurance of the action type if it occurs, otherwise -1
*/;
int Function FindActionForPerformersCSV(string Id, string Positions, string Type) Global Native

;/* FindAnyActionForPerformers
* * returns the first occurance of any of a list of actions from a list of action performers
* *
* * @param: Id, the id of the scene
* * @param: Positions, an array of indices of the performers in the scene
* * @param: Types, an array of action types
* * 
* * @return: the index of the first occurance of any of the action types if one occurs, otherwise -1
*/;
int Function FindAnyActionForPerformers(string Id, int[] Positions, string[] Types) Global Native

;/* FindAnyActionForPerformersCSV
* * same as FindAnyActionForPerformers, except positions and types are passed as a csv-string
* *
* * @param: Id, the id of the scene
* * @param: Positions, a csv-string of indices of the performers in the scene
* * @param: Types, a csv-string of action types
* * 
* * @return: the index of the first occurance of any of the action types if one occurs, otherwise -1
*/;
int Function FindAnyActionForPerformersCSV(string Id, string Positions, string Types) Global Native

;/* FindActionsForPerformers
* * returns all occurances of an action from a list of action performers
* * 
* * @param: Id, the id of the scene
* * @param: Positions, an array of indices of the performers in the scene
* * @param: Type, the action type
* *
* * @return: an array of the indices of all occurances of the action type
*/;
int[] Function FindActionsForPerformers(string Id, int[] Positions, string Type) Global Native

;/* FindActionsForPerformersCSV
* * same as FindActionsForPerformers, except positions are passed as a csv-string
* * 
* * @param: Id, the id of the scene
* * @param: Positions, a csv-string of indices of the performers in the scene
* * @param: Type, the action type
* *
* * @return: an array of the indices of all occurances of the action type
*/;
int[] Function FindActionsForPerformersCSV(string Id, string Positions, string Type) Global Native

;/* FindAllActionsForPerformers
* * returns all occurances of any of a list of actions from a list of action performers
* *
* * @param: Id, the id of the scene
* * @param: Positions, an array of indices of the performers in the scene
* * @param: Types, an array of action types
* * 
* * @return: an array of the indices of all occurances of any of the action types
*/;
int[] Function FindAllActionsForPerformers(string Id, int[] Positions, string[] Types) Global Native

;/* FindAllActionsForPerformersCSV
* * same as FindAllActionsForPerformers, except positions and types are passed as a csv-string
* *
* * @param: Id, the id of the scene
* * @param: Positions, a csv-string of indices of the performers in the scene
* * @param: Types, a csv-string of action types
* * 
* * @return: an array of the indices of all occurances of any of the action types
*/;
int[] Function FindAllActionsForPerformersCSV(string Id, string Positions, string Types) Global Native


;  █████╗  ██████╗████████╗██╗ ██████╗ ███╗   ██╗███████╗    ██████╗ ██╗   ██╗     █████╗  ██████╗████████╗ ██████╗ ██████╗      █████╗ ███╗   ██╗██████╗     ████████╗ █████╗ ██████╗  ██████╗ ███████╗████████╗
; ██╔══██╗██╔════╝╚══██╔══╝██║██╔═══██╗████╗  ██║██╔════╝    ██╔══██╗╚██╗ ██╔╝    ██╔══██╗██╔════╝╚══██╔══╝██╔═══██╗██╔══██╗    ██╔══██╗████╗  ██║██╔══██╗    ╚══██╔══╝██╔══██╗██╔══██╗██╔════╝ ██╔════╝╚══██╔══╝
; ███████║██║        ██║   ██║██║   ██║██╔██╗ ██║███████╗    ██████╔╝ ╚████╔╝     ███████║██║        ██║   ██║   ██║██████╔╝    ███████║██╔██╗ ██║██║  ██║       ██║   ███████║██████╔╝██║  ███╗█████╗     ██║   
; ██╔══██║██║        ██║   ██║██║   ██║██║╚██╗██║╚════██║    ██╔══██╗  ╚██╔╝      ██╔══██║██║        ██║   ██║   ██║██╔══██╗    ██╔══██║██║╚██╗██║██║  ██║       ██║   ██╔══██║██╔══██╗██║   ██║██╔══╝     ██║   
; ██║  ██║╚██████╗   ██║   ██║╚██████╔╝██║ ╚████║███████║    ██████╔╝   ██║       ██║  ██║╚██████╗   ██║   ╚██████╔╝██║  ██║    ██║  ██║██║ ╚████║██████╔╝       ██║   ██║  ██║██║  ██║╚██████╔╝███████╗   ██║   
; ╚═╝  ╚═╝ ╚═════╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝    ╚═════╝    ╚═╝       ╚═╝  ╚═╝ ╚═════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝    ╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝        ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝   ╚═╝   

;/* FindActionForActorAndTarget
* * returns the first occurance of an action from an action actor and target
* * 
* * @param: Id, the id of the scene
* * @param: ActorPosition, the index of the actor in the scene
* * @param: TargetPosition, the index of the target in the scene
* * @param: Type, the action type
* *
* * @return: the index of the first occurance of the action type if it occurs, otherwise -1
*/;
int Function FindActionForActorAndTarget(string Id, int ActorPosition, int TargetPosition, string Type) Global Native

;/* FindAnyActionForActorAndTarget
* * returns the first occurance of any of a list of actions from an action actor and target
* *
* * @param: Id, the id of the scene
* * @param: ActorPosition, the index of the actor in the scene
* * @param: TargetPosition, the index of the target in the scene
* * @param: Types, an array of action types
* * 
* * @return: the index of the first occurance of any of the action types if one occurs, otherwise -1
*/;
int Function FindAnyActionForActorAndTarget(string Id, int ActorPosition, int TargetPosition, string[] Types) Global Native

;/* FindAnyActionForActorAndTargetCSV
* * same es FindAnyActionForActorAndTarget, except types are passed as a csv-string
* *
* * @param: Id, the id of the scene
* * @param: ActorPosition, the index of the actor in the scene
* * @param: TargetPosition, the index of the target in the scene
* * @param: Types, a csv-string of action types
* * 
* * @return: the index of the first occurance of any of the action types if one occurs, otherwise -1
*/;
int Function FindAnyActionForActorAndTargetCSV(string Id, int ActorPosition, int TargetPosition, string Types) Global Native

;/* FindActionsForActorAndTarget
* * returns all occurances of an action from an action actor and target
* * 
* * @param: Id, the id of the scene
* * @param: ActorPosition, the index of the actor in the scene
* * @param: TargetPosition, the index of the target in the scene
* * @param: Type, the action type
* *
* * @return: an array of the indices of all occurances of the action type
*/;
int[] Function FindActionsForActorAndTarget(string Id, int ActorPosition, int TargetPosition, string Type) Global Native

;/* FindAllActionsForActorAndTarget
* * returns all occurances of any of a list of actions from an action actor and target
* *
* * @param: Id, the id of the scene
* * @param: ActorPosition, the index of the actor in the scene
* * @param: TargetPosition, the index of the target in the scene
* * @param: Types, an array of action types
* * 
* * @return: an array of the indices of all occurances of any of the action types
*/;
int[] Function FindAllActionsForActorAndTarget(string Id, int ActorPosition, int TargetPosition, string[] Types) Global Native

;/* FindAllActionsForActorAndTargetCSV
* * same es FindAllActionsForActorAndTarget, except types are passed as a csv-string
* *
* * @param: Id, the id of the scene
* * @param: ActorPosition, the index of the actor in the scene
* * @param: TargetPosition, the index of the target in the scene
* * @param: Types, a csv-string of action types
* * 
* * @return: an array of the indices of all occurances of any of the action types
*/;
int[] Function FindAllActionsForActorAndTargetCSV(string Id, int ActorPosition, int TargetPosition, string Types) Global Native


;/* FindActionForActorsAndTargets
* * returns the first occurance of an action from a list of action actors and a list of action targets
* * 
* * @param: Id, the id of the scene
* * @param: ActorPositions, an array of indices of the actors in the scene
* * @param: TargetPositions, an array of indices of the targets in the scene
* * @param: Type, the action type
* *
* * @return: the index of the first occurance of the action type if it occurs, otherwise -1
*/;
int Function FindActionForActorsAndTargets(string Id, int[] ActorPositions, int[] TargetPositions, string Type) Global Native

;/* FindActionForActorsAndTargetsCSV
* * same es FindActionForActorsAndTargets, except positions are passed as a csv-string
* * 
* * @param: Id, the id of the scene
* * @param: ActorPositions, a csv-string of indices of the actors in the scene
* * @param: TargetPositions, a csv-string of indices of the targets in the scene
* * @param: Type, the action type
* *
* * @return: the index of the first occurance of the action type if it occurs, otherwise -1
*/;
int Function FindActionForActorsAndTargetsCSV(string Id, string ActorPositions, string TargetPositions, string Type) Global Native

;/* FindAnyActionForActorsAndTargets
* * returns the first occurance of any of a list of actions from a list of action actors and a list of action targets
* *
* * @param: Id, the id of the scene
* * @param: ActorPositions, an array of indices of the actors in the scene
* * @param: TargetPositions, an array of indices of the targets in the scene
* * @param: Types, an array of action types
* * 
* * @return: the index of the first occurance of any of the action types if one occurs, otherwise -1
*/;
int Function FindAnyActionForActorsAndTargets(string Id, int[] ActorPositions, int[] TargetPositions, string[] Types) Global Native

;/* FindAnyActionForActorsAndTargetsCSV
* * same es FindAnyActionForActorsAndTargets, except positions and types are passed as a csv-string
* * 
* * @param: Id, the id of the scene
* * @param: ActorPositions, a csv-string of indices of the actors in the scene
* * @param: TargetPositions, a csv-string of indices of the targets in the scene
* * @param: Types, a csv-string of action types
* *
* * @return: the index of the first occurance of the action type if it occurs, otherwise -1
*/;
int Function FindAnyActionForActorsAndTargetsCSV(string Id, string ActorPositions, string TargetPositions, string Types) Global Native

;/* FindActionsForActorsAndTargets
* * returns all occurances of an action from a list of action actors and a list of action targets
* * 
* * @param: Id, the id of the scene
* * @param: ActorPositions, an array of indices of the actors in the scene
* * @param: TargetPositions, an array of indices of the targets in the scene
* * @param: Type, the action type
* *
* * @return: an array of the indices of all occurances of the action type
*/;
int[] Function FindActionsForActorsAndTargets(string Id, int[] ActorPositions, int[] TargetPositions, string Type) Global Native

;/* FindActionsForActorsAndTargetsCSV
* * same es FindActionsForActorsAndTargets, except positions are passed as a csv-string
* * 
* * @param: Id, the id of the scene
* * @param: ActorPositions, a csv-string of indices of the actors in the scene
* * @param: TargetPositions, a csv-string of indices of the targets in the scene
* * @param: Type, the action type
* *
* * @return: an array of the indices of all occurances of the action type
*/;
int[] Function FindActionsForActorsAndTargetsCSV(string Id, string ActorPositions, string TargetPositions, string Type) Global Native

;/* FindAllActionsForActorsAndTargets
* * returns all occurances of any of a list of actions from a list of action actors and a list of action targets
* *
* * @param: Id, the id of the scene
* * @param: ActorPositions, an array of indices of the actors in the scene
* * @param: TargetPositions, an array of indices of the targets in the scene
* * @param: Types, an array of action types
* * 
* * @return: an array of the indices of all occurances of any of the action types
*/;
int[] Function FindAllActionsForActorsAndTargets(string Id, int[] ActorPositions, int[] TargetPositions, string[] Types) Global Native

;/* FindAllActionsForActorsAndTargetsCSV
* * same es FindAllActionsForActorsAndTargets, except positions and types are passed as a csv-string
* * 
* * @param: Id, the id of the scene
* * @param: ActorPositions, a csv-string of indices of the actors in the scene
* * @param: TargetPositions, a csv-string of indices of the targets in the scene
* * @param: Types, a csv-string of action types
* *
* * @return: an array of the indices of all occurances of any of the action types
*/;
int[] Function FindAllActionsForActorsAndTargetsCSV(string Id, string ActorPositions, string TargetPositions, string Types) Global Native


;  █████╗  ██████╗████████╗██╗ ██████╗ ███╗   ██╗███████╗    ██████╗ ██╗   ██╗    ███╗   ███╗ █████╗ ████████╗███████╗███████╗
; ██╔══██╗██╔════╝╚══██╔══╝██║██╔═══██╗████╗  ██║██╔════╝    ██╔══██╗╚██╗ ██╔╝    ████╗ ████║██╔══██╗╚══██╔══╝██╔════╝██╔════╝
; ███████║██║        ██║   ██║██║   ██║██╔██╗ ██║███████╗    ██████╔╝ ╚████╔╝     ██╔████╔██║███████║   ██║   █████╗  ███████╗
; ██╔══██║██║        ██║   ██║██║   ██║██║╚██╗██║╚════██║    ██╔══██╗  ╚██╔╝      ██║╚██╔╝██║██╔══██║   ██║   ██╔══╝  ╚════██║
; ██║  ██║╚██████╗   ██║   ██║╚██████╔╝██║ ╚████║███████║    ██████╔╝   ██║       ██║ ╚═╝ ██║██║  ██║   ██║   ███████╗███████║
; ╚═╝  ╚═╝ ╚═════╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝    ╚═════╝    ╚═╝       ╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚══════╝╚══════╝

; a mate is someone who is either the actor or target of an action
                                                                                                                           
;/* FindActionForMate
* * returns the first occurance of an action from an action mate
* * 
* * @param: Id, the id of the scene
* * @param: Position, the index of the mate in the scene
* * @param: Type, the action type
* *
* * @return: the index of the first occurance of the action type if it occurs, otherwise -1
*/;
int Function FindActionForMate(string Id, int Position, string Type) Global Native

;/* FindAnyActionForMate
* * returns the first occurance of any of a list of actions from an action mate
* *
* * @param: Id, the id of the scene
* * @param: Position, the index of the mate in the scene
* * @param: Types, an array of action types
* * 
* * @return: the index of the first occurance of any of the action types if one occurs, otherwise -1
*/;
int Function FindAnyActionForMate(string Id, int Position, string[] Types) Global Native

;/* FindAnyActionForMateCSV
* * same as FindAnyActionForMate, except types are passed as a csv-string
* *
* * @param: Id, the id of the scene
* * @param: Position, the index of the mate in the scene
* * @param: Types, a csv-string of action types
* * 
* * @return: the index of the first occurance of any of the action types if one occurs, otherwise -1
*/;
int Function FindAnyActionForMateCSV(string Id, int Position, string Types) Global Native

;/* FindActionsForMate
* * returns all occurances of an action from an action mate
* * 
* * @param: Id, the id of the scene
* * @param: Position, the index of the mate in the scene
* * @param: Type, the action type
* *
* * @return: an array of the indices of all occurances of the action type
*/;
int[] Function FindActionsForMate(string Id, int Position, string Type) Global Native

;/* FindAllActionsForMate
* * returns all occurances of any of a list of actions from an action mate
* *
* * @param: Id, the id of the scene
* * @param: Position, the index of the mate in the scene
* * @param: Types, an array of action types
* * 
* * @return: an array of the indices of all occurances of any of the action types
*/;
int[] Function FindAllActionsForMate(string Id, int Position, string[] Types) Global Native

;/* FindAllActionsForMateCSV
* * same as FindAllActionsForMate, except types are passed as a csv-string
* *
* * @param: Id, the id of the scene
* * @param: Position, the index of the mate in the scene
* * @param: Types, a csv-string of action types
* * 
* * @return: an array of the indices of all occurances of any of the action types
*/;
int[] Function FindAllActionsForMateCSV(string Id, int Position, string Types) Global Native


;/* FindActionForMatesAny
* * returns the first occurance of an action with at least one action mate in a given list
* * 
* * @param: Id, the id of the scene
* * @param: Positions, an array of indices of the mates in the scene
* * @param: Type, the action type
* *
* * @return: the index of the first occurance of the action type if it occurs, otherwise -1
*/;
int Function FindActionForMatesAny(string Id, int[] Positions, string Type) Global Native

;/* FindActionForMatesAnyCSV
* * same as FindActionForMatesAny, except positions are passed as a csv-string
* * 
* * @param: Id, the id of the scene
* * @param: Positions, a csv-string of indices of the mates in the scene
* * @param: Type, the action type
* *
* * @return: the index of the first occurance of the action type if it occurs, otherwise -1
*/;
int Function FindActionForMatesAnyCSV(string Id, string Positions, string Type) Global Native

;/* FindAnyActionForMatesAny
* * returns the first occurance of any of a list of actions with at least one action mate in a given list
* *
* * @param: Id, the id of the scene
* * @param: Positions, an array of indices of the mates in the scene
* * @param: Types, an array of action types
* * 
* * @return: the index of the first occurance of any of the action types if one occurs, otherwise -1
*/;
int Function FindAnyActionForMatesAny(string Id, int[] Positions, string[] Types) Global Native

;/* FindAnyActionForMatesAnyCSV
* * same as FindAnyActionForMatesAny, except positions and types are passed as a csv-string
* *
* * @param: Id, the id of the scene
* * @param: Positions, a csv-string of indices of the mates in the scene
* * @param: Types, a csv-string of action types
* * 
* * @return: the index of the first occurance of any of the action types if one occurs, otherwise -1
*/;
int Function FindAnyActionForMatesAnyCSV(string Id, string Positions, string Types) Global Native

;/* FindActionsForMatesAny
* * returns all occurances of an action with at least one action mate in a given list
* * 
* * @param: Id, the id of the scene
* * @param: Positions, an array of indices of the mates in the scene
* * @param: Type, the action type
* *
* * @return: an array of the indices of all occurances of the action type
*/;
int[] Function FindActionsForMatesAny(string Id, int[] Positions, string Type) Global Native

;/* FindActionsForMatesAnyCSV
* * same as FindActionsForMatesAny, except positions are passed as a csv-string
* * 
* * @param: Id, the id of the scene
* * @param: Positions, a csv-string of indices of the mates in the scene
* * @param: Type, the action type
* *
* * @return: an array of the indices of all occurances of the action type
*/;
int[] Function FindActionsForMatesAnyCSV(string Id, string Positions, string Type) Global Native

;/* FindAllActionsForMatesAny
* * returns all occurances of any of a list of actions with at least one action mate in a given list
* *
* * @param: Id, the id of the scene
* * @param: Positions, an array of indices of the mates in the scene
* * @param: Types, an array of action types
* * 
* * @return: an array of the indices of all occurances of any of the action types
*/;
int[] Function FindAllActionsForMatesAny(string Id, int[] Positions, string[] Types) Global Native

;/* FindAllActionsForMatesAnyCSV
* * same as FindAllActionsForMatesAny, except positions and types are passed as a csv-string
* *
* * @param: Id, the id of the scene
* * @param: Positions, a csv-string of indices of the mates in the scene
* * @param: Types, a csv-string of action types
* * 
* * @return: an array of the indices of all occurances of any of the action types
*/;
int[] Function FindAllActionsForMatesAnyCSV(string Id, string Positions, string Types) Global Native

;/* FindActionForMatesAll
* * returns the first occurance of an action with all action mates in a given list
* * 
* * @param: Id, the id of the scene
* * @param: Positions, an array of indices of the mates in the scene
* * @param: Type, the action type
* *
* * @return: the index of the first occurance of the action type if it occurs, otherwise -1
*/;
int Function FindActionForMatesAll(string Id, int[] Positions, string Type) Global Native

;/* FindActionForMatesAllCSV
* * same as FindActionForMatesAll, except positions are passed as a csv-string
* * 
* * @param: Id, the id of the scene
* * @param: Positions, a csv-string of indices of the mates in the scene
* * @param: Type, the action type
* *
* * @return: the index of the first occurance of the action type if it occurs, otherwise -1
*/;
int Function FindActionForMatesAllCSV(string Id, string Positions, string Type) Global Native

;/* FindAnyActionForMatesAll
* * returns the first occurance of any of a list of actions with all action mates in a given list
* *
* * @param: Id, the id of the scene
* * @param: Positions, an array of indices of the mates in the scene
* * @param: Types, an array of action types
* * 
* * @return: the index of the first occurance of any of the action types if one occurs, otherwise -1
*/;
int Function FindAnyActionForMatesAll(string Id, int[] Positions, string[] Types) Global Native

;/* FindAnyActionForMatesAllCSV
* * same as FindAnyActionForMatesAll, except positions and types are passed as a csv-string
* *
* * @param: Id, the id of the scene
* * @param: Positions, a csv-string of indices of the mates in the scene
* * @param: Types, a csv-string of action types
* * 
* * @return: the index of the first occurance of any of the action types if one occurs, otherwise -1
*/;
int Function FindAnyActionForMatesAllCSV(string Id, string Positions, string Types) Global Native

;/* FindActionsForMatesAll
* * returns all occurances of an action with all action mates in a given list
* * 
* * @param: Id, the id of the scene
* * @param: Positions, an array of indices of the mates in the scene
* * @param: Type, the action type
* *
* * @return: an array of the indices of all occurances of the action type
*/;
int[] Function FindActionsForMatesAll(string Id, int[] Positions, string Type) Global Native

;/* FindActionsForMatesAllCSV
* * same as FindActionsForMatesAll, except positions are passed as a csv-string
* * 
* * @param: Id, the id of the scene
* * @param: Positions, a csv-string of indices of the mates in the scene
* * @param: Type, the action type
* *
* * @return: an array of the indices of all occurances of the action type
*/;
int[] Function FindActionsForMatesAllCSV(string Id, string Positions, string Type) Global Native

;/* FindAllActionsForMatesAll
* * returns all occurances of any of a list of actions with all action mates in a given list
* *
* * @param: Id, the id of the scene
* * @param: Positions, an array of indices of the mates in the scene
* * @param: Types, an array of action types
* * 
* * @return: an array of the indices of all occurances of any of the action types
*/;
int[] Function FindAllActionsForMatesAll(string Id, int[] Positions, string[] Types) Global Native

;/* FindAllActionsForMatesAllCSV
* * same as FindAllActionsForMatesAll, except positions and types are passed as a csv-string
* *
* * @param: Id, the id of the scene
* * @param: Positions, a csv-string of indices of the mates in the scene
* * @param: Types, a csv-string of action types
* * 
* * @return: an array of the indices of all occurances of any of the action types
*/;
int[] Function FindAllActionsForMatesAllCSV(string Id, string Positions, string Types) Global Native


;  █████╗  ██████╗████████╗██╗ ██████╗ ███╗   ██╗███████╗    ██████╗ ██╗   ██╗    ██████╗  █████╗ ██████╗ ████████╗██╗ ██████╗██╗██████╗  █████╗ ███╗   ██╗████████╗
; ██╔══██╗██╔════╝╚══██╔══╝██║██╔═══██╗████╗  ██║██╔════╝    ██╔══██╗╚██╗ ██╔╝    ██╔══██╗██╔══██╗██╔══██╗╚══██╔══╝██║██╔════╝██║██╔══██╗██╔══██╗████╗  ██║╚══██╔══╝
; ███████║██║        ██║   ██║██║   ██║██╔██╗ ██║███████╗    ██████╔╝ ╚████╔╝     ██████╔╝███████║██████╔╝   ██║   ██║██║     ██║██████╔╝███████║██╔██╗ ██║   ██║   
; ██╔══██║██║        ██║   ██║██║   ██║██║╚██╗██║╚════██║    ██╔══██╗  ╚██╔╝      ██╔═══╝ ██╔══██║██╔══██╗   ██║   ██║██║     ██║██╔═══╝ ██╔══██║██║╚██╗██║   ██║   
; ██║  ██║╚██████╗   ██║   ██║╚██████╔╝██║ ╚████║███████║    ██████╔╝   ██║       ██║     ██║  ██║██║  ██║   ██║   ██║╚██████╗██║██║     ██║  ██║██║ ╚████║   ██║   
; ╚═╝  ╚═╝ ╚═════╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝    ╚═════╝    ╚═╝       ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝╚═╝╚═╝     ╚═╝  ╚═╝╚═╝  ╚═══╝   ╚═╝   

; a participant is someone who is either the actor, target or performer of an action
                                                                                                                           
;/* FindActionForParticipant
* * returns the first occurance of an action from an action participant
* * 
* * @param: Id, the id of the scene
* * @param: Position, the index of the participant in the scene
* * @param: Type, the action type
* *
* * @return: the index of the first occurance of the action type if it occurs, otherwise -1
*/;
int Function FindActionForParticipant(string Id, int Position, string Type) Global Native

;/* FindAnyActionForParticipant
* * returns the first occurance of any of a list of actions from an action participant
* *
* * @param: Id, the id of the scene
* * @param: Position, the index of the participant in the scene
* * @param: Types, an array of action types
* * 
* * @return: the index of the first occurance of any of the action types if one occurs, otherwise -1
*/;
int Function FindAnyActionForParticipant(string Id, int Position, string[] Types) Global Native

;/* FindAnyActionForParticipantCSV
* * same as FindAnyActionForParticipant, except types are passed as a csv-string
* *
* * @param: Id, the id of the scene
* * @param: Position, the index of the participant in the scene
* * @param: Types, a csv-string of action types
* * 
* * @return: the index of the first occurance of any of the action types if one occurs, otherwise -1
*/;
int Function FindAnyActionForParticipantCSV(string Id, int Position, string Types) Global Native

;/* FindActionsForParticipant
* * returns all occurances of an action from an action participant
* * 
* * @param: Id, the id of the scene
* * @param: Position, the index of the participant in the scene
* * @param: Type, the action type
* *
* * @return: an array of the indices of all occurances of the action type
*/;
int[] Function FindActionsForParticipant(string Id, int Position, string Type) Global Native

;/* FindAllActionsForParticipant
* * returns all occurances of any of a list of actions from an action participant
* *
* * @param: Id, the id of the scene
* * @param: Position, the index of the participant in the scene
* * @param: Types, an array of action types
* * 
* * @return: an array of the indices of all occurances of any of the action types
*/;
int[] Function FindAllActionsForParticipant(string Id, int Position, string[] Types) Global Native

;/* FindAllActionsForParticipantCSV
* * same as FindAllActionsForParticipant, except types are passed as a csv-string
* *
* * @param: Id, the id of the scene
* * @param: Position, the index of the participant in the scene
* * @param: Types, a csv-string of action types
* * 
* * @return: an array of the indices of all occurances of any of the action types
*/;
int[] Function FindAllActionsForParticipantCSV(string Id, int Position, string Types) Global Native


;/* FindActionForParticipantsAny
* * returns the first occurance of an action with at least one action participant in a given list
* * 
* * @param: Id, the id of the scene
* * @param: Positions, an array of indices of the participants in the scene
* * @param: Type, the action type
* *
* * @return: the index of the first occurance of the action type if it occurs, otherwise -1
*/;
int Function FindActionForParticipantsAny(string Id, int[] Positions, string Type) Global Native

;/* FindActionForParticipantsAnyCSV
* * same as FindActionForParticipantsAny, except positions are passed as a csv-string
* * 
* * @param: Id, the id of the scene
* * @param: Positions, a csv-string of indices of the participants in the scene
* * @param: Type, the action type
* *
* * @return: the index of the first occurance of the action type if it occurs, otherwise -1
*/;
int Function FindActionForParticipantsAnyCSV(string Id, string Positions, string Type) Global Native

;/* FindAnyActionForParticipantsAny
* * returns the first occurance of any of a list of actions with at least one action participant in a given list
* *
* * @param: Id, the id of the scene
* * @param: Positions, an array of indices of the participants in the scene
* * @param: Types, an array of action types
* * 
* * @return: the index of the first occurance of any of the action types if one occurs, otherwise -1
*/;
int Function FindAnyActionForParticipantsAny(string Id, int[] Positions, string[] Types) Global Native

;/* FindAnyActionForParticipantsAnyCSV
* * same as FindAnyActionForParticipantsAny, except positions and types are passed as a csv-string
* *
* * @param: Id, the id of the scene
* * @param: Positions, a csv-string of indices of the participants in the scene
* * @param: Types, a csv-string of action types
* * 
* * @return: the index of the first occurance of any of the action types if one occurs, otherwise -1
*/;
int Function FindAnyActionForParticipantsAnyCSV(string Id, string Positions, string Types) Global Native

;/* FindActionsForParticipantsAny
* * returns all occurances of an action with at least one action participant in a given list
* * 
* * @param: Id, the id of the scene
* * @param: Positions, an array of indices of the participants in the scene
* * @param: Type, the action type
* *
* * @return: an array of the indices of all occurances of the action type
*/;
int[] Function FindActionsForParticipantsAny(string Id, int[] Positions, string Type) Global Native

;/* FindActionsForParticipantsAnyCSV
* * same as FindActionsForParticipantsAny, except positions are passed as a csv-string
* * 
* * @param: Id, the id of the scene
* * @param: Positions, a csv-string of indices of the participants in the scene
* * @param: Type, the action type
* *
* * @return: an array of the indices of all occurances of the action type
*/;
int[] Function FindActionsForParticipantsAnyCSV(string Id, string Positions, string Type) Global Native

;/* FindAllActionsForParticipantsAny
* * returns all occurances of any of a list of actions with at least one action participant in a given list
* *
* * @param: Id, the id of the scene
* * @param: Positions, an array of indices of the participants in the scene
* * @param: Types, an array of action types
* * 
* * @return: an array of the indices of all occurances of any of the action types
*/;
int[] Function FindAllActionsForParticipantsAny(string Id, int[] Positions, string[] Types) Global Native

;/* FindAllActionsForParticipantsAnyCSV
* * same as FindAllActionsForParticipantsAny, except positions and types are passed as a csv-string
* *
* * @param: Id, the id of the scene
* * @param: Positions, a csv-string of indices of the participants in the scene
* * @param: Types, a csv-string of action types
* * 
* * @return: an array of the indices of all occurances of any of the action types
*/;
int[] Function FindAllActionsForParticipantsAnyCSV(string Id, string Positions, string Types) Global Native

;/* FindActionForParticipantsAll
* * returns the first occurance of an action with all action participants in a given list
* * 
* * @param: Id, the id of the scene
* * @param: Positions, an array of indices of the participants in the scene
* * @param: Type, the action type
* *
* * @return: the index of the first occurance of the action type if it occurs, otherwise -1
*/;
int Function FindActionForParticipantsAll(string Id, int[] Positions, string Type) Global Native

;/* FindActionForParticipantsAllCSV
* * same as FindActionForParticipantsAll, except positions are passed as a csv-string
* * 
* * @param: Id, the id of the scene
* * @param: Positions, a csv-string of indices of the participants in the scene
* * @param: Type, the action type
* *
* * @return: the index of the first occurance of the action type if it occurs, otherwise -1
*/;
int Function FindActionForParticipantsAllCSV(string Id, string Positions, string Type) Global Native

;/* FindAnyActionForParticipantsAll
* * returns the first occurance of any of a list of actions with all action participants in a given list
* *
* * @param: Id, the id of the scene
* * @param: Positions, an array of indices of the participants in the scene
* * @param: Types, an array of action types
* * 
* * @return: the index of the first occurance of any of the action types if one occurs, otherwise -1
*/;
int Function FindAnyActionForParticipantsAll(string Id, int[] Positions, string[] Types) Global Native

;/* FindAnyActionForParticipantsAllCSV
* * same as FindAnyActionForParticipantsAll, except positions and types are passed as a csv-string
* *
* * @param: Id, the id of the scene
* * @param: Positions, a csv-string of indices of the participants in the scene
* * @param: Types, a csv-string of action types
* * 
* * @return: the index of the first occurance of any of the action types if one occurs, otherwise -1
*/;
int Function FindAnyActionForParticipantsAllCSV(string Id, string Positions, string Types) Global Native

;/* FindActionsForParticipantsAll
* * returns all occurances of an action with all action participants in a given list
* * 
* * @param: Id, the id of the scene
* * @param: Positions, an array of indices of the participants in the scene
* * @param: Type, the action type
* *
* * @return: an array of the indices of all occurances of the action type
*/;
int[] Function FindActionsForParticipantsAll(string Id, int[] Positions, string Type) Global Native

;/* FindActionsForParticipantsAllCSV
* * same as FindActionsForParticipantsAll, except positions are passed as a csv-string
* * 
* * @param: Id, the id of the scene
* * @param: Positions, a csv-string of indices of the participants in the scene
* * @param: Type, the action type
* *
* * @return: an array of the indices of all occurances of the action type
*/;
int[] Function FindActionsForParticipantsAllCSV(string Id, string Positions, string Type) Global Native

;/* FindAllActionsForParticipantsAll
* * returns all occurances of any of a list of actions with all action participants in a given list
* *
* * @param: Id, the id of the scene
* * @param: Positions, an array of indices of the participants in the scene
* * @param: Types, an array of action types
* * 
* * @return: an array of the indices of all occurances of any of the action types
*/;
int[] Function FindAllActionsForParticipantsAll(string Id, int[] Positions, string[] Types) Global Native

;/* FindAllActionsForParticipantsAllCSV
* * same as FindAllActionsForParticipantsAll, except positions and types are passed as a csv-string
* *
* * @param: Id, the id of the scene
* * @param: Positions, a csv-string of indices of the participants in the scene
* * @param: Types, a csv-string of action types
* * 
* * @return: an array of the indices of all occurances of any of the action types
*/;
int[] Function FindAllActionsForParticipantsAllCSV(string Id, string Positions, string Types) Global Native


;  █████╗  ██████╗████████╗██╗ ██████╗ ███╗   ██╗    ███████╗██╗   ██╗██████╗ ███████╗██████╗ ██╗      ██████╗  █████╗ ██████╗ 
; ██╔══██╗██╔════╝╚══██╔══╝██║██╔═══██╗████╗  ██║    ██╔════╝██║   ██║██╔══██╗██╔════╝██╔══██╗██║     ██╔═══██╗██╔══██╗██╔══██╗
; ███████║██║        ██║   ██║██║   ██║██╔██╗ ██║    ███████╗██║   ██║██████╔╝█████╗  ██████╔╝██║     ██║   ██║███████║██║  ██║
; ██╔══██║██║        ██║   ██║██║   ██║██║╚██╗██║    ╚════██║██║   ██║██╔═══╝ ██╔══╝  ██╔══██╗██║     ██║   ██║██╔══██║██║  ██║
; ██║  ██║╚██████╗   ██║   ██║╚██████╔╝██║ ╚████║    ███████║╚██████╔╝██║     ███████╗██║  ██║███████╗╚██████╔╝██║  ██║██████╔╝
; ╚═╝  ╚═╝ ╚═════╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝    ╚══════╝ ╚═════╝ ╚═╝     ╚══════╝╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚═════╝ 

;/* FindActionSuperloadCSVv2
* * returns the first occurance of any of a list of actions matching the given conditions
* * parameters given as "" will be ignored for condition checks
* *
* * @param: Id, the id of the scene
* * @param: ActorPositions, a csv-string of indices of the actors in the scene
* * @param: TargetPositions, a csv-string of the indices of the targets in the scene
* * @param: PerformerPositions, a csv-string of the indices of the perfomers in the scene
* * @param: MatePositionsAny, a csv-string of the indices of the mates in the scene, at least one mate needs to be in this list
* * @param: MatePositionsAll, a csv-string of the indices of the mates in the scene, all mates need to be in this list
* * @param: ParticipantPositionsAny, a csv-string of the indices of the participants in the scene, at least one action participant needs to be in this list
* * @param: ParticipantPositionsAll, a csv-string of the indices of the participants in the scene, all action participants need to be in this list
* * @param: Types, a csv-string of action types
* * @param: AnyActionTag, a csv-string of tags, the action needs to have at least one of these
* * @param: AllActionTags, a csv-string of tags, the action needs to have all of these
* * @param: ActionTagWhitelist, a csv-string of tags, the action needs to have only these
* * @param: ActionTagBlacklist, a csv-string of tags, the action needs to have none of these
* * @param: AnyCustomIntRecord, a csv-string of lists of int record keys, actor, target and performer need to have at least one key in their respective list
* * @param: AllCustomIntRecords, a csv-string of lists of int record keys, actor, target and performer need to have all keys in their respective list
* * @param: AnyCustomFloatRecord, a csv-string of lists of float record keys, actor, target and performer need to have at least one key in their respective list
* * @param: AllCustomFloatRecords, a csv-string of lists of float record keys, actor, target and performer need to have all keys in their respective list
* * @param: AnyCustomStringRecord, a csv-string of lists of string record keys, actor, target and performer need to have at least one key in their respective list
* * @param: AllCustomStringRecords, a csv-string of lists of string record keys, actor, target and performer need to have all keys in their respective list
* * @param: AnyCustomIntListRecord, a csv-string of lists of int list record keys, actor, target and performer need to have at least one key in their respective list
* * @param: AllCustomIntListRecords, a csv-string of lists of int list record keys, actor, target and performer need to have all keys in their respective list
* * @param: AnyCustomFloatListRecord, a csv-string of lists of float list record keys, actor, target and performer need to have at least one key in their respective list
* * @param: AllCustomFloatListRecords, a csv-string of lists of float list record keys, actor, target and performer need to have all keys in their respective list
* * @param: AnyCustomStringListRecord, a csv-string of lists of string list record keys, actor, target and performer need to have at least one key in their respective list
* * @param: AllCustomStringListRecords, a csv-string of lists of string list record keys, actor, target and performer need to have all keys in their respective list
* *
* * @return: the index of the first occurance of a matching action
*/;
int Function FindActionSuperloadCSVv2(string Id, string ActorPositions = "", string TargetPositions = "", string PerformerPositions = "", string MatePositionsAny = "", string MatePositionsAll = "", string ParticipantPositionsAny = "", string ParticipantPositionsAll = "", string Types = "", string AnyActionTag = "", string AllActionTags = "", string ActionTagWhitelist = "", string ActionTagBlacklist = "", string AnyCustomIntRecord = "", string AllCustomIntRecords = "", string AnyCustomFloatRecord = "", string allCustomFloatRecords = "", string anyCustomStringRecord = "", string allCustomStringRecords = "", string AnyCustomIntListRecord = "", string AllCustomIntListRecords = "", string AnyCustomFloatListRecord = "", string AllCustomFloatListRecords = "", string AnyCustomStringListRecord = "", string AllCustomStringListRecords = "") Global Native

;/* FindActionsSuperloadCSVv2
* * returns all occurances of any of a list of actions matching the given conditions
* * parameters given as "" will be ignored for condition checks
* *
* * @param: Id, the id of the scene
* * @param: ActorPositions, a csv-string of indices of the actors in the scene
* * @param: TargetPositions, a csv-string of the indices of the targets in the scene
* * @param: PerformerPositions, a csv-string of the indices of the perfomers in the scene
* * @param: MatePositionsAny, a csv-string of the indices of the mates in the scene, at least one mate needs to be in this list
* * @param: MatePositionsAll, a csv-string of the indices of the mates in the scene, all mates need to be in this list
* * @param: ParticipantPositionsAny, a csv-string of the indices of the participants in the scene, at least one action participant needs to be in this list
* * @param: ParticipantPositionsAll, a csv-string of the indices of the participants in the scene, all action participants need to be in this list
* * @param: Types, a csv-string of action types
* * @param: AnyActionTag, a csv-string of tags, the action needs to have at least one of these
* * @param: AllActionTags, a csv-string of tags, the action needs to have all of these
* * @param: ActionTagWhitelist, a csv-string of tags, the action needs to have only these
* * @param: ActionTagBlacklist, a csv-string of tags, the action needs to have none of these
* * @param: AnyCustomIntRecord, a csv-string of lists of int record keys, actor, target and performer need to have at least one key in their respective list
* * @param: AllCustomIntRecords, a csv-string of lists of int record keys, actor, target and performer need to have all keys in their respective list
* * @param: AnyCustomFloatRecord, a csv-string of lists of float record keys, actor, target and performer need to have at least one key in their respective list
* * @param: AllCustomFloatRecords, a csv-string of lists of float record keys, actor, target and performer need to have all keys in their respective list
* * @param: AnyCustomStringRecord, a csv-string of lists of string record keys, actor, target and performer need to have at least one key in their respective list
* * @param: AllCustomStringRecords, a csv-string of lists of string record keys, actor, target and performer need to have all keys in their respective list
* * @param: AnyCustomIntListRecord, a csv-string of lists of int list record keys, actor, target and performer need to have at least one key in their respective list
* * @param: AllCustomIntListRecords, a csv-string of lists of int list record keys, actor, target and performer need to have all keys in their respective list
* * @param: AnyCustomFloatListRecord, a csv-string of lists of float list record keys, actor, target and performer need to have at least one key in their respective list
* * @param: AllCustomFloatListRecords, a csv-string of lists of float list record keys, actor, target and performer need to have all keys in their respective list
* * @param: AnyCustomStringListRecord, a csv-string of lists of string list record keys, actor, target and performer need to have at least one key in their respective list
* * @param: AllCustomStringListRecords, a csv-string of lists of string list record keys, actor, target and performer need to have all keys in their respective list
* *
* * @return: an array of the indices of all occurances of matching actions
*/;
int[] Function FindActionsSuperloadCSVv2(string Id, string ActorPositions = "", string TargetPositions = "", string PerformerPositions = "", string MatePositionsAny = "", string MatePositionsAll = "", string ParticipantPositionsAny = "", string ParticipantPositionsAll = "", string Types = "", string AnyActionTag = "", string AllActionTags = "", string ActionTagWhitelist = "", string ActionTagBlacklist = "", string AnyCustomIntRecord = "", string AllCustomIntRecords = "", string AnyCustomFloatRecord = "", string allCustomFloatRecords = "", string anyCustomStringRecord = "", string allCustomStringRecords = "", string AnyCustomIntListRecord = "", string AllCustomIntListRecords = "", string AnyCustomFloatListRecord = "", string AllCustomFloatListRecords = "", string AnyCustomStringListRecord = "", string AllCustomStringListRecords = "") Global Native


;  █████╗  ██████╗████████╗██╗ ██████╗ ███╗   ██╗    ██████╗ ██████╗  ██████╗ ██████╗ ███████╗██████╗ ████████╗██╗███████╗███████╗
; ██╔══██╗██╔════╝╚══██╔══╝██║██╔═══██╗████╗  ██║    ██╔══██╗██╔══██╗██╔═══██╗██╔══██╗██╔════╝██╔══██╗╚══██╔══╝██║██╔════╝██╔════╝
; ███████║██║        ██║   ██║██║   ██║██╔██╗ ██║    ██████╔╝██████╔╝██║   ██║██████╔╝█████╗  ██████╔╝   ██║   ██║█████╗  ███████╗
; ██╔══██║██║        ██║   ██║██║   ██║██║╚██╗██║    ██╔═══╝ ██╔══██╗██║   ██║██╔═══╝ ██╔══╝  ██╔══██╗   ██║   ██║██╔══╝  ╚════██║
; ██║  ██║╚██████╗   ██║   ██║╚██████╔╝██║ ╚████║    ██║     ██║  ██║╚██████╔╝██║     ███████╗██║  ██║   ██║   ██║███████╗███████║
; ╚═╝  ╚═╝ ╚═════╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝    ╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚══════╝╚═╝  ╚═╝   ╚═╝   ╚═╝╚══════╝╚══════╝

;/* GetActionTypes
* * return all action types for a scene
* *
* * @param: Id, the id of the scene
* *
* * @return: an array containing all the action types for the scene
*/;
string[] Function GetActionTypes(string Id) Global Native

;/* GetActionType
* * returns the action type for an action in a scene
* * this is much faster than GetActionTypes(id)[index]
* *
* * @param: Id, the id of the scene
* * @param: Index, the index of the action
* *
* * @return: the action type
*/;
string Function GetActionType(string Id, int Index) Global Native

;/* GetActionActors
* * returns all actions actors in a scene
* * 
* * @param: Id, the id of the scene
* *
* * @return: an array of the positions in the scene of the actors of all actions
*/;
int[] Function GetActionActors(string Id) Global Native

;/* GetActionActor
* * returns the actor of an action in a scene
* * this is much faster than GetActionActors(id)[index]
* *
* * @param: Id, the id of the scene
* * @param: Index, the index of the action
* *
* * @return: the position in the scene of the actor
*/;
int Function GetActionActor(string Id, int Index) Global Native

;/* GetActionTargets
* * returns all actions targets
* * 
* * @param: Id, the id of the scene
* *
* * @return: an array of the positions in the scene of the targets of all actions
*/;
int[] Function GetActionTargets(string Id) Global Native

;/* GetActionTarget
* * returns the target of an action in a scene
* * this is much faster than GetActionTargets(id)[index]
* *
* * @param: Id, the id of the scene
* * @param: Index, the index of the action
* *
* * @return: the position in the scene of the target
*/;
int Function GetActionTarget(string Id, int Index) Global Native

;/* GetActionActors
* * returns all actions performers
* * 
* * @param: Id, the id of the scene
* *
* * @return: an array of the positions in the scene of the performers of all actions
*/;
int[] Function GetActionPerformers(string Id) Global Native

;/* GetActionPerformer
* * returns the performer of an action in a scene
* * this is much faster than GetActionPerformers(id)[index]
* *
* * @param: Id, the id of the scene
* * @param: Index, the index of the action
* *
* * @return: the position in the scene of the performer
*/;
int Function GetActionPerformer(string Id, int Index) Global Native


;  █████╗  ██████╗████████╗██╗ ██████╗ ███╗   ██╗    ████████╗ █████╗  ██████╗ ███████╗
; ██╔══██╗██╔════╝╚══██╔══╝██║██╔═══██╗████╗  ██║    ╚══██╔══╝██╔══██╗██╔════╝ ██╔════╝
; ███████║██║        ██║   ██║██║   ██║██╔██╗ ██║       ██║   ███████║██║  ███╗███████╗
; ██╔══██║██║        ██║   ██║██║   ██║██║╚██╗██║       ██║   ██╔══██║██║   ██║╚════██║
; ██║  ██║╚██████╗   ██║   ██║╚██████╔╝██║ ╚████║       ██║   ██║  ██║╚██████╔╝███████║
; ╚═╝  ╚═╝ ╚═════╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝       ╚═╝   ╚═╝  ╚═╝ ╚═════╝ ╚══════╝

; unlike scene and actor tags action tags are not defined in the scene file, but in the action file

;/* GetActionTags
* * returns all tags for an action in a scene
* *
* * @param: Id, the id of the scene
* * @param: Index, the index of the action
* *
* * @return: an array containing all tags of the action in the scene
*/;
string[] Function GetActionTags(string Id, int Index) Global Native

;/* GetAllActionsTags
* * returns all tags for all actions in the scene
* * the list will not contain any duplicates if multiple actions have the same tag
* *
* * @param: ID, the id of the scene
* *
* * @return: an array containing all tags of all actions
*/;
string[] Function GetAllActionsTags(string Id) Global Native

;/* HasActionTag
* * checks if an action has a tag
* *
* * @param: Id, the id of the scene
* * @param: Index, the index of the action
* * @param: Tag, the tag
* *
* * @return: true if the action has the tag, otherwise false
*/;
bool Function HasActionTag(string Id, int Index, string Tag) Global Native

;/* HasActionTagOnAny
* * checks if any action in the scene has a tag
* *
* * @param: Id, the id of the scene
* * @param: Tag, the tag
* * 
* * @return: true if any action has the tag, otherwise false
*/;
bool Function HasActionTagOnAny(string Id, string Tag) Global Native

;/* HasAnyActionTag
* * checks if an action has at least one of a list of tags
* *
* * @param: Id, the id of the scene
* * @param: Index, the index of the actor in the scene
* * @param: Tags, an array of tags
* *
* * @return: true if the action has at least one of the tags, otherwise false
*/;
bool Function HasAnyActionTag(string Id, int Index, string[] Tags) Global Native

;/* HasAnyActionTagCSV
* * same as HasAnyActionTag, except tags are passed as a csv-string
* *
* * @param: Id, the id of the scene
* * @param: Index, the index of the action
* * @param: Tags, a csv-string of tags
* *
* * @return: true if the action has at least one of the tags, otherwise false
*/;
bool Function HasAnyActionTagCSV(string Id, int Index, string Tags) Global Native

;/* HasAnyActionTagOnAny
* * checks if any action in the scene has at least one of a list of tags
* *
* * @param Id, the id of the scene
* * @param Tags, an array of tags
* * 
* * @return: true if any action has at least one of the tags, otherwise false
*/;
bool Function HasAnyActionTagOnAny(string Id, string[] Tags) Global Native

;/* HasAnyActionTagOnAnyCSV
* * same as HasAnyActionTagOnAny, except tags are passed as a csv-string
* *
* * @param: id, the id of the scene
* * @param: tags, a csv-string of tags
* *
* * @return: true if any action has at least one of the tags, otherwise false
*/;
bool Function HasAnyActionTagOnAnyCSV(string Id, string Tags) Global Native

;/* HasAllActionTags
* * checks if an action has all of a list of tags
* *
* * @param: Id, the id of the scene
* * @param: Index, the index of the action
* * @param: Tags, an array of tags
* *
* * @return: true if the action has all the tags, otherwise false
*/;
bool Function HasAllActionTags(string Id, int Index, string[] Tags) Global Native

;/* HasAllActionTagsCSV
* * same as HasAllActionTags, except tags are passed as a csv-string
* *
* * @param: Id, the id of the scene
* * @param: Index, the index of the action
* * @param: Tags, a csv-string of tags
* *
* * @return: true if the action has all the tags, otherwise false
*/;
bool Function HasAllActionTagsCSV(string Id, int Index, string Tags) Global Native

;/* HasAllActionTagsOnAny
* * checks if any action in the scene has all of a list of tags
* *
* * @param: Id, the id of the scene
* * @param: Tags, an array of tags
* *
* * @return: true if any action has all of the tags, otherwise false
*/;
bool Function HasAllActionTagsOnAny(string Id, string[] Tags) Global Native

;/* HasAllActionTagsOnAnyCSV
* * same as HasAllActionTagsOnAny, except tags are passed as a csv-string
* * 
* * @param: Id, the id of the scene
* * @param: Tags, a csv-string of tags
* *
* * @return: true if any action has all of the tags, otherwise false
*/;
bool Function HasAllActionTagsOnAnyCSV(string Id, string Tags) Global Native

;/* HasAllActionTagsOverAll
* * checks if all actions in the scene together have all of a list of tags
* *
* * @param: Id, the id of the scene
* * @param: Tags, an array of tags
* *
* * @return: true if all actions together have all of the tags, otherwise false
*/;
bool Function HasAllActionTagsOverAll(string Id, string[] Tags) Global Native

;/* HasAllActionTagsOverAllCSV
* * same as HasAllActionTagsOverAll, except tags are passed as a csv-string
* *
* * @param: Id, the id of the scene
* * @param: Tags, a csv-string of tags
* *
* * @return: true if all actions together have all of the tags, otherwise false
*/;
bool Function HasAllActionTagsOverAllCSV(string Id, string Tags) Global Native

;/* GetActionTagOverlap
* * returns all action tags that overlap with the list
* *
* * @param: Id, the id of the scene
* * @param: Index, the index of the action in the scene
* * @param: Tags, an array with all the tags to check for
* *
* * @return: an array of tags that appear in the action tags and the given list
*/;
string[] Function GetActionTagOverlap(string Id, int Index, string[] Tags) Global Native

;/* GetActionTagOverlapCSV
* * same as GetActionTagOverlap, except tags are passed as a csv-string
* *
* * @param: Id, the id of the scene
* * @param: Index, the index of the action
* * @param: Tags, a csv-string of all the tags to check for
* *
* * @return: an array of tags that appear in the action tags and the given list
*/;
string[] Function GetActionTagOverlapCSV(string Id, int Index, string Tags) Global Native

;/* GetActionTagOverlapOverAll
* * returns all actions tags of all actions that overlap with with the list
* * the list does not contain duplicates if more than one action has the same tag
* *
* * @param: Id, the id of the scene
* * @param: Tags, an array with all the tags to check for
* *
* * @return: an array of tags that appear in any actions tags and the given list
*/;
string[] Function GetActionTagOverlapOverAll(string Id, string[] Tags) Global Native

;/* GetActionTagOverlapOverAllCSV
* * same as GetActioNTagOverlap, except tags are passed as a csv-string
* *
* * @param: Id, the id of the scene
* * @param: Tags, a csv-string of all the tags to check for
* *
* * @return: an array of tags that appear in any actions tags and the given list
*/;
string[] Function GetActionTagOverlapOverAllCSV(string Id, string Tags) Global Native


;  ██████╗██╗   ██╗███████╗████████╗ ██████╗ ███╗   ███╗     █████╗  ██████╗████████╗██╗ ██████╗ ███╗   ██╗     █████╗  ██████╗████████╗ ██████╗ ██████╗     ██████╗  █████╗ ████████╗ █████╗ 
; ██╔════╝██║   ██║██╔════╝╚══██╔══╝██╔═══██╗████╗ ████║    ██╔══██╗██╔════╝╚══██╔══╝██║██╔═══██╗████╗  ██║    ██╔══██╗██╔════╝╚══██╔══╝██╔═══██╗██╔══██╗    ██╔══██╗██╔══██╗╚══██╔══╝██╔══██╗
; ██║     ██║   ██║███████╗   ██║   ██║   ██║██╔████╔██║    ███████║██║        ██║   ██║██║   ██║██╔██╗ ██║    ███████║██║        ██║   ██║   ██║██████╔╝    ██║  ██║███████║   ██║   ███████║
; ██║     ██║   ██║╚════██║   ██║   ██║   ██║██║╚██╔╝██║    ██╔══██║██║        ██║   ██║██║   ██║██║╚██╗██║    ██╔══██║██║        ██║   ██║   ██║██╔══██╗    ██║  ██║██╔══██║   ██║   ██╔══██║
; ╚██████╗╚██████╔╝███████║   ██║   ╚██████╔╝██║ ╚═╝ ██║    ██║  ██║╚██████╗   ██║   ██║╚██████╔╝██║ ╚████║    ██║  ██║╚██████╗   ██║   ╚██████╔╝██║  ██║    ██████╔╝██║  ██║   ██║   ██║  ██║
;  ╚═════╝ ╚═════╝ ╚══════╝   ╚═╝    ╚═════╝ ╚═╝     ╚═╝    ╚═╝  ╚═╝ ╚═════╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝    ╚═╝  ╚═╝ ╚═════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝    ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝

;/* HasCustomActionActorInt
* * checks if the action has a custom int record defined for the action actor
* *
* * @param: Id, the id of the scene
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom int
* *
* * @return: true if the custom int was defined, otherwise false
*/;
bool Function HasCustomActionActorInt(string Id, int Index, string Record) Global Native

;/* GetCustomActionActorInt
* * returns the custom int record defined for the action actor
* *
* * @param: Id, the id of the scene
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom int
* * @param: Fallback, a fallback value to return if no custom int was defined
* *
* * @return: the value of the custom int or the fallback value if none was defined
*/;
int Function GetCustomActionActorInt(string Id, int Index, string Record, int Fallback = 0) Global Native

;/* IsCustomActionActorInt
* * checks if the custom int record defined for the action actor is a specific value
* *
* * @param: Id, the id of the scene
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom int
* * @param: Value, the value to compare the record against
* *
* * @return: true if the custom int is the given value, false if none was defined or it is not the given value
*/;
bool Function IsCustomActionActorInt(string Id, int Index, string Record, int Value) Global Native

;/* HasCustomActionActorFloat
* * checks if the action has a custom float record defined for the action actor
* *
* * @param: Id, the id of the scene
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom float
* *
* * @return: true if the custom float was defined, otherwise false
*/;
bool Function HasCustomActionActorFloat(string Id, int Index, string Record) Global Native

;/* GetCustomActionActorFloat
* * returns the custom float record defined for the action actor
* *
* * @param: Id, the id of the scene
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom float
* * @param: Fallback, a fallback value to return if no custom float was defined
* *
* * @return: the value of the custom float or the fallback value if none was defined
*/;
float Function GetCustomActionActorFloat(string Id, int Index, string Record, float Fallback = 0.0) Global Native

;/* IsCustomActionActorFloat
* * checks if the custom float record defined for the action actor is a specific value
* *
* * @param: Id, the id of the scene
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom float
* * @param: Value, the value to compare the record against
* *
* * @return: true if the custom float is the given value, false if none was defined or it is not the given value
*/;
bool Function IsCustomActionActorFloat(string Id, int Index, string Record, float Value) Global Native

;/* HasCustomActionActorString
* * checks if the action has a custom string record defined for the action actor
* *
* * @param: Id, the id of the scene
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom string
* *
* * @return: true if the custom string was defined, otherwise false
*/;
bool Function HasCustomActionActorString(string Id, int Index, string Record) Global Native

;/* GetCustomActionActorString
* * returns the custom string record defined for the action actor
* *
* * @param: Id, the id of the scene
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom string
* * @param: Fallback, a fallback value to return if no custom string was defined
* *
* * @return: the value of the custom string or the fallback value if none was defined
*/;
string Function GetCustomActionActorString(string Id, int Index, string Record, string Fallback = "") Global Native

;/* IsCustomActionActorString
* * checks if the custom string record defined for the action actor is a specific value
* *
* * @param: Id, the id of the scene
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom string
* * @param: Value, the value to compare the record against
* *
* * @return: true if the custom string is the given value, false if none was defined or it is not the given value
*/;
bool Function IsCustomActionActorString(string Id, int Index, string Record, string Value) Global Native

;/* HasCustomActionActorIntList
* * checks if the action has a custom int list record defined for the action actor
* *
* * @param: Id, the id of the scene
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom int list
* *
* * @return: true if the custom int list was defined, otherwise false
*/;
bool Function HasCustomActionActorIntList(string Id, int Index, string Record) Global Native

;/* GetCustomActionActorIntList
* * returns the custom int list record defined for the action actor
* *
* * @param: Id, the id of the scene
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom int list
* *
* * @return: an array with all custom ints in the list, empty if none was defined
*/;
int[] Function GetCustomActionActorIntList(string Id, int Index, string Record) Global Native

;/* CustomActionActorIntListContains
* * checks if the custom int list record defined for the action actor contains a value
* *
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom int list
* * @param: Value, the value to check for
* *
* * @return: true if the custom int list contains the given value, false if not or none was defined
*/;
bool Function CustomActionActorIntListContains(string Id, int Index, string Record, int Value) Global Native

;/* CustomActionActorIntListContainsAny
* * checks if the custom int list record defined for the action actor contains any of a list of values
* *
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom int list
* * @param: Values, an array of values to check for
* *
* * @return: true if the custom int list contains any of the given values, false if not or none was defined
*/;
bool Function CustomActionActorIntListContainsAny(string Id, int Index, string Record, int[] Values) Global Native

;/* CustomActionActorIntListContainsAnyCSV
* * same as CustomActionActorIntListContainsAny, except values are passed as a csv-string
* *
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom int list
* * @param: Values, a csv-string of values to check for
* *
* * @return: true if the custom int list contains any of the given values, false if not or none was defined
*/;
bool Function CustomActionActorIntListContainsAnyCSV(string Id, int Index, string Record, string Values) Global Native

;/* CustomActionActorIntListContainsAll
* * checks if the custom int list record defined for the action actor contains all of a list of values
* *
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom int list
* * @param: Values, an array of values to check for
* *
* * @return: true if the custom int list contains all of the given values, false if not or none was defined
*/;
bool Function CustomActionActorIntListContainsAll(string Id, int Index, string Record, int[] Values) Global Native

;/* CustomActionActorIntListContainsAllCSV
* * same as CustomActionActorIntListContainsAll, except values are passed as a csv-string
* *
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom int list
* * @param: Values, a csv-string of values to check for
* *
* * @return: true if the custom int list contains all of the given values, false if not or none was defined
*/;
bool Function CustomActionActorIntListContainsAllCSV(string Id, int Index, string Record, string Values) Global Native

;/* GetCustomActionActorIntListOverlap
* * returns all entries of a custom int list defined for the action actor that overlap with the list
* *
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom int list
* * @param: Values, an array of all the values to check for
* *
* * @param: an array of values that appear in the custom int list and the given list, empty if none was defined
*/;
int[] Function GetCustomActionActorIntListOverlap(string Id, int Index, string Record, int[] Values) Global Native

;/* GetCustomActionActorIntListOverlapCSV
* * same as GetCustomActionActorIntListOverlap, except values are passed as a csv-string
* *
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom int list
* * @param: Values, a csv-string of values to check for
* *
* * @param: an array of values that appear in the custom int list and the given list, empty if none was defined
*/;
int[] Function GetCustomActionActorIntListOverlapCSV(string Id, int Index, string Record, string Values) Global Native

;/* HasCustomActionActorFloatList
* * checks if the action has a custom float list record defined for the action actor
* *
* * @param: Id, the id of the scene
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom float list
* *
* * @return: true if the custom float list was defined, otherwise false
*/;
bool Function HasCustomActionActorFloatList(string Id, int Index, string Record) Global Native

;/* GetCustomActionActorFloatList
* * returns the custom float list record defined for the action actor
* *
* * @param: Id, the id of the scene
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom float list
* *
* * @return: an array with all custom floats in the list, empty if none was defined
*/;
float[] Function GetCustomActionActorFloatList(string Id, int Index, string Record) Global Native

;/* CustomActionActorFloatListContains
* * checks if the custom float list record defined for the action actor contains a value
* *
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom float list
* * @param: Value, the value to check for
* *
* * @return: true if the custom float list contains the given value, false if not or none was defined
*/;
bool Function CustomActionActorFloatListContains(string Id, int Index, string Record, float Value) Global Native

;/* CustomActionActorFloatListContainsAny
* * checks if the custom float list record defined for the action actor contains any of a list of values
* *
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom float list
* * @param: Values, an array of values to check for
* *
* * @return: true if the custom float list contains any of the given values, false if not or none was defined
*/;
bool Function CustomActionActorFloatListContainsAny(string Id, int Index, string Record, float[] Values) Global Native

;/* CustomActionActorFloatListContainsAnyCSV
* * same as CustomActionActorFloatListContainsAny, except values are passed as a csv-string
* *
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom float list
* * @param: Values, a csv-string of values to check for
* *
* * @return: true if the custom float list contains any of the given values, false if not or none was defined
*/;
bool Function CustomActionActorFloatListContainsAnyCSV(string Id, int Index, string Record, string Values) Global Native

;/* CustomActionActorFloatListContainsAll
* * checks if the custom float list record defined for the action actor contains all of a list of values
* *
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom float list
* * @param: Values, an array of values to check for
* *
* * @return: true if the custom float list contains all of the given values, false if not or none was defined
*/;
bool Function CustomActionActorFloatListContainsAll(string Id, int Index, string Record, float[] Values) Global Native

;/* CustomActionActorFloatListContainsAllCSV
* * same as CustomActionActorFloatListContainsAll, except values are passed as a csv-string
* *
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom float list
* * @param: Values, a csv-string of values to check for
* *
* * @return: true if the custom float list contains all of the given values, false if not or none was defined
*/;
bool Function CustomActionActorFloatListContainsAllCSV(string Id, int Index, string Record, string Values) Global Native

;/* GetCustomActionActorFloatListOverlap
* * returns all entries of a custom float list defined for the action actor that overlap with the list
* *
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom float list
* * @param: Values, an array of all the values to check for
* *
* * @param: an array of values that appear in the custom float list and the given list, empty if none was defined
*/;
float[] Function GetCustomActionActorFloatListOverlap(string Id, int Index, string Record, float[] Values) Global Native

;/* GetCustomActionActorFloatListOverlapCSV
* * same as GetCustomActionActorFloatListOverlap, except values are passed as a csv-string
* *
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom float list
* * @param: Values, a csv-string of values to check for
* *
* * @param: an array of values that appear in the custom float list and the given list, empty if none was defined
*/;
float[] Function GetCustomActionActorFloatListOverlapCSV(string Id, int Index, string Record, string Values) Global Native

;/* HasCustomActionActorStringList
* * checks if the action has a custom string list record defined for the action actor
* *
* * @param: Id, the id of the scene
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom string list
* *
* * @return: true if the custom string list was defined, otherwise false
*/;
bool Function HasCustomActionActorStringList(string Id, int Index, string Record) Global Native

;/* GetCustomActionActorStringList
* * returns the custom string list record defined for the action actor
* *
* * @param: Id, the id of the scene
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom string list
* *
* * @return: an array with all custom strings in the list, empty if none was defined
*/;
string[] Function GetCustomActionActorStringList(string Id, int Index, string Record) Global Native

;/* CustomActionActorStringListContains
* * checks if the custom string list record defined for the action actor contains a value
* *
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom string list
* * @param: Value, the value to check for
* *
* * @return: true if the custom string list contains the given value, false if not or none was defined
*/;
bool Function CustomActionActorStringListContains(string Id, int Index, string Record, string Value) Global Native

;/* CustomActionActorStringListContainsAny
* * checks if the custom string list record defined for the action actor contains any of a list of values
* *
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom string list
* * @param: Values, an array of values to check for
* *
* * @return: true if the custom string list contains any of the given values, false if not or none was defined
*/;
bool Function CustomActionActorStringListContainsAny(string Id, int Index, string Record, string[] Values) Global Native

;/* CustomActionActorStringListContainsAnyCSV
* * same as CustomActionActorStringListContainsAny, except values are passed as a csv-string
* *
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom string list
* * @param: Values, a csv-string of values to check for
* *
* * @return: true if the custom string list contains any of the given values, false if not or none was defined
*/;
bool Function CustomActionActorStringListContainsAnyCSV(string Id, int Index, string Record, string Values) Global Native

;/* CustomActionActorStringListContainsAll
* * checks if the custom string list record defined for the action actor contains all of a list of values
* *
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom string list
* * @param: Values, an array of values to check for
* *
* * @return: true if the custom string list contains all of the given values, false if not or none was defined
*/;
bool Function CustomActionActorStringListContainsAll(string Id, int Index, string Record, string[] Values) Global Native

;/* CustomActionActorStringListContainsAllCSV
* * same as CustomActionActorStringListContainsAll, except values are passed as a csv-string
* *
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom string list
* * @param: Values, a csv-string of values to check for
* *
* * @return: true if the custom string list contains all of the given values, false if not or none was defined
*/;
bool Function CustomActionActorStringListContainsAllCSV(string Id, int Index, string Record, string Values) Global Native

;/* GetCustomActionActorStringListOverlap
* * returns all entries of a custom string list defined for the action actor that overlap with the list
* *
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom string list
* * @param: Values, an array of all the values to check for
* *
* * @param: an array of values that appear in the custom string list and the given list, empty if none was defined
*/;
string[] Function GetCustomActionActorStringListOverlap(string Id, int Index, string Record, string[] Values) Global Native

;/* GetCustomActionActorFloatListOverlapCSV
* * same as GetCustomActionActorStringListOverlap, except values are passed as a csv-string
* *
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom string list
* * @param: Values, a csv-string of values to check for
* *
* * @param: an array of values that appear in the custom string list and the given list, empty if none was defined
*/;
string[] Function GetCustomActionActorStringListOverlapCSV(string Id, int Index, string Record, string Values) Global Native


;  ██████╗██╗   ██╗███████╗████████╗ ██████╗ ███╗   ███╗     █████╗  ██████╗████████╗██╗ ██████╗ ███╗   ██╗    ████████╗ █████╗ ██████╗  ██████╗ ███████╗████████╗    ██████╗  █████╗ ████████╗ █████╗ 
; ██╔════╝██║   ██║██╔════╝╚══██╔══╝██╔═══██╗████╗ ████║    ██╔══██╗██╔════╝╚══██╔══╝██║██╔═══██╗████╗  ██║    ╚══██╔══╝██╔══██╗██╔══██╗██╔════╝ ██╔════╝╚══██╔══╝    ██╔══██╗██╔══██╗╚══██╔══╝██╔══██╗
; ██║     ██║   ██║███████╗   ██║   ██║   ██║██╔████╔██║    ███████║██║        ██║   ██║██║   ██║██╔██╗ ██║       ██║   ███████║██████╔╝██║  ███╗█████╗     ██║       ██║  ██║███████║   ██║   ███████║
; ██║     ██║   ██║╚════██║   ██║   ██║   ██║██║╚██╔╝██║    ██╔══██║██║        ██║   ██║██║   ██║██║╚██╗██║       ██║   ██╔══██║██╔══██╗██║   ██║██╔══╝     ██║       ██║  ██║██╔══██║   ██║   ██╔══██║
; ╚██████╗╚██████╔╝███████║   ██║   ╚██████╔╝██║ ╚═╝ ██║    ██║  ██║╚██████╗   ██║   ██║╚██████╔╝██║ ╚████║       ██║   ██║  ██║██║  ██║╚██████╔╝███████╗   ██║       ██████╔╝██║  ██║   ██║   ██║  ██║
;  ╚═════╝ ╚═════╝ ╚══════╝   ╚═╝    ╚═════╝ ╚═╝     ╚═╝    ╚═╝  ╚═╝ ╚═════╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝       ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝   ╚═╝       ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝
                                                                                                                                                                                                     

;/* HasCustomActionTargetInt
* * checks if the action has a custom int record defined for the action target
* *
* * @param: Id, the id of the scene
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom int
* *
* * @return: true if the custom int was defined, otherwise false
*/;
bool Function HasCustomActionTargetInt(string Id, int Index, string Record) Global Native

;/* GetCustomActionTargetInt
* * returns the custom int record defined for the action target
* *
* * @param: Id, the id of the scene
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom int
* * @param: Fallback, a fallback value to return if no custom int was defined
* *
* * @return: the value of the custom int or the fallback value if none was defined
*/;
int Function GetCustomActionTargetInt(string Id, int Index, string Record, int Fallback = 0) Global Native

;/* IsCustomActionTargetInt
* * checks if the custom int record defined for the action target is a specific value
* *
* * @param: Id, the id of the scene
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom int
* * @param: Value, the value to compare the record against
* *
* * @return: true if the custom int is the given value, false if none was defined or it is not the given value
*/;
bool Function IsCustomActionTargetInt(string Id, int Index, string Record, int Value) Global Native

;/* HasCustomActionTargetFloat
* * checks if the action has a custom float record defined for the action target
* *
* * @param: Id, the id of the scene
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom float
* *
* * @return: true if the custom float was defined, otherwise false
*/;
bool Function HasCustomActionTargetFloat(string Id, int Index, string Record) Global Native

;/* GetCustomActionTargetFloat
* * returns the custom float record defined for the action target
* *
* * @param: Id, the id of the scene
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom float
* * @param: Fallback, a fallback value to return if no custom float was defined
* *
* * @return: the value of the custom float or the fallback value if none was defined
*/;
float Function GetCustomActionTargetFloat(string Id, int Index, string Record, float Fallback = 0.0) Global Native

;/* IsCustomActionTargetFloat
* * checks if the custom float record defined for the action target is a specific value
* *
* * @param: Id, the id of the scene
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom float
* * @param: Value, the value to compare the record against
* *
* * @return: true if the custom float is the given value, false if none was defined or it is not the given value
*/;
bool Function IsCustomActionTargetFloat(string Id, int Index, string Record, float Value) Global Native

;/* HasCustomActionTargetString
* * checks if the action has a custom string record defined for the action target
* *
* * @param: Id, the id of the scene
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom string
* *
* * @return: true if the custom string was defined, otherwise false
*/;
bool Function HasCustomActionTargetString(string Id, int Index, string Record) Global Native

;/* GetCustomActionTargetString
* * returns the custom string record defined for the action target
* *
* * @param: Id, the id of the scene
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom string
* * @param: Fallback, a fallback value to return if no custom string was defined
* *
* * @return: the value of the custom string or the fallback value if none was defined
*/;
string Function GetCustomActionTargetString(string Id, int Index, string Record, string Fallback = "") Global Native

;/* IsCustomActionTargetString
* * checks if the custom string record defined for the action target is a specific value
* *
* * @param: Id, the id of the scene
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom string
* * @param: Value, the value to compare the record against
* *
* * @return: true if the custom string is the given value, false if none was defined or it is not the given value
*/;
bool Function IsCustomActionTargetString(string Id, int Index, string Record, string Value) Global Native

;/* HasCustomActionTargetIntList
* * checks if the action has a custom int list record defined for the action target
* *
* * @param: Id, the id of the scene
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom int list
* *
* * @return: true if the custom int list was defined, otherwise false
*/;
bool Function HasCustomActionTargetIntList(string Id, int Index, string Record) Global Native

;/* GetCustomActionTargetIntList
* * returns the custom int list record defined for the action target
* *
* * @param: Id, the id of the scene
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom int list
* *
* * @return: an array with all custom ints in the list, empty if none was defined
*/;
int[] Function GetCustomActionTargetIntList(string Id, int Index, string Record) Global Native

;/* CustomActionTargetIntListContains
* * checks if the custom int list record defined for the action target contains a value
* *
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom int list
* * @param: Value, the value to check for
* *
* * @return: true if the custom int list contains the given value, false if not or none was defined
*/;
bool Function CustomActionTargetIntListContains(string Id, int Index, string Record, int Value) Global Native

;/* CustomActionTargetIntListContainsAny
* * checks if the custom int list record defined for the action target contains any of a list of values
* *
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom int list
* * @param: Values, an array of values to check for
* *
* * @return: true if the custom int list contains any of the given values, false if not or none was defined
*/;
bool Function CustomActionTargetIntListContainsAny(string Id, int Index, string Record, int[] Values) Global Native

;/* CustomActionTargetIntListContainsAnyCSV
* * same as CustomActionTargetIntListContainsAny, except values are passed as a csv-string
* *
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom int list
* * @param: Values, a csv-string of values to check for
* *
* * @return: true if the custom int list contains any of the given values, false if not or none was defined
*/;
bool Function CustomActionTargetIntListContainsAnyCSV(string Id, int Index, string Record, string Values) Global Native

;/* CustomActionTargetIntListContainsAll
* * checks if the custom int list record defined for the action target contains all of a list of values
* *
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom int list
* * @param: Values, an array of values to check for
* *
* * @return: true if the custom int list contains all of the given values, false if not or none was defined
*/;
bool Function CustomActionTargetIntListContainsAll(string Id, int Index, string Record, int[] Values) Global Native

;/* CustomActionTargetIntListContainsAllCSV
* * same as CustomActionTargetIntListContainsAll, except values are passed as a csv-string
* *
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom int list
* * @param: Values, a csv-string of values to check for
* *
* * @return: true if the custom int list contains all of the given values, false if not or none was defined
*/;
bool Function CustomActionTargetIntListContainsAllCSV(string Id, int Index, string Record, string Values) Global Native

;/* GetCustomActionTargetIntListOverlap
* * returns all entries of a custom int list defined for the action target that overlap with the list
* *
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom int list
* * @param: Values, an array of all the values to check for
* *
* * @param: an array of values that appear in the custom int list and the given list, empty if none was defined
*/;
int[] Function GetCustomActionTargetIntListOverlap(string Id, int Index, string Record, int[] Values) Global Native

;/* GetCustomActionTargetIntListOverlapCSV
* * same as GetCustomActionTargetIntListOverlap, except values are passed as a csv-string
* *
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom int list
* * @param: Values, a csv-string of values to check for
* *
* * @param: an array of values that appear in the custom int list and the given list, empty if none was defined
*/;
int[] Function GetCustomActionTargetIntListOverlapCSV(string Id, int Index, string Record, string Values) Global Native

;/* HasCustomActionTargetFloatList
* * checks if the action has a custom float list record defined for the action target
* *
* * @param: Id, the id of the scene
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom float list
* *
* * @return: true if the custom float list was defined, otherwise false
*/;
bool Function HasCustomActionTargetFloatList(string Id, int Index, string Record) Global Native

;/* GetCustomActionTargetFloatList
* * returns the custom float list record defined for the action target
* *
* * @param: Id, the id of the scene
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom float list
* *
* * @return: an array with all custom floats in the list, empty if none was defined
*/;
float[] Function GetCustomActionTargetFloatList(string Id, int Index, string Record) Global Native

;/* CustomActionTargetFloatListContains
* * checks if the custom float list record defined for the action target contains a value
* *
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom float list
* * @param: Value, the value to check for
* *
* * @return: true if the custom float list contains the given value, false if not or none was defined
*/;
bool Function CustomActionTargetFloatListContains(string Id, int Index, string Record, float Value) Global Native

;/* CustomActionTargetFloatListContainsAny
* * checks if the custom float list record defined for the action target contains any of a list of values
* *
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom float list
* * @param: Values, an array of values to check for
* *
* * @return: true if the custom float list contains any of the given values, false if not or none was defined
*/;
bool Function CustomActionTargetFloatListContainsAny(string Id, int Index, string Record, float[] Values) Global Native

;/* CustomActionTargetFloatListContainsAnyCSV
* * same as CustomActionTargetFloatListContainsAny, except values are passed as a csv-string
* *
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom float list
* * @param: Values, a csv-string of values to check for
* *
* * @return: true if the custom float list contains any of the given values, false if not or none was defined
*/;
bool Function CustomActionTargetFloatListContainsAnyCSV(string Id, int Index, string Record, string Values) Global Native

;/* CustomActionTargetFloatListContainsAll
* * checks if the custom float list record defined for the action target contains all of a list of values
* *
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom float list
* * @param: Values, an array of values to check for
* *
* * @return: true if the custom float list contains all of the given values, false if not or none was defined
*/;
bool Function CustomActionTargetFloatListContainsAll(string Id, int Index, string Record, float[] Values) Global Native

;/* CustomActionTargetFloatListContainsAllCSV
* * same as CustomActionTargetFloatListContainsAll, except values are passed as a csv-string
* *
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom float list
* * @param: Values, a csv-string of values to check for
* *
* * @return: true if the custom float list contains all of the given values, false if not or none was defined
*/;
bool Function CustomActionTargetFloatListContainsAllCSV(string Id, int Index, string Record, string Values) Global Native

;/* GetCustomActionTargetFloatListOverlap
* * returns all entries of a custom float list defined for the action target that overlap with the list
* *
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom float list
* * @param: Values, an array of all the values to check for
* *
* * @param: an array of values that appear in the custom float list and the given list, empty if none was defined
*/;
float[] Function GetCustomActionTargetFloatListOverlap(string Id, int Index, string Record, float[] Values) Global Native

;/* GetCustomActionTargetFloatListOverlapCSV
* * same as GetCustomActionTargetFloatListOverlap, except values are passed as a csv-string
* *
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom float list
* * @param: Values, a csv-string of values to check for
* *
* * @param: an array of values that appear in the custom float list and the given list, empty if none was defined
*/;
float[] Function GetCustomActionTargetFloatListOverlapCSV(string Id, int Index, string Record, string Values) Global Native

;/* HasCustomActionTargetStringList
* * checks if the action has a custom string list record defined for the action target
* *
* * @param: Id, the id of the scene
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom string list
* *
* * @return: true if the custom string list was defined, otherwise false
*/;
bool Function HasCustomActionTargetStringList(string Id, int Index, string Record) Global Native

;/* GetCustomActionTargetStringList
* * returns the custom string list record defined for the action target
* *
* * @param: Id, the id of the scene
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom string list
* *
* * @return: an array with all custom strings in the list, empty if none was defined
*/;
string[] Function GetCustomActionTargetStringList(string Id, int Index, string Record) Global Native

;/* CustomActionTargetStringListContains
* * checks if the custom string list record defined for the action target contains a value
* *
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom string list
* * @param: Value, the value to check for
* *
* * @return: true if the custom string list contains the given value, false if not or none was defined
*/;
bool Function CustomActionTargetStringListContains(string Id, int Index, string Record, string Value) Global Native

;/* CustomActionTargetStringListContainsAny
* * checks if the custom string list record defined for the action target contains any of a list of values
* *
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom string list
* * @param: Values, an array of values to check for
* *
* * @return: true if the custom string list contains any of the given values, false if not or none was defined
*/;
bool Function CustomActionTargetStringListContainsAny(string Id, int Index, string Record, string[] Values) Global Native

;/* CustomActionTargetStringListContainsAnyCSV
* * same as CustomActionTargetStringListContainsAny, except values are passed as a csv-string
* *
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom string list
* * @param: Values, a csv-string of values to check for
* *
* * @return: true if the custom string list contains any of the given values, false if not or none was defined
*/;
bool Function CustomActionTargetStringListContainsAnyCSV(string Id, int Index, string Record, string Values) Global Native

;/* CustomActionTargetStringListContainsAll
* * checks if the custom string list record defined for the action target contains all of a list of values
* *
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom string list
* * @param: Values, an array of values to check for
* *
* * @return: true if the custom string list contains all of the given values, false if not or none was defined
*/;
bool Function CustomActionTargetStringListContainsAll(string Id, int Index, string Record, string[] Values) Global Native

;/* CustomActionTargetStringListContainsAllCSV
* * same as CustomActionTargetStringListContainsAll, except values are passed as a csv-string
* *
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom string list
* * @param: Values, a csv-string of values to check for
* *
* * @return: true if the custom string list contains all of the given values, false if not or none was defined
*/;
bool Function CustomActionTargetStringListContainsAllCSV(string Id, int Index, string Record, string Values) Global Native

;/* GetCustomActionTargetStringListOverlap
* * returns all entries of a custom string list defined for the action target that overlap with the list
* *
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom string list
* * @param: Values, an array of all the values to check for
* *
* * @param: an array of values that appear in the custom string list and the given list, empty if none was defined
*/;
string[] Function GetCustomActionTargetStringListOverlap(string Id, int Index, string Record, string[] Values) Global Native

;/* GetCustomActionTargetFloatListOverlapCSV
* * same as GetCustomActionTargetStringListOverlap, except values are passed as a csv-string
* *
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom string list
* * @param: Values, a csv-string of values to check for
* *
* * @param: an array of values that appear in the custom string list and the given list, empty if none was defined
*/;
string[] Function GetCustomActionTargetStringListOverlapCSV(string Id, int Index, string Record, string Values) Global Native


;  ██████╗██╗   ██╗███████╗████████╗ ██████╗ ███╗   ███╗     █████╗  ██████╗████████╗██╗ ██████╗ ███╗   ██╗    ██████╗ ███████╗██████╗ ███████╗ ██████╗ ██████╗ ███╗   ███╗███████╗██████╗     ██████╗  █████╗ ████████╗ █████╗ 
; ██╔════╝██║   ██║██╔════╝╚══██╔══╝██╔═══██╗████╗ ████║    ██╔══██╗██╔════╝╚══██╔══╝██║██╔═══██╗████╗  ██║    ██╔══██╗██╔════╝██╔══██╗██╔════╝██╔═══██╗██╔══██╗████╗ ████║██╔════╝██╔══██╗    ██╔══██╗██╔══██╗╚══██╔══╝██╔══██╗
; ██║     ██║   ██║███████╗   ██║   ██║   ██║██╔████╔██║    ███████║██║        ██║   ██║██║   ██║██╔██╗ ██║    ██████╔╝█████╗  ██████╔╝█████╗  ██║   ██║██████╔╝██╔████╔██║█████╗  ██████╔╝    ██║  ██║███████║   ██║   ███████║
; ██║     ██║   ██║╚════██║   ██║   ██║   ██║██║╚██╔╝██║    ██╔══██║██║        ██║   ██║██║   ██║██║╚██╗██║    ██╔═══╝ ██╔══╝  ██╔══██╗██╔══╝  ██║   ██║██╔══██╗██║╚██╔╝██║██╔══╝  ██╔══██╗    ██║  ██║██╔══██║   ██║   ██╔══██║
; ╚██████╗╚██████╔╝███████║   ██║   ╚██████╔╝██║ ╚═╝ ██║    ██║  ██║╚██████╗   ██║   ██║╚██████╔╝██║ ╚████║    ██║     ███████╗██║  ██║██║     ╚██████╔╝██║  ██║██║ ╚═╝ ██║███████╗██║  ██║    ██████╔╝██║  ██║   ██║   ██║  ██║
;  ╚═════╝ ╚═════╝ ╚══════╝   ╚═╝    ╚═════╝ ╚═╝     ╚═╝    ╚═╝  ╚═╝ ╚═════╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝    ╚═╝     ╚══════╝╚═╝  ╚═╝╚═╝      ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝    ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝

;/* HasCustomActionPerformerInt
* * checks if the action has a custom int record defined for the action performer
* *
* * @param: Id, the id of the scene
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom int
* *
* * @return: true if the custom int was defined, otherwise false
*/;
bool Function HasCustomActionPerformerInt(string Id, int Index, string Record) Global Native

;/* GetCustomActionPerformerInt
* * returns the custom int record defined for the action performer
* *
* * @param: Id, the id of the scene
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom int
* * @param: Fallback, a fallback value to return if no custom int was defined
* *
* * @return: the value of the custom int or the fallback value if none was defined
*/;
int Function GetCustomActionPerformerInt(string Id, int Index, string Record, int Fallback = 0) Global Native

;/* IsCustomActionPerformerInt
* * checks if the custom int record defined for the action performer is a specific value
* *
* * @param: Id, the id of the scene
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom int
* * @param: Value, the value to compare the record against
* *
* * @return: true if the custom int is the given value, false if none was defined or it is not the given value
*/;
bool Function IsCustomActionPerformerInt(string Id, int Index, string Record, int Value) Global Native

;/* HasCustomActionPerformerFloat
* * checks if the action has a custom float record defined for the action performer
* *
* * @param: Id, the id of the scene
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom float
* *
* * @return: true if the custom float was defined, otherwise false
*/;
bool Function HasCustomActionPerformerFloat(string Id, int Index, string Record) Global Native

;/* GetCustomActionPerformerFloat
* * returns the custom float record defined for the action performer
* *
* * @param: Id, the id of the scene
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom float
* * @param: Fallback, a fallback value to return if no custom float was defined
* *
* * @return: the value of the custom float or the fallback value if none was defined
*/;
float Function GetCustomActionPerformerFloat(string Id, int Index, string Record, float Fallback = 0.0) Global Native

;/* IsCustomActionPerformerFloat
* * checks if the custom float record defined for the action performer is a specific value
* *
* * @param: Id, the id of the scene
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom float
* * @param: Value, the value to compare the record against
* *
* * @return: true if the custom float is the given value, false if none was defined or it is not the given value
*/;
bool Function IsCustomActionPerformerFloat(string Id, int Index, string Record, float Value) Global Native

;/* HasCustomActionPerformerString
* * checks if the action has a custom string record defined for the action performer
* *
* * @param: Id, the id of the scene
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom string
* *
* * @return: true if the custom string was defined, otherwise false
*/;
bool Function HasCustomActionPerformerString(string Id, int Index, string Record) Global Native

;/* GetCustomActionPerformerString
* * returns the custom string record defined for the action performer
* *
* * @param: Id, the id of the scene
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom string
* * @param: Fallback, a fallback value to return if no custom string was defined
* *
* * @return: the value of the custom string or the fallback value if none was defined
*/;
string Function GetCustomActionPerformerString(string Id, int Index, string Record, string Fallback = "") Global Native

;/* IsCustomActionPerformerString
* * checks if the custom string record defined for the action performer is a specific value
* *
* * @param: Id, the id of the scene
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom string
* * @param: Value, the value to compare the record against
* *
* * @return: true if the custom string is the given value, false if none was defined or it is not the given value
*/;
bool Function IsCustomActionPerformerString(string Id, int Index, string Record, string Value) Global Native

;/* HasCustomActionPerformerIntList
* * checks if the action has a custom int list record defined for the action performer
* *
* * @param: Id, the id of the scene
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom int list
* *
* * @return: true if the custom int list was defined, otherwise false
*/;
bool Function HasCustomActionPerformerIntList(string Id, int Index, string Record) Global Native

;/* GetCustomActionPerformerIntList
* * returns the custom int list record defined for the action performer
* *
* * @param: Id, the id of the scene
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom int list
* *
* * @return: an array with all custom ints in the list, empty if none was defined
*/;
int[] Function GetCustomActionPerformerIntList(string Id, int Index, string Record) Global Native

;/* CustomActionPerformerIntListContains
* * checks if the custom int list record defined for the action performer contains a value
* *
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom int list
* * @param: Value, the value to check for
* *
* * @return: true if the custom int list contains the given value, false if not or none was defined
*/;
bool Function CustomActionPerformerIntListContains(string Id, int Index, string Record, int Value) Global Native

;/* CustomActionPerformerIntListContainsAny
* * checks if the custom int list record defined for the action performer contains any of a list of values
* *
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom int list
* * @param: Values, an array of values to check for
* *
* * @return: true if the custom int list contains any of the given values, false if not or none was defined
*/;
bool Function CustomActionPerformerIntListContainsAny(string Id, int Index, string Record, int[] Values) Global Native

;/* CustomActionPerformerIntListContainsAnyCSV
* * same as CustomActionPerformerIntListContainsAny, except values are passed as a csv-string
* *
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom int list
* * @param: Values, a csv-string of values to check for
* *
* * @return: true if the custom int list contains any of the given values, false if not or none was defined
*/;
bool Function CustomActionPerformerIntListContainsAnyCSV(string Id, int Index, string Record, string Values) Global Native

;/* CustomActionPerformerIntListContainsAll
* * checks if the custom int list record defined for the action performer contains all of a list of values
* *
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom int list
* * @param: Values, an array of values to check for
* *
* * @return: true if the custom int list contains all of the given values, false if not or none was defined
*/;
bool Function CustomActionPerformerIntListContainsAll(string Id, int Index, string Record, int[] Values) Global Native

;/* CustomActionPerformerIntListContainsAllCSV
* * same as CustomActionPerformerIntListContainsAll, except values are passed as a csv-string
* *
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom int list
* * @param: Values, a csv-string of values to check for
* *
* * @return: true if the custom int list contains all of the given values, false if not or none was defined
*/;
bool Function CustomActionPerformerIntListContainsAllCSV(string Id, int Index, string Record, string Values) Global Native

;/* GetCustomActionPerformerIntListOverlap
* * returns all entries of a custom int list defined for the action performer that overlap with the list
* *
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom int list
* * @param: Values, an array of all the values to check for
* *
* * @param: an array of values that appear in the custom int list and the given list, empty if none was defined
*/;
int[] Function GetCustomActionPerformerIntListOverlap(string Id, int Index, string Record, int[] Values) Global Native

;/* GetCustomActionPerformerIntListOverlapCSV
* * same as GetCustomActionPerformerIntListOverlap, except values are passed as a csv-string
* *
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom int list
* * @param: Values, a csv-string of values to check for
* *
* * @param: an array of values that appear in the custom int list and the given list, empty if none was defined
*/;
int[] Function GetCustomActionPerformerIntListOverlapCSV(string Id, int Index, string Record, string Values) Global Native

;/* HasCustomActionPerformerFloatList
* * checks if the action has a custom float list record defined for the action performer
* *
* * @param: Id, the id of the scene
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom float list
* *
* * @return: true if the custom float list was defined, otherwise false
*/;
bool Function HasCustomActionPerformerFloatList(string Id, int Index, string Record) Global Native

;/* GetCustomActionPerformerFloatList
* * returns the custom float list record defined for the action performer
* *
* * @param: Id, the id of the scene
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom float list
* *
* * @return: an array with all custom floats in the list, empty if none was defined
*/;
float[] Function GetCustomActionPerformerFloatList(string Id, int Index, string Record) Global Native

;/* CustomActionPerformerFloatListContains
* * checks if the custom float list record defined for the action performer contains a value
* *
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom float list
* * @param: Value, the value to check for
* *
* * @return: true if the custom float list contains the given value, false if not or none was defined
*/;
bool Function CustomActionPerformerFloatListContains(string Id, int Index, string Record, float Value) Global Native

;/* CustomActionPerformerFloatListContainsAny
* * checks if the custom float list record defined for the action performer contains any of a list of values
* *
* * @param: Id, the id of the scene
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom float list
* * @param: Values, an array of values to check for
* *
* * @return: true if the custom float list contains any of the given values, false if not or none was defined
*/;
bool Function CustomActionPerformerFloatListContainsAny(string Id, int Index, string Record, float[] Values) Global Native

;/* CustomActionPerformerFloatListContainsAnyCSV
* * same as CustomActionPerformerFloatListContainsAny, except values are passed as a csv-string
* *
* * @param: Id, the id of the scene
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom float list
* * @param: Values, a csv-string of values to check for
* *
* * @return: true if the custom float list contains any of the given values, false if not or none was defined
*/;
bool Function CustomActionPerformerFloatListContainsAnyCSV(string Id, int Index, string Record, string Values) Global Native

;/* CustomActionPerformerFloatListContainsAll
* * checks if the custom float list record defined for the action performer contains all of a list of values
* *
* * @param: Id, the id of the scene
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom float list
* * @param: Values, an array of values to check for
* *
* * @return: true if the custom float list contains all of the given values, false if not or none was defined
*/;
bool Function CustomActionPerformerFloatListContainsAll(string Id, int Index, string Record, float[] Values) Global Native

;/* CustomActionPerformerFloatListContainsAllCSV
* * same as CustomActionPerformerFloatListContainsAll, except values are passed as a csv-string
* *
* * @param: Id, the id of the scene
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom float list
* * @param: Values, a csv-string of values to check for
* *
* * @return: true if the custom float list contains all of the given values, false if not or none was defined
*/;
bool Function CustomActionPerformerFloatListContainsAllCSV(string Id, int Index, string Record, string Values) Global Native

;/* GetCustomActionPerformerFloatListOverlap
* * returns all entries of a custom float list defined for the action performer that overlap with the list
* *
* * @param: Id, the id of the scene
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom float list
* * @param: Values, an array of all the values to check for
* *
* * @param: an array of values that appear in the custom float list and the given list, empty if none was defined
*/;
float[] Function GetCustomActionPerformerFloatListOverlap(string Id, int Index, string Record, float[] Values) Global Native

;/* GetCustomActionPerformerFloatListOverlapCSV
* * same as GetCustomActionPerformerFloatListOverlap, except values are passed as a csv-string
* *
* * @param: Id, the id of the scene
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom float list
* * @param: Values, a csv-string of values to check for
* *
* * @param: an array of values that appear in the custom float list and the given list, empty if none was defined
*/;
float[] Function GetCustomActionPerformerFloatListOverlapCSV(string Id, int Index, string Record, string Values) Global Native

;/* HasCustomActionPerformerStringList
* * checks if the action has a custom string list record defined for the action performer
* *
* * @param: Id, the id of the scene
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom string list
* *
* * @return: true if the custom string list was defined, otherwise false
*/;
bool Function HasCustomActionPerformerStringList(string Id, int Index, string Record) Global Native

;/* GetCustomActionPerformerStringList
* * returns the custom string list record defined for the action performer
* *
* * @param: Id, the id of the scene
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom string list
* *
* * @return: an array with all custom strings in the list, empty if none was defined
*/;
string[] Function GetCustomActionPerformerStringList(string Id, int Index, string Record) Global Native

;/* CustomActionPerformerStringListContains
* * checks if the custom string list record defined for the action performer contains a value
* *
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom string list
* * @param: Value, the value to check for
* *
* * @return: true if the custom string list contains the given value, false if not or none was defined
*/;
bool Function CustomActionPerformerStringListContains(string Id, int Index, string Record, string Value) Global Native

;/* CustomActionPerformerStringListContainsAny
* * checks if the custom string list record defined for the action performer contains any of a list of values
* *
* * @param: Id, the id of the scene
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom string list
* * @param: Values, an array of values to check for
* *
* * @return: true if the custom string list contains any of the given values, false if not or none was defined
*/;
bool Function CustomActionPerformerStringListContainsAny(string Id, int Index, string Record, string[] Values) Global Native

;/* CustomActionPerformerStringListContainsAnyCSV
* * same as CustomActionPerformerStringListContainsAny, except values are passed as a csv-string
* *
* * @param: Id, the id of the scene
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom string list
* * @param: Values, a csv-string of values to check for
* *
* * @return: true if the custom string list contains any of the given values, false if not or none was defined
*/;
bool Function CustomActionPerformerStringListContainsAnyCSV(string Id, int Index, string Record, string Values) Global Native

;/* CustomActionPerformerStringListContainsAll
* * checks if the custom string list record defined for the action performer contains all of a list of values
* *
* * @param: Id, the id of the scene
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom string list
* * @param: Values, an array of values to check for
* *
* * @return: true if the custom string list contains all of the given values, false if not or none was defined
*/;
bool Function CustomActionPerformerStringListContainsAll(string Id, int Index, string Record, string[] Values) Global Native

;/* CustomActionPerformerStringListContainsAllCSV
* * same as CustomActionPerformerStringListContainsAll, except values are passed as a csv-string
* *
* * @param: Id, the id of the scene
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom string list
* * @param: Values, a csv-string of values to check for
* *
* * @return: true if the custom string list contains all of the given values, false if not or none was defined
*/;
bool Function CustomActionPerformerStringListContainsAllCSV(string Id, int Index, string Record, string Values) Global Native

;/* GetCustomActionPerformerStringListOverlap
* * returns all entries of a custom string list defined for the action performer that overlap with the list
* *
* * @param: Id, the id of the scene
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom string list
* * @param: Values, an array of all the values to check for
* *
* * @param: an array of values that appear in the custom string list and the given list, empty if none was defined
*/;
string[] Function GetCustomActionPerformerStringListOverlap(string Id, int Index, string Record, string[] Values) Global Native

;/* GetCustomActionPerformerFloatListOverlapCSV
* * same as GetCustomActionPerformerStringListOverlap, except values are passed as a csv-string
* *
* * @param: Id, the id of the scene
* * @param: Index, the index of the action in the scene
* * @param: Record, the record identifier for the custom string list
* * @param: Values, a csv-string of values to check for
* *
* * @param: an array of values that appear in the custom string list and the given list, empty if none was defined
*/;
string[] Function GetCustomActionPerformerStringListOverlapCSV(string Id, int Index, string Record, string Values) Global Native


;  ██████╗██╗   ██╗███████╗████████╗ ██████╗ ███╗   ███╗    ███████╗ ██████╗███████╗███╗   ██╗███████╗     █████╗  ██████╗████████╗ ██████╗ ██████╗     ██████╗  █████╗ ████████╗ █████╗ 
; ██╔════╝██║   ██║██╔════╝╚══██╔══╝██╔═══██╗████╗ ████║    ██╔════╝██╔════╝██╔════╝████╗  ██║██╔════╝    ██╔══██╗██╔════╝╚══██╔══╝██╔═══██╗██╔══██╗    ██╔══██╗██╔══██╗╚══██╔══╝██╔══██╗
; ██║     ██║   ██║███████╗   ██║   ██║   ██║██╔████╔██║    ███████╗██║     █████╗  ██╔██╗ ██║█████╗      ███████║██║        ██║   ██║   ██║██████╔╝    ██║  ██║███████║   ██║   ███████║
; ██║     ██║   ██║╚════██║   ██║   ██║   ██║██║╚██╔╝██║    ╚════██║██║     ██╔══╝  ██║╚██╗██║██╔══╝      ██╔══██║██║        ██║   ██║   ██║██╔══██╗    ██║  ██║██╔══██║   ██║   ██╔══██║
; ╚██████╗╚██████╔╝███████║   ██║   ╚██████╔╝██║ ╚═╝ ██║    ███████║╚██████╗███████╗██║ ╚████║███████╗    ██║  ██║╚██████╗   ██║   ╚██████╔╝██║  ██║    ██████╔╝██║  ██║   ██║   ██║  ██║
;  ╚═════╝ ╚═════╝ ╚══════╝   ╚═╝    ╚═════╝ ╚═╝     ╚═╝    ╚══════╝ ╚═════╝╚══════╝╚═╝  ╚═══╝╚══════╝    ╚═╝  ╚═╝ ╚═════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝    ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝

; scene actors do not directly have custom data, these functions refer to all action custom data ralated to the scene actor

;/* GetCustomSceneActorIntMin
* * gets the minimum custom int that any action has defined for this scene actor
* *
* * @param: Id, the id of the scene
* * @param: Position, the index of the scene actor
* * @param: Record, the record identifier for the custom int
* * @param: Fallback, a fallback value to return if no custom int was defined
* *
* * @return: the minimum of all custom ints defined for the scene actor, or the fallback, if none was defined
*/;
int Function GetCustomSceneActorIntMin(string Id, int Position, string Record, int Fallback = 0) Global Native

;/* GetCustomSceneActorIntMax
* * gets the maximum custom int that any action has defined for this scene actor
* *
* * @param: Id, the id of the scene
* * @param: Position, the index of the scene actor
* * @param: Record, the record identifier for the custom int
* * @param: Fallback, a fallback value to return if no custom int was defined
* *
* * @return: the maximum of all custom ints defined for the scene actor, or the fallback, if none was defined
*/;
int Function GetCustomSceneActorIntMax(string Id, int Position, string Record, int Fallback = 0) Global Native

;/* GetCustomSceneActorIntSum
* * gets the sum of all custom ints that any action has defined for this scene actor
* *
* * @param: Id, the id of the scene
* * @param: Position, the index of the scene actor
* * @param: Record, the record identifier for the custom int
* * @param: StartValue, the start value for the sum
* *
* * @return: the sum of all custom ints defined for the scene actor
*/;
int Function GetCustomSceneActorIntSum(string Id, int Position, string Record, int StartValue = 0) Global Native

;/* GetCustomSceneActorIntProduct
* * gets the product of all custom ints that any action has defined for this scene actor
* *
* * @param: Id, the id of the scene
* * @param: Position, the index of the scene actor
* * @param: Record, the record identifier for the custom int
* * @param: StartValue, the start value for the product
* *
* * @return: the product of all custom ints defined for the scene actor
*/;
int Function GetCustomSceneActorIntProduct(string Id, int Position, string Record, int StartValue = 1) Global Native


;/* GetCustomSceneActorIntMin
* * gets the minimum custom float that any action has defined for this scene actor
* *
* * @param: Id, the id of the scene
* * @param: Position, the index of the scene actor
* * @param: Record, the record identifier for the custom float
* * @param: Fallback, a fallback value to return if no custom float was defined
* *
* * @return: the minimum of all custom floats defined for the scene actor, or the fallback, if none was defined
*/;
float Function GetCustomSceneActorFloatMin(string Id, int Position, string Record, float Fallback = 0.0) Global Native

;/* GetCustomSceneActorIntMax
* * gets the maximum custom float that any action has defined for this scene actor
* *
* * @param: Id, the id of the scene
* * @param: Position, the index of the scene actor
* * @param: Record, the record identifier for the custom float
* * @param: Fallback, a fallback value to return if no custom float was defined
* *
* * @return: the maximum of all custom floats defined for the scene actor, or the fallback, if none was defined
*/;
float Function GetCustomSceneActorFloatMax(string Id, int Position, string Record, float Fallback = 0.0) Global Native

;/* GetCustomSceneActorFloatSum
* * gets the sum of all custom floats that any action has defined for this scene actor
* *
* * @param: Id, the id of the scene
* * @param: Position, the index of the scene actor
* * @param: Record, the record identifier for the custom float
* * @param: StartValue, the start value for the sum
* *
* * @return: the sum of all custom floats defined for the scene actor
*/;
float Function GetCustomSceneActorFloatSum(string Id, int Position, string Record, float StartValue = 0.0) Global Native

;/* GetCustomSceneActorFloatProduct
* * gets the product of all custom floats that any action has defined for this scene actor
* *
* * @param: Id, the id of the scene
* * @param: Position, the index of the scene actor
* * @param: Record, the record identifier for the custom float
* * @param: StartValue, the start value for the product
* *
* * @return: the product of all custom floats defined for the scene actor
*/;
float Function GetCustomSceneActorFloatProduct(string Id, int Position, string Record, float StartValue = 1.0) Global Native

; ██████╗ ███████╗██████╗ ██████╗ ███████╗ ██████╗ █████╗ ████████╗███████╗██████╗ 
; ██╔══██╗██╔════╝██╔══██╗██╔══██╗██╔════╝██╔════╝██╔══██╗╚══██╔══╝██╔════╝██╔══██╗
; ██║  ██║█████╗  ██████╔╝██████╔╝█████╗  ██║     ███████║   ██║   █████╗  ██║  ██║
; ██║  ██║██╔══╝  ██╔═══╝ ██╔══██╗██╔══╝  ██║     ██╔══██║   ██║   ██╔══╝  ██║  ██║
; ██████╔╝███████╗██║     ██║  ██║███████╗╚██████╗██║  ██║   ██║   ███████╗██████╔╝
; ╚═════╝ ╚══════╝╚═╝     ╚═╝  ╚═╝╚══════╝ ╚═════╝╚═╝  ╚═╝   ╚═╝   ╚══════╝╚═════╝ 

; all of these are only here to not break old addons, don't use them in new addons, use whatever they're calling instead

int Function FindActionSuperloadCSV(string Id, string ActorPositions = "", string TargetPositions = "", string PerformerPositions = "", string MatePositionsAny = "", string MatePositionsAll = "", string ParticipantPositionsAny = "", string ParticipantPositionsAll = "", string Types = "")
	Return FindActionSuperloadCSVv2(Id, ActorPositions, TargetPositions, PerformerPositions, MatePositionsAny, MatePositionsAll, ParticipantPositionsAny, ParticipantPositionsAll, Types)
EndFunction

int[] Function FindActionsSuperloadCSV(string Id, string ActorPositions = "", string TargetPositions = "", string PerformerPositions = "", string MatePositionsAny = "", string MatePositionsAll = "", string ParticipantPositionsAny = "", string ParticipantPositionsAll = "", string Types = "")
	Return FindActionsSuperloadCSVv2(Id, ActorPositions, TargetPositions, PerformerPositions, MatePositionsAny, MatePositionsAll, ParticipantPositionsAny, ParticipantPositionsAll, Types)
EndFunction