#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent

; -------------------------
; VERSION & UPDATE
; -------------------------
global currentVersion  := "1.0"
global versionURL      := "https://raw.githubusercontent.com/YOURUSERNAME/YOURREPO/main/version.txt"
global scriptURL       := "https://raw.githubusercontent.com/YOURUSERNAME/YOURREPO/main/LazyGardenMacro.ahk"

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

; Spam Preset 1 (primary)
global holdKey         := "RButton"
global spamKey         := "Right"
global holdDuration    := 0
global preset1Active   := true

; Spam Preset 2
global holdKey2        := "LButton"
global spamKey2        := "Left"
global holdDuration2   := 0
global preset2Active   := false

; Preset switch keybind
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
global wiggleHoldKey   := "XButton1"
global wiggleKeyA      := "a"
global wiggleKeyB      := "d"
global wiggleHoldA     := 55
global wiggleHoldB     := 55
global wiggleDelay     := 9

; Colors (hex strings without #)
global colorMain       := "1a1a2e"
global colorSettings   := "16213e"
global colorHelp       := "1a1a2e"
global colorText       := "e0e0e0"

; -------------------------
; APPLY COLOR TO A GUI
; -------------------------
ApplyGuiColor(guiObj, bgHex)
{
    guiObj.BackColor := bgHex
}

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
    global wiggleHoldKey, restartKey, presetSwitchKey, preset2AddKey

    try
        HotKey "*" . holdKey, SpamLoop1
    catch as err
        MsgBox "Could not register Preset 1 Hold Key: [" . holdKey . "]"

    if (holdKey2 != "" && holdKey2 != holdKey)
    {
        try
            HotKey "*" . holdKey2, SpamLoop2
        catch as err
        {
        }
    }

    if (speedKey != "")
    {
        try
            HotKey "*" . speedKey, ChangeSpeed
        catch as err
        {
        }
    }

    if (speedKey2 != "" && speedKey2 != speedKey)
    {
        try
            HotKey "*" . speedKey2, ChangeSpeed
        catch as err
        {
        }
    }

    if (wiggleHoldKey != "" && wiggleHoldKey != holdKey && wiggleHoldKey != holdKey2)
    {
        try
            HotKey "*" . wiggleHoldKey, WiggleLoop
        catch as err
        {
        }
    }

    if (restartKey != "")
    {
        try
            HotKey restartKey, DoRestart
        catch as err
        {
        }
    }

    if (presetSwitchKey != "")
    {
        try
            HotKey presetSwitchKey, SwitchPreset
        catch as err
        {
        }
    }

    if (preset2AddKey != "" && preset2AddKey != presetSwitchKey)
    {
        try
            HotKey preset2AddKey, ToggleBothPresets
        catch as err
        {
        }
    }

    UpdatePresetHotkeyStates()
}

UnregisterHotkeys()
{
    global holdKey, holdKey2, speedKey, speedKey2
    global wiggleHoldKey, restartKey, presetSwitchKey, preset2AddKey

    try
        HotKey "*" . holdKey, SpamLoop1, "Off"
    catch as err
    {
    }

    if (holdKey2 != "" && holdKey2 != holdKey)
    {
        try
            HotKey "*" . holdKey2, SpamLoop2, "Off"
        catch as err
        {
        }
    }

    if (speedKey != "")
    {
        try
            HotKey "*" . speedKey, ChangeSpeed, "Off"
        catch as err
        {
        }
    }

    if (speedKey2 != "" && speedKey2 != speedKey)
    {
        try
            HotKey "*" . speedKey2, ChangeSpeed, "Off"
        catch as err
        {
        }
    }

    if (wiggleHoldKey != "")
    {
        try
            HotKey "*" . wiggleHoldKey, WiggleLoop, "Off"
        catch as err
        {
        }
    }

    if (restartKey != "")
    {
        try
            HotKey restartKey, DoRestart, "Off"
        catch as err
        {
        }
    }

    if (presetSwitchKey != "")
    {
        try
            HotKey presetSwitchKey, SwitchPreset, "Off"
        catch as err
        {
        }
    }

    if (preset2AddKey != "" && preset2AddKey != presetSwitchKey)
    {
        try
            HotKey preset2AddKey, ToggleBothPresets, "Off"
        catch as err
        {
        }
    }
}

