;/* OCSV
* * collection of csv utility functions
*/;
ScriptName OCSV

; ██╗     ██╗███████╗████████╗███████╗
; ██║     ██║██╔════╝╚══██╔══╝██╔════╝
; ██║     ██║███████╗   ██║   ███████╗
; ██║     ██║╚════██║   ██║   ╚════██║
; ███████╗██║███████║   ██║   ███████║
; ╚══════╝╚═╝╚══════╝   ╚═╝   ╚══════╝

string Function ToCSVList(string[] Values) Global
	Return PapyrusUtil.StringJoin(Values, ",")
EndFunction

string[] Function FromCSVList(string Values) Global
	Return PapyrusUtil.StringSplit(Values, ",")
EndFunction

string Function CreateCSVList(int Size, string Filler) Global
	If Size == 0
		Return ""
	EndIf

	string Ret = Filler
	int i = 1
	While i < Size
		Ret += "," + Filler
		i += 1
	EndWhile

	Return Ret
EndFunction

string Function CreateSingleCSVListEntry(int Index, string Entry) Global
	string Ret = ""

	While Index
		Index -= 1
		Ret += ","
	EndWhile

	Ret += Entry

	Return Ret
EndFunction

string Function ConcatCSVLists(string ListA, string ListB) Global
	If ListA == ""
		Return ListB
	ElseIf ListB == ""
		Return ListA
	Else
		Return ListA + "," + ListB
	EndIf
EndFunction


; ███╗   ███╗ █████╗ ████████╗██████╗ ██╗ ██████╗███████╗███████╗
; ████╗ ████║██╔══██╗╚══██╔══╝██╔══██╗██║██╔════╝██╔════╝██╔════╝
; ██╔████╔██║███████║   ██║   ██████╔╝██║██║     █████╗  ███████╗
; ██║╚██╔╝██║██╔══██║   ██║   ██╔══██╗██║██║     ██╔══╝  ╚════██║
; ██║ ╚═╝ ██║██║  ██║   ██║   ██║  ██║██║╚██████╗███████╗███████║
; ╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝╚═╝ ╚═════╝╚══════╝╚══════╝

string Function ToCSVMatrix(string[] Values) Global
	Return PapyrusUtil.StringJoin(Values, ";")
EndFunction

string[] Function FromCSVMatrix(string Values) Global
	Return PapyrusUtil.StringSplit(Values, ";")
EndFunction

string Function CreateCSVMatrix(int Size, string Filler) Global
	If Size == 0
		Return ""
	EndIf

	string Ret = Filler
	int i = 1
	While i < Size
		Ret += ";" + Filler
		i += 1
	EndWhile

	Return Ret
EndFunction

string Function CreateSingleCSVMatrixEntry(int Index, string Entry) Global
	string Ret = ""

	While Index
		Index -= 1
		Ret += ";"
	EndWhile
	
	Ret += Entry

	Return Ret
EndFunction

string Function ConcatCSVMatrices(string MatrixA, string MatrixB) Global
	If MatrixA == ""
		Return MatrixB
	ElseIf MatrixB == ""
		Return MatrixA
	Else
		Return MatrixA + ";" + MatrixB
	EndIf
EndFunction
