/*
Function: YAINA_fnc_killLog

Description:
	Logs information about an entity's killer, the weapon and projectile used and similar
    information to the server death log.

Parameters:
	_killer - The unit that killed the player
    _projectile - The projectile that killed the player
    _aisDamageType - The type of damage dealt, as handled by AIS
    _sourceWeapon - The weapon from which the projectile originated
    _sourceWeapons - If applicable the complete list of available weapons (for vehicles)
    _vehicle - The vehicle in which the killer was

Return Values:
	None

Examples:
    Nothing to see here

Author:
	Martin
*/

#include "defines.h";

params ["_killer", "_projectile", "_aisDamageType", "_sourceWeapon", "_sourceWeapons", "_vehicle"];
private ["_tmp"];

if (!isServer) exitWith {};

// we expect this only to be called from players
if (remoteExecutedOwner in [0,2]) exitWith {};

_tmp = (allPlayers select { owner _x isEqualTo remoteExecutedOwner } );
if (_tmp isEqualTo []) exitWith {};
private _killed = _tmp select 0;
private _kt = "UNKNOWN";
private _kc = objNull;

// We might not know who the killer is
if !(isNil "_killer" || { isNull _killer }) then {
    // Was the killer AI / Zeus / Player
    private _ko = owner _killer;
    _kt = "AI";

    _tmp = (allPlayers select { owner _x isEqualTo _ko } );
    if (!(_tmp isEqualTo []) && { YAINA_MM_hcList find (name (_tmp select 0)) isEqualTo -1 }) then {
        _kc = _tmp select 0;
        _kt = ["ZEUS", "PLAYER"] select (_kc isEqualTo _killer);
        if (_kc isEqualTo _killed) then { _kt = "SELF"; };
    };
};

// AI     | yaina_m_server_0_hqg:2  | _killed | _msg
// PLAYER | MartinCo (129512508125) | _killed | _msg
// ZEUS   | MartinCo (124124512512) | _killed | _msg
// SELF   | MartinCo (124124512512) | _killed | _msg

// Form up log line
private _log = [format ["type=%1, killed=%2, killedguid=%3, projectile=%4, aistype=%5", _kt, name _killed, getPlayerUID _killed, _projectile, _aisDamageType]];

// We may have _weapon info
if !(isNil "_sourceWeapon") then {
    _log pushBack format["weapon=%1, sourceweapons=%2", _sourceWeapon, _sourceWeapons];
};

if (!isNull _kc) then {
    _log pushBack format["killer=%1, killerguid=%2", name _kc, getPlayerUID _kc];
} else {
    if !(isNil "_killer" || { isNull _killer } ) then {
        _log pushBack format["killer=%1", _killer];
    };
};

if (!isNil "_vehicle" && { !(_vehicle isEqualTo _killer) }) then {
    private _vs = getText(configFile >> "CfgVehicles" >> typeOf _vehicle >> "displayName");
    _log pushBack format["vehicle=%1", _vs];
};

_log = _log joinString ", ";

// If it's zeus, we additionally log to the zeuslog
if (_kt isEqualTo "ZEUS") then {
    [format["event=kill, %1", _log], "zeuslog"] call YFNC(log);
};

[_log, "KillLog"] call YFNC(log);