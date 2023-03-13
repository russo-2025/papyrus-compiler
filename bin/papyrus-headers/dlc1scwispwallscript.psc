ScriptName DLC1SCWispWallScript extends ObjectReference Conditional Hidden

Int DeadCount = 0
Int WispCount = 0

quest Property QuestToSetOnWallDown auto
Int Property StageToSet auto
keyword Property DLC1WispWallEffect auto

Function CheckDead() native
Function GetWispNumber() native
Function DropWall(ObjectReference WallEffect) native