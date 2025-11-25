;/* OThread
* * collection of methods to modify threads
* * the thread containing the player will always have the ThreadID 0
* * NPC on NPC threads will always have positive ThreadIDs
* *
* * required API Version: 7.0 (29)
*/;
ScriptName OThread

;  ██████╗ ██╗   ██╗██╗ ██████╗██╗  ██╗███████╗████████╗ █████╗ ██████╗ ████████╗
; ██╔═══██╗██║   ██║██║██╔════╝██║ ██╔╝██╔════╝╚══██╔══╝██╔══██╗██╔══██╗╚══██╔══╝
; ██║   ██║██║   ██║██║██║     █████╔╝ ███████╗   ██║   ███████║██████╔╝   ██║
; ██║▄▄ ██║██║   ██║██║██║     ██╔═██╗ ╚════██║   ██║   ██╔══██║██╔══██╗   ██║
; ╚██████╔╝╚██████╔╝██║╚██████╗██║  ██╗███████║   ██║   ██║  ██║██║  ██║   ██║
;  ╚══▀▀═╝  ╚═════╝ ╚═╝ ╚═════╝╚═╝  ╚═╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝

;/* QuickStart
* * starts a new thread without the need of a thread builder, but only limited parameters
* * if the actors contain the player the thread will be started asynchronously
* * if no starting animation is passed the actors will get sorted and one will be chosen automatically
* * if no furniture is passed one will be chosen automatically, if a starting animation is passed only beds will be chosen
* *
* * @param: Actors, the actors to be involved in the thread
* * @param: StartingAnimation, the animation to start the scene in
* * @param: FurnitureRef, the furniture to play the scene on
* *
* * @return: the ThreadID of the thread, or -1 if the thread could not be started
*/;
int Function QuickStart(Actor[] Actors, string StartingAnimation = "", ObjectReference FurnitureRef = None) Global Native


;  ██████╗ ███████╗███╗   ██╗███████╗██████╗  █████╗ ██╗     
; ██╔════╝ ██╔════╝████╗  ██║██╔════╝██╔══██╗██╔══██╗██║     
; ██║  ███╗█████╗  ██╔██╗ ██║█████╗  ██████╔╝███████║██║     
; ██║   ██║██╔══╝  ██║╚██╗██║██╔══╝  ██╔══██╗██╔══██║██║     
; ╚██████╔╝███████╗██║ ╚████║███████╗██║  ██║██║  ██║███████╗
;  ╚═════╝ ╚══════╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝

;/* IsRunning
* * checks if the thread is still running
* *
* * @param: ThreadID, the id of the thread
* *
* * @return: true if the thread is still running, otherwise false
*/;
bool Function IsRunning(int ThreadID) Global Native

;/* Stop
* * ends the thread
* *
* * @param: ThreadID, the id of the thread
*/;
Function Stop(int ThreadID) Global Native

;/* GetThreadCount
* * return the number of currently running threads, including the player thread if it is running
* *
* * @return: the number of currently running threads
*/;
int Function GetThreadCount() Global Native

;/* GetAllThreadIDs
* * returns a list of all currently running thread IDs
* *
* * required API version: 7.3.4 (0x07030040)
* *
* * @return: an array containing the thread IDs of all threads
*/;
int[] Function GetAllThreadIDs() Global Native


; ███╗   ██╗ █████╗ ██╗   ██╗██╗ ██████╗  █████╗ ████████╗██╗ ██████╗ ███╗   ██╗
; ████╗  ██║██╔══██╗██║   ██║██║██╔════╝ ██╔══██╗╚══██╔══╝██║██╔═══██╗████╗  ██║
; ██╔██╗ ██║███████║██║   ██║██║██║  ███╗███████║   ██║   ██║██║   ██║██╔██╗ ██║
; ██║╚██╗██║██╔══██║╚██╗ ██╔╝██║██║   ██║██╔══██║   ██║   ██║██║   ██║██║╚██╗██║
; ██║ ╚████║██║  ██║ ╚████╔╝ ██║╚██████╔╝██║  ██║   ██║   ██║╚██████╔╝██║ ╚████║
; ╚═╝  ╚═══╝╚═╝  ╚═╝  ╚═══╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝

;/* GetScene
* * returns the scene id of the scene that is currently running in the thread
* *
* * @param: ThreadID, the id of the thread
* *
* * @return: the scene id, returns "" if the thread is still in startup or ended
*/;
string Function GetScene(int ThreadID) Global Native

;/* NavigateTo
* * tries to naviate the thread to a new scene
* * cancels any currently running navigations
* * if navigation is not possible instead warps there
* *
* * @param: ThreadID, the id of the thread
* * @param: SceneID, the id of the scene to naviate to
*/;
Function NavigateTo(int ThreadID, string SceneID) Global Native

