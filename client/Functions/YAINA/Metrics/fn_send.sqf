/*
	author: Martin
	description: none
	returns: nothing
*/

#include "defines.h"

params ["_metric", "_value", ["_global", false]];

params ["_metric", "_value", ["_global", false]];
private _metricPath = [format["%1.%2", "eu.yaina.eu1.hosts", profileName], "eu.yaina.eu1.global"] select _global;
[format["%1.%2", _metricPath, _metric], _value] call a3graphite;
