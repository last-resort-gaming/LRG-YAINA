/*
	author: Martin
	description: none
	returns: nothing
*/


#include "..\defines.h"

params ["_command", "_argument"];

if !(isServer) exitWith {};
if (remoteExecutedOwner isEqualTo 0) exitWith {};

private _tmp = (allPlayers select { owner _x isEqualTo remoteExecutedOwner } );
if (_tmp isEqualTo []) exitWith {};

private _caller    = _tmp select 0;

private _idx = GVAR(commands) select 0 find _command;
if (_idx isEqualTo -1) exitWith {
    [_caller, _command, false, "INVALID COMMAND"] call FNC(log);
};

private _lvl = (GVAR(commands) select 1) select _idx;
if !([_caller, _lvl] call FNC(allowed)) exitWith {
    [_caller, _command, false, "NOT PERMITTED"] call FNC(log);
};

// Split duplicate spaces
_argument = _argument splitString " " joinString " ";

// Finally, execute the command, returning the log line
private _msg = [remoteExecutedOwner, _caller, _argument] call (missionNamespace getVariable [format["YAINA_CMD_fnc_%1", _command], {}]);
[_caller, _command, true, _msg] call FNC(log);