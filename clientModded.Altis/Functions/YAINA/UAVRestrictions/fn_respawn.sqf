/*
Function: YAINA_UAV_fnc_respawn

Description:
	Runs whenever a player with UAV access respawns. Runs the 
	rescanning function.

Parameters:
	None

Return Values:
	None

Examples:
    Nothing to see here

Author:
	Martin
*/

#include "defines.h"

// Lock what we have now...
call FNC(rescan);