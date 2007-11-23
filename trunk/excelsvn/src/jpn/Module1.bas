Attribute VB_Name = "Module1"
' Copyright (C) 2005 Osamu OKANO <osamu@dkiroku.com>
'     All rights reserved.
'     This is free software with ABSOLUTELY NO WARRANTY.
'
' You can redistribute it and/or modify it under the terms of
' the GNU General Public License version 2.
'
' Copyright (C) 2007 Koki Yamamoto
'     All rights of modified contents from original one are reserved
'     This is free software with ABSOLUTELY NO WARRANTY.
'
' You can redistribute it and/or modify it under the terms of
' the GNU General Public License version 2.

Option Explicit

Private Function TSVN(ByVal command As String, ByVal DocFileFullName As String) As Boolean
  Dim strTSVN As String
  Dim strCOM As String
  Dim strPATH As String
  strTSVN = """" & CreateObject("WScript.Shell").RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\TortoiseSVN\ProcPath") & """"
  strCOM = "/command:" & command & " /notempfile "

  If Len(DocFileFullName) = 0 Then
    strPATH = "/path:" & """" & ActiveWorkbook.FullName & """"
  Else
    strPATH = "/path:" & """" & DocFileFullName & """"
  End If

  CreateObject("WScript.Shell").Run strTSVN & strCOM & strPATH, , True
  TSVN = True ' Return True
End Function

Sub TSVNUPDATE()
  Dim msgActiveDocMod As String ' Message
  Dim FilePath As String ' Backup of active document full path name

  msgActiveDocMod = "更新できません。" & "'" & ActiveWorkbook.Name & "'" & "は変更されています。"

  ' Test the active document file status
  If ActiveDocFileExistWithMsg() = False Then
    Exit Sub
  End If

  ' Test the folder is under version control
  If IsFileUnderSVNControlWithMsg = False Then
    Exit Sub
  End If

  If ActiveWorkbook.Saved = False Then
  ' Active Workbook is modified but not saved yet.
    MsgBox (msgActiveDocMod)
    Exit Sub
  End If

  FilePath = ActiveWorkbook.FullName
  ActiveWorkbook.Close

  If TSVN("update", FilePath) = True Then
    Workbooks.Open Filename:=FilePath
  End If

End Sub

Sub TSVNCI()
  Dim msgActiveDocFileReadOnly As String ' Message
  Dim msgSaveModDoc As String            ' Message
  Dim ans As Integer     ' Return value of message box
  Dim FilePath As String ' Backup of active document full path name

  msgActiveDocFileReadOnly = "コミットできません。" & "'" & ActiveWorkbook.Name & "'" & "は変更されていますが、ファイル属性が読み取り専用となっています。"
  msgSaveModDoc = "コミット時に、ファイルをいったん閉じて再度開きます。" & "'" & ActiveWorkbook.Name & "'" & "への変更を保存しますか？"

  ' Test the active document file status
  If ActiveDocFileExistWithMsg() = False Then
    Exit Sub
  End If

  ' Test the folder is under version control
  If IsFolderUnderSVNControlWithMsg = False Then
    Exit Sub
  End If

  If ActiveWorkbook.Saved = False Then
  ' Active Workbook is modified but not saved yet.
    ' Test the active document file attributes
    If IsActiveDocFileReadOnly = True Then
        MsgBox (msgActiveDocFileReadOnly)
        Exit Sub
    End If
    
    ans = MsgBox(msgSaveModDoc, vbYesNo)
    If ans = vbYes Then
      ActiveWorkbook.Save
    End If
  End If

  FilePath = ActiveWorkbook.FullName
  ActiveWorkbook.Close

  If TSVN("commit", FilePath) = True Then
    Workbooks.Open Filename:=FilePath
  End If
End Sub

Sub TSVNDIFF()
  ' Test the active document file status
  If ActiveDocFileExistWithMsg() = False Then
    Exit Sub
  End If

  ' Test the file is under version control
  If IsFileUnderSVNControlWithMsg = False Then
    Exit Sub
  End If

  TSVN "diff", ""

