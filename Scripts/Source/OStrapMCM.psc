Scriptname OStrapMCM extends nl_mcm_module

bool property _ostrap_enabled auto
int _ostrap_enabled_flag
bool property _player_enabled auto
bool property _npc_enabled auto
bool property _ocum_enabled auto
bool property _straight_enabled auto
int _ocum_flag
bool property _sos_installed auto
bool property _ocum_installed auto

Faction Property SoSFaction auto hidden
OCumScript Property OCum auto hidden

string[] _shown_presets

String Blue = "#6699ff"
String Pink = "#ff3389"

;
;
; HEY YOU! If you're reading this to try and work out how to do something, especially jcontainers stuff, look at one of my newer mods instead.
; This stuff all works, but it's very inelegant. I have basically the same system for dynamically loading stuff in OJazz and it take up a quarter of the amount of space and is significantly faster.
;
;

int property straponJArray
    int function get()
        return JDB.solveObj(".OStrap.strapons")
      endfunction
      function set(int object)
        JDB.solveObjSetter(".OStrap.strapons", object, true)
      endfunction
endproperty

int function getVersion()
    return 102
endFunction

event OnInit()
    RegisterModule("Core Options")
endevent

event OnPageInit()
    SetModName("OStrap")
    SetLandingPage("Core Options")
    _ostrap_enabled = true
    _player_enabled = true
    _npc_enabled = false  
    _straight_enabled = false  
    _ocum_enabled = false   
    _sos_installed = false
    _ocum_installed = false
    build_strapon_data()
    load_compats()
    purge_list()
    Check_For_Soft_Requirements()
endEvent

event OnVersionUpdate(int a_version)
    ;Nothing for now.
endEvent

event OnGameReload()
    Utility.WaitMenuMode(2.0)
    Check_For_Soft_Requirements()
endevent

event OnPageDraw()
    if (_ostrap_enabled)
        _ostrap_enabled_flag = OPTION_FLAG_NONE
    else
        _ostrap_enabled_flag = OPTION_FLAG_DISABLED
    endif

    if (_sos_installed && _ocum_installed && _ostrap_enabled)
        _ocum_flag = OPTION_FLAG_NONE
    else
        _ocum_flag = OPTION_FLAG_DISABLED
    endif

    SetCursorFillMode(TOP_TO_BOTTOM)
    AddHeaderOption(FONT_CUSTOM("OStrap Core", pink))
    AddToggleOptionST("_ostrap_enabled_state", "Enable Mod", _ostrap_enabled)
    AddToggleOptionST("_strapons_enabled_player", "Enable for Player", _player_enabled)
    AddToggleOptionST("_strapons_enabled_npc", "Enable for NPC", _npc_enabled)
    AddToggleOptionST("_strapons_enabled_straight", "Enable for Straight Scenes", _straight_enabled)
    AddHeaderOption(FONT_CUSTOM("OStrap Intergrations", blue))
    AddToggleOptionST("_ocum_intergration_enabled", "Enable OCum Support", _ocum_enabled, _ocum_flag)
    AddHeaderOption(FONT_CUSTOM("OStrap Misc. Settings", pink))
    AddTextOptionST("_ostrap_purge_invalid", "Purge Invalid Strapons", "Click")
    AddTextOptionST("_ostrap_load_compats", "Load Compatibility Files", "Click")
    AddTextOptionST("preset_save", "Save MCM to Preset", "Click")
    AddTextOptionST("preset_load", "Load MCM from Preset", "Click")
    AddEmptyOption()
    SetCursorPosition(1)
    AddHeaderOption(FONT_CUSTOM("Enabled Strapons", blue))
    build_strapon_page()
endevent

state _ostrap_enabled_state
    event OnDefaultST(string state_id)
        _ostrap_enabled = true
        ForcePageReset()
    endevent

    event OnSelectST(string state_id)
        _ostrap_enabled = !_ostrap_enabled
        ForcePageReset()
    endevent

    event OnHighlightST(string state_id)
        if (_ostrap_enabled)
            SetInfoText("Disable OStrap")
        else
            SetInfoText("Enable OStrap")
        endif
    endevent
endstate

