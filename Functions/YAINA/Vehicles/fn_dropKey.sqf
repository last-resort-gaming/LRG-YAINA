/*
	author: MartinCo
	description: none
	returns: nothing
*/

#include "defines.h"

params ["_target", "_caller", "_id", "_arguments"];

// if _target == _caller, then we are dropping all keys as it's a player action
if (_target isEqualTo _caller) then {
    [_target, nil, "remove"] remoteExec [QFNC(updateOwnership), 2];

    // Remove all map markers, and blat the array
    // We dont need to clean it up on the obj as it'll be
    // overwritten the next time someone takes the key
    {
        _mm = _x getVariable QVAR(mm);
        if !(isNil "_mm") then {  deleteMarkerLocal _mm; };
    } count GVAR(myVehicles);
    GVAR(myVehicles) = [];

} else {
    [_caller, _target, "remove"] remoteExec [QFNC(updateOwnership), 2];
    _idx = GVAR(myVehicles) find _target;
    if !(_idx isEqualTo -1) then {

        _mm = (GVAR(myVehicles) select _idx) getVariable QVAR(mm);
        if !(isNil "_mm") then {  deleteMarkerLocal _mm; };

        GVAR(myVehicles) deleteAt _idx;
    };
};

// And finally update the "Drop all Keys" action
if (!isNil Q(GVAR(keyActionID))) then { player removeAction GVAR(keyActionID); };
_vCount = count GVAR(myVehicles);
if !(_vCount isEqualTo 0) then {
    _title = ["Unlock your vehicle", format["Unlock all %1 vehicles", _vCount]] select (_vCount > 1);
    GVAR(keyActionID) = player addAction [_title, FNC(dropKey), "", -98, false, true];
};