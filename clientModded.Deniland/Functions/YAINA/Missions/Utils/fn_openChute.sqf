/*
Function: YAINA_MM_fnc_openChute

Description:
	Place local player in parachute,force open the chute 
    for the local player and delete it again once they are on the ground

Parameters:
	None

Return Values:
	None

Examples:
    Nothing to see here

Author:
	Martin
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

    // This isn't instant in MP, so, we sleep on it
    if !((vehicle player) isEqualTo player) then {
        moveOut player;
    };

    // We always add a bit of sleep here to add to the delay
    sleep 0.5;

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
    ] call CBA_fnc_waitUntilAndExecute;
}, [], 0.5, 0.5] call YFNC(fadeOutAndExecute);