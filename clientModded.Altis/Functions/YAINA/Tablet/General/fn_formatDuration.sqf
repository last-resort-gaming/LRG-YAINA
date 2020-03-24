/*
Function: YAINA_TABLET_fnc_formatDuration

Description:
	Takes in a scalar representing seconds and forms this number into a string 
    representation.

Parameters:
	_in - The number of seconds we want to form up into a string

Return Values:
	String representation of the seconds

Examples:
    Example Output:
      "4 hours 23 minutes"
      "1 minute 30 seconds"
      "43 seconds"

Author:
	Martin
*/

params ["_in"];

_seconds = round(_in);

// Hours
_hours = floor(_seconds / 3600);
_seconds = _seconds - (3600 * _hours);
_hoursString = format ["%1 hour%2", _hours,  ["s", ""] select (_hours isEqualTo 1)];

// Minutes
_minutes = floor(_seconds / 60);
_seconds = _seconds - (60 * _minutes);
_minutesString = format ["%1 minute%2", _minutes,  ["s", ""] select (_minutes isEqualTo 1)];

// Seconds
_secondsString = format ["%1 second%2", _seconds,  ["s", ""] select (_seconds isEqualTo 1)];


if (_hours > 0) exitWith {
    if (_minutes > 0) exitWith {
        format["%1 %2", _hoursString, _minutesString];
    };
    _hoursString;
};

if (_minutes > 0) exitWith {
    if (_seconds > 0) exitWith {
        format["%1 %2", _minutesString, _secondsString];
    };
    _minutesString;
};

_secondsString