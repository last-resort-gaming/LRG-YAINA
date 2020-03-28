/*
Function: YAINA_VEH_fnc_postInit

Description:
	Handles initialization of the vehicle sub-system during the postInit
    stage. Mainly concerned with setting up the necessary event handlers
    and variables.

Parameters:
	None

Return Values:
	None

Examples:
    Nothing to see here

Author:
	Martin
*/

#include "defines.h"

if(isServer) then {

    // Somewhere to store what's been locked
    GVAR(vehLocks) = [[], []];

    [] call FNC(respawnPFH);

    // And unlock all the players vehicles on DC
    addMissionEventHandler ["HandleDisconnect", {
        params ["_unit", "_id", "_uid", "_name"];

        [_unit, nil, "remove"] call FNC(updateOwnership);

        // Reset Vehicle Locks ?
        _idx = (GVAR(vehLocks) select 0) find _uid;
        if !(_idx isEqualTo -1) then {
            (GVAR(vehLocks) select 0) deleteAt _idx;
            _resetList = (GVAR(vehLocks) select 1) deleteAt _idx;

            {
                // We only reset lock vehicles in the base area, if no players
                // are currently inside it and it's alive...
                if (
                    alive _x
                    && { _x call YFNC(inBaseProtectionArea) }
                    && { ( { alive _x } count (crew _x) ) isEqualTo 0 }
                ) then {
                    _lock = _x getVariable QVAR(defaultLock);
                    if !(isNil "_lock") then {
                        [_x, _lock] remoteExec ["lock", owner _x];
                    };
                };
                nil;
            } count _resetList;
        };
    }];

    // Log locked/unlocked actions by HQ
    ["VehicleLock", {
        params ["_by", "_obj", "_newState"];

        _action   = ["locked", "unlocked"] select (_newState isEqualTo 0);
        _uid      = getPlayerUID _by;

        // If they don't have the veh-unlock action, then it's HQ
        // If so, we add it to the list for the disconnect handler
        if !([['veh-unlock'], _by] call YFNC(testTraits)) then {
            _idx = (GVAR(vehLocks) select 0) find _uid;
            if (_idx isEqualTo -1) then {
                (GVAR(vehLocks) select 0) pushBack _uid;
                (GVAR(vehLocks) select 1) pushBack [_obj];
            } else {
                ((GVAR(vehLocks) select 1) select _idx) pushBackUnique _obj;
            };
        };

        // Log the event
        [format["action=PERMIT, command=%1, player=%2, playeruid=%3, vehicle=%4", _action, name _by, _uid, typeOf _obj], "CommandsLog"] call YFNC(log);

    }] call CBA_fnc_addEventHandler;

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

            }, 0, []] call CBA_fnc_addPerFrameHandler;
        } else {
            // Delete our PFH and vehicle markers
            [GVAR(pfhID)] call CBA_fnc_removePerFrameHandler;
            GVAR(pfhID) = nil;
            { deleteMarkerLocal _x; true; } count ([QVAR(mrk)] call FNC(getMarkers));
        };
    }];

    // Lock Event Handler
    ["VehicleLock", {
        params ["_by", "_obj", "_newState"];
        private _id = _obj getVariable QVAR(lockActionID);
        if !(isNil "_id") then {
            _obj setUserActionText [_id, ["Unlock Vehicle", "Lock Vehicle"] select (_newState isEqualTo 0)];
        };
    }] call CBA_fnc_addEventHandler;
};