#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent

; -------------------------
; VERSION & UPDATE
; -------------------------
global currentVersion  := "1.1"
global versionURL      := "https://raw.githubusercontent.com/kaylaho/LazyGardenMacro/main/version.txt"
global scriptURL       := "https://raw.githubusercontent.com/kaylaho/LazyGardenMacro/main/LazyGardenMacro.ahk"

; -------------------------
; ICON
; -------------------------
global iconPath := ""
if FileExist(A_ScriptDir "\images\icon.ico")
    iconPath := A_ScriptDir "\images\icon.ico"
else if FileExist(A_ScriptDir "\images\icon.png")
    iconPath := A_ScriptDir "\images\icon.png"

if (iconPath != "")
    TraySetIcon iconPath

SetWindowIcon(hwnd)
{
    global iconPath
    if (iconPath = "" || hwnd = 0)
        return
    hIcon := DllCall("LoadImage", "Ptr", 0, "Str", iconPath,
                     "UInt", 1, "Int", 32, "Int", 32,
                     "UInt", 0x10, "Ptr")
    if hIcon
    {
        SendMessage 0x80, 0, hIcon,, "ahk_id " hwnd
        SendMessage 0x80, 1, hIcon,, "ahk_id " hwnd
    }
}

; -------------------------
; GLOBALS
; -------------------------
global paused          := false
global sleepIndex      := 5
global sleepValues     := [0.0000000000000000000000000000000000000000000000000001, 50, 60, 70, 80, 90, 100]
global helpVisible     := false
global exitConfirm     := false
global settingsVisible := false
global settingsGui     := 0
global mainGui         := 0
global settingsFile    := A_ScriptDir "\lazy_garden_settings.ini"

; Spam Preset 1
global holdKey         := "MButton"
global spamKey         := "LButton"
global holdDuration    := 1
global preset1Active   := true

; Spam Preset 2
global holdKey2        := "RButton"
global spamKey2        := "RButton"
global holdDuration2   := 1
global preset2Active   := false

; Preset switch keybinds
global presetSwitchKey := "F6"
global preset2AddKey   := "F7"
global bothActive      := false

; Speed / misc
global speedKey        := "XButton2"
global speedKey2       := "'"
global soundVolume     := 50
global showHelpOnStart := true
global restartKey      := "F8"

; Wiggle settings
global wiggleHoldKey   := "Z"
global wiggleKeyA      := "a"
global wiggleKeyB      := "d"
global wiggleHoldA     := 55
global wiggleHoldB     := 55
global wiggleDelay     := 10

; Sequence macro settings
global seqHoldKey      := "F5"
global seqLoopCount    := 0
global seqLoopDelay    := 500
global seqStepCount    := 4
global seqKeys         := ["w", "s", "a", "d", "", "", "", ""]
global seqHolds        := [500, 500, 300, 300, 0, 0, 0, 0]
global seqDelays       := [100, 100, 100, 100, 0, 0, 0, 0]
global seqRunning      := false

; Recorrection settings
global recorStepCount  := 2
global recorInterval   := 60
global recorKeys       := ["w", "s", "", ""]
global recorHolds      := [300, 300, 0, 0]
global recorDelays     := [100, 100, 0, 0]
global recorRunning    := false

; Colors
global colorMain       := "1a1a2e"
global colorSettings   := "16213e"
global colorHelp       := "1a1a2e"
global colorText       := "e0e0e0"

; -------------------------
; LOAD / SAVE SETTINGS
; -------------------------
LoadSettings()
{
    global holdKey, spamKey, holdDuration, preset1Active
    global holdKey2, spamKey2, holdDuration2, preset2Active, bothActive
    global presetSwitchKey, preset2AddKey
    global speedKey, speedKey2, sleepIndex, restartKey
    global soundVolume, showHelpOnStart, settingsFile
    global wiggleHoldKey, wiggleKeyA, wiggleKeyB, wiggleHoldA, wiggleHoldB, wiggleDelay
    global colorMain, colorSettings, colorHelp, colorText
    global seqHoldKey, seqLoopCount, seqLoopDelay, seqStepCount, seqKeys, seqHolds, seqDelays
    global recorInterval, recorStepCount, recorKeys, recorHolds, recorDelays

    if !FileExist(settingsFile)
        return

    holdKey          := IniRead(settingsFile, "Preset1",  "HoldKey",        holdKey)
    spamKey          := IniRead(settingsFile, "Preset1",  "SpamKey",        spamKey)
    holdDuration     := Integer(IniRead(settingsFile, "Preset1", "HoldDuration", holdDuration))
    holdKey2         := IniRead(settingsFile, "Preset2",  "HoldKey",        holdKey2)
    spamKey2         := IniRead(settingsFile, "Preset2",  "SpamKey",        spamKey2)
    holdDuration2    := Integer(IniRead(settingsFile, "Preset2", "HoldDuration", holdDuration2))
    presetSwitchKey  := IniRead(settingsFile, "Presets",  "SwitchKey",      presetSwitchKey)
    preset2AddKey    := IniRead(settingsFile, "Presets",  "BothKey",        preset2AddKey)
    speedKey         := IniRead(settingsFile, "Keys",     "SpeedKey",       speedKey)
    speedKey2        := IniRead(settingsFile, "Keys",     "SpeedKey2",      speedKey2)
    restartKey       := IniRead(settingsFile, "Keys",     "RestartKey",     restartKey)
    sleepIndex       := Integer(IniRead(settingsFile, "Settings", "SpeedIndex",   sleepIndex))
    soundVolume      := Integer(IniRead(settingsFile, "Settings", "SoundVolume",  soundVolume))
    showHelpOnStart  := (IniRead(settingsFile, "Settings", "ShowHelpOnStart", "1") = "1")
    wiggleHoldKey    := IniRead(settingsFile, "Wiggle",   "WiggleHoldKey",  wiggleHoldKey)
    wiggleKeyA       := IniRead(settingsFile, "Wiggle",   "WiggleKeyA",     wiggleKeyA)
    wiggleKeyB       := IniRead(settingsFile, "Wiggle",   "WiggleKeyB",     wiggleKeyB)
    wiggleHoldA      := Integer(IniRead(settingsFile, "Wiggle", "WiggleHoldA", wiggleHoldA))
    wiggleHoldB      := Integer(IniRead(settingsFile, "Wiggle", "WiggleHoldB", wiggleHoldB))
    wiggleDelay      := Integer(IniRead(settingsFile, "Wiggle", "WiggleDelay", wiggleDelay))
    colorMain        := IniRead(settingsFile, "Colors", "Main",     colorMain)
    colorSettings    := IniRead(settingsFile, "Colors", "Settings", colorSettings)
    colorHelp        := IniRead(settingsFile, "Colors", "Help",     colorHelp)
    colorText        := IniRead(settingsFile, "Colors", "Text",     colorText)
    seqHoldKey       := IniRead(settingsFile, "Sequence", "HoldKey",    seqHoldKey)
    seqLoopCount     := Integer(IniRead(settingsFile, "Sequence", "LoopCount",  seqLoopCount))
    seqLoopDelay     := Integer(IniRead(settingsFile, "Sequence", "LoopDelay",  seqLoopDelay))
    seqStepCount     := Integer(IniRead(settingsFile, "Sequence", "StepCount",  seqStepCount))
    Loop 8
    {
        i := A_Index
        seqKeys[i]   := IniRead(settingsFile, "Sequence", "Key"   . i, seqKeys[i])
        seqHolds[i]  := Integer(IniRead(settingsFile, "Sequence", "Hold"  . i, seqHolds[i]))
        seqDelays[i] := Integer(IniRead(settingsFile, "Sequence", "Delay" . i, seqDelays[i]))
    }
    recorInterval  := Integer(IniRead(settingsFile, "Recorrection", "Interval",  recorInterval))
    recorStepCount := Integer(IniRead(settingsFile, "Recorrection", "StepCount", recorStepCount))
    Loop 4
    {
        i := A_Index
        recorKeys[i]   := IniRead(settingsFile, "Recorrection", "Key"   . i, recorKeys[i])
        recorHolds[i]  := Integer(IniRead(settingsFile, "Recorrection", "Hold"  . i, recorHolds[i]))
        recorDelays[i] := Integer(IniRead(settingsFile, "Recorrection", "Delay" . i, recorDelays[i]))
    }
}

