/*
	author: Martin
	description: none
	returns: nothing
*/

#include "..\defines.h"

if (!isServer) exitWith {};

GVAR(hcList) = [];                  // List of connected HCs [HC, HC, HC]
GVAR(hcDCH)  = [];                  // List of Mission Handlers [ [HC, MissionID, MissionState, Narkers, Groups, Vehicles, Buildings, pfh, pfhDelay, pfhArgs], [...], ...];
GVAR(hcBuildingRestores) = [[],[]]; // List of buildings to restore per-mission, used for restarting mission PFH

// Main Server Mission Manager
GVAR(hcMissionID) = [[], []];          // [ [HC, HC, HC, ...], [MissionID, MissionID, ...]];
publicVariable QVAR(hcMissionID);      // Used by HCs to pick the right mission ID on rejoin to avoid conflicts

GVAR(paradropMarkers) = [];            // Paradrop Markers, markers permitted to paradrop onto
publicVariable QVAR(paradropMarkers);  // Used by clients to overlay on map for paradrop positions

GVAR(lastPriorityMission) = 0;         // When the last priorty mission was so we can keep folks on their toes

addMissionEventHandler ["HandleDisconnect", {
    params ["_unit", "_id", "_uid", "_name"];

    // was this an HC, if so, start existing PFH handlers on server
    _hcID = GVAR(hcList) find _name;
    if !(_hcID isEqualTo -1) then {

        GVAR(hcList) deleteAt _hcID;

        // loop through handlers, and migrate to server
        {
            if (_x select 0 == _name) then {

                _x params ["_profileName", "_missionID", "_missionState", "_missionMarker", "_pfh", "_pfhDelay", "_pfhArgs"];

                [_pfh, _pfhDelay, _pfhArgs] call CBA_fnc_addPerFrameHandler;

                // update the HCDC Handler to be server
                (GVAR(hcDCH) select _forEachIndex) set [0, profileName];
            };

        } forEach GVAR(hcDCH);

        // Delete FPS Marker if it exists
        deleteMarker format ["fpsmarker%1", _name];

    };
}];
