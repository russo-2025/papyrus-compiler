Scriptname RaceMenuBase extends Quest

string Property RACESEX_MENU = "RaceSex Menu" Autoreadonly
string Property MENU_ROOT = "_root.RaceSexMenuBaseInstance.RaceSexPanelsInstance." Autoreadonly

int Property CATEGORY_RACE = 2 AutoReadOnly
int Property CATEGORY_BODY = 4 AutoReadOnly
int Property CATEGORY_HEAD = 8 AutoReadOnly
int Property CATEGORY_FACE = 16 AutoReadOnly
int Property CATEGORY_EYES = 32 AutoReadOnly
int Property CATEGORY_BROW = 64 AutoReadOnly
int Property CATEGORY_MOUTH = 128 AutoReadOnly
int Property CATEGORY_HAIR = 256 AutoReadOnly
int Property CATEGORY_EXTRA = 512 AutoReadOnly

int Property BUFFER_TEXTURES = 1 AutoReadOnly
int Property BUFFER_CATEGORIES = 2 AutoReadOnly
int Property BUFFER_SLIDERS = 4 AutoReadOnly

Actor Property _playerActor Auto
ActorBase Property _playerActorBase Auto

string Property _targetMenu = "" Auto
string Property _targetRoot = "" Auto

Actor Property _targetActor = None Auto
ActorBase Property _targetActorBase = None Auto

string[] _categories = None
int _categoryBuffer = 0

string[] _textures = None
int _textureBuffer = 0

; Body Paint
string[] _textures_body = None
int _textureBuffer_body = 0

; Hand Paint
string[] _textures_hand = None
int _textureBuffer_hand = 0

; Feet Paint
string[] _textures_feet = None
int _textureBuffer_feet = 0

; Face Paint
string[] _textures_face = None
int _textureBuffer_face = 0

string[] _sliders = None
int _sliderBuffer = 0

int Function GetScriptVersionRelease() global
	return 7
EndFunction

Event OnInit()
	_playerActor = Game.GetPlayer()
	_playerActorBase = _playerActor.GetActorBase()

	OnInitialized()

	OnStartup()
EndEvent

Event OnInitialized()
	_textures = new string[128]
	_textureBuffer = 0

	_sliders = new string[128]
	_sliderBuffer = 0

	_categories = new string[128]
	_categoryBuffer = 0

	; Body Paint
	_textures_body = new string[128]
	_textureBuffer_body = 0

	; Hand Paint
	_textures_hand = new string[128]
	_textureBuffer_hand = 0

	; Feet Paint
	_textures_feet = new string[128]
	_textureBuffer_feet = 0

	; Face Paint
	_textures_face = new string[128]
	_textureBuffer_face = 0
EndEvent

; Reinitializes variables if necessary
Function Reinitialize()
	If !_textures
		_textures = new string[128]
		_textureBuffer = 0
	Endif
	If !_sliders
		_sliders = new string[128]
		_sliderBuffer = 0
	Endif
	If !_categories
		_categories = new string[128]
		_categoryBuffer = 0
	Endif
	If !_textures_body
		_textures_body = new string[128]
		_textureBuffer_body = 0
	Endif
	If !_textures_hand
		_textures_hand = new string[128]
		_textureBuffer_hand = 0
	Endif
	If !_textures_feet
		_textures_feet = new string[128]
		_textureBuffer_feet = 0
	Endif
	If !_textures_face
		_textures_face = new string[128]
		_textureBuffer_face = 0
	Endif
EndFunction

Event OnGameReload()
	OnStartup()
	Reinitialize()
EndEvent

Event OnCellLoaded(ObjectReference akRef)
	; Do nothing
EndEvent

Event OnChangeRace(Actor akActor)
	; Do nothing
EndEvent

Event On3DLoaded(ObjectReference akRef)
	; Do nothing
EndEvent

