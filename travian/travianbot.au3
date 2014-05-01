#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.8.1
 Author:         Bilbao

 Script Function:
	Attack Bot

#ce ----------------------------------------------------------------------------

;includes start

#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <ProgressConstants.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <Constants.au3>
#Include <IE.au3>
#Include <Array.au3>
#include <String.au3>
#include <INet.au3>
#Include <WinAPI.au3>
#Include <file.au3>
#include <Memory.au3>
#include <GDIPlus.au3>
#include-once
;includes ende


;var start
GLOBAL $ACC_NAME = "MYACCOUNTNAME"
GLOBAL $ACC_PW = "MYPASSWORD"
Global $ACC_SERVER = "http://www.travian.org/login.php"
GLOBAL $FARM[2]
GLOBAL $ie_travian
Global $form_login="login_form"
GLOBAL $FARMLIST = "farmlist.txt"
Global $farm_x_s[1], $farm_y_s[1], $farm_x, $farm_y
Global $DELIMITER = "|"
GLOBAL $last_farm
GLOBAL $farm_status = 1
GLOBAL $FARM_LEGIO_SIZE = 5
GLOBAL $LEG_UNITS_BUILD = 0
GLOBAL $LEG_UNITS_BUILD__ORDER = 100

GLOBAL $timer_diff_start_now
GLOBAL $start_time_timer
GLOBAL $pause_and_restart




;var ende
Sleep(5000)
_loadfarm()
_calc_and_set_restart_time()
_start_ie_travian()
_login()
_click_login()
Sleep(2000)

While 1
 _sleep(5000,6000,1)
 _build_legio()
 _sleep(2000,4000,1)
_farm()
Wend



Func _start_ie_travian()
	Tooltip("start_ie",0,0)
	HttpSetUserAgent("Lynx/2.8.4rel.1 libwww-FM/2.14 SSL-MM/1.4.1 OpenSSL/0.9.6c")
	 $ie_travian = _IECreate ()
	_IELoadWait($ie_travian)
EndFunc
Func _end_ie_travian()
	Tooltip("end_ie",0,0)
	Sleep(250)
_IENavigate($ie_travian, "http://www.travian.org/logout.php")
_IELoadWait($ie_travian)
_IEQuit ($ie_travian)
EndFunc
Func _login()
	Tooltip("login",0,0)
	_sleep(300,999,1)
_IENavigate($ie_travian, $ACC_SERVER)
_IELoadWait($ie_travian)
_set_name()
_set_pw()

endfunc
Func _set_name()
		Tooltip("set name",0,0)
	_sleep(300,999,1)
local $oForm =_IEFormGetCollection($ie_travian, 0)
local $oName =_IEFormElementGetObjByName($oForm, "name")
_IEFormElementSetValue($oName, $ACC_NAME)
EndFunc
Func _set_pw()
		Tooltip("set pw",0,0)
	_sleep(300,999,1)
local $oForm =_IEFormGetCollection($ie_travian, 0)
local $oName =_IEFormElementGetObjByName($oForm, "password")
_IEFormElementSetValue($oName, $ACC_PW)
endfunc
Func _click_login()
local $oForm =_IEFormGetCollection($ie_travian, 0)
local $sub_button = _IEGetObjByName($oForm,"btn_login")
_IEAction($sub_button,"click")
_IELoadWait($ie_travian)
EndFunc
Func _farm()
Tooltip("farm",0,0)
_sleep(500,999,1)
if ($farm_status>=$last_farm) then $farm_status=1
local $units_in_my_house=_check_legion_units()
if ($units_in_my_house>=$FARM_LEGIO_SIZE)then
_IENavigate($ie_travian, "http://www.travian.org/a2b.php")
_IELoadWait($ie_travian)
_farm_set_legio_size()
_sleep(500,999,1)
_farm_set_x()
_sleep(500,999,1)
_farm_set_y()
_sleep(500,999,1)
_farm_set_raubzug()
_sleep(500,999,1)
_farm_click_ok_start_units()
_sleep(500,999,1)
$farm_status=$farm_status+1
Else
_sleep(2000,5000,1)
Endif

