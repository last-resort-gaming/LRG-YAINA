/*
	author: Martin
	description: none
	returns: nothing
*/

#include "defines.h"

if (isServer) then {

    // We don't allow Air defences for the first 300 seconds due to
    // the value on the server being out of sync: https://community.bistudio.com/wiki/serverTime

    GVAR(nextActive) = 300;
    GVAR(online) = false;
    publicVariable Q(GVAR(nextActive));
    publicVariable Q(GVAR(online));

    // Lock and delete any crew in there
    {
        _x lock 2;
        _x allowDamage false;
        { deleteVehicle _x; } count crew _x;
        true;
    } count AIR_DEFENCES;

    // Hint to let them know when it's available
    [{
        "Air defense network is now available" remoteExecCall ["hint", 0];
    }, [], 300] call CBA_fnc_waitAndExecute;

};

// Set action on air Defence Terminals
{
    _x addAction ["<t color='#ff1111'>Activate Air-Defense Network</t>",
    {

        if(GVAR(online)) exitWith {
            hint "Air Defence Network is already online";
        };

        _currentTime = [diag_tickTime, serverTime] select isMultiplayer;
        _nextAD      = GVAR(nextActive) - _currentTime;

        if (_nextAD <= 0) exitWith {
            call FNC(activateAirDefence);
        };

        hint format ["Air defence network will be available in %1", _nextAD call YFNC(formatDuration)];
    }];
    true;
} count AIR_DEFENCE_TERMINALS;
