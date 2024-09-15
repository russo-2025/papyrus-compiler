Scriptname TextureSet extends Form Hidden

; SKSE additions built 2015-05-24 00:46:48.937000 UTC

; Returns the number of texture paths
int Function GetNumTexturePaths() native

; Returns the path of the texture
string Function GetNthTexturePath(int n) native

; Sets the path of the texture
Function SetNthTexturePath(int n, string texturePath) native