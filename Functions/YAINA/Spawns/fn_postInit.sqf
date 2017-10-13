/*
	author: Martin
	description: none
	returns: nothing
*/

#include "defines.h"

if(hasInterface) then {

    // And we need a respawn handler to add back in the player actioon for unlcoking all vehicles
    player addAction ["Spawn Enemy Air flyby", {

        _spawnPos = [position player] call FNC(getAirSpawnPos);

        _air  = createVehicle ["O_Plane_Fighter_02_F", _spawnPos, [], 0, "FLY" ];
        _crew = createVehicleCrew _air;

        _group = createGroup EAST;

        _pilot = _group createUnit ['O_Fighter_Pilot_F', _spawnPos, [], 300, 'CAN_COLLIDE'];
        _pilot setRank 'PRIVATE';

        _pilot moveInDriver _air;

        _wp1 = _group addWaypoint [position player, 0];
        _wp1 setWaypointSpeed "FULL";


        [[_air], true] call YFNC(addEditableObjects);

    }];

};