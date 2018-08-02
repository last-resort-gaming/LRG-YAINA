/*
Function: YAINA_fnc_AOPos

Description:
	Finds named location for AO to centre around with
	factors such as town or city required factored in.
	Then chooses AO centre from within area.

Parameters
	
	_size - AO size
	_spec - specification from "LAND" (or ""), "CITY", "VILLAGE", "MARINE"
	_min - min distance from centre for objective
	_max - max distance from centre for objective

Return Values:
	_centre - where marker goes over location
	_obj - objective location
	
Examples:

[500, "LAND", 100, 500] call YAINA_fnc_AOPos;

Author:
	Matth & Mitch
*/
if (!isserver) exitwith {};

params ["_size", "_spec", "_min", "_max"];

private ["_inc", "_worldcenter", "_worldSize", "_locs", "_AOCentre"];

_inc = [];

call {
	if (_spec isEqualto "LAND") exitwith {
		_inc = ["Name", "NameCityCapital", "NameCity", "NameVillage", "NameLocal"];
	};
  
	if (_spec isEqualto "CITY") exitwith {
		_inc = ["NameCityCapital", "NameCity"];
	};
  
	if (_spec isEqualto "VILLAGE") exitwith {
		_inc = ["NameVillage", "NameLocal"];
	};
  
	if (_spec isEqualto "MARINE") exitwith {
		_inc = ["NameMarine"];
	};
};

if (_inc isEqualto []) exitwith {};

_worldcenter = getArray (configfile >> "CfgWorlds" >> worldName >> "centerPosition");
_worldsize = getnumber (configfile >> "CfgWorlds" >> worldName >> "mapSize");
_locs = nearestLocations [_worldcenter, _inc, _worldsize];

_AOCentre = [0,0];

_nul = while { _AOCentre isEqualTo [0,0] } do {

	_AOCentre = [_locs, ([_size] call YAINA_MM_fnc_getAOExclusions) + ["water"], {
		{ _x distance2D _this < (_size * 2) } count allPlayers isEqualTo 0 && !(_this isFlatEmpty [-1,-1,0.25,25,0,false,objNull] isEqualTo [])
  }] call BIS_fnc_randomPos;
};

_AOCentre