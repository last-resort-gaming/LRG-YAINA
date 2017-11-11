/*
	author: Martin
	description: none
	returns: nothing
*/

params ["_veh"];

private _serviceTime = 60;
private _serviceRand = 30;

if (isNil "_veh") exitWith {};
if (isNull _veh)  exitWith {};

if(_veh isKindOf "UAV") then {

	_type = getText(configFile >> "CfgVehicles" >> (typeOf _veh) >> "DisplayName");

    _veh sideChat format ["Servicing %1, This will take at least %2", _type, _serviceTime call YAINA_fnc_formatDuration];

    // First we remove any extra waypoints since if we don't it may
    // try and start running away and set the last one to ourselves.
    while {(count (waypoints _veh)) > 1} do {
        deleteWaypoint ((waypoints _veh) select 0);
    };
    ((waypoints _veh) select 0) setWPPos position _veh;

    _veh setFuel 0;

    sleep _serviceTime + (floor random _serviceRand);

    _veh setDamage 0;
    _veh setFuel 1;
    _veh setVehicleAmmo 1;

    _veh engineOn false;
    _veh sideChat format ["%1 is now ready", _type];

};