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
            _pActive       = ({ _x getUnitTrait "YAINA_PILOT" } count allPlayers isEqualTo 0 && !(GVAR(paradropMarkers) isEqualTo []));
            _targetTexture = ["Data\Billboards\paradropInac.paa", "Data\Billboards\paradropAct.paa"] select _pActive;
            {
                _x setObjectTextureGlobal [0, _targetTexture];
            } forEach _paraDropItems;

        }, 30, [_paraDropItems]] call CBA_fnc_addPerFrameHandler;
    };

    player addEventHandler ["Respawn", {
        call FNC(setupParadropActions);
    }];

    GVAR(paradropSetup) = true;
};

// And they're not falling by default
GVAR(openChuteInProgress) = false;

// We also allow the player to drop
player addAction [
    ("<t color=""#ED2744"">") + ("Open Parachute") + "</t>",
    {call FNC(openChute)}, [], 10, false, true,"",
    "(((position _target) select 2) > 20) && (_target == (vehicle _target))"
];
