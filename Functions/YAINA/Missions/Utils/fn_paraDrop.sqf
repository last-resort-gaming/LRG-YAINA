/*
	author: Martin
	description: none
	returns: nothing
*/

#include "..\defines.h"

if (!hasInterface) exitWith {};

if (GVAR(paradropMarkers) isEqualTo []) exitWith {
    systemChat "No drop points available";
};

// Limit paradrop if there are pilots online
private _pCount = { [["PILOT"], _x] call YFNC(testTraits); } count allPlayers;
if (_pCount > 0) exitWith {
    systemChat "Paradrop unavailable, please utilise available pilots";
};

// Limit paradrop if we've dropped recently
private _nt = floor(diag_tickTime - GVAR(lastParadrop));
if (_nt < GVAR(paradropTimeout) and !(GVAR(lastParadrop) isEqualTo 0)) exitWith {
    _dt = GVAR(paradropTimeout) - _nt;
    systemChat format ["Paradrop unavailable, please wait %1", _dt call YFNC(formatDuration)];
};

private _dMrk = [];
private _dCnt = 0;

// Draw all AO locations
{
    _dCnt = _dCnt + 1;
    _mn = format ["dm_mrk_%1", _dCnt];
    _mk = createMarkerLocal [_mn, getMarkerPos _x];
    _mk setMarkerShapeLocal "ELLIPSE";
    _mk setMarkerSizeLocal (getMarkerSize _x apply { _x * 2 });
    _mk setMarkerBrushLocal "SolidBorder";
    _mk setMarkerColorLocal "ColorBLUE";
    _mk setMarkerAlphaLocal 0.5;
    _dMrk pushBack _mk;
} forEach GVAR(paradropMarkers);

// Bring up the map
openMap true;

// Add click handler
[QVAR(paradropClickHandlerID), "onMapSingleClick", {

    private _dMrk = _this select 4;
    private _selectedAO = nil;

    // are we in the drop zone ?
    scopeName "para_main";
    {
        if (_pos inArea _x) then {
            _selectedAO = _x;
            breakTo "para_main";
        };
    } forEach _dMrk;

    if (isNil "_selectedAO") exitWith { systemChat "Please click within the available AOs"; };

    private _leader = leader (group player);

    // Where to drop, default to where they are
    _dropPos = [_pos select 0, _pos select 1, 1000];

    if (!(_leader isEqualTo player) && _leader inArea _selectedAO) then {
        _dropPos = getPos _leader;
        _dropPos set [2, 1000];
        hint "We're dropping you near your leader";
    };

    [{ player setPos (_this select 0) }, [_dropPos], 1, 2] call YFNC(fadeOutAndExecute);


    openMap false;

}, [_dMrk]] call BIS_fnc_addStackedEventHandler;


// Add a PFH (to clean up)
[{
    params ["_args", "_pfhID"];
    _args params ["_dMrk"];

    if !(visibleMap) then {
        { if !(isNil "_x") then { deleteMarkerLocal _x; }; } forEach _dMrk;
        [QVAR(paradropClickHandlerID), "onMapSingleClick"] call BIS_fnc_removeStackedEventHandler;
        [_pfhID] call CBA_fnc_removePerFrameHandler;
    };
}, 0, [_dMrk]] call CBA_fnc_addPerFrameHandler;

