Scriptname NiOverride Hidden

int Function GetScriptVersion() global
	return 7
EndFunction

; Valid keys
; ID - TYPE - Name
; 0 - int - ShaderEmissiveColor
; 1 - float - ShaderEmissiveMultiple
; 2 - float - ShaderGlossiness
; 3 - float - ShaderSpecularStrength
; 4 - float - ShaderLightingEffect1
; 5 - float - ShaderLightingEffect2
; 6 - TextureSet - ShaderTextureSet
; 7 - int - ShaderTintColor
; 8 - float - ShaderAlpha
; 9 - string - ShaderTexture (index 0-8)
; 20 - float - ControllerStartStop (-1.0 for stop, anything else indicates start time)
; 21 - float - ControllerStartTime
; 22 - float - ControllerStopTime
; 23 - float - ControllerFrequency
; 24 - float - ControllerPhase

; Indexes are for controller index (0-255)
; -1 indicates not relevant, use it when not using controller based properties

; Persist True will save the change to the co-save and will automatically re-apply when equipping
; Persist False will apply the change visually until the armor is re-equipped or the game is reloaded (Equivalent to SetPropertyX)

; ObjectReference must be an Actor
; Overrides will clean themselves if the Armor or ArmorAddon no longer exists (i.e. you uninstalled the mod they were associated with)
bool Function HasOverride(ObjectReference ref, bool isFemale, Armor arm, ArmorAddon addon, string node, int key, int index) native global

Function AddOverrideFloat(ObjectReference ref, bool isFemale, Armor arm, ArmorAddon addon, string node, int key, int index, float value, bool persist) native global
Function AddOverrideInt(ObjectReference ref, bool isFemale, Armor arm, ArmorAddon addon, string node, int key, int index, int value, bool persist) native global
Function AddOverrideBool(ObjectReference ref, bool isFemale, Armor arm, ArmorAddon addon, string node, int key, int index, bool value, bool persist) native global
Function AddOverrideString(ObjectReference ref, bool isFemale, Armor arm, ArmorAddon addon, string node, int key, int index, string value, bool persist) native global
Function AddOverrideTextureSet(ObjectReference ref, bool isFemale, Armor arm, ArmorAddon addon, string node, int key, int index, TextureSet value, bool persist) native global

; Gets the saved override value
float Function GetOverrideFloat(ObjectReference ref, bool isFemale, Armor arm, ArmorAddon addon, string node, int key, int index) native global
int Function GetOverrideInt(ObjectReference ref, bool isFemale, Armor arm, ArmorAddon addon, string node, int key, int index) native global
bool Function GetOverrideBool(ObjectReference ref, bool isFemale, Armor arm, ArmorAddon addon, string node, int key, int index) native global
string Function GetOverrideString(ObjectReference ref, bool isFemale, Armor arm, ArmorAddon addon, string node, int key, int index) native global
TextureSet Function GetOverrideTextureSet(ObjectReference ref, bool isFemale, Armor arm, ArmorAddon addon, string node, int key, int index) native global

; Gets the property straight from the node (Handy if you need the current value if an override D.N.E yet)
float Function GetPropertyFloat(ObjectReference ref, bool firstPerson, Armor arm, ArmorAddon addon, string node, int key, int index) native global
int Function GetPropertyInt(ObjectReference ref, bool firstPerson, Armor arm, ArmorAddon addon, string node, int key, int index) native global
bool Function GetPropertyBool(ObjectReference ref, bool firstPerson, Armor arm, ArmorAddon addon, string node, int key, int index) native global
string Function GetPropertyString(ObjectReference ref, bool firstPerson, Armor arm, ArmorAddon addon, string node, int key, int index) native global
;TextureSet is not stored on the node, individual textures are, however.

; Returns whether the specified node could be found for the given parameters
; Debug will report errors to NiOverrides log file
bool Function HasArmorAddonNode(ObjectReference ref, bool firstPerson, Armor arm, ArmorAddon addon, string node, bool debug = false) native global

; Applies all armor properties visually to the actor, this shouldn't be necessary under normal circumstances
Function ApplyOverrides(ObjectReference ref) native global

