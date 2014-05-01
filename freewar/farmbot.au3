#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Res_requestedExecutionLevel=asInvoker
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.6.1
 Author:         Bilbao

 Script Function:
	Freewar-Bot

#ce ----------------------------------------------------------------------------

;~ Include-Sektion
#include <Array.au3>
#include <IE.au3>
#include<WindowsConstants.au3>
#include<EditConstants.au3>
#include <string.au3>
#include <file.au3>

;~ Main
Global $aWege=_ladeWege()
Global $o_FW
_IEErrorNotify(False)
$o_FW= _IEAttach("Freewar.de")
If @error= 7 then _login()
If _IEPropertyGet($o_FW,"locationurl")= "http://welt4.freewar.de/freewar/index.php" Then
	_IEQuit($o_FW)
	_login()
EndIf

Func _login()
	$o_FW = _IECreate()
	_IENavigate($o_FW,"http://welt4.freewar.de/freewar/")
	_IELoadWait($o_FW)
	;WinSetState(WinGetTitle("[active]"),"",@SW_MAXIMIZE)
	$oForm = _IEFormGetObjByName($o_FW,"login_form")
	$oUsername = _IEFormElementGetObjByName($oForm,"name")
	_IEFormElementSetValue($oUsername,"MYUSERNAME")
	$oPass = _IEFormElementGetObjByName($oForm,"password")
	_IEFormElementSetValue($oPass,"MYPASSWORD")
	$login=_IEFormElementGetObjByName ($oForm, "submit")
	_IEAction($login, "click")
	_ieloadwait($o_FW)
	_IELinkClickByText($o_FW,"Hier klicken um Freewar ohne Popup zu starten")
	_ieloadwait($o_FW)
	Sleep(3000)
EndFunc

Func _logout()
	$oFrame = _IEFrameGetObjByName($o_FW, "menuFrame")
	_IELoadWait($oFrame)
	_IELinkClickByText($oFrame, "Logout")
	Sleep(2011)
	$oFrame = _IEFrameGetObjByName($o_FW, "mapFrame")
	_IELoadWait($oFrame)
	_IELinkClickByText($oFrame, "Ja",0,0)
	_IEAction($o_FW,"quit")
Endfunc

#cs ToDO:
- Kampfausgang vor Angriff berechnen
- Wege von Heimat zu allen Shops
- Lager leeren
- Heilen an Heimatort
- gZk nutzen
- Heimzauber nutzen
- Gold ab Wert X auf die Bank bringen
- aktuellen Bankkontostand abrufen und speichern, beim nächsten Einloggen anzeigen.
- Drops im Shop der Onlos verkaufen
- Charakterfähigkeiten prüfen und ausbauen
- GUI für alles :-)
#ce

;~ Listen (Orte, NPCs, Shops, Dropitems etc.)
Func _ladeWege()
	Dim $aReadWege
	dim $string
	if FileExists(@WorkingDir & "\Orte.csv") Then
	 _FileReadToArray(@WorkingDir & "\Orte.csv", $aReadWege) ;Then
;~ 		MsgBox(4096, "Fehler", "Fehler beim Einlesen der Datei in das Array!" & @CRLF & "Fehlercode: " & @error)
;~ 		Exit
;~ 	EndIf
	EndIf
;~ 	_ArrayDisplay($aReadWege)
	dim $aWege[UBound($aReadWege)-2][5]
	for $i=2 to UBound($aReadWege)-1
		$string= $aReadWege[$i]
		$string= StringReplace($string,'"','')
;~ 		MsgBox(0,"",$string)
		$aString= StringSplit($string,";",2)
;~ 	 	_ArrayDisplay($aString,"$aString")
		$aWege[$i-2][0] =$aString[0]		;-	Start
		$aWege[$i-2][1] =$aString[1]		;-	Ziel
		$aWege[$i-2][2] =$aString[2]		;-	Pos Start x/y
		$aWege[$i-2][3] =$aString[3]		;-	Weg
		$aWege[$i-2][4] =$aString[4]		;-	Alternativweg
	Next
	Return $aWege
EndFunc

Func _ListeNPCs()
	$aNPC = StringSplit("Ein Schattenwesen,Blattspinne,Ameisenhügel,Kaklatron,Waldschlurch,Wüstenspinne,Pilzwachtel,Hase,Hyäne,Aasgeier,Wasserschlange,Larvennest,Schattenwiesel,Gelbkatze,Waldratte,Kleines Schaf,Steinpicker-Vogel,Riesenlibelle,Naurofbusch,Klauenratte,Wüstenplankton,Zukuvogel,Blaukamm-Vogel,Wüstenschreck,Lebender Salzhügel,Savannen-Vogel,Silberfuchs,Grabwurm ,Sprungechse,Goldflossenfisch,Sumpfspinne,Steinkäfer,Steinspinne,Wawruz,Wühlratte,Waldvogel,Salzwasservogel,Wüstenmaus,Steppenwolf,~Schneehuhn,Schneekäfer,Staubassel,Trockenwurm,Tempelhüpfer,Feuerwolf,Giftsporenpilz,Kristallfisch,Blumenbeißer,kleiner Laubbär,Langzahnaffe,Goldkrebs,Lianenechse,Erdfisch,Erdschlurch,Aschenvogel,Wurzelwurm,Stachelkäfer,Lablabkaktus,Milchkuh",",")
    Return $aNPC
EndFunc

Func _ListeShops()
	$aShops = StringSplit("X: 77 Y: 101,X: 101 Y: 116,X: 120 Y: 115,X: 79 Y: 110,X: 84 Y: 112,X: 97 Y: 101,X: 90 Y: 115,X: 90 Y: 100",",",2)
	Return $aShops
	; Gobos - X: 77 Y: 101
	; Mento - X:101 Y: 116
	; Lardikia - X: 120 X: 115
	; Plefir - X: 79 Y: 110
	; Loranien - X:84 Y: 112
	; Konlir - X: 97 Y: 101
	; Kerdis - X: 90 Y: 115
