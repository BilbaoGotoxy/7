#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Res_requestedExecutionLevel=asInvoker
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <WindowsConstants.au3>
#include <Constants.au3>
#Include <GuiConstants.au3>
#Include <IE.au3>
#Include <Array.au3>
#include <String.au3>
#include <INet.au3>

;--CONFIG
GLOBAL $LOGFILE = @ScriptDir &"\log.log"
Global $INI_CONFIG = @ScriptDir & "/config.ini"
Global $my_username = IniRead($INI_CONFIG, "Config", "username", "test" )
Global $my_password = IniRead($INI_CONFIG, "Config", "password", "test" )
Global $my_world = IniRead($INI_CONFIG, "Config", "world", 4)
Global $my_setgold = IniRead($INI_CONFIG, "Config", "setgold", 1)
GLOBAL $visible_status = IniRead($INI_CONFIG, "Config", "visible", true)
GLOBAL $GAME_DELAY = IniRead($INI_CONFIG, "Config", "delay", 1250)
GLOBAL $stop_gold = IniRead($INI_CONFIG, "Config", "stop gold", 1.2)
;--

;--GLOBAL VAR
GLOBAL $my_play_gold = $my_setgold
GLOBAL $MYGOLD
GLOBAL $START_GOLD
GLOBAL $my_URL = "http://welt"&$my_world&".freewar.de/freewar/"
GLOBAL $visible_status2 = 1
;--

;--IE VAR
Global $ie_fw
;--

;--main
_precheck()
_start_fw()
Sleep(2000)
_login()
Sleep(2000)
_get_gold()
$START_GOLD=$MYGOLD
Tooltip("GOLD: "&$MYGOLD, 0, 0)
Sleep(5000)
While(1)
_get_gold()
Tooltip("GOLD: "&$MYGOLD, 0, 0)
Sleep($GAME_DELAY)
;_check_end()
 _eine_runde_spielen()
_set_gold_to_play()
_click_play()
_check_result()
_click_weiter()
WEnd
_logout()
Exit
;--

;--Funcs
Func _precheck()
	if $visible_status==true then $visible_status2 = 1
	if $visible_status==false then $visible_status2 = 0
EndFunc
Func _start_fw()
	$ie_fw = _IECreate ()
	_IENavigate($ie_fw,$my_URL)
	_IELoadWait($ie_fw )
	EndFunc
Func _login()
	$login_forum = _IEFormGetObjByName($ie_fw,"login_form")
	$usernamebox = _IEFormElementGetObjByName($login_forum,"name")
	_IEFormElementSetValue($usernamebox ,$my_username)
	$pwbox = _IEFormElementGetObjByName($login_forum,"password")
	_IEFormElementSetValue($pwbox,$my_password)
	$loginbutton=_IEFormElementGetObjByName ($login_forum, "submit")
	_IEAction($loginbutton, "click")
	_ieloadwait($ie_fw)
	_IELinkClickByText($ie_fw,"Hier klicken um Freewar ohne Popup zu starten")
	_ieloadwait($ie_fw)
EndFunc
Func _logout()
	$logoutframe = _IEFrameGetObjByName($ie_fw, "menuFrame")
	_IELoadWait($logoutframe)
	_IELinkClickByText($logoutframe, "Logout")
	Sleep(1000)
	$logoutframe = _IEFrameGetObjByName($ie_fw, "mapFrame")
	_IELoadWait($logoutframe)
	_IELinkClickByText($logoutframe, "Ja",0,0)
	_IEAction($ie_fw,"quit")
Endfunc
Func _get_gold()
_IENavigate($ie_fw, "http://welt"&$my_world&".freewar.de/freewar/internal/item.php")
local $body = _IEBodyReadHTML($ie_fw)
local $Zahl1 = _StringBetween($body, '<b>Geld: </b>', ' <img title=')
If IsArray($Zahl1) Then
   $MYGOLD=$Zahl1[0]
EndIf
_IENavigate($ie_fw, "http://welt"&$my_world&".freewar.de/freewar/internal/main.php")
_IELoadWait($ie_fw )
EndFunc
Func _eine_runde_spielen()
_IENavigate($ie_fw, "http://welt"&$my_world&".freewar.de/freewar/internal/main.php?arrive_eval=spielen")
_IELoadWait($ie_fw )

EndFunc
Func _set_gold_to_play()
	$var_Form1 = _IEFormGetObjByName ($ie_fw, "form1")
	$ie_fw_Query1 = _IEFormElementGetObjByName ($var_Form1, "money")
	_IEFormElementSetValue ($ie_fw_Query1, $my_play_gold)
EndFunc
Func _click_play()
	$var_Form1 = _IEFormGetObjByName ($ie_fw, "form1")
	$playbutton=_IEFormElementGetObjByName ($var_Form1, "submit")
	_IEAction($playbutton, "click")
	_ieloadwait($ie_fw)
;$var_Form1 = _IEFormGetObjByName ($ie_fw, "form1")
;$play_button = _IEFormElementGetObjByName ( $var_Form1, "Spielen" )
;_IEAction ($play_button, "click")
EndFunc
Func _check_result()
	$savedhtml = _IEBodyReadHTML($ie_fw)
	 _IELoadWait ($ie_fw)
        If StringInStr($savedhtml, "hinzugewonnen") Then
                $my_play_gold=$my_setgold
			Else
				$my_play_gold=($my_play_gold*2)
		EndIf
EndFunc
Func _click_weiter()
_IELinkClickByText($ie_fw,"Weiter")
_ieloadwait($ie_fw)
EndFunc
Func _check_end()
	if $MYGOLD >=($START_GOLD*1.2) then
		Tooltip("FINSHED", 0, 0)
		Sleep(60000)
		Exit
	EndIf
EndFunc