; ObjectReference must be an Actor (These could work for non-actor objects, untested)
; ADVANCED USE ONLY, THESE DO NOT SELF CLEANUP IF THE NODE IS NOT FOUND
; Returns whether there is an override for this particular node
bool Function HasNodeOverride(ObjectReference ref, bool isFemale, string node, int key, int index) native global

Function AddNodeOverrideFloat(ObjectReference ref, bool isFemale, string node, int key, int index, float value, bool persist) native global
Function AddNodeOverrideInt(ObjectReference ref, bool isFemale, string node, int key, int index, int value, bool persist) native global
Function AddNodeOverrideBool(ObjectReference ref, bool isFemale, string node, int key, int index, bool value, bool persist) native global
Function AddNodeOverrideString(ObjectReference ref, bool isFemale, string node, int key, int index, string value, bool persist) native global
Function AddNodeOverrideTextureSet(ObjectReference ref, bool isFemale, string node, int key, int index, TextureSet value, bool persist) native global

; Return the stored override, returns default (nil) values if the override D.N.E
float Function GetNodeOverrideFloat(ObjectReference ref, bool isFemale, string node, int key, int index) native global
int Function GetNodeOverrideInt(ObjectReference ref, bool isFemale, string node, int key, int index) native global
bool Function GetNodeOverrideBool(ObjectReference ref, bool isFemale, string node, int key, int index) native global
string Function GetNodeOverrideString(ObjectReference ref, bool isFemale, string node, int key, int index) native global
TextureSet Function GetNodeOverrideTextureSet(ObjectReference ref, bool isFemale, string node, int key, int index) native global

; Gets the property straight from the node (Handy if you need the current value if an override D.N.E yet)
float Function GetNodePropertyFloat(ObjectReference ref, bool firstPerson, string node, int key, int index) native global
int Function GetNodePropertyInt(ObjectReference ref, bool firstPerson, string node, int key, int index) native global
bool Function GetNodePropertyBool(ObjectReference ref, bool firstPerson, string node, int key, int index) native global
string Function GetNodePropertyString(ObjectReference ref, bool firstPerson, string node, int key, int index) native global
;TextureSet is not stored on the node, individual textures are, however.

; Applies all node properties visually to the actor, this shouldn't be necessary under normal circumstances
Function ApplyNodeOverrides(ObjectReference ref) native global


; Version 3 (Weapon Overrides)
;-------------------------------------------------------
; ObjectReference must be an Actor
; If a weapon is templated it will inherit the properties of its parent first
; Note that the player seems to be a special-case where they use the first person model for both first and third person
;
; Overrides will clean themselves if the Weapon no longer exists (i.e. you uninstalled the mod they were associated with)
bool Function HasWeaponOverride(ObjectReference ref, bool isFemale, bool firstPerson, Weapon weap, string node, int key, int index) native global

Function AddWeaponOverrideFloat(ObjectReference ref, bool isFemale, bool firstPerson, Weapon weap, string node, int key, int index, float value, bool persist) native global
Function AddWeaponOverrideInt(ObjectReference ref, bool isFemale, bool firstPerson, Weapon weap, string node, int key, int index, int value, bool persist) native global
Function AddWeaponOverrideBool(ObjectReference ref, bool isFemale, bool firstPerson, Weapon weap, string node, int key, int index, bool value, bool persist) native global
Function AddWeaponOverrideString(ObjectReference ref, bool isFemale, bool firstPerson, Weapon weap, string node, int key, int index, string value, bool persist) native global
Function AddWeaponOverrideTextureSet(ObjectReference ref, bool isFemale, bool firstPerson, Weapon weap, string node, int key, int index, TextureSet value, bool persist) native global

; Gets the saved override value
float Function GetWeaponOverrideFloat(ObjectReference ref, bool isFemale, bool firstPerson, Weapon weap, string node, int key, int index) native global
int Function GetWeaponOverrideInt(ObjectReference ref, bool isFemale, bool firstPerson, Weapon weap, string node, int key, int index) native global
bool Function GetWeaponOverrideBool(ObjectReference ref, bool isFemale, bool firstPerson, Weapon weap, string node, int key, int index) native global
string Function GetWeaponOverrideString(ObjectReference ref, bool isFemale, bool firstPerson, Weapon weap, string node, int key, int index) native global
TextureSet Function GetWeaponOverrideTextureSet(ObjectReference ref, bool isFemale, bool firstPerson, Weapon weap, string node, int key, int index) native global

