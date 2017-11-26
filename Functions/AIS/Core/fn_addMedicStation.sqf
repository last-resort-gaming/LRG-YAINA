/*
	author: Martin
	description: none
	returns: nothing
*/

params ["_station", "_range"];

// If the item has no FAK cargo, do nothing.
private _cargo      = getItemCargo _station;
private _medikitIDX = (_cargo select 0) find "FirstAidKit";
if (_medikitIDX isEqualTo -1) exitWith { false };

// And it's not already in the array
if !(((ais_mobile_medic_stations select 0) find _station) isEqualTo -1) exitWith { true; };

// Might as well do the cleanup here of destroyed stations as we'll be submitting the var
ais_mobile_medic_stations = ais_mobile_medic_stations select { !isNull (_x select 0) && alive (_x select 0) };

// Add to the public array
ais_mobile_medic_stations pushBack [_station, _range];
publicVariable "ais_mobile_medic_stations";

true