EndFunc

;- ToDo: Liste der Heil-Orte
Func _ListeHeilOrte()
	$aHeilOrte = StringSplit("X: 89 Y: 101",",")
	Return $aHeilOrte
EndFunc

Func _ListeDropitems()
	$aItems = StringSplit("Hasenfell,Wakrudpilz,tote Wüstenmaus,Blauer Kristall,Nokulawurzel,Trockenwurmpanzer,Waldschlurchpanzer,Goldflosse,Silberfuchsfell,Staubschleifer-Ei,Salzkristall,Seelenkapsel,Langzahn,Goldkrebspanzer,Nolulawurzel,Kuhkopf",",")
	Return $aItems
EndFunc

Func _ListeHeilItems()
	$aItems = StringSplit("Furgorpilz,Nokulawurzel",",",2)
	Return $aItems
EndFunc

Func _ListeShopItems()
	$aItem = StringSplit("Hasenfell,Trockenwurmpanzer,Waldschlurchpanzer,Goldflosse,Goldkrebspanzer,Silberfuchsfell,Staubschleifer-Ei,Langzahn",",",2)
	Return $aItem
EndFunc

Func _ListeMahaItems()
	Dim $aItem [7][2]
	$aItem0 = StringSplit("Wakrudpilz,tote Wüstenmaus,blauer Kristall,Salzkristall,Seelenkapsel,Kuhkopf,Ölfass",",")
	$aItem1 = StringSplit("77,59,351,193,54,37,245",",")
	For $i = 0 to Ubound($aItem)-1
		$aItem[$i][0] = $aItem0[$i+1]
	Next
	For $i = 0 to Ubound($aItem)-1
		$aItem[$i][1] = $aItem1[$i+1]
	Next
	Return $aItem
EndFunc

;~ Grundlegende Funktionen (Bewegung, Position, Pausen, etc.)
Func _check_laufpause()			;- muss verbessert werden, wenn von Kakti getroffen, Starre etc. einplanen
$oFrame = _IEFrameGetObjByName($o_FW,"mapFrame")
_IELoadWait($oFrame)
$HTMLsource = _IEDocReadHTML($oFrame)
$aPause= _StringBetween($HTMLsource,"align=center>Du kannst in "," Sekunden weiterreisen</DIV>")
If @error Then
;~         MsgBox(0, "check_laufpause", "Suchstring nicht gefunden",20)
        $pause = 1000
        Return $pause
Else
        $pause=$aPause[0]*1000
        Return $pause
EndIf
EndFunc

Func _sPosition() 		;- Position als String
	$oFrame = _IEFrameGetObjByName($o_FW,"mapFrame")
	_IELoadWait($oFrame)
	$HTML = _IEDocReadHTML($oFrame)
	$aPosition = _StringBetween($HTML,'Position ','</p></div>')
	if not IsArray($aPosition) Then $sPosition="X: 0 Y: 0"
	$sPosition=$aPosition[0]
	Return $sPosition
	;MsgBox(48,"Positionsbestimmung", "Die aktuelle Position ist " & $pos[0])
EndFunc

func _aPosition()		;- Position als Array
	$oFrame=_IEFrameGetObjByName($o_FW,"mapFrame")
	_IELoadWait($oFrame)
	$HTML= _IEBodyReadHTML($oFrame)
	$aString= _StringBetween($HTML,"Position X:","</p>")
	$aPos = StringRegExp($aString[0],'([0-9]{2,3})',3)
	Return($aPos)
EndFunc

Func _move($value)
	Select
		Case $value =7
			$oMapFrame=_IEFrameGetObjByName($o_FW,"mapFrame")
			_IELoadWait($oMapFrame)
			$oMapFrame.document.body.innerHTML = $oMapFrame.document.body.innerHTML & '<br><button onclick="javascript:Move(''upleft'')" id="button2">test</button>'
			$oMapFrame.document.getElementById("button2").click
		Case $value =8
			$oMapFrame=_IEFrameGetObjByName($o_FW,"mapFrame")
			_IELoadWait($oMapFrame)
			$oMapFrame.document.body.innerHTML = $oMapFrame.document.body.innerHTML & '<br><button onclick="javascript:Move(''up'')" id="button2">test</button>'
			$oMapFrame.document.getElementById("button2").click
		Case $value =9
			$oMapFrame=_IEFrameGetObjByName($o_FW,"mapFrame")
			_IELoadWait($oMapFrame)
			$oMapFrame.document.body.innerHTML = $oMapFrame.document.body.innerHTML & '<br><button onclick="javascript:Move(''upright'')" id="button2">test</button>'
			$oMapFrame.document.getElementById("button2").click
		Case $value =4
			$oMapFrame=_IEFrameGetObjByName($o_FW,"mapFrame")
			_IELoadWait($oMapFrame)
			$oMapFrame.document.body.innerHTML = $oMapFrame.document.body.innerHTML & '<br><button onclick="javascript:Move(''left'')" id="button2">test</button>'
			$oMapFrame.document.getElementById("button2").click
		Case $value =6
			$oMapFrame=_IEFrameGetObjByName($o_FW,"mapFrame")
			_IELoadWait($oMapFrame)
			$oMapFrame.document.body.innerHTML = $oMapFrame.document.body.innerHTML & '<br><button onclick="javascript:Move(''right'')" id="button2">test</button>'
			$oMapFrame.document.getElementById("button2").click
		Case $value =1
			$oMapFrame=_IEFrameGetObjByName($o_FW,"mapFrame")
			_IELoadWait($oMapFrame)
			$oMapFrame.document.body.innerHTML = $oMapFrame.document.body.innerHTML & '<br><button onclick="javascript:Move(''downleft'')" id="button2">test</button>'
			$oMapFrame.document.getElementById("button2").click
		Case $value =2
			$oMapFrame=_IEFrameGetObjByName($o_FW,"mapFrame")
			_IELoadWait($oMapFrame)
			$oMapFrame.document.body.innerHTML = $oMapFrame.document.body.innerHTML & '<br><button onclick="javascript:Move(''down'')" id="button2">test</button>'
			$oMapFrame.document.getElementById("button2").click
		Case $value =3
			$oMapFrame=_IEFrameGetObjByName($o_FW,"mapFrame")
			_IELoadWait($oMapFrame)
			$oMapFrame.document.body.innerHTML = $oMapFrame.document.body.innerHTML & '<br><button onclick="javascript:Move(''downright'')" id="button2">test</button>'
			$oMapFrame.document.getElementById("button2").click
	EndSelect