; Gets the property straight from the node (Handy if you need the current value if an override D.N.E yet)
float Function GetWeaponPropertyFloat(ObjectReference ref, bool firstPerson, Weapon weap, string node, int key, int index) native global
int Function GetWeaponPropertyInt(ObjectReference ref, bool firstPerson, Weapon weap, string node, int key, int index) native global
bool Function GetWeaponPropertyBool(ObjectReference ref, bool firstPerson, Weapon weap, string node, int key, int index) native global
string Function GetWeaponPropertyString(ObjectReference ref, bool firstPerson, Weapon weap, string node, int key, int index) native global
;TextureSet is not stored on the node, individual textures are, however.

; Returns whether the specified node could be found for the given parameters
; Debug will report errors to NiOverrides log file
bool Function HasWeaponNode(ObjectReference ref, bool firstPerson, Weapon weap, string node, bool debug = false) native global

; Applies all armor properties visually to the actor, this shouldn't be necessary under normal circumstances
Function ApplyWeaponOverrides(ObjectReference ref) native global
; ----------------------------------------------------




; Version 6 (Skin Overrides)
;-------------------------------------------------------
; ObjectReference must be an Actor
;
bool Function HasSkinOverride(ObjectReference ref, bool isFemale, bool firstPerson, int slotMask, int key, int index) native global

Function AddSkinOverrideFloat(ObjectReference ref, bool isFemale, bool firstPerson, int slotMask, int key, int index, float value, bool persist) native global
Function AddSkinOverrideInt(ObjectReference ref, bool isFemale, bool firstPerson, int slotMask, int key, int index, int value, bool persist) native global
Function AddSkinOverrideBool(ObjectReference ref, bool isFemale, bool firstPerson, int slotMask, int key, int index, bool value, bool persist) native global
Function AddSkinOverrideString(ObjectReference ref, bool isFemale, bool firstPerson, int slotMask, int key, int index, string value, bool persist) native global
Function AddSkinOverrideTextureSet(ObjectReference ref, bool isFemale, bool firstPerson, int slotMask, int key, int index, TextureSet value, bool persist) native global

; Gets the saved override value
float Function GetSkinOverrideFloat(ObjectReference ref, bool isFemale, bool firstPerson, int slotMask, int key, int index) native global
int Function GetSkinOverrideInt(ObjectReference ref, bool isFemale, bool firstPerson, int slotMask, int key, int index) native global
bool Function GetSkinOverrideBool(ObjectReference ref, bool isFemale, bool firstPerson, int slotMask, int key, int index) native global
string Function GetSkinOverrideString(ObjectReference ref, bool isFemale, bool firstPerson, int slotMask, int key, int index) native global
TextureSet Function GetSkinOverrideTextureSet(ObjectReference ref, bool isFemale, bool firstPerson, int slotMask, int key, int index) native global

; Gets the property straight from the node (Handy if you need the current value if an override D.N.E yet)
float Function GetSkinPropertyFloat(ObjectReference ref, bool firstPerson, int slotMask, int key, int index) native global
int Function GetSkinPropertyInt(ObjectReference ref, bool firstPerson, int slotMask, int key, int index) native global
bool Function GetSkinPropertyBool(ObjectReference ref, bool firstPerson, int slotMask, int key, int index) native global
string Function GetSkinPropertyString(ObjectReference ref, bool firstPerson, int slotMask, int key, int index) native global
;TextureSet is not stored on the node, individual textures are, however.

; Applies all skin properties visually to the actor, this shouldn't be necessary under normal circumstances
Function ApplySkinOverrides(ObjectReference ref) native global
; ----------------------------------------------------


; Remove functions do not revert the modified state, only remove it from the save

; Removes ALL Armor based overrides from ALL actors (Global purge)
Function RemoveAllOverrides() native global

; Removes all Armor based overrides for a particular actor
Function RemoveAllReferenceOverrides(ObjectReference ref) native global

; Removes all ArmorAddon overrides for a particular actor and armor
Function RemoveAllArmorOverrides(ObjectReference ref, bool isFemale, Armor arm) native global

; Removes all overrides for a particular actor, armor, and addon
Function RemoveAllArmorAddonOverrides(ObjectReference ref, bool isFemale, Armor arm, ArmorAddon addon) native global

