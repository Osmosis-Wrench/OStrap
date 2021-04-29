Scriptname OStrapOnMCM extends ski_configbase  

Bool Property EnabledStrapons Auto
Int SetEnabledStrapons

Int EnabledStraponsFlag

Bool Property PlayerEnabledStrapons Auto
Int SetPlayerEnabled

Bool Property NPCEnabledStrapons Auto
Int SetNPCEnabled

Bool Property EnableForStraightSex Auto
string PageName

Faction Property SoSFaction Auto

Bool Property OCumIntEnabled Auto  
OCumScript Property OCum Auto Hidden

int setOcumIntEnabled
int EnabledOCumIntFlag

; mcm save/load settings
Int ExportSettings
Int ImportSettings
Int ReloadStraponSettings
Int CheckForCompats
int PurgeInvalidStrapons

Bool property SOSInstalled Auto
Bool property OcumInstalled Auto

; TODO: Add options for:
    ; TODO: Exporting and Importing settings.
; TODO: Convert to using JDB to lighten file i/o loading.
; TODO: Work out a way to deal with f/m scenes where female is dom (I.e Pegging.)

Event OnConfigInit()
    EnabledStrapons = True
    PlayerEnabledStrapons = True
    NPCEnabledStrapons = False
    OCumIntEnabled = false
    ; Load the settings file included with the mod
    LoadPrototypeFile()
    LoadCompatFiles()
    PurgeBadForms()
    GetSoftRecs()
    WriteLog("OStrap install finished.")
EndEvent

Event OnPageReset(string page)
	{Called when a new page is selected, including the initial empty page}
    if (EnabledStrapons)
        EnabledStraponsFlag = OPTION_FLAG_NONE
    Else
        EnabledStraponsFlag = OPTION_FLAG_DISABLED
    endIf
    if (SOSInstalled && OcumInstalled)
        EnabledOCumIntFlag = OPTION_FLAG_NONE
    Else
        EnabledOCumIntFlag = OPTION_FLAG_DISABLED
    endIF
    SetCursorPosition(0)
    SetCursorFillMode(TOP_TO_BOTTOM)
    AddColoredHeader("Main settings")
    SetEnabledStrapons = AddToggleOption("Enable Mod", EnabledStrapons)
    SetPlayerEnabled = AddToggleOption("Enable Player Strapons", PlayerEnabledStrapons, EnabledStraponsFlag)
    SetNPCEnabled = AddToggleOption("Enable NPC Strapons", NPCEnabledStrapons, EnabledStraponsFlag)
    AddColoredHeader("Intergrations","Blue")
    SetOcumIntEnabled = AddToggleOption("Enable OCum support.", OCumIntEnabled, EnabledOCumIntFlag)
    AddColoredHeader("Misc Settings")
    PurgeInvalidStrapons = AddTextOption("Purge invalid strapons", "Click")
    CheckForCompats = AddTextOption("Load Compat plugins", "Click")
    ReloadStraponSettings = AddTextOption("Reset strapon info to defualt", "Click")
    ExportSettings = AddTextOption("Reset strapon info to defualt", "Click")
    ImportSettings = AddTextOption("Reset strapon info to defualt", "Click")

    SetCursorPosition(1)
    AddColoredHeader("Enabled Strapons", "Blue")
    PopulateStraponsPage()
endEvent

; Populates the strapon options page, dynamically pulling from StraponsAll.Json to build it.
Function PopulateStraponsPage()
    int data = JValue.ReadFromFile(JContainers.UserDirectory() + "StraponsAll.json")
    if (data == false)
        WriteLog("StraponsAll.json file not found.", true)
        return
    endif
    bool changes = false
    string StraponNameKey = Jmap.NextKey(Data)
    while StraponNameKey
        bool straponEnabled = JValue.SolveInt(Data, "." + StraponNameKey + ".Enabled") as Bool
        int optID = AddStraponToggle(StraponNameKey, StraponEnabled)
        if (optID != JValue.SolveInt(Data, "." + StraponNameKey + ".OptID"))
            Jvalue.SolveIntSetter(Data, "." + StraponNameKey + ".OptID", optID)
            changes = true
        endIF
        StraponNameKey = Jmap.NextKey(Data, StraponNameKey)
    endWhile
    if (changes)
        JValue.WriteToFile(Data, JContainers.UserDirectory() + "StraponsAll.json")
    endIf