End Sub

Sub TSVNRB()
  TSVN "repobrowser", ""
End Sub


Sub TSVNLOG()
  ' Test the active document file status
  If ActiveDocFileExistWithMsg() = False Then
    Exit Sub
  End If

 ' Test the file is under version control
  If IsFileUnderSVNControlWithMsg = False Then
    Exit Sub
  End If

  TSVN "log", ""
End Sub

Sub TSVNLOCK()
  Dim ans As Integer     ' Return value of MessageBox
  Dim FilePath As String ' Backup of active document full path name
  Dim msgActiveDocFileReadOnly As String ' Message
  Dim msgSaveModDoc As String            ' Message
  
  msgActiveDocFileReadOnly = "ロックを取得できません。" & "'" & ActiveWorkbook.Name & "'" & "は変更されていますが、ファイル属性が読み取り専用となっています。"
  msgSaveModDoc = "ロックを取得時に、ファイルをいったん閉じて再度開きます。" & "'" & ActiveWorkbook.Name & "'" & "への変更を保存しますか？"

  ' Test the active document file status
  If ActiveDocFileExistWithMsg() = False Then
    Exit Sub
  End If

  ' Test the file is under version control
  If IsFileUnderSVNControlWithMsg = False Then
    Exit Sub
  End If

  ' Backup file name before save the active document
  FilePath = ActiveWorkbook.FullName

  If ActiveWorkbook.Saved = False Then
  ' Active Workbook is modified but not saved yet.
    ' Test the active document file attributes
    If IsActiveDocFileReadOnly = True Then
      MsgBox (msgActiveDocFileReadOnly)
      Exit Sub
    End If
    
    ans = MsgBox(msgSaveModDoc, vbYesNo)
    If ans = vbYes Then
      ActiveWorkbook.Save
    End If
  End If

  ' Close the file and reopen after lock it, because the following reasons
  '  * The file attribute of read only / read write is changed after lock the file.
  '  * The file can be updated when the file in repository is newer than the working copy.
  '  * If the word open the file and svn failes to update working copy, svn require clean-up.
  ActiveWorkbook.Close
  
  If TSVN("lock", FilePath) = True Then
    Workbooks.Open Filename:=FilePath
  End If
End Sub

Sub TSVNUNLOCK()
  Dim ans As Integer     ' Return value of MessageBox
  Dim FilePath As String ' Backup of active document full path name
  Dim msgActiveDocFileReadOnly As String ' Message
  Dim msgActiveDocMod As String          ' Message

  msgActiveDocFileReadOnly = "ロックを開放できません。" & "'" & ActiveWorkbook.Name & "'" & "は変更されていますが、ファイル属性が読み取り専用となっています。"
  msgActiveDocMod = "'" & ActiveWorkbook.Name & "'" & "は変更されています。ロックの開放では変更内容をリポジトリへ反映することはできません。続行しますか?"

  ' Test the active document file status
  If ActiveDocFileExistWithMsg() = False Then
    Exit Sub
  End If

  ' Test the file is under version control
  If IsFileUnderSVNControlWithMsg = False Then
    Exit Sub
  End If

  ' Backup file name before save the active document
  FilePath = ActiveWorkbook.FullName

  If ActiveWorkbook.Saved = False Then
  ' Active Workbook is modified but not saved yet.
    If IsActiveDocFileReadOnly = True Then
    ' Test the active document file attributes
      MsgBox (msgActiveDocFileReadOnly)
      Exit Sub
    End If

    ans = MsgBox(msgActiveDocMod, vbYesNo)

    If ans = vbNo Then
      Exit Sub ' Exit subroutine without locking
    Else
      ActiveWorkbook.Save
    End If
  End If ' If ActiveWorkbook.Saved = False Then

  ' Close the file and reopen after unlock it, because the following reason
  '  * The file attribute of read only / read write is changed after unlock the file.
  ActiveWorkbook.Close

  If TSVN("unlock", FilePath) = True Then
    Workbooks.Open Filename:=FilePath
  End If