SaveSettings()
{
    global holdKey, spamKey, holdDuration
    global holdKey2, spamKey2, holdDuration2
    global presetSwitchKey, preset2AddKey
    global speedKey, speedKey2, sleepIndex, restartKey
    global soundVolume, showHelpOnStart, settingsFile
    global wiggleHoldKey, wiggleKeyA, wiggleKeyB, wiggleHoldA, wiggleHoldB, wiggleDelay
    global colorMain, colorSettings, colorHelp, colorText
    global seqHoldKey, seqLoopCount, seqLoopDelay, seqStepCount, seqKeys, seqHolds, seqDelays
    global recorInterval, recorStepCount, recorKeys, recorHolds, recorDelays

    IniWrite holdKey,                       settingsFile, "Preset1", "HoldKey"
    IniWrite spamKey,                       settingsFile, "Preset1", "SpamKey"
    IniWrite holdDuration,                  settingsFile, "Preset1", "HoldDuration"
    IniWrite holdKey2,                      settingsFile, "Preset2", "HoldKey"
    IniWrite spamKey2,                      settingsFile, "Preset2", "SpamKey"
    IniWrite holdDuration2,                 settingsFile, "Preset2", "HoldDuration"
    IniWrite presetSwitchKey,               settingsFile, "Presets", "SwitchKey"
    IniWrite preset2AddKey,                 settingsFile, "Presets", "BothKey"
    IniWrite speedKey,                      settingsFile, "Keys",    "SpeedKey"
    IniWrite speedKey2,                     settingsFile, "Keys",    "SpeedKey2"
    IniWrite restartKey,                    settingsFile, "Keys",    "RestartKey"
    IniWrite sleepIndex,                    settingsFile, "Settings","SpeedIndex"
    IniWrite soundVolume,                   settingsFile, "Settings","SoundVolume"
    IniWrite (showHelpOnStart ? "1" : "0"), settingsFile, "Settings","ShowHelpOnStart"
    IniWrite wiggleHoldKey,                 settingsFile, "Wiggle",  "WiggleHoldKey"
    IniWrite wiggleKeyA,                    settingsFile, "Wiggle",  "WiggleKeyA"
    IniWrite wiggleKeyB,                    settingsFile, "Wiggle",  "WiggleKeyB"
    IniWrite wiggleHoldA,                   settingsFile, "Wiggle",  "WiggleHoldA"
    IniWrite wiggleHoldB,                   settingsFile, "Wiggle",  "WiggleHoldB"
    IniWrite wiggleDelay,                   settingsFile, "Wiggle",  "WiggleDelay"
    IniWrite colorMain,                     settingsFile, "Colors",  "Main"
    IniWrite colorSettings,                 settingsFile, "Colors",  "Settings"
    IniWrite colorHelp,                     settingsFile, "Colors",  "Help"
    IniWrite colorText,                     settingsFile, "Colors",  "Text"
    IniWrite seqHoldKey,   settingsFile, "Sequence", "HoldKey"
    IniWrite seqLoopCount, settingsFile, "Sequence", "LoopCount"
    IniWrite seqLoopDelay, settingsFile, "Sequence", "LoopDelay"
    IniWrite seqStepCount, settingsFile, "Sequence", "StepCount"
    Loop 8
    {
        i := A_Index
        IniWrite seqKeys[i],   settingsFile, "Sequence", "Key"   . i
        IniWrite seqHolds[i],  settingsFile, "Sequence", "Hold"  . i
        IniWrite seqDelays[i], settingsFile, "Sequence", "Delay" . i
    }
    IniWrite recorInterval,  settingsFile, "Recorrection", "Interval"
    IniWrite recorStepCount, settingsFile, "Recorrection", "StepCount"
    Loop 4
    {
        i := A_Index
        IniWrite recorKeys[i],   settingsFile, "Recorrection", "Key"   . i
        IniWrite recorHolds[i],  settingsFile, "Recorrection", "Hold"  . i
        IniWrite recorDelays[i], settingsFile, "Recorrection", "Delay" . i
    }
}

LoadSettings()

; -------------------------
; TRAY MENU
; -------------------------
SetupTray()
{
    A_TrayMenu.Delete()
    A_TrayMenu.Add("⚙ Settings & Keybinds", (*) => OpenSettings())
    A_TrayMenu.Add("❓ Help Guide",          (*) => ToggleHelp())
    A_TrayMenu.Add("")
    A_TrayMenu.Add("▶ Open Main Window",    (*) => ShowMainWindow())
    A_TrayMenu.Add("")
    A_TrayMenu.Add("⟳ Save && Restart",     (*) => DoRestart())
    A_TrayMenu.Add("✖ Exit",                (*) => ConfirmExit())
    A_TrayMenu.Default := "▶ Open Main Window"
    A_IconTip := "Lazy Garden Macro"
}

SetupTray()

; -------------------------
; HOTKEY REGISTRATION
; -------------------------
RegisterHotkeys()
{
    global holdKey, holdKey2, speedKey, speedKey2
    global wiggleHoldKey, restartKey, presetSwitchKey, preset2AddKey, seqHoldKey

    try
        HotKey "*" . holdKey, SpamLoop1
    catch as err
        MsgBox "Could not register Preset 1 Hold Key: [" . holdKey . "]"

    if (holdKey2 != "" && holdKey2 != holdKey)
        try HotKey "*" . holdKey2, SpamLoop2
    if (speedKey != "")
        try HotKey "*" . speedKey, ChangeSpeed
    if (speedKey2 != "" && speedKey2 != speedKey)
        try HotKey "*" . speedKey2, ChangeSpeed
    if (wiggleHoldKey != "" && wiggleHoldKey != holdKey && wiggleHoldKey != holdKey2)
        try HotKey "*" . wiggleHoldKey, WiggleLoop
    if (restartKey != "")
        try HotKey restartKey, DoRestart
    if (presetSwitchKey != "")
        try HotKey presetSwitchKey, SwitchPreset
    if (preset2AddKey != "" && preset2AddKey != presetSwitchKey)
        try HotKey preset2AddKey, ToggleBothPresets
    if (seqHoldKey != "")
        try HotKey seqHoldKey, SequenceLoop

    UpdatePresetHotkeyStates()
}

