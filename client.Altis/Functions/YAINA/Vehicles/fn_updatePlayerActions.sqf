/*
	author: Martin
	description: none
	returns: nothing
*/

#include "defines.h";

// And finally update the "Drop all Keys" action
if (!isNil Q(GVAR(keyActionID))) then { player removeAction GVAR(keyActionID); };
_vCount = count GVAR(myVehicles);
if !(_vCount isEqualTo 0) then {
    _title = ["Unlock your vehicle", format["Unlock all %1 vehicles", _vCount]] select (_vCount > 1);
    GVAR(keyActionID) = player addAction [_title, FNC(dropKey), "", -98, false, true];
};

// Update the variable, this is called at all times regawrding ownership changes
// so we can centralise the setting of the var here
player setVariable [QVAR(vehicles), GVAR(myVehicles), true];