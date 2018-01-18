/*
	author: MartinCo
	description: none
	returns: nothing
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