;/* OIntUtil
* * collection of utility functions related to integers
* *
* * required API Version: 7.3.1 (0x07030010)
*/;
ScriptName OIntUtil

;/* EmptyArray
* * returns a dynamic length array of time int
* *
* * @param: Size, the size of the array
* * @param: Filler, the value to fill the array with
* * 
* * @return: the int array
*/;
int[] Function CreateArray(int Size, int Filler = 0) Global Native