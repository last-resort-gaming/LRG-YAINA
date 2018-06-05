/*
Function: YAINA_CMD_fnc_zeusadd

Description:
	Add the given player to the zeus whitelist.

Parameters:
	_owner - The owner of the player object that called this command
    _caller - Not used
    _argStr - The player we want to add to the Zeus list

Return Values:
	Compiled message for internal handling

Examples:
    Nothing to see here

Author:
	Martin
*/

#include "..\defines.h"

params ["_owner", "_caller", "_argStr"];

private _ret = nil;
private _log = nil;

if (_argStr isEqualTo "") then {
    _ret = "Usage: #addzeus <Player Name>";
    _log = "invalid syntax";
} else {

    private _p = [_argStr] call FNC(findPlayer);

    if (_p isEqualTo []) then {
        _ret = format["no player matching %1", _pn];
    } else {
        if !(count _p isEqualTo 1) then {
            _ret = format ["too many matches for prefix %1", _pn];
        } else {
            private _newZeus = _p select 0;
            private _idx = (YVAR(ownerIDs) select 0) find (owner _newZeus);
            if (_idx isEqualTo -1) then {
                _ret = format["couldn't find %1 in ownerIDs", name _newZeus];
            } else {
                private _uid = getPlayerUID _newZeus;

                _ret = format ["zeus allowed for %1 (%2)", name _newZeus, _uid];

                // Also update the zeuslist array
                private _idx = (YVAR(zeuslist) select 0) find _uid;
                if(_idx isEqualTo -1) then {
                    (YVAR(zeuslist) select 0) pushBack _uid;
                    (YVAR(zeuslist) select 1) pushBack (name _newZeus);

                    // And let them know
                    "You have been granted temporary access to the zeus slot" remoteExec ["systemChat", owner _newZeus];
                };
            };
        };
    };
};

if !(isNil "_ret") then {
    _ret remoteExecCall ["systemChat", _owner];
};

if (isNil "_log" && { not isNil "_ret" }) then {
    _log = _ret;
};

_log;
