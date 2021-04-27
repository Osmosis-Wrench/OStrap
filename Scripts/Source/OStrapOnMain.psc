Scriptname OStrapOnMain extends Quest  

Actor Property PlayerRef  Auto  
OStrapOnMCM Property OStrapMCM Auto
OsexIntegrationMain Property OStim Auto
Form Property StrapOn Auto

form strap

Function OnInit()
    RegisterForModEvent("ostim_start", "OnOstimStart")
EndFunction

; Triggers when Ostim starts a scene, and runs the main logic of OStrap
Event OnOstimStart(string eventName, string strArg, float numArg, Form sender)
    If (OStrapMCM.EnabledStrapons)
        ; Cache these to speed it up.
        WriteLog("Scene start detected")
        WriteLog("Getting random Strapon")
        strap = ReturnRandomValidStrapon()
        WriteLog(Strap)
        ; If Player but not NPC is enabled, equip to player.
        If(OStrapMCM.PlayerEnabledStrapons && !OStrapMCM.NPCEnabledStrapons)
            Equipper(PlayerRef, strap)
            WriteLog("Equipping to player.")
        ;If NPC but not Player is enabled, then equip to NPC. Prioritising DomActor in case of f/f scenes with no player actor.
        ElseIf(OStrapMCM.NPCEnabledStrapons && !OStrapMCM.PlayerEnabledStrapons)
            If(Ostim.GetDomActor() != PlayerRef)
                Equipper(Ostim.GetDomActor(), strap)
                WriteLog("Equipping to Dom actor..")
            ElseIf(Ostim.GetSubActor() != PlayerRef)
                Equipper(Ostim.GetSubActor(), strap)
                WriteLog("Equipping to SubActor.")
            EndIf
            WriteLog("Equipping to NPC.")
        ;If both Player and NPC enabled, equip to actor in Dom position.
        ElseIf(OStrapMCM.PlayerEnabledStrapons && OStrapMCM.NPCEnabledStrapons)
            Equipper(Ostim.GetDomActor(), strap)
            WriteLog("Equipping to DomActor")
        EndIf
    EndIf
    While(Ostim.AnimationRunning())
        Utility.Wait(1.0)
    EndWhile
    UnEquipStrapon(Ostim.GetDomActor(), strap)
    UnEquipStrapon(Ostim.GetSubActor(), strap)
    ; Just in case something weird has happened.
    UnEquipStrapon(Ostim.GetThirdActor(), strap)
EndEvent

; Checks if target actor is valid to be equipped with strapon.
Function Equipper(Actor target, form randStrap = none)
    ; Only equip to females who are part of the scene.
    If(Ostim.IsFemale(target) && Ostim.IsActorActive(target) && AllFemale())
        If (OStrapMCM.OCumIntEnabled)
            Target.AddToFaction(OStrapMCM.SosFaction)
            OStrapMCM.OCum.AdjustStoredCumAmount(target, 25)
        endIf
        EquipStrapon(target, strap)
        if ostim.IsInFreeCam() && target == PlayerRef
            target.QueueNiNodeUpdate()
        endif
    EndIf
EndFunction

; deal with pegging later
; Checks if all actors in scene are female.
bool Function AllFemale()
    If (Ostim.IsFemale(Ostim.GetDomActor()) && Ostim.IsFemale(Ostim.GetSubActor()) && Ostim.IsFemale(Ostim.GetThirdActor()))
        Return True
    ElseIf (Ostim.IsFemale(Ostim.GetDomActor()) && Ostim.IsFemale(Ostim.GetSubActor()))
        Return True
    Else
        Return False
    EndIf
endFunction

; Equips strapon from set actor.
Function EquipStrapon(Actor target, form randStrap = None)
    if (RandStrap == None)
        Target.EquipItem(StrapOn, true, True)
        WriteLog("Was unabled to get random stapon, falling back to defualt.")
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
    If (OStrapMCM.SOSInstalled && OStrapMCM.OcumInstalled && OStrapMCM.OCumIntEnabled)
        WriteLog("Removing " + Target + " from SoS faction.")
        Target.RemoveFromFaction(OStrapMCM.SosFaction)
    endIf
EndFunction

; Returns a randomly chosen enabled strapon.
form Function ReturnRandomValidStrapon()
    int data = JValue.ReadFromFile(JContainers.UserDirectory() + "StraponsAll.json")
    if (data == false)
        WriteLog("StraponsAll.json file not found.", true)
        return None
    endif
    int enabledStrapons = JArray.Object()
    string StraponNameKey = Jmap.NextKey(Data)
    while StraponNameKey
        bool straponEnabled = JValue.SolveInt(Data, "." + StraponNameKey + ".Enabled") as Bool
        if (StraponEnabled == true)
            Form straponForm = JValue.SolveForm(Data, "." + StraponNameKey + ".Form")
            Jarray.AddForm(EnabledStrapons, straponForm)
        endIf
        StraponNameKey = Jmap.NextKey(Data, StraponNameKey)
    endWhile
    int Len = JValue.Count(EnabledStrapons)
    int rand = Utility.RandomInt(0, (Len - 1))
    writelog(rand)
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