;/* QueueNavigation
* * tries to navigate the thread to a new scene after the currently running navigation is done
* * if navigation is not possible it will instead queue a warp to the new scene
* * if no navigation is currently running this function behaves identical to NavigateTo
* *
* * required API version: 7.3.4b (0x07030042)
* *
* * @param: ThreadID, the id of the thread
* * @param: SceneID, the id of the scene to navigate to
* * @param: Duration, the duration to remain in the scene before doing further queued navigations
*/;
Function QueueNavigation(int ThreadID, string SceneID, float Duration) Global Native

;/* WarpTo
* * warps the thread to a new scene
* * cancels any currently running navigations
* *
* * @param: ThreadID, the id of the thread
* * @param: SceneID, the id of the scene to warp to
* * @param: UseFades, if set to true the game will fade out before the scene change and back in afterwards
*/;
Function WarpTo(int ThreadID, string SceneID, bool UseFades = False) Global Native

;/* QueueWarp
* * warps the thread to a new scene after the currently running navigation is done
* * if no navigation is currently running this function behaves identical to WarpTo
* *
* * required API version: 7.3.4c (0x07030043)
* *
* * @param ThreadID, the id of the thread
* * @param: SceneID, the id of the scene to warp to
* * @param: Duration, the duration to remain in the scene before doing further queued navigations
*/;
Function QueueWarp(int ThreadID, string SceneID, float Duration) Global Native

;/* AutoTransition
* * plays the auto transition for the thread
* *
* * @param: ThreadID, the id of the thread
* * @param: Type, the type of the auto transition
* *
* * @param: true if the transition exists and was successfully played, otherwise false
*/;
bool Function AutoTransition(int ThreadID, string Type) Global Native

;/* AutoTransitionForActor
* * plays the auto transition for the actor
* *
* * @param: ThreadID, the id of the thread
* * @param: Index, the index of the actor to play the transition for
* * @param: Type, the type of auto transition
* *
* * @return: true if the transition exists and was successfully played, otherwise false
*/;
bool Function AutoTransitionForActor(int ThreadID, int Index, string Type) Global Native

;/* GetSpeed
* * returns the speed index at which the thread is currently running
* *
* * @param: ThreadID, the id of the thread
* *
* * @return: the speed of the thread, returns -1 if the thread is still in startup or ended
*/;
int Function GetSpeed(int ThreadID) Global Native

;/* SetSpeed
* * sets the speed index at which the thread will run
* * values out of range will be clamped to the available speeds
* *
* * @param: ThreadID, the id of the thread
* * @param: Speed, the speed index to use
*/;
Function SetSpeed(int ThreadID, int Speed) Global Native

;/* PlaySequence
* * plays the sequence on the thread
* *
* * required API version: 7.1e (31)
* *
* * @param: Sequence, the sequence to play
* * @param: NavigateTo, if true tries to navigate to the sequence start instead of warping there
* * @param: UseFades, if true uses fade to black when warping to the sequence start if navigation wasn't possible or is disabled
*/;
Function PlaySequence(int ThreadID, string Sequence, bool NavigateTo = false, bool UseFades = false) Global Native


;  █████╗  ██████╗████████╗ ██████╗ ██████╗ ███████╗
; ██╔══██╗██╔════╝╚══██╔══╝██╔═══██╗██╔══██╗██╔════╝
; ███████║██║        ██║   ██║   ██║██████╔╝███████╗
; ██╔══██║██║        ██║   ██║   ██║██╔══██╗╚════██║
; ██║  ██║╚██████╗   ██║   ╚██████╔╝██║  ██║███████║
; ╚═╝  ╚═╝ ╚═════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚══════╝

;/* GetActors
* * returns the actors of the thread
* *
* * @param: ThreadID, the id of the thread
* *
* * @return: an array of actors
*/;
Actor[] Function GetActors(int ThreadID) Global Native

;/* GetActor
* * returns the actor at the given index
* *
* * @param: ThreadID, the id of the thread
* * @index: the index of the actor
* *
* * @return: the actor
*/;
Actor Function GetActor(int ThreadID, int Index) Global Native

;/* GetActorPosition
* * returns the index of the actor in the thread
* *
* * @param: ThreadID, the id of the thread
* * @param: Act, the actor to get the position for
* *
* * @return: the actors index, returns -1 the the thread doesn't contain the actor or ended
*/;
int Function GetActorPosition(int ThreadID, Actor Act) Global Native


