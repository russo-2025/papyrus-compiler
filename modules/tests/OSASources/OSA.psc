Scriptname OSA




; ██████╗ ███████╗ █████╗                                                                                                                                             
;██╔═══██╗██╔════╝██╔══██╗                                                                                                                                            
;██║   ██║███████╗███████║  Functions for papyrus developers to interact with OSA.                                                                                 
;██║   ██║╚════██║██╔══██║      Play OSA Scenes, use OSA effects, format csv strings for the UI. etc.                                                                                                                       
;╚██████╔╝███████║██║  ██║                                                                                                                                            
; ╚═════╝ ╚══════╝╚═╝  ╚═╝                                                                                    
; █████╗█████╗█████╗█████╗                                                                                   
; ╚════╝╚════╝╚════╝╚════╝
;
;   ___    ___     _   
;  / _ \  / __|   /_\           | Skyrim Ascendancy
; | (_) | \__ \  / _ \          
;  \___/  |___/ /_/ \_\         | UI Expansion+
;          ___   ___    ___     
;         / __| | __|  / _ \    | Animation Framework+
;        | (__  | _|  | (_) |       
;     By  \___| |___|  \___/    | Character Persona/Personality Infuser+
;  
;
;   Papyrus and Actionscript made with tremendous support from: 
;     ___   ___   ___   ___    _   _   ___    ___ 
;    | _ \ |_ _| | _ \ |   \  | | | | |   \  | __|
;    |  _/  | |  |  _/ | |) | | |_| | | |) | | _| 
;    |_|   |___| |_|   |___/   \___/  |___/  |___|  My Champion
;
;     ___   ___ 
;    / __| | __|
;    \__ \ | _| 
;    |___/ |_|  
;            
;     __  __   ___    ___     _     _    
;    |  \/  | |_ _|  / __|   /_\   | |   
;    | |\/| |  | |  | (_ |  / _ \  | |__ 
;    |_|  |_| |___|  \___| /_/ \_\ |____|

;     ___    ___    ___    ___   ___   ___    ___    _  _     ___   _  __
;    / __|  / __|  / _ \  | _ \ | _ \ |_ _|  / _ \  | \| |   / __| | |/ /
;    \__ \ | (__  | (_) | |  _/ |   /  | |  | (_) | | .` |   \__ \ | ' < 
;    |___/  \___|  \___/  |_|   |_|_\ |___|  \___/  |_|\_|   |___/ |_|\_\
; 
;
;
;   OSA would not be possible or at least take a few more years to complete
;       without the invaluable help, bug-testing, and personal investment from: 
;
;
;         _  __  ___   _  _   _  __ __   __
;        | |/ / |_ _| | \| | | |/ / \ \ / /
;        | ' <   | |  | .` | | ' <   \ V / 
;        |_|\_\ |___| |_|\_| |_|\_\   |_|  
;
;         ___   ___    ___   __  __ __   __  ___    __ 
;        | _ \ | _ \  / _ \  \ \/ / \ \ / / ( _ )  / / 
;        |  _/ |   / | (_) |  >  <   \ V /  / _ \ / _ \
;        |_|   |_|_\  \___/  /_/\_\   |_|   \___/ \___/                                   
;
;
;   And the excellent assistance of people holding down the fort
;   on Nexus giving their time helping others getting OSA setup: 
;  __  __  __   __  ___   _____   ___   ___   ___    ___    _   _   ___ 
; |  \/  | \ \ / / / __| |_   _| | __| | _ \ |_ _|  / _ \  | | | | / __|
; | |\/| |  \ V /  \__ \   | |   | _|  |   /  | |  | (_) | | |_| | \__ \
; |_|  |_|   |_|   |___/  _|_|_  |___|_|_|_\ |___|  \___/   \___/  |___/
;                  / __| | | | | \ \ / /                                
;                 | (_ | | |_| |  \ V /                                 
;                  \___|  \___/    |_|                                  
;
;         _      _   _    ___     _     ___   _  _   __  __ 
;        | |    | | | |  / __|   /_\   / __| | || | |  \/  |
;        | |__  | |_| | | (__   / _ \  \__ \ | __ | | |\/| |
;        |____|  \___/   \___| /_/ \_\ |___/ |_||_| |_|  |_|
;                                                    
;
;   Thanks to the wonderfully supportive fans & users of OSA
;       Who's feedback and enthusiasm for this project kept
;           me motivated to finish it. 
;    This also includes the:
;     ___   ___   _      ___   _  _   _____                                      
;    / __| |_ _| | |    | __| | \| | |_   _|                                     
;    \__ \  | |  | |__  | _|  | .` |   | |                                       
;    |___/ |___|_|____| |___| |_|\_|  _|_|  _____     _     _  _   _____   ___   
;      /_\   / __| / __| |_ _| / __| / __| |_   _|   /_\   | \| | |_   _| / __|  
;     / _ \  \__ \ \__ \  | |  \__ \ \__ \   | |    / _ \  | .` |   | |   \__ \  
;    /_/_\_\ |___/ |___/ |___| |___/ |___/   |_|   /_/ \_\ |_|\_|   |_|   |___/  
;      /_\   | \| | |   \                                                        
;     / _ \  | .` | | |) |                                                       
;    /_/_\_\_|_|\_|_|___/    ___   _   _   ___   ___    ___    ___   _____   ___ 
;    / __| | || | \ \ / /   / __| | | | | | _ \ | _ \  / _ \  | _ \ |_   _| / __|
;    \__ \ | __ |  \ V /    \__ \ | |_| | |  _/ |  _/ | (_) | |   /   | |   \__ \
;    |___/ |_||_|   |_|     |___/  \___/  |_|   |_|    \___/  |_|_\   |_|   |___/
;                                                                             
;     Yea you know you who are...
;
;             ,.                 .,
;            ,: ':.    .,.    .:' :,
;            ,',   '.:'   ':.'   ,',
;            : '.  '         '  .' :
;            ', : '           ' : ,'
;           '.' .,:,.   .,:,. '.'
;             ,:    V '. .' V    :,
;            ,:        / '        :,
;            ,:                   :,
;            ,:       =:=       :,
;              ,: ,     :     , :,
;               :' ',.,' ',.,:' ':
;              :'      ':WW::'   '.
;             .:'       '::::'   ':
;             ,:        '::::'    :,
;             :'         ':::'    ':
;            ,:           ':''     :.
;           .:'             '.     ',.
;          ,:'               ''     '.
;          .:'               .',    ':
;         .:'               .'.,     :
;         .:                .,''     :
;         ::                .,''    ,:
;         ::              .,'','   .:'
;       .,::'.           .,','     ::::.
;     .:'     ',.       ,:,       ,WWWWW,
;     :'        :       :W:'     :WWWWWWW,          .,.
;     :         ',      WWW      WWWWWWWWW          '::,
;     '.         ',     WWW     :WWWWWWWWW            '::,
;      '.         :     WWW     :WWWWWWWW'             :::
;       '.       ,:     WWW     :WWWWWWW'             .:::
;        '.     .W:     WWW     :WWWWWW'           .,:::'
;         '.   :WW:     WWW     :WWWWW'      .,,:::::''
;        .,'   ''::     :W:     :WWWWW.  .,::::''
;     ,'        ''','',',','','''WWWWW::::''
;      ':,,,,,,,':  :  : : :  :  :WWWW'''
;
;
;                                      ~Thanks also to my cat
;                                        I love you so much
;
;  _ _  __      __  ___       _     ___   ___ 
; ( | ) \ \    / / | __|     /_\   | _ \ | __|
;  V V   \ \/\/ /  | _|     / _ \  |   / | _| 
;         \_/\_/   |___|   /_/ \_\ |_|_\ |___|
;                 ___  __   __  ___   ___   ___    ___    ___   __   __  _ _ 
;                | __| \ \ / / | __| | _ \ | _ )  / _ \  |   \  \ \ / / ( | )
;                | _|   \ V /  | _|  |   / | _ \ | (_) | | |) |  \ V /   V V 
;                |___|   \_/   |___| |_|_\ |___/  \___/  |___/    |_|        
;                                                          
;                                    -Charlie from Lost
;
;
;
;
; __      __  _  _     _     _____     ___   ___      ___    ___     _   
; \ \    / / | || |   /_\   |_   _|   |_ _| / __|    / _ \  / __|   /_\  
;  \ \/\/ /  | __ |  / _ \    | |      | |  \__ \   | (_) | \__ \  / _ \ 
;   \_/\_/   |_||_| /_/ \_\   |_|     |___| |___/    \___/  |___/ /_/ \_\
;
;
;   OSA is a framework to aid animators in putting seamless, 
;   interactive scenes into Skyrim without having to code 
;   Papyrus and do Creation Kit. The scene data is customized 
;   in XML and each document is meant to function as a 
;   pseudo creation kit form (basically for data that the 
;   creation kit doesn't have forms for.)
;
;   OSA exists in a scaleform actionscript UI script that is
;   loaded by Skyrim as a menu. While a majority of the script 
;   is handled there the papyrus scripts serve as ports for the
;   game to communicate with the UI and vice versa. The papyrus
;   side is light since the Actionscript is doing a majority of it.
;
;   OSA serves a few other purposes in giving actors enhanced
;   personality and persona data which the scenes use. It also
;   brings UI enhancements and additional overlay and display 
;   boxes to Skyrim.
;
;
;   ___    ___     _       ___    ___   ___   ___   ___   _____ 
;  / _ \  / __|   /_\     / __|  / __| | _ \ |_ _| | _ \ |_   _|
; | (_) | \__ \  / _ \    \__ \ | (__  |   /  | |  |  _/   | |  
;  \___/  |___/ /_/ \_\   |___/  \___| |_|_\ |___| |_|     |_|  
;         ___     _     __  __   ___   _     __   __
;        | __|   /_\   |  \/  | |_ _| | |    \ \ / /
;        | _|   / _ \  | |\/| |  | |  | |__   \ V / 
;        |_|   /_/ \_\ |_|  |_| |___| |____|   |_|  
;
;  OSA: Holds functions for use by papyrus developers to aid in OSA interaction.
;
; _oOmni: The persistent quest script that holds trigger keys and handles global requests from the UI.
;
; _oMega: Black Ops support script for _oOmni to keep it's primary stuff in global functions to ease clean saving.
;
; _oUI: The persistent quest script that boots the UI.
;
; _oActra: Spell that gives actors the ability to communicate with the UI.
;
; _oActraga: Spell that empowers actors to receive all scene commands from the UI.
;
; _oActro: Spell that functions as a stage and aids in coordinating multi actors in a scene.
;
; _oGlobal: Holds shared global functions for all OSA scripts.
;
; _oSpellTog: A small utility spell script for toggling magic effects. (Used by ActorLights)


bool function exists() global
If Quest.GetQuest("0SA")
return true
else
return false
endIf
endFunction

bool function moduleExists(string moduleID) global
if UI.getInt("HUD Menu", "_root.WidgetContainer."+(Quest.GetQuest("0SA") as _oOmni).glyph+".widget.__"+moduleID) == 1
return true
else
return false
endIf
endFunction



;API event that begins a basic scene. Intended to be the permenant stable trigger.
;(Type1) Intended as the permenant stable version.



;  ___    ___   ___   _  _   ___      ___   ___   ___     _     _____   ___    ___    _  _ 
; / __|  / __| | __| | \| | | __|    / __| | _ \ | __|   /_\   |_   _| |_ _|  / _ \  | \| |
; \__ \ | (__  | _|  | .` | | _|    | (__  |   / | _|   / _ \    | |    | |  | (_) | | .` |
; |___/  \___| |___| |_|\_| |___|    \___| |_|_\ |___| /_/ \_\   |_|   |___|  \___/  |_|\_|



; Creates an actionscript shell for the stage with all properties.
; This allows the scene to be configured before being launched.

string[] function makeStage() global
string password = utility.randomInt(0, 999999) as string
oGlyphS(".glyph.makeStage", password)
string[] sceneBuilder= new string[20]
sceneBuilder[0] = oGlyphGS(".glyph.ref."+password)
return sceneBuilder
endFunction

;Relays the actors to the actionscript to become Actor Objects.
;It then run checks to see if the actors are approved for OSA Scenes
;If they are approved it sends them to _oOmni to be full buffed up.
;Could use a function to abort the scene if failed.

bool function setActors(string[] sceneSuite, actor[] actra) global
int i = 0
int l = actra.length
while i < l
sceneSuite[i+1] = id(actra[i])
i+=1
endWhile
oGlyphSS(".glyph.setActors", PapyrusUtil.SliceStringArray(sceneSuite, 0, L))
i=0

faction statusFaction = Game.GetFormFromFile(0x00006190, "OSA.esm") as faction

bool approved = true
while i < l
    if _oGlobal.checkActra(sceneSuite[0], actra[i], statusFaction)
    i+=1
    else
    approved = false
    i+99
    endIf
endWhile

if approved == true
(Quest.GetQuest("0SA") as _oOmni).prepActra(sceneSuite, actra)
endif
return approved
endFunction

string[] function sceneFlags(string[] sceneSuite)
return settings(sceneSuite[0])
endFunction

string[] function settings(string stageID)
string[] settings = new String[1]
settings[0] = stageID
return settings 
endFunction

;Checks to see if the actor is allowed to participate.
;This does not include the OSABusyFaction check due to form dependancy

bool function isAllowed(actor actra, bool creature=false) global
    if !creature
        if(!actra.IsChild())
            if(actra.HasKeywordString("ActorTypeNPC"))
                if(!actra.HasKeywordString("ActorTypeCreature"))                    
                    return true
                else
                return false
                endif
            else
            return false
            endif
        else
        return false
        endif
    else
    return false
    endif
endFunction



function setModule(string[] sceneSuite, string moduleID, string sceneID="AUTO", string sceneLoc="") global
sceneSuite[1] = moduleID
sceneSuite[2] = sceneID
sceneSuite[3] = sceneLoc
oGlyphSS(".glyph.setModule", sceneSuite)
endFunction


function setPlan(string[] sceneSuite, string[] plan) global
plan[0] = sceneSuite[0]
oGlyphSS(".glyph.setPlan", plan)
endFunction

string function plan(string myPlan, string newPlan) global
return myPlan+newPlan+"__"
endFunction

function setPlanString(string[] sceneSuite, string plan) global
plan = sceneSuite[0] + "__" + plan
oGlyphS(".glyph.setPlanString", plan)
endFunction


function start(string[] sceneSuite) global
oGlyphSS(".glyph.startStage", sceneSuite)
endFunction
;   ___   ___   _____ 
;  / __| | __| |_   _|
; | (_ | | _|    | |  
;  \___| |___|   |_| 
;  _       ___     ___     _     _____   ___    ___    _  _ 
; | |     / _ \   / __|   /_\   |_   _| |_ _|  / _ \  | \| |
; | |__  | (_) | | (__   / _ \    | |    | |  | (_) | | .` |
; |____|  \___/   \___| /_/ \_\   |_|   |___|  \___/  |_|\_|
;

;Makes a CSV string for the location where the scene should begin. (Version #2)
;Used to retrieve coordinate data for a start location from an objectReference

string function getPosObject(ObjectReference Object)
return object.GetPositionX()+","+object.GetPositionY()+","+object.GetPositionZ()+","+object.GetAngleX()+","+object.GetAngleY()+","+object.GetAngleZ()
endFunction


;Makes a CSV string for the location where the scene should begin. (Version #2)
;Used to retrieve coordinate data for a start location from an Actor

string function getPosActor(Actor actra)
return actra.GetPositionX()+","+actra.GetPositionY()+","+actra.GetPositionZ()+","+actra.GetAngleX()+","+actra.GetAngleY()+","+actra.GetAngleZ()
endFunction


;Makes a CSV string for the location where the scene should begin. (Version #3)
;Use this version if you want to input the coordinates yourself based on your own calculations or if you want to use an exact spot.

string function scribePos(float posX, float posY, float posZ, float rotX, float rotY, float rotZ)
return posX+","+posY+","+posZ+","+rotX+","+rotY+","+rotZ
endFunction



;  ___    ___   ___   ___   ___   ___ 
; / __|  / __| | _ \ |_ _| | _ ) | __|
; \__ \ | (__  |   /  | |  | _ \ | _| 
; |___/  \___| |_|_\ |___| |___/ |___|
                                     

;Makes a CSV string for the UI of flags that apply to all OSA scenes

string function scribeOFlags()
return ""
endFunction

;Makes a CSV string for the UI of flags that apply to a specific module

string function scribeSceneFlags()
return ""
endFunction


;Ease of life Function that takes a bunch of actors and makes and array as OSA expects it.

actor[] function scribeActors(actor a0, actor a1=none, actor a2=none, actor a3=none, actor a4=none, actor a5=none, actor a6=none, actor a7=none, actor a8=none) global
actor[] actorTeam = new Actor[1]

actorTeam[0] = a0
if a1
papyrusUtil.PushActor(actorTeam, a1)
if a2
papyrusUtil.PushActor(actorTeam, a2)
if a3
papyrusUtil.PushActor(actorTeam, a3)
if a4
papyrusUtil.PushActor(actorTeam, a4)
if a5
papyrusUtil.PushActor(actorTeam, a5)
if a6
papyrusUtil.PushActor(actorTeam, a6)
if a7
papyrusUtil.PushActor(actorTeam, a7)
if a8
papyrusUtil.PushActor(actorTeam, a8)
endIf
endIf
endIf
endIf
endIf
endIf
endIf
endIf


return actorTeam
endFunction
;  ___    ___    ___   __  __     ___   ___  
; | __|  / _ \  | _ \ |  \/  |   |_ _| |   \ 
; | _|  | (_) | |   / | |\/| |    | |  | |) |
; |_|    \___/  |_|_\ |_|  |_|   |___| |___/ 
                                            
;Returns the always true formID of an actor which OSA uses as a serial number. 
;Note that this number will change with the users load order so it should not be used as a permenant identifier
;The actors events while they are in a scene can be registered for and listened to using this.

string function id(actor actra) global
return _oGlobal.GetFormID_s(actra.GetActorBase())
endFunction
;Epic solution made by SF, thank you!



 ;  ___     ___   _     __   __  ___   _  _ 
 ; / _ \   / __| | |    \ \ / / | _ \ | || |
 ;| (_) | | (_ | | |__   \ V /  |  _/ | __ |
 ; \___/   \___| |____|   |_|   |_|   |_||_|

;These are not intended for developers to use to often but for
;very advanced stuff they can be used to directly trigger functions in the UI
;
;oGlyph is my cryptic designation for ID# of the UI for communication with the actionscript. 
;It's retrieved and set in a global variable everytime the UI is rebooted.
;This allows outside develpoers to communicate directly with the UI without needing to master OSA

;The glyph will auto fill itself out if it's not given but it does use a game.getfile which might be expensive
;These most likely will not have to be used to often but if for some reason a developer needs to spam them
;I would recommend getting the glyph with oGlyph() and including it in your functions. Keep in mind that the
;OGlyph value could change everytime the game is reloaded so don't save it for permenant usage.
;It's life time usage should be restricted to one play session.

Function oGlyphO(string zMethod, int glyph=0) global
    glyph = oGlyphValidate(glyph)
    UI.Invoke("HUD Menu", "_root.WidgetContainer."+glyph+".widget"+zMethod)
EndFunction

Function oGlyphI(string zMethod, int zInt, int glyph=0) global
    glyph = oGlyphValidate(glyph)
    UI.InvokeInt("HUD Menu", "_root.WidgetContainer."+glyph+".widget"+zMethod, zInt)
EndFunction

Function oGlyphS(string zMethod, string zString, int glyph=0) global
    glyph = oGlyphValidate(glyph)
    UI.InvokeString("HUD Menu", "_root.WidgetContainer."+glyph+".widget"+zMethod, zString)
EndFunction

Function oGlyphSS(string zMethod, string[] zStringArray, int glyph=0) global
    glyph = oGlyphValidate(glyph)
    UI.InvokeStringA("HUD Menu", "_root.WidgetContainer."+glyph+".widget"+zMethod, zStringArray)
EndFunction

string Function oGlyphGS(string path, int glyph=0) global
        glyph = oGlyphValidate(glyph)
return  UI.GetString("HUD Menu", "_root.WidgetContainer."+glyph+".widget"+path)
EndFunction
;Validates the oGlyph
;If one isn't provided by the user in the parent function this will retrive
;the oGlyph value itself.

int function oGlyphValidate(int glyph) global
if glyph < 1
return oGlyph()
else
return glyph as int
endif
endFunction

int function oGlyph() global
return  (Quest.GetQuest("0SUI") as _oUI).WidgetID
endFunction


;
;
;
;             *     ,MMM8&&&.            *
;                  MMMM88&&&&&    .
;                 MMMM88&&&&&&&
;     *           MMM88&&&&&&&&
;                 MMM88&&&&&&&&
;                 'MMM88&&&&&&'
;                   'MMM8&&&'      *    
;           /\/|_      __/\\
;          /    -\    /-   ~\  .              '
;          \    = Y =T_ =   /
;           )==*(`     `) ~ \
;          /     \     /     \
;          |     |     ) ~   (
;         /       \   /     ~ \
;         \       /   \~     ~/
;  jgs_/\_/\__  _/_/\_/\__~__/_/\_/\_/\_/\_/\_
;  |  |  |  | ) ) |  |  | ((  |  |  |  |  |  |
;  |  |  |  |( (  |  |  |  \\ |  |  |  |  |  |
;  |  |  |  | )_) |  |  |  |))|  |  |  |  |  |
;  |  |  |  |  |  |  |  |  (/ |  |  |  |  |  |
;  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
;  Kitty Kisses Motherfucker