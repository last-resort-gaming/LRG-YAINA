/*
	author: Martin
	description: none
	returns:
	    Boolean - if cleanup went ahead
*/
#include "..\defines.h"

params ["_pfhID", "_missionID", ["_force", false]];
private ["_idx"];

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

// Delete all reinforcements
private _idx = (GVAR(reinforcements) select 0) find _missionID;
if !(_idx isEqualTo -1) then {
    {
        _x params ["_rgroups", "_rvehs"];
        // Reinforcement Groups
        {
            { if !(isNull _x) then { deleteVehicle _x; }; true; } count units _x;
            deleteGroup _x;
            nil
        } count _rgroups;

        // Reinfrocement vehicles
        {
            if !(isNull _x) then { deleteVehicle _x; };
            nil
        } count _rvehs;

        nil
    } count ((GVAR(reinforcements) select 1) select _idx);
};

// As we have deleted units, fail as we dont wanna kill buildings with folks in
if (_fail) exitWith { false; };

// Restore any replaced building to remove the ruins etc. then delete
// to avoid any left-overs, these are really for the
{
    _x setDamage 0;
    deleteVehicle _x;
} count _buildings;

// Due to the intensity of the following section, we spawn it so it doesn't
// Lag out the HC. We do the buildings above, as when this fnc returns true, any
// terrain objects clear will re-appear and we don't want that to go too badly

[_pfhID, _missionID, _markers, _groups, _vehicles, _buildings, _localRunningMissionID] spawn {
    params ["_pfhID", "_missionID", "_markers", "_groups", "_vehicles", "_buildings", "_localRunningMissionID"];

    // cleanup area = 1.5 times the AO size
    _cp = getMarkerPos (_markers select 0);
    _sz =  1.5 * (getMarkerSize (_markers select 0) select 0);

    // Restore buildings/Things etc, but delete thoose placed in game (e.g. zeus minefield signs)
    {
        {
            _x setDamage 0;
            if (getObjectType _x isEqualTo 8) then {
                deleteVehicle _x;
            };
            true;
        } count (_cp nearObjects [_x, _sz]);
        nil
    } count ["Building", "Thing"];

    // Remove UXO / Mines etc. / Smokes / Ground weapon holders (backpacks/rifles on floor etc) / blood splatters
    {
        _t = _x;
        { deleteVehicle _x; true } count (_cp nearObjects [_t, _sz]);
        true
    } count ["MineBase", "Grenade", "#crater", "GroundWeaponHolder", "#slop"];

    // Now we just remove any zeus-units, vehicles, dead bodies, ammo crates etc. etc.
    { deleteVehicle _x; true } count (entities [["All"], ["Animal_Base_F", "Logic"], true, false] select { _x distance2D _cp < _sz });

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

};

true;