Function RegisterEvents()
	RegisterForModEvent("RSM_Initialized", "OnMenuInitialized")
	RegisterForModEvent("RSM_Reinitialized", "OnMenuReinitialized")
	RegisterForModEvent("RSM_SliderChange", "OnMenuSliderChange") ; Event sent when a slider's value is changed
	RegisterForModEvent("RSM_LoadPlugins", "OnMenuLoadPlugins")
	RegisterForModEvent("RSM_CategoriesInitialized", "OnMenuCategoriesInitialized")

	; RaceSexMenu Data Transfer
	RegisterForModEvent("RSMDT_SendTargetActor", "OnReceiveTargetActor")
	RegisterForModEvent("RSMDT_SendMenuName", "OnReceiveMenuName")
	RegisterForModEvent("RSMDT_SendRootName", "OnReceiveRootName")
	RegisterForModEvent("RSMDT_SendPrefix", "OnReceivePrefix")
	RegisterForModEvent("RSMDT_SendDataRequest", "OnReceiveDataRequest")
	RegisterForModEvent("RSMDT_SendRestore", "OnReceiveRestore")
EndFunction

Event OnStartup()
	RegisterEvents()

	_targetMenu = RACESEX_MENU
	_targetRoot = MENU_ROOT
	
	OnReceiveTargetActor(_playerActor)
EndEvent

Function OnReceiveTargetActor(Form target)
	_targetActor = target as Actor
	_targetActorBase = _targetActor.GetActorBase()
EndFunction

Event OnReceivePrefix(string eventName, string strArg, float numArg, Form formArg)
	UnregisterForModEvent("RSM_Initialized")
	UnregisterForModEvent("RSM_Reinitialized")
	UnregisterForModEvent("RSM_CategoriesInitialized")
	UnregisterForModEvent("RSM_SliderChange")
	UnregisterForModEvent("RSM_LoadPlugins")

	RegisterForModEvent(strArg + "_Initialized", "OnMenuInitialized")
	RegisterForModEvent(strArg + "_Reinitialized", "OnMenuReinitialized")
	RegisterForModEvent(strArg + "_CategoriesInitialized", "OnMenuCategoriesInitialized")
	RegisterForModEvent(strArg + "_SliderChange", "OnMenuSliderChange") ; Event sent when a slider's value is changed
	RegisterForModEvent(strArg + "_LoadPlugins", "OnMenuLoadPlugins")
EndEvent

Event OnReceiveMenuName(string eventName, string strArg, float numArg, Form formArg)
	_targetMenu = strArg
EndEvent

Event OnReceiveRootName(string eventName, string strArg, float numArg, Form formArg)
	_targetRoot = strArg
EndEvent

Event OnReceiveRestore(string eventName, string strArg, float numArg, Form formArg)
	_targetMenu = RACESEX_MENU
	_targetRoot = MENU_ROOT

	OnReceiveTargetActor(_playerActor)
EndEvent