EndFunc

Func _Eingabe($value)			;- Inputbox mit von der aktuellen Position aus bekannten Zielen und Aufrufen von _moveto
	If $value = 0 Then			;- Wenn kein Wert an die Funktion übergeben wird -> Inputbox
		Dim $text
		$aPos= _aPosition()
		$PosStr=_ArrayToString($aPos,"/")
		$PosFA=_ArraySearch($aWege,$PosStr)
		If $PosFA = -1 Then
			MsgBox(0,"Unbekannte Position","Von hier aus kenne ich leider keine Wege"&@CRLF&"Du kannst neue Wege in der Orte.csv einfügen.")
		Else
			$PosFE=_ArraySearch($aWege,$PosStr,"","","","",0)
			for $i=$PosFA to $PosFE
				$text= $text & $i &@TAB& $aWege[$i][1] &@CRLF
			Next
			Do
				$input= int(InputBox("Mögliche Wege","Von hier kenne ich Wege zu:" &@CRLF&@CRLF & $text&@CRLF&@CRLF&"Ziel als Ziffer eingeben:",1,"",250,250))
				If @error =1 Then Exit
					If IsNumber($input)=1 and $input <= UBound($aWege) Then
					$aWeg= StringSplit($aWege[$input][3],",",2)
	;~ 		 		_ArrayDisplay($aWeg,"Weg zu: " & $aWege[$input][1])
					for $b=0 to ubound($aWeg) -1
						Sleep(_check_laufpause())
						_move($aWeg[$b])
						_Feldaktionen()
						Sleep(_check_laufpause())
						_Feldaktionen()
						Sleep(_check_laufpause())
					Next
				Else
					MsgBox(0,"Eingabefehler","Falschen Wert eingegeben.")
				EndIf
				ExitLoop
			Until @error = 1
		EndIf
	Else
		If IsNumber($value)=1 and $value <= UBound($aWege) Then			;- Wenn der Funktion ein Wert übergeben wird, direkt _move ausführen
		$aWeg= StringSplit($aWege[$value][3],",",2)
;~ 		 		_ArrayDisplay($aWeg,"Weg zu: " & $aWege[$input][1])
		for $b=0 to ubound($aWeg) -1
			Sleep(_check_laufpause())
			_move($aWeg[$b])
			_Feldaktionen()
;~ 			Sleep(_check_laufpause())
			_Feldaktionen()
			Sleep(_check_laufpause())
		Next
		EndIf
	EndIf
EndFunc

Func _IELinkClickByPartText(ByRef $o_object, $s_linkText, $i_index = 0, $f_wait = 1)
    If Not IsObj($o_object) Then
       __IEErrorNotify("Error", "_IELinkClickByText", "$_IEStatus_InvalidDataType")
       Return SetError($_IEStatus_InvalidDataType, 1, 0)
    EndIf
    Local $found = 0, $linktext, $links = $o_object.document.links
    $i_index = Number($i_index)
    For $link In $links
       $linktext = $link.outerText & "" ; Append empty string to prevent problem with no outerText (image) links
       If StringInStr($linktext , $s_linkText) Then
          If ($found = $i_index) Then
             $link.click
             If $f_wait Then
                _IELoadWait($o_object)
                Return SetError(@error, 0, -1)
             EndIf
             Return SetError($_IEStatus_Success, 0, -1)
          EndIf
          $found = $found + 1
       EndIf
    Next
    __IEErrorNotify("Warning", "_IELinkClickByText", "$_IEStatus_NoMatch")
    Return SetError($_IEStatus_NoMatch, 0, 0) ; Could be caused by parameter 2, 3 or both
EndFunc

Func _getLinks($sFrame,$sOption)					;- Beispiel: _getLinks("itemFrame","innerhtml")
	$oFrame = _IEFrameGetObjByName($o_FW,$sFrame)
	$oLinks = _IELinkGetCollection($oFrame)
	dim $aLinks[1]
	$i=0
	Select
		Case $sOption ="innertext"
			for $oLink in $oLinks
				$aLinks[$i]	=	$oLink.innertext
				ReDim $aLinks[UBound($aLinks)+1]
				$i+=1
			Next
		Case $sOption = "innerhtml"
			for $oLink in $oLinks
				$aLinks[$i]	=	$oLink.innerhtml
				ReDim $aLinks[UBound($aLinks)+1]
				$i+=1
			Next
		Case $sOption ="outerhtml"
			for $oLink in $oLinks
				$aLinks[$i]	=	$oLink.outerhtml
				ReDim $aLinks[UBound($aLinks)+1]
				$i+=1
			Next
		Case $sOption ="href"
			for $oLink in $oLinks
				$aLinks[$i]	=	$oLink.href
				ReDim $aLinks[UBound($aLinks)+1]
				$i+=1
			Next
		EndSelect
	_ArrayDelete($aLinks,UBound($aLinks)-1)
	Return $aLinks
EndFunc

