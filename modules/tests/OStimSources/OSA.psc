ScriptName OSA


;  ██████╗ ███████╗ █████╗
; ██╔═══██╗██╔════╝██╔══██╗
; ██║   ██║███████╗███████║  Functions for papyrus developers to interact with OSA.
; ██║   ██║╚════██║██╔══██║      Play OSA Scenes, use OSA effects, format csv strings for the UI. etc.
; ╚██████╔╝███████║██║  ██║
;  ╚═════╝ ╚══════╝╚═╝  ╚═╝
;  █████╗█████╗█████╗█████╗
;  ╚════╝╚════╝╚════╝╚════╝
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


Bool Function Exists() Global
    If (Quest.GetQuest("0SA"))
        Return True
    else
        Return False
    EndIf
EndFunction

Bool Function ModuleExists(String ModuleID) Global
    If (UI.getInt("HUD Menu", "_root.WidgetContainer." + (Quest.GetQuest("0SA") as _oOmni).Glyph + ".widget.__" + ModuleID) == 1)
        Return True
    else
        Return False
    EndIf
EndFunction

; API event that begins a basic scene. Intended to be the permenant stable trigger.
; (Type1) Intended as the permenant stable version.


;  ___    ___   ___   _  _   ___      ___   ___   ___     _     _____   ___    ___    _  _
; / __|  / __| | __| | \| | | __|    / __| | _ \ | __|   /_\   |_   _| |_ _|  / _ \  | \| |
; \__ \ | (__  | _|  | .` | | _|    | (__  |   / | _|   / _ \    | |    | |  | (_) | | .` |
; |___/  \___| |___| |_|\_| |___|    \___| |_|_\ |___| /_/ \_\   |_|   |___|  \___/  |_|\_|


; Creates an actionscript shell for the stage with all properties.
; This allows the scene to be configured before being launched.
String[] Function MakeStage() Global
    String Password = OSANative.RandomInt(0, 999999) as String
    OGlyphS(".glyph.makeStage", Password)
    String[] SceneBuilder = new String[20]
    SceneBuilder[0] = oGlyphGS(".glyph.ref." + Password)
    Return SceneBuilder
EndFunction

; Relays the actors to the actionscript to become Actor Objects.
; It then run checks to see if the actors are approved for OSA Scenes
; If they are approved it sends them to _oOmni to be full buffed up.
; Could use a function to abort the scene if failed.

Bool Function SetActors(String[] SceneSuite, Actor[] Actra) Global
    OsexIntegrationMain OsexCore = OUtils.getostim()
    OsexCore.AcceptReroutingActors(Actra[0], Actra[1])
    Return True
EndFunction

Bool Function SetActorsStim(String[] SceneSuite, Actor[] Actra) Global

    Int i = 0
    Int L = Actra.length
    While (i < L)
        SceneSuite[i + 1] = ID(Actra[i])
        i += 1
    EndWhile

    OGlyphSS(".glyph.setActors", PapyrusUtil.SliceStringArray(SceneSuite, 0, L))
    Faction StatusFaction = Game.GetFormFromFile(0x00006190, "OSA.esm") as Faction

    Bool Approved = True

    i = 0
    While (i < L)
        If (_oGlobal.CheckActra(SceneSuite[0], Actra[i], StatusFaction))
            i += 1
        else
            Approved = False
            i + 99
        EndIf
    EndWhile

    


    If (Approved)
        (Quest.GetQuest("0SA") as _oOmni).PrepActra(SceneSuite, Actra)
    Endif

    Return Approved
EndFunction

String[] Function SceneFlags(String[] SceneSuite)
    Return Settings(SceneSuite[0])
EndFunction

String[] Function Settings(String stageID)
    String[] Settings = new String[1]
    Settings[0] = stageID
    Return Settings
EndFunction

; Checks to see if the actor is allowed to participate.
; This does not include the OSABusyFaction check due to form dependancy
Bool Function IsAllowed(Actor Actra, Bool Creature = False) Global
    If (!Creature)
        If (!OUtils.ischild(actra))
            If (Actra.HasKeywordString("ActorTypeNPC"))
                ;If (!Actra.HasKeywordString("ActorTypeCreature"))
                    Return True
                ;EndIf
            EndIf
        EndIf
    EndIf
    Return False
EndFunction

Function SetModule(String[] SceneSuite, String ModuleID, String SceneID = "AUTO", String SceneLoc = "") Global
    SceneSuite[1] = ModuleID
    SceneSuite[2] = SceneID
    SceneSuite[3] = SceneLoc
    OGlyphSS(".glyph.setModule", SceneSuite)
EndFunction

Function SetPlan(String[] SceneSuite, String[] Plan) Global
    Plan[0] = SceneSuite[0]
    OGlyphSS(".glyph.setPlan", Plan)
EndFunction

String Function Plan(String MyPlan, String NewPlan) Global
    Return MyPlan + NewPlan + "__"
EndFunction

Function SetPlanString(String[] SceneSuite, String Plan) Global
    Plan = SceneSuite[0] + "__" + Plan
    OGlyphS(".glyph.setPlanString", Plan)
EndFunction

Function Start(String[] SceneSuite) Global
    OsexIntegrationMain OsexCore = game.GetFormFromFile(0x000801, "Ostim.esp") as OsexIntegrationMain
    OsexCore.StartReroutedScene()
EndFunction

Function stimstart(String[] SceneSuite) Global
    OGlyphSS(".glyph.startStage", SceneSuite)
EndFunction

Bool Function StimInstalledProper() Global
    Return True
Endfunction


;   ___   ___   _____
;  / __| | __| |_   _|
; | (_ | | _|    | |
;  \___| |___|   |_|
;  _       ___     ___     _     _____   ___    ___    _  _
; | |     / _ \   / __|   /_\   |_   _| |_ _|  / _ \  | \| |
; | |__  | (_) | | (__   / _ \    | |    | |  | (_) | | .` |
; |____|  \___/   \___| /_/ \_\   |_|   |___|  \___/  |_|\_|
;

; Makes a CSV String for the location where the scene should begin. (Version #2)
; Used to retrieve coordinate data for a start location from an objectReference
String Function GetPosObject(ObjectReference Object)
    Return Object.GetPositionX() + "," + Object.GetPositionY() + "," + Object.GetPositionZ() + "," + Object.GetAngleX() + "," + Object.GetAngleY() + "," + Object.GetAngleZ()
EndFunction

; Makes a CSV String for the location where the scene should begin. (Version #2)
; Used to retrieve coordinate data for a start location from an Actor
String Function GetPosActor(Actor Actra)
    Return Actra.GetPositionX() + "," + Actra.GetPositionY() + "," + Actra.GetPositionZ() + "," + Actra.GetAngleX() + "," + Actra.GetAngleY() + "," + Actra.GetAngleZ()
EndFunction

; Makes a CSV String for the location where the scene should begin. (Version #3)
; Use this version if you want to input the coordinates yourself based on your own calculations or if you want to use an exact spot.
String Function ScribePos(float PosX, float PosY, float PosZ, float RotX, float RotY, float RotZ)
    Return PosX + "," + PosY + "," + PosZ + "," + RotX + "," + RotY + "," + RotZ
EndFunction


;  ___    ___   ___   ___   ___   ___
; / __|  / __| | _ \ |_ _| | _ ) | __|
; \__ \ | (__  |   /  | |  | _ \ | _|
; |___/  \___| |_|_\ |___| |___/ |___|


; Makes a CSV String for the UI of flags that apply to all OSA scenes
String Function ScribeOFlags()
    Return ""
EndFunction

; Makes a CSV String for the UI of flags that apply to a specific module
String Function ScribeSceneFlags()
    Return ""
EndFunction

; Ease of life Function that takes a bunch of actors and makes and array as OSA expects it.
Actor[] Function ScribeActors(Actor a0, Actor a1 = None, Actor a2 = None, Actor a3 = None, Actor a4 = None, Actor a5 = None, Actor a6 = None, Actor a7 = None, Actor a8 = None) Global
    Actor[] ActorTeam = new Actor[1]
    ActorTeam[0] = a0
    If (a1)
        PapyrusUtil.PushActor(ActorTeam, a1)
        If (a2)
            PapyrusUtil.PushActor(ActorTeam, a2)
            If (a3)
                PapyrusUtil.PushActor(ActorTeam, a3)
                If (a4)
                    PapyrusUtil.PushActor(ActorTeam, a4)
                    If (a5)
                        PapyrusUtil.PushActor(ActorTeam, a5)
                        If (a6)
                            PapyrusUtil.PushActor(ActorTeam, a6)
                            If (a7)
                                PapyrusUtil.PushActor(ActorTeam, a7)
                                If (a8)
                                    PapyrusUtil.PushActor(ActorTeam, a8)
                                EndIf
                            EndIf
                        EndIf
                    EndIf
                EndIf
            EndIf
        EndIf
    EndIf
    Return ActorTeam
EndFunction


;  ___    ___    ___   __  __     ___   ___
; | __|  / _ \  | _ \ |  \/  |   |_ _| |   \
; | _|  | (_) | |   / | |\/| |    | |  | |) |
; |_|    \___/  |_|_\ |_|  |_|   |___| |___/

; Returns the always True FormID of an actor which OSA uses as a serial number.
; Note that this number will change with the users load order so it should not be used as a permenant identifier
; The actors events while they are in a scene can be registered for and listened to using this.
; Epic solution made by SF, thank you!
String Function ID(Actor Actra) Global
    Return _oGlobal.GetFormID_S(OSANative.GetLeveledActorBase(actra))
EndFunction


;   ___     ___   _     __   __  ___   _  _
;  / _ \   / __| | |    \ \ / / | _ \ | || |
; | (_) | | (_ | | |__   \ V /  |  _/ | __ |
;  \___/   \___| |____|   |_|   |_|   |_||_|

; These are not intended for developers to use to often but for
; very advanced stuff they can be used to directly trigger functions in the UI

; oGlyph is my cryptic designation for ID# of the UI for communication with the actionscript.
; It's retrieved and set in a global variable everytime the UI is rebooted.
; This allows outside develpoers to communicate directly with the UI without needing to master OSA

; The glyph will auto fill itself out if it's not given but it does use a game.getfile which might be expensive
; These most likely will not have to be used to often but if for some reason a developer needs to spam them
; I would recommend getting the glyph with oGlyph() and including it in your functions. Keep in mind that the
; OGlyph value could change everytime the game is reloaded so don't save it for permenant usage.
; It's life time usage should be restricted to one play session.

Function OGlyphO(String zMethod, Int Glyph = 0) Global
    Glyph = OGlyphValidate(Glyph)
    UI.Invoke("HUD Menu", "_root.WidgetContainer." + Glyph + ".widget" + zMethod)
EndFunction

Function OGlyphI(String zMethod, Int zInt, Int Glyph = 0) Global
    Glyph = OGlyphValidate(Glyph)
    UI.InvokeInt("HUD Menu", "_root.WidgetContainer." + Glyph + ".widget" + zMethod, zInt)
EndFunction

Function OGlyphS(String zMethod, String zString, Int Glyph = 0) Global
    Glyph = OGlyphValidate(Glyph)
    UI.InvokeString("HUD Menu", "_root.WidgetContainer." + Glyph + ".widget" + zMethod, zString)
EndFunction

Function OGlyphSS(String zMethod, String[] zStringArray, Int Glyph = 0) Global
    Glyph = OGlyphValidate(Glyph)
    UI.InvokeStringA("HUD Menu", "_root.WidgetContainer." + Glyph + ".widget" + zMethod, zStringArray)
EndFunction

String Function OGlyphGS(String Path, Int Glyph = 0) Global
    Glyph = OGlyphValidate(Glyph)
    Return UI.GetString("HUD Menu", "_root.WidgetContainer." + Glyph + ".widget" + Path)
EndFunction

; Validates the oGlyph
; If one isn't provided by the user in the parent function this will retrive
; the oGlyph value itself.
Int Function OGlyphValidate(Int Glyph) Global
    If (Glyph < 1)
        Return OGlyph()
    Else
        Return Glyph as Int
    Endif
EndFunction

Int Function OGlyph() Global
    ;OUtils.Console("Call to getquest")
    Return (Quest.GetQuest("0SUI") as _oUI).WidgetID
EndFunction


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
