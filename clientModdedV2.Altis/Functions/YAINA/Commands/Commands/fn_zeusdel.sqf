/*
Function: YAINA_CMD_fnc_zeusdel

Description:
	Remove given player from the Zeus whitelist.

Parameters:
	_owner - The owner of the player object that called this command
    _caller - Not used
    _argStr - The player we want to remove from the Zeus list

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
    _ret = "Usage: #zeusdel (<Player Nmae>|<Player UID>)";
    _log = "invalid syntax";
} else {

    private _p = [_argStr] call FNC(findPlayer);

    if (_p isEqualTo []) then {
        // Then could be a  UID
        _idx = (YVAR(zeuslist) select 0) find _argStr;
        if (_idx isEqualTo -1) then {
            _ret = format["no player matching %1", _argStr];
        } else {
            _ret = format["%1 has had zeus removed", (YVAR(zeuslist) select 1) deleteAt _idx];
            (YVAR(zeuslist) select 0) deleteAt _idx;
            (YVAR(zeuslist) select 1) deleteAt _idx;
        };
    } else {
        if !(count _p isEqualTo 1) then {
            _ret = format ["too many matches for prefix %1", _pn];
        } else {
            private _oldZeus = _p select 0;
            private _idx = (YVAR(ownerIDs) select 0) find (owner _oldZeus);
            if (_idx isEqualTo -1) then {
                _ret = format["couldn't find %1 in ownerIDs", name _oldZeus];
            } else {
                private _uid = getPlayerUID _oldZeus;


                // Also update the zeuslist array
                private _idx = (YVAR(zeuslist) select 0) find _uid;
                if (_idx isEqualTo -1) then {
                    _ret = format ["%1 does not have zeus", name _oldZeus];
                } else {
                    _ret = format ["%1 has had their zeus removed", name _oldZeus];


                    (YVAR(zeuslist) select 0) deleteAt _idx;
                    (YVAR(zeuslist) select 1) deleteAt _idx;

                    // If they are currently online in that slot, kick them
                    if (typeOf _oldZeus isEqualTo "VirtualCurator_F") then {
                        SERVER_COMMAND_PASSWORD serverCommand format ['#kick %1', getPLayerUID _oldZeus];
                    };

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
