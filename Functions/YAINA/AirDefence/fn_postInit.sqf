/*
	author: Martin
	description: none
	returns: nothing
*/

#include "defines.h"


AIR_DEFENCES = [];
AIR_DEFENCES_TERMINALS = [];

if (worldName isEqualTo "Malden") then {
    AIR_DEFENCES = [
        HQ_AA1C,
        HQ_AA2C,
        HQ_AA3C,
        HQ_AA4C,
        USS_AA1,
        USS_AA2,
        USS_AA3,
        USS_AA4,
        USS_AA5,
        USS_AA6,
        USS_AA7,
        INS_AA1C,
        INS_AA2C
    ];

    AIR_DEFENCES_TERMINALS = [
        AirDefenceSwitch1,
        AirDefenceSwitch2,
        Laptop_USS_F
    ];
};

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
} count AIR_DEFENCES_TERMINALS;
