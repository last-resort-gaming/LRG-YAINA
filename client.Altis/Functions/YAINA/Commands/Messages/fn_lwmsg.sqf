/*
Function: YAINA_CMD_fnc_lwmsg

Description:
	Prints out a message warning about lonewolfing.

Parameters:
	_owner - The owner of the player object that called this command
    _caller - Not used
    _argStr - The name of the player to warn about lonewolfing

Return Values:
	Compiled message for internal handling

Examples:
    Nothing to see here

Author:
	Martin
*/

#include "..\defines.h"

params ["_owner", "_caller", "_argStr"];

// Lonewolfing (near base): <Name>, do not leave base alone. Lonewolfing is not allowed on this server. Return to base and line up.
// Lonewolfing (Ungrouped): <Name>, lonewolfing is not allowed on this server. Join the section closest to you and rendezvous with them.
// Lonewolfing (Grouped): <Name>, lonewolfing is not allowed on this server. Return to your section and follow your section commander’s orders.

_msg = nil;
_ret = "";

if !(_argStr isEqualTo "") then {
    _p = [_argStr] call FNC(findPlayer);
    if (_p isEqualTo []) then {
        _ret = format["no player matching %1", _argStr];
        _ret remoteExec ["systemChat", _owner];
    } else {
        if !(count _p isEqualTo 1) then {
            _ret = format ["too many matches for prefix %1", _argStr];
            _ret remoteExec ["systemChat", _owner];
        } else {

            _p = _p select 0;

            // Which Message ?
            _grouped   = ["IsGroupRegistered", [group _p]] call BIS_fnc_dynamicGroups;

            _msg = call {
                if (_grouped && { _p isEqualTo (leader (group _p)) }) exitWith {  "%1, lonewolfing is not allowed on this server. Return to your section bay and request transport from HQ." };
                if (_grouped)  exitWith { "%1, lonewolfing is not allowed on this server. Return to your section and follow your section commander’s orders." };
                if ({ _p distance2D (getMarkerPos _x) < 500; } count BASE_PROTECTION_AREAS > 0) exitWith { "%1, do not leave base alone. Lonewolfing is not allowed on this server. Return to base and line up." };
                if !(_grouped) exitWith { "%1, lonewolfing is not allowed on this server. Join the section closest to you and rendezvous with them." };
                "%1, lonewolfing is not allowed on this server. Return to your section bay."
            };

            _msg = format[_msg, name _p];

            // In addition to side chat, hintC it so they can't say they didn't see it
            _msg remoteExec [QYFNC(hintC), _p];
            _ret = format ["%1 sent to %2", "lwmsg", name _p];
        };
    };
} else {
    _ret = format ["This command requires a player argument"];
    _ret remoteExec ["systemChat", _owner];
};

if !(isNil "_msg") then {
    [[west, "HQ"], _msg] remoteExec ["sideChat"];
};

_ret