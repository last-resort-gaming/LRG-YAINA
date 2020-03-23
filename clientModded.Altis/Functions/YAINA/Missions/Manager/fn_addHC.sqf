/*
Function: YAINA_MM_fnc_addHC

Description:
	Add a new headless client to the mission manager's life cycle.
	Also registers a given missionID with the HC.

Parameters:
	_profileName - The profile name of the newly added Headless Client used for unique identification
	_missionID - The missionID to register with the newly added HC

Return Values:
	The index at which the new HC was inserted in the global hcList, or -1 if adding failed

Examples:
    Nothing to see here

Author:
	Martin
*/

#include "..\defines.h"
if(!isServer) exitWith {};

params ["_profileName", "_missionID"];

TRACE_2("addHC", _profileName, _missionID);

// If we exist in hcMissionID update, else create
[_profileName, _missionID] call FNC(setMissionID);

// And add it to available HC list
GVAR(hcList) pushBackUnique _profileName;