Event OnReceiveDataRequest(string eventName, string strArg, float numArg, Form formArg)
	int requestFlag = numArg as int
	bool sendWarPaint = Math.LogicalAnd(requestFlag, 0x01) == 0x01
	bool sendBodyPaint = Math.LogicalAnd(requestFlag, 0x02) == 0x02
	bool sendHandPaint = Math.LogicalAnd(requestFlag, 0x04) == 0x04
	bool sendFeetPaint = Math.LogicalAnd(requestFlag, 0x08) == 0x08
	bool sendFacePaint = Math.LogicalAnd(requestFlag, 0x10) == 0x10
	bool sendSliders = Math.LogicalAnd(requestFlag, 0x20) == 0x20
	bool sendCategories = Math.LogicalAnd(requestFlag, 0x40) == 0x40
	If sendCategories
		OnCategoryRequest()
	Endif
	If sendWarPaint
		OnWarpaintRequest()
	Endif
	If sendBodyPaint
		OnBodyPaintRequest()
	Endif
	If sendHandPaint
		OnHandPaintRequest()
	Endif
	If sendFeetPaint
		OnFeetPaintRequest()
	Endif
	If sendFacePaint
		OnFacePaintRequest()
	Endif
	If sendWarPaint
		AddWarpaints(_textures)
	Endif
	If sendBodyPaint
		AddBodyPaints(_textures_body)
	Endif
	If sendHandPaint
		AddHandPaints(_textures_hand)
	Endif
	If sendFeetPaint
		AddFeetPaints(_textures_feet)
	Endif
	If sendFacePaint
		AddFacePaints(_textures_face)
	Endif
	If sendSliders
		OnSliderRequest(_targetActor, _targetActorBase, _targetActorBase.GetRace(), _targetActorBase.GetSex() as bool)
		AddSliders(_sliders)
	Endif
	If sendCategories
		AddCategories(_categories)
	Endif
	If sendWarPaint || sendBodyPaint || sendHandPaint || sendFeetPaint || sendFacePaint || sendCategories
		int flushType = BUFFER_TEXTURES
		If sendSliders
			flushType += BUFFER_SLIDERS
		Endif
		If sendCategories
			flushType += BUFFER_CATEGORIES
		Endif
		FlushBuffer(flushType)
	Endif
EndEvent

Event OnMenuInitialized(string eventName, string strArg, float numArg, Form formArg)
	OnWarpaintRequest()
	OnBodyPaintRequest()
	OnHandPaintRequest()
	OnFeetPaintRequest()
	OnFacePaintRequest()
	AddWarpaints(_textures)
	AddBodyPaints(_textures_body)
	AddHandPaints(_textures_hand)
	AddFeetPaints(_textures_feet)
	AddFacePaints(_textures_face)
	OnInitializeMenu(_targetActor, _targetActorBase)
	OnSliderRequest(_targetActor, _targetActorBase, _targetActorBase.GetRace(), _targetActorBase.GetSex() as bool)
	AddSliders(_sliders)
	FlushBuffer(BUFFER_TEXTURES + BUFFER_SLIDERS)
EndEvent

Event OnMenuReinitialized(string eventName, string strArg, float numArg, Form formArg)
	OnResetMenu(_targetActor, _targetActorBase)
	OnSliderRequest(_targetActor, _targetActorBase, _targetActorBase.GetRace(), _targetActorBase.GetSex() as bool)
	AddSliders(_sliders)
	FlushBuffer(BUFFER_SLIDERS)
EndEvent

Event OnMenuCategoriesInitialized(string eventName, string strArg, float numArg, Form formArg)
	OnCategoryRequest()
	AddCategories(_categories)
	FlushBuffer(BUFFER_CATEGORIES)
EndEvent

Event OnMenuSliderChange(string eventName, string strArg, float numArg, Form formArg)
	OnSliderChanged(strArg, numArg)
EndEvent

Event OnMenuLoadPlugins(string eventName, string strArg, float numArg, Form formArg)
	OnReloadSettings(_targetActor, _targetActorBase)
EndEvent

Event OnReloadSettings(Actor player, ActorBase playerBase)
	; Do nothing
EndEvent

Event OnWarpaintRequest()
	; Do nothing
EndEvent

Event OnBodyPaintRequest()
	; Do nothing
EndEvent

Event OnHandPaintRequest()
	; Do nothing
EndEvent

Event OnFeetPaintRequest()
	; Do nothing
EndEvent

Event OnFacePaintRequest()
	; Do nothing
EndEvent

Event OnInitializeMenu(Actor player, ActorBase playerBase)
	; Do nothing
EndEvent

Event OnResetMenu(Actor player, ActorBase playerBase)
	; Do nothing
EndEvent

Event OnSliderRequest(Actor player, ActorBase playerBase, Race actorRace, bool isFemale)
	; Do nothing
EndEvent

Event OnCategoryRequest()
	; Do nothing
EndEvent

Event OnSliderChanged(string callback, float value)
	; Do nothing
EndEvent

