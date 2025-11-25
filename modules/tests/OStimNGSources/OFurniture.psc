;/* OFurniture
* * collection of furniture related native functions
* *
* * all references to furniture types refer to OStims classification of furniture, not Skyrims internal one
* * for more information about OStims furniture types read "../Data/SKSE/Plugins/OStim/furniture types README.txt"
*/;
ScriptName OFurniture

;/* GetFurnitureType
* * returns the type of the furniture
* *
* * @param: FurnitureRef, the furniture to get the type for
* *
* * @return: the furniture type, or "none" if the reference is not a valid furniture
*/;
string Function GetFurnitureType(ObjectReference FurnitureRef) Global Native

;/* IsChildOf
* * checks if the furniture type is a child of the other type
* *
* * * * required API version: 7.3.4a (0x07030041)
* *
* * @param: SuperType, the parent type
* * @param: SubType, the child type
* *
* * @return: true if the subtype is a child of the supertype, otherwise false
*/;
bool Function IsChildOf(string SuperType, string SubType) Global Native

;/* FindFurniture
* * returns the closest object reference of each furniture that that is not occupied or reserved
* * the return array is sorted by distance to the center, so the first element in the array is the closest object to the CenterRef, etc.
* *
* * @param: ActorCount, the amount of actors for the scene, furniture that does not have animations for this many actors will be skipped
* * @param: CenterRef, the reference to center the search around
* * @param: Radius, the radius to search in
* * @param: SameFloor, the difference in the Z coordinate to search in
* *
* * @return: an array of furniture references, can be size 0 if none was found
*/;
ObjectReference[] Function FindFurniture(int ActorCount, ObjectReference CenterRef, float Radius, float SameFloor = 0.0) Global Native

;/* FindFurnitureOfType
* * searches for the closest furniture of the specified type that is not occupied or reserved
* *
* * required API version: 7.1e (31)
* *
* * @param: Type, the type of furniture to search
* * @param: CenterRef, the reference to center the search around
* * @param: Radius, the radius to search in
* * @param: SameFloor, the difference in the Z coordinate to search in
* *
* * @return: the furniture, or None if none was found
*/;
ObjectReference Function FindFurnitureOfType(string Type, ObjectReference CenterRef, float Radius, float SameFloor = 0.0) Global Native

;/* GetOffset
* * returns an array of five elements {x, y, z, rotation, scale} for the actor offset as defined in the furniture type of the reference
* *
* * @param: FurnitureRef, the furniture to get the offset for
* *
* * return: the offset array, {0.0, 0.0, 0.0, 0.0, 1.0} if the reference is not a valid furniture
*/;
float[] Function GetOffset(ObjectReference FurnitureRef) Global Native

;/* GetSceneID
* * gets the scene ID of the scene involding the furniture
* *
* * required API version: 7.3.4a (0x07030041)
* *
* * @param: FurnitureRef, the furniture to get the scene ID for
* *
* * @return: the scene ID, -1 if the furniture is not involved in a scene
*/;
int Function GetSceneID(ObjectReference FurnitureRef) Global Native

;/* ResetClutter
* * resets all clutter in an area
* *
* * @param: CenterRef, the reference to center the clutter search around
* * @param: Radius, the radius of the area of clutter to reset
*/;
Function ResetClutter(ObjectReference CenterRef, float Radius) Global Native