Func _getTagElements($sFrame,$sTag,$sOption)		;- Beispiel: _getTagElements("itemFrame","span","innerhtml")
	$oFrame = _IEFrameGetObjByName($o_FW,$sFrame)
	$oElements= _IETagNameGetCollection ($oFrame,$sTag)
	dim $aElements[1]
	$i=0
	Select
		Case $sOption ="innertext"
			For $oElement In $oElements
				$aElements[$i] = $oElement.innertext
				ReDim $aElements[UBound($aElements)+1]
			$i+=1
			Next
		Case $sOption = "innerhtml"
			For $oElement In $oElements
				$aElements[$i] = $oElement.innerhtml
				ReDim $aElements[UBound($aElements)+1]
			$i+=1
			Next
		Case $sOption ="outerhtml"
			For $oElement In $oElements
				$aElements[$i] = $oElement.outerhtml
				ReDim $aElements[UBound($aElements)+1]
			$i+=1
			Next
		EndSelect
	_ArrayDelete($aElements,UBound($aElements)-1)
	Return $aElements
EndFunc

Func click_weiter()       						   ;Klick auf 'weiter', falls Infos im MainFrame stören
$oFrame = _IEFrameGetObjByName($o_FW, "mainFrame")
_IELinkClickByPartText($oFrame, "Weiter"); falls Meldungen im mainFrame stehen: wegklicken
_IELoadWait($o_FW)
EndFunc

Func zufallspause($nw,$hw) 							;nw -> niedrigster Wert, hw -> höchster Wert
$ran=random($nw,$hw)
$ret=$ran*1000
Return($ret)
EndFunc

;- Charakterwerte checken (XP, LP, Inventar, etc.)
Func _checkCharacter()	;- Werte: XP, LP, Gold, Int, A-Stärke, A-Waffe, A-Zustand, V-Stärke, V-Waffe, V-Zustand
	$oFrame= _IEFrameGetObjByName($o_FW,"itemFrame")
	_IELoadWait($oFrame)
	$aTMP= _getTagElements("itemFrame","p","innertext")
	_ArrayDelete($aTMP,1)			;- WICHTIG! Falls keine Akas vorhanden auskommentieren
	$aTMPZ= _getTagElements("itemFrame","p","outerhtml")
	_ArrayDelete($aTMPZ,1)			;- WICHTIG! Falls keine Akas vorhanden auskommentieren
	Dim $aCharacter[10]
	$TMP= _StringBetween($aTMP[0],"Erfahrung: "," von")
	$aCharacter[0]= int($TMP[0])
	$TMP= _StringBetween($aTMP[4],"Lebenspunkte: (","/")
	$aCharacter[1]= int($TMP[0])
	$TMP= _StringBetween($aTMP[5],"Geld: "," ")
	$aCharacter[2]= int(StringReplace($TMP[0],".",""))
	$TMP= _StringBetween($aTMP[6],"Intelligenz: ","(")
	$aCharacter[3]= int($TMP[0])
	If StringInStr($aTMP[7],"(durch Waffe)") = 0 Then
		$TMP= StringRegExp($aTMP[7],"([0-9]{1,4})",3)
		$aCharacter[4]= int($TMP[0])
	Else
		$TMP= StringRegExp($aTMP[7],"([0-9]{1,4})",3)
		$aCharacter[4]= int($TMP[0]+$TMP[1])
	EndIf
	$TMP= StringRegExp($aTMP[8],"(?<=Angriffswaffe: )[[:ascii:]]*",3)
	$aCharacter[5]= $TMP[0]
	If $aCharacter[5] <> "Keine" Then
		$TMP= _StringBetween($aTMPZ[8],"Zustand: ","%")
		$aCharacter[6]= $TMP[0]
	EndIf
	$TMP= StringRegExp($aTMP[9],"([0-9]{1,4})",3)
	If UBound($TMP) = 1 Then
		$aCharacter[7]= int($TMP[0])
	Else
		$aCharacter[7]= int($TMP[0]+$TMP[1])
	EndIf
	$TMP= StringRegExp($aTMP[10],"(?<=Verteidigungswaffe: )[[:ascii:]]*",3)
	$aCharacter[8]= $TMP[0]
	If $aCharacter[8] <> "Keine" Then
		$TMP= _StringBetween($aTMPZ[10],"Zustand: ","%")
		$aCharacter[9]= $TMP[0]
	EndIf
	Return $aCharacter
EndFunc

func _Inv()
	$oFrame = _IEFrameGetObjByName($o_FW,"itemFrame")
	_IELoadWait($oFrame)
	$sHTML = _IEDocReadHTML($oFrame)
	If StringRegExp($sHTML,"(öffnen)",0) = 1 Then
		_IELinkClickByText($oFrame, "öffnen")
		$oFrame = _IEFrameGetObjByName($o_FW,"itemFrame")
		_IELoadWait($oFrame)
	EndIf
	$aTMP= _getTagElements("itemFrame","p","innertext")
	_ArrayDelete($aTMP,1)
	For $i=0 to 12
		_ArrayDelete($aTMP,0)
	Next
	$aTMP2= _getTagElements("itemFrame","p","innerhtml")
	_ArrayDelete($aTMP2,1)
	For $i=0 to 12
		_ArrayDelete($aTMP2,0)
	Next
	Dim $aInv[UBound($aTMP)][2]
	For $i=0 to UBound($aTMP)-1
		$aInv[$i][0]= $aTMP[$i]
		$aItemID= StringRegExp($aTMP2[$i],"([0-9]{2,10})",1)
		$aInv[$i][1]= $aItemID[0]
	Next
	Return $aInv
EndFunc

Func _checkFurgor()
	Dim $iMax=3
	$oFrame = _IEFrameGetObjByName($o_FW,"itemFrame")
	_IELoadWait($oFrame)
	$sHTML = _IEDocReadHTML($oFrame)
	If StringRegExp($sHTML,"(öffnen)",0) = 1 Then
		_IELinkClickByText($oFrame, "öffnen")
		$oFrame = _IEFrameGetObjByName($o_FW,"itemFrame")
		_IELoadWait($oFrame)
	EndIf
	$aInv= _inv()
