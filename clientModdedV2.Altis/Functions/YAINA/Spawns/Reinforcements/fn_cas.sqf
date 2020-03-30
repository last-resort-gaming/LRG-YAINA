/*
Function: YAINA_SPAWNS_fnc_cas

Description:
	Spawn a randomly selected jet to provide CAS in the Main AO.
    Uses the Main AO faction for selecting a fitting aircraft.

Parameters:
	_pos - The position where which we want the jet to go
    _radius - Radius around _pos for selecting the jet destination
    _force - Force spawning the jet?

Return Values:
	None

Examples:
    Nothing to see here

Author:
	Martin - Main Author
    Mitch - Random Faction Selection
*/

#include "..\defines.h"

private _max = 2;

// Due to the nature of AI jets, and that we don't want tons of them in the air, we only run on server

if !(isServer) exitWith {
    _this remoteExecCall [QFNC(cas), 2];
};

params ["_pos", "_radius", ["_force", false], "_army"];
private ["_type", "_PilotType", "_spawnPos", "_group", "_jet", "_pilot", "_speed", "_dir", "_wp", "_side"];


_army call {

	_side = east;

	if (_this isEqualto "CSAT") exitwith {
		_type = selectRandom [
			"O_Plane_Fighter_02_F",         // To-201 Shikra
			"O_Plane_Fighter_02_Stealth_F", // To-201 Shikra (Stealth)
			"O_Plane_Fighter_02_Cluster_F", // To-201 Shikra (Cluster)
			"O_Plane_CAS_02_F",             // To-199 Neophron (CAS)
			"O_Plane_CAS_02_F",             // To-199 Neophron (CAS)
			"O_Plane_CAS_02_Cluster_F"      // To-199 Neophron (Cluster)
		];
		_PilotType = "O_pilot_F";
        [_type, _PilotType, east];
	};

	if (_this isEqualto "AAF") exitwith {
		_type = selectRandom [
			"I_Plane_Fighter_03_AA_F",      // A-143 Buzzard (AA)
			"I_Plane_Fighter_03_AA_F",		// A-143 Buzzard (AA)
			"I_Plane_Fighter_03_CAS_F",     // A-143 Buzzard (CAS)
			"I_Plane_Fighter_03_CAS_F",		// A-143 Buzzard (CAS)
			"I_Plane_Fighter_03_Cluster_F", // A-143 Buzzard (Cluster)
			"I_Plane_Fighter_03_Cluster_F",	// A-143 Buzzard (Cluster)
			"I_Plane_Fighter_04_F"			// A-149 Gryphon
		];
		_PilotType = "I_pilot_F";
		[_type, _PilotType, resistance];
	};

	if (_this isEqualto "CSAT Pacific") exitwith {
		_type = selectRandom [
			"O_Plane_Fighter_02_F",         // To-201 Shikra
			"O_Plane_Fighter_02_Stealth_F", // To-201 Shikra (Stealth)
			"O_Plane_Fighter_02_Cluster_F", // To-201 Shikra (Cluster)
			"O_Plane_CAS_02_F",             // To-199 Neophron (CAS)
			"O_Plane_CAS_02_F",             // To-199 Neophron (CAS)
			"O_Plane_CAS_02_Cluster_F",     // To-199 Neophron (Cluster)
			"O_T_VTOL_02_infantry_dynamicLoadout_F",
			"O_T_VTOL_02_infantry_dynamicLoadout_F"
		];
		_PilotType = "O_T_pilot_F";
        [_type, _PilotType, east];
	};
} params ["_type", "_PilotType", "_side"];

// We filter any deads here as it's the only time we care about it
if (isNil QVAR(cas)) then {
    GVAR(cas) = [];
} else {
    GVAR(cas) = GVAR(cas) select { alive _x };
};

if (count GVAR(cas) >= _max && { !_force } ) exitWith {
    ["Number of active CAS jets exceeded."] call YFNC(log);
};

// Lets spawn us a jet, fly though our calling radio tower position and set up a patrol
// we use delete on enpty group so we don't need to manage this at all once spawned

_spawnPos = [_pos] call FNC(getAirSpawnPos);
_group = createGroup _side;

_jet   = createVehicle [_type, _spawnPos, [], 0, "FLY"];
_pilot = _group createUnit [_PilotType, [0,0,1000], [], 0, "NONE"];
_pilot moveInDriver _jet;

_jet flyInHeight (500 + (random 850));
_jet allowCrewInImmobile true;
_jet lock 2;

// Point the jet towards our tower, and set it going
_dir = _jet getDir _pos;
_jet setDir _dir;
_speed = (getNumber (configFile >> "CfgVehicles">> _type >> "maxspeed") + getNumber (configFile >> "CfgVehicles" >> _type >> "landingSpeed")) / 2;
_jet setVelocity [sin _dir*(_speed/3.6), cos _dir*(_speed/3.6), 0];

// Add to global
GVAR(cas) pushBack _jet;

// Set a nice little waypoint around the _pos
[_group, "LRG Default", false] call FNC(setUnitSkill);

// Add to zeus
[[_pilot, _jet]] call YFNC(addEditableObjects);

// Let them know a jet has spawned
parseText format["<t size='1.5' align='center' color='#FF0808'>Enemy Jet Incoming</t><br/>____________________<br/>Watch out, an enemy %1 has just entered the area.</t>", getText(configFile >> "CfgVehicles" >> _type >> "DisplayName")]  call YFNC(globalHint);

// He loves having ammo
_jet addEventHandler ["Fired",{ (_this select 0) setVehicleAmmo 1; }];

// Killed Hint/Points
_jet addEventHandler ["HandleDamage", {
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

_jet addEventHandler ["Killed",{
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

    parseText format["<t align='center'><t size='1.5' align='center' color='#34DB16'>Enemy Jet Destroyed</t><br/>____________________<br/>Nice work! The enemy Jet was taken down by %1. Here's %2 Credits for your efforts.</t>", _name, 100]  call YFNC(globalHint);
    [100, "jet"] call YFNC(addRewardPoints);

    // Delete the jet in 5 minutes
    [_unit, 300] call YFNC(deleteVehicleIn);

}];

// DEBUG: Log this for the future and to see if issues persist
[format ["CAS: Jet has been spawned at %1, unit is %2", _spawnPos, _jet]] call YFNC(log);

// To let the AI do it's thing, regarding gun runs etc, we just set it to a SAD and periodically reveal targets in the main AO

[{
    params ["_args", "_pfhID"];
    _args params ["_pos", "_radius", "_group", "_jet"];

    if (!alive _jet) exitWith {

        // DEBUG: Log this too
        [format ["Jet %1 has been killed", _jet]] call YFNC(log);

        // Delete the pilot/any other crew, followed by the group
        { deleteVehicle _x; } count (units _group);
        deleteGroup _group;

        _pfhID call CBA_fnc_removePerFrameHandler;
    };

    // Keep the bird in the air
    _jet setFuel 1;

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

}, 30, [_pos, _radius, _group, _jet]] call CBA_fnc_addPerFrameHandler;











