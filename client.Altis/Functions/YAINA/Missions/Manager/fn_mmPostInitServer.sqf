/*
Function: YAINA_MM_fnc_mmPostInitServer

Description:
	Handles initialization of the mission manager during the postInit
    phase. Mainly concerned with setting up the necessary variables,
    runs general setup duties for the PFHs, kick-starts the headless
    clients, start the mission manager life cycle, and initialize
    the building restoring functionality.

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

// This only needs to be run on server hosts or HC
if !(isServer || !hasInterface) exitWith {};

// Where we store our local MissionID
GVAR(paused) = false;
GVAR(localMissionID) = 0;
GVAR(localRunningMissions)  = [[], []];   // [Mission ID, Mission ID, ...], [Mission Args, Mission Args, ...]]
GVAR(reinforcements)        = [[], []];   // [Mission ID, Mission ID, ...], [[[Grps,Veh], [Grps, Veh], ...], [...]]
GVAR(stopRequests) = []; // List of mission IDs that have been requested for force completion
GVAR(missionCleanupTimeouts) = [[], []]; // Array for minimum timeout on de-spawn

// General Setup
call FNC(utilityPFH);

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
    ] call CBAP_fnc_waitUntilAndExecute;
};

if (isServer) then {
    // Start our Mission Manager in 60 seconds to give our HCs time to connect
    [{ call FNC(missionManager); }, [], 60] call CBAP_fnc_waitAndExecute;


    // We need to keep track of building changes to ensure we restore them when a player moves away
    // just to keep the map clean of destroyed buildings all over the place.
    // If it's in an AO, then we don't need to worry as the cleanup script will handle it for us.

    addMissionEventHandler["BuildingChanged", {
        params ["_from", "_to", "_ruins"];

        if (!_ruins) exitWith {};

        if(isServer) then {

            // We always add it to a list, because if the HC failover happens, the new HC will need to know to restore
            _missionManaged = { _from inArea ((_x select 6) select 0) } count GVAR(hcDCH);

            // Restore the building if all players are fair enough distance away
            if (_missionManaged isEqualTo 0) then {
                [
                    { call { { (_this select 0) distance2D _x < 1000 } count allPlayers; } isEqualTo 0 },
                    { (_this select 0) setDamage 0; },
                    [_from]
                ] call CBAP_fnc_waitUntilAndExecute;
            };
        };
    }];
};