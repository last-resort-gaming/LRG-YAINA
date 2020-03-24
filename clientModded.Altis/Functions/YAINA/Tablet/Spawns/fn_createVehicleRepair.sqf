/*
Function: YAINA_TABLET_fnc_createVehicleRepair

Description:
	Create a vehicle repair box to repair vehicles in the field.
	Crate will be spawned on the SP_CARGO trigger.

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

_crate = "B_Slingload_01_Repair_F" createVehicle getPosATL SP_CARGO;
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

[[west, "HQ"], format["Support Request: Vehicle Repair Container Created"]] remoteExec ["sideChat"];