endFunction

; When called will create a toggleoption for the provided strapon and returns the optionID of the toggleoption menu item.
int Function AddStraponToggle(string StraponName, bool StraponState)
    int optID
    optID = AddToggleOption(StraponName, StraponState)
    return optID
endFunction

Event OnOptionSelect(int Option)
    If (Option == SetEnabledStrapons)
        EnabledStrapons = !EnabledStrapons
        SetToggleOptionValue(Option, EnabledStrapons)
        ForcePageReset()
    ElseIf (Option == SetOcumIntEnabled)
        OCumIntEnabled = !OCumIntEnabled
        SetToggleOptionValue(Option, OCumIntEnabled)
    ElseIf (Option == SetPlayerEnabled)
        PlayerEnabledStrapons = !PlayerEnabledStrapons
        SetToggleOptionValue(Option, PlayerEnabledStrapons)
    ElseIf (Option == SetNPCEnabled)
        NPCEnabledStrapons = !NPCEnabledStrapons
        SetToggleOptionValue(Option, NPCEnabledStrapons)
    ElseIf (Option == PurgeInvalidStrapons)
        PurgeBadForms()
        Debug.MessageBox("Removing invalid strapons, wait a second before clicking OK.")
        ForcePageReset()
    ElseIf (Option == CheckForCompats)
        LoadCompatFiles()
        Debug.MessageBox("Checking for compat files, wait a second before clicking OK.")
        ForcePageReset()
    ElseIf (Option == ReloadStraponSettings)
        ReloadSettingsFile()
        Debug.MessageBox("Reloading from default, wait a second before clicking OK.")
        ForcePageReset()
    ElseIf (Option == ExportSettings)
        ExportMCM()
    ElseIf (Option == ImportSettings)
        ImportMCM()
    Else
        ; if not any of the above options, checks if the option is one of the strapon options.
        GetStraponOptions(Option)
    EndIf
EndEvent

Event OnOptionHighlight(Int Option)
    If (Option == SetEnabledStrapons)
        SetInfoText("Enables the strapon system.")
    ElseIf (Option == SetOcumIntEnabled)
        SetInfoText("Enables actor with strapon to cum using OCum. Use if you have equiped a SOS Schlong for example.")
    ElseIf (Option == SetPlayerEnabled)
        SetInfoText("Enables strapons for player.")
    ElseIf (Option == SetNPCEnabled)
        SetInfoText("Enables strapons for NPC's\nNote that if enabled for player and NPCs, whichever actor is in the Dom role according to Ostim will be give the strapon.")
    ElseIf (Option == PurgeInvalidStrapons)
        SetInfoText("Will delete any strapons that are uninstalled or broken from the list. Do this if you have removed a strapon mod.")
    ElseIf (Option == CheckForCompats)
        SetInfoText("Will check for any existing compatibility files and load them.")
    ElseIf (Option == ReloadStraponSettings)
        SetInfoText("Reloads default strapon settings, removing all strapons not packaged with OStap.")
    ElseIf (Option == ExportSettings)
        SetInfoText("Exports OStrap MCM settings (Excluding strapon selections) to /My Games/Skyrim Special Edition/JCUser/OStrapMCMSettings.json")
    ElseIf (Option == ImportSettings)
        SetInfoText("Imports OStrap MCM settings (Excluding strapon selections) from either Data folder or /My Games/Skyrim Special Edition/JCUser/OStrapMCMSettings.json")
    Else
        ; if not any of the above, assumes it's a strapon option.
        SetInfoText("OStrap will randomly select one of the enabled strapons each time it starts.")
    EndIf
EndEvent

; Checks if Option is equal to and of the optionID's stored in StraponsAll.json and if it is, toggles that option.
function GetStraponOptions(int Option)
    int data = JValue.ReadFromFile(JContainers.UserDirectory() + "StraponsAll.json")
    if (data == false)
        WriteLog("StraponsAll.json file not found.", true)
        return
    endif
    string StraponNameKey = Jmap.NextKey(Data)
    while StraponNameKey
        int optID = JValue.SolveInt(Data, "." + StraponNameKey + ".OptID")
        if (option == optID)
            bool enabled = JValue.SolveInt(Data, "." + StraponNameKey + ".Enabled") as Bool
            enabled = !enabled
            Jvalue.SolveIntSetter(Data, "." + StraponNameKey + ".Enabled", enabled as int)
            SetToggleOptionValue(optID, enabled)
            JValue.WriteToFile(Data, JContainers.UserDirectory() + "StraponsAll.json")
            return
        endif
        StraponNameKey = Jmap.NextKey(Data, StraponNameKey)
    endWhile