; Removes all overrides for a particukar actor, armor, addon, and nodeName
Function RemoveAllArmorAddonNodeOverrides(ObjectReference ref, bool isFemale, Armor arm, ArmorAddon addon, string node) native global

; Removes one particular override from an actor, armor, addon, node name, key, index
Function RemoveOverride(ObjectReference ref, bool isFemale, Armor arm, ArmorAddon addon, string node, int key, int index) native global

; Removes ALL Node based overrides for ALL actors (Global purge)
Function RemoveAllNodeOverrides() native global

; Removes all Node based overrides for a particular actor
Function RemoveAllReferenceNodeOverrides(ObjectReference ref) native global

; Removes all Node based overrides for a particular actor, gender, and nodeName
Function RemoveAllNodeNameOverrides(ObjectReference ref, bool isFemale, string node) native global

; Removes one particular override from an actor, of a particular gender, nodeName, key, and index
Function RemoveNodeOverride(ObjectReference ref, bool isFemale, string node, int key, int index) native global


; Removes ALL weapon based overrides from ALL actors (Global purge)
Function RemoveAllWeaponBasedOverrides() native global

; Removes all weapon based overrides for a particular actor
Function RemoveAllReferenceWeaponOverrides(ObjectReference ref) native global

; Removes all weapon overrides for a particular actor, gender, view, and weapon
Function RemoveAllWeaponOverrides(ObjectReference ref, bool isFemale, bool firstPerson, Weapon weap) native global

; Removes all overrides for a particukar actor, gender, view, weapon, and nodeName
Function RemoveAllWeaponNodeOverrides(ObjectReference ref, bool isFemale, bool firstPerson, Weapon weap, string node) native global

; Removes a particular weapon override
Function RemoveWeaponOverride(ObjectReference ref, bool isFemale, bool firstPerson, Weapon weap, string node, int key, int index) native global


; Removes ALL skin based overrides from ALL actors (Global purge)
Function RemoveAllSkinBasedOverrides() native global

; Removes all skin based overrides for a particular actor
Function RemoveAllReferenceSkinOverrides(ObjectReference ref) native global

; Removes all skin overrides for a particular actor, gender, view, and weapon
Function RemoveAllSkinOverrides(ObjectReference ref, bool isFemale, bool firstPerson, int slotMask) native global

; Removes a particular skin override
Function RemoveSkinOverride(ObjectReference ref, bool isFemale, bool firstPerson, int slotMask, int key, int index) native global


; Overlay Data
int Function GetNumBodyOverlays() native global
int Function GetNumHandOverlays() native global
int Function GetNumFeetOverlays() native global
int Function GetNumFaceOverlays() native global

int Function GetNumSpellBodyOverlays() native global
int Function GetNumSpellHandOverlays() native global
int Function GetNumSpellFeetOverlays() native global
int Function GetNumSpellFaceOverlays() native global

; Adds all enabled overlays to an Actor (Cannot add to player, always exists for player)
Function AddOverlays(ObjectReference ref) native global

; Returns whether this actor has overlays enabled (Always true for player)
bool Function HasOverlays(ObjectReference ref) native global

; Removes overlays from an actor (Cannot remove from player)
Function RemoveOverlays(ObjectReference ref) native global

; Restores the original non-diffuse skin textures to skin overlays
Function RevertOverlays(ObjectReference ref) native global

; Restores the original non-diffuse skin textures to particular overlay
; Valid masks: Combining masks not recommended
; 4 - Body
; 8 - Hands
; 128 - Feet
Function RevertOverlay(ObjectReference ref, string nodeName, int armorMask, int addonMask) native global

; Restores the original non-diffuse skin textures to all head overlays
Function RevertHeadOverlays(ObjectReference ref) native global

; Restores the original non-diffuse skin textures to particular overlay
; Valid partTypes
; 1 - Face
; Valid shaderTypes
; 4 - FaceTint
Function RevertHeadOverlay(ObjectReference ref, string nodeName, int partType, int shaderType) native global

; Sets a body morph value on an actor
Function SetMorphValue(ObjectReference ref, string morphName, float value) global
	SetBodyMorph(ref, morphName, "RSMLegacy", value)
EndFunction

