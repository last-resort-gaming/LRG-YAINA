/*
	author: Martin
	description: none
	returns: nothing
*/

#include "defines.h"

if (isServer) then {
    // Ensure Zeus keeps slot, despite admin logging
    [{
        {
            _x params ["_player", "_mod"];

            // they're fucked, so we have to free up our dedicated curator
            if(isPlayer _player && { isNull getAssignedCuratorLogic _player } ) then {
                // If it thinks it assigned, unassig
                if !(isNull (getAssignedCuratorUnit _mod)) then {
                    unassignCurator _mod;
                } else {
                    _player assignCurator _mod;
                };
            };
            nil
        } count [
            [zeus1, zeus1mod],
            [zeus2, zeus2mod]
        ];
    }, 2, []] call CBAP_fnc_addPerFrameHandler;

    private _zeusGroup = createGroup sideLogic;
    ZEUS_PING_MODULE = _zeusGroup createunit["ModuleCurator_F", [0, 0, 0], [], 0.5, "NONE"];
    ZEUS_PING_MODULE addEventHandler ["CuratorPinged",{_this call FNC(zeusPinged)}];
};

if (hasInterface) then {

    {
        _x addEventHandler ["CuratorObjectPlaced", {
            // We place the typeof here as it's the only chance we'll get for modules etc.
            GVAR(objectsPlaced) pushBack [(_this select 1), typeOf (_this select 1), ([_this select 1] call YFNC(getNearestPlayer)) select 1];
        }];

        // We check our zeus handlers are running for each player when they launch the zeus interface
        _x addEventHandler ["CuratorObjectRegistered", {
            [player] remoteExecCall [QFNC(zeusConnected), 2],
        }];

        // And list our deleted objects
        _x addEventHandler ["CuratorObjectDeleted", {

            _class = typeOf (_this select 1);
            _type  = call {
                if (_class isKindOf "Man")         exitWith { "unit" };
                if (_class isKindOf "Module_F")    exitWith { "module" };
                if (_class isKindOf "ReammoBox_F") exitWith { "ammobox" };
                if (_class isKindOf "AllVehicles") exitWith { "vehicle" };
                if (_class isKindOf "ReammoBox")   exitWith { "weapon" };
                "object"
            };

            GVAR(objectsDeleted) pushBack [_class, _type, ([_this select 1] call YFNC(getNearestPlayer)) select 1];
        }];

        nil;
    } count allCurators;

    addMissionEventHandler ["PlayerViewChanged", {

        params ["_old", "_new", "_veh", "_oldCamOn", "_newCamOn", "_uav"];

        // Handle players jumping into vehicles / same-side UAVs etc.
        if ( _oldCamOn isEqualTo _newCamOn) exitWith {};
        if ( _newCamOn isEqualTo vehicle player ) exitWith {};
        if ( _newCamOn call YAINA_fnc_isUAV && { side _newCamOn isEqualTo side player } ) exitWith {};

        // This is to protect against infistar spectate triggering
        if (isPlayer _newCamOn) exitWith {};
        if !(isNil 'SPECTATE_THREAD') exitWith {};

        // If we're remote controling a unit in a vehicle then it all goes weird
        // but we don't really care about it

        // So if we got here, it's likely that we're zeus remote controling the unit, so log it as such
        [format ['event: remotecontrol, curator: %1, group: %2, name: %3, unittype: %4, nearestPlayer: %5 }',
            name player,
            group _newCamOn,
            name _newCamOn,
            typeOf _newCamOn,
            ([_newCamOn] call YAINA_fnc_getNearestPlayer) select 1
        ], "zeuslog"] remoteExec [QYFNC(log), 2];
    }];

}