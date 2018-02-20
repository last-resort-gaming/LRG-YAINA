/*
	author: Martin
	description: none
	returns: nothing
*/

// Takes an array to bundle configClasses

params ["_prefix", "_path"];
private ["_cf", "_ret"];

_ret = [];

// Config File
_cf = configFile >> "CfgFunctions"; { _cf = _cf >> _x } forEach _path;
{
    _ret pushBackUnique format["%1_%2", _prefix, configName _x];
    nil
} count ("true" configClasses _cf);

// Mission Config File
_cf = missionConfigFile >> "CfgFunctions"; { _cf = _cf >> _x } forEach _path;
{
    _ret pushBackUnique format["%1_%2", _prefix, configName _x];
    nil
} count ("true" configClasses _cf);

_ret