End Sub

' :Function:Test whether the active document is saved as a file or not.
' :Return value:True=The file exists., False=No file exists.
Function ActiveDocFileExist() As Boolean
  If ActiveWorkbook.Path = "" Then
    ' Judge that no file exists when no path exists.
    ActiveDocFileExist = False
  Else
    ActiveDocFileExist = True
  End If
End Function

' :Function:Test whether the active document is saved as a file or not.
'           And this displays error message if the file does't exist.
' :Return value:True=The file exists., False=No file exists.
Function ActiveDocFileExistWithMsg() As Boolean
  Dim msgActiveDocFileNotExist As String
  msgActiveDocFileNotExist = "'" & ActiveWorkbook.Name & "'" & "のファイルがありません。文書をファイルに保存してからこの操作を行ってください。"

  If ActiveDocFileExist Then
    ActiveDocFileExistWithMsg = True
  Else
    MsgBox (msgActiveDocFileNotExist)
    ActiveDocFileExistWithMsg = False
  End If
End Function

' :Function: Test whether the active document file is read only or not.
' :Retrun value: True = Read Only, False = Not Read Only
Function IsActiveDocFileReadOnly() As Boolean
  Dim glFSO As Object  ' File System Object
  Set glFSO = CreateObject("Scripting.FileSystemObject")

  If glFSO.GetFile(ActiveWorkbook.FullName).Attributes And 1 Then
    IsActiveDocFileReadOnly = True  ' Return True
  Else
    IsActiveDocFileReadOnly = False ' Return False
  End If
End Function

' :Function: Test whether the file exist in the file under SVN version control.
' :Return value: True=Under version control, False=Not under version control
Function IsFolderUnderSVNControl() As Boolean
  Dim strDotSvn As String ' SVN control folder ".svn"
  strDotSvn = ActiveWorkbook.Path & "\.svn"

  If CreateObject("Scripting.FileSystemObject").FolderExists(strDotSvn) Then
    IsFolderUnderSVNControl = True  ' Return True
  Else
    IsFolderUnderSVNControl = False ' Return False
  End If
End Function

' :Function: Test whether the file exist in the folder under SVN version control.
'            And this displays error message if the folder isn't under version control.
' :Return value: True=Under version control, False=Not under version control
Function IsFolderUnderSVNControlWithMsg() As Boolean
  Dim msgNotUnderCtrl As String ' Message
  msgNotUnderCtrl = "'" & ActiveWorkbook.Name & "'" & "はバージョンコントロール下のフォルダにありません。"
  
  If IsFolderUnderSVNControl Then
    IsFolderUnderSVNControlWithMsg = True 'Return True
  Else
    MsgBox (msgNotUnderCtrl)
    IsFolderUnderSVNControlWithMsg = False 'Return False
  End If
End Function

Function IsFileUnderSVNControl() As Boolean
  Dim strTextBase As String ' Base file full path name
  strTextBase = ActiveWorkbook.Path & "\.svn\text-base\" & ActiveWorkbook.Name & ".svn-base"

  If CreateObject("Scripting.FileSystemObject").FileExists(strTextBase) Then
    IsFileUnderSVNControl = True  ' Return True
  Else
    IsFileUnderSVNControl = False ' Return False
  End If
End Function

Function IsFileUnderSVNControlWithMsg() As Boolean
  Dim msgNotUnderCtrl As String ' Message
  msgNotUnderCtrl = "'" & ActiveWorkbook.Name & "'" & "はバージョンコントロールされていません。"

  If IsFileUnderSVNControl Then
    IsFileUnderSVNControlWithMsg = True  ' Return True
  Else
    MsgBox (msgNotUnderCtrl)
    IsFileUnderSVNControlWithMsg = False ' Return False
  End If
End Function



