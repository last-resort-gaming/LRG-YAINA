/*
Function: YAINA_fnc_AOPos

Description:
	Finds named location for AO to centre around with
	factors such as town or city required factored in.
	Then chooses AO centre from within area.

Parameters

	_size - AO size
	_spec - specification from "LAND", "CITY", "VILLAGE", "MARINE"
	_objSpec - specification from "FLAT", "BUILDING", "ROAD", "COAST"

Return Values:

	_AOobj - objective location
	_AOcentrePos - location position
	_AOCentreName - location name



Examples:

[500, "LAND", "FLAT"] call YAINA_fnc_AOPos;

Author:
	Matth & Mitch
*/

params ["_size", "_spec", "_objSpec"];

private ["_inc", "_worldcenter", "_worldSize", "_locs", "_AOCentre", "_AOCentre", "_AOobj"];

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

_AOobj = [0,0];

call {
	if (_objSpec isEqualTo "FLAT") exitWith {
		_nul = while { _AOobj isEqualTo [0,0] } do {
			_AOobj = [_locs, ([_size] call YAINA_MM_fnc_getAOExclusions) + ["water"], {
				{ _x distance2D _this < (_size * 2) } count allPlayers isEqualTo 0 && !(_this isFlatEmpty [-1,-1,0.25,25,0,false,objNull] isEqualTo [])
		  }] call BIS_fnc_randomPos;
		};
	};

	if (_objSpec isEqualTo "BUILDING") exitWith {
		_nul = while { _AOobj isEqualTo [0,0] } do {
			_AOobj = [_locs, ([_size] call YAINA_MM_fnc_getAOExclusions) + ["water"], {
				{ _x distance2D _this < (_size * 2) } count allPlayers isEqualTo 0
		  }] call BIS_fnc_randomPos;
		};
		_AOobj = getPos (nearestBuilding _AOobj);
	};

	if (_objSpec isEqualTo "ROAD") exitWith {
		_nul = while { _AOobj isEqualTo [0,0] } do {
			_AOobj = [_locs, ([_size] call YAINA_MM_fnc_getAOExclusions) + ["water"], {
				{ _x distance2D _this < (_size * 2) } count allPlayers isEqualTo 0 && (isOnRoad _this)
		  }] call BIS_fnc_randomPos;
		};
	};

	if (_objSpec isEqualTo "COAST") exitWith {
		_nul = while { _AOobj isEqualTo [0,0] } do {
			_AOobj = [_locs, ([_size] call YAINA_MM_fnc_getAOExclusions) + ["water"], {
				{ _x distance2D _this < (_size * 2) } count allPlayers isEqualTo 0 && !(_this isFlatEmpty [-1,-1,0.25,25,0,true,objNull] isEqualTo [])
		  }] call BIS_fnc_randomPos;
		};
	};
};

_AOCentre = nearestLocations [_AOobj, _inc, _size, _AOobj] select 0;

_AOCentreName = text _AOCentre;

_AOcentrePos = position _AOCentre;

[_AOobj, _AOCentrePos, _AOCentreName]