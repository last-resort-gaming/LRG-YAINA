/*
Function: YAINA_TABLET_fnc_createVehicleAmmo

Description:
	Create a crate containing vehicle ammo for rearming vehicles
	in the field. Ammo crate will be placed on the SP_CARGO trigger.

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

_crate = "B_Slingload_01_Ammo_F" createVehicle getPosATL SP_CARGO;
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

[[west, "HQ"], format["Support Request: Vehicle Ammo Container Created"]] remoteExec ["sideChat"];