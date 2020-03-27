/*
Function: YAINA_fnc_kickSelf

Description:
	Kicks the player on which this command is run from the server,
	logging the given message to the server.

Parameters:
	_msg - Message to be displayed in the server log

Return Values:
	None

Examples:
    Nothing to see here

Author:
	Martin
*/

#include "defines.h"

params ["_msg"];

if !(isServer) exitWith {};
if (remoteExecutedOwner isEqualTo 0) exitWith {};

private _tmp = (allPlayers select { owner _x isEqualTo remoteExecutedOwner } );
if (_tmp isEqualTo []) exitWith {};

private _caller = _tmp select 0;
private _calleruid = getPlayerUID _caller;

// Log it as a report since we shouldn't be self-kicking for no reason
[format ["action=PERMIT, command=report, uid=%1, player=%2, msg=%3", _calleruid, name _caller, _msg], "CommandsLog"] call YFNC(log);

SERVER_COMMAND_PASSWORD serverCommand format ["#kick %1", _calleruid];