;~ 	_ArrayDisplay($ainv)
	Dim $iAnzahl
	For $i=0 to UBound($ainv)-1
		If StringInStr($ainv[$i][0],"Furgorpilz") <> 0 Then
			$test=StringRegExp($ainv[$i][0],"([0-9]{1,2})",1)
;~ 			_ArrayDisplay($test)
			if $test[0] <> 0 Then
				$iAnzahl= $iAnzahl+ $test[0]
			Else
				$iAnzahl+=1
			EndIf
		EndIf
	Next
	If $iAnzahl < $iMax Then
		$oFrame = _IEFrameGetObjByName($o_FW,"mainFrame")
		_IELoadWait($oFrame)
		_IELinkClickByText($oFrame, "Einkaufen")
		 $oFrame = _IEFrameGetObjByName($o_FW,"mainFrame")
		_IELoadWait($oFrame)
		Sleep(2000)
		$aLinks= _getLinks("mainFrame","innerhtml")
		$oForm= _IEFormGetCollection($oFrame,0)
		$oElement = _IEFormElementGetCollection($oForm,0)
		_IEFormElementSetValue($oElement,$iMax-$iAnzahl,1)
;~ 		_ArrayDisplay($aLinks)
		_IELinkClickByText($oForm,$aLinks[1])
		_IELoadWait($oFrame)
		Sleep(2000)
		_IELinkClickByText($oFrame, "Zurück")
	EndIf
EndFunc

;- Feld Informationen checken (NPC da, Dropitems...)
Func _checkNPC()			;- (NPC-Check kann noch verbessert werden)
	$oFrame = _IEFrameGetObjByName($o_FW,"mainFrame")
	$HTML = _IEDocReadHTML($oFrame)
	$arN = _StringBetween($HTML,'<b>',' </b>(NPC)')
	if isArray($arN) Then
		$npc=$arN[0]
	Else
		$npc=""
	EndIf
	Return $npc
EndFunc

Func _checkDropitem()
	$oFrame = _IEFrameGetObjByName($o_FW,"mainFrame")
	$HTML = _IEDocReadHTML($oFrame)
	$aItems=_ListeDropitems()
	For $i =1 to $aItems[0]
		if (StringInStr($HTML,$aItems[$i]))<>0 Then
			$sItem = $aItems[$i]
			ExitLoop
		Else
			$sItem = ""
		EndIf
	Next
	Return $sItem
EndFunc

;- Kaufen, Verkaufen und MaHa Funktionen

Func _ShopVerkauf()
	$aShopitem= _ListeShopItems()
	;~ _ArrayDisplay($aShopItems)
	$oFrame=  _IEFrameGetObjByName($o_FW,"mainFrame")
	_IELoadWait($oFrame)
	_IELinkClickByText($oFrame, "Item an den Laden verkaufen")
	$oFrame = _IEFrameGetObjByName($o_FW, "mainFrame")
	_IELoadWait($oFrame)
	$oElementsA = _IETagNameGetCollection ($oFrame,"b")
	$oElementsB = _IETagNameGetCollection ($oFrame,"span")
	dim $aItem[1][2]
	$i=0
	For $oElement In $oElementsA
		$aItem[$i][0] = $oElement.innertext
		ReDim $aItem[UBound($aItem)+1][2]
		$i+=1
	Next
	$i=0
	For $oElement In $oElementsB
		$aItem[$i][1] = $oElement.innerhtml
		$i+=1
	Next
	_ArrayDelete($aItem,UBound($aItem)-1)
	$aLinks= _getLinks("mainFrame","innerhtml")
	for $i=0 to UBound($aShopItem)-1
		$oForm= _IEFormGetCollection($oFrame,0)
		$index= _ArraySearch($aItem,$aShopItem[$i])
		if $index <> -1 Then
			$oElements= _IEFormElementGetCollection($oForm,$index)
			_IEFormElementSetValue($oElements,$aItem[$index][1])
			Sleep(500)
			MsgBox(0,"",$aLinks[$index])
;~ 			_IELinkClickByText($oFrame,$aLinks[$index])
			$oFrame= _IEFrameGetObjByName($o_FW,"mainFrame")
			_IELoadWait($oFrame)
			sleep(2000)
;~ 			_IELinkClickByText($oFrame,"Zurück")
;~ 			sleep(1000)
;~ 			$oFrame=  _IEFrameGetObjByName($o_FW,"mainFrame")
;~ 			_IELoadWait($oFrame)
;~ 			_IELinkClickByText($oFrame, "Item an den Laden verkaufen")
;~ 			$oFrame = _IEFrameGetObjByName($o_FW, "mainFrame")
;~ 			_IELoadWait($oFrame)
		EndIf
	Next
EndFunc

