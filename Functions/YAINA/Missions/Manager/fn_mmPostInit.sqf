/*
	author: Martin
	description: none
	returns: nothing
*/

#include "..\defines.h"

// This only needs to be run on server hosts or HC
if !(isServer || !hasInterface) exitWith {};

// Where we store our local MissionID
GVAR(localMissionID) = 0;
GVAR(localRunningMissions)  = [[], []];   // [Mission ID, Mission ID, ...], [Mission Args, Mission Args, ...]]
GVAR(localBuildingRestores) = [[], []]; // [Mission ID, Mission ID, ...], [Building, Building, ...]]

// We need to keep track of building changes to ensure we can restore an AO once a mission ends
// This handler happens both server + HCDCH so that if it fails over the server also knows what
// needs cleaning up

addMissionEventHandler["BuildingChanged", {
    params ["_from", "_to", "_ruins"];

    if (!_ruins) exitWith {};

    // If it's in my AOs, add it to the restore list
    {
        _missionID = _x;
        if(_from inArea ((((GVAR(localRunningMissions) select 1) select _forEachIndex) select 0) select 1)) then {
            _idx = (GVAR(localBuildingRestores) select 0) find _missionID;
            if (_idx isEqualTo -1) then {
                (GVAR(localBuildingRestores) select 0) pushBack _missionID;
                (GVAR(localBuildingRestores) select 1) pushBack [_from];
            } else {
                ((GVAR(localBuildingRestores) select 1) select _idx) pushBack _from;
            };
        };
    } forEach (GVAR(localRunningMissions) select 0);

    if(isServer) then {

        // We always add it to a list, because if the HC failover happens, the new HC will need to know to restore
        _missionManaged = {
            if (_from inArea ((_x select 4) select 1)) exitWith {
                _missionID = _x select 1;
                _idx = (GVAR(hcBuildingRestores) select 0) find _missionID;
                if (_idx isEqualTo -1) then {
                    (GVAR(hcBuildingRestores) select 0) pushBack _missionID;
                    (GVAR(hcBuildingRestores) select 1) pushBack [_from];
                } else {
                    ((GVAR(hcBuildingRestores) select 1) select _idx) pushBack _from;
                };
                true;
            };
            false;
        } count GVAR(hcDCH);

        // Restore the building if all players are fair enough distance away
        if (_missionManaged isEqualTo 0) then {
            [
                { call { { (_this select 0) distance2D _x < 75 } count allPlayers; } isEqualTo 0 },
                { (_this select 0) setDamage 0; },
                [_from]
            ] call CBA_fnc_waitUntilAndExecute;
        };
    };
}];


// Setup our HCs
if !(isServer or hasInterface) then {

    // Wait until we have our mission ID from the public variable before adding ourselves as an HC
    [
        {!isNil QVAR(hcMissionID)},
        {
            private _mid = 0;
            private _idx = (GVAR(hcMissionID) select 0) find profileName;

            if !(_idx isEqualTo -1) then {
                _mid = (GVAR(hcMissionID) select 1) select _idx;
            };

            GVAR(localMissionID) = _mid;

            [profileName, GVAR(localMissionID)] remoteExecCall [QFNC(addHC), 2];
        },
        []
    ] call CBA_fnc_waitUntilAndExecute;

};

if (isServer) then {
    // Start our Mission Manager in 120 seconds to give our HCs time to connect
    [{ call FNC(missionManager); }, [], 120] call CBA_fnc_waitAndExecute;
};