VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "ThisDocument"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = True
'------------------- Copy & paste from here to the ThisDocument module of wordsvn.dot --------------------
' $Rev: 504 $
' Copyright (C) 2005 Osamu OKANO <osamu@dkiroku.com>
'     All rights reserved.
'     This is free software with ABSOLUTELY NO WARRANTY.
'
' You can redistribute it and/or modify it under the terms of
' the GNU General Public License version 2.
'
' Copyright (C) 2005 Kazuyuki NAGAMORI <nagamori@nekoconeko.com>
'     All rights reserved.
'     This is free software with ABSOLUTELY NO WARRANTY.
'
' You can redistribute it and/or modify it under the terms of
' the GNU General Public License version 2.
'
' :$Date:: 2009-07-04 19:24:59 +0900#$
' :Author: Koki Yamamoto <kokiya@gmail.com>
' :Module Name: ThisDocument
' :Description: wordsvn specific module

Option Explicit

Dim MsOfficeSvnAppEvent As New AppEvent


' :Function: Install Subversion menu and command bar
' :Remarks:  This function is called when MS-Word starts
Sub AutoExec()
  'Dim bNeedInstToolBar As Boolean

  'Msgbox "AutoExec Starts."
  ' Assume that tool bar must be installed.
  'bNeedInstToolBar = True

  ' Build the SVN Menu
  'InstallSvnMenu

  ' Install tool bar once when this add-in is loaded in Office 97 first time.
  ' Because tool bar's position is not saved if reinstall it.
  ' NOTE: I'm not sure wether it happens to only Office 97 or not.
  'If GetAppMajorVersionNum < gOffice2000MajorVer Then
  '  If GetIniToolBarInstStat = gIniValToolBarInstalled Then
  '    bNeedInstToolBar = False
  '  End If
  'End If

  ' Build the SVN Tool bar
  'If bNeedInstToolBar Then
    'InstallSvnToolBar
  '  WriteIniToolBarInstStat gIniValToolBarInstalled
  'End If

  RegisterShortcutKey

  'True:Test it
  If GetAutoLock Then
    'MsgBox "RegisterEventHandler Called."
    MsOfficeSvnAppEvent.RegisterEventHandler
  End If
End Sub


' :Function: Uninstall Subversion menu and command bar
' :Remarks: This function is called when MS-Word exits
Sub AutoExit()
  'DeleteSvnMenu

  ' Don't delete the tool bar to keep the tool bar position in the case of Office 97
  'If gOffice2000MajorVer <= GetAppMajorVersionNum Then
  '  DeleteSvnToolBar
  'End If
End Sub


