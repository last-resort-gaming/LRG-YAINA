/*
Script: general.sqf

Description:
	General purpose servicing script. Able to deal with most vehicles/aircrafts.

Parameters:
	_kind - The kind of vehicle we are trying to service
    _veh - The actual vehicle object we are servicing
    _serviceTime - The time it takes to service the vehicle
    _serviceRand - Additional max. random service time
    _sideChat - Announce servicing in side chat?
    _allowAny - Allow any vehicle to be serviced?
    _playerDistance - Distance that player needs to be in for servicig to go ahead

Return Values:
	None

Examples:
    Nothing to see here

Author:
	Martin
*/

params ["_kind", "_veh", ["_serviceTime", 60], ["_serviceRand", 30], ["_sideChat", true], ["_allowAny", false], ["_playerDistance", 0]];

if (isNil "_veh") exitWith {};
if (isNull _veh)  exitWith {};

if(_veh isKindOf _kind && !(_veh isKindOf "UAV")) then {

    if !(_allowAny || (driver _veh isEqualTo player)) exitWith {};

	_type = getText(configFile >> "CfgVehicles" >> (typeOf _veh) >> "DisplayName");

    _msg = format ["Servicing %1, This will take at least %2", _type, _serviceTime call YAINA_fnc_formatDuration];

    if(_sideChat) then {
        _veh sideChat _msg;
    } else {
        systemChat _msg;
    };

    _veh setFuel 0;

    sleep _serviceTime + (floor random _serviceRand);

    // Handle player distance
    if (_playerDistance > 0 && _veh distance2D player > _playerDistance) exitWith {
        _msg = format ["Servicing Failed for %1, no longer in range", _type];
        if(_sideChat) then {
            _veh sideChat _msg;
        } else {
            systemChat _msg;
        };
    };

    _veh setDamage 0;
    _veh setFuel 1;
    _veh setVehicleAmmo 1;

    _veh engineOn false;

    _msg = format ["%1 is now ready", _type];
    if(_sideChat) then {
        _veh sideChat _msg;
    } else {
        systemChat _msg;
    }
};