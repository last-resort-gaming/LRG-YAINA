/*
	author: Martin
	description: none
	returns: nothing
*/

#include "..\defines.h"

params ["_owner", "_caller", "_argStr"];

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
            _msg = format["%1, please join a section and request your squad leader to arrange you transport - alternatively, start a group and request transport when you have at least 4 members.", name (_p select 0)];

            // In addition to side chat, hintC it so they can't say they didn't see it
            _msg remoteExec [QYFNC(hintC), _p select 0];
            _ret = format ["ugmsg sent to %1", name (_p select 0)];
        };
    };
} else {
    _msg = "Could all ungrouped players back at base please join an existing section and request your new squad lead for transport, or start a new section and request transport once you have at least 4 members";
    _ret = "General ugmsg sent";

};

if !(isNil "_msg") then {
    [[west, "HQ"], _msg] remoteExec ["sideChat"];
};

_ret