### Describe the bug

I have so far been using 0.0.1 without issues that I am aware of.

I saw that there was an upgrade to 0.0.4 and tried it out.

Then I got aware of the stricter checking.

This caused a script source file from Alternate Perspective - Alternate Start to fail with many errors.

I saw here another issue with Headers and tried out that header script. Technically it is an issue for that page, since some definitions are missing.

But in practice it is problematic when I cannot even try the new release with a lot of issues that are not really present. So this extra check should definitively be optional.

If you add such a flag you also need to provide a method to check the content of the existing headers. This is not such an easy task since they can be in multiple subfolders. A larger mod list can have at least several dozen of source folders. 

For me as a tool user this leaves me this release as "broken". Hence the bug report. 

Typical example: skse Form.psc. When I add the the folder to that file the content having "RegisterForModEvent" is present and not found, this is really problematic.

Consequently I don't think new feature is of any use for a tool user. It could be used as an additional flag that first checks for present of f.e. "RegisterForModEvent.psc" and then checks inside if the needed object (like function, class) is present.

### Reproduction Steps

1. Extract Release into a arbitrary folder
2. (Optionally, but probably needed) Run a script to generate psc files from existing psc files that generate files like RegisterForModEvent.psc (which it did not for me).
3. Run papyrus.exe compile -nocache -i source -o D:\Modding\tools\papyrus-compiler\scripts -h "d:\Modding\tools\Papyrus_Header_Generator\Headers"
4. Original run was exactly as documented with the Skyrim\Data\Scripts\Source folder as usual

### Expected Behavior

Builds the scripts folder content without errors as the original compiler.

### Current Behavior

Creates errors (see main comment) like 
```
D:\Modding\tools\papyrus-compiler\source\APDialoguePlayer.psc:16:2: Checker error: undefined function `RegisterForModEvent`
4 | Event OnPlayerLoadGame()
5 |     RegisterForModEvent("AP_MessengerMenuOpen", "MenuOpen")
6 |     RegisterForModEvent("AP_MessengerMenuSelect", "MenuSelect")
  |     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
7 |     RegisterForModEvent("AP_MessengerMenuStart", "QuestStart")
8 | EndEvent
```

### Additional Information/Context

_No response_

### Compiler version

0.0.4

### Environment details (OS name and version, etc.)

Windows 10
Papyrus-Compiler Release 0.0.4
Skyrim Special Edition Game 1.6.1170
Latest Release of Alternate Perspective - Alternate Start 4.1.0
Mod Organizer 2.5.2