endFunction

; On first config load, looks for Prototype file in data folder and tries to load it.
Function LoadPrototypeFile()
    WriteLog("Installing OStrap", true)
    int prototype = JValue.ReadFromFile(".\\Data\\OStrapData\\StraponPrototypeFile.json")
    int standard = JValue.ReadFromFile(JContainers.UserDirectory() + "StraponsAll.json")
    if (Prototype == False)
        Writelog(("Something went wrong during installation, Strapon Prototype file was not found in data folder."), true)
        Writelog(("Attempting to load file from /My Games/SSE/JCUser instead."), true)
        if (standard == False)
            WriteLog(("No strapon data found, try re-installing mod and ensure StraponPrototypeFile.Json is included."), true)
        endIf
    ElseIf(Prototype == True && standard == False)
        Writelog("Creating strapon info based off prototype file.")
        JValue.WriteToFile(prototype, JContainers.UserDirectory() + "StraponsAll.json")
    ElseIf(Prototype == True && Standard == True)
        Writelog("Existing strapon info exists in JCUser folder, and will be used instead of regenerating.")
    ElseIf(Prototype == False && Standard == True)
        Writelog("No prototype file for strapons was found, but existing info was found in JCUser folder.", true)
        Writelog("This will be used instead, but strangeness may occur.", true)
    endIf
endFunction

Function ReloadSettingsFile()
    Writelog("Reloading strapon settings file from prototype.")
    int prototype = JValue.ReadFromFile(".\\Data\\OStrapData\\StraponPrototypeFile.json")
    if (prototype == false)
        Debug.MessageBox("Defaults file could not be found.")
    else
        JValue.WriteToFile(prototype, JContainers.UserDirectory() + "StraponsAll.json")
    endIf
endFunction

; Loads any file .json file in Data/OstrapData/OstrapCompat/ folder and appeneds any valid strapons to the strapon list.
Function LoadCompatFiles()
    WriteLog("Checking for compats.", true)
    int compats = JValue.readFromDirectory("Data/OStrapData/OstrapCompat", ".json")
    int existing = JValue.ReadFromFile(JContainers.UserDirectory() + "StraponsAll.json")
    Jvalue.Retain(Compats)
    Jvalue.Retain(Existing)

    int compatData
    string compatDataPath
    string path = Jmap.nextKey(Compats)
    ;Unwrap combined compat file.
    while path
        WriteLog("Loading compat file:" + Path)
        compatData = Jmap.GetObj(compats, path)
        compatDataPath = Jmap.NextKey(compatData)
        while compatDataPath
            bool straponEnabled = JValue.SolveInt(compatData, "." + compatDataPath + ".Enabled") as Bool
            form straponForm = JValue.SolveForm(compatData, "." + compatDataPath + ".Form")
            JMap.SetObj(existing, compatDataPath, BuildStraponObject(straponForm, StraponEnabled))

            compatDataPath = jmap.nextKey(compatData, compatDataPath)
        endwhile
        path = Jmap.NextKey(compats, path)
    endwhile

    JValue.WriteToFile(Existing, JContainers.UserDirectory() + "StraponsAll.json")
    WriteLog("All detected compats loaded.")

    Jvalue.Release(Compats)
    Jvalue.Release(Existing)
    PurgeBadForms()
endFunction

