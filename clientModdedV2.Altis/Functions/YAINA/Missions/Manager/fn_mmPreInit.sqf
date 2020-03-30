/*
Function: YAINA_MM_fnc_preInit

Description:
	Handles initialization of the mission manager during the 
    preInit phase. Mainly concerned with initializing the necessary
    variables and setting up the headless client fail-over procedures.

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

if (!isServer) exitWith {};

GVAR(hcList) = [];                  // List of connected HCs [HC, HC, HC]
GVAR(hcDCH)  = [];                  // List of Mission Handlers [ [HC, MissionID, MissionStage, MissionState, MissionDesc, ParentMission, Markers, Units, Vehicles, Buildings, pfh, pfhDelay, pfhArgs], [...], ...];

// Main Server Mission Manager
GVAR(hcMissionID) = [[], []];          // [ [HC, HC, HC, ...], [MissionID, MissionID, ...]];
publicVariable QVAR(hcMissionID);      // Used by HCs to pick the right mission ID on rejoin to avoid conflicts

GVAR(paradropMarkers) = [];            // Paradrop Markers, markers permitted to paradrop onto
publicVariable QVAR(paradropMarkers);  // Used by clients to overlay on map for paradrop positions

GVAR(missionAreas) = [];               // Used for area exclusions when picking AOs
publicVariable QVAR(missionAreas);     // worst case scenario, is it's the same as paradrop markers

GVAR(lastPriorityMission) = 0;         // When the last priorty mission was so we can keep folks on their toes

addMissionEventHandler ["HandleDisconnect", {
    params ["_unit", "_id", "_uid", "_name"];

    // was this an HC, if so, start existing PFH handlers on server
    _hcID = GVAR(hcList) find _name;
    if !(_hcID isEqualTo -1) then {

        GVAR(hcList) deleteAt _hcID;

        [format ["HC Disconnect: %1", _name]] call YFNC(log);

        // loop through handlers, and migrate to server
        {
            if (_x select 0 == _name) then {

                _x params ["_profileName", "_missionID", "_missionType", "_stage", "_missionName", "_parentMissionID", "_markers", "_units", "_vehicles", "_buildings", "_pfh", "_pfhDelay", "_pfhArgs"];

                // We update the pfhArgs stage to be that of the HCDCH state before running it
                // So it resumes from correct location
                _pfhArgs set [1,_stage];

                // Then add it to local running missions for the sweet cleanup
                (GVAR(localRunningMissions) select 0) pushBack _missionID;
                (GVAR(localRunningMissions) select 1) pushBack [_markers, _units, _vehicles, _buildings];

                // Start processing the PFH locally
                [_pfh, _pfhDelay, _pfhArgs] call CBA_fnc_addPerFrameHandler;

                // reinforcements + building restores are always kept on server, so we don't have anything to update

                // update the HCDC Handler to be server
                (GVAR(hcDCH) select _forEachIndex) set [0, profileName];

                // Log
                [format ["HC Mission Migrated to Server: %1 from %2", _missionID, _name]] call YFNC(log);
            };

        } forEach GVAR(hcDCH);

        // Delete FPS Marker if it exists
        deleteMarker format ["fpsmarker%1", _name];

    };
}];
