scriptName MantellaSubtitles hidden

; the next time the given topic would be spoken by the given speaker, replace
; its subtitle with the given subtitle
Bool function SetInjectTopicAndSubtitleForSpeaker(Actor speaker, Topic topic, String subtitle) global native
; shows a "custom" subtitle line spoken by a given speaker, for the amount of
; time specified
Bool function AddTopicAndSubtitleForSpeaker(Actor speaker, String subtitle, int ms_to_show) global native