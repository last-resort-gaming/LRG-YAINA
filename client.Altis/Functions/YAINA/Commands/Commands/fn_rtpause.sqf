/*
	author: Martin
	description: none
	returns: nothing
*/

#include "..\defines.h"

params ["_owner", "_caller", "_argStr"];

private _msg = "";

// Curious case, we must log here, due to the impending restart
if (yaina_time_manager_paused) then {
    yaina_time_manager_paused = false;
    real_weather_paused = false;
    _msg  = "RealWeather / Time Compression has been enabled, this may take upto 1 minute to take affect";
} else {
    yaina_time_manager_paused = true;
    real_weather_paused = true;
    _msg = "RealWeather / Time Compression have been disabled, this may take upto 1 minute to take affect";
};

publicVariable "yaina_time_manager_paused";
publicVariable "real_weather_paused";

// Let Admins know
[_caller, _msg, 3] call FNC(notifyAdmins);

_msg