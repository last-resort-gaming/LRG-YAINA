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

    addMissionEventHandler["Map", {
        params ["_mapOpen", "_mapIsForced"];

        if (_mapOpen) then {

            // If it already exists, dont do anything
            if !(isNil QVAR(pfhID)) exitWith {};

            GVAR(pfhID) = [{

                // VEH Markers
                _markers = [];
                _markersFor = (units (group player)) apply { [_x, 1] };

                // If the map is shut just skip this
                if (visibleMap) then {

                    // HQ can see everyones vehicle
                    if (["HQ", "veh-lock-markers"] call YFNC(testTraits)) then {
                        _markersFor = allPlayers apply { [_x, [0.25,1] select ((group _x) isEqualTo (group player)) ] };
                    };

                    {
                        _x params ["_p", "_a"];
                        _pids = _p getVariable [QVAR(vehicles), []];
                        {
                            _id = _x call BIS_fnc_objectVar;
                            _md = format["%1_%2", QVAR(mrk), _id];
                            _markers pushBack _md;

                            if ((getMarkerPos _md) isEqualTo [0,0,0]) then {
                                createMarkerLocal [_md, position _x];
                                _md setMarkerShapeLocal "ICON";
                                _md setMarkerTypeLocal "mil_triangle";
                                _md setMarkerTextLocal format["%1's %2", name _p, getText(configFile >> "CfgVehicles" >> typeOf (_x) >> "displayName")];
                                _md setMarkerAlphaLocal _a;
                            };

                            _md setMarkerPosLocal (position _x);

                        } forEach _pids;
                    } forEach _markersFor;
                };

                // Delete any markers that don't belong to our group / given up keys for
                { if !(_x in _markers) then { deleteMarkerLocal _x; }; true; } count ([QVAR(mrk)] call FNC(getMarkers));

            }, 0, []] call CBAP_fnc_addPerFrameHandler;
        } else {
            // Delete our PFH and vehicle markers
            [GVAR(pfhID)] call CBAP_fnc_removePerFrameHandler;
            GVAR(pfhID) = nil;
            { deleteMarkerLocal _x; true; } count ([QVAR(mrk)] call FNC(getMarkers));
        };
    }];
};