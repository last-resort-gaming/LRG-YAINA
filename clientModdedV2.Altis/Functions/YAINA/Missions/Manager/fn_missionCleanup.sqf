/*
Function: YAINA_MM_fnc_missionCleanup

Description:
	Handles mission cleanup after mission end.
    Removes markers, units and vehicles and restore buildings and 
    terrain. Clears out mines and explosives, and Zeus stuff.
    Also delete the reinforcements, and remove from stop requests.

Parameters:
	_pfhID - The ID of the per-frame event handler associated with the mission
    _missionID - ID of the mission we want to run cleanup for
    _force - Do we want to force cleanup even if there are players nearby

Return Values:
	true, if cleanup did go ahead, false otherwise

Examples:
    Nothing to see here

Author:
	Martin
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
((GVAR(localRunningMissions) select 1) select _localRunningMissionID) params ["_markers", "_units", "_vehicles", "_buildings"];

// We can only clear up if the area marker exists
_idx = (GVAR(missionCleanupTimeouts) select 0) find _missionID;

if (_force isEqualTo false) then {
    if (_idx isEqualTo -1) then {
        (GVAR(missionCleanupTimeouts) select 0) pushBack _missionID;
        (GVAR(missionCleanupTimeouts) select 1) pushBack (LTIME + 300);
        [format ["Mission Cleanup Timer Started for %1", _missionID], "CleanupLog"] call YFNC(log);
        _fail = true;
    } else {
        if (LTIME < ((GVAR(missionCleanupTimeouts) select 1) select _idx)) then {
            [format ["Mission Cleanup Timeout not reached for %1", _missionID], "CleanupLog"] call YFNC(log);
            _fail = true;
        };
    };
};

// Finall ensure we're out the area
if !(_markers isEqualTo []) then {

    private _areaMarker = _markers select 0;

    // We always set the marker alphas to 0 so they're no longer on the map, shortcut for finding people to bail
    { _x setMarkerAlpha 0; } count _markers;

    // Check no players in 1.5 * AO Size
    _area = [getMarkerPos _areaMarker] +
                (getMarkerSize _areaMarker apply { _x * 1.5 }) +
                [markerDir _areaMarker, markerShape _areaMarker == "RECTANGLE"];

    // Check the fail just so we don't get extra messages
    if !(_fail) then {
        // If there are players remaining in the AO, just bail out
        if !(call { { _x inArea _area } count allPlayers; } isEqualTo 0) then {
            _fail = true;
            [format ["Players in area for %1: %2", _missionID, _areaMarker], "CleanupLog"] call YFNC(log);
        } else {
            [format ["No plaayers in area for %1: %2", _missionID, _areaMarker], "CleanupLog"] call YFNC(log);

            // As we have no players in the AO, but might be within our min despawn time
            // we take the opportunity to delette dead units to reduce some load
            {
                if !(isNull _x && { !(alive _x) }) then { deleteVehicle _x; };
            } count _units;
        };
    };
};

// Fail now unless it's forced, in which case we want to delete units/vehicles
if (_fail && { not _force } ) exitWith { false; };

[format ["Proceeding with cleanup for %1", _missionID], "CleanupLog"] call YFNC(log);

// Delete all units
{
    if !(isNull _x) then { deleteVehicle _x; };
} count _units;

// Delete all vehicles
{
    if !(isNull _x) then {
        // If there is a player in the vehicle, we initialize the vehicle handler
        // so it can naturally be despawned when it's abandoned
        if ( ( { alive _x && { isPlayer _x } } count (crew _x)) isEqualTo 0 ) then {
            // Due to wrecks and you can't delete a dead/civvie/objNull crew, empty it out first
            // to avoid empty objects floating around
            _v = _x;
            { _v deleteVehicleCrew _x ; nil } count (crew _v);
            deleteVehicle _v;
        } else {
            // We just use a shorter abandon distance
            [_x, true, -1, 1500] call YAINA_VEH_fnc_initVehicle;
        };
    };
    true;
} count _vehicles;


// Delete all reinforcements
private _idx = (GVAR(reinforcements) select 0) find _missionID;
if !(_idx isEqualTo -1) then {
    {
        _x params ["_runits", "_rvehs"];

        // Reinforcement Units
        {
            if !(isNull _x) then { deleteVehicle _x; };
            nil
        } count _runits;

        // Reinfrocement vehicles
        {
            if !(isNull _x) then {
                _v = _x;
                { _v deleteVehicleCrew _x ; nil } count (crew _v);
                deleteVehicle _v;
            };
            nil
        } count _rvehs;

        nil
    } count ((GVAR(reinforcements) select 1) select _idx);
};

// Do a scan for any empty groups and remove them
{ deleteGroup _x; true } count (allGroups select { count (units _x) isEqualTo 0; } );

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

[_pfhID, _missionID, _markers, _units, _vehicles, _buildings] spawn {
    params ["_pfhID", "_missionID", "_markers", "_units", "_vehicles", "_buildings"];

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
    {
        // Given the cleanup size is larger than the area size, there is a chance a vehicle with players
        // is just outside the completion radios, but within this radius, and dn't want them getting nuked
        // so...

        if ( ( { alive _x && { side _x isEqualTo west } } count (crew _x)) isEqualTo 0) then {
            deleteVehicle _x;
        } else {
            // We just use a shorter abandon distance, as long as it's not a person
            if !(_x isKindOf "CAManBase") then {
                [_x, true, -1, 1500] call YAINA_VEH_fnc_initVehicle;
            };
        };
        nil;
    } count (entities [["All"], ["Animal_Base_F", "Logic"], true, false] select { _x distance2D _cp < _sz });

    // delete our _markers
    { deleteMarker _x; true; } count _markers;

    // Delete ourselves from our local running missions flag, this may have moved on by now
    private _localRunningMissionID = (GVAR(localRunningMissions) select 0) find _missionID;
    if !(_localRunningMissionID isEqualTo -1) then {
        (GVAR(localRunningMissions) select 0) deleteAt _localRunningMissionID;
        (GVAR(localRunningMissions) select 1) deleteAt _localRunningMissionID;
    };

    // Delete our cleanup timer
    private _idx = (GVAR(missionCleanupTimeouts) select 0) find _missionID;
    if !(_idx isEqualTo -1) then {
        (GVAR(missionCleanupTimeouts) select 0) deleteAt _idx;
        (GVAR(missionCleanupTimeouts) select 1) deleteAt _idx;
    };

    // Call BIS_fnc_taskDeldete ? We delay this by 2 minutes so the success message
    // goes through and people can see it in the map, if an HC disconnects at this
    // point then it'll never get deleted.
    [{ _this call BIS_fnc_deleteTask; }, [_missionID], 120] call CBA_fnc_waitAndExecute;

    // Remove from stopRequests
    _idx = GVAR(stopRequests) find _missionID;
    if !(_idx isEqualTo -1) then {
        GVAR(stopRequests) deleteAt _idx;
    };

    // Delete our HCDCH
    [profileName, _missionID] remoteExecCall [QFNC(delHCDCH), 2];


    // Remove pfh
    [_pfhID] call CBA_fnc_removePerFrameHandler;

};

true;