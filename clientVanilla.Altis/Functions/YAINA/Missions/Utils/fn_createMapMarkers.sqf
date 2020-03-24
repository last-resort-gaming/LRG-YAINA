/*
Function: YAINA_MM_fnc_createMapMarkers

Description:
	Create the necessary map markers for the given mission.
    These are the circles indicating the AO itself and the actual
    icon adapted to the kind of mission.

Parameters:
	_missionID - The ID of the mission for which we want to create markers
    _markerPos - The position where we want to make our markers
    _size - The size of the AO for the circle marker
    _showSelector - Create a selectable marker on the AO for easy mission assignment
    _brush - The brushing type for the AO circle marker
    _startID - The ID for identifying the marker
    _color - The color of the marker

Return Values:
	Array containing the following information:

    _mrk1 - If created, the selectable icon marker
    _mrk2 - The AO circle marker

Examples:
    Nothing to see here

Author:
	Martin
*/

#include "..\defines.h"

params ["_missionID", "_markerPos", "_size", ["_showSelector", true], ["_brush", "FDiagonal"], ["_startID", 1], ["_color", "ColorOPFOR"]];

private _mrk1 = nil;

if !(isNil "_showSelector") then {
    _mrk1 = format ["%1_mrk%2", _missionID, _startID];
    createMarker [_mrk1, _markerPos];
    _mrk1 setMarkerShape "ICON";

    if (typeName _showSelector isEqualTo "STRING") then {
        _mrk1 setMarkerType _showSelector;
    } else {
        _mrk1 setMarkerType "selector_selectable";
        _mrk1 setMarkerColor "ColorBLUFOR";
    };
    INCR(_startID);
};

private _mrk2 = format ["%1_mrk%2", _missionID, _startID];
createMarker [_mrk2, _markerPos];
_mrk2 setMarkerShape "ELLIPSE";
_mrk2 setMarkerSize [_size, _size];
_mrk2 setMarkerBrush _brush;
_mrk2 setMarkerColor _color;

// return the area marker first, this is used in the cleanup phase
[_mrk2,_mrk1]