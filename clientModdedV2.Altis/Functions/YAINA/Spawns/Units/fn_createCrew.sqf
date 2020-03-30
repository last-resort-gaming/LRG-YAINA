/*
Function: YAINA_SPAWNS_fnc_createCrew

Description:
	Function to fill all crew positions in a vehicle, including turrets.
	In dummy mode no objects are created and the returned array contains only ones.
	In this mode the function can be used to count the actual crew of an existing vehicle or vehicle type.

Parameters:
	_this select 0 - the vehicle (Object)
	_this select 1 - the crew's group (Group)
	_this select 2 - Faction from units.hpp

Return Values:
	Array of Objects or Scalars - newly created crew or crew count

Examples:
	Nothing to see here

Author:
	Joris-Jan van 't Land
*/

//Validate parameter count
if ((count _this) < 2) exitWith {["Log: [spawnCrew] Function requires at least 2 parameters!", "ErrorLog"] call YAINA_fnc_log; []};

params ["_vehicle", "_grp","_factionDefine"];

//Validate parameters
if ((typeName _vehicle) != (typeName objNull)) exitWith {["Log: [spawnCrew] Vehicle (0) must be an Object!", "ErrorLog"] call YAINA_fnc_log; []};
if ((typeName _grp) != (typeName grpNull)) exitWith {["Log: [spawnCrew] Crew group (1) must be a Group!", "ErrorLog"] call YAINA_fnc_log; []};
if ((typeName _factionDefine) != (typeName "")) exitWith {["Log: [spawnCrew] Crew type (4) must be a String!", "ErrorLog"] call YAINA_fnc_log; []};

_type = typeOf _vehicle;

_entry = configFile >> "CfgVehicles" >> _type;
_crew = [];

private ["_hasDriver"];
_hasDriver = getNumber (_entry >> "hasDriver");

// Get Faction approprate units
_crewTypeArray = _factionDefine call {
    if (_this isEqualTo "AAF") exitWith { ["I_Soldier_A_F", "I_Soldier_AAR_F", "I_Soldier_AAA_F", "I_Soldier_AAT_F", "I_Soldier_AR_F", "I_medic_F", "I_engineer_F",
                                                    "I_Soldier_exp_F", "I_Soldier_GL_F", "I_Soldier_M_F", "I_Soldier_AA_F", "I_Soldier_AT_F", "I_officer_F", "I_Soldier_repair_F",
                                                    "I_soldier_F", "I_Soldier_LAT_F", "I_Soldier_lite_F", "I_Soldier_SL_F", "I_Soldier_TL_F" ] };
    []
};

if (_crewTypeArray isEqualTo []) exitWith {
    [format["No crew type for faction; %1", _factionDefine], "ErrorLog"] call YAINA_fnc_log;
};

//Spawn a driver if needed
if ((_hasDriver == 1) && (isNull (driver _vehicle))) then
{
        _crewType = _crewTypeArray call BIS_fnc_selectRandom;
		_unit = _grp createUnit [_crewType, position _vehicle, [], 0, "NONE"];
		_crew = _crew + [_unit];

		_unit moveInDriver _vehicle;
};

//Search through all turrets and spawn crew for these as well.
_turrets = [_entry >> "turrets"] call BIS_fnc_returnVehicleTurrets;

//All turrets were found, now spawn crew for them
_funcSpawnTurrets =
{
	params ["_crewTypeArray", "_vehicle", "_grp", "_crew", "_turrets", "_path"];
    _crewType = _crewTypeArray call BIS_fnc_selectRandom;
	private ["_i"];
	_i = 0;
	while {_i < (count _turrets)} do
	{
		private ["_turretIndex", "_thisTurret"];
		_turretIndex = _turrets select _i;
		_thisTurret = _path + [_turretIndex];

			if (isNull (_vehicle turretUnit _thisTurret)) then
			{
				//Spawn unit into this turret, if empty.
				_unit = _grp createUnit [_crewType, position _vehicle, [], 0, "NONE"];
				_crew = _crew + [_unit];

				_unit moveInTurret [_vehicle, _thisTurret];
			};

		//Spawn units into subturrets.
		[_turrets select (_i + 1), _thisTurret] call _funcSpawnTurrets;

		_i = _i + 2;
	};
};

[_crewTypeArray, _vehicle, _grp, _crew, _turrets, []] call _funcSpawnTurrets;
[_vehicle,"LIEUTENANT"] call bis_fnc_setRank;

_crew
