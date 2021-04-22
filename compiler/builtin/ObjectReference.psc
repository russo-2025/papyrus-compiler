ScriptName ObjectReference extends Form

float Function GetDistance(ObjectReference akOther) native
Function RemoveAllItems(ObjectReference akTransferTo = None, bool abKeepOwnership = false, bool abRemoveQuestItems = false) native
Function AddItem(Form akItemToAdd, int aiCount = 1, bool abSilent = false) native
Function RemoveItem(Form akItemToRemove, int aiCount = 1, bool abSilent = false, ObjectReference akOtherContainer = None) native
int Function GetItemCount(Form akItem) native
ObjectReference Function PlaceAtMe(Form akFormToPlace, int aiCount = 1, bool abForcePersist = false, bool abInitiallyDisabled = false) native
int Function GetCurrentDestructionStage() native
int Function GetItemCount(Form akItem) native
Form[] Function GetContainerForms() native
string Function GetDisplayName() native
Function Disable(bool abFadeOut = False) native
bool Function SetDisplayName(string name, bool force = false) Native
Form Function GetBaseObject() Native
Function SetPosition(float afX, float afY, float afZ) Native
Function SetAngle(float afXAngle, float afYAngle, float afZAngle) Native
Function DamageObject(float afDamage) Native
Function ClearDestruction() Native
bool Function IsInInterior() Native
Cell Function GetParentCell() Native
WorldSpace Function GetWorldSpace() Native
Function SetScale(float afScale) native
