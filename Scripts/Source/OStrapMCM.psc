Scriptname OStrapMCM extends nl_mcm_module

bool _ostrap_enabled = true
int _ostrap_enabled_flag
bool _player_enabled = true
bool _npc_enabled = false

bool _ocum_enabled = false
int _ocum_flag

bool _sos_installed = false
bool _ocum_installed = false


event OnInit()
    if RegisterModule("OStrap_Core") != OK
        KeepTryingToRegister()
    endif

    SetModName("OStrap")
    SetLandingPage("OStrap_Core")
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
endevent

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
        _ocum_enabled = !_ocum_enabled
        SetToggleOptionValueST(_ocum_enabled, false, "_ocum_intergration_enabled")
    endevent

    event OnHighlightST()
        SetInfoText("Enables any actor with a strapon to cum using OCum.")
    endEvent
endstate

state _ostrap_load_compats
    event OnSelectST()
        _ocum_enabled = !_ocum_enabled
        SetToggleOptionValueST(_ocum_enabled, false, "_ocum_intergration_enabled")
    endevent

    event OnHighlightST()
        SetInfoText("Enables any actor with a strapon to cum using OCum.")
    endEvent
endstate

state _ostrap_reset
    event OnSelectST()
        _ocum_enabled = !_ocum_enabled
        SetToggleOptionValueST(_ocum_enabled, false, "_ocum_intergration_enabled")
    endevent

    event OnHighlightST()
        SetInfoText("Enables any actor with a strapon to cum using OCum.")
    endEvent
endstate

state _ostrap_mcm_save
    event OnSelectST()
        _ocum_enabled = !_ocum_enabled
        SetToggleOptionValueST(_ocum_enabled, false, "_ocum_intergration_enabled")
    endevent

    event OnHighlightST()
        SetInfoText("Enables any actor with a strapon to cum using OCum.")
    endEvent
endstate

state _ostrap_mcm_load
    event OnSelectST()
        _ocum_enabled = !_ocum_enabled
        SetToggleOptionValueST(_ocum_enabled, false, "_ocum_intergration_enabled")
    endevent

    event OnHighlightST()
        SetInfoText("Enables any actor with a strapon to cum using OCum.")
    endEvent
endstate
    
    
    