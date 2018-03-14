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

            // Active if we have pilots online, and there is somewhere to drop onto
            _pActive       = ({ [["PILOT"], _x] call YFNC(testTraits) } count allPlayers isEqualTo 0 && !(GVAR(paradropMarkers) isEqualTo []));
            _targetTexture = ["Data\Billboards\paradropInac.paa", "Data\Billboards\paradropAct.paa"] select _pActive;
            {
                _x setObjectTextureGlobal [0, _targetTexture];
            } forEach _paraDropItems;

        }, 10, [_paraDropItems]] call CBAP_fnc_addPerFrameHandler;
    };
    GVAR(paradropSetup) = true;
};