/*
	author: Martin
	description: none
	returns: nothing
*/

#include "..\defines.h"

params ["_missionID", "_markerPos", "_size"];

TRACE_3("createMapMarkers", _missionID, _markerPos, _size);

private _mrk1 = format ["%1_mrk1", _missionID];
createMarker [_mrk1, _markerPos];
_mrk1 setMarkerShape "ICON";
_mrk1 setMarkerType "selector_selectable";
_mrk1 setMarkerColor "ColorBLUFOR";

private _mrk2 = format ["%1_mrk2", _missionID];
createMarker [_mrk2, _markerPos];
_mrk2 setMarkerShape "ELLIPSE";
_mrk2 setMarkerSize [_size, _size];
_mrk2 setMarkerBrush "Border";
_mrk2 setMarkerColor "ColorOPFOR";

[_mrk1, _mrk2]