; Gets a body morph value on an actor
float Function GetMorphValue(ObjectReference ref, string morphName) global
	return GetBodyMorph(ref, morphName, "RSMLegacy")
EndFunction

; Clears a body morph value on an actor
Function ClearMorphValue(ObjectReference ref, string morphName) global
	return ClearBodyMorph(ref, morphName, "RSMLegacy")
EndFunction

; Returns true if there are any body morphs with this key and name
bool Function HasBodyMorph(ObjectReference ref, string morphName, string keyName) native global

; Sets a body morph value on an actor
Function SetBodyMorph(ObjectReference ref, string morphName, string keyName, float value) native global

; Gets a body morph value on an actor
float Function GetBodyMorph(ObjectReference ref, string morphName, string keyName) native global

; Clears a body morph value on an actor
Function ClearBodyMorph(ObjectReference ref, string morphName, string keyName) native global

; Returns true if there are any body morphs with this key
bool Function HasBodyMorphKey(ObjectReference ref, string keyName) native global

; Clears all body morphs with this key
Function ClearBodyMorphKeys(ObjectReference ref, string keyName) native global

; Returns true if there are any body morphs with this name
bool Function HasBodyMorphName(ObjectReference ref, string keyName) native global

; Clears all body morphs with this name
Function ClearBodyMorphNames(ObjectReference ref, string morphName) native global

; Clears all body morphs for an actor
Function ClearMorphs(ObjectReference ref) native global

; Updates the weight data post morph value
; only to be used on actors who have morph values set
Function UpdateModelWeight(ObjectReference ref) native global

; Returns all Body Morph names applied to the reference
string[] Function GetMorphNames(ObjectReference ref) native global

; Returns all Body Morph keys applied for the morph name
string[] Function GetMorphKeys(ObjectReference ref, string morphName) native global

; Returns all References currently being morphed
ObjectReference[] Function GetMorphedReferences() native global

; Calls the function by name on target for each morphed reference
Function ForEachMorphedReference(string callback, Form target) native global

; Call this function prior to frequent changes in dyes to prevent massive lag
Function EnableTintTextureCache() native global
; Call this when finished frequent dye edits
Function ReleaseTintTextureCache() native global

; -------------- Unique Item functions -----------------
; When a UID is added to an item, that particular item will keep that UID
; until that item is deleted, you can use this UID to map additional
; data if you choose, you can tell when a UID has been deleted via the
; NiOverride_Internal_EraseUID Mod Event
; e.g.
; RegisterForModEvent("NiOverride_Internal_EraseUID", "OnEraseUID")
; Event OnEraseUID(string eventName, string strArg, float UID, Form formId)
; The UID functions are no longer valid when the UID event is received

; Returns a number for a unique item, if the item is not unique it will be made unique, returns 0 when invalid
int Function GetItemUniqueID(ObjectReference akActor, int weaponSlot, int slotMask, bool makeUnique = true) native global

; Returns a number for a unique item in the world, when it's placed in inventory it will maintain this ID
int Function GetObjectUniqueID(ObjectReference akObject, bool makeUnique = true) native global

; Returns the base form associated with this uniqueId
Form Function GetFormFromUniqueID(int uniqueId) native global

; Returns the reference that is holding the item described by this uniqueId
; If the item is in the world, it will return the world reference of itself
; If the item is inside of an inventory, it will return the reference of the inventory
Form Function GetOwnerOfUniqueID(int uniqueId) native global

; Dye Functions
; Uses the uniqueId acquired from GetItemUniqueID
Function SetItemDyeColor(int uniqueId, int maskIndex, int color) native global
int Function GetItemDyeColor(int uniqueId, int maskIndex) native global
Function ClearItemDyeColor(int uniqudId, int maskIndex) native global

; Regenerates the tintmask of the dyed object, use after assigning/clearing dye colors
Function UpdateItemDyeColor(ObjectReference akActor, int uniqueId) native global


; v2 Dye Functions
; Uses the uniqueId acquired from GetItemUniqueID
Function SetItemTextureLayerColor(int uniqueId, int textureIndex, int layer, int color) native global
int Function GetItemTextureLayerColor(int uniqueId, int textureIndex, int layer) native global
Function ClearItemTextureLayerColor(int uniqudId, int textureIndex, int layer) native global