Function AddWarpaint(string name, string texturePath)
	_textures[_textureBuffer] = name + ";;" + texturePath
	_textureBuffer += 1
	if _textureBuffer == _textures.length
		string[] textures = Utility.CreateStringArray(_textures.length + _textures.length / 2)
		if textures.length > 0
			int i = 0
			While i < _textures.length
				textures[i] = _textures[i]
				i += 1
			EndWhile

			_textures = textures
		Endif
	Endif
EndFunction

Function AddBodyPaint(string name, string texturePath)
	_textures_body[_textureBuffer_body] = name + ";;" + texturePath
	_textureBuffer_body += 1

	if _textureBuffer_body == _textures_body.length
		string[] textures = Utility.CreateStringArray(_textures_body.length + _textures_body.length / 2)
		if textures.length > 0
			int i = 0
			While i < _textures_body.length
				textures[i] = _textures_body[i]
				i += 1
			EndWhile

			_textures_body = textures
		Endif
	Endif
EndFunction

Function AddBodyPaintEx(string name, string texture0, string texture1 = "ignore", string texture2 = "ignore", string texture3 = "ignore", string texture4 = "ignore", string texture5 = "ignore", string texture6 = "ignore", string texture7 = "ignore")
	_textures_body[_textureBuffer_body] = name + ";;" + texture0 + "|" + texture1 + "|" + texture2 + "|" + texture3 + "|" + texture4 + "|" + texture5 + "|" + texture6 + "|" + texture7
	_textureBuffer_body += 1

	if _textureBuffer_body == _textures_body.length
		string[] textures = Utility.CreateStringArray(_textures_body.length + _textures_body.length / 2)
		if textures.length > 0
			int i = 0
			While i < _textures_body.length
				textures[i] = _textures_body[i]
				i += 1
			EndWhile

			_textures_body = textures
		Endif
	Endif
EndFunction

Function AddHandPaint(string name, string texturePath)
	_textures_hand[_textureBuffer_hand] = name + ";;" + texturePath
	_textureBuffer_hand += 1

	if _textureBuffer_hand == _textures_hand.length
		string[] textures = Utility.CreateStringArray(_textures_hand.length + _textures_hand.length / 2)
		if textures.length > 0
			int i = 0
			While i < _textures_hand.length
				textures[i] = _textures_hand[i]
				i += 1
			EndWhile

			_textures_hand = textures
		Endif
	Endif
EndFunction

Function AddHandPaintEx(string name, string texture0, string texture1 = "ignore", string texture2 = "ignore", string texture3 = "ignore", string texture4 = "ignore", string texture5 = "ignore", string texture6 = "ignore", string texture7 = "ignore")
	_textures_hand[_textureBuffer_hand] = name + ";;" + texture0 + "|" + texture1 + "|" + texture2 + "|" + texture3 + "|" + texture4 + "|" + texture5 + "|" + texture6 + "|" + texture7
	_textureBuffer_hand += 1

	if _textureBuffer_hand == _textures_hand.length
		string[] textures = Utility.CreateStringArray(_textures_hand.length + _textures_hand.length / 2)
		if textures.length > 0
			int i = 0
			While i < _textures_hand.length
				textures[i] = _textures_hand[i]
				i += 1
			EndWhile

			_textures_hand = textures
		Endif
	Endif
EndFunction

Function AddFeetPaint(string name, string texturePath)
	_textures_feet[_textureBuffer_feet] = name + ";;" + texturePath
	_textureBuffer_feet += 1

	if _textureBuffer_feet == _textures_feet.length
		string[] textures = Utility.CreateStringArray(_textures_feet.length + _textures_feet.length / 2)
		if textures.length > 0
			int i = 0
			While i < _textures_feet.length
				textures[i] = _textures_feet[i]
				i += 1
			EndWhile

			_textures_feet = textures
		Endif
	Endif
EndFunction