UnregisterHotkeys()
{
    global holdKey, holdKey2, speedKey, speedKey2
    global wiggleHoldKey, restartKey, presetSwitchKey, preset2AddKey, seqHoldKey

    try HotKey "*" . holdKey, SpamLoop1, "Off"
    if (holdKey2 != "" && holdKey2 != holdKey)
        try HotKey "*" . holdKey2, SpamLoop2, "Off"
    if (speedKey != "")
        try HotKey "*" . speedKey, ChangeSpeed, "Off"
    if (speedKey2 != "" && speedKey2 != speedKey)
        try HotKey "*" . speedKey2, ChangeSpeed, "Off"
    if (wiggleHoldKey != "")
        try HotKey "*" . wiggleHoldKey, WiggleLoop, "Off"
    if (restartKey != "")
        try HotKey restartKey, DoRestart, "Off"
    if (presetSwitchKey != "")
        try HotKey presetSwitchKey, SwitchPreset, "Off"
    if (preset2AddKey != "" && preset2AddKey != presetSwitchKey)
        try HotKey preset2AddKey, ToggleBothPresets, "Off"
    if (seqHoldKey != "")
        try HotKey seqHoldKey, SequenceLoop, "Off"
}

ReenableHotkeys()
{
    global holdKey, holdKey2, speedKey, speedKey2
    global wiggleHoldKey, restartKey, presetSwitchKey, preset2AddKey, seqHoldKey

    try HotKey "*" . holdKey, SpamLoop1, "On"
    if (holdKey2 != "" && holdKey2 != holdKey)
        try HotKey "*" . holdKey2, SpamLoop2, "On"
    if (speedKey != "")
        try HotKey "*" . speedKey, ChangeSpeed, "On"
    if (speedKey2 != "" && speedKey2 != speedKey)
        try HotKey "*" . speedKey2, ChangeSpeed, "On"
    if (wiggleHoldKey != "")
        try HotKey "*" . wiggleHoldKey, WiggleLoop, "On"
    if (restartKey != "")
        try HotKey restartKey, DoRestart, "On"
    if (presetSwitchKey != "")
        try HotKey presetSwitchKey, SwitchPreset, "On"
    if (preset2AddKey != "" && preset2AddKey != presetSwitchKey)
        try HotKey preset2AddKey, ToggleBothPresets, "On"
    if (seqHoldKey != "")
        try HotKey seqHoldKey, SequenceLoop, "On"
    UpdatePresetHotkeyStates()
}

UpdatePresetHotkeyStates()
{
    global holdKey, holdKey2, preset1Active, preset2Active, bothActive
    state1 := (preset1Active || bothActive) ? "On" : "Off"
    try HotKey "*" . holdKey, SpamLoop1, state1
    if (holdKey2 != "" && holdKey2 != holdKey)
    {
        state2 := (preset2Active || bothActive) ? "On" : "Off"
        try HotKey "*" . holdKey2, SpamLoop2, state2
    }
}

; -------------------------
; PRESET SWITCHING
; -------------------------
SwitchPreset(*)
{
    global preset1Active, preset2Active, bothActive
    if bothActive
        return
    if preset1Active
    {
        preset1Active := false
        preset2Active := true
        ShowMessage("Preset 2 active ✦")
    }
    else
    {
        preset1Active := true
        preset2Active := false
        ShowMessage("Preset 1 active ✦")
    }
    UpdatePresetHotkeyStates()
    UpdateMainStatus()
}

ToggleBothPresets(*)
{
    global preset1Active, preset2Active, bothActive
    bothActive := !bothActive
    if bothActive
    {
        preset1Active := true
        preset2Active := true
        ShowMessage("Both presets active ✦✦")
    }
    else
    {
        preset1Active := true
        preset2Active := false
        ShowMessage("Preset 1 active ✦")
    }
    UpdatePresetHotkeyStates()
    UpdateMainStatus()
}

; -------------------------
; SPAM LOOPS
; -------------------------
SpamLoop1(thisKey)
{
    global sleepValues, sleepIndex, holdKey, spamKey, holdDuration
    while GetKeyState(holdKey, "P")
    {
        if RegExMatch(spamKey, "i)^(Left|Right|Middle)$")
        {
            Click spamKey . " Down"
            Sleep holdDuration
            Click spamKey . " Up"
        }
        else
        {
            Send "{" . spamKey . " Down}"
            Sleep holdDuration
            Send "{" . spamKey . " Up}"
        }
        elapsed := 0
        target  := sleepValues[sleepIndex]
        while (elapsed < target && GetKeyState(holdKey, "P"))
        {
            Sleep 10
            elapsed += 10
            if (sleepValues[sleepIndex] != target)
                break
        }
    }
}

SpamLoop2(thisKey)
{
    global sleepValues, sleepIndex, holdKey2, spamKey2, holdDuration2
    while GetKeyState(holdKey2, "P")
    {
        if RegExMatch(spamKey2, "i)^(Left|Right|Middle)$")
        {
            Click spamKey2 . " Down"
            Sleep holdDuration2
            Click spamKey2 . " Up"
        }
        else
        {
            Send "{" . spamKey2 . " Down}"
            Sleep holdDuration2
            Send "{" . spamKey2 . " Up}"
        }
        elapsed := 0
        target  := sleepValues[sleepIndex]
        while (elapsed < target && GetKeyState(holdKey2, "P"))
        {
            Sleep 10
            elapsed += 10
            if (sleepValues[sleepIndex] != target)
                break
        }
    }
}

; -------------------------
; RECORRECTION RUNNER
; -------------------------
RunRecorrection()
{
    global recorStepCount, recorKeys, recorHolds, recorDelays, seqRunning
    ShowMessage("↺ Recorrection running...")
    i := 1
    while (i <= recorStepCount && seqRunning)
    {
        k := recorKeys[i]
        h := recorHolds[i]
        d := recorDelays[i]
        if (k != "")
        {
            if RegExMatch(k, "i)^(Left|Right|Middle)$")
            {
                Click k . " Down"
                Sleep h
                Click k . " Up"
            }
            else
            {
                Send "{" . k . " Down}"
                Sleep h
                Send "{" . k . " Up}"
            }
            if (d > 0)
                Sleep d
        }
        i++
    }
    ShowMessage("↺ Recorrection done — resuming ▶")
}

; -------------------------
; SEQUENCE MACRO LOOP
; -------------------------
SequenceLoop(thisKey)
{
    global seqHoldKey, seqLoopCount, seqLoopDelay, seqStepCount
    global seqKeys, seqHolds, seqDelays, seqRunning
    global recorInterval, recorRunning

    if seqRunning
    {
        seqRunning := false
        ShowMessage("Sequence stopped ✖")
        return
    }
    seqRunning   := true
    recorRunning := false
    ShowMessage("Sequence started ▶")

    loopsDone     := 0
    lastRecorTime := A_TickCount

    while (seqRunning && (seqLoopCount = 0 || loopsDone < seqLoopCount))
    {
        if (recorInterval > 0 && (A_TickCount - lastRecorTime) / 1000 >= recorInterval)
        {
            recorRunning  := true
            RunRecorrection()
            recorRunning  := false
            lastRecorTime := A_TickCount
            if !seqRunning
                break
        }

        i := 1
        while (i <= seqStepCount && seqRunning)
        {
            if (recorInterval > 0 && (A_TickCount - lastRecorTime) / 1000 >= recorInterval)
            {
                recorRunning  := true
                RunRecorrection()
                recorRunning  := false
                lastRecorTime := A_TickCount
                if !seqRunning
                    break
            }

            k := seqKeys[i]
            h := seqHolds[i]
            d := seqDelays[i]
            if (k != "")
            {
                if RegExMatch(k, "i)^(Left|Right|Middle)$")
                {
                    Click k . " Down"
                    Sleep h
                    Click k . " Up"
                }
                else
                {
                    Send "{" . k . " Down}"
                    Sleep h
                    Send "{" . k . " Up}"
                }
                if (d > 0)
                    Sleep d
            }
            i++
        }

        loopsDone++
        if (seqRunning && (seqLoopCount = 0 || loopsDone < seqLoopCount))
            Sleep seqLoopDelay
    }

    seqRunning := false
    ShowMessage("Sequence finished ✔")
}

