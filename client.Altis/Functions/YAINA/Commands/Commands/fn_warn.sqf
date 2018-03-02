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
    _ret = "Usage: #warn <Player Nmae>";
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

            _idx  = (YVAR(warnings) select 0) find _playeruid;
            _warn = 1;
            if !(_idx isEqualTo -1) then {
                _warn = (YVAR(warnings) select 1 select _idx) + 1;
                (YVAR(warnings) select 1) set [_idx, _warn];
            } else {
                (YVAR(warnings) select 0) pushBack _playeruid;
                (YVAR(warnings) select 1) pushBack _warn;
            };

            _title   = "First Warning";
            _content = "This is an official warning!<br/><br/>You must follow the server rules and any requests from admins.<br/><br/>Do you agree ?";

            if(_warn > 1) then {
                _title   = "Final Warning";
                _content = "This is your final offical warning.<br/><br/>You must follow the rules, any further infractions will result in you being removed from the server.<br/><br/>Do you acknowledge?";
            };

            if(_warn > 2) then {
                // We just kick + log
                _log = format["%1 (%2) exceeded warn limit => %3", name _player, _playeruid, _warn];
                SERVER_COMMAND_PASSWORD serverCommand format ["#kick %1", _playeruid];
                [_caller, format["%1 has been kicked for exceeding the warning limit: %2)", name _player, _warn], 4] call FNC(notifyAdmins);
            } else {
                [[_title, _content], {
                    params ["_title", "_content"];
                    _result = [_content, _title, "YES", "NO"] call BIS_fnc_guiMessage;
                    if !(_result) then {
                        [format["Disagreed to their %s", toLower _title]] remoteExecCall ["YAINA_fnc_kickSelf", 2];
                    };
                }] remoteExec ["spawn", _player];

                // Let admins know
                [_caller, format["has been given their %1 (total: %2)", toLower _title, _warn], 4] call FNC(notifyAdmins);
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