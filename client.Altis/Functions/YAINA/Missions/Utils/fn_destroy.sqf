/*
	author: Martin
	description: none
	returns: nothing
*/

if !(isServer) exitWith {};


[{
    params ["_delay", "_pos", ["_sub", [0, 10, 5]], ["_method", "Bo_mk82"], ["_preCode", {}], ["_preCodeArgs", []]];

    _preArgs call _preCode;
    _method createVehicle (_pos vectorAdd [0,0,0.5]);

    private _csleep = _sub select 1;
    private _nsleep = (_sub select 1) * 2;

    if ((_sub select 0) > 0) then {
        for "_x" from 2 to ((_sub select 0)+1) do {
            private _m = _x % 2;
            private _s = 0; if (_m isEqualTo 1) then { _s = 0.25 + (random 0.75); };
            [{ "SmallSecondary" createVehicle _this }, [_pos, floor(_x / 2) * (_sub select 2), random 360] call BIS_fnc_relPos, _csleep + _s] call CBAP_fnc_waitAndExecute;
            if (_m isEqualTo 1) then {
                _nsleep = _nsleep / 2;
                _csleep = _csleep + (_nsleep / 2);
            };
        };
    };

}, _this, _this select 0] call CBAP_fnc_waitAndExecute;