StopSequence()
{
    global seqRunning
    seqRunning := false
    ShowMessage("Sequence stopped ✖")
}

; -------------------------
; WIGGLE LOOP
; -------------------------
WiggleLoop(thisKey)
{
    global wiggleHoldKey, wiggleKeyA, wiggleKeyB, wiggleHoldA, wiggleHoldB, wiggleDelay
    while GetKeyState(wiggleHoldKey, "P")
    {
        Send "{" . wiggleKeyA . " Down}"
        Sleep wiggleHoldA
        Send "{" . wiggleKeyA . " Up}"
        Sleep wiggleDelay
        if !GetKeyState(wiggleHoldKey, "P")
            break
        Send "{" . wiggleKeyB . " Down}"
        Sleep wiggleHoldB
        Send "{" . wiggleKeyB . " Up}"
        Sleep wiggleDelay
    }
}

; -------------------------
; TOOLTIP HELPER
; -------------------------
ShowMessage(text)
{
    ToolTip text
    SetTimer ClearTip, -2450
}

ClearTip()
{
    ToolTip
}

; -------------------------
; PLAY SOUND
; -------------------------
PlaySound(filePath)
{
    global soundVolume
    if !FileExist(filePath)
        return
    scaledVol := Round((soundVolume / 100.0) * 65535)
    packedVol := scaledVol | (scaledVol << 16)
    DllCall("winmm.dll\waveOutSetVolume", "UInt", 0, "UInt", packedVol)
    DllCall("winmm.dll\PlaySoundW", "Ptr", 0,        "Ptr", 0, "UInt", 0)
    DllCall("winmm.dll\PlaySoundW", "Str", filePath, "Ptr", 0, "UInt", 0x20001)
}

; -------------------------
; MAIN WINDOW
; -------------------------
global statusLabel := 0
global delayLabel  := 0
global presetLabel := 0

MainWindowClose(*)
{
    global exitConfirm, mainGui
    if !exitConfirm
    {
        exitConfirm := true
        ShowMessage("⚠ Click X again to close the macro ⚠")
        SetTimer ResetConfirm, -2450
        return 1
    }
    totalTime := 450
    interval  := 10
    steps     := totalTime // interval
    Loop steps
    {
        remaining := totalTime - A_Index * interval
        ToolTip "✗⸝⸝Closing in " . Format("{:.2f}", remaining / 1000) . "s...⸝⸝✗"
        Sleep interval
    }
    ToolTip "✞︎ Goodbye, my love. ✞︎"
    Sleep 950
    ExitApp
}

BuildMainWindow()
{
    global mainGui, statusLabel, delayLabel, presetLabel
    global holdKey, spamKey, holdKey2, spamKey2
    global wiggleHoldKey, wiggleKeyA, wiggleKeyB, sleepValues, sleepIndex
    global colorMain

    mainGui := Gui("+AlwaysOnTop", "Lazy Garden Macro")
    mainGui.SetFont("s9")
    mainGui.BackColor := colorMain
    mainGui.OnEvent("Close", MainWindowClose)

    mainGui.Add("Text", "w240 Center cWhite", "✿ LAZY GARDEN MACRO ✿")
    mainGui.Add("Text", "w240 Center cWhite", "♡⸝⸝Made by: kaylah⸝⸝♡")
    mainGui.Add("Text", "w240 y+4 h1 0x10 cWhite", "")

    statusLabel := mainGui.Add("Text", "w120 y+6 cWhite", "▶ Running")
    delayLabel  := mainGui.Add("Text", "x+0 w120 Right cWhite", sleepValues[sleepIndex] . "ms delay")

    mainGui.Add("Text", "w240 y+4 cWhite", "P1: [" . holdKey . "] → " . spamKey)
    mainGui.Add("Text", "w240 y+2 cWhite", "P2: [" . holdKey2 . "] → " . spamKey2)
    mainGui.Add("Text", "w240 y+2 cWhite", "Wiggle: [" . wiggleHoldKey . "] → " . wiggleKeyA . " ↔ " . wiggleKeyB)

    presetLabel := mainGui.Add("Text", "w240 y+4 cWhite", "Active: Preset 1")
    mainGui.Add("Text", "w240 y+6 h1 0x10 cWhite", "")

    btnPause    := mainGui.Add("Button", "w114 y+8",  "⏸ Pause  [F2]")
    btnSettings := mainGui.Add("Button", "x+6 w114",  "⚙ Settings  [F9]")
    btnHelp     := mainGui.Add("Button", "w114 y+4",  "❓ Help  [F1]")
    btnRestart  := mainGui.Add("Button", "x+6 w114",  "⟳ Save & Restart")
    btnExit     := mainGui.Add("Button", "w234 y+4",  "✖ Exit  [F3]")

    btnPause.OnEvent("Click",    (*) => TogglePause())
    btnSettings.OnEvent("Click", (*) => OpenSettings())
    btnHelp.OnEvent("Click",     (*) => ToggleHelp())
    btnRestart.OnEvent("Click",  (*) => DoRestart())
    btnExit.OnEvent("Click",     (*) => ConfirmExit())

    mainGui.Show()
    SetWindowIcon(mainGui.Hwnd)
}

ShowMainWindow()
{
    global mainGui
    mainGui.Show()
}

UpdateMainStatus()
{
    global statusLabel, delayLabel, presetLabel
    global paused, sleepValues, sleepIndex, preset1Active, preset2Active, bothActive

    if IsObject(statusLabel)
        statusLabel.Value := paused ? "⏸ Paused" : "▶ Running"
    if IsObject(delayLabel)
        delayLabel.Value := sleepValues[sleepIndex] . "ms delay"
    if IsObject(presetLabel)
    {
        if bothActive
            presetLabel.Value := "Active: Both presets"
        else if preset1Active
            presetLabel.Value := "Active: Preset 1"
        else
            presetLabel.Value := "Active: Preset 2"
    }
}

; -------------------------
; HELP WINDOW
; -------------------------
global helpGui   := 0
global helpLabel := 0

BuildHelpGui()
{
    global helpGui, helpLabel, showHelpOnStart, helpVisible, colorHelp

    helpGui := Gui("+AlwaysOnTop", "Lazy Garden — Help Guide")
    helpGui.SetFont("s10")
    helpGui.BackColor := colorHelp
    helpGui.OnEvent("Close", (*) => (helpGui.Hide(), helpVisible := false))
    helpLabel := helpGui.Add("Text", "w360 cWhite", GetHelpText())
    helpGui.Add("Button", "w80", "Close").OnEvent("Click", (*) => (helpGui.Hide(), helpVisible := false))

    if showHelpOnStart
    {
        helpGui.Show()
        helpVisible := true
    }
}

