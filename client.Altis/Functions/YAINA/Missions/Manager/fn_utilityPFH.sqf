/*
Function: YAINA_MM_fnc_utilityPFH

Description:
	Initializes a utility PFH to man-handle Tigris' because they
    are a bit of a pain.

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

if !(isNil QVAR(utilityPFH)) exitWith {};


GVAR(utilityPFH) = [{

    // Tigris' are a pain in the ass, both in that they stop at waypoints,
    // and they have a tendency to chase units way out of the AOs

    _AOs   = GVAR(missionAreas) apply { [getMarkerPos _x] + (getMarkerSize _x apply { _x * 1.5 }) + [0,false] };
    _vlist = vehicles select { local _x && { !(side _x in [civilian, west]) } && { typeOf _x isKindOf "Land" } };

    {
        _v     = _x;
        _g     = group _v;
        _wps   = waypoints _g;

        if !(count _wps > 1) exitWith {};

        _cwid  = currentWaypoint _g;
        _cwp   = _wps select _cwid;

        _cwpcr = waypointCompletionRadius _cwp;
        if (_cwpcr isEqualTo 0) then { _cwpcr = 30 };

        // Abort chasing ? If the vehicle isn't in an AO, we force it back to it's last waypoint
        private _inAO = { _v inArea _x } count _AOs;
        if (_inAO isEqualTo 0) then {

            // We only tell it to move if our expected destination isn't within 300m of our
            // waypoint, or if it's got a target assigned, or if we're not moving at all
            _assign = false;

            _tgt = assignedTarget _v;

            if !(_tgt isEqualTo objNull) then {
                _g forgetTarget _tgt;
                _assign = true;
            };

            if ((waypointPosition _cwp) distance2D (expectedDestination _v select 0) > 300 || { velocity _x isEqualTo [0,0,0] } ) then {
                _assign = true;
            };

            if (_assign) then {

                // Already assigned ?
                _lb = _g getVariable QVAR(lastBehaviour);
                if (isNil "_lb") then {
                    // They're stubborn so we force them to behave
                    _g setVariable [QVAR(lastBehaviour), behaviour _v, true];

                    {
                        _x disableAI "AUTOCOMBAT";
                        _x disableAI "AUTOTARGET";
                        _x disableAI "TARGET";
                        _x disableAI "FSM";
                        nil;
                    } count (units _g);
                    _g setBehaviour "CARELESS";
                };

                _v commandWatch objNull;

                // We increment the waypoint here again, to force it to start moving once more
                _nw = _cwid + 1;
                if (_nw > count _wps) then { _nw = 0 };
                _g setCurrentWaypoint (_wps select _nw);
            };

        } else {

            // And if they're in the AO we put them back to what they were when they were forced to return
            _lb = _g getVariable QVAR(lastBehaviour);
            if !(isNil "_lb") then {
                _g setBehaviour _lb;
                _g setVariable [QVAR(lastBehaviour), nil, true];
                {
                    _x enableAI "AUTOCOMBAT";
                    _x enableAI "AUTOTARGET";
                    _x enableAI "TARGET";
                    _x enableAI "FSM";
                    nil;
                } count (units _g);
            };

            // Force Waypoint Completion ? Tigris' don't follow
            if (typeOf _x isKindOf "APC_Tracked_02_base_F") then {
                // If we're close to the current waypoint, or we're entirely stationary, move to next WP
                if ( waypointPosition _cwp distance2D _v < _cwpcr || { velocity _x isEqualTo [0,0,0] } ) then {
                    _nw = _cwid + 1;
                    if (_nw > count _wps) then { _nw = 0 };
                    _g setCurrentWaypoint (_wps select _nw);
                };
            };
        };

        nil
    } count _vlist;
}, 2, []] call CBAP_fnc_addPerFrameHandler;