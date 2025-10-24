Scriptname MantellaConstants extends Quest hidden

string property HTTP_ROUTE_MAIN = "Mantella" auto
string property HTTP_ROUTE_STT = "stt" auto

string property HTTP_ERROR = "SKSE_HTTP_error" auto

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;          Mod events         ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; string property EVENT_ACTIONS = "MantellaConversation_Action_" auto
; string property EVENT_CONVERSATION_STARTED = "MantellaConversation_Started" auto
; string property EVENT_CONVERSATION_ENDED = "MantellaConversation_Ended" auto
; string property EVENT_CONVERSATION_NPC_ADDED = "MantellaConversation_NPC_Added" auto
; string property EVENT_CONVERSATION_NPC_REMOVED = "MantellaConversation_NPC_Removed" auto

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; JSON keys for communication ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

string property PREFIX = "mantella_" auto
string property KEY_REQUESTTYPE = "mantella_request_type" auto
string property KEY_REPLYTYPE = "mantella_reply_type" auto
string property KEY_INPUTTYPE = "mantella_input_type" auto

string property KEY_REQUEST_EXTRA_ACTIONS = "mantella_extra_actions" auto

;Conversation
string property KEY_REQUESTTYPE_INIT = "mantella_initialize" auto
string property KEY_REQUESTTYPE_STARTCONVERSATION = "mantella_start_conversation" auto
string property KEY_REQUESTTYPE_CONTINUECONVERSATION = "mantella_continue_conversation" auto
string property KEY_REQUESTTYPE_PLAYERINPUT = "mantella_player_input" auto
string property KEY_REQUESTTYPE_ENDCONVERSATION = "mantella_end_conversation" auto

string property KEY_REPLYTTYPE_INITCOMPLETED = "mantella_init_completed" auto
string property KEY_REPLYTTYPE_STARTCONVERSATIONCOMPLETED = "mantella_start_conversation_completed" auto

string property KEY_REPLYTYPE_NPCTALK = "mantella_npc_talk" auto
string property KEY_REPLYTYPE_PLAYERTALK = "mantella_player_talk" auto
string property KEY_REPLYTYPE_NPCACTION = "mantella_npc_action" auto
string property KEY_REPLYTYPE_ENDCONVERSATION = "mantella_end_conversation" auto

string property KEY_STARTCONVERSATION_WORLDID = "mantella_worldid" auto
string property KEY_STARTCONVERSATION_USENARRATOR = "mantella_use_narrator" auto
string property KEY_CONTINUECONVERSATION_TOPICINFOFILE = "mantella_topicinfofile" auto

;Actors
string property KEY_ACTORS = "mantella_actors" auto
string property KEY_ACTOR_BASEID = "mantella_actor_baseid" auto
string property KEY_ACTOR_REFID = "mantella_actor_refid" auto
string property KEY_ACTOR_NAME = "mantella_actor_name" auto
string property KEY_ACTOR_GENDER = "mantella_actor_gender" auto
string property KEY_ACTOR_RACE = "mantella_actor_race" auto
string property KEY_ACTOR_ISPLAYER = "mantella_actor_is_player" auto
string property KEY_ACTOR_RELATIONSHIPRANK = "mantella_actor_relationshiprank" auto
string property KEY_ACTOR_VOICETYPE = "mantella_actor_voicetype" auto
string property KEY_ACTOR_ISINCOMBAT = "mantella_actor_is_in_combat" auto
string property KEY_ACTOR_ISENEMY = "mantella_actor_is_enemy" auto
string property KEY_ACTOR_CUSTOMVALUES = "mantella_actor_custom_values" auto

string property KEY_ACTOR_PC_DESCRIPTION = "mantella_pc_description" auto
string property KEY_ACTOR_PC_VOICEPLAYERINPUT = "mantella_pc_voiceplayerinput" auto
string property KEY_ACTOR_PC_VOICEMODEL = "mantella_pc_voicemodel" auto


;sentence
string property KEY_ACTOR_SPEAKER = "mantella_actor_speaker" auto
string property KEY_ACTOR_LINETOSPEAK = "mantella_actor_line_to_speak" auto
string property KEY_ACTOR_ISNARRATION = "mantella_is_narration" auto
string property KEY_ACTOR_VOICEFILE= "mantella_actor_voice_file" auto
string property KEY_ACTOR_DURATION = "mantella_actor_line_duration" auto
string property KEY_ACTOR_ACTIONS = "mantella_actor_actions" auto

;context
string property KEY_CONTEXT = "mantella_context" auto
string property KEY_CONTEXT_LOCATION = "mantella_location" auto
string property KEY_CONTEXT_WEATHER = "mantella_weather" auto
string property KEY_CONTEXT_WEATHER_ID = "mantella_weather_id" auto
string property KEY_CONTEXT_WEATHER_CLASSIFICATION = "mantella_weather_classification" auto
string property KEY_CONTEXT_TIME = "mantella_time" auto
string property KEY_CONTEXT_INGAMEEVENTS = "mantella_ingame_events" auto

;player input
string property KEY_REQUESTTYPE_TTS = "mantella_tts" auto
string property KEY_INPUT_NAMESINCONVERSATION = "mantella_names_in_conversation" auto
string property KEY_TRANSCRIBE = "mantella_transcribe" auto
string property KEY_INPUTTYPE_TEXT = "mantella_text_input" auto
string property KEY_INPUTTYPE_MIC = "mantella_mic_input" auto
string property KEY_INPUTTYPE_PTT = "mantella_push_to_talk" auto

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       Possible actions      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

string property ACTION_RELOADCONVERSATION = "mantella_reload_conversation" auto
string property ACTION_ENDCONVERSATION = "mantella_end_conversation" auto
string property ACTION_REMOVECHARACTER = "mantella_remove_character" auto

string property ACTION_NPC_OFFENDED = "mantella_npc_offended" auto
string property ACTION_NPC_FORGIVEN = "mantella_npc_forgiven" auto
string property ACTION_NPC_FOLLOW = "mantella_npc_follow" auto
string property ACTION_NPC_INVENTORY = "mantella_npc_inventory" auto