Function SetItemTextureLayerType(int uniqueId, int textureIndex, int layer, int type) native global
int Function GetItemTextureLayerType(int uniqueId, int textureIndex, int layer) native global
Function ClearItemTextureLayerType(int uniqudId, int textureIndex, int layer) native global

Function SetItemTextureLayerTexture(int uniqueId, int textureIndex, int layer, string texture) native global
string Function GetItemTextureLayerTexture(int uniqueId, int textureIndex, int layer) native global
Function ClearItemTextureLayerTexture(int uniqudId, int textureIndex, int layer) native global

Function SetItemTextureLayerBlendMode(int uniqueId, int textureIndex, int layer, string texture) native global
string Function GetItemTextureLayerBlendMode(int uniqueId, int textureIndex, int layer) native global
Function ClearItemTextureLayerBlendMode(int uniqudId, int textureIndex, int layer) native global

Function UpdateItemTextureLayers(ObjectReference akActor, int uniqueId) native global

; ------ NON PERSISTENT FUNCTIONS --------------
; These functions do not persist in game sessions but are instead 
; very fast and are suitable to be used on a game load event

; Returns true if the Form has been registered as a Dye
bool Function IsFormDye(Form akForm) native global

; Returns the dye color bound to this form
int Function GetFormDyeColor(Form akForm) native global

; Registers the Form as a Dye with a color, 0x00FFFFFF is the universal dye
Function RegisterFormDyeColor(Form akForm, int color) native global

; Removes this form as a 
Function UnregisterFormDyeColor(Form akForm) native global
; -------------------------------------------------



; ----------------- Node manipulation functions --------------
; These functions should only be used on nodes that either exist
; directly on the skeleton, or are injected via armor templates
; Armor Template injections are as follows:
; NiStringsExtraData - Name: EXTN (Count divisible by 3)
; [0] - TargetNode Name
; [1] - SourceNode Name
; [2] - Absolute nif path, relative to skyrim directory
; Notes: Template will take only the first root node and all
; its children, the Source Node should be the name of this
; root node. The TargetNode will be the parent to Source
; ------------------------------------------------------------

; As of script version 6 all keys ending with .esp or .esm will check if the mod is active
; and erase the key at load time if the mod is not active

; Checks whether there is a positon override for the particular parameters
bool Function HasNodeTransformPosition(ObjectReference akRef, bool firstPerson, bool isFemale, string nodeName, string key) native global

; Adds a position override for the particular key, pos[0-2] correspond to x,y,z
Function AddNodeTransformPosition(ObjectReference akRef, bool firstPerson, bool isFemale, string nodeName, string key, float[] pos) native global

; Returns a position override for the particular key an array of size 3 corresponding to x,y,z
float[] Function GetNodeTransformPosition(ObjectReference akRef, bool firstPerson, bool isFemale, string nodeName, string key) native global

; Removes a particular position override, returns true if it removed, false if did not exist
bool Function RemoveNodeTransformPosition(ObjectReference akRef, bool firstPerson, bool isFemale, string nodeName, string key) native global


; Checks whether there is a scale override for the particular parameters
bool Function HasNodeTransformScale(ObjectReference akRef, bool firstPerson, bool isFemale, string nodeName, string key) native global

; Adds a scale override for the particular key, pos[0-2] correspond to x,y,z
Function AddNodeTransformScale(ObjectReference akRef, bool firstPerson, bool isFemale, string nodeName, string key, float scale) native global

; Returns a scale value override for the particular key, 0.0 if did not exist or failed
float Function GetNodeTransformScale(ObjectReference akRef, bool firstPerson, bool isFemale, string nodeName, string key) native global

; Removes a particular scale override, returns true if it removed, false if did not exist
bool Function RemoveNodeTransformScale(ObjectReference akRef, bool firstPerson, bool isFemale, string nodeName, string key) native global


; Checks whether there is a rotation override for the particular parameters
bool Function HasNodeTransformRotation(ObjectReference akRef, bool firstPerson, bool isFemale, string nodeName, string key) native global

; Adds a rotation override for the particular key given either a size 3 or 9 array
; rotation[0-8] corresponding to the linear indices of a 3x3 matrix in radians
; rotation[0-2] corresponding to heading, attitude, and bank in degrees
Function AddNodeTransformRotation(ObjectReference akRef, bool firstPerson, bool isFemale, string nodeName, string key, float[] rotation) native global

