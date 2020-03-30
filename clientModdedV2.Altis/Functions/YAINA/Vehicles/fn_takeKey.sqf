/*
Function: YAINA_VEH_fnc_takeKey

Description:
	Assume ownership of a vehicle and obtain its keys, if possible.
	Creates the marker, and allows the player that took the vehicle's
	keys to (un)lock the vehicle.

Parameters:
	_target - The player to which the keys shall be given
	_caller - The player that executed this function
	_id - The key ID for identification, unused
	_arguments - Arguments passed, unused

Return Values:
	None

Examples:
    Nothing to see here

Author:
	Martin
*/

#include "defines.h"

params ["_target", "_caller", "_id", "_arguments"];

if !(_caller isEqualTo player) exitWith {};

// We set the owner to be the _caller, and create a map marker name;
_target setVariable [QVAR(owner), _caller call BIS_fnc_objectVar, true];

// Update the server's knowledge of who owns what (unlock on disconnect etc)
[_caller, _target, "add"] remoteExec [QFNC(updateOwnership), 2];

// And add to our vehicle list
GVAR(myVehicles) pushBackUnique _target;

// And finally update the "Drop all Keys" action to reflect the locked vehicle count
call FNC(updatePlayerActions);

systemChat "You've taken the keys...";