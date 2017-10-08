/*
	author: MartinCo
	description: none
	returns: nothing
*/

#include "defines.h"

params ["_target", "_caller", "_id", "_arguments"];

if !(_caller isEqualTo player) exitWith {};

_markerID = format["%1_%2_%3", QVAR(mm), _caller call BIS_fnc_objectVar, floor random 100000 ];

// We set the owner to be the _caller, and create a map marker name;
_target setVariable [QVAR(owner), _caller];
_target setVariable [QVAR(mm), _markerID];

// Create the marker
_mm = createMarkerLocal [_markerID, position _target];
_mm setMarkerTypeLocal "mil_triangle";
_mm setMarkerSizeLocal [1,1];
_mm setMarkerTextLocal format["Your %1", getText(configFile >> "CfgVehicles" >> typeOf (_target) >> "displayName")];

// Update the server's knowledge of who owns what (unlock on disconnect etc)
[_caller, _target, "add"] remoteExec [QFNC(updateOwnership), 2];

// And add to our vehicle list
GVAR(myVehicles) pushBackUnique _target;

// Now we trigger a PFH if there isn't one to update my vehicle positions on the map
if (isNil Q(GVAR(PFHID))) then {
    GVAR(PFHID) = [{
        // If we have none, we bail out
        params ["_args", "_pfhID"];

        _count = {
            _mm = _x getVariable QVAR(mm);
            if !(isNil "_mm") then {
                _mm setMarkerPosLocal position _x;
            };
            true;
        } count GVAR(myVehicles);

        if (_count isEqualTo 0) then {
            _pfhID call CBA_fnc_removePerFrameHandler;
            GVAR(PFHID) = nil;
        };
    }, 1, []] call CBA_fnc_addPerFrameHandler;
};

// And finally update the "Drop all Keys" action to reflect the locked vehicle count
if (!isNil Q(GVAR(keyActionID))) then { player removeAction GVAR(keyActionID); };
_vCount = count GVAR(myVehicles);
if !(_vCount isEqualTo 0) then {
    _title = ["Unlock your vehicle", format["Unlock all %1 vehicles", _vCount]] select (_vCount > 1);
    GVAR(keyActionID) = player addAction [_title, FNC(dropKey), "", -98, false, true];
};

systemChat "You've taken the keys...";