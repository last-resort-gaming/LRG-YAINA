/*
	author: Martin
	description: none
	returns: nothing
*/

#include "defines.h"

if (isServer) then {
    // Ensure Zeus keeps slot, despite admin logging
    [{
        {
            _x params ["_player", "_mod"];

            // they're fucked, so we have to free up our dedicated curator
            if(isPlayer _player && { isNull getAssignedCuratorLogic _player } ) then {
                // If it thinks it assigned, unassig
                if !(isNull (getAssignedCuratorUnit _mod)) then {
                    unassignCurator _mod;
                } else {
                    _player assignCurator _mod;
                };
            };
            nil
        } count [
            [zeus1, zeus1mod],
            [zeus2,zeus2mod]
        ];
    }, 2, []] call CBAP_fnc_addPerFrameHandler;
};

if !(side player isEqualTo sideLogic && { typeOf player isEqualTo "VirtualCurator_F" } ) exitWith {};

// we spawn here to esnure we have a display

[] spawn {

    // Delay until the server time has sync'd
    waitUntil {time > 5};
    // For JIP, wait until the main screen loads
    waitUntil {!isNull (findDisplay 46) };

    [player] remoteExecCall [QFNC(zeusConnected), 2];

};