Function AddFeetPaintEx(string name, string texture0, string texture1 = "ignore", string texture2 = "ignore", string texture3 = "ignore", string texture4 = "ignore", string texture5 = "ignore", string texture6 = "ignore", string texture7 = "ignore")
	_textures_feet[_textureBuffer_feet] = name + ";;" + texture0 + "|" + texture1 + "|" + texture2 + "|" + texture3 + "|" + texture4 + "|" + texture5 + "|" + texture6 + "|" + texture7
	_textureBuffer_feet += 1

	if _textureBuffer_feet == _textures_feet.length
		string[] textures = Utility.CreateStringArray(_textures_feet.length + _textures_feet.length / 2)
		if textures.length > 0
			int i = 0
			While i < _textures_feet.length
				textures[i] = _textures_feet[i]
				i += 1
			EndWhile

			_textures_feet = textures
		Endif
	Endif
EndFunction

Function AddFacePaint(string name, string texturePath)
	_textures_face[_textureBuffer_face] = name + ";;" + texturePath
	_textureBuffer_face += 1

	if _textureBuffer_face == _textures_face.length
		string[] textures = Utility.CreateStringArray(_textures_face.length + _textures_face.length / 2)
		if textures.length > 0
			int i = 0
			While i < _textures_face.length
				textures[i] = _textures_face[i]
				i += 1
			EndWhile

			_textures_face = textures
		Endif
	Endif
EndFunction

Function AddFacePaintEx(string name, string texture0, string texture1 = "ignore", string texture2 = "ignore", string texture3 = "ignore", string texture4 = "ignore", string texture5 = "ignore", string texture6 = "ignore", string texture7 = "ignore")
	_textures_face[_textureBuffer_face] = name + ";;" + texture0 + "|" + texture1 + "|" + texture2 + "|" + texture3 + "|" + texture4 + "|" + texture5 + "|" + texture6 + "|" + texture7
	_textureBuffer_face += 1

	if _textureBuffer_face == _textures_face.length
		string[] textures = Utility.CreateStringArray(_textures_face.length + _textures_face.length / 2)
		if textures.length > 0
			int i = 0
			While i < _textures_face.length
				textures[i] = _textures_face[i]
				i += 1
			EndWhile

			_textures_face = textures
		Endif
	Endif
EndFunction

Function AddSlider(string name, int section, string callback, float min, float max, float interval, float position)
	_sliders[_sliderBuffer] = name + ";;" + section + ";;" + callback + ";;" + min + ";;" + max + ";;" + interval + ";;" + position
	_sliderBuffer += 1

	if _sliderBuffer == _sliders.length
		string[] sliders = Utility.CreateStringArray(_sliders.length + _sliders.length / 2)
		if sliders.length > 0
			int i = 0
			While i < _sliders.length
				sliders[i] = _sliders[i]
				i += 1
			EndWhile

			_sliders = sliders
		Endif
	Endif
EndFunction

Function AddSliderEx(string name, string category_key, string callback, float min, float max, float interval, float position, int section = 0, int priority = 0)
	_sliders[_sliderBuffer] = name + ";;" + section + ";;" + callback + ";;" + min + ";;" + max + ";;" + interval + ";;" + position + ";;" + category_key + ";;" + priority
	_sliderBuffer += 1

	if _sliderBuffer == _sliders.length
		string[] sliders = Utility.CreateStringArray(_sliders.length + _sliders.length / 2)
		if sliders.length > 0
			int i = 0
			While i < _sliders.length
				sliders[i] = _sliders[i]
				i += 1
			EndWhile

			_sliders = sliders
		Endif
	Endif
EndFunction

Function AddCategory(string keyName, string name, int priority = 0)
	_categories[_categoryBuffer] = keyName + ";;" + name + ";;" + priority
	_categoryBuffer += 1

	if _categoryBuffer == _categories.length
		string[] categories = Utility.CreateStringArray(_categories.length + _categories.length / 2)
		if categories.length > 0
			int i = 0
			While i < _categories.length
				categories[i] = _categories[i]
				i += 1
			EndWhile

			_categories = categories
		Endif
	Endif
