/*
	author: Martin
	description: none
	returns: nothing
*/

#include "..\defines.h"

private _paraDropItems = [
    paradrop1
];

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

// We also allow the player to drop
player addAction [
    ("<t color=""#ED2744"">") + ("Parachute") + "</t>",
    {call FNC(openShoot)}, [], 10, false, true,"",
    "(((position _target) select 2) > 20) && (_target == (vehicle _target))"
];

// And they're not falling by default
GVAR(openShootInProgress) = false;

// We set up a PFH every 30 seconds to check if pilots are online
// If they are, we change the texture
if (isServer) then {
    [{
        params ["_args", "_pfhID"];
        _args params ["_paraDropItems"];

        _pCount        = { _x getUnitTrait "YAINA_PILOT" } count allPlayers;
        _targetTexture = ["Data\Billboards\section1.paa", "Data\Billboards\section3.paa"] select (_pCount > 0);
        {
            _x setObjectTextureGlobal [0, _targetTexture];
        } forEach _paraDropItems;

    }, 30, [_paraDropItems]] call CBA_fnc_addPerFrameHandler;
}