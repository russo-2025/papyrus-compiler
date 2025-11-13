Scriptname SoundCategory extends Form Hidden


; Pause any sounds that belong to this category
Function Pause() native

; Play any Paused sounds that belong to this category
Function UnPause() native

; Mute any sounds that belong to this category
Function Mute() native

; UnMute any Muted sounds that belong to this category
Function UnMute() native

; Set a volume modifier [0.0 - 1.0] for any sounds in this category
Function SetVolume(float afVolume) native

; Set a frequency modifier [0.0 - 1.0] for any sounds in this category
Function SetFrequency(float afFrequencyCoeffecient) native