;  ██████╗██╗     ██╗███╗   ███╗ █████╗ ██╗  ██╗
; ██╔════╝██║     ██║████╗ ████║██╔══██╗╚██╗██╔╝
; ██║     ██║     ██║██╔████╔██║███████║ ╚███╔╝ 
; ██║     ██║     ██║██║╚██╔╝██║██╔══██║ ██╔██╗ 
; ╚██████╗███████╗██║██║ ╚═╝ ██║██║  ██║██╔╝ ██╗
;  ╚═════╝╚══════╝╚═╝╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝

;/* StallClimax
* * prevents all actors in the thread from climaxing, including the prevention of auto climax animations
* * does not prevent the climaxes of auto climax animations that already started
* *
* * @param: Thread, the id of the thread
*/;
Function StallClimax(int ThreadID) Global Native

;/* PermitClimax
* * permits the actors in the thread to climax again (as in it undoes StallClimax)
* *
* * @param: Thread, the id of the thread
* * @param: PermitActors, if true this also undoes the StallClimax calls for the individual actors
*/;
Function PermitClimax(int ThreadID, bool PermitActors = false) Global Native

;/* IsClimaxStalled
* * checks if this actor is currently prevented from climaxing
* *
* * @param: Thread, the id of the thread
* *
* * @return: true if the actor is currently prevented from climaxing
*/;
bool Function IsClimaxStalled(int ThreadID) Global Native


; ███████╗██╗   ██╗██████╗ ███╗   ██╗██╗████████╗██╗   ██╗██████╗ ███████╗
; ██╔════╝██║   ██║██╔══██╗████╗  ██║██║╚══██╔══╝██║   ██║██╔══██╗██╔════╝
; █████╗  ██║   ██║██████╔╝██╔██╗ ██║██║   ██║   ██║   ██║██████╔╝█████╗  
; ██╔══╝  ██║   ██║██╔══██╗██║╚██╗██║██║   ██║   ██║   ██║██╔══██╗██╔══╝  
; ██║     ╚██████╔╝██║  ██║██║ ╚████║██║   ██║   ╚██████╔╝██║  ██║███████╗
; ╚═╝      ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚══════╝

;/* GetFurniture
* * returns the furniture object used by the thread
* *
* * @param: ThreadID, the id of the thread
* *
* * @return: the furniture object, or None if the thread isn't using one
*/;
ObjectReference Function GetFurniture(int ThreadID) Global Native

;/* GetFurnitureType
* * returns the furniture type used in the thread
* *
* * @param: ThreadID, the id of the thread
* *
* * @return: the furniture type, returns "" if the thread is still in startup or ended
*/;
string Function GetFurnitureType(int ThreadID) Global Native

;/* ChangeFurniture
* * moves the scene to a new furniture object
* *
* * required API version: 7.3.2 (0x07030020)
* *
* * @param: ThreadID, the id of the thread
* * @param: FurnitureRef, the new furniture
* * @param: SceneID, the scene to play on the new furniture, if none is given a starting animation will be chosen randomly
*/;
Function ChangeFurniture(int ThreadID, ObjectReference FurnitureRef, string SceneID = "") Global Native


;  █████╗ ██╗   ██╗████████╗ ██████╗     ███╗   ███╗ ██████╗ ██████╗ ███████╗
; ██╔══██╗██║   ██║╚══██╔══╝██╔═══██╗    ████╗ ████║██╔═══██╗██╔══██╗██╔════╝
; ███████║██║   ██║   ██║   ██║   ██║    ██╔████╔██║██║   ██║██║  ██║█████╗  
; ██╔══██║██║   ██║   ██║   ██║   ██║    ██║╚██╔╝██║██║   ██║██║  ██║██╔══╝  
; ██║  ██║╚██████╔╝   ██║   ╚██████╔╝    ██║ ╚═╝ ██║╚██████╔╝██████╔╝███████╗
; ╚═╝  ╚═╝ ╚═════╝    ╚═╝    ╚═════╝     ╚═╝     ╚═╝ ╚═════╝ ╚═════╝ ╚══════╝

;/* IsInAutoMode
* * checks if the thread is currently running in automatic mode
* *
* * @param: ThreadID, the id of the thread
* *
* * @return: true if the thread is in auto mode, otherwise false
*/;
bool Function IsInAutoMode(int ThreadID) Global Native

;/* StartAutoMode
* * sets the thread to automatic mode
* *
* * @param: ThreadID, the id of the thread
*/;
Function StartAutoMode(int ThreadID) Global Native

;/* StopAutoMode
* * sets the thread to manual mode
* * for the player thread that means the player is now again in control of the navigation
* * for NPC threads this means they will need to be controlled from the outside
* *
* * @param: ThreadID, the id of the thread
*/;
Function StopAutoMode(int ThreadID) Global Native


