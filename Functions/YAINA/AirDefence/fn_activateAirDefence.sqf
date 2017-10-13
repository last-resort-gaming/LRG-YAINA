/*
	author: Martin
	description: none
	returns: nothing
*/

#include "defines.h"
//--------------------------------------------------------------

_activeTime   = 300;  // Time it'll remain online
_rechargeTime = 600; // How long it takes between activations
_delay        = 5;   // Delay before it's online

//--------------------------------------------------------------

if (!isServer) exitWith {
    remoteExecCall [Q(FNC(activateAirDefence)), 2];
};

_currentTime   = diag_tickTime;
_nextAvailable = _activeTime + _rechargeTime + _delay;

// Can we ?
if(_currentTime < GVAR(nextActive)) exitWith {

    if (GVAR(online)) exitWith {-1};
    GVAR(nextActive) - diag_tickTime;

};

GVAR(nextActive) = _currentTime + _nextAvailable;
GVAR(online) = true;

// Hint to everyone to let them know AD coming online
if !(_delay isEqualTo 0) then {
    "Air defense network coming online..." remoteExecCall ["hint", 0];
};

// Hint to let them know when it's back online
[{
    "Air defense network is now available" remoteExecCall ["hint", 0];
}, [], _nextAvailable] call CBA_fnc_waitAndExecute;

// Now we wait the dealy
[{
    params ["_activeTime"];

    _groups = [];

    // Add Crew to vehicles, set them to combat
    {
        createVehicleCrew _x;
        _id = _groups pushBack (group (crew _x select 0));
        _gr = _groups select _id;
        _gr setBehaviour "COMBAT";
        _gr setCombatMode "RED";
        true;
    } count AIR_DEFENCES;

    "Air defense network is now online" remoteExecCall ["hint", 0];

    // Now we stay online for the duration, and cleanup
    [{
        GVAR(online) = false;

        params ["_groups"];

        {
            { deleteVehicle _x; true; } count (units _x);
            deleteGroup _x;
            true;
        } count _groups;

        "Air defence network now offline" remoteExec ["hint", 0];
    }, [_groups], _activeTime] call CBA_fnc_waitAndExecute;

}, [_activeTime], _delay] call CBA_fnc_waitAndExecute;

0;