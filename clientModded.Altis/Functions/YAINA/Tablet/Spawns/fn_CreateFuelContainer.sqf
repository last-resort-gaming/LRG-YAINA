/*
Function: YAINA_TABLET_fnc_createFuelContainer

Description:
	Create a fuel container for refueling vehicles in the field.
	Container will be created on the SP_CARGO trigger.

Parameters:
	None

Return Values:
	None

Examples:
    Nothing to see here

Author:
	MitchJC
*/

#include "..\defines.h"


// Check position is empty, or bail
if (triggerActivated SP_CARGO) exitWith { false; };

_crate = "B_Slingload_01_Fuel_F" createVehicle getPosATL SP_CARGO;
_crate setDir (triggerArea SP_CARGO select 2);

// Remove Content
clearWeaponCargoGlobal _crate;
clearMagazineCargoGlobal _crate;
clearItemCargoGlobal _crate;
clearBackpackCargoGlobal _crate;


// Allow it to be droppable
[_crate] call FNC(setDroppable);

// Add to Zeus
[[_crate]] call YFNC(addEditableObjects);

[[west, "HQ"], format["Support Request: Fuel Container Created"]] remoteExec ["sideChat"];