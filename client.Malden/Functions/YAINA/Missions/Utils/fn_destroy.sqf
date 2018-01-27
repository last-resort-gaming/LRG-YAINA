/*
	author: Martin
	description: none
	returns: nothing
*/

if !(isServer) exitWith {};


[{
    params ["_delay", "_pos", ["_sub", [0, 10]], ["_method", "Bo_mk82"], ["_preCode", {}], ["_preCodeArgs", []]];

    _preArgs call _preCode;
    _method createVehicle (_pos vectorAdd [0,0,0.5]);

    if ((_sub select 0) > 0) then {
        [_pos, _sub select 0, (_sub select 1) * 2] spawn {
            params ["_pos", "_subCount", "_subDelay"];
            for "_x" from 2 to (_subCount+2) do {
                private _distance = floor(_x / 2) * 5;
                private _sleep = _subDelay / _x;
                if ((_x % 2) isEqualTo 0) then {
                    sleep _sleep;
                };
                "SmallSecondary" createVehicle ([_pos, _distance, random 360] call BIS_fnc_relPos);
                sleep (random 1);
            };
        };
    };

}, _this, _this select 0] call CBAP_fnc_waitAndExecute;