; ███╗   ███╗███████╗████████╗ █████╗ ██████╗  █████╗ ████████╗ █████╗ 
; ████╗ ████║██╔════╝╚══██╔══╝██╔══██╗██╔══██╗██╔══██╗╚══██╔══╝██╔══██╗
; ██╔████╔██║█████╗     ██║   ███████║██║  ██║███████║   ██║   ███████║
; ██║╚██╔╝██║██╔══╝     ██║   ██╔══██║██║  ██║██╔══██║   ██║   ██╔══██║
; ██║ ╚═╝ ██║███████╗   ██║   ██║  ██║██████╔╝██║  ██║   ██║   ██║  ██║
; ╚═╝     ╚═╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝

;/* HasMetadata
* * checks if the thread has a specific metadata
* *
* * @param: ThreadID, the id of the thread
* * @param: Metadata, the metadata to check for
* *
* * @return: true if the thread has the metadata, otherwise false
*/;
bool Function HasMetadata(int ThreadID, string Metadata) Global Native

;/* AddMetadata
* * adds metadata to the thread
* *
* * @param: ThreadID, the id of the thread
* * @param: Metadata, the metadata to add
*/;
Function AddMetadata(int ThreadID, string Metadata) Global Native

;/* GetMetadata
* * returns a list of all metadata of the thread
* *
* * @param: ThreadID, the id of the thread
* *
* * @return: the list of metadata
*/;
string[] Function GetMetadata(int ThreadID) Global Native


;/* HasMetaFloat
* * checks if the thread has a float value for the key
* *
* * required API version: 7.3.4b (0x07030042)
* *
* * @param: ThreadID, the id of the thread
* * @param: MetaID, the id of the float value
* *
* * @return: true if the thread has a float for that key set, otherwise false
*/;
bool Function HasMetaFloat(int ThreadID, string MetaID) Global Native

;/* GetMetaFloat
* * returns the threads float value for the key
* *
* * required API version: 7.3.2 (0x07030020)
* *
* * @param: ThreadID, the id of the thread
* * @param: MetaID, the id of the float value
* *
* * @return: the float value for the given key, or 0 if none is set
*/;
float Function GetMetaFloat(int ThreadID, string MetaID) Global Native

;/* SetMetaFloat
* * sets the threads float value for the key
* *
* * required API version: 7.3.2 (0x07030020)
* *
* * @param: ThreadID, the id of the thread
* * @param: MetaID, the id of the float value
* * @param: Value, the float value to set
*/;
Function SetMetaFloat(int ThreadID, string MetaID, float Value) Global Native


;/* HasMetaString
* * checks if the thread has a string value for the key
* *
* * required API version: 7.3.4b (0x07030042)
* *
* * @param: ThreadID, the id of the thread
* * @param: MetaID, the id of the string value
* *
* * @return: true if the thread has a string for that key set, otherwise false
*/;
bool Function HasMetaString(int ThreadID, string MetaID) Global Native

;/* GetMetaString
* * returns the threads string value for the key
* *
* * required API version: 7.3.2 (0x07030020)
* *
* * @param: ThreadID, the id of the thread
* * @param: MetaID, the id of the string value
* *
* * @return: the string value for the given key, or "" if none is set
*/;
string Function GetMetaString(int ThreadID, string MetaID) Global Native

;/* SetMetaString
* * sets the threads string value for the key
* *
* * required API version: 7.3.2 (0x07030020)
* *
* * @param: ThreadID, the id of the thread
* * @param: MetaID, the id of the string value
* * @param: Value, the string value to set
*/;
Function SetMetaString(int ThreadID, string MetaID, string Value) Global Native


; ███████╗██╗   ██╗███████╗███╗   ██╗████████╗███████╗
; ██╔════╝██║   ██║██╔════╝████╗  ██║╚══██╔══╝██╔════╝
; █████╗  ██║   ██║█████╗  ██╔██╗ ██║   ██║   ███████╗
; ██╔══╝  ╚██╗ ██╔╝██╔══╝  ██║╚██╗██║   ██║   ╚════██║
; ███████╗ ╚████╔╝ ███████╗██║ ╚████║   ██║   ███████║
; ╚══════╝  ╚═══╝  ╚══════╝╚═╝  ╚═══╝   ╚═╝   ╚══════╝

;/* CallEvent
* * calls the event for the thread, events and their properties can be defined in data/SKSE/plugins/OStim/events
* * the corresponding mod events will be thrown even if no event was defined for the event name
* *
* * @param: ThreadID, the id of the thread
* * @param: EventName, the name of the event
* * @param: Actor, the index of the event actor
* * @param: Target, the index of the event target, if none is given the actor index is used
* * @param: Performer, the index of the event performer, if none is given the actor index is used
*/;
Function CallEvent(int ThreadID, string EventName, int Actor, int Target = -1, int Performer = -1) Global Native