state _strapons_enabled_player
    event OnDefaultST(string state_id)
        _player_enabled = true
    endevent

    event OnSelectST(string state_id)
        _player_enabled = !_player_enabled
        SetToggleOptionValueST(_player_enabled, false, "_strapons_enabled_player")
    endevent

    event OnHighlightST(string state_id)
        SetInfoText("Enables strapons for the Player.")
    endEvent
endstate

state _strapons_enabled_npc
    event OnDefaultST(string state_id)
        _npc_enabled = false
    endevent

    event OnSelectST(string state_id)
        _npc_enabled = !_npc_enabled
        SetToggleOptionValueST(_npc_enabled, false, "_strapons_enabled_npc")
    endevent

    event OnHighlightST(string state_id)
        SetInfoText("Enables strapons for NPC's.")
    endEvent
endstate

state _strapons_enabled_straight
    event OnDefaultST(string state_id)
        _straight_enabled = false
    endevent

    event OnSelectST(string state_id)
        _straight_enabled = !_straight_enabled
        SetToggleOptionValueST(_straight_enabled, false, "_strapons_enabled_straight")
    endevent

    event OnHighlightST(string state_id)
        SetInfoText("Enables strapons for straight scenes (Pegging). \n If you want to see this happen more often, enable Player Always Dom in the Ostim MCM.")
    endEvent
endstate

state _ocum_intergration_enabled
    event OnDefaultST(string state_id)
        _ocum_enabled = false
    endevent

    event OnSelectST(string state_id)
        _ocum_enabled = !_ocum_enabled
        SetToggleOptionValueST(_ocum_enabled, false, "_ocum_intergration_enabled")
    endevent

    event OnHighlightST(string state_id)
        SetInfoText("Enables any actor with a strapon to cum using OCum.")
    endEvent
endstate  
    
state _ostrap_purge_invalid
    event OnSelectST(string state_id)
        purge_list()
    endevent

    event OnHighlightST(string state_id)
        SetInfoText("Remove all invalid or uninstalled strapons from the list.")
    endEvent
endstate

state _ostrap_load_compats
    event OnSelectST(string state_id)
        load_compats()
    endevent

    event OnHighlightST(string state_id)
        SetInfoText("Check for and load any new compatibility files.")
    endEvent
endstate

state preset_save
    event OnSelectST(string state_id)
        SaveMCMToPreset("OStrapMCMSettings")
        ForcePageReset()
    endevent

    event OnHighlightST(string state_id)
        SetInfoText("Save the MCM to file")
    endEvent
endstate

state preset_load
    event OnSelectST(string state_id)
        LoadMCMFromPreset("OStrapMCMSettings")
        ForcePageReset()
    endevent

    event OnHighlightST(string state_id)
        SetInfoText("Load a preset from file")
    endEvent
endstate

state strapon_toggle_option
    event OnSelectST(string state_id)
        bool straponEnabled = JValue.SolveInt(straponJArray, "." + state_id + ".Enabled") as bool
        straponEnabled = !straponEnabled
        SetToggleOptionValueST(straponEnabled, false, "strapon_toggle_option___" + state_id)
        JValue.SolveIntSetter(straponJArray, "." + state_id + ".Enabled", straponEnabled as int)
    endevent

    event OnHighlightST(string state_id)
        SetInfoText("Enabled or Disable " + state_id)
    endEvent
endstate

function build_strapon_page()
    string straponkey = JMap.NextKey(straponJArray)
    while straponkey
        bool strapon_enabled = Jvalue.SolveInt(straponJArray, "." + straponkey + ".Enabled") as bool
        AddToggleOptionST("strapon_toggle_option___" + straponkey, straponkey, strapon_enabled)
        straponkey = Jmap.nextKey(straponJArray, straponkey)
    endwhile
endFunction

function build_strapon_data()
    int data
    if JContainers.FileExistsAtPath(".\\Data\\OStrapData\\StraponPrototypeFile.json")
        data = JValue.ReadFromFile(".\\Data\\OStrapData\\StraponPrototypeFile.json")
    else
        WriteLog("StraponPrototypeFile not found in OStrapData.", true)
        return
    endif
    StraponJArray = data
endfunction