ReenableHotkeys()
{
    global holdKey, holdKey2, speedKey, speedKey2
    global wiggleHoldKey, restartKey, presetSwitchKey, preset2AddKey

    try
        HotKey "*" . holdKey, SpamLoop1, "On"
    catch as err
    {
    }

    if (holdKey2 != "" && holdKey2 != holdKey)
    {
        try
            HotKey "*" . holdKey2, SpamLoop2, "On"
        catch as err
        {
        }
    }

    if (speedKey != "")
    {
        try
            HotKey "*" . speedKey, ChangeSpeed, "On"
        catch as err
        {
        }
    }

    if (speedKey2 != "" && speedKey2 != speedKey)
    {
        try
            HotKey "*" . speedKey2, ChangeSpeed, "On"
        catch as err
        {
        }
    }

    if (wiggleHoldKey != "")
    {
        try
            HotKey "*" . wiggleHoldKey, WiggleLoop, "On"
        catch as err
        {
        }
    }

    if (restartKey != "")
    {
        try
            HotKey restartKey, DoRestart, "On"
        catch as err
        {
        }
    }

    if (presetSwitchKey != "")
    {
        try
            HotKey presetSwitchKey, SwitchPreset, "On"
        catch as err
        {
        }
    }

    if (preset2AddKey != "" && preset2AddKey != presetSwitchKey)
    {
        try
            HotKey preset2AddKey, ToggleBothPresets, "On"
        catch as err
        {
        }
    }

    UpdatePresetHotkeyStates()
}

