/*
	author: Martin
	description: none
	returns: nothing
*/

#include "..\defines.h"

params ["_missionID", "_markerPos", "_size", ["_showSelector", true], ["_brush", "FDiagonal"], ["_startID", 1]];

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
_mrk2 setMarkerColor "ColorOPFOR";

[_mrk1, _mrk2]