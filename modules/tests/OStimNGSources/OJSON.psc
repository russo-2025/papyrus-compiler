;/* OJSON
* * utility script to get thread information out of json strings that get passed by some events
*/;
ScriptName OJSON

;/* GetActors
* * gets all the actors that were involved in the thread
* *
* * @param: Json, the json string
* *
* * @return: an array of actors 
*/;
Actor[] Function GetActors(string Json) Global Native

;/* GetScene
* * gets the scene that was played by the thread
* *
* * @param: Json, the json string
* *
* * @return: the scene id
*/;
string Function GetScene(string Json) Global Native

;/* GetMetadata
* * gets the metadata that was attached to the thread
* *
* * @required API version: 7.3.4d (0x07030044)
* *
* * @param: Json, the json string
* *
* * @return: an array containing all the metadata
*/;
string[] Function GetMetadata(string Json) Global Native