; Purges invalid forms from the Strapons list.
Function PurgeBadForms()
    Writelog("Checking for bad forms")
    int data = JValue.ReadFromFile(JContainers.UserDirectory() + "StraponsAll.json")
    int fixed = Jmap.Object()
    string nameKey = JMap.NextKey(data)
    form checkForm
    bool enabled
    while nameKey
        checkForm = JValue.SolveForm(Data, "." + nameKey + ".Form")
        if (checkForm == false)
            Writelog("Bad form detected in compat file: " + NameKey)
        Else
            enabled = JValue.SolveInt(Data, "." + nameKey + ".Enabled") as Bool
            JMap.SetObj(fixed, NameKey, BuildStraponObject(checkForm, Enabled))
        endif
        namekey = JMap.NextKey(Data, namekey)
    endWhile
    JValue.WriteToFile(fixed, JContainers.UserDirectory() + "StraponsAll.json")
EndFunction

; build strapon object to be returned in LoadCompatFiles
int Function BuildStraponObject(Form Formid, Bool Enabled)
    int StraponObject = Jmap.Object()
    Jmap.SetForm(StraponObject, "Form", Formid)
    Jmap.SetInt(StraponObject, "Enabled", enabled as int)
    Jmap.SetInt(StraponObject, "OptID", 0)
    return StraponObject
endFunction

Function GetSoftRecs()
	If (Game.GetModByName("Schlongs of Skyrim.esp") != 255)
		SoSFaction = (Game.GetFormFromFile(0x0000AFF8, "Schlongs of Skyrim.esp")) as Faction
        Utility.Wait(1.0)
		If (SoSFaction)
			SoSInstalled = true
		Else
			SoSInstalled = false
		Endif
	Else
		SoSInstalled = false
	EndIf
    If (Game.GetModByName("OCum.esp") != 255)
        OCum = (Game.GetFormFromFile(0x800, "OCum.esp") as OCumScript)
        Utility.Wait(1.0)
        if (OCum)
            OcumInstalled = True
        Else
            OcumInstalled = False
        endIf
    Else
        OcumInstalled = False
    endIf
endFunction

; Modified version of the same function from Ostim, just with manual control.
Function AddColoredHeader(String In, String color = "Pink")
	String Blue = "#6699ff"
	String Pink = "#ff3389"
    If (color == "pink")
        Color = Pink
    ElseIf (color == "blue")
        Color = Blue
    Else
        Color = Pink
    EndIf
	AddHeaderOption("<font color='" + Color +"'>" + In)
EndFunction

; This just makes life easier sometimes.
Function WriteLog(String OutputLog, bool error = false)
    MiscUtil.PrintConsole("OStrap: " + OutputLog)
    Debug.Trace("OStrap: " + OutputLog)
    if (error == true)
        Debug.Notification("Ostrap: " + OutputLog)
    endIF
EndFunction

Function ExportMCM()
    int data = JMap.Object()
    Debug.MessageBox("Exporting to file, wait a second or two before clicking OK.")

    JMap.SetInt(data, "EnabledStrapons", EnabledStrapons as Int)
    JMap.SetInt(data, "PlayerEnabledStrapons", PlayerEnabledStrapons as Int)
    JMap.SetInt(data, "NPCEnabledStrapons", NPCEnabledStrapons as Int)
    JMap.SetInt(data, "EnableForStraightSex", EnableForStraightSex as Int)
    JMap.SetInt(data, "OCumIntEnabled", OCumIntEnabled as Int)

    Jvalue.WriteToFile(Data, JContainers.UserDirectory() + "OStrapMCMSettings.json")
EndFunction

Function ImportMCM()
    int data = JValue.readFromFile(JContainers.UserDirectory() + "OstimMCMSettings.json")
    int modlistData = JValue.readFromFile(".\\Data\\OstimMCMSettings.json")

    If (data == false && modlistData == false)
        Debug.MessageBox("Tried to import from file, but no file was found.")
        return
    ElseIf (data == false && modlistData == true)
        Debug.Messagebox("Found MCM settings in Data folder, loading from there.")
        data = modlistData
    Else
        Debug.MessageBox("Found MCM settings in JCUser folder, loading from there.")
    EndIf
    
    EnabledStrapons = JMap.GetInt(data, "EnabledStrapons")
    PlayerEnabledStrapons = JMap.GetInt(data, "PlayerEnabledStrapons")
    NPCEnabledStrapons = JMap.GetInt(data, "NPCEnabledStrapons")
    EnableForStraightSex = JMap.GetInt(data, "EnableForStraightSex")
    OCumIntEnabled = JMap.GetInt(data, "OCumIntEnabled")
    
    ForcePageReset()
EndFunction

