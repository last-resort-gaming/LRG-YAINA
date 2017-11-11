/*
	author: Martin
	description: none
	returns: nothing
*/

params ["_kind", "_veh", ["_serviceTime", 60], ["_serviceRand", 30]];

if (isNil "_veh") exitWith {};
if (isNull _veh)  exitWith {};

if(_veh isKindOf _kind && !(_veh isKindOf "UAV") && driver _veh isEqualTo player) then {

	_type = getText(configFile >> "CfgVehicles" >> (typeOf _veh) >> "DisplayName");

    _veh sideChat format ["Servicing %1, This will take at least %2", _type, _serviceTime call YAINA_fnc_formatDuration];

    _veh setFuel 0;

    sleep _serviceTime + (floor random _serviceRand);

    _veh setDamage 0;
    _veh setFuel 1;
    _veh setVehicleAmmo 1;

    _veh engineOn false;
    _veh sideChat format ["%1 is now ready", _type];

};