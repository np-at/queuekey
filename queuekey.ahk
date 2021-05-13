SetWorkingDir %A_ScriptDir%
ScriptNameFixed := SubStr(A_ScriptName, 1, StrLen(A_ScriptName) - 4)
SaveFileLoc .= Format("{1:s}\{2:s}\{3:s}", A_AppData, ScriptNameFixed,"queuekey-savedata.txt")
CSV_Load(SaveFileLoc, ilist, ",")
Gui, Add, Edit, vInputText x12 y9 w120 r1
Gui, Add, ListView, -ReadOnly -LV0x10 x12 y39 w120 h250 vilist, InputSelection
CSV_LVLoad(ilist, 1, 12, 39, 120, 250, InputSelection, 0, 1)
Gui, Add, Button, x142 y9 w100 h20 gAdItem, Add
Gui, Add, Button, x142 y39 w100 h20 gDelItem, Delete
Gui, Add, Checkbox, x154 y129 w100 vhkeystate ghkeytoggle Checked0, Check to turn on Hotkey
Gui, Add, Text, w100, Choose your hotkey by clicking on the box and pressing the desired hotkey `:
Gui, Add, Hotkey, vChosenHotKey ghkeychange, q
Gui, Show, x127 y40 h379 w479 Autosize, Queuekey
hkey = q
ChosenHotKey = q
Return
#If (hkeystate = 1)
  AdItem:
  GuiControlGet, InputText
  LV_Add(, InputText)
return
DelItem:
  FocusedRow := LV_GetNext(, F)
  LV_Delete(FocusedRow)
return
sinput:
  FocusedRow := LV_GetNext(, F)
  LV_GetText(lineread, FocusedRow, 1)
  in_array := StrSplit(lineread, ",")
  Loop % in_array.MaxIndex()
  {
    current_send := in_array[A_Index]
    SendRaw %current_send%
    Sleep, 1000
  }
return
hkeychange:
  Hotkey, %hkey%, sinput, off
  hkey = %ChosenHotKey%
  Goto, hkeytoggle
return
hkeytoggle:
  GuiControlGet, hkeystate,, hkeystate
  Hotkey, If, (hkeystate = 1)
    Hotkey, $%hkey%, sinput, On
return
CSV_LVLoad(CSV_Identifier, Gui=1, x=10, y=10, w="", h="", header="", Sort=0, AutoAdjustCol=1)
{
  Local Row
  CurrentCSV_TotalRows := %CSV_Identifier%CSV_TotalRows
  CurrentCSV_TotalCols := %CSV_Identifier%CSV_TotalCols
  GuiControl, -Redraw, %CSV_Identifier%
  Sleep, 200
  LV_Delete()
  Loop, %currentcsv_totalrows%
    LV_Add("", "")
  Loop, %currentcsv_totalrows%
  {
    Row := A_Index
    Loop, %currentCSV_TotalCols%
      LV_Modify(Row, "Col" . A_Index, %CSV_Identifier%CSV_Row%Row%_Col%A_Index%)
  }
  If Sort <> 0
    LV_ModifyCol(Sort, "Sort")
  If AutoAdjustCol = 1
    LV_ModifyCol()
  GuiControl, +Redraw, %CSV_Identifier%
}
CSV_Load(FileName, CSV_Identifier="", Delimiter="`,")
{
  Local Row
  Local Col
  temp := %CSV_Identifier%CSVFile
  FileRead, temp, %FileName%
  String = a,b,c`r`nd,e,f,,"g`r`n",h`r`nB,`n"C`nC",D
  e:= """"
  RegExNeedle:= "\n(?=[^" e "]*" e "([^" e "]*" e "[^" e "]*" e ")*([^" e "]*)\z)"
  String := RegExReplace(String, RegExNeedle , "" )
  StringReplace,String, String,`r,@,All
  Loop, Parse, temp, `n, `r
  {
    Col := ReturnDSVArray(A_LoopField, CSV_Identifier . "CSV_Row" . A_Index . "_Col", Delimiter)
    Row := A_Index
  }
  %CSV_Identifier%CSV_TotalRows := Row
  %CSV_Identifier%CSV_TotalCols := Col
  %CSV_Identifier%CSV_Delimiter := Delimiter
  SplitPath, FileName, %CSV_Identifier%CSV_FileName, %CSV_Identifier%CSV_Path
  IfNotInString, FileName, `\
  {
    %CSV_Identifier%CSV_FileName := FileName
    %CSV_Identifier%CSV_Path := A_ScriptDir
  }
  %CSV_Identifier%CSV_FileNamePath := %CSV_Identifier%CSV_Path . "\" . %CSV_Identifier%CSV_FileName
}
CSV_LVSave(FileName, CSV_Identifier, Delimiter=",",OverWrite=1, Gui=1)
{
  Gui, %Gui%:Default
  Gui, ListView, %CSV_Identifier%
  Rows := LV_GetCount()
  Cols := LV_GetCount("Col")
  IfExist,2 %FileName%
    If OverWrite = 0
    Return 0
  FileDelete, %FileName%
  Loop, %Rows%
  {
    FullRow =
    Row := A_Index
    Loop, %Cols%
    {
      LV_GetText(CellData, Row, A_Index)
      FullRow .= Format4CSV(CellData)
      If A_Index <> %Cols%
        FullRow .= Delimiter
    }
    stringreplace, checkforemptyrow, fullrow, %Delimiter%,,all
    If (checkforemptyrow = "")
      Continue
    If Row <> %Rows%
      FullRow .= "`n"
    EntireFile .= FullRow
  }
  FileAppend, %EntireFile%, %FileName%
}
ReturnDSVArray(CurrentDSVLine, ReturnArray="DSVfield", Delimiter=",", Encapsulator="""")
{
  global
  if ((StrLen(Delimiter)!=1)||(StrLen(Encapsulator)!=1))
  {
    return -1
  }
  SetFormat,integer,H
  local d := SubStr(ASC(delimiter)+0,2)
  local e := SubStr(ASC(encapsulator)+0,2)
  SetFormat,integer,D
  local p0 := 1
  local fieldCount := 0
  CurrentDSVLine .= delimiter
  Loop
  {
    Local RegExNeedle := "\" d "(?=(?:[^\" e "]*\" e "[^\" e "]*\" e ")*(?![^\" e "]*\" e "))"
    Local p1 := RegExMatch(CurrentDSVLine,RegExNeedle,tmp,p0)
    fieldCount++
    local field := SubStr(CurrentDSVLine,p0,p1-p0)
    if (SubStr(field,1,1)=encapsulator)
    {
      field := RegExReplace(field,"^\" e "|\" e "$")
      StringReplace,field,field,% encapsulator encapsulator,%encapsulator%, All
    }
    Local _field := ReturnArray A_Index
    %_field% := field
    if (p1=0)
    {
      fieldCount--
      Break
    } Else
    p0 := p1 + 1
  }
return fieldCount
}
Format4CSV(F4C_String)
{
  Reformat:=False
  IfInString, F4C_String,`n
    Reformat:=True
  IfInString, F4C_String,`r
    Reformat:=True
  IfInString, F4C_String,`,
    Reformat:=True
  IfInString, F4C_String, `"
  { Reformat:=True
    StringReplace, F4C_String, F4C_String, `",`"`", All
  }
  If (Reformat)
    F4C_String=`"%F4C_String%`"
Return, F4C_String
}
GuiClose:
  CSV_LVSave(SaveFileLoc, ilist, ",", 1, 1)
ExitApp