Scriptname FNIS_aaQuest extends Quest 

Quest Property FNIS_Q2 Auto

bool Property bConvDataReady Auto

string[] Property Prefix Auto
int[] Property GroupId Auto
int[] Property ModId Auto
int[] Property Base Auto
int[] Property Index Auto
int Property nMods Auto
int Property nSets Auto
int Property crc Auto

Event OnInit()
	If !self.isRunning()		; if quest isn't started, despite being "start game enabled"
		self.Start()
		return
	endIf

;	Debug.Notification("FNIS aa (init) started")
;	Prefix = new string[30]
	ModId = new int[128]
	GroupId = new int[128]
	Base = new int[128]
	Index = new int[128]
		
	nMods = FNIS_aa2.GetAAnumber(0)
	nSets = FNIS_aa2.GetAAnumber(1)
	crc = FNIS_aa2.GetAAnumber(2)
	Debug.Trace("FNIS aa started (init) nMods: " + nMods + " nSets: " + nSets)
		
	Prefix = FNIS_aa2.GetAAprefixList(nMods, "FNIS aa", true)
	FNIS_aa.GetAAsets(nSets, GroupId, ModId, Base, Index, "FNIS aa", true)		
endEvent