Func _MaHaVerkauf()
	$aMaHaitems= _ListeMahaItems()
	$oFrame = _IEFrameGetObjByName($o_FW, "mainFrame")
	_IELoadWait($oFrame)
	_IELinkClickByText($oFrame, "Item verkaufen lassen in der Markthalle")
	$oFrame = _IEFrameGetObjByName($o_FW, "mainFrame")
	_IELoadWait($oFrame)
	$oElementsA = _IETagNameGetCollection ($oFrame,"b")
	$oElementsB = _IETagNameGetCollection ($oFrame,"span")
	dim $aItem[1][2]
	$i=0
	For $oElement In $oElementsA
		$aItem[$i][0] = $oElement.innertext
		ReDim $aItem[UBound($aItem)+1][2]
		$i+=1
	Next
	$i=0
	For $oElement In $oElementsB
		$aItem[$i][1] = $oElement.innerhtml
		$i+=1
	Next
	_ArrayDelete($aItem,UBound($aItem)-1)
	$aLinks= _getLinks("mainFrame","innerhtml")
	for $i=0 to UBound($aMaHaitems)-1
		$oForm= _IEFormGetCollection($oFrame,0)
		$index= _ArraySearch($aItem,$aMaHaitems[$i][0])
		if $index <> -1 Then
			$oElements= _IEFormElementGetCollection($oForm,$index)
			_IEFormElementSetValue($oElements,$aItem[$index][1])
			Sleep(500)
			_IELinkClickByText($oFrame,$aLinks[$index],$index)
			$oFrame= _IEFrameGetObjByName($o_FW,"mainFrame")
			_IELoadWait($oFrame)
			$oForm= _IEFormGetObjByName($oFrame,"form1")
			$oElements= _IEFormElementGetCollection($oForm,0)
			$oButton= _IEFormElementGetObjByName($oForm,"Submit")
			_IEFormElementSetValue($oElements,$aMaHaitems[$i][1])
			sleep(1000)
			_IEAction($oButton, "click")
			sleep(1000)
			click_weiter()
			$oFrame=  _IEFrameGetObjByName($o_FW,"mainFrame")
			_IELoadWait($oFrame)
			sleep(2000)
		EndIf
	Next
	Sleep(2000)
	_IELinkClickByText($oFrame,"Zurück")
EndFunc

;- Aktionen (Killen, heilen,...)
Func _npcKillen()
	;- ToDo: Kampfausgang berechnen. Lt. Wiki: FaktorAngreifer = LVerteidiger / ( AAngreifer - VVerteidiger)  LP-NPC / ($Angriff-0)
	;- Beim Verteidiger kann es sich sowohl um einen Spieler als auch um ein NPC handeln; NPCs haben (bis jetzt) alle eine Verteidigung von 0.
	$oFrame = _IEFrameGetObjByName($o_FW,"mainFrame")
	_IELoadWait($oFrame)
	_IELinkClickByText($oFrame, "Angreifen")
	$oFrame = _IEFrameGetObjByName($o_FW,"mainFrame")
	_IELoadWait($oFrame)
	_IELinkClickByText($oFrame, "Angreifen")
EndFunc

Func _Reparieren()
	$aShops = _ListeShops()
	$sPosition= _sPosition()
	For $i = 0 to UBound($aShops)-1
		If $sPosition = $aShops[$i] Then
			$aCharacter= _checkCharacter()
;~ 			_ArrayDisplay($aCharacter)
;- Werte: 	[0]XP, [1]LP, [2]Gold, [3]Int, [4]A-Stärke, [5]A-Waffe
;-			[6]A-Zustand, [7]V-Stärke, [8]V-Waffe, [9]V-Zustand
			Select
				Case $aCharacter[5] <> "keine" And $aCharacter[6] <= 85 And $aCharacter[8] <> "keine" And $aCharacter[9] <= 85
;~ 					MsgBox(0,"","Beide Waffen müssen repariert werden")
					$aInv= _inv()
					$oFrame= _IEFrameGetObjByName($o_FW,"mainFrame")
					_IELoadWait($oFrame)
					_IELinkClickByText($oFrame, "Waffe reparieren")
					Sleep(500)
					$oFrame= _IEFrameGetObjByName($o_FW,"mainFrame")
					_IELoadWait($oFrame)
					$aTMP= _getTagElements("mainFrame","b","innertext")
					$iIndex= _ArraySearch($aInv,$aCharacter[5],0,0,0,1)
					$aLinks= _getLinks("mainFrame","href")
					$iIndex= _ArraySearch($aLinks,$aInv[$iIndex][1],0,0,0,1)
					_IELinkClickByIndex($oFrame,$iIndex)
					Sleep(500)
					click_weiter()
					Sleep(500)
					$aInv= _inv()
					$oFrame= _IEFrameGetObjByName($o_FW,"mainFrame")
					_IELoadWait($oFrame)
					_IELinkClickByText($oFrame, "Waffe reparieren")
					Sleep(500)
					$oFrame= _IEFrameGetObjByName($o_FW,"mainFrame")
					_IELoadWait($oFrame)
					$aTMP= _getTagElements("mainFrame","b","innertext")
					$iIndex= _ArraySearch($aInv,$aCharacter[8],0,0,0,1)
					$aLinks= _getLinks("mainFrame","href")
					$iIndex= _ArraySearch($aLinks,$aInv[$iIndex][1],0,0,0,1)
					_IELinkClickByIndex($oFrame,$iIndex)
					Sleep(500)
					click_weiter()
				Case $aCharacter[5] <> "keine" And $aCharacter[6] <= 85
;~ 					MsgBox(0,"","Die Angriffswaffe muss repariert werden")
					$aInv= _inv()
					$oFrame= _IEFrameGetObjByName($o_FW,"mainFrame")
					_IELoadWait($oFrame)
					_IELinkClickByText($oFrame, "Waffe reparieren")
					Sleep(500)
					$oFrame= _IEFrameGetObjByName($o_FW,"mainFrame")
					_IELoadWait($oFrame)
					$aTMP= _getTagElements("mainFrame","b","innertext")
					$iIndex= _ArraySearch($aInv,$aCharacter[5],0,0,0,1)
					$aLinks= _getLinks("mainFrame","href")
					$iIndex= _ArraySearch($aLinks,$aInv[$iIndex][1],0,0,0,1)
					_IELinkClickByIndex($oFrame,$iIndex)
					Sleep(500)
					click_weiter()
				Case $aCharacter[8] <> "keine" And $aCharacter[9] <= 85
