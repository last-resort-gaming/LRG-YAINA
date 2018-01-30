/*
	author: Martin
	description: none
	returns: nothing
*/

// Dawn   03:30 - 05:30   3.5 -> 5.5
// Day    05:30 - 18:30   5.5 -> 18.5
// Dusk   18:30 - 20:30  18.5 -> 20.5
// Night  20:30 - 03:30  20.5 -> ...

private _dawnMultiplier  = ("DawnDuration"  call BIS_fnc_getParamValue) / 10;
private _dayMultiplier   = ("DayDuration"   call BIS_fnc_getParamValue) / 10;
private _duskMultiplier  = ("DuskDuration"  call BIS_fnc_getParamValue) / 10;
private _nightMultiplier = ("NightDuration" call BIS_fnc_getParamValue) / 10;

[{
    params ["_args", "_pfhID"];
    _args params ["_dawnMultiplier", "_dayMultiplier", "_duskMultiplier", "_nightMultiplier"];

    // Default to night Multiplier
    _cTime = daytime;
    _mTime = _nightMultiplier;

    if (_cTime < 20.5) then {
        if (_cTime > 18.5) then {
            _mTime = _duskMultiplier;
        } else {
            if (_cTime > 5.5) then {
                _mTime = _dayMultiplier;
            } else {
                if (_cTime > 3.5) then {
                    _mTime = _dawnMultiplier;
                };
            };
        };
    };

    if !(_mTime isEqualTo timeMultiplier) then {
        setTimeMultiplier _mTime;
    };

}, 60, [_dawnMultiplier, _dayMultiplier, _duskMultiplier, _nightMultiplier]] call CBAP_fnc_addPerFrameHandler;