GetHelpText()
{
    global holdKey, spamKey, holdKey2, spamKey2
    global speedKey, speedKey2, sleepValues, sleepIndex
    global wiggleHoldKey, wiggleKeyA, wiggleKeyB, restartKey
    global presetSwitchKey, preset2AddKey, recorInterval

    spd1  := (speedKey        != "") ? speedKey        : "(none)"
    spd2  := (speedKey2       != "") ? speedKey2       : "(none)"
    wHold := (wiggleHoldKey   != "") ? wiggleHoldKey   : "(none)"
    rKey  := (restartKey      != "") ? restartKey      : "(none)"
    swKey := (presetSwitchKey != "") ? presetSwitchKey : "(none)"
    btKey := (preset2AddKey   != "") ? preset2AddKey   : "(none)"
    recorNote := (recorInterval > 0)
        ? "Recorrection fires every " . recorInterval . "s during sequence."
        : "Recorrection is disabled (interval = 0)."

    return (
        "⁺‧₊˚ ཐི⋆ HOW TO USE LAZY GARDEN MACRO ⋆ཋྀ ˚₊‧⁺`n`n"
        . "— SPAM PRESET 1 —`n"
        . "Hold [" . holdKey . "] → spams [" . spamKey . "]`n`n"
        . "— SPAM PRESET 2 —`n"
        . "Hold [" . holdKey2 . "] → spams [" . spamKey2 . "]`n`n"
        . "— WIGGLE —`n"
        . "Hold [" . wHold . "] → [" . wiggleKeyA . "] ↔ [" . wiggleKeyB . "]`n`n"
        . "[" . spd1 . "] or [" . spd2 . "] → Cycle spam delay (" . sleepValues[sleepIndex] . "ms)`n"
        . "[" . swKey . "]  → Switch between preset 1 / preset 2`n"
        . "[" . btKey . "]  → Toggle both presets active at once`n`n"
        . "F1  → Show / Hide help`n"
        . "F2  → Pause / Unpause`n"
        . "F3  → Exit macro (press twice)`n"
        . rKey . "  → Save & Restart`n"
        . "F9  → Settings & Keybinds`n`n"
        . "— RECORRECTION —`n"
        . recorNote . "`n"
        . "Configure in Settings → Sequence tab."
    )
}

ToggleHelp()
{
    global helpGui, helpVisible, helpLabel
    if helpVisible
    {
        helpGui.Hide()
        helpVisible := false
    }
    else
    {
        helpLabel.Value := GetHelpText()
        helpGui.Show()
        helpVisible := true
    }
}

; -------------------------
; SETTINGS GUI
; -------------------------
global sHoldEdit, sSpamEdit, sHoldDurEdit
global sHoldEdit2, sSpamEdit2, sHoldDurEdit2
global sPresetSwitchEdit, sPreset2AddEdit
global sSpeed1Edit, sSpeed2Edit, sRestartEdit
global sVolSlider, sVolLabel, sHelpCheck
global sWiggleHoldEdit, sWiggleKeyAEdit, sWiggleKeyBEdit
global sWiggleHoldAEdit, sWiggleHoldBEdit, sWiggleDelayEdit
global sColorMainEdit, sColorSettingsEdit, sColorHelpEdit
global sSeqHoldEdit, sSeqLoopEdit, sSeqLoopDelayEdit, sSeqStepCountEdit
global sSeqKeyEdits, sSeqHoldEdits, sSeqDelayEdits
global sRecorIntervalEdit, sRecorStepCountEdit
global sRecorKeyEdits, sRecorHoldEdits, sRecorDelayEdits

