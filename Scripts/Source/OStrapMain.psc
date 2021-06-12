Scriptname OStrapMain extends Quest  

Actor Property PlayerRef  Auto  
OStrapMCM Property O_MCM Auto
OsexIntegrationMain Property OStim Auto
Form Property StrapOn Auto
form strap

int property straponJArray
    int function get()
        return JDB.solveObj(".OStrap.strapons")
      endfunction
      function set(int object)
        JDB.solveObjSetter(".OStrap.strapons", object, true)
      endfunction
endproperty

Function OnInit()
    RegisterForModEvent("ostim_start", "OnOstimStart")
EndFunction

; Triggers when Ostim starts a scene, and runs the main logic of OStrap
Event OnOstimStart(string eventName, string strArg, float numArg, Form sender)
    if (O_MCM._ostrap_enabled)
        strap = ReturnRandomValidStrapon()
        actor[] acts = Ostim.GetActors()
        actor unequipTarget
        if (O_MCM._player_enabled && !O_MCM._npc_enabled)
            if (acts[0] == PlayerRef)
                Equipper(acts[0] , strap)
                unequipTarget = acts[0]
            endif
        elseif (!O_MCM._player_enabled && O_MCM._npc_enabled)
            if (acts[0] != PlayerRef)
                Equipper(acts[0] , strap)
                unequipTarget = acts[0]
            endif
        elseif (O_MCM._player_enabled && O_MCM._npc_enabled)
            Equipper(acts[0] , strap)
            unequipTarget = acts[0]
        endif
        while Ostim.AnimationRunning()
            Utility.Wait(1.0)
        endwhile
        UnEquipStrapon(unequipTarget, strap)
    endif
endEvent

; Checks if target actor is valid to be equipped with strapon.
Function Equipper(Actor target, form randStrap = none)
    ; Only equip to females who are part of the scene.
    If(Ostim.IsFemale(target) && Ostim.IsActorActive(target) && IsAllowedScene())
        If (O_MCM._ocum_enabled)
            Target.AddToFaction(O_MCM.SosFaction)
            O_MCM.OCum.AdjustStoredCumAmount(target, 25)
        endIf
        EquipStrapon(target, strap)
        if (ostim.IsInFreeCam() && target == PlayerRef)
            target.QueueNiNodeUpdate()
        endif
    EndIf
EndFunction

; Checks if a scene is a valid one for strapons.
bool Function IsAllowedScene()
    actor[] act = Ostim.GetActors()
    int len = act.length
    int i = 0
    if (len == 1 || len > 3 || len == 0) ; catch solo and weird edge cases
        return false
    endif
    If (O_MCM._straight_enabled) ; if straight is enabled, all scenes are fine to equip.
        return true
    EndIf
    while i <= len
        if Ostim.IsFemale(act[i])
            i += 1
        else
            return False
        endif
    endwhile
    return true
endfunction

; Equips strapon from set actor.
Function EquipStrapon(Actor target, form randStrap = None)
    if (RandStrap == None)
        Target.EquipItem(StrapOn, true, True)
        WriteLog("Was unable to get random strapon, falling back to default.")
    else
        Target.EquipItem(randStrap, true, True)
    endIf
EndFunction

; Unequips strapon from set actor.
Function UnEquipStrapon(Actor target, form randStrap = None)
    if (randStrap == None)
        Target.RemoveItem(StrapOn, 1, true)
    else
        Target.RemoveItem(randStrap, 1, true)
    endIf
    If (O_MCM._sos_installed && O_MCM._ocum_installed && O_MCM._ocum_enabled && Ostim.AppearsFemale(target))
        Target.RemoveFromFaction(O_MCM.SosFaction)
    endIf
EndFunction

; Returns a randomly chosen enabled strapon.
form Function ReturnRandomValidStrapon()
    int enabledStrapons = JArray.Object()
    string StraponNameKey = Jmap.NextKey(StraponJArray)
    while StraponNameKey
        bool straponEnabled = JValue.SolveInt(StraponJArray, "." + StraponNameKey + ".Enabled") as Bool
        if (StraponEnabled == true)
            Form straponForm = JValue.SolveForm(StraponJArray, "." + StraponNameKey + ".Form")
            Jarray.AddForm(EnabledStrapons, straponForm)
        endIf
        StraponNameKey = Jmap.NextKey(StraponJArray, StraponNameKey)
    endWhile
    int Len = JValue.Count(EnabledStrapons)
    int rand = Utility.RandomInt(0, (Len - 1))
    return JArray.GetForm(EnabledStrapons, rand)
endFunction

; This just makes life easier sometimes.
Function WriteLog(String OutputLog, bool error = false)
        MiscUtil.PrintConsole("OStrap: " + OutputLog)
        Debug.Trace("OStrap: " + OutputLog)
        if (error == true)
            Debug.Notification("Ostrap: " + OutputLog)
        endIF
EndFunction
