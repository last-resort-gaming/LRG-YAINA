/*
	author: Martin
	description: none
	returns: nothing
*/

#include "..\defines.h"

params ["_veh",
    ["_hasKeys", false],
    ["_respawnTime", 10],
    ["_abandonDistance", 1000]
];

if (isNil "_veh") exitWith {};
if (isNull _veh) exitWith {};

_veh enableCopilot false;

[_veh, _hasKeys, _respawnTime, _abandonDistance, [], {
    params ["_veh", "_args"];

    // Only condition is that the requestor is a pilot, and it's empty
    // and not already getting some explosives
    _checkCode = "'PILOT' call YAINA_fnc_testTraits &&
                  { !( [_target] call YAINA_fnc_inBaseProtectionArea ) } &&
                  { ( { alive _x } count (crew _target) ) isEqualTo 0 } &&
                  { isNil { _target getVariable 'YAINA_planting_explosives' } } &&
                  { isNil { _target getVariable 'YAINA_explosives' } }";

    [_veh, "<t color='#ff1111'>Plant Explosives</t>", {
        params ["_target", "_caller", "_id", "_arguments"];

        // Dont let 2 folks do it at once
        _target setVariable["YAINA_planting_explosives", true, true];

        ["Planting Explosives", 5, {

            params ["_target", "_caller"];
            _target setVariable["YAINA_explosives", true, true];
            _target setVariable["YAINA_planting_explosives", nil, true];

            // Let them know
            [_caller, "Explosives have been set for 30 seconds"] remoteExecCall ["sideChat"];

            // And start a timer to explode
            [30, getPos _target vectorAdd [0,1,0.5], [2,1,2], "Bo_mk82", {
                params ["_target", "_caller"];
                if !( ({ alive _x } count (crew _target) ) isEqualTo 0) exitWith {
                    // Abort.. not empty
                    _target setVariable["YAINA_explosives", nil, true];
                    [_caller, "Destruction Aborted, there are players on board"] remoteExecCall ["sideChat"];
                    false
                };
                true
            }, [_target, _caller]] remoteExec ["YAINA_MM_fnc_destroy", 2];

        }, [_target, _caller], {
            // on Abort;
            params ["_target", "_caller"];
            _target setVariable["YAINA_planting_explosives", nil, true];
        }] call AIS_Core_fnc_Progress_ShowBar;
    }, [], 1.5, false, true, "", _checkCode, 15, false] call YFNC(addActionMP);

}, [], true] call YAINA_VEH_fnc_initVehicle;