;WEnd
Endfunc
Func _farm_set_x()
local $oForm =_IEFormGetCollection($ie_travian, 0)
local $oName =_IEFormElementGetObjByName($oForm, "x")
_IEFormElementSetValue($oName, $farm_x_s[$farm_status])
EndFunc
Func _farm_set_y()
local $oForm =_IEFormGetCollection($ie_travian, 0)
local $oName =_IEFormElementGetObjByName($oForm, "y")
_IEFormElementSetValue($oName, $farm_y_s[$farm_status])
EndFunc
Func _farm_set_raubzug()
local $oForm =_IEFormGetCollection($ie_travian, 0)
local $oName =_IEFormElementGetObjByName($oForm, "c")
_IEFormElementSetValue($oName, "4")
EndFunc
Func _farm_set_legio_size()
local $oForm =_IEFormGetCollection($ie_travian, 0)
local $oName =_IEFormElementGetObjByName($oForm, "t1")
_IEFormElementSetValue($oName, $FARM_LEGIO_SIZE)
EndFunc
Func _farm_click_ok_start_units()
local $oForm =_IEFormGetCollection($ie_travian, 0)
local $sub_button = _IEGetObjByName($oForm,"btn_ok")
_sleep(500,999,1)
_IEAction($sub_button,"click")
_IELoadWait($ie_travian)
local $oForm_best =_IEFormGetCollection($ie_travian, 0)
local $sub_button_best = _IEGetObjByName($oForm,"btn_ok")
_sleep(500,999,1)
_IEAction($sub_button_best,"click")
_sleep(500,999,1)
EndFunc
Func _loadfarm()
		Tooltip("load farm",0,0)
	_sleep(300,999,1)
	$FILEHANDLER = FileOpen($farmlist, 0)
	$last_farm=_FileCountLines(@ScriptDir & '\farmlist.txt')

	While 1
		$LINEINFILE = FileReadLine($FILEHANDLER)
		If @error = -1 Then
			ExitLoop
		Else
			$farm_y_STARTPOSITION = StringInStr($LINEINFILE, $DELIMITER)
			$farm_x = StringLeft($LINEINFILE, $farm_y_STARTPOSITION - 1)
			$farm_y = StringRight($LINEINFILE, StringLen($LINEINFILE) - $farm_y_STARTPOSITION)
			If $farm_x_s[0] = "" Then
				$farm_x_s[0] = $farm_y
			Else
				_ArrayAdd($farm_x_s, $farm_x)
			EndIf
			If $farm_y_s[0] = "" Then
				$farm_y_s[0] = $farm_y
			Else
				_ArrayAdd($farm_y_s, $farm_y)
			EndIf
		EndIf
	WEnd
	FileClose($FILEHANDLER)
EndFunc
Func _sleep($MIN_DELAY,$MAX_DELAY,$STEPS)
	LOCAL $NUMBER = String(Random($MIN_DELAY, $MAX_DELAY, $STEPS))
	LOCAL $NUMBER_S =$NUMBER/1000
	Tooltip("Sleep: "&$NUMBER_S&"sec",0,0)
	SLEEP($NUMBER)
EndFunc
Func _check_legion_units()
	_IENavigate($ie_travian, "http://www.travian.org/build.php?id=23")
	_IELoadWait($ie_travian)
	local $v_code = _IEDocReadHTML ($ie_travian)
	local $legios_count = _StringBetween($v_code,'>Legionär</a> <span class="info">(Vorhanden: ',')</span>')
	return $legios_count[0]
EndFunc
Func _build_legio()
	_IENavigate($ie_travian, "http://www.travian.org/build.php?id=23")
	_IELoadWait($ie_travian)
	local $buildable_leg_max = _max_buildable_leg()
if ($LEG_UNITS_BUILD<=$LEG_UNITS_BUILD__ORDER AND $buildable_leg_max>=1) Then
local $oForm =_IEFormGetCollection($ie_travian, 0)
local $oName =_IEFormElementGetObjByName($oForm, "t1")
_IEFormElementSetValue($oName, $buildable_leg_max)
_sleep(250,500,1)
local $start_build_units_button = _IEGetObjByName($oForm,"s1")
_IEAction($start_build_units_button,"click")
_IELoadWait($ie_travian)
_sleep(500,999,1)
endif
EndFunc
Func _max_buildable_leg()
	local $v_code = _IEDocReadHTML ($ie_travian)
	local $legios_max_buildable_count = _StringBetween($v_code,'.value=' , ';')
	return $legios_max_buildable_count[0]
EndFunc

Func _pause_and_restart()
	$timer_diff_start_now = TimerDiff($start_time_timer)
	If ($timer_diff_start_now >= $pause_and_restart) Then
			AdlibUnRegister("_pause_and_restart")
			_end_ie_travian()
			_sleep(60000,99999,1)
			Run(@ScriptDir & "\t_bot.exe")
			Sleep(100)
			Exit

   EndIf

EndFunc


Func _calc_and_set_restart_time()
	local $restarttimefortimer = String(Random(2400000, 3600000, 1))
	$pause_and_restart=$restarttimefortimer
	$start_time_timer = TimerInit()
     ADLIBREGISTER("_pause_and_restart", 30000)

Endfunc
