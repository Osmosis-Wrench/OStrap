Scriptname OStrapMCM extends nl_mcm_module

bool property _ostrap_enabled auto
int _ostrap_enabled_flag
bool property _player_enabled auto
bool property _npc_enabled auto
bool property _ocum_enabled auto
int _ocum_flag
bool property _sos_installed auto
bool property _ocum_installed auto

Faction Property SoSFaction auto
OCumScript Property OCum Auto Hidden

event OnInit()
    if RegisterModule("OStrap_Core") != OK
        KeepTryingToRegister()
    endif

    SetModName("OStrap")
    SetLandingPage("OStrap_Core")
    startup()
endevent

function startup()
    _ostrap_enabled = true
    _player_enabled = true
    _npc_enabled = false  
    _ocum_enabled = false   
    _sos_installed = false
    _ocum_installed = false
endfunction

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
    AddHeaderOption(FONT_PRIMARY("OStrap Core"))
    AddToggleOptionST("_ostrap_enabled_state", "Enable Mod", _ostrap_enabled)
    AddToggleOptionST("_strapons_enabled_player", "Enable for Player", _player_enabled)
    AddToggleOptionST("_strapons_enabled_npc", "Enable for NPC", _npc_enabled)
    AddHeaderOption(FONT_PRIMARY("OStrap Intergrations"))
    AddToggleOptionST("_ocum_intergration_enabled", "Enable OCum Support", _ocum_enabled, _ocum_flag)
    AddHeaderOption(FONT_PRIMARY("OStrap Misc. Settings"))
    AddTextOptionST("_ostrap_purge_invalid", "Purge Invalid Strapons", "Click")
    AddTextOptionST("_ostrap_load_compats", "Load Compatibility Files", "Click")
    AddTextOptionST("_ostrap_reset", "Reset Strapons to Default", "Click")
    AddTextOptionST("_ostrap_mcm_save", "Save MCM to File", "Click")
    AddTextOptionST("_ostrap_mcm_load", "Load MCM from File", "Click")
    AddEmptyOption()
    SetCursorPosition(1)
    AddHeaderOption(FONT_PRIMARY("Enabled Strapons"))
    build_strapon_page()
endevent

function build_strapon_page()
    int data = JValue.ReadFromFile(JContainers.UserDirectory() + "StraponsAll.json")
    if (!data)
        WriteLog("StraponsAll.json not found.", true)
        return
    endif
    bool changes = False
    string straponkey = Jmap.NextKey(data)
    while straponkey
        bool strapon_enabled = Jvalue.SolveInt(data, "." + straponkey + ".Enabled") as bool
        AddToggleOptionST("strapon_toggle_option___" + straponkey, straponkey, strapon_enabled)
        straponkey = Jmap.nextKey(data, straponkey)
    endwhile
endFunction

state _ostrap_enabled_state
    event OnDefaultST()
        _ostrap_enabled = true
    endevent

    event OnSelectST()
        _ostrap_enabled = !_ostrap_enabled
        SetToggleOptionValueST(_ostrap_enabled, false, "_ostrap_enabled_state")
    endevent

    event OnHighlightST()
        if (_ostrap_enabled)
            SetInfoText("Disable OStrap")
        else
            SetInfoText("Enable OStrap")
        endif
    endevent
endstate

state _strapons_enabled_player
    event OnDefaultST()
        _player_enabled = true
    endevent

    event OnSelectST()
        _player_enabled = !_player_enabled
        SetToggleOptionValueST(_player_enabled, false, "_strapons_enabled_player")
    endevent

    event OnHighlightST()
        SetInfoText("Enables strapons for the Player.")
    endEvent
endstate

state _strapons_enabled_npc
    event OnDefaultST()
        _npc_enabled = true
    endevent

    event OnSelectST()
        _npc_enabled = !_npc_enabled
        SetToggleOptionValueST(_npc_enabled, false, "_npc_enabled_player")
    endevent

    event OnHighlightST()
        SetInfoText("Enables strapons for NPC's.")
    endEvent
endstate

state _ocum_intergration_enabled
    event OnDefaultST()
        _ocum_enabled = false
    endevent

    event OnSelectST()
        _ocum_enabled = !_ocum_enabled
        SetToggleOptionValueST(_ocum_enabled, false, "_ocum_intergration_enabled")
    endevent

    event OnHighlightST()
        SetInfoText("Enables any actor with a strapon to cum using OCum.")
    endEvent
endstate  
    
state _ostrap_purge_invalid
    event OnSelectST()
        purge_list()
    endevent

    event OnHighlightST()
        SetInfoText("Remove all invalid or uninstalled strapons from the list.")
    endEvent
endstate

state _ostrap_load_compats
    event OnSelectST()
        load_compats()
    endevent

    event OnHighlightST()
        SetInfoText("Check for and load any new compatibility files.")
    endEvent
endstate

state _ostrap_reset
    event OnSelectST()
        reset_list()
    endevent

    event OnHighlightST()
        SetInfoText("Reset strapon list to baseline.")
    endEvent
endstate

state _ostrap_mcm_save
    event OnSelectST()
        save_mcm()
    endevent

    event OnHighlightST()
        SetInfoText("Export all MCM settings to a file.")
    endEvent
endstate

state _ostrap_mcm_load
    event OnSelectST()
        load_mcm()
    endevent

    event OnHighlightST()
        SetInfoText("Import all MCM settings from a file.")
    endEvent
endstate

state strapon_toggle_option
    event OnSelectST_EX(string state_id)
        toggle_strapon(state_id)
    endevent

    event OnHighlightST_EX(string state_id)
        SetInfoText("Enabled or Disable " + state_id)
    endEvent
endstate

function toggle_strapon(string straponName)
    int data = JValue.ReadFromFile(JContainers.UserDirectory() + "StraponsAll.json")
    if (data == false)
        WriteLog("StraponsAll.json file not found.", true)
        return
    endif

    string straponkey = JMap.GetStr(data, straponName)
    if (straponKey)
        bool straponEnabled = JValue.SolveInt(Data, "." + straponkey + ".Enabled") as Bool
        straponEnabled = !straponEnabled
        JValue.SolveIntSetter(Data, "." + straponkey + ".Enabled", straponEnabled as int)
        SetToggleOptionValueST(straponEnabled, false, "strapon_toggle_option___" + straponName)
    endif
endFunction

function reset_list()

endFunction

function load_compats()

endFunction

function purge_list()

endFunction

function load_mcm()

endFunction

function save_mcm()

endFunction

Function OStrap_OnLoad()

endFunction

; This just makes life easier sometimes.
Function WriteLog(String OutputLog, bool error = false)
    MiscUtil.PrintConsole("OStrap: " + OutputLog)
    Debug.Trace("OStrap: " + OutputLog)
    if (error == true)
        Debug.Notification("Ostrap: " + OutputLog)
    endIF
EndFunction