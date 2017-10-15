/*
* Add HC
*/

#include "..\defines.h"
if(!isServer) exitWith {};

params ["_profileName", "_missionID"];

TRACE_2("addHC", _profileName, _missionID);

// If we exist in hcMissionID update, else create
[_profileName, _missionID] call FNC(setMissionID);

// And add it to available HC list
GVAR(hcList) pushBackUnique _profileName;