UpdatePresetHotkeyStates()
{
    global holdKey, holdKey2, preset1Active, preset2Active, bothActive

    state1 := (preset1Active || bothActive) ? "On" : "Off"
    try
        HotKey "*" . holdKey, SpamLoop1, state1
    catch as err
    {
    }

    if (holdKey2 != "" && holdKey2 != holdKey)
    {
        state2 := (preset2Active || bothActive) ? "On" : "Off"
        try
            HotKey "*" . holdKey2, SpamLoop2, state2
        catch as err
        {
        }
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
global statusLabel  := 0
global delayLabel   := 0
global presetLabel  := 0

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
    global presetSwitchKey, preset2AddKey
    spd1  := (speedKey       != "") ? speedKey       : "(none)"
    spd2  := (speedKey2      != "") ? speedKey2      : "(none)"
    wHold := (wiggleHoldKey  != "") ? wiggleHoldKey  : "(none)"
    rKey  := (restartKey     != "") ? restartKey     : "(none)"
    swKey := (presetSwitchKey != "") ? presetSwitchKey : "(none)"
    btKey := (preset2AddKey  != "") ? preset2AddKey  : "(none)"
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
        . "F9  → Settings & Keybinds`n"
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

BuildSettingsGui()
{
    global holdKey, spamKey, holdDuration
    global holdKey2, spamKey2, holdDuration2
    global presetSwitchKey, preset2AddKey
    global speedKey, speedKey2, restartKey, soundVolume, showHelpOnStart
    global wiggleHoldKey, wiggleKeyA, wiggleKeyB, wiggleHoldA, wiggleHoldB, wiggleDelay
    global colorMain, colorSettings, colorHelp
    global settingsGui, settingsVisible
    global sHoldEdit, sSpamEdit, sHoldDurEdit
    global sHoldEdit2, sSpamEdit2, sHoldDurEdit2
    global sPresetSwitchEdit, sPreset2AddEdit
    global sSpeed1Edit, sSpeed2Edit, sRestartEdit
    global sVolSlider, sVolLabel, sHelpCheck
    global sWiggleHoldEdit, sWiggleKeyAEdit, sWiggleKeyBEdit
    global sWiggleHoldAEdit, sWiggleHoldBEdit, sWiggleDelayEdit
    global sColorMainEdit, sColorSettingsEdit, sColorHelpEdit

    ; Get screen height so we can cap the settings window
    screenH := SysGet(1)   ; SM_CYSCREEN
    maxH    := screenH - 80

    settingsGui := Gui("+AlwaysOnTop", "Lazy Garden — Settings & Keybinds")
    settingsGui.SetFont("s9")
    settingsGui.BackColor := colorSettings
    settingsGui.OnEvent("Close", (*) => (settingsGui.Hide(), settingsVisible := false))

    w := 420   ; content width

    settingsGui.Add("Text", "w" w " Center cWhite", "⁺‧₊˚ SETTINGS & KEYBINDS ˚₊‧⁺")
    settingsGui.Add("Text", "w" w " cWhite", "")

    ; ---- PRESET 1 ----
    settingsGui.Add("Text", "w" w " Center cWhite", "— SPAM PRESET 1 —")
    settingsGui.Add("Text", "w" w " y+4 cWhite", "Hold Key:")
    sHoldEdit := settingsGui.Add("Edit", "w" w, holdKey)
    settingsGui.Add("Text", "w" w " y+4 cWhite", "Spam Key:")
    sSpamEdit := settingsGui.Add("Edit", "w" w, spamKey)
    settingsGui.Add("Text", "w" w " y+4 cWhite", "Hold Duration (ms):")
    sHoldDurEdit := settingsGui.Add("Edit", "w80", holdDuration)

    ; ---- PRESET 2 ----
    settingsGui.Add("Text", "w" w " y+10 Center cWhite", "— SPAM PRESET 2 —")
    settingsGui.Add("Text", "w" w " y+4 cWhite", "Hold Key:")
    sHoldEdit2 := settingsGui.Add("Edit", "w" w, holdKey2)
    settingsGui.Add("Text", "w" w " y+4 cWhite", "Spam Key:")
    sSpamEdit2 := settingsGui.Add("Edit", "w" w, spamKey2)
    settingsGui.Add("Text", "w" w " y+4 cWhite", "Hold Duration (ms):")
    sHoldDurEdit2 := settingsGui.Add("Edit", "w80", holdDuration2)

    ; ---- PRESET KEYS ----
    settingsGui.Add("Text", "w" w " y+10 Center cWhite", "— PRESET KEYBINDS —")
    settingsGui.Add("Text", "w" w " y+4 cWhite", "Switch Preset Key:")
    sPresetSwitchEdit := settingsGui.Add("Edit", "w" w, presetSwitchKey)
    settingsGui.Add("Text", "w" w " y+4 cWhite", "Both Active Key:")
    sPreset2AddEdit := settingsGui.Add("Edit", "w" w, preset2AddKey)

    ; ---- OTHER KEYS ----
    settingsGui.Add("Text", "w" w " y+10 Center cWhite", "— OTHER KEYS —")
    settingsGui.Add("Text", "w" w " y+4 cWhite", "Speed Cycle Key 1:  (blank = disabled)")
    sSpeed1Edit := settingsGui.Add("Edit", "w" w, speedKey)
    settingsGui.Add("Text", "w" w " y+4 cWhite", "Speed Cycle Key 2:  (blank = disabled)")
    sSpeed2Edit := settingsGui.Add("Edit", "w" w, speedKey2)
    settingsGui.Add("Text", "w" w " y+4 cWhite", "Save & Restart Key:  (blank = disabled)")
    sRestartEdit := settingsGui.Add("Edit", "w" w, restartKey)

    ; ---- WIGGLE ----
    settingsGui.Add("Text", "w" w " y+10 Center cWhite", "— WIGGLE —")
    settingsGui.Add("Text", "w" w " y+4 cWhite", "Wiggle Hold Key:")
    sWiggleHoldEdit := settingsGui.Add("Edit", "w" w, wiggleHoldKey)
    settingsGui.Add("Text", "w" w " y+4 cWhite", "Key A  /  Key B:")
    sWiggleKeyAEdit := settingsGui.Add("Edit", "w80", wiggleKeyA)
    sWiggleKeyBEdit := settingsGui.Add("Edit", "x+8 w80", wiggleKeyB)
    settingsGui.Add("Text", "w" w " y+4 cWhite", "Key A Hold (ms)  /  Key B Hold (ms):")
    sWiggleHoldAEdit := settingsGui.Add("Edit", "w80", wiggleHoldA)
    sWiggleHoldBEdit := settingsGui.Add("Edit", "x+8 w80", wiggleHoldB)
    settingsGui.Add("Text", "w" w " y+4 cWhite", "Delay Between Presses (ms):")
    sWiggleDelayEdit := settingsGui.Add("Edit", "w80", wiggleDelay)

    ; ---- SOUND & MISC ----
    settingsGui.Add("Text", "w" w " y+10 Center cWhite", "— SOUND & MISC —")
    settingsGui.Add("Text", "w" w " y+4 cWhite", "Sound Volume:  (0 = mute, 100 = full)")
    sVolLabel  := settingsGui.Add("Text", "w40 cWhite", soundVolume . "%")
    sVolSlider := settingsGui.Add("Slider", "x+8 w" (w-50) " Range0-100 TickInterval10 AltSubmit", soundVolume)
    sVolSlider.OnEvent("Change", OnVolSliderChange)
    settingsGui.Add("Text", "w" w " y+6", "")
    sHelpCheck := settingsGui.Add("Checkbox", "w" w " cWhite" . (showHelpOnStart ? " Checked" : ""), "Show help guide on startup")

    ; ---- COLORS ----
    settingsGui.Add("Text", "w" w " y+10 Center cWhite", "— BACKGROUND COLORS (hex, no #) —")
    settingsGui.Add("Text", "w" w " y+4 cWhite", "Main window color:")
    sColorMainEdit := settingsGui.Add("Edit", "w120", colorMain)
    settingsGui.Add("Text", "w" w " y+4 cWhite", "Settings window color:")
    sColorSettingsEdit := settingsGui.Add("Edit", "w120", colorSettings)
    settingsGui.Add("Text", "w" w " y+4 cWhite", "Help window color:")
    sColorHelpEdit := settingsGui.Add("Edit", "w120", colorHelp)
    settingsGui.Add("Text", "w" w " y+4 cWhite", "  Examples: ff0000 = red   1a1a2e = dark navy   ffffff = white")

    ; ---- BUTTONS ----
    settingsGui.Add("Text", "w" w " y+10", "")
    btnTest   := settingsGui.Add("Button", "w110", "▶ Test Sound")
    btnSave   := settingsGui.Add("Button", "x+8 w150", "✔ Save && Restart")
    btnCancel := settingsGui.Add("Button", "x+8 w110", "✘ Cancel")

    btnTest.OnEvent("Click",   (*) => PlaySound(A_ScriptDir "\pop.wav"))
    btnCancel.OnEvent("Click", (*) => (settingsGui.Hide(), settingsVisible := false))
    btnSave.OnEvent("Click",   (*) => ApplySettings(
        sHoldEdit.Value,         sSpamEdit.Value,         sHoldDurEdit.Value,
        sHoldEdit2.Value,        sSpamEdit2.Value,        sHoldDurEdit2.Value,
        sPresetSwitchEdit.Value, sPreset2AddEdit.Value,
        sSpeed1Edit.Value,       sSpeed2Edit.Value,       sRestartEdit.Value,
        sVolSlider.Value,        sHelpCheck.Value,
        sWiggleHoldEdit.Value,   sWiggleKeyAEdit.Value,   sWiggleKeyBEdit.Value,
        sWiggleHoldAEdit.Value,  sWiggleHoldBEdit.Value,  sWiggleDelayEdit.Value,
        sColorMainEdit.Value,    sColorSettingsEdit.Value, sColorHelpEdit.Value
    ))

    ; Show and then resize height if taller than screen
    settingsGui.Show("AutoSize")
    settingsGui.GetPos(,, &sW, &sH)
    if (sH > maxH)
        settingsGui.Move(,, sW, maxH)
    settingsGui.Hide()
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

ApplySettings(nHold, nSpam, nHoldDur, nHold2, nSpam2, nHoldDur2,
              nSwitchKey, nBothKey,
              nSpeed1, nSpeed2, nRestartKey,
              nVolume, nHelpOnStart,
              nWiggleHold, nWigKeyA, nWigKeyB, nWigHoldA, nWigHoldB, nWigDelay,
              nColorMain, nColorSettings, nColorHelp)
{
    global holdKey, spamKey, holdDuration
    global holdKey2, spamKey2, holdDuration2
    global presetSwitchKey, preset2AddKey
    global speedKey, speedKey2, restartKey, soundVolume, showHelpOnStart
    global wiggleHoldKey, wiggleKeyA, wiggleKeyB, wiggleHoldA, wiggleHoldB, wiggleDelay
    global colorMain, colorSettings, colorHelp

    UnregisterHotkeys()

    holdKey         := Trim(nHold)
    spamKey         := Trim(nSpam)
    holdDuration    := Integer(nHoldDur)
    holdKey2        := Trim(nHold2)
    spamKey2        := Trim(nSpam2)
    holdDuration2   := Integer(nHoldDur2)
    presetSwitchKey := Trim(nSwitchKey)
    preset2AddKey   := Trim(nBothKey)
    speedKey        := Trim(nSpeed1)
    speedKey2       := Trim(nSpeed2)
    restartKey      := Trim(nRestartKey)
    soundVolume     := Integer(nVolume)
    showHelpOnStart := (nHelpOnStart = 1)
    wiggleHoldKey   := Trim(nWiggleHold)
    wiggleKeyA      := Trim(nWigKeyA)
    wiggleKeyB      := Trim(nWigKeyB)
    wiggleHoldA     := Integer(nWigHoldA)
    wiggleHoldB     := Integer(nWigHoldB)
    wiggleDelay     := Integer(nWigDelay)
    colorMain       := Trim(nColorMain)
    colorSettings   := Trim(nColorSettings)
    colorHelp       := Trim(nColorHelp)

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
    global sHoldEdit, sSpamEdit, sHoldDurEdit
    global sHoldEdit2, sSpamEdit2, sHoldDurEdit2
    global sPresetSwitchEdit, sPreset2AddEdit
    global sSpeed1Edit, sSpeed2Edit, sRestartEdit
    global sVolSlider, sHelpCheck
    global sWiggleHoldEdit, sWiggleKeyAEdit, sWiggleKeyBEdit
    global sWiggleHoldAEdit, sWiggleHoldBEdit, sWiggleDelayEdit
    global sColorMainEdit, sColorSettingsEdit, sColorHelpEdit

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

    ; Try to fetch the remote version number
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
        ; No internet or URL not set up yet — silently skip
        return
    }

    ; Strip placeholder check — if URL still has YOURUSERNAME skip silently
    if InStr(versionURL, "YOURUSERNAME")
        return

    if (remoteVersion = "" || remoteVersion = currentVersion)
        return

    ; New version found — ask user
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

    ; Save current settings first so they survive the update
    SaveSettings()
    ShowMessage("⬇ Downloading update... ⚠")

    ; Download new script to a temp file then replace
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

    ; Replace current script with new one
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
