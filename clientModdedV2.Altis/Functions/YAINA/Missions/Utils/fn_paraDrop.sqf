/*
Function: YAINA_MM_fnc_paraDrop

Description:
	Main function for handling the paradropping system.
    Checks for available drop points, ensure that dropping is allowed,
    draws the available paradrop markers, displays them on the map,
    add the click handler and handle deployment of the chute.

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

if (!hasInterface) exitWith {};

if (GVAR(paradropMarkers) isEqualTo []) exitWith {
    systemChat "No drop points available";
};

// Ensure we're allowed
if !(GVAR(paradropEnabled)) exitWith {
    systemChat "Paradrop unavailable, please utilise available pilots";
};

private _dMrk = [];
private _aMrk = [];
private _dCnt = 0;

// Draw all AO locations
{
    _dCnt = _dCnt + 1;
    _mn = format ["dm_mrk_%1a", _dCnt];
    _mk = createMarkerLocal [_mn, getMarkerPos _x];
    _mk setMarkerShapeLocal "ELLIPSE";
    _mk setMarkerSizeLocal (getMarkerSize _x apply { _x * 2.5 });
    _mk setMarkerBrushLocal "SolidBorder";
    _mk setMarkerColorLocal "ColorBLUE";
    _mk setMarkerAlphaLocal 0.5;
    _dMrk pushBack _mk;

    _mn = format ["dm_mrk_%1b", _dCnt];
    _mk = createMarkerLocal [_mn, getMarkerPos _x];
    _mk setMarkerShapeLocal "ELLIPSE";
    _mk setMarkerSizeLocal (getMarkerSize _x apply { _x * 1.5 });
    _mk setMarkerBrushLocal "SolidBorder";
    _mk setMarkerColorLocal "ColorBlack";
    _mk setMarkerAlphaLocal 0.75;
    _aMrk pushBack _mk;

} forEach GVAR(paradropMarkers);

// Bring up the map
openMap true;

// Add click handler
[QVAR(paradropClickHandlerID), "onMapSingleClick", {

    private _dMrk = _this select 4;
    private _aMrk = _this select 5;
    private _inAO = false;
    private _selectedAO = nil;

    // are we in the drop zone ?
    scopeName "para_main";

    {
        if (_pos inArea _x) then {
            _inAO = true;
            breakTo "para_main";
         };
    } forEach _aMrk;

    {
        if (_pos inArea _x) then {
            _selectedAO = _x;
            breakTo "para_main";
        };
    } forEach _dMrk;

    if (isNil "_selectedAO") exitWith { systemChat "Please click within the available AOs"; };
    if (_inAO) exitWith { systemChat "You cannot drop directly on top of an AO"; };

    private _leader = leader (group player);

    // Where to drop, default to where they are
    _dropPos = [_pos select 0, _pos select 1, 1000];

    if (!(_leader isEqualTo player) && _leader inArea _selectedAO) then {
        _dropPos = getPos _leader;
        _dropPos set [2, 1000];
        hint "We're dropping you near your leader";
    };

    // Add the action
    player addAction [
        ("<t color=""#ED2744"">") + ("Open Parachute") + "</t>",
        {player removeAction (_this select 2); call FNC(openChute)}, [], 10, false, true,"",
        "(((position _target) select 2) > 20) && (_target == (vehicle _target))"
    ];

    [{ player setPos (_this select 0) }, [_dropPos], 1, 2] call YFNC(fadeOutAndExecute);


    openMap false;

}, [_dMrk, _aMrk]] call BIS_fnc_addStackedEventHandler;


// Add a PFH (to clean up)
[{
    params ["_args", "_pfhID"];
    _args params ["_dMrk", "_aMrk"];

    if !(visibleMap) then {
        { if !(isNil "_x") then { deleteMarkerLocal _x; }; } forEach _dMrk;
        { if !(isNil "_x") then { deleteMarkerLocal _x; }; } forEach _aMrk;
        [QVAR(paradropClickHandlerID), "onMapSingleClick"] call BIS_fnc_removeStackedEventHandler;
        [_pfhID] call CBAP_fnc_removePerFrameHandler;
    };
}, 0, [_dMrk, _aMrk]] call CBAP_fnc_addPerFrameHandler;