;~ 					MsgBox(0,"","Die Verteidigungswaffe muss repariert werden")
					$aInv= _inv()
					$oFrame= _IEFrameGetObjByName($o_FW,"mainFrame")
					_IELoadWait($oFrame)
					_IELinkClickByText($oFrame, "Waffe reparieren")
					Sleep(500)
					$oFrame= _IEFrameGetObjByName($o_FW,"mainFrame")
					_IELoadWait($oFrame)
					$aTMP= _getTagElements("mainFrame","b","innertext")
					$iIndex= _ArraySearch($aInv,$aCharacter[8],0,0,0,1)
					$aLinks= _getLinks("mainFrame","href")
					$iIndex= _ArraySearch($aLinks,$aInv[$iIndex][1],0,0,0,1)
					_IELinkClickByIndex($oFrame,$iIndex)
					Sleep(500)
					click_weiter()
			EndSelect
		EndIf
	Next
EndFunc

Func _item_aufheben()
	 $oFrame = _IEFrameGetObjByName($o_FW,"mainFrame")
	_IELoadWait($oFrame)
	_IELinkClickByText($oFrame, "Nehmen")
EndFunc

Func _heilen($LP)
	If $LP <=5 Then
		$aInv= _Inv()
;~ 		_ArrayDisplay($aInv)
		$aHeilItems= _ListeHeilItems()
		For $i=0 to UBound($aHeilItems)-1
			$Index= _ArraySearch($aInv,$aHeilItems[$i],0,0,0,1)
;~ 			MsgBox(0,"",$Index)
			If $Index <> -1 Then
;~ 				MsgBox(0,"",$aInv[$Index])
				$aElements= _getTagElements("itemframe","p","innerhtml")
				$aLinks= _getLinks("itemFrame","outerhtml")
				$Index= _ArraySearch($aElements,"Furgorpilz",0,0,0,1)
				If $Index <> -1 Then
;~ 					MsgBox(0,"","Test")
					$aItemID= StringRegExp($aElements[$Index],"([0-9]{2,10})",1)
					$Index = _ArraySearch($aLinks,$aItemID[0],0,0,0,1)
;~ 					MsgBox(0,"",$Index)
					$oFrame= _IEFrameGetObjByName($o_FW,"itemFrame")
					_IELoadWait($oFrame)
					_IELinkClickByIndex($oFrame,$Index)
					ExitLoop
				EndIf
			Else
;~ 				MsgBox(0,"Warnung!","Keine Heilitems im Inventar!")
			EndIf
		Next
	EndIf
EndFunc

Func _XPabsaugen()
	$oItemFrame = _IEFrameGetObjByName($o_FW,"itemFrame")
	_IELoadWait($oItemFrame)
	$HTMLsource = _IEDocReadHTML($oItemFrame)
	$aXP= _StringBetween($HTMLsource,"Erfahrung: "," von 100)")
	If $aXP[0] >0 Then
		$oMainFrame=_IEFrameGetObjByName($o_FW,"mainFrame")
		_IELoadWait($oMainFrame)
		$oForm= _IEFormGetCollection($oMainFrame,0)
		$oAnz = _IEFormElementGetObjByName($oForm,"anz")
		_IEFormElementSetValue($oAnz,$aXP[0])
		_IELinkClickByText($oMainFrame,"Erfahrungspunkte absaugen lassen")
		_IELoadWait($oMainFrame)
	EndIf
EndFunc

Func _Feldaktionen()
	$aPos			= _aPosition()
	$sPosition		= _sPosition()
	$aCharacter		= _checkCharacter()		;- Werte: XP, LP, Gold, Int, A-Stärke, A-Waffe, A-Zustand, V-Stärke, V-Waffe, V-Zustand
	_heilen($aCharacter[1])
;~ 	_ShopVerkauf()
	_Reparieren()
	If $aPos[0] = 96 and $aPos[1] = 101 Then _MahaVerkauf()							;- MaHa Konlir
	If $aPos[0] = 79 and $aPos[1] = 110 Then _checkFurgor()							;- Plefir-Shop
	If $aPos[0] = 80 and $aPos[1] = 94 And $aCharacter[0] >= 40 Then _XPabsaugen()	;- Dunkler Turm
	If $aCharacter[0] < 48 And $aCharacter[1] > 5 And $aCharacter[6] > 80 And $aCharacter[9] > 80 Then	;- NPC, XP, Zustand checken, ggf. killen, ggf. heilen
		$aListeNPC= _ListeNPCs()
		$NPC= _checknpc()
		For $i = 1 to $aListeNPC[0]
			if ($aListeNPC[$i]=$NPC) then
				_npckillen()
				_heilen($aCharacter[1])
			EndIf
		Next
	EndIf
	$i = 0
	While $i < 4												;- Dropitems aufheben
		$sDropItem = _checkDropitem()
		if not $sDropItem = "" Then	_item_aufheben()
		$i += 1
	Wend
EndFunc

;- Routen
Func Route1()
	_Eingabe(5)		;- zu BaW
	_Eingabe(51)	;- zu MaHa Konlir
	_Eingabe(53)	;- zu Öllager
	_Eingabe(15)	;- zu Plefir - Nähe Stiftung (83/110)
	$aCharacter= _checkCharacter()
	If $aCharacter[0] < 48 Then _Eingabe(62)	;- Pilze jagen
	_Eingabe(61)	;- zu Gaslager
	_Eingabe(20)	;- zu dunkler Turm
	_Eingabe(38)	;- zu Geburtsort
EndFunc

;~ Aktionen
for $i=0 to 3
	route1()
Next
;~ _logout()


;- Testsektion
#cs Inhalt von $aInv:
[0][0]= Anzahl, [0][1]= Beschreibung, [0][2]= ItemID, [0][3] =Ist Heilitem(0/1), [0][4]= Ist Shopitem(0/1), [0][5]= Ist MaHa-Item (0/1)
[0][6]= Preis MaHa, [0][7]= Waffentyp (A/V), [0][8]= A/V-Wert Waffe, [0][9]= Zustand A/V, [0][10]= Min.Attribut-Wert Waffe
#ce

