/*
	author: Martin
	description: none
	returns: nothing
*/

params ["_veh"];

if (isNil "_veh") exitWith {};
if (isNull _veh)  exitWith {};

private _type = getText(configFile >> "CfgVehicles" >> (typeOf _veh) >> "DisplayName");

if(_veh isKindOf "UAV") then {

    _veh sideChat format ["Servicing %1, This will take at least 10 seconds", _type];

    // First we remove any extra waypoints since if we don't it may try and start running away
    while {(count (waypoints _veh)) > 1} do {
        deleteWaypoint ((waypoints _veh) select 0);
    };
    ((waypoints _veh) select 0) setWPPos position _veh;

    _veh setFuel 0;

    sleep 10 + (floor random 10);

    _veh setDamage 0;
    _veh setFuel 1;
    _veh setVehicleAmmo 1;

    _veh engineOn false;
    _veh sideChat format ["%1 is now ready", _type];

};