function load_compats()
    int compats = JValue.readFromDirectory("Data/OStrapData/OstrapCompat", ".json")
    JValue.Retain(compats)
    int compatData
    string compatkey = JMap.nextKey(compats)
    while compatkey
        compatData = JMap.GetObj(compats, compatkey)
        string compatDataKey = JMap.NextKey(CompatData)
        while compatDataKey
            form straponForm = JValue.SolveForm(CompatData, "." + compatDataKey + ".Form")
            bool enabled = JValue.SolveInt(compatData, "." + compatDataKey + ".Enabled") as Bool
            Jmap.SetObj(StraponJArray, compatDataKey, Build_Strapon_Object(straponForm, enabled))
            compatDataKey = JMap.NextKey(compatdata, compatdatakey)
        endwhile
        compatkey = Jmap.NextKey(compats, compatkey)
    endwhile
    JValue.Release(compats)
    purge_list()
endFunction

function purge_list()
    string straponkey = JMap.NextKey(StraponJArray)
    int cleaned = JMap.Object()
    JValue.Retain(cleaned)
    form checkform
    bool enabled
    while straponkey
        checkform = JValue.SolveForm(StraponJArray, "." + straponkey + ".Form")
        if (checkForm == false)
            Writelog("Invalid strapon detected in compat file: " + straponkey)
        else
            enabled = JValue.SolveInt(StraponJArray, "." + straponkey + ".Enabled" ) as bool
            Jmap.setObj(cleaned, straponkey, Build_Strapon_Object(checkform, enabled))
        endif
        straponKey = JMap.NextKey(StraponJArray, straponKey)
    endwhile
    JValue.WriteToFile(cleaned, JContainers.UserDirectory() + "cleaned.json")
    straponJArray = cleaned
    JValue.Release(cleaned)
    ForcePageReset()
endFunction

int function Build_Strapon_Object(form formid, bool enabled)
    int straponObject = Jmap.Object()
    JMap.SetForm(StraponObject, "Form", Formid)
    Jmap.SetInt(StraponObject, "Enabled", enabled as int)
    Jmap.SetInt(StraponObject, "OptID", 0)
    return StraponObject
endfunction

function LoadData(int jObj)
    _ostrap_enabled = JMap.GetInt(jObj, "_ostrap_enabled")
    _player_enabled = JMap.GetInt(jObj, "_player_enabled")
    _npc_enabled = JMap.GetInt(jObj, "_npc_enabled")
    _ocum_enabled = JMap.GetInt(jObj, "_ocum_enabled")
    _straight_enabled = JMap.GetInt(jObj, "_straight_enabled")
    

    build_strapon_data()
    load_compats()
    purge_list()
endFunction

int function SaveData()
    int jObj = JMap.Object()
    JMap.SetInt(jObj, "_ostrap_enabled", _ostrap_enabled as Int)
    JMap.SetInt(jObj, "_player_enabled", _player_enabled as Int)
    JMap.SetInt(jObj, "_npc_enabled", _npc_enabled as Int)
    JMap.SetInt(jObj, "_ocum_enabled", _ocum_enabled as Int)
    JMap.SetInt(jObj, "_straight_enabled", _straight_enabled as Int)

    return jObj
endFunction

Function Check_For_Soft_Requirements()
    if (!_ocum_installed || !OCum)
        if (Game.GetModByName("OCum.esp") != 255)
            OCum = (Game.GetFormFromFile(0x800, "OCum.esp") as OCumScript)
            Utility.Wait(1.0)
        endif
        if (Ocum)
            _ocum_installed = true
            WriteLog("OCum detected.", true)
        else
            _ocum_installed = false
        endif
    endif

    if (!_sos_installed || !SoSFaction)
        if (Game.GetModByName("Schlongs of Skyrim.esp") != 255)
            SoSFaction = (Game.GetFormFromFile(0x0000AFF8, "Schlongs of Skyrim.esp")) as Faction
            Utility.Wait(1.0)
        endif
        if (SoSFaction)
            _sos_installed = true
            WriteLog("SOS detected.", true)
        else
            _sos_installed = false
        endif
    endif

    if ((!_sos_installed || !_ocum_installed) && _ocum_enabled)
        _ocum_enabled = false
    endif
endFunction

; This just makes life easier sometimes.
Function WriteLog(String OutputLog, bool error = false)
    MiscUtil.PrintConsole("OStrap: " + OutputLog)
    Debug.Trace("OStrap: " + OutputLog)
    if (error == true)
        Debug.Notification("Ostrap: " + OutputLog)
    endIF
EndFunction
