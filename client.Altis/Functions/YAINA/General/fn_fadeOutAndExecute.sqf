/*
	author: Martin
	description: none
	returns: nothing
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