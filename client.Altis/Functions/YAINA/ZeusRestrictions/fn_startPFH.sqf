/*
Function: YAINA_ZEUS_fnc_startPFH

Description:
	Starts the necessary per-frame event handlers for enforcing
    the Zeus restrictions and keeping stuff clean.

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

// Only run if we haven't already started
if !(isNil QVAR(PFH)) exitWith {};
GVAR(PFH) = true;

GVAR(objectsDeleted) = [];
GVAR(objectsPlaced)  = [];
GVAR(prefix) = ((name player) splitString "-,. ") joinString "";


// Now every 5 seconds, we process the objects that have already been placed
[{

    _queue = GVAR(objectsPlaced);
    GVAR(objectsPlaced) = [];

    _delqueue = GVAR(objectsDeleted);
    GVAR(objectsDeleted) = [];

    // We add all to zeus anyhow
    [_queue apply { _x select 0 }, true] call YFNC(addEditableObjects);

    _groups    = [[], []]; // Unique list of groups, and min distance from player
    _vehicles  = []; // List of non-group vehicles (empty);
    _weapons   = []; // Log placed weapons
    _ammoboxes = []; // Ammoboxes
    _modules   = []; // Modules (Lightning etc)
    _objects   = []; // Everything else, plain ole objects

    // Process the objects in queue
    {
        _x params ["_obj", "_class", "_distance"];
        call {
            // Handle group based vehicles / units
            _g = group _obj;
            if !(isNull _g) exitWith {
                _idx = (_groups select 0) find _g;
                if !(_idx isEqualTo -1) then {
                    if (_distance < (_groups select 1) select _idx) then {
                        (_groups select 1) set [_idx, _distance];
                    };
                } else {
                    (_groups select 0) pushBack _g;
                    (_groups select 1) pushBack _distance;
                };
            };

            if (_class isKindOf "Module_F")    exitWith { _modules   pushBack [_class, _distance]};
            if (_class isKindOf "ReammoBox_F") exitWith { _ammoboxes pushBack [_obj, _class, _distance] };
            if (_class isKindOf "AllVehicles") exitWith { _vehicles  pushBack [_obj, _class, _distance] };
            if (_class isKindOf "ReammoBox")   exitWith { _weapons   pushBack [_obj, _class, _distance] };
            _objects pushBack [_class, _distance];
        };
        nil;
    } count _queue;

    // Handle groups
    {
        _distance = (_groups select 1) select _forEachIndex;

        // Only manage groups with no players in
        _pc = { isPlayer _x } count (units _x);
        if (_pc isEqualTo 0) then {
            // previx the group id with curator
            _gn = groupId _x;
            _x setGroupIdGlobal [format ["%1 %2", GVAR(prefix), _gn]];
            [_x] remoteExecCall [QFNC(migrate), 2];
        };

        // Build Log
        _ut = [[],[]]; // Unit Types
        _gv = [];      // Group Vehicles
        _cu = -1;      // Clostest unit in the group

        _n  = {
            _t = typeOf _x;
            _idx = (_ut select 0) find _t;
            if !(_idx isEqualTo -1) then {
                (_ut select 1) set [_idx, (_ut select 1 select _idx) + 1];
            } else {
                (_ut select 0) pushBack _t;
                (_ut select 1) pushBack 1;z
            };

            _v = vehicle _x;
            if !(_v isEqualTo _x) then {
                _gv pushBackUnique (vehicle _x);
            };

            true;
        } count (units _x);

        // Build string representation of above
        _us = []; { _us pushBack (format ["%1: %2", _x, _ut select 1 select _forEachIndex ]); } forEach (_ut select 0);

        // Format log entry
        [format ['event: group, curator: %2, count: %2, units: %3, vehicles: %4, nearestPlayer: %5',
            name player,
            _n,
            _us joinString ", ",
            _gv apply { typeOf _x },
            _distance
        ], "zeuslog"] remoteExec [QYFNC(log), 2];

        nil;
    } forEach (_groups select 0);

    // Ammoboxes, weapons and vehicles are logged individually due to their regular cycle
    _typeList = [["ammobox", "weapon", "vehicle"], [_ammoboxes, _weapons, _vehicles]];
    {
        _objs = (_typeList select 1) select _forEachIndex;
        _type = _x;
        if !(_objs isEqualTo []) then {
            {
                _x params ["_obj", "_class", "_distance"];
                [format ['event: %1, creator: %2, event: %3, nearestPlayer: %4 }',
                    _type,
                    name player,
                    _class,
                    _distance
                ], "zeuslog"] remoteExec [QYFNC(log), 2];
                nil;
            } count _objs;
        };
    } forEach (_typeList select 0);

    // Modules just get dumped with each type spawned
    if !(_modules isEqualTo []) then {
        [format ['event: modules, creator: %1, classes: %2',
            name player,
            _modules joinString ", "
        ], "zeuslog"] remoteExec [QYFNC(log), 2];
    };

    // All other objects just get dumped
    if !(_objects isEqualTo []) then {

        // Build Log
        _ut = [[],[]]; // Object Types

        _n  = {
            _x params ["_class", "_distance"];

            _idx = (_ut select 0) find _class;
            if !(_idx isEqualTo -1) then {
                _c = (_ut select 1 select _idx select 0) + 1;
                _d = (_ut select 1 select _idx select 1);
                if (_distance < _d) then {
                    _d = _distance;
                };
                (_ut select 1) set [_idx, [_c, _d]];
            } else {
                (_ut select 0) pushBack _class;
                (_ut select 1) pushBack [1, _distance];
            };
            true;
        } count _objects;

        // Build string representation of above
        _us = [];
        {
            ((_ut select 1) select _forEachIndex) params ["_class", "_minDistance"];
            _us pushBack (format ["%1_count: %2, %1_distance: %3", _x, _class, _minDistance]);
        } forEach (_ut select 0);
        [format ['event: objects, creator: %1, count: %2, objects: %3', name player, count _objects, _us], "zeuslog"] remoteExec [QYFNC(log), 2];
    };

    // To avoid mass noise, we log the deletes a little more truncated
    if !(_delqueue isEqualTo []) then {

        _ta = [[], []];
        {
            _x params ["_class", "_type", "_distance"];

            _idx = (_ta select 0) find _type;
            if !(_idx isEqualTo -1) then {
                _c = (((_ta select 1) select _idx) select 0) + 1;
                _d = (_ta select 1) select _idx select 1;
                if (_distance < _d) then {
                    _d = _distance;
                };
                (_ta select 1) set [_idx, [_c, _d]];
            } else {
                (_ta select 0) pushBack _type;
                (_ta select 1) pushBack [1, _distance];
            };

            nil;
        } count _delqueue;

        _us = ["action: delete"];
        {
            ((_ta select 1) select _forEachIndex) params ["_count", "_minDistance"];
            _us pushBack format ["%1_count: %2, %1_distance: %3", _x, _count, _minDistance];
        } forEach (_ta select 0);

        [_us joinString ", ", "zeuslog"] remoteExec [QYFNC(log), 2];
    };

}, 30, []] call CBAP_fnc_addPerFrameHandler;