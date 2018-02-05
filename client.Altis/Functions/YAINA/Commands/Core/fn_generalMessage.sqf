/*
	author: Martin
	description: none
	returns: nothing
*/

#include "..\defines.h"

params ["_args", "_type", "_messageIndividual", "_messageGeneral"];


_args params ["_owner", "_caller", "_argStr"];

_msg = nil;
_ret = "";

if (!(_argStr isEqualTo "") && { !(isNil "_messageIndividual") }) then {
    _p = [_argStr] call FNC(findPlayer);
    if (_p isEqualTo []) then {
        _ret = format["no player matching %1", _argStr];
        _ret remoteExec ["systemChat", _owner];
    } else {
        if !(count _p isEqualTo 1) then {
            _ret = format ["too many matches for prefix %1", _argStr];
            _ret remoteExec ["systemChat", _owner];
        } else {
            _msg = format[_messageIndividual, name (_p select 0)];

            // In addition to side chat, hintC it so they can't say they didn't see it
            _msg remoteExec [QYFNC(hintC), _p select 0];
            _ret = format ["%1 sent to %2", _type, name (_p select 0)];
        };
    };
} else {
    if (isNil "_messageGeneral") then {
        _ret = format ["This command requires a player argument"];
        _ret remoteExec ["systemChat", _owner];
    } else {
        _msg = _messageGeneral;
        _ret = format["General %1 sent", _type];
    };
};

if !(isNil "_msg") then {
    [[west, "HQ"], _msg] remoteExec ["sideChat"];
};

_ret