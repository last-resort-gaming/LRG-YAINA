/*
Function: YAINA_CMD_fnc_generalMessage

Description:
	Main formatting module for messages sent using commands.
    Allows sending messages to all or specfic players.
    Supplied _args array must contain the following information:

    _owner - The player sending the message to the general public or an individual
    _caller - The player having called this function (not used)
    _argStr - The target of the message, in case we are only messaging an individual

Parameters:
	_args - Arguments array containing meta information (see above)
    _type - The type of message sent (eg. abusemsg...)
    _messageIndividual - Message to be sent to one individual (declared in _args)
    _messageGeneral - Message to be sent to the general public

Return Values:
	Formatted string for logging, information on the type of 
    message sent (and to whom).

Examples:
    Nothing to see here

Author:
	Martin
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