; Returns a rotation override for the particular key
; type 0 - size 3 euler angles in degrees
; type 1 - size 9 matrix
float[] Function GetNodeTransformRotation(ObjectReference akRef, bool firstPerson, bool isFemale, string nodeName, string key, int type = 0) native global

; Checks whether there is a scale override for the particular parameters
bool Function HasNodeTransformScaleMode(ObjectReference akRef, bool firstPerson, bool isFemale, string nodeName, string key) native global

; Adds a scale mode override for a node, Modes=[0,1,2,3] [Multiplicative,Averaged,Additive,Maximum]
Function AddNodeTransformScaleMode(ObjectReference akRef, bool firstPerson, bool isFemale, string nodeName, string key, int scaleMode) native global

; Returns a scale mode override for the particular key, -1 if non-existent
float Function GetNodeTransformScaleMode(ObjectReference akRef, bool firstPerson, bool isFemale, string nodeName, string key) native global

; Removes a particular scale mode override, returns true if it removed, false if did not exist
bool Function RemoveNodeTransformScaleMode(ObjectReference akRef, bool firstPerson, bool isFemale, string nodeName, string key) native global


; Returns the inverse scale, alters the in pos to the inverse out pos and the in rotation to the out inverse rotation
; Accepts either a size 3 rotation of euler degrees, or a 9 radian matrix
float Function GetInverseTransform(float[] in_out_pos, float[] in_out_rotation, float in_scale = 1.0) native global

; Removes a particular scale override, returns true if it removed, false if did not exist
bool Function RemoveNodeTransformRotation(ObjectReference akRef, bool firstPerson, bool isFemale, string nodeName, string key) native global

; Updates and computes ALL resulting transformation overrides for the particular reference
; This should not need to be called under normal circumstances
Function UpdateAllReferenceTransforms(ObjectReference akRef) native global

; Removes all transforms for a particular reference
Function RemoveAllReferenceTransforms(ObjectReference akRef) native global

; Removes all transforms from all references
Function RemoveAllTransforms() native global

; Updates and computes a particular node's transformation override
; Use this after changing a particular override
Function UpdateNodeTransform(ObjectReference akRef, bool firstPerson, bool isFemale, string nodeName) native global

; These function parts move a node to be a child of the destination node
; Moves a node from one the current parent to another, there can only be ONE of these overrides, call UpdateNodeTransform
Function SetNodeDestination(ObjectReference akRef, bool firstPerson, bool isFemale, string nodeName, string destination) native global

; Returns the node destination of the particular parameters
string Function GetNodeDestination(ObjectReference akRef, bool firstPerson, bool isFemale, string nodeName) native global

; Removes a node destination for a particular node, does not revert the physical mesh, only removes the key
bool Function RemoveNodeDestination(ObjectReference akRef, bool firstPerson, bool isFemale, string nodeName) native global

; These functions can be used to walk all of the current nodes if necessary
; Returns an array of all the altered nodes for the particular reference, skeleton, and gender
string[] Function GetNodeTransformNames(ObjectReference akRef, bool firstPerson, bool isFemale) native global

; Returns an array of all the existing key'd transforms to the particular node
; NodeDestination is a special key
string[] Function GetNodeTransformKeys(ObjectReference akRef, bool firstPerson, bool isFemale, string nodeName) native global
; --------------------------------------------------------------------


; NiExtraData Acquisition
bool Function GetBooleanExtraData(ObjectReference akRef, bool firstPerson, string nodeName, string dataName) native global

float Function GetFloatExtraData(ObjectReference akRef, bool firstPerson, string nodeName, string dataName) native global
float[] Function GetFloatsExtraData(ObjectReference akRef, bool firstPerson, string nodeName, string dataName) native global

int Function GetIntegerExtraData(ObjectReference akRef, bool firstPerson, string nodeName, string dataName) native global
int[] Function GetIntegersExtraData(ObjectReference akRef, bool firstPerson, string nodeName, string dataName) native global

string Function GetStringExtraData(ObjectReference akRef, bool firstPerson, string nodeName, string dataName) native global
string[] Function GetStringsExtraData(ObjectReference akRef, bool firstPerson, string nodeName, string dataName) native global