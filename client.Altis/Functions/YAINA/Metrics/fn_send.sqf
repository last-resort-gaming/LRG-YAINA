/*
	author: Martin
	description: none
	returns: nothing
*/

#include "defines.h"

params ["_metric", "_value", ["_global", false]];

params ["_metric", "_value", ["_global", false]];
private _metricPath = [format["%1.%2.%3", A3GRAPHITE_PREFIX, "hosts", profileName], format["%1.%2", A3GRAPHITE_PREFIX, "global"] select _global;
[format["%1.%2", _metricPath, _metric], _value] call a3graphite;
