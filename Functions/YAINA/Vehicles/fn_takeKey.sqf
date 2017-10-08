/*
	author: MartinCo
	description: none
	returns: nothing
*/

#include "defines.h"

params ["_target", "_caller", "_id", "_arguments"];

if !(_caller isEqualTo player) exitWith {};


// Create the marker
_markerID = "";

if(SQUAD_BASED) then {
    _markerID = format["_USER_DEFINED #%1/%2%3/3", player call BIS_fnc_netId splitString ":" select 0, QVAR(mm), floor random 100000];
    _mm = createMarker [_markerID, position _target];
    _mm setMarkerShape "ICON";
    _mm setMarkerType "mil_triangle";
    _mm setMarkerSize [1,1];
    _mm setMarkerText format["Your %1", getText(configFile >> "CfgVehicles" >> typeOf (_target) >> "displayName")];
} else {
    _markerID = format["%1_%2_%3", QVAR(mm), _caller call BIS_fnc_objectVar, floor random 100000 ];
    _mm = createMarkerLocal [_markerID, position _target];
    _mm setMarkerShapeLocal "ICON";
    _mm setMarkerTypeLocal "mil_triangle";
    _mm setMarkerSizeLocal [1,1];
    _mm setMarkerTextLocal format["Your %1", getText(configFile >> "CfgVehicles" >> typeOf (_target) >> "displayName")];
};

// We set the owner to be the _caller, and create a map marker name;
_target setVariable [QVAR(owner), _caller call BIS_fnc_objectVar];
_target setVariable [QVAR(mm), _markerID];

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
call FNC(updatePlayerActions);

systemChat "You've taken the keys...";