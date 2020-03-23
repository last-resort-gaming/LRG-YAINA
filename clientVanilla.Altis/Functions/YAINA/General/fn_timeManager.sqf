/*
Function: YAINA_fnc_timeManager

Description:
	Initializes the time manager during the postInit phase.
    The time manager is concerned with setting date and time at mission start as well
    as setting the time acceleration depending on the time of day.

Parameters:
	None

Return Values:
	None

Examples:
    Nothing to see here

Author:
	Martin
*/

#include "defines.h"

if !(isServer) exitWith {};

if (isNil "yaina_time_manager_enabled") then { yaina_time_manager_enabled = true; };

if !(yaina_time_manager_enabled) exitWith {
    if(isNil "yaina_default_time_multiplier") then { yaina_default_time_multiplier = 1; };
    setTimeMultiplier yaina_default_time_multiplier;
};

if (isNil "yaina_time_manager_paused") then {
    yaina_time_manager_paused = false;
};

[{
    params ["_args", "_pfhID"];

    _mult = 1;
    if !(yaina_time_manager_paused) then {
        _sunriseSunsetTime = date call BIS_fnc_sunriseSunsetTime;

        // Duration in minutes of the times of day
        _dawnTarget  = 60;
        _dayTarget   = 120;
        _duskTarget  = 60;
        _nightTarget = 20;


        // We just use the general day multiplier if we're in a zone that has no
        // sunrise / sunset times (poles)
        if (_sunriseSunsetTime in [[-1,0],[0,-1]]) then {
            _mult = (60*24) / (_dawnTarget + _dayTarget + _duskTarget + _nightTarget);
        } else {

            _dawnStart  = (_sunriseSunsetTime select 0) - 1;
            _dawnEnd    = (_sunriseSunsetTime select 0) + 1;

            _duskStart = (_sunriseSunsetTime select 1) - 1;
            _duskEnd   = (_sunriseSunsetTime select 1) + 1;

            _cTime = daytime;

            _mult = call {
                if (_cTime < _dawnStart || { _cTime > _duskEnd }) exitWith { (60 * (_dawnStart + (24 - _duskEnd))) / _nightTarget };
                if (_cTime < _dawnEnd) exitWith { (60 * (_dawnEnd - _dawnStart)) / _dawnTarget };
                if (_cTime < _duskStart) exitWith { (60 * ( _duskStart - _dawnEnd)) / _dayTarget };
                (60 * (_duskEnd - _duskStart)) / _duskTarget
            };
        };
    };

    if !(_mult isEqualTo timeMultiplier) then {
        setTimeMultiplier _mult;
    };

}, 60, []] call CBAP_fnc_addPerFrameHandler;
