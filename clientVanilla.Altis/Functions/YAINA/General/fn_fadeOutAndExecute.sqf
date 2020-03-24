/*
Function: YAINA_fnc_fadeOutAndExecute

Description:
	Fade out the screen to black and execute the given code with the given arguments.
    Fade out and fade in time can be adjusted.

Parameters:
	_code - The code we want to execute after the fade out
    _args - The arguments with which the code shall be executed
    _fadeOutTime - The time it takes until the fade out is complete
    _fadeInTime - The time it takes until the fade in is complete

Return Values:
	None

Examples:
    Nothing to see here

Author:
	Martin
*/

params [["_code", {}], ["_args", []], ["_fadeOutTime", 1], ["_fadeInTime", 1]];

[_code, _args, _fadeOutTime, _fadeInTime] spawn {
    params ["_code", "_args", "_fadeOutTime", "_fadeInTime"];


    if (_fadeOutTime > 0) then {
        titleText ["", "BLACK OUT", _fadeOutTime];
        sleep (_fadeOutTime);
    };

    _args call _code;

    titleText ["", "BLACK IN", _fadeInTime];
};