BuildSettingsGui()
{
    global holdKey, spamKey, holdDuration
    global holdKey2, spamKey2, holdDuration2
    global presetSwitchKey, preset2AddKey
    global speedKey, speedKey2, restartKey, soundVolume, showHelpOnStart
    global wiggleHoldKey, wiggleKeyA, wiggleKeyB, wiggleHoldA, wiggleHoldB, wiggleDelay
    global colorMain, colorSettings, colorHelp
    global seqHoldKey, seqLoopCount, seqLoopDelay, seqStepCount, seqKeys, seqHolds, seqDelays
    global recorInterval, recorStepCount, recorKeys, recorHolds, recorDelays
    global settingsGui, settingsVisible
    global sHoldEdit, sSpamEdit, sHoldDurEdit
    global sHoldEdit2, sSpamEdit2, sHoldDurEdit2
    global sPresetSwitchEdit, sPreset2AddEdit
    global sSpeed1Edit, sSpeed2Edit, sRestartEdit
    global sVolSlider, sVolLabel, sHelpCheck
    global sWiggleHoldEdit, sWiggleKeyAEdit, sWiggleKeyBEdit
    global sWiggleHoldAEdit, sWiggleHoldBEdit, sWiggleDelayEdit
    global sColorMainEdit, sColorSettingsEdit, sColorHelpEdit
    global sSeqHoldEdit, sSeqLoopEdit, sSeqLoopDelayEdit, sSeqStepCountEdit
    global sSeqKeyEdits, sSeqHoldEdits, sSeqDelayEdits
    global sRecorIntervalEdit, sRecorStepCountEdit
    global sRecorKeyEdits, sRecorHoldEdits, sRecorDelayEdits

    settingsGui := Gui("+AlwaysOnTop", "Lazy Garden — Settings Menu")
    settingsGui.SetFont("s9")
    settingsGui.BackColor := colorSettings
    settingsGui.OnEvent("Close", (*) => (settingsGui.Hide(), settingsVisible := false))

    ; Tab control — x10 y10, wide and tall enough for all content
    tabs := settingsGui.Add("Tab3", "x10 y10 w460 h785",
        ["Presets && Spammy", "Wiggle", "Sequence [ALPHA]", "Sound && Colors"])

    ; ==============================================================
    ; TAB 1 — PRESETS & KEYS
    ; First control MUST use absolute x,y inside the tab body.
    ; Tab3 body starts at roughly y=38 (tab strip height ~28px).
    ; We offset from the Tab3's own y=10, so body top = ~10+28 = 38.
    ; Use x=20, y=48 as the safe first anchor.
    ; ==============================================================
    tabs.UseTab(1)

    settingsGui.Add("Text",  "x20 y48 w200 Center cWhite",  "— SPAM PRESET 1 —")
    settingsGui.Add("Text",  "x20 y+8 w200 cWhite",         "Hold Key:")
    sHoldEdit     := settingsGui.Add("Edit", "x20 y+2 w200", holdKey)
    settingsGui.Add("Text",  "x20 y+6 w200 cWhite",         "Spam Key:")
    sSpamEdit     := settingsGui.Add("Edit", "x20 y+2 w200", spamKey)
    settingsGui.Add("Text",  "x20 y+6 w200 cWhite",         "Hold Duration (ms):")
    sHoldDurEdit  := settingsGui.Add("Edit", "x20 y+2 w80",  holdDuration)

    settingsGui.Add("Text",  "x20 y+14 w200 Center cWhite", "— SPAM PRESET 2 —")
    settingsGui.Add("Text",  "x20 y+8 w200 cWhite",         "Hold Key:")
    sHoldEdit2    := settingsGui.Add("Edit", "x20 y+2 w200", holdKey2)
    settingsGui.Add("Text",  "x20 y+6 w200 cWhite",         "Spam Key:")
    sSpamEdit2    := settingsGui.Add("Edit", "x20 y+2 w200", spamKey2)
    settingsGui.Add("Text",  "x20 y+6 w200 cWhite",         "Hold Duration (ms):")
    sHoldDurEdit2 := settingsGui.Add("Edit", "x20 y+2 w80",  holdDuration2)

    settingsGui.Add("Text",  "x20 y+14 w200 Center cWhite", "— PRESET SWITCH KEYS —")
    settingsGui.Add("Text",  "x20 y+8 w200 cWhite",         "Switch Preset Key:")
    sPresetSwitchEdit := settingsGui.Add("Edit", "x20 y+2 w200", presetSwitchKey)
    settingsGui.Add("Text",  "x20 y+6 w200 cWhite",         "Both Active Key:")
    sPreset2AddEdit   := settingsGui.Add("Edit", "x20 y+2 w200", preset2AddKey)

    settingsGui.Add("Text",  "x20 y+14 w200 Center cWhite", "— OTHER KEYS —")
    settingsGui.Add("Text",  "x20 y+8 w200 cWhite",         "Speed Key 1:  (blank = off)")
    sSpeed1Edit  := settingsGui.Add("Edit", "x20 y+2 w200",  speedKey)
    settingsGui.Add("Text",  "x20 y+6 w200 cWhite",         "Speed Key 2:  (blank = off)")
    sSpeed2Edit  := settingsGui.Add("Edit", "x20 y+2 w200",  speedKey2)
    settingsGui.Add("Text",  "x20 y+6 w200 cWhite",         "Save && Restart Key:")
    sRestartEdit := settingsGui.Add("Edit", "x20 y+2 w200",  restartKey)

    ; ==============================================================
    ; TAB 2 — WIGGLE
    ; ==============================================================
    tabs.UseTab(2)

    settingsGui.Add("Text",  "x20 y48 w220 Center cWhite",  "— WIGGLE SETTINGS —")
    settingsGui.Add("Text",  "x20 y+10 w220 cWhite",        "Wiggle Hold Key:")
    sWiggleHoldEdit  := settingsGui.Add("Edit", "x20 y+2 w200", wiggleHoldKey)
    settingsGui.Add("Text",  "x20 y+10 w100 cWhite",        "Key A:")
    sWiggleKeyAEdit  := settingsGui.Add("Edit", "x20 y+2 w80",  wiggleKeyA)
    settingsGui.Add("Text",  "x20 y+8 w100 cWhite",         "Key B:")
    sWiggleKeyBEdit  := settingsGui.Add("Edit", "x20 y+2 w80",  wiggleKeyB)
    settingsGui.Add("Text",  "x20 y+10 w220 cWhite",        "Key A Hold Duration (ms):")
    sWiggleHoldAEdit := settingsGui.Add("Edit", "x20 y+2 w80",  wiggleHoldA)
    settingsGui.Add("Text",  "x20 y+8 w220 cWhite",         "Key B Hold Duration (ms):")
    sWiggleHoldBEdit := settingsGui.Add("Edit", "x20 y+2 w80",  wiggleHoldB)
    settingsGui.Add("Text",  "x20 y+10 w220 cWhite",        "Delay Between Keys (ms):")
    sWiggleDelayEdit := settingsGui.Add("Edit", "x20 y+2 w80",  wiggleDelay)
    settingsGui.Add("Text",  "x20 y+20 w400 cWhite",
        "TIP: Wiggle alternates Key A → Key B while you hold the Wiggle Hold Key.`n"
        . "Tune hold durations and delay to control speed and distance.")

    ; ==============================================================
    ; TAB 3 — SEQUENCE
    ; ==============================================================
    tabs.UseTab(3)

    settingsGui.Add("Text",  "x20 y48 w420 Center cWhite",  "— SEQUENCE MACRO [IN ALPHA] —")
    settingsGui.Add("Text",  "x20 y+8 w420 cWhite",         "Activate Key  (press once to start, again to stop):")
    sSeqHoldEdit      := settingsGui.Add("Edit", "x20 y+2 w120", seqHoldKey)
    settingsGui.Add("Text",  "x20 y+8 w200 cWhite",         "Loop Count  (0 = infinite):")
    sSeqLoopEdit      := settingsGui.Add("Edit", "x20 y+2 w80",  seqLoopCount)
    settingsGui.Add("Text",  "x20 y+6 w200 cWhite",         "Delay Between Loops (ms):")
    sSeqLoopDelayEdit := settingsGui.Add("Edit", "x20 y+2 w80",  seqLoopDelay)
    settingsGui.Add("Text",  "x20 y+6 w200 cWhite",         "Number of Active Steps  (1–8):")
    sSeqStepCountEdit := settingsGui.Add("Edit", "x20 y+2 w80",  seqStepCount)

    ; Column header row — pin columns with absolute x
    settingsGui.Add("Text",  "x20 y+10 w30 cWhite",  "#")
    settingsGui.Add("Text",  "x54 yp   w100 cWhite", "Key")
    settingsGui.Add("Text",  "x158 yp  w80 cWhite",  "Hold ms")
    settingsGui.Add("Text",  "x242 yp  w80 cWhite",  "Delay ms")

    sSeqKeyEdits   := []
    sSeqHoldEdits  := []
    sSeqDelayEdits := []

    Loop 8
    {
        i := A_Index
        settingsGui.Add("Text",  "x20  y+5 w30 cWhite", i . ".")
        eKey   := settingsGui.Add("Edit", "x54  yp w100", seqKeys[i])
        eHold  := settingsGui.Add("Edit", "x158 yp w80",  seqHolds[i])
        eDelay := settingsGui.Add("Edit", "x242 yp w80",  seqDelays[i])
        sSeqKeyEdits.Push(eKey)
        sSeqHoldEdits.Push(eHold)
        sSeqDelayEdits.Push(eDelay)
    }

    ; ---- Recorrection ----
    settingsGui.Add("Text",  "x20 y+14 w420 Center cWhite", "— RECORRECTION —")
    settingsGui.Add("Text",  "x20 y+6 w420 cWhite",
        "Interrupts the sequence every N seconds, runs its own steps, then resumes.")
    settingsGui.Add("Text",  "x20 y+8 w240 cWhite",         "Interval in seconds  (0 = disabled):")
    sRecorIntervalEdit  := settingsGui.Add("Edit", "x20 y+2 w80",  recorInterval)
    settingsGui.Add("Text",  "x20 y+6 w240 cWhite",         "Number of Active Steps  (1–4):")
    sRecorStepCountEdit := settingsGui.Add("Edit", "x20 y+2 w80",  recorStepCount)

    settingsGui.Add("Text",  "x20 y+10 w30 cWhite",  "#")
    settingsGui.Add("Text",  "x54 yp   w100 cWhite", "Key")
    settingsGui.Add("Text",  "x158 yp  w80 cWhite",  "Hold ms")
    settingsGui.Add("Text",  "x242 yp  w80 cWhite",  "Delay ms")

    sRecorKeyEdits   := []
    sRecorHoldEdits  := []
    sRecorDelayEdits := []

    Loop 4
    {
        i := A_Index
        settingsGui.Add("Text",  "x20  y+5 w30 cWhite", i . ".")
        rKey   := settingsGui.Add("Edit", "x54  yp w100", recorKeys[i])
        rHold  := settingsGui.Add("Edit", "x158 yp w80",  recorHolds[i])
        rDelay := settingsGui.Add("Edit", "x242 yp w80",  recorDelays[i])
        sRecorKeyEdits.Push(rKey)
        sRecorHoldEdits.Push(rHold)
        sRecorDelayEdits.Push(rDelay)
    }

    ; ==============================================================
    ; TAB 4 — SOUND & COLORS
    ; ==============================================================
    tabs.UseTab(4)

    settingsGui.Add("Text",  "x20 y48 w240 Center cWhite",  "— SOUND —")
    settingsGui.Add("Text",  "x20 y+10 w40 cWhite",         "Volume:")
    sVolLabel  := settingsGui.Add("Text",   "x64 yp w36 cWhite", soundVolume . "%")
    sVolSlider := settingsGui.Add("Slider", "x104 yp w160 Range0-100 TickInterval10 AltSubmit", soundVolume)
    sVolSlider.OnEvent("Change", OnVolSliderChange)

    sHelpCheck := settingsGui.Add("Checkbox", "x20 y+12 w240 cWhite" . (showHelpOnStart ? " Checked" : ""),
        "Show help on startup")
    settingsGui.Add("Button", "x20 y+10 w120", "▶ Test Sound").OnEvent("Click",
        (*) => PlaySound(A_ScriptDir "\pop.wav"))

    settingsGui.Add("Text",  "x20 y+20 w240 Center cWhite", "— COLORS (hex, no #) —")
    settingsGui.Add("Text",  "x20 y+10 w240 cWhite",        "Main window background:")
    sColorMainEdit     := settingsGui.Add("Edit", "x20 y+2 w200", colorMain)
    settingsGui.Add("Text",  "x20 y+8 w240 cWhite",         "Settings window background:")
    sColorSettingsEdit := settingsGui.Add("Edit", "x20 y+2 w200", colorSettings)
    settingsGui.Add("Text",  "x20 y+8 w240 cWhite",         "Help window background:")
    sColorHelpEdit     := settingsGui.Add("Edit", "x20 y+2 w200", colorHelp)
    settingsGui.Add("Text",  "x20 y+14 w380 cWhite",
        "TIP: Any 6-digit hex color, e.g. 1a1a2e (dark navy) or ff69b4 (pink).`nChanges apply after Save && Restart.")

    ; ==============================================================
    ; SAVE / CANCEL — outside all tabs
    ; ==============================================================
    tabs.UseTab(0)

    btnSave   := settingsGui.Add("Button", "x10 y800 w150", "✔ Save && Restart")
    btnCancel := settingsGui.Add("Button", "x168 y800 w110", "✘ Cancel")
    btnCancel.OnEvent("Click", (*) => (settingsGui.Hide(), settingsVisible := false))
    btnSave.OnEvent("Click",   (*) => ApplySettingsFull())

    settingsGui.Show("Hide")
}

