Scriptname MQHrothgarPilgrimmageTabletSCRIPT extends ObjectReference  
{simple script to display pop-up text for the shrines along the path to High Hrothgar from Ivarstead}

message property myText auto
int property MQshrineIndex = 0 auto
{Which Shrine am I?  If not, leave alone.  DEFAULT: 0/FALSE}
spell property MQpathtoHHShrineBlessing auto
quest property dunMasterQST auto

EVENT onActivate(objectReference actronaut)
	; First, show the text regardless of anything else.
	myText.show()	
	
	dunMasterQSTscript QuestScript = dunMasterQST as dunMasterQSTscript
	
	if MQshrineIndex != 0
			; first, see if I've previously completed the pilgrimmage.
			; if so, (and the blessing has worn off) clear all flags so I can re-start.
			if checkShrines() == TRUE
			clearAll()
			utility.wait(0.1)
			endif
			
			; Now, start checking and setting again
			if MQshrineIndex == 1
				questScript.HHshrine01 = TRUE
			elseif MQshrineIndex == 2
				questScript.HHshrine02 = TRUE
			elseif MQshrineIndex == 3
				questScript.HHshrine03 = TRUE
			elseif MQshrineIndex == 4
				questScript.HHshrine04 = TRUE
			elseif MQshrineIndex == 5
				questScript.HHshrine05 = TRUE
			elseif MQshrineIndex == 6
				questScript.HHshrine06 = TRUE
			elseif MQshrineIndex == 7
				questScript.HHshrine07 = TRUE
			elseif MQshrineIndex == 8
				questScript.HHshrine08 = TRUE
			elseif MQshrineIndex == 9
				questScript.HHshrine09 = TRUE
			elseif MQshrineIndex == 10
				questScript.HHshrine10 = TRUE
			endif
			
			if checkShrines() 
				(actronaut As Actor).DispelSpell(MQpathtoHHShrineBlessing)
				MQpathtoHHShrineBlessing.cast(actronaut)
			endif
			
	endif
endEVENT

bool FUNCTION checkShrines()
	; check and see if we have visited all shrines
	dunMasterQSTscript QuestScript = dunMasterQST as dunMasterQSTscript
	
	if questScript.HHshrine01 == TRUE && \
	    questScript.HHshrine02 == TRUE && \
		questScript.HHshrine03 == TRUE && \
		questScript.HHshrine04 == TRUE && \
		questScript.HHshrine05 == TRUE && \
		questScript.HHshrine06 == TRUE && \
		questScript.HHshrine07 == TRUE && \
		questScript.HHshrine08 == TRUE && \
		questScript.HHshrine09 == TRUE && \
	    questScript.HHshrine10 == TRUE
		return TRUE
	else
		return FALSE
	endif
endFUNCTION

FUNCTION clearAll()
	dunMasterQSTscript QuestScript = dunMasterQST as dunMasterQSTscript
	questScript.HHshrine01 = FALSE
	questScript.HHshrine02 = FALSE
	questScript.HHshrine03 = FALSE
	questScript.HHshrine04 = FALSE
	questScript.HHshrine05 = FALSE
	questScript.HHshrine06 = FALSE
	questScript.HHshrine07 = FALSE
	questScript.HHshrine08 = FALSE
	questScript.HHshrine09 = FALSE
	questScript.HHshrine10 = FALSE
endFUNCTION
