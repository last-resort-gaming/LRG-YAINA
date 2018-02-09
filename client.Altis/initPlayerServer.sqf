/*
	author: Martin
	description: none
	returns: nothing
*/

params ["_player", "_didJIP"];

_player setVariable ["YAINA_adminLevel", _player call YAINA_fnc_getAdminLevel, true];