OnVolSliderChange(*)
{
    global sVolSlider, sVolLabel
    sVolLabel.Value := sVolSlider.Value . "%"
}

OpenSettings()
{
    global settingsVisible, settingsGui
    if settingsVisible
    {
        settingsGui.Hide()
        settingsVisible := false
    }
    else
    {
        settingsGui.Show()
        settingsVisible := true
    }
}

ApplySettingsFull()
{
    global holdKey, spamKey, holdDuration
    global holdKey2, spamKey2, holdDuration2
    global presetSwitchKey, preset2AddKey
    global speedKey, speedKey2, restartKey, soundVolume, showHelpOnStart
    global wiggleHoldKey, wiggleKeyA, wiggleKeyB, wiggleHoldA, wiggleHoldB, wiggleDelay
    global colorMain, colorSettings, colorHelp
    global seqHoldKey, seqLoopCount, seqLoopDelay, seqStepCount, seqKeys, seqHolds, seqDelays
    global recorInterval, recorStepCount, recorKeys, recorHolds, recorDelays
    global sHoldEdit, sSpamEdit, sHoldDurEdit
    global sHoldEdit2, sSpamEdit2, sHoldDurEdit2
    global sPresetSwitchEdit, sPreset2AddEdit
    global sSpeed1Edit, sSpeed2Edit, sRestartEdit
    global sVolSlider, sHelpCheck
    global sWiggleHoldEdit, sWiggleKeyAEdit, sWiggleKeyBEdit
    global sWiggleHoldAEdit, sWiggleHoldBEdit, sWiggleDelayEdit
    global sColorMainEdit, sColorSettingsEdit, sColorHelpEdit
    global sSeqHoldEdit, sSeqLoopEdit, sSeqLoopDelayEdit, sSeqStepCountEdit
    global sSeqKeyEdits, sSeqHoldEdits, sSeqDelayEdits
    global sRecorIntervalEdit, sRecorStepCountEdit
    global sRecorKeyEdits, sRecorHoldEdits, sRecorDelayEdits

    UnregisterHotkeys()

    holdKey         := Trim(sHoldEdit.Value)
    spamKey         := Trim(sSpamEdit.Value)
    holdDuration    := Integer(sHoldDurEdit.Value)
    holdKey2        := Trim(sHoldEdit2.Value)
    spamKey2        := Trim(sSpamEdit2.Value)
    holdDuration2   := Integer(sHoldDurEdit2.Value)
    presetSwitchKey := Trim(sPresetSwitchEdit.Value)
    preset2AddKey   := Trim(sPreset2AddEdit.Value)
    speedKey        := Trim(sSpeed1Edit.Value)
    speedKey2       := Trim(sSpeed2Edit.Value)
    restartKey      := Trim(sRestartEdit.Value)
    soundVolume     := Integer(sVolSlider.Value)
    showHelpOnStart := (sHelpCheck.Value = 1)
    wiggleHoldKey   := Trim(sWiggleHoldEdit.Value)
    wiggleKeyA      := Trim(sWiggleKeyAEdit.Value)
    wiggleKeyB      := Trim(sWiggleKeyBEdit.Value)
    wiggleHoldA     := Integer(sWiggleHoldAEdit.Value)
    wiggleHoldB     := Integer(sWiggleHoldBEdit.Value)
    wiggleDelay     := Integer(sWiggleDelayEdit.Value)
    colorMain       := Trim(sColorMainEdit.Value)
    colorSettings   := Trim(sColorSettingsEdit.Value)
    colorHelp       := Trim(sColorHelpEdit.Value)
    seqHoldKey      := Trim(sSeqHoldEdit.Value)
    seqLoopCount    := Integer(sSeqLoopEdit.Value)
    seqLoopDelay    := Integer(sSeqLoopDelayEdit.Value)
    seqStepCount    := Integer(sSeqStepCountEdit.Value)
    Loop 8
    {
        i := A_Index
        seqKeys[i]   := Trim(sSeqKeyEdits[i].Value)
        seqHolds[i]  := Integer(sSeqHoldEdits[i].Value)
        seqDelays[i] := Integer(sSeqDelayEdits[i].Value)
    }
    recorInterval  := Integer(sRecorIntervalEdit.Value)
    recorStepCount := Integer(sRecorStepCountEdit.Value)
    Loop 4
    {
        i := A_Index
        recorKeys[i]   := Trim(sRecorKeyEdits[i].Value)
        recorHolds[i]  := Integer(sRecorHoldEdits[i].Value)
        recorDelays[i] := Integer(sRecorDelayEdits[i].Value)
    }

    SaveSettings()
    ShowMessage("⚠ Reloading with new settings... ⚠")
    Sleep 700
    Run A_ScriptFullPath
    ExitApp
}

