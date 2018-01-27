/*
	author: Martin
	description: none
	returns: nothing
*/

if !(isServer) exitWith {};


[{
    params ["_delay", "_pos", ["_method", "Bo_mk82"], ["_preCode", {}], ["_preCodeArgs", []]];

    _preArgs call _preCode;
    _method createVehicle (_pos vectorAdd [0,0,0.5]);

}, _this, _this select 0] call CBAP_fnc_waitAndExecute;