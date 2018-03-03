/*
	author: Martin
	description: none
	returns: nothing
*/

#include "..\defines.h"

params ["_owner", "_caller", "_argStr"];

private _ret = nil;
private _log = nil;

if (_argStr isEqualTo "") then {
    _ret = "Usage: #kick <Player Nmae>";
    _log = "invalid syntax";
} else {

    private _p = [_argStr] call FNC(findPlayer);

    if (_p isEqualTo []) then {
        _ret = format["no player matching %1", _pn];
    } else {
        if !(count _p isEqualTo 1) then {
            _ret = format ["too many matches for prefix %1", _pn];
        } else {

            _player    = _p select 0;
            _playeruid = getPlayerUID _player;

            [["You're getting kicked", "The severity of your actions has resulted in an admin immediately kicking you.<br/><br/>If you feel this was unreasonable, please file a complaint on our website: http://lastresortgaming.net"], {
                params ["_title", "_content"];

                // We schedule a kick in 7 seconds so they have enough time to read it, in case they're not
                // actually closing the dialog and go on a rager
                [{
                    ["!kick timedout"] remoteExecCall ["YAINA_fnc_kickSelf", 2];
                }, [], 7] call CBAP_fnc_waitAndExecute;

                _result = [_content, _title, "YES", false] call BIS_fnc_guiMessage;
                ["Accepted their !kick"] remoteExecCall ["YAINA_fnc_kickSelf", 2];
            }] remoteExec ["spawn", _player];

            // increase the warning count by 3 (as 3 warnings) - this is so they get the join message, and any
            // further warning is an immediate kick
            _idx  = (YVAR(warnings) select 0) find _playeruid;
            if !(_idx isEqualTo -1) then {
                _warn = (YVAR(warnings) select 1 select _idx) + 3;
                (YVAR(warnings) select 1) set [_idx, _warn];
            } else {
                (YVAR(warnings) select 0) pushBack _playeruid;
                (YVAR(warnings) select 1) pushBack 3;
            };

            _log = format["%1 (%2) was kicked", name _player, _playeruid];

            // Let Admins know
            [_caller, format["I have kicked: %1", name _player], 4] call FNC(notifyAdmins);
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
