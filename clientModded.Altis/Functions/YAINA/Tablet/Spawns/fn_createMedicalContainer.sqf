/*
Function: YAINA_TABLET_fnc_createMedicalContainer

Description:
	Create a medical container for healing and reviving people in the 
	field. Crate will be spawned on the SP_CARGO trigger.

Parameters:
	None

Return Values:
	None

Examples:
    Nothing to see here

Author:
	Martin
*/

#include "..\defines.h"


// Check position is empty, or bail
if (triggerActivated SP_CARGO) exitWith { false; };

_crate = "B_Slingload_01_Medevac_F" createVehicle getPosATL SP_CARGO;
_crate setDir (triggerArea SP_CARGO select 2);
_crate setVariable ["YAINA_ARSENAL_filtered", true, true];

// Remove Content
clearWeaponCargoGlobal _crate;
clearMagazineCargoGlobal _crate;
clearItemCargoGlobal _crate;
clearBackpackCargoGlobal _crate;

// Add in FAKs
_crate addItemCargoGlobal ["Medikit", 1];
_crate addItemCargoGlobal ["FirstAidKit", 10];

// Allow Revive within 50 meters
[_crate, 50] call AIS_Core_fnc_addMedicStation;

// Allow it to be droppable
[_crate] call FNC(setDroppable);

// Add to Zeus
[[_crate]] call YFNC(addEditableObjects);

[[west, "HQ"], format["Support Request: Medical Container Created"]] remoteExec ["sideChat"];