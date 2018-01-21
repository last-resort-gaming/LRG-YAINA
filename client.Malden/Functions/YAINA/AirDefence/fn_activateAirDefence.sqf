/*
	author: Martin
	description: none
	returns: nothing
*/

#include "defines.h"

if (!isServer) exitWith {
    [] remoteExecCall [QFNC(activateAirDefence), 2];
};

//--------------------------------------------------------------

_activeTime   = 30;  // Time it'll remain online
_rechargeTime = 300; // How long it takes between activations
_delay        = 10;  // Delay before it's online

//--------------------------------------------------------------

if (!isServer) exitWith {
    remoteExecCall [Q(FNC(activateAirDefence)), 2];
};

_currentTime   = [diag_tickTime, serverTime] select isMultiplayer;
_nextAvailable = _activeTime + _rechargeTime + _delay;

// Can we ?
if(_currentTime < GVAR(nextActive)) exitWith {};

GVAR(nextActive) = _currentTime + _nextAvailable;
GVAR(online) = true;
publicVariable Q(GVAR(nextActive));
publicVariable Q(GVAR(online));

// Hint to everyone to let them know AD coming online
if !(_delay isEqualTo 0) then {
    "Air defense network coming online..." remoteExecCall ["hint", 0];
};

// Hint to let them know when it's back online
[{
    "Air defense network is now available" remoteExecCall ["hint", 0];
}, [], _nextAvailable] call CBAP_fnc_waitAndExecute;

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
        publicVariable Q(GVAR(online));

        params ["_groups"];

        {
            { deleteVehicle _x; true; } count (units _x);
            deleteGroup _x;
            true;
        } count _groups;

        "Air defence network now offline" remoteExec ["hint", 0];
    }, [_groups], _activeTime] call CBAP_fnc_waitAndExecute;

}, [_activeTime], _delay] call CBAP_fnc_waitAndExecute;

0;