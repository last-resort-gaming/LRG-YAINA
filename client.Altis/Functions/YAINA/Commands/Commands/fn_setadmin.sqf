/*
	author: Martin
	description: none
	returns: nothing
*/

#include "..\defines.h"

params ["_owner", "_caller", "_argStr"];

private _ret = nil;
private _log = nil;
private _argSplit = _argStr splitString " ";
private _lvl = _argSplit deleteAt 0;
private _lvln = parseNumber _lvl;

if (_argStr isEqualTo "" || { _argSplit isEqualTo [] } || { not ((str _lvln) isEqualTo _lvl) }) then {
    _ret = "Usage: #addadmin <admin level> <Player Nmae>";
    _log = "invalid syntax";
} else {

    private _pn = _argStr select [count _lvl + 1];
    private _p = [_pn] call FNC(findPlayer);

    if (_p isEqualTo []) then {
        _ret = format["no player matching %1", _pn];
    } else {
        if !(count _p isEqualTo 1) then {
            _ret = format ["too many matches for prefix %1", _pn];
        } else {
            private _newAdmin = _p select 0;
            private _idx = (YVAR(ownerIDs) select 0) find (owner _newAdmin);
            if (_idx isEqualTo -1) then {
                _ret = format["couldn't find %1 in ownerIDs", name _newAdmin];
            } else {
                private _uid = getPlayerUID _newAdmin;

                _ret = format ["admin level set to %1 for %2 (%3)", _lvl, name _newAdmin, _uid];
                ((YVAR(ownerIDs) select 1) select _idx) set [3, _lvln];

                // Also update the admins array
                private _idx = (YVAR(admins) select 0) find _uid;
                if(_idx isEqualTo -1) then {
                    (YVAR(admins) select 0) pushBack _uid;
                    (YVAR(admins) select 1) pushBack _lvln;
                } else {
                    (YVAR(admins) select 1) set [_idx, _lvln];
                };

                // Save the DB
                ["write", ["general", "admins", YVAR(admins)]] call YVAR(inidbi);

                // Update the vars (used for radio comms really)
                _newAdmin setVariable ["YAINA_adminLevel", _lvln, true];

                // And let them know
                format["Your admin level has been changed to %1", _lvln] remoteExec ["systemChat", owner _newAdmin];
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
