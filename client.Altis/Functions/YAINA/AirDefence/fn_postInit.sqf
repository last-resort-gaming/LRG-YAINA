/*
Function: YAINA_AD_fnc_postInit

Description:
	Sets up the Base Air Defence during the postInit stage.
    The setup initializes the laptops at base.

Parameters:
	None

Return Values:
	None

Examples:
    Nothing to see here

Author:
	Martin
*/

#include "defines.h"

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
            remoteExecCall [QFNC(activateAirDefence), 2];
        };

        hint format ["Air defence network will be available in %1", _nextAD call YFNC(formatDuration)];
    }];
    true;
} count AIR_DEFENCES_TERMINALS;
