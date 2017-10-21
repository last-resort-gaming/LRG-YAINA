/*
	author: Martin
	description: none
	returns: nothing
*/

#include "defines.h";

private _flags = [
    [Flag_Base, "HQ"],
    [Flag_INS, "Land Insertion Point"],
    [Flag_USSF, "USS Freedom"]
];

{
    _obj = _x select 0;
    {
        if !(_obj isEqualTo (_x select 0)) then {
            _x params ["_target", "_desc"];
            _obj addAction [
                format["Teleport to %1", _desc], {
                    _target = (_this select 3) select 0;
                    [{
                        _target = _this select 0;
                        if (_target isEqualTo Flag_USSF) then {
                            _asl = (getPosASL Flag_USSF);
                            _p = Flag_USSF getRelPos [random 5 + 1, random 180];
                            _p set [2,_asl select 2];
                            player setPosASL _p
                        } else {
                            _p = (getPosATL (_this select 0)) findEmptyPosition [2,15];
                            if !(_p isEqualTo []) then {
                                player setPosATL _p;
                            };
                        };
                    }, [_target]] call YFNC(fadeOutAndExecute);
                }, [_target]
            ];
        };
    } forEach _flags;
} forEach _flags;

