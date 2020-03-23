/*
Function: YAINA_fnc_playerIntroComplete

Description:
	Executes some stuff after the player intro has completed.
    This display warning messages if rejoining after being kicked or banned.

Parameters:
	_player - The player for whom we want to run this function

Return Values:
	None

Examples:
    Nothing to see here

Author:
	Martin
*/

#include "defines.h"

params ["_player"];
private ["_warn", "_playeruid", "_idx"];

if !(isServer) exitWith {};
if (remoteExecutedOwner isEqualTo 0) exitWith {};

if !(owner _player isEqualTo remoteExecutedOwner) exitWith { diag_log "SSFAF"; };

// If we have rejoined following a kick ?
_warn = 0;
_playeruid = getPlayerUID _player;
_idx  = (YVAR(warnings) select 0) find _playeruid;
if !(_idx isEqualTo -1) then {
    _warn = (YVAR(warnings) select 1 select _idx);
};

// Looks like they've just come back from a kick
if (_warn > 2) then {
    [["Welcome Back", "It looks like you have returned following multiple warnings.<br/><br/>If you continue to disobey the server rules or admins, you will be served with a more permanant ban.<br/><br/>Do you accept?"], {
        params ["_title", "_content"];
        _result = [_content, _title, "YES", "NO"] call BIS_fnc_guiMessage;
        if !(_result) then {
            [format["Disagreed to their welcome back from ban %1", toLower _title]] remoteExecCall ["YAINA_fnc_kickSelf"];
        };
    }] remoteExec ["spawn", _player];
};