EndFunction

Function AddWarpaints(string[] textures)
	UI.InvokeStringA(_targetMenu, _targetRoot + "RSM_AddWarpaints", textures)
EndFunction

Function AddBodyPaints(string[] textures)
	UI.InvokeStringA(_targetMenu, _targetRoot + "RSM_AddBodyPaints", textures)
EndFunction

Function AddHandPaints(string[] textures)
	UI.InvokeStringA(_targetMenu, _targetRoot + "RSM_AddHandPaints", textures)
EndFunction

Function AddFeetPaints(string[] textures)
	UI.InvokeStringA(_targetMenu, _targetRoot + "RSM_AddFeetPaints", textures)
EndFunction

Function AddFacePaints(string[] textures)
	UI.InvokeStringA(_targetMenu, _targetRoot + "RSM_AddFacePaints", textures)
EndFunction

Function AddSliders(string[] sliders)
	UI.InvokeStringA(_targetMenu, _targetRoot + "RSM_AddSliders", sliders)
EndFunction

Function AddCategories(string[] categories)
	UI.InvokeStringA(_targetMenu, _targetRoot + "RSM_AddCategories", categories)
EndFunction

Function SetSliderParameters(string callback, float min, float max, float interval, float position)
	string[] params = new string[5]
	params[0] = callback
	params[1] = min as string
	params[2] = max as string
	params[3] = interval as string
	params[4] = position as string
	UI.InvokeStringA(_targetMenu, _targetRoot + "RSM_SetSliderParameters", params)
EndFunction

Function SetSliderParametersEx(string[] callback, float[] min, float[] max, float[] interval, float[] position, int[] flags)
	string[] params = new string[6]

	if callback.length > 0
		params[0] = callback[0]
		params[1] = min[0] as string
		params[2] = max[0] as string
		params[3] = interval[0] as string
		params[4] = position[0] as string
		params[5] = flags[0] as string

		int i = 1
		While i < callback.length
			params[0] = params[0] + ";;" + callback[i]
			params[1] = params[1] + ";;" + min[i] as string
			params[2] = params[2] + ";;" + max[i] as string
			params[3] = params[3] + ";;" + interval[i] as string
			params[4] = params[4] + ";;" + position[i] as string
			params[5] = params[5] + ";;" + flags[i] as string
			i += 1
		EndWhile
	EndIf

	UI.InvokeStringA(_targetMenu, _targetRoot + "RSM_SetSliderParametersEx", params)
EndFunction

; 1 - Texture Buffers
; 2 - Slider Buffers
; 4 - Category Buffer

; 3 - Both Buffers
; 5
Function FlushBuffer(int bufferType)
	int i = 0

	; Overwriting the entire buffers will be faster than iterating and assigning
	if Math.LogicalAnd(bufferType, BUFFER_TEXTURES) == BUFFER_TEXTURES
		_textures = Utility.CreateStringArray(_textures.length)
		_textureBuffer = 0

		_textures_body = Utility.CreateStringArray(_textures_body.length)
		_textureBuffer_body = 0

		_textures_hand = Utility.CreateStringArray(_textures_hand.length)
		_textureBuffer_hand = 0

		_textures_feet = Utility.CreateStringArray(_textures_feet.length)
		_textureBuffer_feet = 0

		_textures_face = Utility.CreateStringArray(_textures_face.length)
		_textureBuffer_face = 0
	Endif

	if Math.LogicalAnd(bufferType, BUFFER_SLIDERS) == BUFFER_SLIDERS
		_sliders = Utility.CreateStringArray(_sliders.length)
		_sliderBuffer = 0
	Endif

	if Math.LogicalAnd(bufferType, BUFFER_CATEGORIES) == BUFFER_CATEGORIES
		_categories = Utility.CreateStringArray(_categories.length)
		_categoryBuffer = 0
	Endif

	; Reinit incase we're still using an older SKSE version that would kill the buffers
	Reinitialize()
EndFunction
