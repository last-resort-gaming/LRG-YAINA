/*
Function: YAINA_METRICS_fnc_send

Description:
	Sends the passed information to the a3graphite instance, which
	then handles transmitting the information to the web server.

Parameters:
	_metric - Reference of the metric we are sending
	_value - The value of the metric which we are transmitting
	_global - Are we handling a global metric?

Return Values:
	None

Examples:
    Nothing to see here

Author:
	Martin
*/

#include "defines.h"

params ["_metric", "_value", ["_global", false]];

params ["_metric", "_value", ["_global", false]];
private _metricPath = [format["%1.%2.%3", A3GRAPHITE_PREFIX, "hosts", profileName], format["%1.%2", A3GRAPHITE_PREFIX, "global"]] select _global;
[format["%1.%2", _metricPath, _metric], _value] call a3graphite;