; -------------------------
; DO RESTART
; -------------------------
DoRestart(*)
{
    global holdKey, spamKey, holdDuration
    global holdKey2, spamKey2, holdDuration2
    global presetSwitchKey, preset2AddKey
    global speedKey, speedKey2, restartKey, soundVolume, showHelpOnStart
    global wiggleHoldKey, wiggleKeyA, wiggleKeyB, wiggleHoldA, wiggleHoldB, wiggleDelay
    global colorMain, colorSettings, colorHelp
    global seqHoldKey, seqLoopCount, seqLoopDelay, seqStepCount, seqKeys, seqHolds, seqDelays
    global recorInterval, recorStepCount, recorKeys, recorHolds, recorDelays
    global sHoldEdit, sSpamEdit, sHoldDurEdit
    global sHoldEdit2, sSpamEdit2, sHoldDurEdit2
    global sPresetSwitchEdit, sPreset2AddEdit
    global sSpeed1Edit, sSpeed2Edit, sRestartEdit
    global sVolSlider, sHelpCheck
    global sWiggleHoldEdit, sWiggleKeyAEdit, sWiggleKeyBEdit
    global sWiggleHoldAEdit, sWiggleHoldBEdit, sWiggleDelayEdit
    global sColorMainEdit, sColorSettingsEdit, sColorHelpEdit
    global sSeqHoldEdit, sSeqLoopEdit, sSeqLoopDelayEdit, sSeqStepCountEdit
    global sSeqKeyEdits, sSeqHoldEdits, sSeqDelayEdits
    global sRecorIntervalEdit, sRecorStepCountEdit
    global sRecorKeyEdits, sRecorHoldEdits, sRecorDelayEdits

    try
    {
        holdKey         := Trim(sHoldEdit.Value)
        spamKey         := Trim(sSpamEdit.Value)
        holdDuration    := Integer(sHoldDurEdit.Value)
        holdKey2        := Trim(sHoldEdit2.Value)
        spamKey2        := Trim(sSpamEdit2.Value)
        holdDuration2   := Integer(sHoldDurEdit2.Value)
        presetSwitchKey := Trim(sPresetSwitchEdit.Value)
        preset2AddKey   := Trim(sPreset2AddEdit.Value)
        speedKey        := Trim(sSpeed1Edit.Value)
        speedKey2       := Trim(sSpeed2Edit.Value)
        restartKey      := Trim(sRestartEdit.Value)
        soundVolume     := Integer(sVolSlider.Value)
        showHelpOnStart := (sHelpCheck.Value = 1)
        wiggleHoldKey   := Trim(sWiggleHoldEdit.Value)
        wiggleKeyA      := Trim(sWiggleKeyAEdit.Value)
        wiggleKeyB      := Trim(sWiggleKeyBEdit.Value)
        wiggleHoldA     := Integer(sWiggleHoldAEdit.Value)
        wiggleHoldB     := Integer(sWiggleHoldBEdit.Value)
        wiggleDelay     := Integer(sWiggleDelayEdit.Value)
        colorMain       := Trim(sColorMainEdit.Value)
        colorSettings   := Trim(sColorSettingsEdit.Value)
        colorHelp       := Trim(sColorHelpEdit.Value)
        seqHoldKey      := Trim(sSeqHoldEdit.Value)
        seqLoopCount    := Integer(sSeqLoopEdit.Value)
        seqLoopDelay    := Integer(sSeqLoopDelayEdit.Value)
        seqStepCount    := Integer(sSeqStepCountEdit.Value)
        Loop 8
        {
            i := A_Index
            seqKeys[i]   := Trim(sSeqKeyEdits[i].Value)
            seqHolds[i]  := Integer(sSeqHoldEdits[i].Value)
            seqDelays[i] := Integer(sSeqDelayEdits[i].Value)
        }
        recorInterval  := Integer(sRecorIntervalEdit.Value)
        recorStepCount := Integer(sRecorStepCountEdit.Value)
        Loop 4
        {
            i := A_Index
            recorKeys[i]   := Trim(sRecorKeyEdits[i].Value)
            recorHolds[i]  := Integer(sRecorHoldEdits[i].Value)
            recorDelays[i] := Integer(sRecorDelayEdits[i].Value)
        }
    }
    catch as err
    {
    }

    SaveSettings()
    ShowMessage("⚠ Saving & Restarting... ⚠")
    Sleep 500
    Run A_ScriptFullPath
    ExitApp
}

; -------------------------
; CHANGE SPEED
; -------------------------
ChangeSpeed(*)
{
    global sleepIndex, sleepValues
    sleepIndex++
    if (sleepIndex > sleepValues.Length)
        sleepIndex := 1
    ShowMessage("♡⸝⸝Delay: " . sleepValues[sleepIndex] . " ms⸝⸝♡")
    PlaySound(A_ScriptDir "\pop.wav")
    SaveSettings()
    UpdateMainStatus()
}

; -------------------------
; PAUSE TOGGLE
; -------------------------
TogglePause()
{
    global paused
    paused := !paused
    if paused
    {
        UnregisterHotkeys()
        ShowMessage("Paused ✖")
    }
    else
    {
        ReenableHotkeys()
        ShowMessage("Unpaused ✔")
    }
    UpdateMainStatus()
}

; -------------------------
; EXIT
; -------------------------
ConfirmExit(*)
{
    global exitConfirm
    if !exitConfirm
    {
        exitConfirm := true
        ShowMessage("⚠ Press X or F3 again to close the macro ⚠")
        SetTimer ResetConfirm, -2450
        return
    }
    totalTime := 450
    interval  := 15
    steps     := totalTime // interval
    Loop steps
    {
        remaining := totalTime - A_Index * interval
        ToolTip "✗⸝⸝Closing in " . Format("{:.2f}", remaining / 1000) . "s...⸝⸝✗"
        Sleep interval
    }
    ToolTip "✞︎ Goodbye, my love. ✞︎"
    Sleep 950
    ExitApp
}

ResetConfirm()
{
    global exitConfirm
    exitConfirm := false
}

; -------------------------
; AUTO UPDATE
; -------------------------
CheckForUpdates()
{
    global currentVersion, versionURL, scriptURL, settingsFile

    remoteVersion := ""
    try
    {
        tempVersionFile := A_ScriptDir "\_update_version_check.tmp"
        Download versionURL, tempVersionFile
        remoteVersion := Trim(FileRead(tempVersionFile))
        FileDelete tempVersionFile
    }
    catch as err
    {
        return
    }

    if InStr(versionURL, "YOURUSERNAME")
        return

    if (remoteVersion = "" || remoteVersion = currentVersion)
        return

    response := MsgBox(
        "♡ A new version of Lazy Garden Macro is available! ♡`n`n"
        . "Your version:   " . currentVersion . "`n"
        . "New version:    " . remoteVersion . "`n`n"
        . "Would you like to update now?`n"
        . "(Your settings will be saved and kept.)",
        "Lazy Garden Macro — Update Available",
        "YesNo Icon?"
    )

    if (response != "Yes")
        return

    SaveSettings()
    ShowMessage("⬇ Downloading update... ⚠")

    tempScript := A_ScriptDir "\_update_new.ahk"
    try
    {
        Download scriptURL, tempScript
    }
    catch as err
    {
        MsgBox "Download failed. Please update manually.`n`n" err.Message
        return
    }

    currentScript := A_ScriptFullPath
    try
    {
        FileDelete currentScript
        FileMove tempScript, currentScript
    }
    catch as err
    {
        MsgBox "Could not replace script file. Try running as administrator.`n`n" err.Message
        FileDelete tempScript
        return
    }

    ShowMessage("✔ Updated to v" . remoteVersion . "! Restarting...")
    Sleep 800
    Run currentScript
    ExitApp
}

; -------------------------
; BUILD & START
; -------------------------
RegisterHotkeys()
BuildMainWindow()
BuildHelpGui()
BuildSettingsGui()
CheckForUpdates()

ShowMessage("♡⸝⸝Delay: " . sleepValues[sleepIndex] . " ms⸝⸝♡")

; -------------------------
; FIXED HOTKEYS
; -------------------------
*F1::ToggleHelp()
*F9::OpenSettings()
*F2::TogglePause()
*F3::ConfirmExit()
