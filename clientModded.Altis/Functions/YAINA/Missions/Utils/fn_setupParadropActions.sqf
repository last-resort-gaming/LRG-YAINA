/*
Function: YAINA_MM_fnc_setupParadropActions

Description:
	Handles initialization of the paradrop actions during the postInit
    phase. This sets up the interaction options and test conditions.

Parameters:
	None

Return Values:
	None

Examples:
    Nothing to see here

Author:
	Martin
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
                              {
                                [["PILOT"], _x] call YFNC(testTraits)
                                && {
                                    vehicle _x isEqualTo _x
                                    || {
                                        driver (vehicle _x) isEqualTo _x
                                        && { !(getNumber (configFile >> "CfgVehicles" >> typeOf (vehicle _x) >> "transportSoldier") isEqualTo 0) }
                                    }
                                }
                              } count allPlayers isEqualTo 0
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
            _targetTexture = ["z\LRG Fundamentals\Addons\Media\images\Public Server\paradropInac.paa", "z\LRG Fundamentals\Addons\Media\images\Public Server\paradropAct.paa"] select _active;
            {
                _x setObjectTextureGlobal [0, _targetTexture];
            } forEach _paraDropItems;

        }, 10, [_paraDropItems]] call CBA_fnc_addPerFrameHandler;
    };
    GVAR(paradropSetup) = true;
};