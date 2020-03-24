/*
Function: YAINA_ARSENAL_fnc_postInit

Description:
	Handles initialization of the arsenals during the postInit phase.
	Adds an event handler to all players, executed whenever they 
	take something from a container, to run gear enforcements 
	and initializes the arsenal boxes.

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

private _arsenals = [];

if (isClass(configfile >> "CfgPatches" >> "UK3CB_BAF_Equipment")) then {
	
	[ARSENALS] call FNC(initArsenal3CB);

} else {
	
	[ARSENALS] call FNC(initArsenal);	
};

// Player take handler, if the weapon hold is BLUFOR then we enforce weapon restrictions

player addEventHandler ["Take", {
    params ["_unit", "_container", "_item"];
    [_unit, _item, _container] call FNC(enforceGear);
}];

