/*
Function: YAINA_SPAWNS_fnc_helicas

Description:
	Randomly selects a helicopter to provide CAS at the Main AO.
    Uses Main AO faction for selecting the aircraft.

Parameters:
	_pos - The position where which we want the helicopter to go
    _radius - Radius around _pos for selecting the helicopter destination
    _force - Force spawning the helicopter?

Return Values:
	None

Examples:
    Nothing to see here

Author:
	Martin - Author of YAINA_SPAWNS_fnc_CAS
    Matth - Ported to helicopters
    MitchJC - Random Faction Selection
*/

#include "..\defines.h"

private _max = 2;

// Due to the nature of AI helis, and that we don't want tons of them in the air, we only run on server

if !(isServer) exitWith {
    _this remoteExecCall [QFNC(cas), 2];
};

params ["_pos", "_radius", ["_force", false], "_army"];
private ["_type", "_PilotType", "_spawnPos", "_group", "_heli", "_pilot", "_copilot", "_speed", "_dir", "_wp", "_side"];


call {

	_side = east;

	if (_army isEqualto "CSAT") exitwith {
		_type = selectRandom [
			"O_Heli_Light_02_dynamicLoadout_F",
			"O_Heli_Light_02_dynamicLoadout_F",
			"O_Heli_Light_02_dynamicLoadout_F",
			"O_Heli_Light_02_dynamicLoadout_F",
			"O_Heli_Attack_02_dynamicLoadout_F"
		];
		_PilotType = "O_helipilot_F";
	};

	if (_army isEqualto "AAF") exitwith {
		_type = selectRandom [
			"I_Heli_light_03_dynamicLoadout_F"
		];
		_PilotType = "I_helipilot_F";
		_side = resistance;
	};

	if (_army isEqualto "CSAT Pacific") exitwith {
		_type = selectRandom [
			"O_Heli_Light_02_dynamicLoadout_F",
			"O_Heli_Light_02_dynamicLoadout_F",
			"O_Heli_Light_02_dynamicLoadout_F",
			"O_Heli_Light_02_dynamicLoadout_F",
			"O_Heli_Attack_02_dynamicLoadout_F"
		];
		_PilotType = "O_helipilot_F";
	};
};


// We filter any deads here as it's the only time we care about it
if (isNil QVAR(cas)) then {
    GVAR(cas) = [];
} else {
    GVAR(cas) = GVAR(cas) select { alive _x };
};

if (count GVAR(cas) >= _max && { !_force } ) exitWith {};

// Lets spawn us a heli, fly though our calling radio tower position and set up a patrol
// we use delete on enpty group so we don't need to manage this at all once spawned

_spawnPos = [_pos] call FNC(getAirSpawnPos);
_group = createGroup _side;

_heli   = createVehicle [_type, _spawnPos, [], 0, "FLY"];
_pilot = _group createUnit [_PilotType, [0,0,1000], [], 0, "NONE"];
_pilot moveInDriver _heli;

_copilot = _group createUnit [_PilotType, [0,0,1000], [], 0, "NONE"];
_copilot moveInAny _heli;

_heli flyInHeight (100 + (random 200));
_heli allowCrewInImmobile true;
_heli lock 2;

// Point the heli towards our tower, and set it going
_dir = _heli getDir _pos;
_heli setDir _dir;
_speed = (getNumber (configFile >> "CfgVehicles">> _type >> "maxspeed") + getNumber (configFile >> "CfgVehicles" >> _type >> "landingSpeed")) / 2;
_heli setVelocity [sin _dir*(_speed/3.6), cos _dir*(_speed/3.6), 0];

// Add to global
GVAR(cas) pushBack _heli;

// Set a nice little waypoint around the _pos
[_group, "LRG Default", false] call FNC(setUnitSkill);

// Add to zeus
[[_pilot, _copilot, _heli]] call YFNC(addEditableObjects);

// Let them know a heli has spawned
parseText format["<t size='1.5' align='center' color='#FF0808'>Enemy heli Incoming</t><br/>____________________<br/>Watch out, an enemy %1 has just entered the area.</t>", getText(configFile >> "CfgVehicles" >> _type >> "DisplayName")]  call YFNC(globalHint);