#cs
Func item_verkaufen($sItem,$iAnzahl)
	$oFrame = _IEFrameGetObjByName($o_FW, "mainFrame"); get a reference to the main frame
    _IELinkClickByText($oFrame, "Item an den Laden verkaufen")
	$oFrame = _IEFrameGetObjByName($o_FW, "mainFrame"); get a reference to the main frame
    $HTML = _IEDocReadHTML($oFrame)
	$id = _StringBetween($HTML, '>'&$sItem&'</B></TD>'&@CRLF&'<TD>&nbsp;</TD>'&@CRLF&'<TD><INPUT class=input id=anz_', ' style="TEXT-ALIGN: right" maxLength=3 size=3 value=1>',-1)
	if not isArray($id) then $id = _StringBetween($HTML, '>'&$sItem&'</B></TD>'&@CRLF&'<TD>&nbsp;</TD>'&@CRLF&'<TD><INPUT style="TEXT-ALIGN: right" id=anz_', ' class=input value=1 maxLength=3 size=3>',-1)
    ;MsgBox(0,"","id= " & $id[0])
	if isArray($id) Then
		For $i = 1 to $iAnzahl
			$oForm = _IEFormGetCollection($oFrame,0)
			$oFrame.document.body.innerHTML = $oframe.document.body.innerHTML & '<A onclick="this.href += "&amp;anz=" + document.getElementById("anz_'&$id[0]&'").value;" href="main.php?arrive_eval=sell&amp;sell_item='&$id[0]&'">verkaufen</A>'
			_IELinkClickByText($oFrame, "verkaufen")
		Next
	EndIf
EndFunc

Func check_anzahl_items($item)
$oFrame0 = _IEFrameGetObjByName($o_FW,"itemFrame")
_IELoadWait($oFrame0)
If $item = "gepresste Zauberkugel" Then
	$sHTML = _IEDocReadHTML($oFrame0)
	$aGzk = _StringBetween($sHTML,'>gepresste Zauberkugel</a> (',')</td>')
	if isArray($aGzk) Then
		$anzahl_items = $aGzk[0]
	Else
		$anzahl_items = 0
	EndIf
ElseIf $item = "Stab des Handels" Then
	$sHTML = _IEDocReadHTML($oFrame0)
	$aSdH = _StringBetween($sHTML,'>Stab des Handels</a> (',')</td>')
	if isArray($aSdH) Then
		$anzahl_items = $aSdH[0]
	Else
		$anzahl_items = 0
	EndIf
Else
	_IELinkClickByText($oFrame0, "öffnen")
	$oFrame = _IEFrameGetObjByName($o_FW,"itemFrame")
	_IELoadWait($oFrame)
	$HTMLsource = _IEDocReadHTML($oFrame)
	$items_existieren = StringInStr($HTMLsource,$item)
	If $items_existieren <> 0 Then
		$anzahl_items = 1
		$anzahl_gleich_1 = StringInStr($HTMLsource,'<P class=listitemrow><B>'&$item&'</B>')
		If $anzahl_gleich_1 = 0 Then
			$ItemTextSchnippsel = _StringBetween($HTMLsource,'<SPAN class=itemamount>','x</SPAN> <B>'&$item&'</B>')
		If @error Then
            MsgBox(0, "ItemTextschnippsel", "Suchstring nicht gefunden")
		Else
		$anzahl_items = $ItemTextSchnippsel[0]
	   EndIf
    EndIf
	Else
		$anzahl_items = 0
	EndIf
	_IELinkClickByText($oFrame, "schliessen")
EndIf
Return $anzahl_items
EndFunc

Func verkauf($iPos)
	$aShops = init_shops()
	;_ArrayDisplay($aShops)
	For $i = 1 to $aShops[0]
		If $iPos = $aShops[$i] Then
			$aVerkaufsItems = init_verkaufsitems()
			;_ArrayDisplay($aVerkaufsItems)
			For $j = 1 to Ubound($aVerkaufsItems)-1
				$iNumItems = check_anzahl_items($aVerkaufsItems[$j])
				If $iNumItems > 0 Then item_verkaufen($aVerkaufsItems[$j],$iNumItems)
			Next
		EndIf
	Next
EndFunc

Func _holeRohstoff()
$oFrame4 = _IEFrameGetObjByName($o_FW, "mainFrame"); get a reference to the main frame
_IELinkClickByPartText($oFrame4, "mitnehmen"); wenn Fässer vorhanden steht im mainFrame ein Link: "<anzahl> Ölfässer abholen"
$oFrame1 = _IEFrameGetObjByName($o_FW, "mainFrame"); get a reference to the main frame
_IELinkClickByText($oFrame1, "Weiter"); click on a link in the contents frame
EndFunc

#ce

;~ _heilen(5)
;~ $aInv=_inv()
;~ _ArrayDisplay($aInv)
;~ _ShopVerkauf()
;~ _MaHaVerkauf()
;~ _checkFurgor()
;~ $aCharacter=_checkCharacter()
;~ _ArrayDisplay($aCharacter)
;~ _Reparieren()

#cs beste waffe anlegen
Func _BesteWaffeAnlegen()
	$aInv=	_checkInv()
;~ _ArrayDisplay($aInv)
	$aIndexA= _ArrayFindAll($aInv,"A",0,0,0,0,7)
	$aIndexV= _ArrayFindAll($aInv,"V",0,0,0,0,7)
	$sIndexA= $aIndexA[0]
	$sIndexV= $aIndexV[0]
	$oFrame = _IEFrameGetObjByName($o_FW,"itemFrame")
	_IELoadWait($oFrame)
	$aLinks= _getLinks("itemFrame","href")
	_IELinkClickByIndex($oFrame,_ArraySearch($aLinks,$aInv[$sIndexV][2],"","","",1)+1)	;- +1= Anschauen
	$oFrame = _IEFrameGetObjByName($o_FW,"itemFrame")
	_IELoadWait($oFrame)
	$HTML= _IEBodyReadHTML($oFrame)
	MsgBox(0,"",$HTML)
EndFunc


#ce
