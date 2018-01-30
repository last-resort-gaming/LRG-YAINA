/*
	author: Martin
	description: none
	returns:
	    Boolean - if cleanup went ahead
*/
#include "..\defines.h"

params ["_pfhID", "_missionID", ["_force", false]];

// Do we break out ?
_fail = false;

// Find our missionID
private _localRunningMissionID = (GVAR(localRunningMissions) select 0) find _missionID;

// We exit with true, mainly to delete the PFH even though it'll leak resources
if (_localRunningMissionID isEqualTo -1) exitWith { true; };

// Bring in the params from our local missions
((GVAR(localRunningMissions) select 1) select _localRunningMissionID) params ["_markers", "_groups", "_vehicles", "_buildings"];

// We can only clear up if the area marker exists

if !(_markers isEqualTo []) then {

    private _areaMarker = _markers select 0;

    // We always set the marker alphas to 0 so they're no longer on the map, shortcut for finding people to bail
    { _x setMarkerAlpha 0; } count _markers;

    // If there are players remaining in the AO, just bail out
    if !(call { { _x inArea _areaMarker } count allPlayers; } isEqualTo 0) then { _fail = true; };

};

// Fail now unless it's forced, in which case we want to delete units/vehicles
if (_fail && { not _force } ) exitWith { false; };

// Delete all vehicles
{
    if !(isNull _x) then { deleteVehicle _x; };
    true;
} count _vehicles;

// Delete all units in group, then the group itself
{
    { if !(isNull _x) then { deleteVehicle _x; }; true; } count units _x;
    deleteGroup _x;
} count _groups;

// As we have deleted units, fail as we dont wanna kill buildings with folks in
if (_fail) exitWith { false; };

// Restore any replaced building to remove the ruins etc. then delete
// to avoid any left-overs, these are really for the
{
    _x setDamage 0;
    deleteVehicle _x;
} count _buildings;

// Restore any buildings around 1.5 times the AO size
// Remove any mines around the AO

_sz =  3 * (getMarkerSize (_markers select 0) select 0);
{ _x setDamage 0; true; } count ((getMarkerPos (_markers select 0)) nearObjects ["All", _sz]);
{ deleteVehicle _x; } count ((getMarkerPos (_markers select 0)) nearObjects ["MineBase", _sz]);


// delete our _markers
{ deleteMarker _x; true; } count _markers;

// Delete ourselves from our local running missions flag
(GVAR(localRunningMissions) select 0) deleteAt _localRunningMissionID;
(GVAR(localRunningMissions) select 1) deleteAt _localRunningMissionID;

// Call BIS_fnc_taskDeldete ? We delay this by 2 minutes so the success message
// goes through and people can see it in the map, if an HC disconnects at this
// point then it'll never get deleted.
[{ _this call BIS_fnc_deleteTask; }, [_missionID], 120] call CBAP_fnc_waitAndExecute;

// Remove from stopRequests
_idx = GVAR(stopRequests) find _missionID;
if !(_idx isEqualTo -1) then {
    GVAR(stopRequests) deleteAt _idx;
};

// Delete our HCDCH
[profileName, _missionID] remoteExecCall [QFNC(delHCDCH), 2];

// Remove pfh
[_pfhID] call CBAP_fnc_removePerFrameHandler;

true;