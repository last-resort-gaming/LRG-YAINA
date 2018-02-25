/*
	author: Martin
	description: none
	returns: nothing
*/

#include "defines.h"

params ["_unit", "_veh", "_action"];

if (_action isEqualTo "add") then {
    if(!(isNil "_unit") && !(isNil "_veh")) then {
        (GVAR(owners) select 0) pushBack _unit;
        (GVAR(owners) select 1) pushBack _veh;
    };
};

// Either it's all a given players locks, or a given vehicle
if (_action isEqualTo "remove") then {
    if !(isNil "_veh") then {
        _id = (GVAR(owners) select 1) find _veh;

        if !(_id isEqualTo -1) then {

            _owner = (GVAR(owners) select 0) select _id;
            _mm    = _veh getVariable QVAR(mm);

            _veh setVariable [QVAR(owner), nil, true];
            (GVAR(owners) select 0) deleteAt _id;
            (GVAR(owners) select 1) deleteAt _id;
        };
    } else {
        if(!isNil "_unit") then {
            for "_i" from (count(GVAR(owners) select 0) - 1) to 0 step -1 do {
                if (((GVAR(owners) select 0) select _i) isEqualTo _unit) then {

                    _veh   = ((GVAR(owners) select 1) select _i);
                    _owner = ((GVAR(owners) select 0) select _i);
                    _mm    = _veh getVariable QVAR(mm);

                    _veh setVariable [QVAR(owner), nil, true];
                    (GVAR(owners) select 0) deleteAt _i;
                    (GVAR(owners) select 1) deleteAt _i;
                };
            };
        };
    };
};
