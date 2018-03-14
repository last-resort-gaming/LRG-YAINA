/*
	author: Martin
	description: none
	returns: nothing
*/

#include "..\defines.h";

// If they have the action disabled, let them know why...
private _np = player getVariable QYVAR(noPara);
if !(isNil "_np") exitWith {
    systemChat format ["Unable to deply parachute: %1", _np];
};

// Fade out, jump into a parachute, and fade back in
[{

    // If you're that close to the ground, you're gonna die
    if ((getPosATL player select 2) < 20) exitWith {};

    if !((vehicle player) isEqualTo player) then {
        moveOut player;
    };

    // Spawn the chute, and get in it
    private _chute = createVehicle ["Steerable_Parachute_F", (getPos player), [], 0, "NONE"];
    _chute setPos (getPos player);
    player moveInDriver _chute;

    // Now, setup to remove the chute when we're on the ground
    [
        {isNull (_this select 0) || isTouchingGround (vehicle (_this select 0))},
        {
            params ["_player", "_chute"];

            if !(isNull player) then {
                if ((vehicle _player) isEqualTo _chute) then {
                    moveOut _player;
                };
            };
            deleteVehicle _chute;
        },
        [player, _chute]
    ] call CBAP_fnc_waitUntilAndExecute;
}, [], 0.5, 1] call YFNC(fadeOutAndExecute);