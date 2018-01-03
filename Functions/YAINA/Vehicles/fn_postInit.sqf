/*
	author: Martin
	description: none
	returns: nothing
*/

#include "defines.h"

if(isServer) then {

    [] call FNC(respawnPFH);

    // And unlock all the players vehicles on DC
    addMissionEventHandler ["HandleDisconnect", { [_this select 0, nil, "remove"] call FNC(updateOwnership) } ];

};

if(hasInterface) then {

    // And we need a respawn handler to add back in the player actioon for unlcoking all vehicles
    player addEventHandler ["Respawn", {
        call FNC(updatePlayerActions);
    }];

    player addEventHandler ["GetInMan", FNC(getInMan)];

    // Whilst adding it to Engine is nicer, you could get greifing with players refusing to get out
    // So lets just add it to getIn / seat changed and force eject them from the vehicle.
    player addEventHandler ["SeatSwitchedMan", {

        params ["_unit1", "_unit2", "_veh"];

        _assRole   = assignedVehicleRole player;
        if(_assRole isEqualTo []) exitWith {};

        _playerPos = _assRole select 0;
        _turretPos = [];

        if (_playerPos isEqualTo "Turret") then {
           _playerPos = "gunner";
           _turretPos = _assRole select 1;
        };

        // And if we're still in, call our standard GetInMan handler too
        [player, _playerPos, _veh, _turretPos] call FNC(getInMan);

    }];

};