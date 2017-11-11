/*
	author: Martin
	description: none
	returns: nothing
*/

#include "defines.h"

params ["_veh"];

_veh setVariable [QVAR(rddl), [[], []], true];

_veh addEventHandler ["RopeAttach", {
    params ["_veh", "_rope", "_item"];

    _v = _veh getVariable QVAR(rddl);

    if !(isNil "_v") then {

        _idx = (_v select 0) find _item;
        if !(_idx isEqualTo -1) then {
            _nv = (_v select 1) select _idx;
            (_v select 1) set [_idx, _nv + 1 ];
        } else {
            (_v select 0) pushBack _item;
            (_v select 1) pushBack 1;
        };

        _veh setVariable [QVAR(rddl), _v, true];
    };
}];

_veh addEventHandler ["RopeBreak", {
    params ["_veh", "_rope", "_item"];

    _v = _veh getVariable QVAR(rddl);
    if !(isNil "_v") then {
        _idx = (_v select 0) find _item;
        if !(_idx isEqualTo -1) then {
            _nv = ((_v select 1) select _idx) - 1;
            (_v select 1) set [_idx, _nv];

            if (_nv <= 0) then {
                _rddh = _item getVariable QVAR(rddh);

                if !(isNil "_rddh") then {
                    {
                        [_item, _veh] call _x;
                    } forEach _rddh;
                };
            };
        };

        _veh setVariable [QVAR(rddl), _v, true];
    };
}];

