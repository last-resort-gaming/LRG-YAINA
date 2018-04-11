/*
	author: Martin
	description: none
	returns: nothing
*/

#include "..\defines.h"

private _paraDropItems = [
    paradrop1
];

if (isNil QVAR(paradropSetup)) then {

    // Override
    GVAR(paradropOverride) = 0;
    GVAR(paradropEnabled)  = false;
    publicVariable QVAR(paradropEnabled);

    {
       _x addAction [
           "Paradrop on AO",
           { call FNC(paraDrop); },
           nil,
           101,
           false,
           true,
           "",
           "true",
           5,
           false
       ];
    } forEach _paraDropItems;

    // We set up a PFH every 30 seconds to check if pilots are online
    // If they are, we change the texture
    if (isServer) then {
        [{
            params ["_args", "_pfhID"];
            _args params ["_paraDropItems"];

            _active = (
                          (
                              { [["PILOT"], _x] call YFNC(testTraits) } count allPlayers isEqualTo 0
                              || { LTIME < GVAR(paradropOverride) }
                          )
                          && { !(GVAR(paradropMarkers) isEqualTo []) }
                      );

            // Update clients
            if !(_active isEqualTo GVAR(paradropEnabled)) then {
                GVAR(paradropEnabled) = _active;
                publicVariable QVAR(paradropEnabled);
            };

            // Always set tex so
            _targetTexture = ["Data\Billboards\paradropInac.paa", "Data\Billboards\paradropAct.paa"] select _active;
            {
                _x setObjectTextureGlobal [0, _targetTexture];
            } forEach _paraDropItems;

        }, 10, [_paraDropItems]] call CBAP_fnc_addPerFrameHandler;
    };
    GVAR(paradropSetup) = true;
};