// He loves having ammo
_heli addEventHandler ["Fired",{ (_this select 0) setVehicleAmmo 1; }];

// Killed Hint/Points
_heli addEventHandler ["HandleDamage", {
    params ["_unit", "_selection", "_damage", "_source", "_projectile", "_hitPart", "_instigator", "_hitPoint"];

    // If we have a last damage source, use it
    _instigatorReal = _instigator;
    if (_instigator isEqualTo objNull) then {
        if (_source call YFNC(isUAV)) then {
            _instigatorReal = (UAVControl _source) select 0;
        } else {
            _instigatorReal = _unit;
        };
    };

    if !(isNull _instigatorReal) then {
        _unit setVariable[QVAR(damage), _instigatorReal];
    };

}];

_heli addEventHandler ["Killed",{
    params ["_unit", "_killer", "_instigator"];

    // If we have a real killer, use that
    _instigatorReal = _instigator;
    if (_instigator isEqualTo objNull) then {
        if (_killer isKindOf "UAV") then {
            _instigatorReal = (UAVControl _killer) select 0;
        } else {
            _instigatorReal = _killer;
        };
    };

    // If we weren't killed outright then pick who last damaged us...
    if (isNull _instigatorReal || { name _instigatorReal isEqualTo "Error: No unit" }) then {
        _instigatorReal = _unit getVariable [QVAR(damage), objNull];
    };

    // Finally dispatch who dun it
    _name =  [name _instigatorReal, "someone"] select (isNull _instigatorReal || { name _instigatorReal isEqualTo "Error: No unit" });

    parseText format["<t align='center'><t size='1.5' align='center' color='#34DB16'>Enemy heli Destroyed</t><br/>____________________<br/>Nice work! The enemy heli was taken down by %1. Here's %2 Credits for your efforts.</t>", _name, 100]  call YFNC(globalHint);
    [100, "heli"] call YFNC(addRewardPoints);

    // Delete the heli in 5 minutes
    [_unit, 300] call YFNC(deleteVehicleIn);

}];

// To let the AI do it's thing, regarding gun runs etc, we just set it to a SAD and periodically reveal targets in the main AO

[{
    params ["_args", "_pfhID"];
    _args params ["_pos", "_radius", "_group", "_heli"];

    if (!alive _heli) exitWith {

        // Delete the pilot/any other crew, followed by the group
        { deleteVehicle _x; } count (units _group);
        deleteGroup _group;

        _pfhID call CBA_fnc_removePerFrameHandler;
    };

    // Keep the bird in the air
    _heli setFuel 1;

    // Just let the AI know about everyone in the AO to do it's thing
    _units = units _group;
    _pina  = allPlayers select  {
        _p = _x;
        _inArea = _x inArea [_pos, _radius, _radius, 0, false];
        {
            _x reveal [_p, [0, 3] select _inArea];
            nil
        } count _units;
        _inArea
    };

    if !(_pina isEqualTo []) then {

        _group setCombatMode "RED";
        _group setBehaviour "COMBAT";
        _group setSpeedMode "FULL";

        // Pick a random player to go all SAD on
        [_group] call CBA_fnc_clearWaypoints;
        [_group, getPos (selectRandom _pina), 20, "SAD", "COMBAT", "RED"] call CBA_fnc_addWaypoint;
    } else {
        // We should at least stick around the AO on a loiter
        _wps = waypoints _group;

        if ( (count _wps) isEqualTo 0 || { (waypointPosition (_wps select 0)) distance2D _pos > 5 } ) then {
            [_group] call CBA_fnc_clearWaypoints;
            _wp = _group addWaypoint [_pos, 0];
            _wp setWaypointType "LOITER";
            _wp setWaypointLoiterRadius (_radius * 1.5);
            _wp setWaypointBehaviour "COMBAT";
            _wp setWaypointCombatMode "RED";
        };
    };

}, 30, [_pos, _radius, _group, _heli, 0, [_target, _designator]]] call CBA_fnc_addPerFrameHandler;











